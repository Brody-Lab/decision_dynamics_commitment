#include <DrvDebug.h>

#include "ControlList.h"
#include "HalEnv.h"
#include "LinuxInterface.h"
#include "LinuxGlue.h"
#include "HalAdapter.h"
#include "Hal.h"
#include "SharedControls.h"

#define FIRST_PLAY_DEV (WAVE_PLAY0_DEVICE + FIRST_PLAY_CHAN)

// struct for LinuxContext::priv
struct Private
{
  Private() : adapter(0), driverInfo(0) {}
  ~Private() { delete adapter; delete driverInfo; adapter = 0, driverInfo = 0;}
  
  PHALADAPTER adapter;
  PHALDRIVERINFO driverInfo;

  struct SoundBuffer {
    SoundBuffer() : buf(0), loop(false) { mut = rtlinux_lock_create(); }
    ~SoundBuffer() { setNull(); if (mut) rtlinux_lock_destroy(mut); }
    bool isNull() const 
        { return !buf || !num_blocks || !num_chans || !sample_size; }

    void setNull() { buf = 0; num_played = num_blocks = 0; num_chans = 0; loop = false; }
    void lock() { rtlinux_lock(mut); }
    void unlock() { rtlinux_unlock(mut); }

    PVOID buf;
    unsigned long num_blocks; /* A sample block is the size of 1 sample 
                                 for mono or 2 left-right pairs for stereo */
    unsigned long sample_size;
    unsigned num_chans; /* 1 for mono, 2 stereo */

    unsigned long num_played;
    bool loop;
    RTLinux_Lock_t *mut;
  } soundBuf[L22_NUM_CHANS];

};

// helper function
static void CopyAudioToNextDMABuffer(LinuxContext *ctx, PHALDMA dma); // DMA
static void SetupMixer(PHALMIXER mixer); // sets up mixing of 4 channels

USHORT LinuxGlue::FindPCI(PVOID pContext, PPCI_CONFIGURATION pPCI)
{
  LinuxContext *ctx = reinterpret_cast<LinuxContext *>(pContext);
  
  pPCI->usDeviceID = Lynx22DeviceID; // ergh, why didn't CHalAdapter::Find()  do this for us?
  return linux_find_pcidev(ctx, pPCI->usVendorID, pPCI->usDeviceID);
}

USHORT LinuxGlue::AllocateDMA(PVOID pCtx, PVOID *pVAddr, PVOID *pPAddr,
                              ULONG ulLength, ULONG ulAddressMask)
{
  // TODO: Handle addressmask here..
  (void)ulAddressMask;
  LinuxContext *ctx = reinterpret_cast<LinuxContext *>(pCtx);
  void *virt;
  unsigned long phys;

  DEBUG_MSG("LinuxGlue::AllocateDMA() ulAddressMask is: %08lx\n", ulAddressMask);

  USHORT ret = linux_allocate_dma_mem(ctx, &virt, &phys, ulLength); 
  if ( 0 == ret ) {
    ctx->dma.DBL.len = ulLength;
    ctx->dma.DBL.virt = virt;
    ctx->dma.DBL.phys = phys;
    *pVAddr = static_cast<PVOID>(ctx->dma.DBL.virt);
    *pPAddr = reinterpret_cast<PVOID>(ctx->dma.DBL.phys);
    // clear the memory
    memset(virt, 0, ulLength);
  }
  return ret;
}

USHORT LinuxGlue::FreeDMA(PVOID pCtx, PVOID pMemory)
{
  LinuxContext *ctx = reinterpret_cast<LinuxContext *>(pCtx);
  if (pMemory != ctx->dma.DBL.virt) {
    WARNING("LinuxGlue::FreeDMA called with an unknown pointer!\n");
    return HSTATUS_INVALID_PARAMETER;
  }
  USHORT ret = linux_free_dma_mem(ctx, ctx->dma.DBL.virt, ctx->dma.DBL.phys, ctx->dma.DBL.len);
  ctx->dma.DBL.virt = 0;
  ctx->dma.DBL.phys = 0;
  ctx->dma.DBL.len = 0;
  return ret;
}

USHORT LinuxGlue::MapIO( PVOID pContext, PPCI_CONFIGURATION pPCI )
{
  int ok = 0;
  LinuxContext *ctx = reinterpret_cast<LinuxContext *>(pContext);
  for (int bar = 0; bar < MAX_PCI_ADDRESSES; ++bar) {
    unsigned long phys, len;
    void *vaddr =  linux_map_io(ctx, bar, &phys, &len);    
    PCI_BASEADDRESS & base =  pPCI->Base[bar]; // reference..
    if (vaddr) {
      // save values in PCI_CONFIGURATION... 
      base.ulPhysicalAddress = phys;
      base.ulAddress = reinterpret_cast<ULONG>(vaddr);
      base.ulSize = len;
      base.usType = PCI_BARTYPE_MEM; // erm it's all memory mapped, right?!
      ++ok;
    }
  }
  return ok == 0;
}

USHORT LinuxGlue::UnmapIO( PVOID pContext, PPCI_CONFIGURATION pPCI )
{
  LinuxContext *ctx = reinterpret_cast<LinuxContext *>(pContext);
  for (int bar = 0; bar < MAX_PCI_ADDRESSES; ++bar) {
    PCI_BASEADDRESS & base =  pPCI->Base[bar]; // reference..
    if (base.ulAddress)
      linux_unmap_io(ctx, reinterpret_cast<void *>(base.ulAddress));
  }
  return 0;
}

PHALADAPTER LinuxGlue::GetHalAdapter(PVOID pContext, ULONG ulAdapterNum)
{
  (void)ulAdapterNum;
  LinuxContext *ctx = reinterpret_cast<LinuxContext *>(pContext);
  if (ctx && ctx->priv)
    return ctx->priv->adapter;
  return 0;
}

void *operator new(unsigned int size)
{
  return linux_allocate(size);
}

void operator delete(void *p)
{
  linux_free(p);
}

void *operator new[](unsigned int size)
{
  return linux_allocate(size);
}

void operator delete[](void *p)
{
  linux_free(p);
}

static inline bool DMABuffersAreAvailable(LinuxContext *ctx,
                                          PHALDEVICE dev,
                                          PHALDMA dma)
{
  return 
    dev->IsRunning()
    && dma->GetNumberOfEntries() < NUM_BUFFERS_PER_STREAM
    && dma->GetNumberOfEntries() < NUM_DMA_AUDIO_BUFS;
}

extern "C" {

  /* Stuff for Linux module to call into C++ code.. */
  unsigned short LynxStartup(LinuxContext *ctx) { 
    ctx->priv = new Private;
    if (!ctx->priv) {
      ERROR("LinuxGlue::LynxStartup CHalAdapter::Open() could not allocate Private data!\n");
      return HSTATUS_INSUFFICIENT_RESOURCES;
    }

    PHALDRIVERINFO driverInfo; // alias variable..
    driverInfo = ctx->priv->driverInfo = new HALDRIVERINFO; 
    if (!driverInfo) {
      ERROR("LinuxGlue::LynxStartup CHalAdapter::Open() could not allocate HalDriverInfo data!\n");
      LynxCleanup(ctx);
      return HSTATUS_INSUFFICIENT_RESOURCES;      
    }
    driverInfo->pFind = LinuxGlue::FindPCI;
    driverInfo->pMap = LinuxGlue::MapIO;
    driverInfo->pUnmap = LinuxGlue::UnmapIO;
    driverInfo->pGetAdapter = LinuxGlue::GetHalAdapter;
    driverInfo->pAllocateMemory = LinuxGlue::AllocateDMA;
    driverInfo->pFreeMemory = LinuxGlue::FreeDMA;
    driverInfo->pContext = reinterpret_cast<PVOID>(ctx);
    PHALADAPTER adapter; // alias for ctx->priv->adapter...
    adapter = ctx->priv->adapter = new CHalAdapter(driverInfo, ctx->adapter_num);
    if (!adapter) {
      LynxCleanup(ctx);
      return HSTATUS_INSUFFICIENT_RESOURCES;
    }
    
    unsigned short retval = adapter->Open(false);
    if (retval != HSTATUS_OK) {
      ERROR("LinuxGlue::LynxStartup CHalAdapter::Open() returned error: %hu!\n", retval);
      LynxCleanup(ctx);
      return retval;
    }

    // NB: autorecalibrate is normally a good thing for accuracy
    // but it happens to cause the device to play silence for 1000 DWORDs
    // when the sampling rate changes.. which is really unacceptable.
    // TODO/HACK: experiment with this enabled, disabled, and also see about 
    // handling sampling rate changes more gracefully..
    adapter->SetAutoRecalibrate(false);

    SetupMixer(adapter->GetMixer());
    
    memset(ctx->dma.audio, 0, sizeof(ctx->dma.audio));

    // paranoia
#   if NUM_DMA_AUDIO_BUFS > NUM_BUFFERS_PER_STREAM
#     error NUM_DMA_AUDIO_BUFS > NUM_BUFFERS_PER_STREAM!
#   endif
    for (unsigned i = 0; !retval && i < L22_NUM_CHANS; ++i)
      for (unsigned j = 0; !retval && j < NUM_DMA_AUDIO_BUFS; ++j) {
        struct MemRegion & mem = ctx->dma.audio[i][j];
        mem.len = DMABufferSize; // DMABufferSize comes from dma_size= module param
        retval = linux_allocate_dma_mem(ctx, &mem.virt, &mem.phys, mem.len);
        if (retval) {
          retval = HSTATUS_INSUFFICIENT_RESOURCES;
          break;
        }
        memset(mem.virt, 0, mem.len);
      }
    
    if (retval) 
      LynxCleanup(ctx);    
    
    return retval;
  }

  void LynxCleanup(LinuxContext *ctx) 
  { 
    if (!ctx) return;

    if (ctx->priv) {
      if (ctx->priv->adapter)
        ctx->priv->adapter->Close(false);
      delete ctx->priv;
      ctx->priv = 0;
    }
    for (unsigned i = 0; i < L22_NUM_CHANS; ++i)
      for (unsigned j = 0; j < NUM_DMA_AUDIO_BUFS; ++j) {
        struct MemRegion & mem = ctx->dma.audio[i][j];
        if (mem.virt) {
          linux_free_dma_mem(ctx, mem.virt, mem.phys, mem.len);
          mem.virt = 0;
        }
    }
  }
  
  unsigned short LynxSetAudioBuffer(LinuxContext *ctx,
                                    void *buffer, 
                                    unsigned long nbytes, 
                                    int format_code,
                                    unsigned chan,
                                    int looped)
  {
    if (!ctx) {
      ERROR("LynxSetAudioBuffer called with invalid ctxpointer!\n");
      return HSTATUS_INVALID_PARAMETER; // paranoia..
    }
    if (!ctx->priv || !ctx->priv->adapter) {
      ERROR("LynxSetAudioBuffer called while adapter is not found/open.\n");
      return HSTATUS_ADAPTER_NOT_OPEN;
    }
    if (chan >= L22_NUM_CHANS) {
      ERROR("LynxSetAudioBuffer called with invalid channel id %u.\n", chan);
      return HSTATUS_INVALID_PARAMETER;
    }

    struct Private::SoundBuffer & buf = ctx->priv->soundBuf[chan];
    buf.lock();

    buf.setNull();
   
    if (!buffer || !nbytes)
    {
        buf.unlock();
        return HSTATUS_OK;
    }    

    buf.num_chans = (format_code&FMT_STEREO) ? 2 : 1 ;
    int format_code_no_chanspec = format_code&0x3;
    switch (format_code_no_chanspec) {
    case FMT_PCM8: buf.sample_size = 1; break;
    case FMT_PCM16: buf.sample_size = 2; break;
    case FMT_PCM24: buf.sample_size = 3; break;
    case FMT_PCM32: buf.sample_size = 4; break;      
    default: 
      ERROR("LynxSetAudioBuffer called with invalid format %d!\n", format_code_no_chanspec);
      buf.unlock();
      return HSTATUS_INVALID_PARAMETER; 
      break;
    }

    buf.num_blocks = nbytes / (buf.sample_size*buf.num_chans);
    buf.num_played = 0;
    buf.loop = looped;

    // for now we use 1 hardcoded format and just do an error check
//     PHALWAVEDMADEVICE dev = ctx->priv->adapter->GetWaveDMADevice(chan + FIRST_PLAY_DEV);    
//     USHORT status = HSTATUS_OK;
//     status = dev->SetFormat(WAVE_FORMAT_PCM, // PCM
//                             buf.num_chans,  // number of channels 1 or 2
//                             ctx->sampling_rate, // rate in HZ
//                             buf.sample_size*8, // bits per sample.. 
//                             buf.sample_size*buf.num_chans ); // block alignment
//     if (status) {
//       ERROR("CHalWaveDMADevice::SetFormat returned %hu!\n", status);
//       buf.unlock();
//       return status;
//     }

    if (buf.num_chans != 2 
        || buf.sample_size*8 != 32 
        || buf.sample_size*buf.num_chans != 8) 
    {
        ERROR("Due to implementation limitations, only 32-bit signed stereo PCM format buffers are supported!\n");
        buf.unlock();
        return HSTATUS_INVALID_PARAMETER;      
    }


    buf.buf = reinterpret_cast<PVOID>(buffer);
    buf.unlock();
    
    return HSTATUS_OK;
  }
  
  unsigned short LynxPlay(LinuxContext *ctx, unsigned chan)
  {
    DEBUG_MSG("LynxPlay called with chan %u\n", chan);
    if (!ctx) return HSTATUS_INVALID_PARAMETER; // paranoia..
    if (!ctx->priv) {
      ERROR("LynxPlay called while adapter is not found/open.\n");
      return HSTATUS_ADAPTER_NOT_OPEN;
    }
    if (chan == L22_ALL_CHANS) { // handle ALL_CHANS case..
      for (unsigned i = 0; i < L22_NUM_CHANS; ++i) {
        USHORT ret = LynxPlay(ctx, i); // call myself for each chan
        if (ret != HSTATUS_OK) return ret;
      }
      return HSTATUS_OK;
    }
    if ( chan >= L22_NUM_CHANS) {
      ERROR("LynxPlay called with invalid channel id %u.\n", chan);
      return HSTATUS_INVALID_PARAMETER;
    }
   
    struct Private::SoundBuffer & buf = ctx->priv->soundBuf[chan];
    buf.lock();
    buf.num_played = 0; // tell engine to start from beginning.. 
    buf.unlock();

    if (LynxIsPlaying(ctx, chan)) return HSTATUS_OK;

    USHORT ret = HSTATUS_OK;

    /* Driver was loaded with DMA to copy data around.. */
    PHALWAVEDMADEVICE dev = ctx->priv->adapter->GetWaveDMADevice(chan + FIRST_PLAY_DEV);
    PHALDMA dma = dev->GetDMA();
    
    // Make sure that the dma subsystem has at least one buffer to process
    // Note that we don't fill all DMA buffers yet as we want the play command
    // to start as soon as possible.  The remaining DMA buffers will be filled
    // by the interrupt handler (InterruptCallback()).
    if (dma->GetNumberOfEntries() == 0)
      CopyAudioToNextDMABuffer(ctx, dma);
        
    dev->SetAutoFree(false);
    
    // for now, we hardcode 1 format into the always-playing stream
    dev->SetFormat(WAVE_FORMAT_PCM, // format code
                   2, // 2 channels (stereo)
                   SampleRate, // sampling rate
                   32, // bits per sample
                   8); // block alignment

    // Start it, param DoPreloads specifies if DMA preload should occur in
    // the card.  Since we wait synchronously for preloads to
    // complete, for realtime drivers the DoPreloads param should be false..
    ret = dev->Start( false ); 
            
    return ret;
  }

  unsigned short LynxStop(LinuxContext *ctx, unsigned chan)
  {
    if (!ctx) return HSTATUS_INVALID_PARAMETER; // paranoia..
    if (!ctx->priv) {
      ERROR("LynxStop called while adapter is not found/open.\n");
      return HSTATUS_ADAPTER_NOT_OPEN;
    }
    if (chan == L22_ALL_CHANS) { // handle ALL_CHANS case..
      for (unsigned i = 0; i < L22_NUM_CHANS; ++i) {
        USHORT ret = LynxStop(ctx, i); // call myself for each chan
        if (ret != HSTATUS_OK) return ret;
      }
      return HSTATUS_OK;
    }
    if ( chan >= L22_NUM_CHANS) {
      ERROR("LynxStop called with invalid channel id %u.\n", chan);
      return HSTATUS_INVALID_PARAMETER;
    }

    USHORT status = HSTATUS_OK;


    struct Private::SoundBuffer & buf = ctx->priv->soundBuf[chan];
    buf.lock();
    buf.num_played = 0;
    buf.unlock();

    PHALWAVEDMADEVICE dev = ctx->priv->adapter->GetWaveDMADevice(chan + FIRST_PLAY_DEV);
    status = dev->Stop();

    return status;
  }

  void LynxPresetSamplingRate(LinuxContext *ctx)
  {
    //PlayInitialSilence(ctx);

    // NB: no need to play initial silence.. just set the clock and
    // 1000 DWORDs later the mixer will come back on after it settles.
    if (ctx && ctx->priv && ctx->priv->adapter) {
      ctx->priv->adapter->GetSampleClock()->Set(SampleRate);
      long actualRate = 0;
      ctx->priv->adapter->GetSampleClock()->Get(&actualRate);
      if ((long)SampleRate != actualRate)
        WARNING("Actual sampling rate of %ld differs from requested rate of %u!\n", actualRate, SampleRate);
      SampleRate = actualRate; // comes from global var.. 
    }
  }
  
  ULONG LynxGetVolume(LinuxContext *ctx, unsigned chan)
  {
    ULONG volL = 0, volR = 0;
    if (ctx && ctx->priv && ctx->priv->adapter && chan < L22_NUM_CHANS) {
      PHALMIXER mix = ctx->priv->adapter->GetMixer();
      if (!mix) {
        ERROR("CHalAdapter::GetMixer() returned a NULL pointer!\n");
        return 0;
      }

      mix->GetControl(LINE_OUT_1, LINE_PLAY_MIXA + chan, CONTROL_VOLUME, 0, &volL);
      mix->GetControl(LINE_OUT_2, LINE_PLAY_MIXA + chan, CONTROL_VOLUME, 0, &volR);
      if (volL != volR) 
        WARNING("LynxGetVolume() Left Volume != Right Volume!  Using Left volume for now.\n");

    }
    return volL;
  }

  int LynxSetVolume(LinuxContext *ctx, unsigned chan, ULONG volume)
  {
    if (volume > MAX_VOLUME) volume = MAX_VOLUME;
    if (ctx && ctx->priv && ctx->priv->adapter) {
      if (chan == L22_ALL_CHANS) {
        int retval = 0;
        // handle "all channels" case...
        for (chan = 0; chan < L22_NUM_CHANS; ++chan) 
          retval |= LynxSetVolume(ctx, chan, volume);          
        
        return retval;
      } else  if (chan >= L22_NUM_CHANS) {
        ERROR("LynxSetVolume() got an invalid channel id %u!\n", chan);
        return HSTATUS_INVALID_PARAMETER;
      }
      // handle normal case of a valid channel id
      PHALMIXER mix = ctx->priv->adapter->GetMixer();


      mix->SetControl(LINE_OUT_1, LINE_PLAY_MIXA + chan, CONTROL_VOLUME, 0, volume);
      mix->SetControl(LINE_OUT_2, LINE_PLAY_MIXA + chan, CONTROL_VOLUME, 0, volume);

      return HSTATUS_OK; 
    }
    return HSTATUS_INVALID_PARAMETER;
  }

  int LynxIsPlaying(LinuxContext *ctx, unsigned chan)
  {
    if (ctx && ctx->priv && ctx->priv->adapter 
        && (chan < L22_NUM_CHANS || chan == L22_ALL_CHANS) ) 
    {
      if (chan == L22_ALL_CHANS) 
      { // handle ALL_CHANS case..
        for (unsigned i = 0; i < L22_NUM_CHANS; ++i) 
        {
          // call myself for each chan, if any are playing, break and return true
          if (LynxIsPlaying(ctx, i)) return 1; 
        }
        return 0;
      }
      // normal case of chan < L22_NUM_CHANS...
      PHALDEVICE dev = ctx->priv->adapter->GetWaveDevice(FIRST_PLAY_DEV + chan);
      int ret = dev->IsRunning();
      return ret;
    }

    return 0;
  }

  int LynxMixerOverflowed(LinuxContext *ctx) 
  {
    if (ctx && ctx->priv && ctx->priv->adapter) {
      PHALMIXER mix = ctx->priv->adapter->GetMixer();
      ULONG val1 = 0, val2 = 0;
      mix->GetControl(LINE_OUT_1, LINE_NO_SOURCE, CONTROL_OVERLOAD, 0, &val1);
      mix->GetControl(LINE_OUT_2, LINE_NO_SOURCE, CONTROL_OVERLOAD, 0, &val2);
      mix->SetControl(LINE_OUT_1, LINE_NO_SOURCE, CONTROL_OVERLOAD, 0, 0);
      mix->SetControl(LINE_OUT_2, LINE_NO_SOURCE, CONTROL_OVERLOAD, 0, 0);
      return val1+val2;
    }
    return 0;    
  }

} // end extern "C"

static void CopyAudioToNextDMABuffer(LinuxContext *ctx, PHALDMA dma)
{
      if (!ctx || !ctx->priv) return; // paranoia..
      const unsigned bufno = dma->GetHostBufferIndex() % NUM_DMA_AUDIO_BUFS;
      const unsigned chanNo = dma->GetDeviceNumber() - FIRST_PLAY_DEV;
      struct MemRegion & mem = ctx->dma.audio[chanNo][bufno];
      struct Private::SoundBuffer & buf = ctx->priv->soundBuf[chanNo];
      buf.lock();

      if (buf.loop && buf.num_played >= buf.num_blocks) {
        // enforce looping here for soundfiles that have the loop flag set
        buf.num_played = 0;
      }
      if (buf.isNull() || buf.num_played >= buf.num_blocks) {
        // the sample ended, just add an empty DMA buffer..
        memset(mem.virt, 0, mem.len);
        dma->AddEntry(reinterpret_cast<PVOID>(mem.phys), mem.len/sizeof(int), false);
        DEBUG_MSG("CopyAudioToNextDMABuffer: added silence entry %u:%u\n", chanNo, bufno);
        buf.unlock();
        return;
      }
      //unsigned space = mem.len / buf.sample_size;
      unsigned space_bytes = (mem.len / (buf.sample_size*buf.num_chans)) * buf.sample_size*buf.num_chans; // ensures space_bytes is in whole blocks
      unsigned num_left_bytes = (buf.num_blocks - buf.num_played) * buf.sample_size*buf.num_chans;
      unsigned num_played_bytes = buf.num_played*buf.sample_size*buf.num_chans;
      if (space_bytes > num_left_bytes) space_bytes = num_left_bytes;
      if (!space_bytes) {
        buf.unlock();        
        return; // ergh?
      }
      memcpy(mem.virt, 
             buf.buf + num_played_bytes,
             space_bytes);
      
      if (space_bytes < mem.len) 
          // zero out the rest of the DMA buffer to avoid playing back parts
          // of the previous sound .. not sure if this fixes some of the 
          // suprious bugs we saw.
          memset(static_cast<char *>(mem.virt) + space_bytes, 
                 0, 
                 mem.len - space_bytes);      

      dma->AddEntry(reinterpret_cast<PVOID>(mem.phys), 
                    space_bytes / sizeof(int), /* Ergh, size param must be in DWORDs.. gross */ 
                    false);
      buf.num_played += space_bytes/(buf.sample_size*buf.num_chans);    
      DEBUG_MSG("LinuxGlue::CopyAudioToNextDMABuffer() copied %lu %d-byte sample-blocks to buffer num %u at %p (phys: %p)\n",
                space_bytes/(buf.sample_size*buf.num_chans), (int)buf.sample_size*buf.num_chans, bufno, mem.virt, (void *)linux_virt_to_phys(mem.virt));
      DEBUG_MSG("LinuxGlue::CopyAudioToNextDMABuffer() Current hardware index for DMA buffers is %d\n", (int)dma->GetDMABufferIndex());
      buf.unlock();
}

static void SetupMixer(PHALMIXER mix)
{
  for (int chan = 0; chan < L22_NUM_CHANS; ++chan) {
    // for each 'chan', associate it with a play stream
    // a chan is actually a LINE_PLAY_MIX in L22 HAL terminology, 
    // we have LINE_PLAY_MIX A-D, for a total of four possible channels in
    // our terminology.
    // LINE_OUT_1 is Left and LINE_OUT_2 is Right output line
    mix->SetControl(LINE_OUT_1, LINE_PLAY_MIXA + chan, CONTROL_SOURCE, 0, MIXVAL_PMIXSRC_PLAY0L + 2*chan);
    mix->SetControl(LINE_OUT_2, LINE_PLAY_MIXA + chan, CONTROL_SOURCE, 0, MIXVAL_PMIXSRC_PLAY0R + 2*chan);
    // our mixers default to off and muted, enable their volumes and unmute 
    // them
    mix->SetControl(LINE_OUT_1, LINE_PLAY_MIXA + chan, CONTROL_VOLUME, 0, L22_MAX_VOLUME);
    mix->SetControl(LINE_OUT_2, LINE_PLAY_MIXA + chan, CONTROL_VOLUME, 0, L22_MAX_VOLUME);
    mix->SetControl(LINE_OUT_1, LINE_PLAY_MIXA + chan, CONTROL_MUTE, 0, 0);
    mix->SetControl(LINE_OUT_2, LINE_PLAY_MIXA + chan, CONTROL_MUTE, 0, 0);
  }
  // clear overflow flags, if any  
  ULONG dummy;
  mix->GetControl(LINE_OUT_1, LINE_NO_SOURCE, CONTROL_OVERLOAD, 0, &dummy);
  mix->GetControl(LINE_OUT_2, LINE_NO_SOURCE, CONTROL_OVERLOAD, 0, &dummy);
  mix->SetControl(LINE_OUT_1, LINE_NO_SOURCE, CONTROL_OVERLOAD, 0, 0);
  mix->SetControl(LINE_OUT_2, LINE_NO_SOURCE, CONTROL_OVERLOAD, 0, 0);
}

void LynxDoDMAPoll(struct LinuxContext *ctx)
{
  int chan;
  for (chan = 0; chan < L22_NUM_CHANS; ++chan) {
    PHALWAVEDMADEVICE dev = ctx->priv->adapter->GetWaveDMADevice(chan + WAVE_PLAY0_DEVICE);
    PHALDMA dma = dev->GetDMA();
#ifdef DEBUG
    ULONG h = dma->GetEntriesInHardware(), e = dma->GetNumberOfEntries();
    DEBUG_MSG("LynxDoDMAPoll: h: %lu  e: %lu  r0: %lu r1: %lu\n", h, e, dma->GetBytesRemaining(0), dma->GetBytesRemaining(1));
    if (dma->IsDMAStarved()) {
      DEBUG_MSG("LynxDoDMAPoll: dma is starved for channel %d\n", chan);
    }
#endif
    // free any used-up entries
    while ( dma->GetEntriesInHardware() < dma->GetNumberOfEntries() ) 
      dma->FreeEntry();
    
    while ( DMABuffersAreAvailable(ctx, dev, dma) ) 
      CopyAudioToNextDMABuffer(ctx, dma);    
  }
}

int LynxIsPlayingSound(LinuxContext *ctx, unsigned chan)
{
  if (chan >= L22_NUM_CHANS) return 0;
  Private::SoundBuffer & buf = ctx->priv->soundBuf[chan];
  buf.lock();
  int ret = LynxIsPlaying(ctx, chan) && !buf.isNull() && buf.num_played < buf.num_blocks;
  buf.unlock();
  return ret;
}

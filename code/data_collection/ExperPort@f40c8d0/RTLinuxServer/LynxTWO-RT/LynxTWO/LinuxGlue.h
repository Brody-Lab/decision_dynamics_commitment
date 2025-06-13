#ifndef LINUX_GLUE_H
#define LINUX_GLUE_H

/* Glue code, mainly intended to glue calling from  Linux into  Lynx C++ HAL */

#include "LynxTWO-RT.h" /* for L22_* defines.. */

#ifdef __cplusplus 

/* C++, these are some functions used as callbacks from HAL to us */

#include "Hal.h"

namespace LinuxGlue
{
  // functions for use as function pointers in HalDevice struct..
  extern USHORT FindPCI(PVOID pContext, PPCI_CONFIGURATION pPCI);
  extern USHORT AllocateDMA( PVOID pCtx, PVOID *pVAddr, PVOID *pPAddr, ULONG ulLength, ULONG ulAddressMask );
  extern USHORT FreeDMA( PVOID pCtx, PVOID pMemory );  

  extern USHORT MapIO( PVOID pContext, PPCI_CONFIGURATION pPCI );
  extern USHORT UnmapIO( PVOID pContext, PPCI_CONFIGURATION pPCI );
  extern PHALADAPTER GetHalAdapter(PVOID pContext, ULONG ulAdapterNum);
}

#endif

#ifdef __cplusplus
extern "C" {
#endif
  /* C -- for .c files to see some variables and functions to call 
     into C++ code.. */
#  define LynxVendorID 0x1621
#  define Lynx22DeviceID 0x0023

  /* All functions that return a value return a HAL Status code from
     HalStatusCodes.h */

  extern unsigned short LynxStartup(LinuxContext *ctx);
  extern void LynxCleanup(LinuxContext *ctx);
  
  /* Format codes for LynxSetAudioBuffer.. */
  enum { FMT_PCM8 = 0, FMT_PCM16 = 1, FMT_PCM24 = 2, FMT_PCM32 = 3, 
	 FMT_STEREO = 0x4, FMT_MONO = 0 };


#  define FIRST_PLAY_CHAN 0 /* absolute channel 8 is OUT chan 0 */

  /* Use this to tell the driver code the soundfile you want to play */
  extern unsigned short LynxSetAudioBuffer(LinuxContext *ctx,
                                           void *buffer, 
                                           unsigned long num_bytes, 
                                           int format_code,
                                           unsigned chan /*0 to L22_NUM_CHANS*/,
                                           int looped);
  extern unsigned short LynxPlay(LinuxContext *, unsigned chan);
  extern unsigned short LynxStop(LinuxContext *, unsigned chan);

  /** Call this to change the sampling rate.  */
  extern void LynxPresetSamplingRate(LinuxContext *);

  /** Returns 0 on success, nonzero on error. Volume should be between 
      0 (mute) and 0xFFFF (maximum volume) */
  extern int LynxSetVolume(LinuxContext *, unsigned chan, unsigned long volume);
  /** Returns the volume as a value between 0 and 0xFFFF. */
  extern unsigned long LynxGetVolume(LinuxContext *, unsigned chan);

  /** Returns true iff Lynx is playing a sound currently on 
      the specified channel. Note that this will almost always return true. */
  extern int LynxIsPlaying(LinuxContext *, unsigned chan);

  /** Returns true iff the specified channel has a valid audio buffer
      and is currently not playing silence. */
  extern int LynxIsPlayingSound(LinuxContext *ctx, unsigned chan);

  /** Returns the overflow count of the mixer since the last call to this 
      function, or 0 if no overflow has ocurred since the last call. */
  extern int LynxMixerOverflowed(LinuxContext *ctx);

  /** Tries to load more data into DMA buffers -- called from realtime loop */
  extern void LynxDoDMAPoll(LinuxContext *ctx);

#ifdef __cplusplus
}
#endif



#endif /* LINUX_GLUE_H */

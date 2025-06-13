#define MODULE_NAME "Lynx22-RT"

#define EXPORT_SYMTAB 1
#include <linux/module.h>
#include <linux/pci.h>
#include <linux/pci_ids.h>
#include <linux/ioport.h>
#include <linux/sched.h>
#include <linux/string.h>
#include <linux/types.h>
#include <linux/slab.h>
#include <linux/vmalloc.h>
#include <linux/spinlock.h>
#include <asm/timex.h> /* for get_cycles() */
#include <asm/atomic.h>
#include <asm/io.h>
#include <asm/page.h>
#include <asm/system.h>
#define HALENV_INTERNAL /* Turn off some #defines that interfere with this file, such as memcpy, etc.. */
#include "HalEnv.h"
#include "LinuxInterface.h"
#include "LinuxGlue.h"
#include "HalStatusCodes.h"

/* Header that contains declarations exported to ksyms (kernel space) */
#include "LynxTWO-RT.h"


#include <rtl.h>
#include <rtl_core.h>
#include <rtl_sync.h>
#include <rtl_sched.h>
#include <rtl_sema.h>
#include <rtl_mutex.h>
#include <rtl_time.h>
#include <posix/time.h>

/* tweak lock granularity.. for now we  lock inside this file and notbut rather
   in LinuxGlue.cpp -- so these do something for now */
/* #  define LOCK_L22(ctx) */
/* #  define UNLOCK_L22(ctx) */
/* #  define YIELD() */
#  define LOCK_L22(ctx)  rtlinux_l22_lock(ctx)
#  define UNLOCK_L22(ctx) rtlinux_l22_unlock(ctx)
#  define YIELD()         rtlinux_yield()


#ifndef STR
#  define STR1(x) #x
#  define STR(x) STR1(x)
#endif

int debug = 0;

ULONG read_register_ulong(volatile const void *pAddr)
{
  ULONG ret = readl(pAddr);
  wmb();
  return ret;
}

void write_register_ulong(volatile void *pAddr, ULONG value)
{
  writel(value, pAddr);
  rmb();
}

void *memset_linux(void *s, int c, unsigned n)
{
  return memset(s, c, n);
}

void *memcpy_linux(void *dest, const void *src, unsigned n)
{
  return memcpy(dest, src, n);
}

void memcpy_toio_linux(volatile void *dest, void *source, unsigned num)
{
  memcpy_toio(dest, source, num);
}

void memcpy_fromio_linux(void *dest, volatile void *source, unsigned num)
{
  memcpy_fromio(dest, source, num);
}

/* Device discovery function for the HAL */
int linux_find_pcidev(LinuxContext * ctx, unsigned short vendorID, unsigned short deviceID)
{
  return ctx->dev == 0; /*(ctx->dev = pci_find_device(vendorID, deviceID, NULL)) == 0;*/
}

int linux_allocate_dma_mem(LinuxContext *ctx, void **pVirt, unsigned long *pPhys, unsigned long size)
{
  struct pci_pool *pool = ctx->dma.poolDMA;
  dma_addr_t addr;
  if (size == 2048) pool = ctx->dma.pool2k;
  else if (size != DMABufferSize) {
    ERROR("linux_allocate_dma_mem got a request %lu that is not a multiple of the DMA_BUF_SIZE of %lu!\n", size, (unsigned long)DMABufferSize);
    *pVirt = 0;
    *pPhys = 0;
    return 1;
  }
  *pVirt = pci_pool_alloc(pool, SLAB_KERNEL, &addr); /* SLAB_KERNEL means allocation can block.. */
  *pPhys = addr;
  return *pVirt == 0;
}

int linux_free_dma_mem(LinuxContext *ctx, void *virt, unsigned long phys, unsigned long size)
{
  struct pci_pool *pool = ctx->dma.poolDMA;
  if (size == 2048) pool = ctx->dma.pool2k;
  pci_pool_free(pool, virt, phys);
  return 0;
}

void * linux_map_io(LinuxContext *ctx, unsigned bar, unsigned long *phys, unsigned long *len)
{
  void *virt;
  unsigned long start = pci_resource_start(ctx->dev, bar), rlen = pci_resource_len(ctx->dev, bar);
  if (bar >= MAX_REGIONS) return 0;
  if (!start) return 0;
  if (phys) *phys = start;
  if (len) *len = rlen;
  if (pci_request_region(ctx->dev, bar, MODULE_NAME)) return 0;
  virt = ioremap(start, rlen);
  /* save the region in our context so that we can pass correct stuff back to pci_release_region() and iounmap() */
  ctx->regions[bar].virt = virt;
  ctx->regions[bar].phys = start;
  ctx->regions[bar].len = rlen;
  return virt;
}

int linux_unmap_io(LinuxContext *ctx, void *virt)
{
  int bar;
  for (bar = 0; bar < MAX_REGIONS; ++bar) {
    if (ctx->regions[bar].virt == virt) {
      /* found the bar num, need to pass it to pci_release_region().. */
      pci_release_region(ctx->dev, bar);
      iounmap(virt);
      /* clear our saved region info just to be safe.. */
      memset(&ctx->regions[bar], 0, sizeof(ctx->regions[bar]));
      break;
    }
  }
  return bar <= MAX_REGIONS ? 0 : 1;
}

/* It appears kmalloc() is preferred despite its 128KB limitation --
   vmalloc() allocates memory along page boundaries so it doesn't cope
   well with small allocations.. */
void linux_free(void *mem) { kfree(mem); }
void *linux_allocate(unsigned size) { return kmalloc(size, GFP_KERNEL); }

int linux_printk(const char *fmt, ...) 
{
  char print_buf[128];
  int ret;
  va_list args;
  va_start(args, fmt);
  ret = vsnprintf(print_buf, sizeof(print_buf), fmt, args);
  va_end(args);
  print_buf[sizeof(print_buf)-1] = 0;
  rtl_printf("%s", print_buf);
  return ret;
}

static int do_message_print(const char *prepend, const char *fmt, va_list args)
{
  char print_buf1[128 + 16], print_buf2[sizeof(print_buf1)];
  snprintf(print_buf1, sizeof(print_buf1), "%s%s: %s", prepend, MODULE_NAME, fmt);
  vsnprintf(print_buf2, sizeof(print_buf2), print_buf1, args);
  print_buf2[sizeof(print_buf2)-1] = 0;
  return linux_printk("%s", print_buf2);  
}

int linux_message(const char *fmt, ...)
{
  int ret;
  va_list args;
  va_start(args, fmt); 
  ret = do_message_print(KERN_INFO, fmt, args);
  va_end(args);
  return ret;
}

int linux_debug(const char *fmt, ...)
{
  int ret;
  va_list args;
  va_start(args, fmt); 
  ret = do_message_print(KERN_DEBUG, fmt, args);
  va_end(args);
  return ret;
}

int linux_warning(const char *fmt, ...)
{
  int ret;
  va_list args;
  va_start(args, fmt); 
  ret = do_message_print(KERN_WARNING, fmt, args);
  va_end(args);
  return ret;
}

int linux_error(const char *fmt, ...)
{
  int ret;
  va_list args;
  va_start(args, fmt); 
  ret = do_message_print(KERN_ERR, fmt, args);
  va_end(args);
  return ret;
}

unsigned long linux_virt_to_phys(volatile void *address)
{
  return virt_to_phys(address);
}

void linux_microwait(unsigned long micros)
{
  unsigned long t1, t2;
  const unsigned long long us = ((unsigned long long )micros) * 1000ULL;
  rdtscl(t1);  
  do { rdtscl(t2); } while( ((unsigned long long) (t2-t1)) < us );
}

unsigned long long linux_get_cycles(void)
{
  return get_cycles();
}

void linux_memory_barrier(void)
{
  mb();
}

struct L22Lock
{
  pthread_mutex_t mutex;
};

void rtlinux_l22_lock(struct LinuxContext *ctx)
{
  pthread_mutex_lock(&ctx->lock->mutex);
}

void rtlinux_l22_unlock(struct LinuxContext *ctx)
{
  pthread_mutex_unlock(&ctx->lock->mutex);
}

void rtlinux_yield(void)
{
  /* workarounds for buggy rtlinux headers */
#define pre1 1
#define pre2 2
#define pre3 3
#define pre4 4
#if RTLINUX_VERSION_CODE >= RTLINUX_VERSION(3,2,0)
  pthread_yield();
#else 
  sched_yield();
#endif
#undef pre1
#undef pre2
#undef pre3
#undef pre4
}

#define DECLARE_FLAGS(x) rtl_irqstate_t x
#define CLI(x) rtl_no_interrupts(x)
#define STI(x) rtl_restore_interrupts(x)
#define SPIN_LOCK_IRQSAVE(lock,flags) rtl_spin_lock_irqsave(lock, flags)
#define SPIN_UNLOCK_IRQRESTORE(lock,flags) rtl_spin_unlock_irqrestore(lock, flags)

#define linux_no_interrupts(f) CLI(f)
#define linux_restore_interrupts(f) STI(f)


/*---------------------------------------------------------------------------
  Linux Kernel & Module API Stuff
-----------------------------------------------------------------------------*/
#define MINIMUM_DMA_BUF_SIZE (128)
#define MAXIMUM_DMA_BUF_SIZE ((0x1<<24)-1)
#define DEFAULT_DMA_BUF_SIZE (256) /* Testing.. 256 byte DMA buffers enough? */
#define MINIMUM_SAMPLE_RATE (8000)
#define MAXIMUM_SAMPLE_RATE (200000)
#define DEFAULT_SAMPLE_RATE (200000)
int dma_size = DEFAULT_DMA_BUF_SIZE, sample_rate = DEFAULT_SAMPLE_RATE;
/* Variables identical to above, but 'exported' to C++ code via 
   LinuxInterface.h */
unsigned DMABufferSize = 0; 
unsigned SampleRate = 0;

MODULE_AUTHOR("Calin A. Culianu <calin@rtlab.org>");             
#ifdef MODULE_LICENSE
MODULE_LICENSE("GPL");
#endif
MODULE_DESCRIPTION("Lynx22 Limited-Capability Realtime Driver for RTLinux");
static struct pci_device_id pci_table[] __devinitdata = {
  { LynxVendorID, Lynx22DeviceID, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
  { 0 }
};
MODULE_PARM(debug, "i");
MODULE_PARM_DESC(debug, "If set, produce very verbose (and slow) debug output.  Not recommended unless you are a developer. :)  Defaults to 0.");
MODULE_PARM(dma_size, "i");
MODULE_PARM_DESC(dma_size, "The size in bytes of each of the DMA Buffers used for host DMA transfers.  Tweak this to balance out latency versus CPU load versus underrun risk.  The default is good enough for an RTOS-based driver.  Default is "STR(DEFAULT_DMA_BUF_SIZE)".");
MODULE_PARM(sample_rate, "i");
MODULE_PARM_DESC(sample_rate, "The fixed sample rate at which to run the L22 Device for playback.  Default is "STR(DEFAULT_SAMPLE_RATE)".");

/* New device inserted, return >=0 for ok */
static int  do_probe  (struct pci_dev *dev, const struct pci_device_id *id);
static void do_remove(struct pci_dev *dev);

static struct pci_driver driver = { .name = MODULE_NAME, 
                                    .id_table = pci_table, 
                                    .probe = do_probe, 
                                    .remove = do_remove, 
                                    .suspend = 0,
                                    .resume = 0, 
                                    .enable_wake = 0 };

static LinuxContext dev_contexts[L22_MAX_DEVS];
static int num_contexts = 0;
static int did_register_driver = 0;


static int createL22Lock(struct LinuxContext *);
static void destroyL22Lock(struct LinuxContext *);

typedef enum 
{
  NONE = 0,
  SAMPLERATE_CHANGE,
  NOOP,
  EXIT
} ThreadReq;

struct ThreadData
{
  pthread_t thread;
  pthread_cond_t cond; /* associated mutex is the l22 mutex */
  ThreadReq req; 
};

static int createThread(struct LinuxContext *);
static void destroyThread(struct LinuxContext *);
/*  Board rt-thread for managing loading of DMA data  */
static void *deviceThread(void *arg);

static void checkAndSetupModuleParams(void);
void cleanup(void);

int init(void)
{  
  memset(dev_contexts, 0, sizeof(dev_contexts));

  checkAndSetupModuleParams();

  if (pci_module_init(&driver)) {
    WARNING("Lynx22 Device not found, silently ignoring error, but driver is not active!\n");
  } else {
    did_register_driver = 1;
  }

  return 0;
}

void cleanup(void)
{
  if (did_register_driver)
    pci_unregister_driver(&driver);
}

static void checkAndSetupModuleParams(void)
{
  if (dma_size < MINIMUM_DMA_BUF_SIZE || dma_size > MAXIMUM_DMA_BUF_SIZE) {
    LOG_MSG("The specified dma_size %d is outside the acceptable range of %u-%u.  Defaulting to %u.\n", dma_size, MINIMUM_DMA_BUF_SIZE, MAXIMUM_DMA_BUF_SIZE, DEFAULT_DMA_BUF_SIZE);
    dma_size = DEFAULT_DMA_BUF_SIZE;
  }
  if (sample_rate < MINIMUM_SAMPLE_RATE || sample_rate > MAXIMUM_SAMPLE_RATE) {
    LOG_MSG("The specified sample_rate %d is outside the acceptable range of %u-%u.  Defaulting to %u.\n", sample_rate, MINIMUM_SAMPLE_RATE, MAXIMUM_SAMPLE_RATE, DEFAULT_SAMPLE_RATE);
    sample_rate = DEFAULT_SAMPLE_RATE;
  }
  DMABufferSize = dma_size;
  SampleRate = sample_rate;
}

static int do_probe(struct pci_dev *dev, const struct pci_device_id *id)
{
  int status = 0;
  struct LinuxContext *ctx;

  if (!dev) { 
    ERROR("Could not find PCI device %04x:%04x\n", (int)id->vendor, (int)id->device);
    return -ENODEV;
  }

  if (num_contexts >= L22_MAX_DEVS) {
    ERROR("Could not attach L22 Device %s as the driver only supports max %d L22 devices, need to change L22_MAX_DEVS and recompile.  Sorry.. :(.\n", dev->slot_name, L22_MAX_DEVS);
    return -EINVAL;
  }

  ctx = &dev_contexts[num_contexts];
  memset(ctx, 0, sizeof(*ctx));
  ctx->dev = dev;
  ctx->id = id;
  ctx->adapter_num = num_contexts;

  if ( createL22Lock(ctx) ) {
    ERROR("createL22Lock() failed, no memory?\n");
    return -ENOMEM;
  }

  ctx->dma.pool2k = pci_pool_create(MODULE_NAME, ctx->dev, 2048, 2048, 0, SLAB_DMA);
  if (!ctx->dma.pool2k) return -ENOMEM;

  ctx->dma.poolDMA = pci_pool_create(MODULE_NAME, ctx->dev, DMABufferSize, sizeof(int), 0, SLAB_DMA);
  if (!ctx->dma.poolDMA) return -ENOMEM;

  /* PCI devices need to be enabled before they can be used.. */
  pci_enable_device(ctx->dev);
  pci_set_master(ctx->dev);
  
  status = LynxStartup(ctx);
  
  if ( status != 0) {
    ERROR("LynxStartup returned %d, failed to initialize hardware...\n", status);
    do_remove(dev);
    return -EINVAL;
  }
  
  ctx->did_lynx_startup = 1;

  /* NB: Install the handler after doing LynxStartup, so as to 
     avoid null pointer problems, of course of course. */  
  LynxPresetSamplingRate(ctx);

  if ( createThread(ctx) ) {
    ERROR("Creation of Realtime Thread failed!\n");
    do_remove(dev);
  }

  LOG_MSG("Found L22 device %s, activated.\n", ctx->dev->slot_name);
  ++num_contexts;
  return 0;
}

static void do_remove(struct pci_dev *dev)
{
  int i;
  struct LinuxContext *ctx = 0;

  for (i = 0; !ctx && i < L22_MAX_DEVS; ++i)
    if (dev_contexts[i].dev == dev) 
      ctx = &dev_contexts[i];

  
  if (ctx && ctx->dev) {
    destroyThread(ctx);

    LOCK_L22(ctx);

    /* Free the irq before destroying anything, obviously.. */

    if (ctx->did_lynx_startup) LynxCleanup(ctx);   
    ctx->did_lynx_startup = 0;

    pci_disable_device(ctx->dev);
    ctx->dev = 0;

    if (ctx->dma.pool2k) {
      pci_pool_destroy(ctx->dma.pool2k);
      ctx->dma.pool2k = 0;
    }
    
    if (ctx->dma.poolDMA) {
      pci_pool_destroy(ctx->dma.poolDMA);
      ctx->dma.poolDMA = 0;
    }

    UNLOCK_L22(ctx);

    destroyL22Lock(ctx);

    LOG_MSG("L22 device %s deactivated.\n", dev->slot_name);
    memset(ctx, 0, sizeof(*ctx));
  }
}

static int createThread(struct LinuxContext *ctx)
{
  pthread_attr_t attr;
  struct sched_param sched_param;
  int error;

  ctx->td = (struct ThreadData *)kmalloc(sizeof(*ctx->td), GFP_KERNEL);
  if (!ctx->td) {
    ERROR("Could not kmalloc struct ThreadData, aborting.\n");
    return -ENOMEM;
  }
  memset(ctx->td, 0, sizeof(*ctx->td));
  pthread_attr_init(&attr);
  sched_param.sched_priority = 5; /* Make sure our sched_priority is decent */
  pthread_attr_setschedparam(&attr, &sched_param);
  /*  pthread_attr_setfp_np(&attr, 1);*/
  pthread_cond_init(&ctx->td->cond, 0);
  error = pthread_create(&ctx->td->thread, &attr, deviceThread, ctx);
  if (error) {
    ERROR("Could not create deviceThread, pthread_create returned %d!\n", error);
    return -error;
  }
  return 0;
}

static void destroyThread(struct LinuxContext *ctx)
{
  if (ctx && ctx->td) {
    void *threadRet;
    LOCK_L22(ctx);
    ctx->td->req = EXIT;
    pthread_cond_signal(&ctx->td->cond);
    UNLOCK_L22(ctx);
    pthread_join(ctx->td->thread, &threadRet);
    pthread_cond_destroy(&ctx->td->cond);
    kfree(ctx->td); 
    ctx->td = 0; 
    DEBUG_MSG("deviceThread exited after %lu cycles.\n", (unsigned long)threadRet);
  }
}

static int createL22Lock(struct LinuxContext *ctx)
{
  if (!ctx) return -EINVAL;
  ctx->lock = (struct L22Lock *)kmalloc(sizeof(*ctx->lock), GFP_KERNEL);
  if (!ctx->lock) return -ENOMEM;
  return pthread_mutex_init(&ctx->lock->mutex, 0);
}

static void destroyL22Lock(struct LinuxContext *ctx)
{  
  if (ctx->lock) {
    pthread_mutex_destroy(&ctx->lock->mutex);
    kfree(ctx->lock);
    ctx->lock = 0;
  }
}

static inline hrtime_t computeTaskPeriod(long long srate, long long bsize)
{
  static const hrtime_t BILLION = 1000000000LL;
  return ((BILLION / srate) * ((hrtime_t)DMABufferSize) / bsize) / 2LL;
}

#define ABS(x) ( (x) < 0 ? -(x) : (x) )
/*  Board rt-thread for managing loading of DMA data  */
static void *deviceThread(void *arg)
{
  struct LinuxContext *ctx = (struct LinuxContext *)arg;
  int stop = 0;
  unsigned long count = 0;
  struct timespec ts;
  hrtime_t period = computeTaskPeriod(SampleRate, 4*2 /* TODO this is the sample block size */);
  DEBUG_MSG("deviceThread: Task period is %ld\n", (long)period);
  ts = timespec_from_ns(gethrtime());
  LOCK_L22(ctx);
  LynxPlay(ctx, L22_ALL_CHANS);
  while (!stop) {
    int retval = 0;
    timespec_add_ns(&ts, period);
    retval = pthread_cond_timedwait(&ctx->td->cond, &ctx->lock->mutex, &ts);
#ifdef DEBUGGGGG
    long long dff = gethrtime() - timespec_to_ns(&ts);
    if (ABS(dff) > 30000) {
      DEBUG_MSG("deviceThread: Woke up %ld off.\n", (long)dff);
    }
#endif

    if (retval != ETIMEDOUT && retval != 0) {
      ERROR("deviceThread: pthread_cond_timedwait returned %d! Stopping all playback.\n", retval);
      break;
    }
    switch (ctx->td->req) {
    case SAMPLERATE_CHANGE:
      /* not normal case, sampling rate changed.. */
      period = computeTaskPeriod(SampleRate, 4*2 /* TODO make this specific to format(s)? */ );
      ts = timespec_from_ns(gethrtime());
      /* notice fall-through.. we should still check the buffers */
    case NONE:
      /* normal case, we waited for 1 task perdiod.. */
      LynxDoDMAPoll(ctx);
      break;
    case EXIT: stop = 1; break;
    default:
      WARNING("deviceThread: got unknown request %d!\n", ctx->td->req);
    }
    ctx->td->req = NONE;
    ++count;
  }
  LynxStop(ctx, L22_ALL_CHANS);
  UNLOCK_L22(ctx);
  return (void *)count;
}


module_init(init);
module_exit(cleanup);


/*---------------------------------------------------------------------------
  FUNCTIONS EXPORTED TO KSYMS (Kernel Symbol Table)
  These are, for the most part, declared in LynxTWO-RT.h
  They also are, for the most part, just wrappers around functions
  declared in LinuxGlue.h...
-----------------------------------------------------------------------------*/
EXPORT_SYMBOL_NOVERS(L22GetNumDevices);
EXPORT_SYMBOL_NOVERS(L22SetAudioBuffer);
EXPORT_SYMBOL_NOVERS(L22Play);
EXPORT_SYMBOL_NOVERS(L22Stop);
EXPORT_SYMBOL_NOVERS(L22GetSampleRate);
EXPORT_SYMBOL_NOVERS(L22GetVolume);
EXPORT_SYMBOL_NOVERS(L22SetVolume);
EXPORT_SYMBOL_NOVERS(L22IsPlaying);
EXPORT_SYMBOL_NOVERS(L22MixerOverflowed);
EXPORT_SYMBOL_NOVERS(L22Open);
EXPORT_SYMBOL_NOVERS(L22Close);

#define  DECLARE_CTX_FROM_HANDLE(handle, ctx) \
struct LinuxContext *ctx; \
  if (handle < 0 || handle >= num_contexts) \
    return 0;\
\
  ctx = &dev_contexts[handle]\

/** returns true if the L22 device exists and is ready for commands.. */
int L22GetNumDevices(void) {  return num_contexts; }

/** Specify an audio buffer for the audio data to play.  
    Currently only 32-bit stereo PCM format (8 bytes per channel pair)
    is supported due to implementation limitations.  Anything else will
    return an error. */
int L22SetAudioBuffer(L22Dev_t handle,
                      void *buffer, 
                      unsigned long num_bytes, 
                      int format_code,
                      unsigned chan, 
                      int looped)
{
  unsigned ret = 0;
  DECLARE_CTX_FROM_HANDLE(handle, ctx);  
  
  /* we will try not locking here for low-latency.. */
  ret = LynxSetAudioBuffer(ctx, buffer, num_bytes, format_code, chan, looped);

  return !ret;
}

/* Play the audio buffer specified by L22SetAudioBuffer.
   Note that for now only out channel 0 is used for audio output.   
   It is safe to call this function from realtime context.  */
int L22Play(L22Dev_t handle, unsigned chan) 
{ 
  unsigned ret;
  DECLARE_CTX_FROM_HANDLE(handle, ctx);

  ret = LynxPlay(ctx, chan);

  return ret == HSTATUS_OK; 
}

/* Stop playing if we were playing, otherwise noop. 
   It is safe to call this function from realtime context.  */
void L22Stop(L22Dev_t dev, unsigned chan) 
{ 
  L22SetAudioBuffer(dev, 0, 0, 0, chan, 0); 
}


unsigned L22GetSampleRate(L22Dev_t dev) 
{ 
  return SampleRate;
}

/** Returns the current play volume, a value from 0 - L22_MAX_VOLUME */
unsigned long L22GetVolume(L22Dev_t dev, unsigned chan)
{
  unsigned long ret;
  DECLARE_CTX_FROM_HANDLE(dev, ctx);
  LOCK_L22(ctx);
  ret = LynxGetVolume(ctx, chan);
  UNLOCK_L22(ctx);
  return ret;
}

/** Sets the current play volume, a value from 0 - L22_MAX_VOLUME 
    returns 1 on success or 0 on error.                              */
int L22SetVolume(L22Dev_t dev, unsigned chan, unsigned long volume)
{
  int ret;
  DECLARE_CTX_FROM_HANDLE(dev, ctx);
  LOCK_L22(ctx);
  ret = LynxSetVolume(ctx, chan, volume) == 0;
  UNLOCK_L22(ctx);
  return ret == HSTATUS_OK;
}

int L22IsPlaying(L22Dev_t dev, unsigned chan)
{
  int ret;
  DECLARE_CTX_FROM_HANDLE(dev, ctx);
  LOCK_L22(ctx);
  ret = LynxIsPlayingSound(ctx, chan);
  UNLOCK_L22(ctx);
  return ret;
}

int L22MixerOverflowed(L22Dev_t dev)
{
  int ret;
  DECLARE_CTX_FROM_HANDLE(dev, ctx);
  LOCK_L22(ctx);
  ret = LynxMixerOverflowed(ctx);
  UNLOCK_L22(ctx);
  return ret;
}

L22Dev_t L22Open(int num)
{
  if (num < 0 || num >= L22GetNumDevices()) {
    ERROR("L22Open: got invalid device number: %d\n", num);
    return L22DEV_OPEN_ERROR;
  }
  return num;
}

void L22Close(L22Dev_t d)
{
  (void)d; /* do nothing.. */
}

struct RTLinux_Lock_t *rtlinux_lock_create(void)
{
  pthread_mutex_t *ret = kmalloc(sizeof(pthread_mutex_t), GFP_KERNEL);
  DEBUG_MSG("rtlinux_lock_create() called\n");
  if (ret && pthread_mutex_init(ret, 0) ) {
    /* some error.. */
    kfree(ret);
    ret = 0;
  }
  if (!ret)
    ERROR("rtlinux_lock_create() failed to create a mutex!\n");
  return (struct RTLinux_Lock_t *)ret;
}

void rtlinux_lock_destroy(struct RTLinux_Lock_t *l)
{
  DEBUG_MSG("rtlinux_lock_destroy() called\n");
  if (!l) return;
  pthread_mutex_destroy((pthread_mutex_t *)l);
  kfree(l);
}

void rtlinux_lock(struct RTLinux_Lock_t *l)
{
  if (!l) return;
  pthread_mutex_lock((pthread_mutex_t *)l);
}

void rtlinux_unlock(struct RTLinux_Lock_t *l)
{
  if (!l) return;
  pthread_mutex_unlock((pthread_mutex_t *)l);
}

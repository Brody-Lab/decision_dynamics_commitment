/*
 * This file is part of the CNMC Software Experiment System from
 * Cold Spring Harbor Laboratory, NY.
 *
 * Copyright (C) 2005-2006 Calin Culianu <calin@ajvar.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program (see COPYRIGHT file); if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA, or go to their website at
 * http://www.gnu.org.
 */

/**
 * Trigger RT program that knows how to talk to the LynxTWO-RT driver
 * for triggering sounds.  To avoid any latency, all soundfiles are
 * stored in memory, and they come from userspace via the
 * LynxTrigServer program.  Soundfile memory is allocated at module
 * insertion, and by default about 1/3 of system memory is grabbed.
 */

#include <linux/module.h> 
#include <linux/kernel.h>
#include <linux/version.h>
#include <linux/types.h>
#include <linux/errno.h>
#include <linux/bitops.h>
#include <linux/delay.h>
#include <asm/semaphore.h> /* for synchronizing the exported functions */
#include <asm/bitops.h>    /* for set/clear bit                        */
#include <linux/slab.h>
#include <linux/vmalloc.h>
#include <linux/string.h> /* some memory copyage                       */
#include <linux/fs.h> /* for the determine_minor() functionality       */
#include <linux/proc_fs.h>
#include <asm/div64.h> /* for do_div 64-bit division macro             */
#include <linux/list.h>
#include <linux/spinlock.h>
#include <linux/mm.h>
#include <linux/comedilib.h>
#include <linux/seq_file.h>
#include <rtl.h>
#include <rtl_time.h>
#include <rtl_fifo.h>
#include <rtl_sched.h>
#include <rtl_mutex.h>
#include <rtl_sema.h>
#include <mbuff.h>
#include <linux/config.h>


#include "LynxTrig.h"
#include "LynxTrigVirt.h"
#include "LynxTWO-RT.h"
#include "ChanMapper.h"
#include "libtlsf/src/tlsf.h"

#if MAX_CARDS != L22_MAX_DEVS
#error  MAX_CARDS needs to equal L22_MAX_DEVS.  Please fix either LynxTWO-RT.h or LynxTrig.h to make these #defines equal!
#endif

#define MODULE_NAME "LynxTrig-RT"
#ifdef MODULE_LICENSE
  MODULE_LICENSE("GPL");
#endif
#ifndef STR
#  define STR1(x) #x
#  define STR(x) STR1(x)
#endif
#ifndef ABS
#  define ABS(x) ( (x) < 0 ? -(x) : (x) )
#endif
#define LOG_MSG(x...) rtl_printf(KERN_INFO MODULE_NAME": "x)
#define DEBUG(x...)  do { if(debug) rtl_printf(KERN_DEBUG MODULE_NAME": DEBUG: "x); } while(0)
#define WARNING(x...)  rtl_printf(KERN_WARNING MODULE_NAME ": WARNING: "x)
#define ERROR(x...)  rtl_printf(KERN_ERR MODULE_NAME ": INTERNAL ERROR: "x)
MODULE_AUTHOR("Calin A. Culianu");
MODULE_DESCRIPTION(MODULE_NAME ": A component for CSHL to trigger the Lynx22 board (requires LynxTWO-RT driver).");

typedef unsigned CardID_t;

int init(void);  /**< Initialize data structures and register callback */
void cleanup(void); /**< Cleanup.. */

static int initAudioMem(void);
static int initRunStates(void);
static int initRunState(CardID_t);
static int initShm(void);
static int initFifos(void);
static int initRT(void);
static int initComedi(void);

static void *doRT (void *);

/* Called whenever the /proc/LynxTrig proc file is read */
static int myseq_show (struct seq_file*, void *data);
static int myseq_open(struct inode *, struct file *);
static struct file_operations myproc_fops =
{
  open:    myseq_open,
  read:    seq_read,
  llseek:  seq_lseek,
  release: single_release
};


/* Spawns one of the below threads in software triggers mode, or 
   calls the function directly in hardware triggers mode.. 
   Pass a command of the type seen in enum FifoMsgID */
enum {
  PLAY_CMD = USER_LYNXTRIG_MSG_ID+1,
  STOP_CMD
};
static void *doCmdInRTThread(int cmd, void *arg);


module_init(init);
module_exit(cleanup);


/*---------------------------------------------------------------------------- 
  Some private 'global' variables...
-----------------------------------------------------------------------------*/
static volatile struct Shm *shm = 0;
static volatile struct LynxTrigVirtShm *virtShm = 0;
/* Pointer to TLSF memory pool for audio memory buffers */
void *audio_memory_pool = 0;

/** array of L22Dev_t for all the devices we have open */
L22Dev_t *l22dev = 0;
/** the size of the above array */
unsigned n_l22dev = 0;

/* Some helper macros to make tlsf usage slightly easier.. */
#define TLSF_malloc(s) malloc_ex(s, audio_memory_pool)
#define TLSF_realloc(p,s) realloc_ex(p, s, audio_memory_pool)
#define TLSF_free(p) free_ex(p, audio_memory_pool)

#define DEFAULT_SAMPLING_RATE 10000
#define DEFAULT_TRIGGER_MS 1

static char COMEDI_DEVICE_FILE[] = "/dev/comediXXXXXXXXXXXXXXX";
int minordev = 0, 
    sampling_rate = DEFAULT_SAMPLING_RATE, 
    debug = 0,
    first_trig_chan = 0,
    num_trig_chans = 8,
    comedi_triggers = 0,
    audio_memory = 0,
    trig_on_event_chan = -1;
MODULE_PARM(minordev, "i");
MODULE_PARM_DESC(minordev, "The minor number of the comedi device to use.");
MODULE_PARM(sampling_rate, "i");
MODULE_PARM_DESC(sampling_rate, "The sampling rate, or frequency of the periodic polling task if using comedi_triggers.  Note: Do not confuse this with the sound board's sampling rate which is specified via the userspace program LynxTrigServer. Defaults to " STR(DEFAULT_SAMPLING_RATE) ".");
MODULE_PARM(debug, "i");
MODULE_PARM_DESC(debug, "If true, print extra (cryptic) debugging output.  Defaults to 0.");
MODULE_PARM(first_trig_chan, "i");
MODULE_PARM_DESC(first_trig_chan, "The first DIO channel to use for board triggers.  Note that this plus num_trig_chans determine exact lines we scan to get the binary trigger id.  Defaults to 0.");
MODULE_PARM(num_trig_chans, "i");
MODULE_PARM_DESC(num_trig_chans, "The number of DIO channels from first_trig_chan to scan for triggers. Defaults to 8.  (0 means take all channels left until the last).");
MODULE_PARM(comedi_triggers, "i");
MODULE_PARM_DESC(comedi_triggers, "If set, use COMEDI DIO device to do triggering.  Otherwise use a SHM which contains a singe int for 'virtual' triggering from another RT module.  The SHM name is \""LYNX_TRIG_VIRT_SHM_NAME"\" of size sizeof(int).  Defaults to 0 (virtual).");
MODULE_PARM(audio_memory, "i");
MODULE_PARM_DESC(audio_memory, "The number of MB to preallocate for audio buffers.  Note that this should be a large value otherwise you will soon run out of realtime audio buffers when sending sounds from userspace!  Defaults to 1/3 the system's physical RAM.");
MODULE_PARM(trig_on_event_chan, "i");
MODULE_PARM_DESC(trig_on_event_chan, "If non-negative, the DIO channel (not related to first_trig_chan or num_trig_chans at all!) to 'trigger' for one cycle whenever a play event occurs. This feature is intended to be used for debugging the timing of the play command. Defaults to -1 (off).");
#if defined(CONFIG_BIGPHYS_AREA) && CONFIG_BIGPHYS_AREA
#include <linux/bigphysarea.h>
int bigphys = 0;
MODULE_PARM(bigphys, "i");
MODULE_PARM_DESC(bigphys, "KB of memory to allocate using bigphysarea_alloc(). (Do cat /proc/bigphysarea to see KB free of bigphys memory).  Note: This parameter replaces audio_memory, and it tells this module to attempt to allocate the audio memory from the bigphysarea pool (requires a specially patched kernel and a bootime parameter, see Documentation/bigphysarea.txt for more info).  Specify a size in KB of the bigphysarea.  A positive nonzero value means to use the bigphysarea, otherwise the audio_memory parameter is used instead.  Defaults to 0 (don't use bigphysarea).");
#endif

#define NUM_CHANS_REQUIRED (first_trig_chan+(num_trig_chans-1))

static struct proc_dir_entry *proc_ent = 0;
static volatile int rt_task_stop = 0; /* Internal variable to stop the RT 
                                         thread. */
static volatile int rt_task_running = 0;
static pthread_t rt_task = 0;

static struct RamperThread
{
  pthread_t thread;
  atomic_t tauParam;
  atomic_t stop;
  sem_t sem;
  unsigned dev; /* The L22 device this thread is responsible for */
  unsigned chan; /* The L22 channel this thread is responsible for */
} ramperThreads[L22_MAX_DEVS][L22_NUM_CHANS]; /**< TODO/FIXME put this in RunState */

struct DevChan 
{
  union {
    struct {
      unsigned short dev;
      unsigned short chan;
    };
    unsigned devchan;
    void *devchan_voidp;
  };
};
typedef struct DevChan DevChan;

struct DevEvt
{
  union {
    struct {
      unsigned short dev;
      short evt;
    };
    unsigned devevt;
    void *devevt_voidp;
  };
};
typedef struct DevEvt DevEvt;


static comedi_t *dev = 0;
static unsigned subdev = 0;

/* Remembered state of all DIO channels.  */
unsigned dio_bits = 0, dio_bits_prev = 0;  
uint64 cycle = 0; /* the current cycle */

#define MILLION 1000000
#define BILLION 1000000000
uint64 task_period_ns = BILLION;

#define Sec2Nano(s) (s*BILLION)
static inline unsigned long Nano2Sec(unsigned long long nano);
static inline unsigned long Nano2USec(unsigned long long nano);
static inline long Micro2Sec(long long micro, unsigned long *remainder);
/*---------------------------------------------------------------------------- 
  More internal 'global' variables and data structures.
-----------------------------------------------------------------------------*/
struct AudioBuf {
  char *buf;
  unsigned long len;
  unsigned rate;
  unsigned short bits;
  unsigned short nchans;
  unsigned short stop_ramp_tau_ms;
  unsigned short is_looped_flag;
  unsigned long final_size;
  unsigned trig_play_ct;
  unsigned trig_stop_ct;
};

struct RunState {
    /* NB: this is not SMP-safe and also suffers from race conditions 
       with userspace in case another CPU writes to these values on behalf of 
       userspace writes to these values.. TODO: add smp-safe locks.          */
    
    int64 current_ts; /* Time elapsed, in ns, since init_ts */
    int64 init_ts; /* Time of initialization, in nanoseconds.  Absolute
                      time derived from the Pentium's monotonically 
                      increasing TSC. */            

    int forced_event; /* If positive, force this trigger. */
    int last_event;    /* The last event.. 0 for none, but if anything ever 
			  happeened it's usually nonzero.  Negative for a 
			  stop event. */
    int current_event ; /* The currently playing event.. quickly settles to 0 */
  
    int paused; /* If this is true, input lines do not lead to 
		   sound playing. Useful when we want to temporarily 
		   pause triggering, etc. */

    int invalid; /* If this is true, the kernel ignores the sound file(s).
                    Useful when userspace wants to 'upload' a new sound file.*/

    struct AudioBuf *last_played_buf[L22_NUM_CHANS];
    struct AudioBuf audio_buffers[MAX_SND_ID];    
};

static struct RunState rs[L22_MAX_DEVS];

#define SOFTWARE_TRIGGERS()  (!comedi_triggers)
#define COMEDI_TRIGGERS() (comedi_triggers != 0)
static DECLARE_MUTEX(trigger_mutex);
/** Note locking only happens in non-rt context (SOFTWARE_TRIGGERS() mode).
    In COMEDI_TRIGGERS() mode, we don't lock anything as all trigger access 
    is synchronous. */
#define LOCK_TRIGGERS() do { if (SOFTWARE_TRIGGERS()) down_interruptible(&trigger_mutex); } while(0)
#define UNLOCK_TRIGGERS() do { if (SOFTWARE_TRIGGERS()) up(&trigger_mutex); } while(0)
#define TRIGGERS_LOCKED() (SOFTWARE_TRIGGERS() && atomic_read(&trigger_mutex.count) <= 0)

/*---------------------------------------------------------------------------
 Some helper functions
-----------------------------------------------------------------------------*/
static int detectEvent(CardID_t); /**< returns 0 on no input detected, positive for play id or negative for stop id */
static pthread_mutex_t dispatch_Mut = PTHREAD_MUTEX_INITIALIZER;
static void dispatchEvent(CardID_t, int trig); /**< Do triggers (if any).. */
static int virtualTriggerFunction(CardID_t, int); /* Do virtual 'soft' triggers (if any) */      
static int createRamperThreads(void);
static void destroyRamperThreads(void);
static void doPossiblyRampedStop(unsigned card, unsigned chan);
static void *cosine2RamperThread(void *);
static void cancelAnyRunningRampedStops(unsigned card, unsigned chan);

static int handleFifos_MapCardID(unsigned int fifo_no); /* gets called as rtf handler, maps rtf id to card id and calls handleFifos(cardId */
static int handleFifos(CardID_t card);
static void grabAllDIO(void);
static inline void updateTS(CardID_t c) { rs[c].current_ts = gethrtime() - rs[c].init_ts; }
static void freeAudioBuffers(CardID_t c);
/* just like clock_gethrtime but instead it used timespecs */
static inline void clock_gettime(clockid_t clk, struct timespec *ts);
static inline void nano2timespec(hrtime_t time, struct timespec *t);
/* 64-bit division is not natively supported on 32-bit processors, so it must 
   be emulated by the compiler or in the kernel, by this function... */
static inline unsigned long long ulldiv(unsigned long long dividend, unsigned long divisor, unsigned long *remainder);
/* Just like above, but does modulus */
static inline unsigned long ullmod(unsigned long long dividend, unsigned long divisor);
/* this function is non-reentrant! */
static const char *uint64_to_cstr(uint64 in);

static struct Channels *channels[MAX_CARDS];
static int initChanMapper(void); 
static void destroyChanMapper(void);
static void stopAllChans(CardID_t c);
static int initL22Devs(void);
static void cleanupL22Devs(void);
static void freeAudioMemory(void);

/*-----------------------------------------------------------------------------*/

int init (void)
{
  int retval = 0;
  
  if (    (retval = initL22Devs())
       || (retval = initChanMapper())
       || (retval = initAudioMem()) 
       || (retval = initShm())
       || (retval = initFifos())
       || (retval = initRunStates())
       || (retval = initComedi())
       || (retval = initRT())  ) 
    {
      cleanup();  
      return retval;
    }
  
  proc_ent = create_proc_entry(MODULE_NAME, S_IFREG|S_IRUGO, 0);
  if (proc_ent)  {/* if proc_ent is zero, we silently ignore... */
    proc_ent->owner = THIS_MODULE;
    proc_ent->uid = 0;
    proc_ent->proc_fops = &myproc_fops;
  }

  if ( SOFTWARE_TRIGGERS() ) {
    LOG_MSG("started successfully, using passive 'virtual' triggers at SHM \"%s\", for a total of 2^31 possible triggered sounds!\n", LYNX_TRIG_VIRT_SHM_NAME);
  } else {
    LOG_MSG("started successfully at %d Hz, using COMEDI DIO for triggering, first trig: %d, num trigs: %d.\n", sampling_rate, first_trig_chan, num_trig_chans);
  }

  atomic_set(&virtShm->valid, 1);
  
  return retval;
}

void cleanup (void)
{
  unsigned c;

  LOCK_TRIGGERS();

  for (c = 0; c < n_l22dev; ++c) stopAllChans(c);
  
  /* TODO: Worry about possible race conditions with RT thread in
     virtualTriggerFunction() (it's possible for an RT thread to 
     be in that function here?) */
  if (virtShm) {
    atomic_set(&virtShm->valid, 0);
    virtShm->function = 0; /* Clear the function pointer just in case other
			      rt tasks are looking at it. */
    virtShm->magic = 0;
    mbuff_free(LYNX_TRIG_VIRT_SHM_NAME, (void *)virtShm);
    virtShm = 0;
  }

  if (proc_ent)
    remove_proc_entry(MODULE_NAME, 0);
  
  if (rt_task_running) {
    rt_task_stop = 1;
    pthread_cancel(rt_task);
    pthread_join(rt_task, 0);
  }
  
  destroyRamperThreads();

  if (dev) {
    comedi_close(dev);
    dev = 0;
  }

  if (shm)  { 
    for (c = 0; c < n_l22dev; ++c) {
      if (shm->fifo_in[c] >= 0) rtf_destroy(shm->fifo_in[c]);
      if (shm->fifo_out[c] >= 0) rtf_destroy(shm->fifo_out[c]);
    }
    mbuff_free(SHM_NAME, (void *)shm); 
    shm = 0; 
  }

  destroyChanMapper();

  if (audio_memory_pool) {
    destroy_memory_pool(audio_memory_pool);
    freeAudioMemory(); /* either uses bigphyadrea_free or vfree */
  }

  if (COMEDI_TRIGGERS())
    LOG_MSG("unloaded successfully after %s cycles.\n",
            uint64_to_cstr(cycle));
  else
    LOG_MSG("unloaded successfully after %s virtual trigger events.\n", 
            uint64_to_cstr(cycle));

  UNLOCK_TRIGGERS();

  pthread_mutex_trylock(&dispatch_Mut);
  pthread_mutex_unlock(&dispatch_Mut);
  pthread_mutex_destroy(&dispatch_Mut);

  cleanupL22Devs();
}

static int initL22Devs(void)
{
  unsigned i, arr_bytes = 0;
  n_l22dev = L22GetNumDevices();
  if (!n_l22dev) return -EINVAL;
  arr_bytes = sizeof(*l22dev)*n_l22dev;
  l22dev = kmalloc(arr_bytes, GFP_KERNEL);
  if (!l22dev) { n_l22dev = 0; return -ENOMEM; }
  for (i = 0; i < n_l22dev; ++i) /* clear array.. */
    l22dev[i] = L22DEV_OPEN_ERROR;
  for (i = 0; i < n_l22dev; ++i) {
    if ( (l22dev[i] = L22Open(i)) == L22DEV_OPEN_ERROR ) {
      n_l22dev = i;
      return -EINVAL;
    }
  }
  return 0;
}

static void cleanupL22Devs(void)
{
  unsigned i;  
  if (!l22dev) return;
  for (i = 0; l22dev[i] != L22DEV_OPEN_ERROR && i < n_l22dev; ++i) 
    L22Close(l22dev[i]), l22dev[i] = L22DEV_OPEN_ERROR;
  kfree(l22dev);
  l22dev = 0;
}

static int initAudioMem(void)
{
  int retval;
  unsigned long tstchunk = 0, memsize = 0;
  char *tmp = 0;
  int first_alloc_try = 1;

#if defined(CONFIG_BIGPHYS_AREA) && CONFIG_BIGPHYS_AREA
  if (bigphys > 0) {
    bigphys *= 1024;
    audio_memory_pool = (void *)bigphysarea_alloc(bigphys);
    if (!audio_memory_pool) {
      ERROR("Could not allocate %d bytes from bigphysarea pool, defaulting to regular vmalloc() value via audio_memory parameter.\n", bigphys);
      bigphys = 0;
    } else {
      memsize = bigphys;
      LOG_MSG("Allocated %d bytes for audio memory pool using bigphysarea_alloc().\n", memsize);

    }
  }
#endif
  /* above failed or is compiled out, try and use vmalloc() */
  if (!audio_memory_pool) { 
      if (audio_memory <= 0) {
        struct sysinfo si;
        si_meminfo(&si);
        audio_memory = si.totalram*si.mem_unit / 3;
      } else
        audio_memory *= 1024*1024;  
      
      if (audio_memory <= 0) {
        LOG_MSG("Invalid audio memory value: %d!\n", audio_memory);
        return -EINVAL;
      }
      
      /* Try and allocate requested size for audio memory pool.. if that fails,
         keep trying with 1MB smaller amounts until we either succeed or 
         if that fails.. give up. */
      do {    
        audio_memory_pool = (void *)vmalloc(audio_memory);
        if (!audio_memory_pool) {
          if (first_alloc_try)
            WARNING("Cannot allocate %d bytes for the audio memory pool!  Trying smaller amounts..\n", 
                    audio_memory);
          audio_memory -= 1024*1024; /* Try 1MB less.. */
          first_alloc_try = 0;
        } else {
          LOG_MSG("Allocated %d bytes for audio memory pool using vmalloc().\n", audio_memory);
        }
      } while(!audio_memory_pool && audio_memory > 1024*1024);
      /* Ergh!  We failed to even get 1MB of audio memory! WTF? */
      if (!audio_memory_pool) {
        ERROR("Could not even get a measely %d bytes for the audio memory pool!  Out of memory?\n", audio_memory); 
        return -ENOMEM;
      }

      memsize = audio_memory;
  }
  tstchunk = (memsize/2);

  /* Ok, now give the audio memory pool to the TLSF dynamic memory
     allocator so we can allocate memory in realtime.. */
  if ( (retval = init_memory_pool(memsize, audio_memory_pool)) <= 0 || !(tmp = (char *)TLSF_malloc(tstchunk)) )
  {
      if (retval == TLSF_FLI_TOOSMALL) 
        ERROR("TLSF init_memory_pool complained that memory size is too big!  Increase compile-time MAX_FLI in tlsf.h to at least log2(%d)!\n", memsize);
      else
        ERROR("TLSF init_memory_pool returned %d, aborting..\n", retval);
      freeAudioMemory();
      return -EINVAL;
  }

  /* Test memory pool.. */
  memset(tmp, 0, tstchunk);
  TLSF_free(tmp);

  return 0;
}

static void freeAudioMemory(void)
{
#if defined(CONFIG_BIGPHYS_AREA) && CONFIG_BIGPHYS_AREA
  if (bigphys && audio_memory_pool) {
    bigphysarea_free((caddr_t)audio_memory_pool, bigphys);
  } else 
#endif
    vfree(audio_memory_pool);
  audio_memory_pool = 0;
}

static int initShm(void)
{
  unsigned i;

  shm = (volatile struct Shm *) mbuff_alloc(SHM_NAME, SHM_SIZE);
  if (! shm)  {
    ERROR("Could not mbuff_alloc the shared memory structure.  Aborting!\n");
    return -ENOMEM;
  }
  
  memset((void *)shm, 0, sizeof(*shm));
  shm->magic = SHM_MAGIC;

  for (i = 0; i < MAX_CARDS; ++i)
    shm->fifo_out[i] = shm->fifo_in[i] = -1;

  if ( SOFTWARE_TRIGGERS() ) 
  {
      virtShm = (struct LynxTrigVirtShm *) 
        mbuff_alloc(LYNX_TRIG_VIRT_SHM_NAME, LYNX_TRIG_VIRT_SHM_SIZE);
      if (!virtShm) return -ENOMEM;
      virtShm->magic = LYNX_TRIG_VIRT_SHM_MAGIC;
      virtShm->function = virtualTriggerFunction;
  }

  /* erm.. a const_cast basically */
  *((unsigned *)&shm->num_cards) = n_l22dev;

  return 0;
}

static int find_free_rtf(unsigned *minor, unsigned size)
{
  unsigned i;
  for (i = 0; i < RTF_NO; ++i) {
    int ret = rtf_create(i, size);
    if ( ret  == 0 ) {
      *minor = i;
      return 0;
    } else if ( ret != -EBUSY ) 
      /* Uh oh.. some deeper error occurred rather than just the fifo was
	 already allocated.. */
      return ret;
  }
  return -EBUSY;
}

static int initFifos(void)
{
  int32 err, minor, i;

  for (i = 0; i < n_l22dev; ++i) {
    /* Open up fifos here.. */
    err = find_free_rtf(&minor, sizeof(FIFO_SZ));
    if (err < 0) return 1;
    shm->fifo_out[i] = minor;
    err = find_free_rtf(&minor, sizeof(FIFO_SZ));
    if (err < 0) return 1;
    shm->fifo_in[i] = minor;

    if ( SOFTWARE_TRIGGERS() ) 
      {
        /* In soft trigger mode, install an RT handler since there is no 
           rt-thread polling the fifos.. */
        if ( rtf_create_handler(shm->fifo_in[i], handleFifos_MapCardID) ) {
          LOG_MSG("rtf_create_handler returned error!\n");
          return 1;
        }
      }
  }

  return 0;  
}

static int initRunStates(void)
{
  unsigned i;
  for (i = 0; i < L22_MAX_DEVS; ++i) initRunState(i);
  return 0;
}

static int initRunState(CardID_t c)
{
  /* Clear the runstate memory area.. */
  memset((void *)&rs[c], 0, sizeof(rs[c]));

  /* Grab current time from rtlinux */
  rs[c].init_ts = gethrtime();

  rs[c].invalid = 1; /* Start out with an 'invalid' FSM since we expect it
                     to be populated later from userspace..               */

  return 0;  
}

static int initComedi(void) 
{
  int i, n_chans = 0;

  if ( SOFTWARE_TRIGGERS() ) {
    /* Virtual triggers, don't initialize comedi just setup the 
       trigger vars instead.. */
    return 0;
  }

  /* If we got to this point, we aren't using virtual triggers to open 
     comedi device, etc.. */

  if (first_trig_chan < 0 || num_trig_chans < 0) {
    LOG_MSG("first_trig_chan (%d) and num_trig_chans (%d) must be positive!",
            first_trig_chan, num_trig_chans);
    return -EINVAL;
  }

  if (!dev) {
    int sd;

    sprintf(COMEDI_DEVICE_FILE, "/dev/comedi%d", minordev);
    dev = comedi_open(COMEDI_DEVICE_FILE);
    if (!dev) {
      LOG_MSG("Cannot open Comedi device at %s\n", COMEDI_DEVICE_FILE);
      return -EINVAL/*comedi_errno()*/;
    }

    sd = comedi_find_subdevice_by_type(dev, COMEDI_SUBD_DIO, 0);    
    if (sd >= 0) n_chans = comedi_get_n_channels(dev, sd);
    if (num_trig_chans <= 0) num_trig_chans = (n_chans-first_trig_chan);
    if (sd < 0 || n_chans < first_trig_chan || n_chans < NUM_CHANS_REQUIRED) {
      LOG_MSG("DIO subdevice requires at least %d+%d DIO channels.\n", first_trig_chan, num_trig_chans-1);
      comedi_close(dev);
      dev = 0;
      return -ENODEV;
    }
    subdev = sd;
  }
  DEBUG("COMEDI: n_chans = %u\n", n_chans);
  
  /* Now, setup channel modes correctly */
  for (i = first_trig_chan; i < first_trig_chan+num_trig_chans; ++i) 
    if ( comedi_dio_config(dev, subdev, i, COMEDI_INPUT) != 1 )
      WARNING("comedi_dio_config returned error for channel %d mode %d\n", i, (int)COMEDI_INPUT);
      
  { 
    unsigned bits = 0;
    if ( comedi_dio_bitfield(dev, subdev, (unsigned)-1, &bits) < 0 ) 
      WARNING("comedi_dio_bitfield returned error\n");
  }

  if (trig_on_event_chan >= 0)
    comedi_dio_config(dev, subdev, trig_on_event_chan, COMEDI_OUTPUT); 

  return 0;
}

static int initRT(void)
{
#define TASK_STACKSIZE 8192
  static char TASK_STACK[TASK_STACKSIZE];
  pthread_attr_t attr;
  struct sched_param sched_param;
  int error;
  unsigned long rem;

  error = createRamperThreads();

  if (error) return -error;

  /* No rt task is run in 'virtual' or software trigger mode.. */
  if ( SOFTWARE_TRIGGERS() ) return 0;

  /* setup task period.. */
  if (sampling_rate <= 0 || sampling_rate >= BILLION) {
    LOG_MSG("Sampling rate of %d seems crazy, going to default of %d\n", sampling_rate, DEFAULT_SAMPLING_RATE);
    sampling_rate = DEFAULT_SAMPLING_RATE;
  }
  task_period_ns = ulldiv(BILLION, sampling_rate, &rem);

  /* Setup pthread data, etc.. */
  pthread_attr_init(&attr);
  pthread_attr_setfp_np(&attr, 1);
  error = pthread_attr_setstackaddr(&attr, TASK_STACK);
  if (error) return -error;
  error = pthread_attr_setstacksize(&attr, TASK_STACKSIZE);  
  if (error) return -error;
  sched_param.sched_priority = 1;
  error = pthread_attr_setschedparam(&attr, &sched_param);  
  if (error) return -error;
  error = pthread_create(&rt_task, &attr, doRT, 0);
  if (error) return -error;
  return 0;
}

static int myseq_open(struct inode *i, struct file *f)
{
  return single_open(f, myseq_show, 0);
}

static int myseq_show (struct seq_file *m, void *dummy)
{  
  (void) dummy;
  unsigned c;

  seq_printf(m, "%s Module\n\n", MODULE_NAME);

  seq_printf(m, "Audio memory pool at %p ", audio_memory_pool);
#if defined(CONFIG_BIGPHYS_AREA) && CONFIG_BIGPHYS_AREA
  if (bigphys && audio_memory_pool) {
    seq_printf(m, "size %d bytes (used bigphysarea).\n", bigphys);
  } else 
#endif
    seq_printf(m, "size %d bytes (used vmalloc).\n", audio_memory);
  
  seq_printf(m, "shm addr: %p\tshm magic: %08x\n", (void *)shm, shm->magic);

  for (c = 0; c < n_l22dev; ++c) {
    seq_printf(m, "\nSound Card %u:", c);
    if (rs[c].invalid) {
      seq_printf(m, "\tSound is not specified or is invalid.\n");
    } else {
      int i;
      seq_printf(m, "\n"); /* extra newline */
      for (i = 0; i < MAX_SND_ID; ++i) {
        struct AudioBuf *buf = &rs[c].audio_buffers[i];
        if (buf->buf)
          seq_printf(m, "\tSound buffer %d: buf_ptr: %p, rate - %u,  len - %lu,  bits - %hu,  nchans - %hu,  ramp_ms - %hu,  plays - %u,  stops - %u\n", i, buf->buf, buf->rate, buf->len, buf->bits, buf->nchans, buf->stop_ramp_tau_ms, buf->trig_play_ct, buf->trig_stop_ct);
      }      
    }
  }
  return 0;
}

/**
 * This function does the following:
 *  Detects edges, plays sounds via external LynxPlay(), updates Shm,
 *  reads from userspace fifos..
 */
static void *doRT (void *arg)
{
  struct timespec next_task_wakeup;
  (void)arg;

  rt_task_running = 1;

  clock_gettime(CLOCK_REALTIME, &next_task_wakeup);
  
  
  while (! rt_task_stop) {

    /*#define TIME_IT*/
#if defined(TIME_IT)
    /* DEBUG */
    static int i = 0;
    long long ts = gethrtime(), tend;
#endif

    timespec_add_ns(&next_task_wakeup, (long)task_period_ns);

    ++cycle;

    /* Grab current time from hard realtime clock */
    updateTS(0);
        
    /* Grab all available DIO bits at once (up to 32 bits due to limitations 
       in COMEDI) */
    grabAllDIO();
   
    handleFifos(0/*only card0 is in rt..*/);
    
    if ( ! rs[0].invalid && ! rs[0].paused ) {
      
      int event_id = 0;
	  
      /* Normal event transition code, event_id is non-negative on event 
         detection. */
      event_id = detectEvent(0);

      if (COMEDI_TRIGGERS() && trig_on_event_chan >= 0) 
	/* set this DIO line high to indicate an event detection, 
	   used to time the latency of the play command.. */
        comedi_dio_write(dev, subdev, trig_on_event_chan, event_id!=0); 
      
      dispatchEvent(0, event_id);
      
    }
    
    
#if defined(TIME_IT)
    tend = gethrtime();

    /* DEBUG */
    if (i++ % sampling_rate == 0 || (tend-ts) > (long long)(120000) ) {
      char buf[64];
      int64_to_cstr((long long) tend - ts, buf);
      LOG_MSG("%s nanos for this scan\n", buf);
    }
#endif
    
    /* Sleep until next period */
    clock_nanosleep(CLOCK_REALTIME, TIMER_ABSTIME, &next_task_wakeup, 0); 
  }

  rt_task_running = 0;
  pthread_exit(0);
  return 0;
}


static void dispatchEvent(CardID_t c, int event_id)
{
  int chan = -1, snd_id;
  struct AudioBuf * buf;

  rs[c].current_event = 0;

  if (!event_id || ABS(event_id) >= MAX_SND_ID) return;

  DEBUG("dispatchEvent card=%u event_id=%d\n", c, event_id);
  
  rs[c].last_event = event_id;
  rs[c].current_event = event_id;


  if (event_id < 0) { /* Handle stop events.. */
      pthread_mutex_lock(&dispatch_Mut); 
      snd_id = -event_id;
      buf = &rs[c].audio_buffers[snd_id];
      chan = CM_LookupSound(channels[c], snd_id);
      if (chan > -1) doPossiblyRampedStop(c, chan);
      CM_ClearSound(channels[c], snd_id);
      ++buf->trig_stop_ct; /* increment trig stop count */
      pthread_mutex_unlock(&dispatch_Mut); 
      return;
  }
  snd_id = event_id; /* at this point the snd_id == the event_id */

  /* else..   Event_id > 0, play event.. */
  buf = &rs[c].audio_buffers[snd_id];

  pthread_mutex_lock(&dispatch_Mut); 

  chan = CM_GrabChannel(channels[c], snd_id);

  if (!buf->buf || !buf->len) {
    DEBUG("Triggered event %d skipped due to missing audio buffer.\n",
          snd_id);
    pthread_mutex_unlock(&dispatch_Mut); 
    return;
  }

  /* Schedule a play to happen ASAP */
  L22SetAudioBuffer(l22dev[c], buf->buf, buf->len, (buf->bits/8-1)|((buf->nchans-1)*4), chan, buf->is_looped_flag);
  
  ++buf->trig_play_ct; /* increment trig play count */
  
  rs[c].last_played_buf[chan] = buf;

  cancelAnyRunningRampedStops(c, chan);

  pthread_mutex_unlock(&dispatch_Mut); 
}

/** Called from the function pointer in the shm, by another rt-task,
    in rt-context, to do the 'software' virtual triggering.  
    (RatExpFSM.c knows how to call this, for example). */
static int virtualTriggerFunction(CardID_t card, int trig)
{
  int ret = 0;

  if (card >= n_l22dev) {
    WARNING("virtual trigger function called with an invalid card id %u!\n", card);
    return ret;
  }

#ifdef MOD_INC_USE_COUNT
  MOD_INC_USE_COUNT;
#endif

  /* TODO: Worry about race conditions with cleanup() here? */
  
  if ( !TRIGGERS_LOCKED() ) 
  {
      DEBUG("virtual trigger function called with %d\n", trig);
      dispatchEvent(card, trig);
      ++cycle;
      ret = 1;
  }
  else
    DEBUG("virtual trigger function called with %d, skipping due to locked triggers\n", trig);


#ifdef MOD_DEC_USE_COUNT
  MOD_DEC_USE_COUNT;
#endif
  
  return ret;
}

static void freeAudioBuffers(CardID_t c)
{
  int i;
  for (i = 0; i < MAX_SND_ID; ++i) {
    struct AudioBuf *buf = &rs[c].audio_buffers[i];
    if (buf->buf) {
      TLSF_free(buf->buf);
      buf->buf = 0;
      buf->len = 0;
      buf->final_size = 0;
    }
  }
}

static int handleFifos_MapCardID(unsigned int fifo_no) /* gets called as rtf handler, maps rtf id to card id and calls handleFifos(cardId) */
{
  if (shm) {
    unsigned card;
    for (card = 0; card < n_l22dev; ++card) 
      if (fifo_no == shm->fifo_in[card])
        return handleFifos(card);
  }
  return 0;
}

/* Note: in comedi_triggers mode this is run in realtime context, otherwise
   it is called as a non-realtime rt-fifo handler in Linux context.          */
static int handleFifos(CardID_t c)
{
  FifoNotify_t dummy = 1;
  int errcode;

  /** locking only does something for software trigger mode (in which case
      this function is in non-realtime context), since that is the
      only case where there is asynchronous access to trigger data.. */
  LOCK_TRIGGERS();

  if (SOFTWARE_TRIGGERS()) 
    DEBUG("handleFifos called asynchronously in Linux context.\n");
  

  errcode = rtf_get(shm->fifo_in[c], &dummy, sizeof(dummy));

  if (errcode == sizeof(dummy)) {
      /* Ok, a message is ready, so take it from the SHM */
      struct FifoMsg *msg = (struct FifoMsg *)&shm->msg[c];
      int do_reply = 0;
      
      switch (msg->id) {
        
      case RESET:
        doCmdInRTThread(RESET, (void *)c); /* may spawn a new thread and wait 
                                              for it if we are not in 
                                              rt-context.. */
        do_reply = 1;
        break;
                
      case PAUSEUNPAUSE:
        rs[c].paused = !rs[c].paused;
        /* Notice fall through to next case.. */
      case GETPAUSE:
        msg->u.is_paused = rs[c].paused;
        do_reply = 1;
        break;
        
      case INVALIDATE:
        rs[c].invalid = 1;
        /* Notice fall through.. */
      case GETVALID:
        msg->u.is_valid = !rs[c].invalid;
        do_reply = 1;
        break;
        
      case SOUND:
        rs[c].invalid = 1; /* lock? */
        {
          unsigned id = msg->u.sound.id;
          msg->u.sound.transfer_ok = 0; /* Assume not until otherwise proven to be ok.. */
          if (id < MAX_SND_ID) {
            struct AudioBuf *buf = &rs[c].audio_buffers[id];
            char *newbuf = 0;
            unsigned long pos = 0;
            unsigned long old_final_size = buf->final_size;
            unsigned devRate = 0;
            /*L22Stop(); / * Just in case it was playing a sound.. */
            if (buf->buf && msg->u.sound.append) pos = buf->len;
            if (msg->u.sound.size > MSG_SND_SZ) msg->u.sound.size = MSG_SND_SZ;
            buf->len = msg->u.sound.size+pos;
            buf->stop_ramp_tau_ms = msg->u.sound.stop_ramp_tau_ms;
            old_final_size = buf->final_size;
            buf->final_size = msg->u.sound.total_size;
            if ( (old_final_size && old_final_size == buf->final_size 
                  && (newbuf = buf->buf))
                 || (newbuf = (char *)TLSF_realloc(buf->buf, buf->final_size)) ) {

              buf->buf = newbuf;
              memcpy(buf->buf + pos, msg->u.sound.snd, msg->u.sound.size);
              buf->nchans = msg->u.sound.chans;
              buf->rate = msg->u.sound.rate;
              buf->bits = msg->u.sound.bits_per_sample;
              buf->is_looped_flag = msg->u.sound.is_looped;
              buf->trig_play_ct = buf->trig_stop_ct = 0;
              msg->u.sound.transfer_ok = 1;

              /** Verify the sampling rate matches the L22 device.. */
              if ( (devRate = L22GetSampleRate(c)) != buf->rate) {
                WARNING("Lynx device hard-coded sampling rate of %u differs "
                        "from specified rate of %u!\n", 
                        devRate, (unsigned)buf->rate);
              }

              /* not supported anymore.. L22SetSampleRate(l22dev, buf->rate); */
            } else {
              if (buf->buf) TLSF_free(buf->buf); /* ergh.. out of memory.. free old buffer if it existed :( */
              ERROR("Sound buffer %u could not be allocated with size %u!  Out of memory in memory pool?\n", id, buf->len);
              memset(buf, 0, sizeof(*buf));
            }
            msg->u.sound.size = 0; /* Clear it, just in case? */
          } else {
            /* ID is too high.. */
            ERROR("Sound buffer specified with invalid/too high an id %u.  Limit is %u.\n", id, MAX_SND_ID);
          }
        }
        rs[c].invalid = 0; /* Unlock.. */
        
        do_reply = 1;
        break;
        
      case FORCEEVENT:
        rs[c].forced_event = msg->u.forced_event;

        /* If the rt task isn't running, dispatch the forced event
         *now* in non-RT context.  Otherwise, it will get picked up
         by the RT task.. */
        if ( SOFTWARE_TRIGGERS() ) 
          {
            DevEvt de;
            de.dev = c;
            de.evt = rs[c].forced_event;
            doCmdInRTThread(FORCEEVENT, de.devevt_voidp);
            rs[c].forced_event = 0;
          }

        do_reply = 1;
        break;
        
      case GETRUNTIME:
        if ( SOFTWARE_TRIGGERS() ) updateTS(c);
        msg->u.runtime_us = Nano2USec(rs[c].current_ts);
        do_reply = 1;
        break;

        
      case GETLASTEVENT:
        msg->u.last_event = rs[c].last_event;
        do_reply = 1;
        break;
        
      default:
        WARNING("Got unknown msg id '%d' in handleFifos()!\n", msg->id);
        do_reply = 0;
        break;
      }
      
      errcode = rtf_put(shm->fifo_out[c], &dummy, sizeof(dummy));
      if (errcode != sizeof(dummy)) {
        static int once_only = 0;
        if (!once_only) 
          ERROR("rtos_fifo_put to fifo_out %d returned %d!\n", shm->fifo_out[c], errcode), once_only++;
      }
  } else if (errcode != 0) {
      static int once_only = 0;
      if (!once_only)
        ERROR("got return value of (%d) when reading from fifo_in %d\n", errcode, shm->fifo_in[c]), once_only++;
  }

  /** locking only does something for non-realtime! */
  UNLOCK_TRIGGERS();

  return 0;
}

static void grabAllDIO(void)
{
  /* Remember previous bits */
  dio_bits_prev = dio_bits;

  if ( COMEDI_TRIGGERS() ) 
  {
      /* Grab all the input channels at once */
      comedi_dio_bitfield(dev, subdev, 0, (unsigned int *)&dio_bits);
      dio_bits &= ((1 << (num_trig_chans+first_trig_chan)) - 1) & ~((1 << first_trig_chan) - 1) ; /* Mask out unwanted channels */

      if (debug && dio_bits && ullmod(cycle, sampling_rate) == 0)
        DEBUG("READS 0x%x\n", dio_bits);
  }

}

/**< returns 0 on no input detected, positive for play id 
   or negative for stop id */
static int detectEvent(CardID_t c)
{
  int ret = 0;

  if (rs[c].forced_event) {
    ret = rs[c].forced_event;
    rs[c].forced_event = 0;
    return ret;
  }

  if (COMEDI_TRIGGERS() && dio_bits != dio_bits_prev) {

      unsigned trig_tmp;
      /* Grab the exact channels we want.. */
      trig_tmp = (dio_bits>>first_trig_chan) & ((0x1<<num_trig_chans) - 1);
      ret = trig_tmp;
      /* Special case, 1 trig chan means 0/1 is stop/start.. */
      if (num_trig_chans == 1 && trig_tmp == 0) ret = -1; 
      /* Check for sign bit? Last bit is 'sign' bit, and it it's set, we are supposed to return the negative value of trig_tmp.. */
      else if (num_trig_chans > 1 && trig_tmp & (0x1<<(num_trig_chans-1))) 
        ret = -((int)(trig_tmp & ((0x1<<(num_trig_chans-1))-1)));
      
  }

  return ret;
}

static void doPossiblyRampedStop(unsigned c, unsigned chan)
{
  DEBUG("doPossiblyRampedStop called for card %u channel %u\n", c, chan);
  if (chan >= L22_NUM_CHANS || c >= n_l22dev) {
    DEBUG("doPossiblyRampedStop got invalid card %u chan %u!\n", c, chan);
    return;
  }
  if (!rs[c].last_played_buf[chan] || !rs[c].last_played_buf[chan]->stop_ramp_tau_ms || !L22IsPlaying(l22dev[c], chan)) /* paranoia */ {
    /* call L22stop just in case.. */
    L22Stop(l22dev[c], chan);
    CM_ClearChannel(channels[c], chan);

    if (rs[c].last_played_buf[chan] && !rs[c].last_played_buf[chan]->stop_ramp_tau_ms)
      DEBUG("doPossiblyRampedStop skipped a ramping stop because tau_ms is 0!\n");
    else
      DEBUG("doPossiblyRampedStop skipped a ramping stop because there is no sound playing!");

  } else if (rs[c].last_played_buf[chan]) {
    struct RamperThread *thr = &ramperThreads[c][chan];
    if ( !atomic_read(&thr->tauParam) ) {
      /* give ramper thread its tau_ms param.. */
      atomic_set(&thr->tauParam, rs[c].last_played_buf[chan]->stop_ramp_tau_ms);
      /* wake up ramper thread.. */
      sem_post(&thr->sem); 
    } else {
      DEBUG("doPossiblyRampedStop skipped a ramping stop because there already is a ramping stop running!\n");
    }
    rs[c].last_played_buf[chan] = 0; /* need to clear this because it should only get set once when a sound is played */
  }
}

static int createRamperThreads(void)
{
    int chan, error = 0;
    unsigned dev;
    for (dev = 0; dev < n_l22dev; ++dev) 
      for (chan = 0; chan < L22_NUM_CHANS; ++chan) 
        {
          /* Create a separate threads that run in realtime every .1 ms
             and do the cosine2 ramping function -- they sleep on their
             semaphore when not needed. */
          pthread_attr_t attr;
          struct sched_param sched_param;      
          struct RamperThread *thr = &ramperThreads[dev][chan];
          
          memset(thr, 0, sizeof(*thr)); /* clear/init the data structure.. */
          
          thr->chan = chan;
          thr->dev = dev;
          error = sem_init(&thr->sem, 0, 0); /* init the semaphore */
          
          if (!error) {
            
            /* Setup pthread data, etc.. */
            pthread_attr_init(&attr);
            error = pthread_attr_setfp_np(&attr, 1);
            if (!error) {
              sched_param.sched_priority = 1;
              error = pthread_attr_setschedparam(&attr, &sched_param);  
              if (!error) {
                error = pthread_create(&thr->thread, &attr, 
                                       cosine2RamperThread, (void *)thr);
              }
            }
            
          }
          
          if (error) {
            WARNING("createRamperThreads() could not create the cosine2RamperThread #%d (%d)!\n", chan, error);
            break;
          }
        }
    return error;
}

static void destroyRamperThreads(void)
{
  int chan;
  unsigned dev;
  for (dev = 0; dev < n_l22dev; ++dev) 
    for (chan = 0; chan < L22_NUM_CHANS; ++chan) {
      struct RamperThread *thr = &ramperThreads[dev][chan];
      if (thr->thread) {
        void *count = 0;
        atomic_set(&thr->stop, 1);
        sem_post(&thr->sem);
        pthread_join(thr->thread, &count);
        DEBUG("ramper thread %u:%d deleted after %u successful rampings!\n", dev, chan, (unsigned)count);
        thr->thread = 0;
      }
      sem_destroy(&thr->sem);
    }
}

/* just like clock_gethrtime but instead it used timespecs */
static inline void clock_gettime(clockid_t clk, struct timespec *ts)
{
  hrtime_t now = clock_gethrtime(clk);
  nano2timespec(now, ts);  
}

static inline void nano2timespec(hrtime_t time, struct timespec *t)
{
  unsigned long rem = 0;
  t->tv_sec = ulldiv(time, 1000000000, &rem);
  t->tv_nsec = rem;
}
static inline unsigned long long ulldiv(unsigned long long ull, unsigned long uld, unsigned long *r)
{
    if (r) *r = do_div(ull, uld);
    else do_div(ull, uld);
    return ull;
}
static inline unsigned long ullmod(unsigned long long ull, unsigned long uld)
{         
        unsigned long ret;
        ulldiv(ull, uld, &ret);
        return ret;
}

static inline unsigned long Nano2Sec(unsigned long long nano)
{
  unsigned long rem = 0;
  return ulldiv(nano, BILLION, &rem);
}

static inline unsigned long Nano2USec(unsigned long long nano)
{
  unsigned long rem = 0;
  return ulldiv(nano, 1000, &rem);
}


static const char *uint64_to_cstr(uint64 num)
{
  static const uint64 ZEROULL = 0ULL;
  static const uint32 dividend = 10;
  static char buf[21];
  int ct = 0, i;
  uint64 quotient = num;
  unsigned long remainder;
  char reversebuf[21];

  buf[0] = 0;

  /* convert to base 10... results will be reversed */
  do {
    remainder = do_div(quotient, dividend);
    reversebuf[ct++] = remainder + '0';
  } while (quotient != ZEROULL);

  /* now reverse the reversed string... */
  for (i = 0; i < ct; i++) 
    buf[i] = reversebuf[(ct-i)-1];
  
  /* add null... */
  buf[ct] = 0;
  
  return buf;
}

static inline long Micro2Sec(long long micro, unsigned long *remainder)
{
  int neg = micro < 0;
  unsigned long rem;
  if (neg) micro = -micro;
  long ans = ulldiv(micro, 1000000, &rem);
  if (neg) ans = -ans;
  if (remainder) *remainder = rem;
  return ans;
}

extern double cos(double);

static inline double cos2(double r) { double c = cos(r); return c*c; }

static void *cosine2RamperThread(void *arg)
{
  static const unsigned long task_period_nanos = BILLION/2500; /* .4 ms task period */
  static const double HALF_PI = 3.14159/2.0;
  struct RamperThread *me = (struct RamperThread *)arg;
  unsigned num_handled = 0;
  unsigned short tau_ms;
  sem_t *mySemaphore = &me->sem;
  atomic_t *myStopFlg = &me->stop, *myParam = &me->tauParam;
  const unsigned chan = me->chan;
  const unsigned dev = me->dev;
  const L22Dev_t ldev = l22dev[dev];
  const unsigned v_init = L22GetVolume(ldev, chan);

  while ( !atomic_read(myStopFlg) ) {
    if ( !(tau_ms = atomic_read(myParam)) )  sem_wait(mySemaphore); 
    else {
      const unsigned total_loops = (tau_ms*MILLION)/task_period_nanos;
      const double t_incr = 1.0/(total_loops ? ((double)total_loops) : 1.0);
      double t = 0.0;
      struct timespec next_task_wakeup;
      
      clock_gettime(CLOCK_REALTIME, &next_task_wakeup);
      
      /* Keep looping until either:
         1. the device is stopped (could be from a call outside this code)
         2. someone reset the tau_ms (from dispatchEvent() when another
            sound was triggered while we were looping)
         3. We finish the ramp-down.. */
      while (L22IsPlaying(ldev, chan) && t <= 1.0 && atomic_read(myParam)) {
        unsigned vol = v_init * cos2(t*HALF_PI);
        t += t_incr;
        L22SetVolume(ldev, chan, vol);
        if (debug > 1) DEBUG("ramper%u:%u: setvolume: %u\n", dev, chan, vol);

        timespec_add_ns(&next_task_wakeup, task_period_nanos);
        /* Sleep until next period */
        clock_nanosleep(CLOCK_REALTIME, TIMER_ABSTIME, &next_task_wakeup, 0); 
      }
      if (L22IsPlaying(ldev, chan)) { 
        L22Stop(ldev, chan);
        CM_ClearChannel(channels[dev], chan); 
      }
      L22SetVolume(ldev, chan, v_init); 
      atomic_set(myParam, 0);
      ++num_handled;
    }
  }
  return (void *)num_handled;
}

static void cancelAnyRunningRampedStops(unsigned c, unsigned chan)
{
  if (c < n_l22dev && chan < L22_NUM_CHANS) 
    atomic_set(&ramperThreads[c][chan].tauParam, 0);  
}

static void stopAllChans(CardID_t c)
{
  unsigned chan;
  
  for (chan = 0; chan < L22_NUM_CHANS; ++chan) {
      DevChan dc;
      dc.dev = c;
      dc.chan = chan;
      doCmdInRTThread(STOP_CMD, dc.devchan_voidp);
      /*L22Stop(chan);  above is better -- since l22 funcs now have to be 
        called from RT only! */
  }
  CM_Reset(channels[c]);
}

static int initChanMapper(void) 
{ 
  unsigned i;
  memset(channels, 0, sizeof(channels));
  for (i = 0; i < n_l22dev; ++i) {
    channels[i] = CM_Init(l22dev[i], debug ? rtl_printf : 0);
    if (!channels[i]) return -ENOMEM; 
  }
  return 0;
}

static void destroyChanMapper(void)
{
  unsigned i;
  for (i = 0; i < n_l22dev; ++i) 
    if (channels[i]) CM_Destroy(channels[i]);
  memset(channels, 0, sizeof(channels));
}

/* Some thread functions used to implement some fifo commands.  These are
   called from either a real-time thread spawned by handleFifos in 
   SOFTWARE_TRIGGERS mode or from the rt-task in hardware triggers mode. */
static void *doPlayCmd(void *arg) 
{ 
  DevChan dc;
  dc.devchan_voidp = arg;
  L22Play(l22dev[dc.dev], dc.chan);
  return (void *)1; 
}
static void *doStopCmd(void *arg) 
{
  DevChan dc;
  dc.devchan_voidp = arg;
  L22Stop(l22dev[dc.dev], dc.chan);
  return (void *)1; 
}

static void *doResetCmd(void *arg) 
{
  unsigned card = (unsigned)arg;
  
  /* Just to make sure we start off fresh ... */
  stopAllChans(card);
  freeAudioBuffers(card);
  initRunState(card);
  return (void *)1;
}

static void *doEventCmd(void *arg) 
{
  DevEvt de;  
  de.devevt_voidp = arg;
  dispatchEvent(de.dev, de.evt);
  return (void *)1;
}

static void *doCmdInRTThread(int cmd, void *arg)
{
  void *(*func)(void *) = 0;
  switch (cmd) {
  case FORCEEVENT: func = doEventCmd; break;
  case RESET: func = doResetCmd; break;
  case STOP_CMD: func = doStopCmd; break;
  case PLAY_CMD: func = doPlayCmd; break;
  default:
    ERROR("*** Internal Error *** Invalid command passed to doCmdInRTThread: %d!\n", cmd);
    return 0;
  }
  if (func) {
    if ( pthread_self() == pthread_linux() ) {
      /* we are not in an rt thread, so spawn a new thread and wait for it */
      pthread_t thr;
      void * ret;
      int err = pthread_create(&thr, 0, func, arg);
      if (err) {
        ERROR("*** Internal Error *** Could not create RT thread in doCmdInRTThread: %d!\n", cmd);
        return 0;
      }
      pthread_join(thr, &ret);
      return ret;
    } else  /* already in an rt-thread, just call the func */
    return func(arg);  
  }
  /* not _normally_ reached.. */
  return 0;
}

/**
 * Rat Experiments FSM, for use at CSHL
 *
 * Note this RT program requires a lot of memory (something like 40 MB!)
 *
 * TODO: optimize it to not use *so* much memory in the average case.
 *
 * Calin A. Culianu <calin@ajvar.org>
 * License: GPL v2 or later.
 */

#include <linux/module.h> 
#include <linux/kernel.h>
#include <linux/version.h>
#include <linux/types.h>
#include <linux/errno.h>
#include <linux/bitops.h>
#include <linux/delay.h>
#include <asm/semaphore.h> /* for synchronization primitives           */
#include <asm/bitops.h>    /* for set/clear bit                        */
#include <linux/slab.h>
#include <linux/vmalloc.h>
#include <linux/string.h> /* some memory copyage                       */
#include <linux/proc_fs.h>
#include <asm/div64.h>    /* for do_div 64-bit division macro          */
#include <linux/list.h>
#include <linux/spinlock.h>
#include <linux/comedilib.h>
#include <linux/seq_file.h>
#include <rtl.h>
#include <rtl_time.h>
#include <rtl_fifo.h>
#include <rtl_sched.h>
#include <rtl_mutex.h>
#include <rtl_sync.h>
#include <mbuff.h>

#if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0)
/* 2.4 kernel lacks this function, so we will emulate it using the function
   it does have ffs(), which thinks of the first bit as bit 1, but we want the
   first bit to be bit 0. */
static __inline__ int __ffs(int x) { return ffs(x)-1; }
#endif

#include "RatExpFSM.h"
#include "../LynxTrig/LynxTrigVirt.h" /* Ehh ugly, I know.. but it's a 
                                         hack for now.. */
#include "FSMExternalTime.h" /* for the external time shm stuff */
#include "softtask.h" /* for asynchronous process context kernel tasks! */

#define MODULE_NAME "RatExpFSM"
#ifdef MODULE_LICENSE
  MODULE_LICENSE("GPL");
#endif

#define LOG_MSG(x...) rtl_printf(KERN_INFO MODULE_NAME ": "x)
#define WARNING(x...) rtl_printf(KERN_WARNING MODULE_NAME ": WARNING - " x)
#define ERROR(x...) rtl_printf(KERN_ERR MODULE_NAME": ERROR - " x)
#define ERROR_INT(x... ) rtl_printf(KERN_CRIT MODULE_NAME": INTERNAL ERROR - " x)
#define DEBUG(x... ) do { if (debug) rtl_printf(KERN_DEBUG MODULE_NAME": DEBUG - " x); } while (0)

MODULE_AUTHOR("Calin A. Culianu");
MODULE_DESCRIPTION(MODULE_NAME ": A Real-Time experiment for CSHL.");

int init(void);  /**< Initialize data structures and register callback */
void cleanup(void); /**< Cleanup.. */

/** Index into RunState rs array declared below.. */
typedef unsigned FSMID_t;

static int initRunStates(void);
static int initRunState(FSMID_t);
static int initShm(void);
static int initBuddyTask(void);
static int initFifos(void);
static int initTaskPeriod(void);
static int initRT(void);
static int initComedi(void);
static void reconfigureIO(void); /* helper that reconfigures DIO channels 
                                    for INPUT/OUTPUT whenever the state 
                                    matrix, etc changes, computes ai_chans_in_use_mask, di_chans_in_use_mask, etc */
static int initAISubdev(void); /* Helper for initComedi() */
static int initAOSubdev(void); /* Helper for initComedi() */
static int setupComediCmd(void);
static void cleanupAOWaves(FSMID_t);
struct AOWaveINTERNAL;
static void cleanupAOWave(volatile struct AOWaveINTERNAL *, FSMID_t fsm_id, int bufnum);

/* The callback called by rtlinux scheduler every task period... */
static void *doFSM (void *);

/* Called whenever the /proc/RatExpFSM proc file is read */
static int myseq_show (struct seq_file *m, void *d);
static int myseq_open(struct inode *, struct file *);
static struct file_operations myproc_fops =
{
  open:    myseq_open,
  read:    seq_read,
  llseek:  seq_lseek,
  release: single_release
};

module_init(init);
module_exit(cleanup);


/*---------------------------------------------------------------------------- 
  Some private 'global' variables...
-----------------------------------------------------------------------------*/
static volatile Shm *shm = 0;
static volatile struct LynxTrigVirtShm *lynxTrigShm = 0; /* For lynx sound triggering.. */
static volatile struct FSMExtTimeShm *extTimeShm = 0; /* for external time synch. */

#define JITTER_TOLERANCE_NS 76000
#define MAX_HISTORY 65536 /* The maximum number of state transitions we remember -- note that the struct StateTransition is currently 16 bytes so the memory we consume (in bytes) is this number times 16! */
#define DEFAULT_SAMPLING_RATE 6000
#define DEFAULT_AI_SAMPLING_RATE 10000
#define DEFAULT_AI_SETTLING_TIME 5
#define DEFAULT_TRIGGER_MS 1
#define DEFAULT_AI "synch"
#define MAX_AI_CHANS (sizeof(unsigned)*8)
#define MAX(a,b) ( a > b ? a : b )
#define MIN(a,b) ( a < b ? a : b )
static char COMEDI_DEVICE_FILE[] = "/dev/comediXXXXXXXXXXXXXXX";
int minordev = 0, minordev_ai = -1, minordev_ao = -1,
    sampling_rate = DEFAULT_SAMPLING_RATE, 
    ai_sampling_rate = DEFAULT_AI_SAMPLING_RATE, 
    ai_settling_time = DEFAULT_AI_SETTLING_TIME,  /* in microsecs. */
    trigger_ms = DEFAULT_TRIGGER_MS,    
    debug = 0,
    avoid_redundant_writes = 0;
char *ai = DEFAULT_AI;

#ifndef STR
#define STR1(x) #x
#define STR(x) STR1(x)
#endif
MODULE_PARM(minordev, "i");
MODULE_PARM_DESC(minordev, "The minor number of the comedi device to use.");
MODULE_PARM(minordev_ai, "i");
MODULE_PARM_DESC(minordev_ai, "The minor number of the comedi device to use for AI.  -1 to probe for first AI subdevice (defaults to -1).");
MODULE_PARM(minordev_ao, "i");
MODULE_PARM_DESC(minordev_ao, "The minor number of the comedi device to use for AO.  -1 to probe for first AO subdevice (defaults to -1).");
MODULE_PARM(sampling_rate, "i");
MODULE_PARM_DESC(sampling_rate, "The sampling rate.  Defaults to " STR(DEFAULT_SAMPLING_RATE) ".");
MODULE_PARM(ai_sampling_rate, "i");
MODULE_PARM_DESC(ai_sampling_rate, "The sampling rate for asynch AI scans.  Note that this rate only takes effect when ai=asynch.  This is the rate at which to program the DAQ boad to do streaming AI.  Defaults to " STR(DEFAULT_AI_SAMPLING_RATE) ".");
MODULE_PARM(ai_settling_time, "i");
MODULE_PARM_DESC(ai_settling_time, "The amount of time, in microseconds, that it takes an AI channel to settle.  This is a function of the max sampling rate of the board. Defaults to " STR(DEFAULT_AI_SETTLING_TIME) ".");
MODULE_PARM(trigger_ms, "i");
MODULE_PARM_DESC(trigger_ms, "The amount of time, in milliseconds, to sustain trigger outputs.  Defaults to " STR(DEFAULT_TRIGGER_MS) ".");
MODULE_PARM(debug, "i");
MODULE_PARM_DESC(debug, "If true, print extra (cryptic) debugging output.  Defaults to 0.");
MODULE_PARM(avoid_redundant_writes, "i");
MODULE_PARM_DESC(avoid_redundant_writes, "If true, do not do comedi DIO writes during scans that generated no new output.  Defaults to 0 (false).");
MODULE_PARM(ai, "s");
MODULE_PARM_DESC(ai, "This can either be \"synch\" or \"asynch\" to determine whether we use asynch IO (comedi_cmd: faster, less compatible) or synch IO (comedi_data_read: slower, more compatible) when acquiring samples from analog channels.  Note that for asynch to work properly it needs a dedicated realtime interrupt.  Defaults to \""DEFAULT_AI"\".");

#define FIRST_IN_CHAN(f) (rs[(f)].states->routing.first_in_chan)
#define NUM_IN_CHANS(f) (rs[(f)].states->routing.num_in_chans)
#define OUTPUT_ROUTING(f,i) ((struct OutputSpec *)&rs[(f)].states->routing.output_routing[i])
#define NUM_OUT_COLS(f) (rs[(f)].states->routing.num_out_cols)
#define AFTER_LAST_IN_CHAN(f) (FIRST_IN_CHAN(f)+NUM_IN_CHANS(f))
#define NUM_AI_CHANS ((const unsigned)n_chans_ai_subdev)
#define NUM_AO_CHANS ((const unsigned)n_chans_ao_subdev)
#define NUM_DIO_CHANS ((const unsigned)n_chans_dio_subdev)
#define READY_FOR_TRIAL_JUMPSTATE(f) (rs[(f)].states->ready_for_trial_jumpstate)
#define NUM_INPUT_EVENTS(f)  (rs[(f)].states->routing.num_evt_cols)
#define NUM_IN_EVT_CHANS(f) (NUM_IN_CHANS(f))
#define NUM_IN_EVT_COLS(f) (rs[(f)].states->routing.num_evt_cols)
#define NUM_ROWS(f) (rs[(f)].states->n_rows)
#define NUM_COLS(f) (rs[(f)].states->n_cols)
#define TIMER_EXPIRED(f,state_timeout_us) ( (rs[(f)].current_ts - rs[(f)].current_timer_start) >= ((int64)(state_timeout_us))*1000LL )
#define RESET_TIMER(f) (rs[(f)].current_timer_start = rs[(f)].current_ts)
#define NUM_TRANSITIONS(f) ((rs[(f)].history.num_transitions))
#define IN_CHAN_TYPE(f) ((const unsigned)rs[(f)].states->routing.in_chan_type)
#define AI_THRESHOLD_VOLTS_HI ((const unsigned)4)
#define AI_THRESHOLD_VOLTS_LOW ((const unsigned)3)
enum { SYNCH_MODE = 0, ASYNCH_MODE, UNKNOWN_MODE };
#define AI_MODE ((const unsigned)ai_mode)
#define FSM_PTR(f) ((struct FSMBlob *)(rs[(f)].states))
#define OTHER_FSM_PTR(f) ((struct FSMBlob *)(FSM_PTR(f) == &rs[(f)].states1 ? &rs[(f)].states2 : &rs[(f)].states1))
#define INPUT_ROUTING(f,x) (rs[(f)].states->routing.input_routing[(x)])
#define SW_INPUT_ROUTING(f,x) ( !rs[(f)].states->has_sched_waves ? -1 : rs[(f)].states->routing.sched_wave_input[(x)] )
#define SW_OUTPUT_ROUTING(f,x) ( !rs[(f)].states->has_sched_waves ? -1 : rs[(f)].states->routing.sched_wave_output[(x)] )
static struct proc_dir_entry *proc_ent = 0;
static volatile int rt_task_stop = 0; /* Internal variable to stop the RT 
                                         thread. */
static volatile int rt_task_running = 0;

static struct SoftTask *buddyTask[NUM_STATE_MACHINES] = {0}, /* non-RT kernel-side process context buddy 'tasklet' */
                       *buddyTaskComedi = 0;
static pthread_t rt_task;
static comedi_t *dev = 0, *dev_ai = 0, *dev_ao = 0;
static unsigned subdev = 0, subdev_ai = 0, subdev_ao = 0, n_chans_ai_subdev = 0, n_chans_dio_subdev = 0, n_chans_ao_subdev = 0, maxdata_ai = 0, maxdata_ao = 0;

static unsigned long fsm_cycle_long_ct = 0, fsm_wakeup_jittered_ct = 0;
static unsigned long ai_n_overflows = 0;

/* Comedi CB stats */
static unsigned long cb_eos_skips = 0, cb_eos_skipped_scans = 0;

/* Remembered state of all DIO channels.  Bitfield array is indexed
   by DIO channel-id. */
unsigned dio_bits = 0, dio_bits_prev = 0, ai_bits = 0, ai_bits_prev = 0;
lsampl_t ai_thresh_hi = 0, /* Threshold, above which we consider it 
                              a digital 1 */
         ai_thresh_low = 0; /* Below this we consider it a digital 0. */

sampl_t ai_samples[MAX_AI_CHANS]; /* comedi_command callback copies samples to here, or our grabAI synch function puts samples here */
void *ai_asynch_buf = 0; /* pointer to driver's DMA circular buffer for AI. */
comedi_krange ai_krange, ao_krange; 
unsigned long ai_asynch_buffer_size = 0; /* Size of driver's DMA circ. buf. */
unsigned ai_range = 0, ai_mode = UNKNOWN_MODE, ao_range = 0;
unsigned ai_chans_in_use_mask = 0, di_chans_in_use_mask = 0, do_chans_in_use_mask = 0; 
unsigned int lastTriggers; /* Remember the trigger lines -- these 
                              get shut to 0 after 1 cycle                */
uint64 cycle = 0; /* the current cycle */
uint64 trig_cycle[NUM_STATE_MACHINES] = {0}; /* The cycle at which a trigger occurred, useful for deciding when to clearing a trigger (since we want triggers to last trigger_ms) */
#define BILLION 1000000000
#define MILLION 1000000
uint64 task_period_ns = BILLION;
#define Sec2Nano(s) (s*BILLION)
static inline unsigned long Nano2Sec(unsigned long long nano);
static inline unsigned long Nano2USec(unsigned long long nano);
static inline long Micro2Sec(long long micro, unsigned long *remainder);
static inline long long timespec_to_nano(const struct timespec *);
static inline void UNSET_LYNX_TRIG(unsigned which_card, unsigned trig);
static inline void SET_LYNX_TRIG(unsigned which_cast, unsigned trig);
static inline void CHK_AND_DO_LYNX_TRIG(FSMID_t f, unsigned which_card, unsigned trig);
#define ABS(n) ( (n) < 0 ? -(n) : (n) )
/*---------------------------------------------------------------------------- 
  More internal 'global' variables and data structures.
-----------------------------------------------------------------------------*/
struct StateHistory
{
  /* The state history is a circular history.  It is a series of 
     state number/timestamp pairs, that keeps growing until it loops around
     to the beginning.                                                       */
  struct StateTransition transitions[MAX_HISTORY];
  unsigned num_transitions; /* Number of total transitions since RESET of state
                               machine.  
                               Index into array: num_transitions%MAX_HISTORY */
};

struct RunState {
    /* TODO: verify this is smp-safe.                                        */
    
    /* FSM Specification */
    
    /* The actual state transition specifications -- 
       we have two of them since we swap them when a new FSM comes in from
       userspace to avoid dropping events during ITI. */
    struct FSMBlob    states1;
    struct FSMBlob    states2;
    struct FSMBlob   *states;

    /* End FSM Specification. */

    unsigned current_state;
    int64 current_ts; /* Time elapsed, in ns, since init_ts */
    int64 ext_current_ts; /** Abs. time from external reference -- 
                              see FSMExtTimeShm and FSMExternalTime.h */
    int64 init_ts; /* Time of initialization, in nanoseconds.  Absolute
                      time derived from the Pentium's monotonically 
                      increasing TSC. */        
    int64 current_timer_start; /* When, in ns, the current timer  started 
                                  -- relative to current_ts. */
    unsigned previous_state; 
    

    int forced_event; /* If non-negative, force this event. */
    int forced_times_up; /* If true, time's up event will be forced this tick,
                            gets set from ShmMsg cmd from userspace..*/

    /* This gets populated from FIFO cmd, and if not empty, specifies
       outputs that are "always on". */
    unsigned int forced_outputs_mask; /**< Bitmask indexed by DIO channel-id */

    int valid; /* If this is true, the FSM task uses the state machine,
                  if false, the FSM task ignores the state machine.
                  useful when userspace wants to 'upload' a new state 
                  machine (acts like a sort of a lock).                      */

    int paused; /* If this is true, input lines do not lead to 
                   state transitions.  Useful when we want to temporarily 
                   pause state progression to play with the wiring, etc.
                   Note that this is almost identical to !valid flag
                   for all intents and purposes, but we differentiate from
                   invalid state machines and paused ones for now..          */

    int ready_for_trial_flg; /* If true, that means we got a 
                                READYFORTRIAL command from userspace.  
                                This indicates that the next time
                                we are in state 35, we should jump to state 0. 
                             */

  /** Mimes of the scheduled waves that came in from the FSMBlob.  These 
      mimics contain times, relative to current_ts, at which each of the
      components of the wave are due to take place: from edge-up, to
      edge-down, to wave termination (after the refractory period). */     
  struct ActiveWave {
    int64 edge_up_ts;   /**< from: current_ts + SchedWave::preamble_us       */
    int64 edge_down_ts; /**< from: edge_up_ts + SchedWave::sustain_us        */
    int64 end_ts;       /**< from: edge_down_ts + SchedWave::refractory_us   */
  } active_wave[FSM_MAX_SCHED_WAVES];
  /** A quick mask of the currently active scheduled waves.  The set bits
      in this mask correspond to array indices of the active_wave
      array above. */
  unsigned active_wave_mask;
  /** A quick mask of the currently active AO waves.  The set bits
      in this mask correspond to array indices of the aowaves array outside 
      this struct. */
  unsigned active_ao_wave_mask; 
  /** Store pointers to analog output wave data -- 
   *  Note: to avoid memory leaks make sure initRunState() is never called when
   *  we have active valid pointers here!  This means that aowaves should be cleaned
   *  up (freed) using cleanupAOWaves() whenever we get a new FSM.  cleanupAOWaves()
   *  needs to be called in Linux process context. */
  struct AOWaveINTERNAL 
  {
    unsigned aoline, nsamples, loop, cur;
    unsigned short *samples;
    signed char *evt_cols;
  } aowaves[FSM_MAX_SCHED_WAVES];

  /** Keep track, on a per-state-machine-basis the AI channels used for DAQ */
  unsigned daq_ai_nchans, daq_ai_chanmask;

  /** Keep track of trigger and cont chans per state machine */
  unsigned do_chans_trig_mask, do_chans_cont_mask;

  /** Keep track of the last IP out trig values to avoid sending dupe packets -- used by doOutput() */
  char last_ip_outs_is_valid[FSM_MAX_OUT_EVENTS];
  /** Keep track of the last IP out trig values to avoid sending dupe packets -- used by doOutput() */
  unsigned last_ip_outs[FSM_MAX_OUT_EVENTS];

  unsigned pending_fsm_swap; /**< iff true, need to swap fsms on next state0 
                                  crossing */

  /* This *always* should be at the end of this struct since we don't clear
     the whole thing in initRunState(), but rather clear bytes up until
     this point! */
    struct StateHistory history;             /* Our state history record.   */
};

volatile static struct RunState rs[NUM_STATE_MACHINES];


/*---------------------------------------------------------------------------
 Some helper functions
-----------------------------------------------------------------------------*/
static inline volatile struct StateTransition *historyAt(FSMID_t, unsigned);
static inline volatile struct StateTransition *historyTop(FSMID_t);
static inline void historyPush(FSMID_t, int event_id);

static int gotoState(FSMID_t, unsigned state_no, int event_id_for_history); /**< returns 1 if new state, 0 if was the same and no real transition ocurred, -1 on error */
static unsigned long detectInputEvents(FSMID_t); /**< returns 0 on no input detected, otherwise returns bitfield array of all the events detected -- each bit corresponds to a state matrix "in event column" position, eg center in is bit 0, center out is bit 1, left-in is bit 2, etc */
static int doSanityChecksStartup(void); /**< Checks mod params are sane. */
static int doSanityChecksRuntime(FSMID_t); /**< Checks FSM input/output params */
static void doOutput(FSMID_t);
static void clearAllOutputLines(FSMID_t);
static inline void clearTriggerLines(FSMID_t);
static void dispatchEvent(FSMID_t, unsigned event_id);
static void handleFifos(FSMID_t);
static inline void dataWrite(unsigned chan, unsigned bit);
static void commitDataWrites(void);
static void grabAllDIO(void);
static void grabAI(void); /* AI version of above.. */
static void doDAQ(void); /* does the data acquisition for remaining channels that grabAI didn't get.  See STARTDAQ fifo cmd. */
static unsigned long processSchedWaves(FSMID_t); /**< updates active wave state, does output, returns event id mask of any waves that generated input events (if any) */
static unsigned long processSchedWavesAO(FSMID_t); /**< updates active wave state, does output, returns event id mask of any waves that generated input events (if any) */
static void scheduleWave(FSMID_t, unsigned wave_id, int op);
static void scheduleWaveDIO(FSMID_t, unsigned wave_id, int op);
static void scheduleWaveAO(FSMID_t, unsigned wave_id, int op);
static void stopActiveWaves(FSMID_t); /* called when FSM starts a new trial */
static void updateHasSchedWaves(FSMID_t);
static void swapFSMs(FSMID_t);

/* just like clock_gethrtime but instead it used timespecs */
static inline void clock_gettime(clockid_t clk, struct timespec *ts);
static inline void nano2timespec(hrtime_t time, struct timespec *t);
/* 64-bit division is not natively supported on 32-bit processors, so it must 
   be emulated by the compiler or in the kernel, by this function... */
static inline unsigned long long ulldiv(unsigned long long dividend, unsigned long divisor, unsigned long *remainder);
/* Just like above, but does modulus */
static inline unsigned long ullmod(unsigned long long dividend, unsigned long divisor);
static inline long long lldiv(long long ll, long ld, long *r);
/* this function is non-reentrant! */
static const char *uint64_to_cstr(uint64 in);
/* this function is reentrant! */
static int uint64_to_cstr_r(char *buf, unsigned bufsz, uint64 num);
static unsigned long transferCircBuffer(void *dest, const void *src, unsigned long offset, unsigned long bytes, unsigned long bufsize);
/* Place an unsigned int into the debug fifo.  This is currently used to
   debug AI 0 reads.  Only useful for development.. */
static inline void putDebugFifo(unsigned value);
static void printStats(void);
static void buddyTaskHandler(void *arg);
static void buddyTaskComediHandler(void *arg);

/*-----------------------------------------------------------------------------*/

int init (void)
{
  int retval = 0;
  
  if (    (retval = initTaskPeriod())
       || (retval = initShm())
       || (retval = initFifos())
       || (retval = initRunStates())
       || (retval = initBuddyTask())
       || (retval = initComedi())
       || (retval = initRT())
       || (retval = doSanityChecksStartup()) )
    {
      cleanup();  
      return retval;
    }  
  
  proc_ent = create_proc_entry(MODULE_NAME, S_IFREG|S_IRUGO, 0);
  if (proc_ent) {  /* if proc_ent is zero, we silently ignore... */
    proc_ent->owner = THIS_MODULE;
    proc_ent->uid = 0;
    proc_ent->proc_fops = &myproc_fops;
  }

  printk(MODULE_NAME": started successfully at %d Hz.\n", sampling_rate);
  
  return retval;
}

void cleanup (void)
{
  FSMID_t f;

  if (proc_ent)
    remove_proc_entry(MODULE_NAME, 0);

  if (rt_task_running) {
    rt_task_stop = 1;
    pthread_cancel(rt_task);
    pthread_join(rt_task, 0);
  }
  for (f = 0; f < NUM_STATE_MACHINES; ++f) {
    cleanupAOWaves(f);

    if (buddyTask[f]) softTaskDestroy(buddyTask[f]);
    buddyTask[f] = 0;
  }
  if (buddyTaskComedi) softTaskDestroy(buddyTaskComedi);
  buddyTaskComedi = 0;

  if (dev) {
    comedi_unlock(dev, subdev);
    comedi_close(dev);
    dev = 0;
  }

  if (dev_ai) {
    comedi_cancel(dev_ai, subdev_ai);
    comedi_unlock(dev_ai, subdev_ai);
    /* Cleanup any comedi_cmd */
    if ( AI_MODE == ASYNCH_MODE )
      comedi_register_callback(dev_ai, subdev_ai, 0, 0, 0);
    comedi_close(dev_ai);
    dev_ai = 0;
  }

  if (dev_ao) {
    comedi_unlock(dev_ao, subdev_ao);
    comedi_close(dev_ao);
    dev_ao = 0;
  }

  if (shm)  { 
    for (f = 0; f < NUM_STATE_MACHINES; ++f) {
      if (shm->fifo_in[f] >= 0) rtf_destroy(shm->fifo_in[f]);
      if (shm->fifo_out[f] >= 0) rtf_destroy(shm->fifo_out[f]);
      if (shm->fifo_trans[f] >= 0) rtf_destroy(shm->fifo_trans[f]);
      if (shm->fifo_daq[f] >= 0) rtf_destroy(shm->fifo_daq[f]);
      if (shm->fifo_nrt_output[f] >= 0) rtf_destroy(shm->fifo_nrt_output[f]);
    }
    if (shm->fifo_debug >= 0) rtf_destroy(shm->fifo_debug);
    mbuff_free(SHM_NAME, (void *)shm); 
    shm = 0; 
  }
  if (lynxTrigShm) {
    /* Kcount needs to be decremented so need to detach.. */
    mbuff_detach(LYNX_TRIG_VIRT_SHM_NAME, (void *)lynxTrigShm);
    lynxTrigShm = NULL;
  }
  if (extTimeShm) {
    /* Kcount needs to be decremented so need to detach.. */
    mbuff_detach(FSM_EXT_TIME_SHM_NAME, (void *)extTimeShm);
    extTimeShm = NULL;
  }
  printStats();
}

static void printStats(void)
{
  if (debug && cb_eos_skips) 
    DEBUG("skipped %u times, %u scans\n", cb_eos_skips, cb_eos_skipped_scans);
  
  printk(MODULE_NAME": unloaded successfully after %s cycles.\n",
         uint64_to_cstr(cycle));
}

static int initBuddyTask(void)
{
  FSMID_t f;
  for (f = 0; f < NUM_STATE_MACHINES; ++f) {
    buddyTask[f] = softTaskCreate(buddyTaskHandler, MODULE_NAME" Buddy Task");
    if (!buddyTask[f]) return -ENOMEM;
  }
  buddyTaskComedi = softTaskCreate(buddyTaskComediHandler, MODULE_NAME" Comedi Buddy Task");
  if (!buddyTaskComedi) return -ENOMEM;
  return 0;
}

static int initShm(void)
{
  FSMID_t f;

  shm = (volatile struct Shm *) mbuff_alloc(SHM_NAME, SHM_SIZE);
  if (! shm)  return -ENOMEM;
  
  memset((void *)shm, 0, sizeof(*shm));
  shm->magic = SHM_MAGIC;
  
  shm->fifo_debug = -1;
  
  for (f = 0; f < NUM_STATE_MACHINES; ++f)
    shm->fifo_nrt_output[f] = shm->fifo_daq[f] = shm->fifo_trans[f] = shm->fifo_out[f] = shm->fifo_in[f] = -1;

  lynxTrigShm = mbuff_attach(LYNX_TRIG_VIRT_SHM_NAME, LYNX_TRIG_VIRT_SHM_SIZE);
  if (!lynxTrigShm) {
    LOG_MSG("Could not attach to SHM %s.\n", LYNX_TRIG_VIRT_SHM_NAME);
    return -ENOMEM;
  } else if (!LYNX_TRIG_VIRT_SHM_IS_VALID(lynxTrigShm)) {
    WARNING("Attached to SHM %s, but it appears to be invalid currently (this could change later if LynxTrig-RT.o is loaded).\n", 
	    LYNX_TRIG_VIRT_SHM_NAME);
  }

  extTimeShm = mbuff_attach(FSM_EXT_TIME_SHM_NAME, FSM_EXT_TIME_SHM_SIZE);
  if (!extTimeShm) {
    LOG_MSG("Could not attach to SHM %s.\n", FSM_EXT_TIME_SHM_NAME);
    return -ENOMEM;    
  } else if (!FSM_EXT_TIME_SHM_IS_VALID(extTimeShm)) {
    WARNING("Attached to SHM %s, but it appears to be invalid currently (this could change later if a kernel module that uses this shm is loaded).\n", FSM_EXT_TIME_SHM_NAME);
  }
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
  int32 err, minor;
  FSMID_t f;

  /* Open up fifos here.. */
  
  for (f = 0; f < NUM_STATE_MACHINES; ++f) {
    err = find_free_rtf(&minor, FIFO_SZ);
    if (err < 0) return 1;
    shm->fifo_out[f] = minor;
    err = find_free_rtf(&minor, FIFO_SZ);
    if (err < 0) return 1;
    shm->fifo_in[f] = minor;
    err = find_free_rtf(&minor, FIFO_TRANS_SZ);
    if (err < 0) return 1;
    shm->fifo_trans[f] = minor;
    err = find_free_rtf(&minor, FIFO_DAQ_SZ);
    if (err < 0) return 1;
    shm->fifo_daq[f] = minor;
    err = find_free_rtf(&minor, FIFO_NRT_OUTPUT_SZ);
    if (err < 0) return 1;
    shm->fifo_nrt_output[f] = minor;
    
    DEBUG("FIFOS: For FSM %u in %d out %d trans %d daq %d nrt_out %d\n", f, shm->fifo_in[f], shm->fifo_out[f], shm->fifo_trans[f], shm->fifo_daq[f], shm->fifo_nrt_output[f]);
  }

  if (debug) {
    err = find_free_rtf(&minor, 3072); /* 3kb fifo enough? */  
    if (err < 0) return 1;
    shm->fifo_debug = minor;
    DEBUG("FIFOS: Debug %d\n", shm->fifo_debug);
  }

  return 0;  
}

static int initRunStates(void)
{
  FSMID_t f;
  int ret = 0;
  for (f = 0; !ret && f < NUM_STATE_MACHINES; ++f) ret |= initRunState(f);
  return ret;
}

static int initRunState(FSMID_t f)
{
  /* Clear the runstate memory area.. note how we only clear the beginning
     and don't touch the state history since it is rather large! */
  memset((void *)&rs[f], 0, sizeof(rs[f]) - sizeof(struct StateHistory));
  rs[f].states = (struct FSMBlob *)&rs[f].states1;

  /* Now, initialize the history.. */
  rs[f].history.num_transitions = 0; /* indicate no state history. */

  /* clear first element of transitions array to be anal */
  memset((void *)&rs[f].history.transitions[0], 0, sizeof(rs[f].history.transitions[0]));
  
  /* Grab current time from gethrtime() which is really the pentium TSC-based 
     timer  on most systems. */
  rs[f].init_ts = gethrtime();

  RESET_TIMER(f);

  rs[f].forced_event = -1; /* Negative value here means not forced.. this needs
                              to always reset to negative.. */
  rs[f].paused = 1; /* By default the FSM is paused initially. */
  rs[f].valid = 0; /* Start out with an 'invalid' FSM since we expect it
                      to be populated later from userspace..               */
  
  return 0;  
}

static int initComedi(void) 
{
  int n_chans = 0, ret;

  ai_mode = 
    (!strcmp(ai, "synch")) 
    ? SYNCH_MODE 
    : ( (!strcmp(ai, "asynch")) 
        ? ASYNCH_MODE 
        : UNKNOWN_MODE );
  
  if (!dev) {
    int sd;

    sprintf(COMEDI_DEVICE_FILE, "/dev/comedi%d", minordev);
    dev = comedi_open(COMEDI_DEVICE_FILE);
    if (!dev) {
      ERROR("Cannot open Comedi device at %s\n", COMEDI_DEVICE_FILE);
      return -EINVAL/*comedi_errno()*/;
    }

    sd = comedi_find_subdevice_by_type(dev, COMEDI_SUBD_DIO, 0);    
    if (sd < 0 || (n_chans = comedi_get_n_channels(dev, sd)) <= 0) {
      printk(MODULE_NAME": DIO subdevice requires a DIO subdevice.\n");
      comedi_close(dev);
      dev = 0;
      return -ENODEV;
    }

    subdev = sd;
    n_chans_dio_subdev = n_chans;
    comedi_lock(dev, subdev);
  }

  DEBUG("COMEDI: n_chans /dev/comedi%d = %u\n", minordev, n_chans);  

  reconfigureIO();

  /* Set up AI subdevice for synch/asynch acquisition in case we ever opt to 
     use AI for input. */
  ret = initAISubdev();
  if ( ret ) return ret;    

  /* Probe for or open the AO subdevice for analog output (sched waves to AO)*/
  ret = initAOSubdev();
  if ( ret ) return ret;

  return 0;
}

static void reconfigureIO(void)
{
  int i, reconf_ct = 0;
  static unsigned char old_modes[FSM_MAX_IN_CHANS];
  static char old_modes_init = 0;
  hrtime_t start;
  FSMID_t f;

  start = gethrtime();

  if (!old_modes_init) {
    for (i = 0; i < FSM_MAX_IN_CHANS; ++i)
      old_modes[i] = 0x6e;
    old_modes_init = 1;
  }

  ai_chans_in_use_mask = 0;
  di_chans_in_use_mask = 0;
  do_chans_in_use_mask = 0;

  for (f = 0; f < NUM_STATE_MACHINES; ++f) {
    rs[f].do_chans_cont_mask = 0;
    rs[f].do_chans_trig_mask = 0;
    /* indicate to doOutputs() that the last_ip_outs array is to be ignored
       until an output occurs on that ip_out column */
    memset((void *)&rs[f].last_ip_outs_is_valid, 0, sizeof(rs[f].last_ip_outs_is_valid));

    for (i = FIRST_IN_CHAN(f); i < NUM_IN_CHANS(f); ++i)
      if (IN_CHAN_TYPE(f) == AI_TYPE)
        ai_chans_in_use_mask |= 0x1<<i;
      else
        di_chans_in_use_mask |= 0x1<<i;
    for (i = 0; i < NUM_OUT_COLS(f); ++i) {
      struct OutputSpec *spec = OUTPUT_ROUTING(f,i);
      switch (spec->type) {
      case OSPEC_DOUT:
        rs[f].do_chans_cont_mask |= ((0x1<<(spec->to+1 - spec->from))-1) << spec->from;        
        break;
      case OSPEC_TRIG:
        rs[f].do_chans_trig_mask |= ((0x1<<(spec->to+1 - spec->from))-1) << spec->from;
        break;
      }
      do_chans_in_use_mask |= rs[f].do_chans_cont_mask|rs[f].do_chans_trig_mask;
    }
  }

  DEBUG("ReconfigureIO masks: ai_chans_in_use_mask 0x%x di_chans_in_use_mask 0x%x do_chans_in_use_mask 0x%x\n", ai_chans_in_use_mask, di_chans_in_use_mask, do_chans_in_use_mask);

  /* Now, setup channel modes correctly */
  for (i = 0; i < NUM_DIO_CHANS; ++i) {
      unsigned char mode;
      unsigned char *old_mode;
      if ((0x1<<i) & di_chans_in_use_mask) mode =  COMEDI_INPUT;
      else if ((0x1<<i) & do_chans_in_use_mask) mode = COMEDI_OUTPUT;
      else continue;
      old_mode = (i < FSM_MAX_IN_CHANS) ? &old_modes[i] : 0;
      if (old_mode && *old_mode == mode) continue; /* don't redundantly configure.. */
      ++reconf_ct;
      if ( comedi_dio_config(dev, subdev, i, mode) != 1 )
        WARNING("comedi_dio_config returned error for channel %u mode %d\n", i, (int)mode);
      
      DEBUG("COMEDI: comedi_dio_config %u %d\n", i, (int)mode);
      if (old_mode) *old_mode = mode; /* remember old configuration.. */
  }

  if (reconf_ct)
    LOG_MSG("Cycle %lu: Reconfigured %d DIO chans in %lu nanos.\n", (unsigned long)cycle, reconf_ct, (unsigned long)(gethrtime()-start));
}

static int initAISubdev(void)
{
  int m, s = -1, n, i, range = -1;
  int minV = INT_MIN, maxV = INT_MAX;

  if (minordev_ai >= 0) {
      /* They specified an AI subdevice, so try and use it. */

      sprintf(COMEDI_DEVICE_FILE, "/dev/comedi%d", minordev_ai);    
      if ( !(dev_ai = comedi_open(COMEDI_DEVICE_FILE)) ) {
        ERROR("Cannot open Comedi device at %s\n", COMEDI_DEVICE_FILE);
        return -EINVAL;
      }
      s = comedi_find_subdevice_by_type(dev_ai, COMEDI_SUBD_AI, 0);
      if (s < 0) {
        ERROR("Could not find any AI subdevice on %s!\n", COMEDI_DEVICE_FILE);
        return -EINVAL;          
      }
      subdev_ai = s;
  } else { /* They specified probe of AI:  minordev_ai < 0 */

      /* Now, attempt to probe AI subdevice, etc. */
      while (minordev_ai < 0) {
        for (m = 0; m < COMEDI_NDEVICES; ++m) {
          sprintf(COMEDI_DEVICE_FILE, "/dev/comedi%d", m);
          if ( (dev_ai = comedi_open(COMEDI_DEVICE_FILE)) ) {
            s = comedi_find_subdevice_by_type(dev_ai, COMEDI_SUBD_AI, 0);
            if (s >= 0) {
              n = comedi_get_n_channels(dev_ai, s);
              if (n < 1) {
                WARNING("%s, subdev %d not enough AI channels (we require %d but found %d).\n", COMEDI_DEVICE_FILE, s, (int)1, n);
              } else {
                n_chans_ai_subdev = n;
                break; /* Everything's copacetic, skip the close code below */
              }
            } 
            /* AI subdev not found or incompatible, try next minor, closing current dev_ai first */
            comedi_close(dev_ai);
            dev_ai = 0;              
          }
        }
        if (s < 0) {
          /* Failed to probe/find an AI subdev. */
          ERROR("Could not find any AI subdevice on any comedi devices on the system!\n");
          return -EINVAL;
        } else {
          minordev_ai = m;
          subdev_ai = s;
        }
      }
  }
  /* we got a dev_ai and subdev_ai unconditionally at this point, so lock it */
  comedi_lock(dev_ai, subdev_ai);

  /* set up the ranges we want.. which is the closest range to 0-5V */
  n = comedi_get_n_ranges(dev_ai, subdev_ai, 0);
  for (i = 0; i < n; ++i) {
    comedi_get_krange(dev_ai, subdev_ai, 0, i, &ai_krange);
    if (RF_UNIT(ai_krange.flags) == UNIT_volt /* If it's volts we're talking 
                                                 about */
        && minV < ai_krange.min && maxV > ai_krange.max /* And this one is 
                                                           narrower than the 
                                                           previous */
        && ai_krange.min <= 0 && ai_krange.max >= 5*1000000) /* And it 
                                                            encompasses 0-5V */
      {
        /* Accept this range, save it, and determine the ai_thresh value
           which is important for making decisions about what a '1' or '0' is. 
        */
        maxdata_ai =  comedi_get_maxdata(dev_ai, subdev_ai, 0);

        ai_range = range = i;
        minV = ai_krange.min;
        maxV = ai_krange.max;
        /* Determine threshold, we set it to 4 Volts below... */
        if (maxV != minV) {
          /* NB: this tmpLL business is awkward but if avoids integer underflow
             and/or overflow and is necessary.  The alternative is to use 
             floating point which is prohibited in the non-realtime kernel! */
          long long tmpLL = AI_THRESHOLD_VOLTS_HI * 1000000LL - (long long)minV;
          long rem_dummy;
          tmpLL *= (long long)maxdata_ai;
          ai_thresh_hi =  lldiv(tmpLL, maxV - minV, &rem_dummy);
          tmpLL = AI_THRESHOLD_VOLTS_LOW * 1000000LL - (long long)minV;
          tmpLL *= (long long)maxdata_ai;
          ai_thresh_low = lldiv(tmpLL, maxV - minV, &rem_dummy);
        } else 
          /* This should not occur, just here to avoid divide-by-zero.. */
          ai_thresh_hi = ai_thresh_low = 0;
      }
  }
  if (range < 0) {
    WARNING("Could not determine any valid range for %s AI subdev!  Defaulting to 0-5V with comedi range id = 0!\n", COMEDI_DEVICE_FILE);
    /* now fudge the range settings.. */
    minV = ai_krange.min = 0;
    maxV = ai_krange.max = 5000000;
    ai_krange.flags = UNIT_volt;
    ai_range = 0;
    maxdata_ai  = comedi_get_maxdata(dev_ai, subdev_ai, 0);
    ai_thresh_hi = AI_THRESHOLD_VOLTS_HI * 10 / 5 * maxdata_ai / 10;
    ai_thresh_low = AI_THRESHOLD_VOLTS_LOW * 10 / 5 * maxdata_ai / 10;    
  }
  DEBUG("AI dev: %s subdev: %d range: %d min: %d max: %d thresh (%dV-%dV): %u-%u maxdata: %u \n", COMEDI_DEVICE_FILE, (int)subdev_ai, (int)ai_range, minV, maxV, AI_THRESHOLD_VOLTS_LOW, AI_THRESHOLD_VOLTS_HI, ai_thresh_low, ai_thresh_hi, maxdata_ai);

  /* Setup comedi_cmd */
  if ( AI_MODE == ASYNCH_MODE ) {
    int err = setupComediCmd();
    if (err) return err;
  }

  return 0;
}

static int initAOSubdev(void)
{
  int m, s = -1, n, i, range = -1;
  int minV = INT_MIN, maxV = INT_MAX;

  if (minordev_ao >= 0) {
      /* They specified an AO subdevice, so try and use it. */

      sprintf(COMEDI_DEVICE_FILE, "/dev/comedi%d", minordev_ao);    
      if ( !(dev_ao = comedi_open(COMEDI_DEVICE_FILE)) ) {
        ERROR("Cannot open Comedi device at %s\n", COMEDI_DEVICE_FILE);
        return -EINVAL;
      }
      s = comedi_find_subdevice_by_type(dev_ao, COMEDI_SUBD_AO, 0);
      if (s < 0) {
        ERROR("Could not find any AO subdevice on %s!\n", COMEDI_DEVICE_FILE);
        return -EINVAL;          
      }
      subdev_ao = s;
  } else { /* They specified probe:  minordev_ao < 0 */

      /* Now, attempt to probe AO subdevice, etc. */
      while (minordev_ao < 0) {
        for (m = 0; m < COMEDI_NDEVICES; ++m) {
          sprintf(COMEDI_DEVICE_FILE, "/dev/comedi%d", m);
          if ( (dev_ao = comedi_open(COMEDI_DEVICE_FILE)) ) {
            s = comedi_find_subdevice_by_type(dev_ao, COMEDI_SUBD_AO, 0);
            if (s >= 0) {
              n = comedi_get_n_channels(dev_ao, s);
              if (n < 1) {
                WARNING("%s, subdev %d not enough AO channels (we require %d but found %d).\n", COMEDI_DEVICE_FILE, s, (int)1, n);
              } else {
                n_chans_ao_subdev = n;
                break; /* Everything's copacetic, skip the close code below */
              }
            } 
            /* AO subdev not found or incompatible, try next minor, closing current dev_ao first */
            comedi_close(dev_ao);
            dev_ao = 0;
          }
        }
        if (s < 0) {
          /* Failed to probe/find an AO subdev. */
          ERROR("Could not find any AO subdevice on any comedi devices on the system!\n");
          return -EINVAL;
        } else {
          minordev_ao = m;
          subdev_ao = s;
        }
      }
  }
  /* we got a dev_ao and subdev_ao unconditionally at this point, so lock it */
  comedi_lock(dev_ao, subdev_ao);

  /* set up the ranges we want.. which is the closest range to 0-5V */
  n = comedi_get_n_ranges(dev_ao, subdev_ao, 0);
  for (i = 0; i < n; ++i) {
    comedi_get_krange(dev_ao, subdev_ao, 0, i, &ao_krange);
    if (RF_UNIT(ao_krange.flags) == UNIT_volt /* If it's volts we're talking 
                                                 about */
        && minV < ao_krange.min && maxV > ao_krange.max /* And this one is 
                                                           narrower than the 
                                                           previous */
        && ao_krange.min <= 0 && ao_krange.max >= 5*1000000) /* And it 
                                                            encompasses 0-5V */
      {
        /* Accept this range, save it. */
        maxdata_ao =  comedi_get_maxdata(dev_ao, subdev_ao, 0);

        ao_range = range = i;
        minV = ao_krange.min;
        maxV = ao_krange.max;
      }
  }
  if (range < 0) {
    ERROR("Could not determine any valid range for %s AO subdev!\n", COMEDI_DEVICE_FILE);
    return -EINVAL;
  }  
  DEBUG("AO dev: %s subdev: %d range: %d min: %d max: %d maxdata: %u \n", COMEDI_DEVICE_FILE, (int)subdev_ao, (int)ao_range, minV, maxV, maxdata_ao);

  return 0;
}

static inline unsigned long transferCircBuffer(void *dest, 
                                               const void *src, 
                                               unsigned long offset, 
                                               unsigned long bytes, 
                                               unsigned long bufsize)
{
  char *d = (char *)dest;
  const char *s = (char *)src;
  unsigned long nread = 0;
  while (bytes) {
    unsigned long n = bytes;
    if ( offset + n > bufsize) { 
      /* buffer wrap-around condition.. */
      if (debug > 1) DEBUG("transferCircBuffer: buffer wrapped around!\n");
      n = bufsize - offset;
    }
    if (!n) {
      offset = 0;
      continue;
    }
    memcpy(d + nread, s + offset, n);
    if (debug > 1) DEBUG("transferCircBuffer: copied %lu bytes!\n", n);
    bytes -= n;
    offset += n;
    nread += n;
  }  
  return offset;
}

/** Called by comedi during asynch IO to tell us a scan ended. */
static int comediCallback(unsigned int mask, void *ignored)
{
  char timeBuf[22] = {0};
  (void)ignored;

  if (debug > 1) {
    /* used in debug sections below.. */
    uint64_to_cstr_r(timeBuf, sizeof(timeBuf), gethrtime()); 
  }

  if (mask & COMEDI_CB_EOA) {
    /* Ignore EOA */
    DEBUG("comediCallback: got COMEDI_CB_EOA.\n");
  }
  if (mask & COMEDI_CB_ERROR) {
    WARNING("comediCallback: got COMEDI_CB_ERROR!\n");    
  }
  if (mask & COMEDI_CB_OVERFLOW) {
    ++ai_n_overflows;
    WARNING("comediCallback: got COMEDI_CB_OVERFLOW! Attempting to restart acquisition!\n");
    comedi_cancel(dev_ai, subdev_ai);
    /* slow operation to restart the comedi command, so just pend it
       to non-rt buddy task which runs in process context and can take its 
       sweet-assed time.. */
    softTaskPend(buddyTaskComedi, 0); 
    return 0;
  }
  if (mask & COMEDI_CB_BLOCK) {
    if (debug > 2) 
        DEBUG("comediCallback: got COMEDI_CB_BLOCK at abs. time %s.\n", timeBuf);
  }
  if (mask & COMEDI_CB_EOS) {
    /* This is what we want.. EOS. Now copy scans from the comedi driver 
       buffer: ai_asynch_buf, to our local data structure for feeding to 
       RT... */
    int  offset   = comedi_get_buffer_offset(dev_ai, subdev_ai),
         numBytes = comedi_get_buffer_contents(dev_ai, subdev_ai);
    const int oneScanBytes = sizeof(sampl_t)*NUM_AI_CHANS;
    int  numScans = numBytes / (oneScanBytes ? oneScanBytes : numBytes+1),
         lastScanOffset = (offset + ((numScans-1)*oneScanBytes))
                          % ai_asynch_buffer_size;
    char *buf = (char *)ai_asynch_buf;

    if (debug > 2) 
      DEBUG("comediCallback: got COMEDI_CB_EOS at abs. time %s, with %d bytes (offset: %d) of data.\n", timeBuf, numBytes, offset);
    
    if (numScans > 1) {
      if (debug > 2) DEBUG("COMEDI_CB_EOS with more than one scan's data:  Expected %d, got %d.\n", oneScanBytes, numBytes);
      cb_eos_skips++;
      cb_eos_skipped_scans += numScans-1;
    } else if (numScans <= 0) {
      static int onceOnly = 0;
      if (!onceOnly) {
        ERROR("**** BUG in COMEDI driver!  COMEDI_CB_EOS callback called with less than one scan's data available.  Expected: %d, got %d!\n", oneScanBytes, numBytes);
        onceOnly = 1;
        /*comedi_cancel(dev_ai, subdev_ai);*/
      }        
      return -EINVAL;
    }

    /* NB: We *need* to pull exactly one scan.. not more!  It didn't
       occur to me initially that this callback sometimes gets called
       late, when the board already has put some samples of the next
       scan in the DMA buffer for us!  Thus, it is bad bad bad to
       consume all available data.  Instead, we should just consume
       exactly the last full scan available (but not any partial
       scans!).  Note that it is also theoretically possible that we
       were called so late that more than one scan is available, so we
       will take the latest scan.
    */
    
    /* 
       Points to remember:

       1. Consume everything up to and including the last whole scan only. 
       
       2. Leave partial scans in the DMA buffer.  We need to maintain the 
          invariant that the buffer always starts on a scan boundary. 
    */
    { 
      unsigned long flags;
      
      rtl_critical(flags); /* Lock machine, disable interrupts.. to avoid
                              race conditions with RT since we write to 
                              ai_samples. */

      /* Read only the latest full scan available.. */
      lastScanOffset = 
        transferCircBuffer(ai_samples, /* dest */
                           buf,  /* src */
                           lastScanOffset, /* offset into src */
                           oneScanBytes, /* num */
                           ai_asynch_buffer_size); /* circ buf size */

      /* consume all full scans up to present... */
      comedi_mark_buffer_read(dev_ai, subdev_ai, numScans * oneScanBytes);
      rtl_end_critical(flags); /* Unlock machine, reenable interrupts... */

      /* puts chan0 to the debug fifo iff in debug mode */
      putDebugFifo(ai_samples[0]); 
    }

  } /* end if COMEDI_CB_EOS */
  return 0;
}

/** This function sets up asynchronous streaming acquisition for AI
    input.  It is a pain to get working and doesn't work on all boards. */
static int setupComediCmd(void)
{
  comedi_cmd cmd;
  int err, i;
  unsigned int chanlist[MAX_AI_CHANS];

  /* Clear sample buffers.. */
  memset(ai_samples, 0, sizeof(ai_samples));

  /* First, setup our callback func. */
  err = comedi_register_callback(dev_ai, subdev_ai,  COMEDI_CB_EOA|COMEDI_CB_ERROR|COMEDI_CB_OVERFLOW|COMEDI_CB_EOS/*|COMEDI_CB_BLOCK*/, comediCallback, 0);

  if ( err ) {
    ERROR("comedi_register_callback returned %d, failed to setup comedi_cmd.\n", err);
    return err;
  }

  /* Next, setup our comedi_cmd */
  memset(&cmd, 0, sizeof(cmd));
  cmd.subdev = subdev_ai;
  cmd.flags = TRIG_WAKE_EOS|TRIG_RT|TRIG_ROUND_DOWN; /* do callback every scan, try to use RT, round period down */
  cmd.start_src = TRIG_NOW;
  cmd.start_arg = 0;
  cmd.scan_begin_src = TRIG_TIMER;

  if (ai_sampling_rate < sampling_rate) {
    ai_sampling_rate = sampling_rate;
    WARNING("setupComediCmd: ai_sampling rate was too low.  Forced it to %d.\n", ai_sampling_rate);
  }

  cmd.scan_begin_arg = BILLION / ai_sampling_rate; /* Pray we don't overflow here */
  cmd.convert_src = TRIG_TIMER; 
  cmd.convert_arg =  ai_settling_time * 1000; /* settling time in nanos */ 
/*   cmd.convert_arg = 0; /\* try to avoid intersample delay?? *\/ */
  cmd.scan_end_src = TRIG_COUNT;
  cmd.scan_end_arg = NUM_AI_CHANS;
  cmd.stop_src = TRIG_NONE;
  cmd.stop_arg = 0;
  /*cmd.data = ai_samples;
    cmd.data_len = NUM_AI_CHANS; */
  
  for (i = 0; i < (int)NUM_AI_CHANS; ++i) 
    chanlist[i] = CR_PACK(i, ai_range, AREF_GROUND);
  cmd.chanlist = chanlist;
  cmd.chanlist_len = i; 

  err = comedi_command_test(dev_ai, &cmd);
  if (err == 3)  err = comedi_command_test(dev_ai, &cmd); 
  if (err != 4 && err != 0) {
    ERROR("Comedi command could not be started, comedi_command_test returned: %d!\n", err);
    return err;
  }

  /* obtain a pointer to the command buffer */
  err = comedi_map(dev_ai, subdev_ai, (void *)&ai_asynch_buf);
  if (err) {
    ERROR("Comedi command could not be started, comedi_map() returned: %d!\n", err);
    return err;
  }
  ai_asynch_buffer_size = comedi_get_buffer_size(dev_ai, subdev_ai);
  DEBUG("Comedi Asynch buffer at 0x%p of size %d\n", ai_asynch_buf, ai_asynch_buffer_size);

  err = comedi_command(dev_ai, &cmd);
  if (err) {
    ERROR("Comedi command could not be started, comedi_command returned: %d!\n", err);
    return err;
  }

  if (cmd.scan_begin_arg != BILLION / ai_sampling_rate) {
    WARNING("Comedi Asynch IO rate requested was %d, got %lu!\n", BILLION / ai_sampling_rate, (unsigned long)cmd.scan_begin_arg);
  }

  LOG_MSG("Comedi Asynch IO started with period %u ns.\n", cmd.scan_begin_arg);
  
  return 0;
}

static int initTaskPeriod(void)
{
  unsigned long rem;

  /* setup task period.. */
  if (sampling_rate <= 0 || sampling_rate >= BILLION) {
    LOG_MSG("Sampling rate of %d seems crazy, going to default of %d\n", sampling_rate, DEFAULT_SAMPLING_RATE);
    sampling_rate = DEFAULT_SAMPLING_RATE;
  }
  task_period_ns = ulldiv(BILLION, sampling_rate, &rem);

  return 0;
}

static int initRT(void)
{
#ifdef USE_OWN_STACK
#define TASK_STACKSIZE 8192
  static char TASK_STACK[TASK_STACKSIZE];
#endif
  pthread_attr_t attr;
  struct sched_param sched_param;
  int error;

  /* Setup pthread data, etc.. */
  pthread_attr_init(&attr);
  pthread_attr_setfp_np(&attr, 1);
#ifdef USE_OWN_STACK
  error = pthread_attr_setstackaddr(&attr, TASK_STACK);
  if (error) return -error;
  error = pthread_attr_setstacksize(&attr, TASK_STACKSIZE);  
  if (error) return -error;
#endif
  sched_param.sched_priority = sched_get_priority_max(SCHED_FIFO);
  error = pthread_attr_setschedparam(&attr, &sched_param);  
  if (error) return -error;
  error = pthread_create(&rt_task, &attr, doFSM, 0);
  if (error) return -error;
  return 0;
}

/**< Checks that mod params are sane. */
static int doSanityChecksStartup(void)
{
  int ret = 0;
  
  if (AI_MODE != SYNCH_MODE && AI_MODE != ASYNCH_MODE) {
    ERROR("ai= module parameter invalid.  Please pass one of \"asynch\" or \"synch\".\n");
    ret = -EINVAL;
  }
          
  if (ai_settling_time <= 0) {
    WARNING("AI settling time of %d too small!  Setting it to 1 microsecond.\n",            ai_settling_time);
    ai_settling_time = 1;
  }

  return ret;
}

static int doSanityChecksRuntime(FSMID_t f)
{
  int ret = 0;
/*   int n_chans = n_chans_dio_subdev + NUM_AI_CHANS, ret = 0; */
/*   char buf[256]; */
/*   static int not_first_time[NUM_STATE_MACHINES] = {0}; */

  if (READY_FOR_TRIAL_JUMPSTATE(f) >= NUM_ROWS(f) || READY_FOR_TRIAL_JUMPSTATE(f) <= 0)  
    WARNING("ready_for_trial_jumpstate of %d need to be between 0 and %d!\n", 
            (int)READY_FOR_TRIAL_JUMPSTATE(f), (int)NUM_ROWS(f)); 
  
/*   if (dev && n_chans != NUM_CHANS(f) && debug) */
/*     WARNING("COMEDI devices have %d input channels which differs from the number of input channels indicated by the sum of FSM parameters num_in_chans+num_cont_chans+num_trig_chans=%d!\n", n_chans, NUM_CHANS(f)); */

/*   if (NUM_IN_CHANS < NUM_IN_EVT_CHANS)  */
/*     ERROR("num_in_chans of %d is less than hard-coded NUM_IN_EVT_CHANS of %d!\n", (int)NUM_IN_CHANS, (int)NUM_IN_EVT_CHANS), ret = -EINVAL; */

/*   if ( dev && n_chans < NUM_CHANS(f))  */
/*     ERROR("COMEDI device only has %d input channels, but FSM parameters require at least %d channels!\n", n_chans, NUM_CHANS(f)), ret = -EINVAL; */
  
  if (IN_CHAN_TYPE(f) == AI_TYPE && AFTER_LAST_IN_CHAN(f) > MAX_AI_CHANS) 
    ERROR("The input channels specified (%d-%d) exceed MAX_AI_CHANS (%d).\n", (int)FIRST_IN_CHAN(f), ((int)AFTER_LAST_IN_CHAN(f))-1, (int)MAX_AI_CHANS), ret = -EINVAL;
  if (ret) return ret;

/*   if (!not_first_time[f] || debug) { */
/*     LOG_MSG("FSM %u: Number of physical input channels is %d; Number actually used is %d; Virtual triggers start at 2^%d with %d total vtrigs (bit 2^%d is sound stop bit!)\n", f, n_chans, NUM_CHANS(f), VTRIG_OFFSET(f), NUM_VTRIGS(f), NUM_VTRIGS(f) ? VTRIG_OFFSET(f)+NUM_VTRIGS(f)-1 : 0); */

/*     snprintf(buf, sizeof(buf), "in chans: %d-%d ", FIRST_IN_CHAN(f), ((int)AFTER_LAST_IN_CHAN(f))-1); */
/*     if (NUM_CONT_CHANS(f)) */
/*       snprintf(buf + strlen(buf), sizeof(buf) - strlen(buf), "cont chans: %d-%d ", FIRST_CONT_CHAN(f), FIRST_CONT_CHAN(f)+NUM_CONT_CHANS(f)-1); */
/*     if (NUM_TRIG_CHANS(f)) */
/*       snprintf(buf + strlen(buf), sizeof(buf) - strlen(buf), "trig chans: %d-%d",FIRST_CONT_CHAN(f)+NUM_CONT_CHANS(f),FIRST_CONT_CHAN(f)+NUM_CONT_CHANS(f)+NUM_TRIG_CHANS(f)-1); */
/*     LOG_MSG("%s\n", buf); */
/*     not_first_time[f] = 1; */
/*   } */

  return 0;
}

static int myseq_open(struct inode *i, struct file *f)
{
  return single_open(f, myseq_show, 0);
}

static int myseq_show (struct seq_file *m, void *dummy)
{ 
  FSMID_t f;

  (void)dummy;
  seq_printf(m, "%s Module\n\nmagic: %08x\n\n", MODULE_NAME, shm->magic);

  seq_printf(m, 
             "Misc. Stats\n"
             "-----------\n"
             "Num Cycles Too Long: %lu\t"  "Num Cycles Wokeup Late/Early: %lu\n\n", 
             fsm_cycle_long_ct, fsm_wakeup_jittered_ct);

  if (AI_MODE == ASYNCH_MODE) {
    seq_printf(m,
               "AI Asynch Info\n"
               "--------------\n"
               "NumSkips: %lu\t"  "NumScansSkipped: %lu\t"  "NumAIOverflows: %lu\n\n",
               cb_eos_skips, cb_eos_skipped_scans, ai_n_overflows);    
  }

  for (f = 0; f < NUM_STATE_MACHINES; ++f) {
    if (f > 0) seq_printf(m, "\n"); /* additional newline between FSMs */

    seq_printf(m, 
               "FSM %u Info\n"
               "----------\n", f);

    if (!rs[f].valid) {
      seq_printf(m, "FSM is not specified or is invalid.\n");
    } else {
      int structlen = sizeof(struct RunState) - sizeof(struct StateHistory);
      struct RunState *ss = (struct RunState *)vmalloc(structlen);
      if (ss) {
        unsigned state_it;
        unsigned num_rows = NUM_ROWS(f), num_in_evts = NUM_IN_EVT_COLS(f);
        
        memcpy(ss, (struct RunState *)&rs[f], structlen);
        /* setup the pointer to the real fsm correctly */
        ss->states = (rs[f].states == &rs[f].states1 ? &ss->states1 : &ss->states2);
        
        seq_printf(m, "Current State: %d\t"    "Transition Count:%d\n", 
                   (int)ss->current_state,     (int)NUM_TRANSITIONS(f));      

        seq_printf(m, "\n"); /* extra nl */

        if (ss->paused) { 
          seq_printf(m,
                     "FSM %u State Table - Input Processing PAUSED\n"
                     "-------------------------------------------\n", f);
        } else {
          seq_printf(m,
                     "FSM %u State Table\n"
                     "-----------------\n", f);
        }
        
        
        for (state_it = 0; state_it < num_rows; ++state_it) {
          DECLARE_STATE_PTR(state);
          unsigned long i;
          GET_STATE(ss->states, state, state_it);
          seq_printf(m, "State %d:\t", (int)state_it);
          for (i = 0; i < num_in_evts; ++i) 
            seq_printf(m, "%d ", state->input[i]);
          seq_printf(m, "%d ", state->timeout_state);
          seq_printf(m, "%ld.%06lu ", Micro2Sec(state->timeout_us, &i), i);
          for (i = 0; i < state->n_outputs; ++i) 
            seq_printf(m, "%x ", state->output[i]);
          seq_printf(m, "\n");
        }

        { /* print input routing */
          unsigned i, j;
          seq_printf(m, "\nFSM %u Input Routing\n"
                          "-------------------\n", f);
          seq_printf(m, "%s Channel IDs: ", ss->states->routing.in_chan_type == AI_TYPE ? "AI" : "DIO");
          /* argh this is an O(n^2) algorithm.. sorry :( */
          for (i = 0; i < ss->states->routing.num_evt_cols; ++i)
            for (j = 0; j < FSM_MAX_IN_EVENTS; ++j)
              if (ss->states->routing.input_routing[j] == i) {
                int chan_id = j/2;
                seq_printf(m, "%c%d ", j%2 ? '-' : '+', chan_id);
                break;
              }
          seq_printf(m, "\n");
        }

        { /* print static timer info */
          
          unsigned tstate_col = ss->states->routing.num_evt_cols;
          seq_printf(m, "\nFSM %u Timeout Timer\n"
                          "-------------------\n", f);
          seq_printf(m, "Columns:\n");
          seq_printf(m, "\tColumn %u: timeout jump-state\n\tColumn %u: timeout time (seconds)\n", tstate_col, tstate_col+1);
        }

        { /* print output routing */
          unsigned i;
          seq_printf(m, "\nFSM %u Output Routing\n"
                     "--------------------\n", f);
          seq_printf(m, "Columns:\n");
          for (i = 0; i < ss->states->routing.num_out_cols; ++i) {
            seq_printf(m, "\tColumn %u: ", i+ss->states->routing.num_evt_cols+2);
            struct OutputSpec *spec = &ss->states->routing.output_routing[i];
            switch(spec->type) {
            case OSPEC_DOUT: 
            case OSPEC_TRIG: 
              seq_printf(m, "%s output on chans %u-%u\n", spec->type == OSPEC_DOUT ? "digital" : "trigger", spec->from, spec->to); 
              break;
            case OSPEC_SOUND: seq_printf(m, "sound triggering on card %u\n", spec->sound_card); break;
            case OSPEC_SCHED_WAVE: seq_printf(m, "scheduled wave trigger\n"); break;
            case OSPEC_TCP: 
            case OSPEC_UDP: {
              unsigned len = strlen(spec->fmt_text);
              char *text = kmalloc(len+1, GFP_KERNEL);
              if (text) {
                unsigned j;
                strncpy(text, spec->fmt_text, len);  text[len] = 0;
                /* strip newlines.. */
                for (j = 0; j < len; ++j) if (text[j] == '\n') text[j] = ' ';
              }
              seq_printf(m, "%s packet for host %s port %u text: \"%s\"\n", spec->type == OSPEC_TCP ? "TCP" : "UDP", spec->host, spec->port, text ? text : "(Could not allocate buffer to print text)"); 
              kfree(text);
            }
              break;
            case OSPEC_NOOP: 
              seq_printf(m, "no operation (column ignored)\n"); 
              break;              
            default: 
              seq_printf(m, "*UNKNOWN OUTPUT COLUMN TYPE!*\n");
              break;              
            }
          }
        }            

        if (ss->states->has_sched_waves) { /* Print Sched. Wave statistics */
          int i;
          seq_printf(m, "\nFSM %u Scheduled Wave Info\n"
                          "-------------------------\n", f);
          /* Print stats on AO Waves */
          for (i = 0; i < FSM_MAX_SCHED_WAVES; ++i) {
            if (ss->aowaves[i].nsamples && ss->aowaves[i].samples) {
              seq_printf(m, "AO  Sched. Wave %d  %u bytes (%s)\n", i, ss->aowaves[i].nsamples*(sizeof(*ss->aowaves[i].samples)+sizeof(*ss->aowaves[i].evt_cols)), ss->active_ao_wave_mask & 0x1<<i ? "playing" : "idle");
            }
          }
          /* Print stats on DIO Sched Waves */
          for (i = 0; i < FSM_MAX_SCHED_WAVES; ++i) {
            if (ss->states->sched_waves[i].enabled) {
              seq_printf(m, "DIO Sched. Wave %d  (%s)\n", i, ss->active_wave_mask & 0x1<<i ? "playing" : "idle");
            }
          }
        }
        vfree(ss);
      } else {
        seq_printf(m, "Cannot retrieve FSM data:  Temporary failure in memory allocation.\n");
      }    
    }
  }
  return 0;
}

static inline int triggersExpired(FSMID_t f)
{
  return cycle - trig_cycle[f] >= (sampling_rate/1000)*trigger_ms;
}

static inline void resetTriggerTimer(FSMID_t f)
{
  trig_cycle[f] = cycle;
}

/**
 * This function does the following:
 *  Detects edges, does state transitions, updates state transition history,
 *  and also reads commands off the real-time fifo.
 *  This function is called by rtlinux scheduler every task period... 
 *  @see init()
 */
static void *doFSM (void *arg)
{
  struct timespec next_task_wakeup;
  hrtime_t cycleT0, cycleTf;
  long long tmpts;
  FSMID_t f;

  (void)arg;

  rt_task_running = 1;

  clock_gettime(CLOCK_REALTIME, &next_task_wakeup);
    
  while (! rt_task_stop) {

    cycleT0 = gethrtime();

    /* see if we woke up jittery/late.. */
    tmpts = timespec_to_nano(&next_task_wakeup);
    tmpts = ((long long)cycleT0) - tmpts;
    if ( ABS(tmpts) > JITTER_TOLERANCE_NS ) {
      ++fsm_wakeup_jittered_ct;
      WARNING("Jittery wakeup! Magnitude: %ld ns (cycle #%lu)\n",
              (long)tmpts, (unsigned long)cycle);
      if (tmpts > 0) {
        /* fudge the task cycle period to avoid lockups? */
        clock_gettime(CLOCK_REALTIME, &next_task_wakeup);
      }
    }

    timespec_add_ns(&next_task_wakeup, (long)task_period_ns);

    ++cycle;

#ifdef DEBUG_CYCLE_TIME
    do {
      static long long last = 0;
      tmpts = gethrtime();
      if (last)
        rtl_printf("%d\n", (int)ts-last);
      last = ts;
    } while(0);
#endif
    
    for (f = 0; f < NUM_STATE_MACHINES; ++f) {
      if (lastTriggers && triggersExpired(f)) 
        /* Clears the results of the last 'trigger' output done, but only
           when the trigger 'expires' which means it has been 'sustained' in 
           the on position for trigger_ms milliseconds. */
        clearTriggerLines(f);
    }
    
      /* Grab both DI and AI chans depending on the chans in use mask which
         was setup by reconfigureIO. */
    if (di_chans_in_use_mask) grabAllDIO(); 
    if (ai_chans_in_use_mask) grabAI(); 
    
    for (f = 0; f < NUM_STATE_MACHINES; ++f) {
      /* Grab time */
      rs[f].current_ts = cycleT0 - rs[f].init_ts;
      rs[f].ext_current_ts = FSM_EXT_TIME_GET(extTimeShm);

      handleFifos(f);
      
      if ( rs[f].valid ) {

        unsigned long events_bits = 0;
        int got_timeout = 0, n_evt_loops;
        DECLARE_STATE_PTR(state);
        GET_STATE(rs[f].states, state, rs[f].current_state);
        
        
        if ( rs[f].forced_times_up ) {
          
          /* Ok, it was a forced timeout.. */
          if (state->timeout_us != 0) got_timeout = 1;
          rs[f].forced_times_up = 0;
          
        } 
        
        if (rs[f].forced_event > -1) {
          
          /* Ok, it was a forced input transition.. indicate this event in our bitfield array */
          events_bits |= 0x1 << rs[f].forced_event;
          rs[f].forced_event = -1;
          
        } 
        
        /* If we aren't paused.. detect timeout events and input events */
        if ( !rs[f].paused  ) {
          
          /* Check for state timeout -- 
             IF Curent state *has* a timeout (!=0) AND the timeout expired */
          if ( !got_timeout && state->timeout_us != 0 && TIMER_EXPIRED(f, state->timeout_us) )   {
            
            got_timeout = 1;
            
            if (debug > 1) {
              char buf[22];
              strncpy(buf, uint64_to_cstr(rs[f].current_ts), 21);
              buf[21] = 0;
              DEBUG("timer expired in state %u t_us: %u timer: %s ts: %s\n", rs[f].current_state, state->timeout_us, uint64_to_cstr(rs[f].current_timer_start), buf);
            }
            
          }
          
          /* Normal event transition code -- detectInputEvents() returns
             a bitfield array of all the input events we have right now.
             Note how we can have multiple ones, and they all get
             acknowledged by the loop later in this function!
             
             Note we |= this because we may have forced some event to be set 
             as part of the forced_event stuff in this function above.  */
          events_bits |= detectInputEvents(f);   
          
          if (debug >= 2) {
            DEBUG("FSM %u Got input events mask %08x\n", f, events_bits);
          }
          
          /* Process the scheduled waves by checking if any of their components
             expired.  For scheduled waves that result in an input event
             on edge-up/edge-down, they will return those event ids
             as a bitfield array.  */
          events_bits |= processSchedWaves(f);
          
          if (debug >= 2) {
            DEBUG("FSM %u After processSchedWaves(), got input events mask %08x\n", f, events_bits);
          }
          
          /* Process the scheduled AO waves -- do analog output for
             samples this cycle.  If there's an event id for the samples
             outputted, will get a mask of event ids.  */
          events_bits |= processSchedWavesAO(f);
          
          if (debug >= 2) {
            DEBUG("FSM %u After processSchedWavesAO(), got input events mask %08x\n", f, events_bits);
          }
          
        }
        
        if (got_timeout) 
          /* Timeout expired, transistion to timeout_state.. */
          gotoState(f, state->timeout_state, -1);
        
        
        /* Normal event transition code, keep popping ones off our 
           bitfield array, events_bits. */
        for (n_evt_loops = 0; events_bits && n_evt_loops < NUM_INPUT_EVENTS(f); ++n_evt_loops) {
          unsigned event_id; 
          
          /* use asm/bitops.h __ffs to find the first set bit */
          event_id = __ffs(events_bits);
          /* now clear or 'pop off' the bit.. */
          events_bits &= ~(0x1UL << event_id); 
          
          dispatchEvent(f, event_id);
        }
        
        if (NUM_INPUT_EVENTS(f) && n_evt_loops >= NUM_INPUT_EVENTS(f) && events_bits) {
          ERROR_INT("Event detection code in doFSM() for FSM %u tried to loop more than %d times!  DEBUG ME!\n", f, n_evt_loops, NUM_INPUT_EVENTS(f));
        }
        
      }
    } /* end loop through each state machine */

    commitDataWrites();   
    
    cycleTf = gethrtime();
    
    if ( cycleTf-cycleT0 + 1000LL > task_period_ns) {
        WARNING("Cycle %lu took %lu ns (task period is %lu ns)!\n", (unsigned long)cycle, ((unsigned long)(cycleTf-cycleT0)), (unsigned long)task_period_ns);
        ++fsm_cycle_long_ct;
        if ( (cycleTf - cycleT0) > task_period_ns ) {
          /* If it broke RT constraints, resynch next task wakeup to ensure
             we don't monopolize the CPU */
          clock_gettime(CLOCK_REALTIME, &next_task_wakeup);
          timespec_add_ns(&next_task_wakeup, (long)task_period_ns);
        }
    }
    
    /* do any necessary data acquisition and writing to shm->fifo_daq */
    doDAQ();

    /* Sleep until next period */    
    clock_nanosleep(CLOCK_REALTIME, TIMER_ABSTIME, &next_task_wakeup, 0);
  }

  rt_task_running = 0;
  pthread_exit(0);
  return 0;
}

static inline volatile struct StateTransition *historyAt(FSMID_t f, unsigned idx) 
{
  return &rs[f].history.transitions[idx % MAX_HISTORY];
}

static inline volatile struct StateTransition *historyTop(FSMID_t f)
{
  return historyAt(f, NUM_TRANSITIONS(f)-1);
}

static inline void transitionNotifyUserspace(FSMID_t f, volatile struct StateTransition *transition)
{
  const unsigned long sz = sizeof(*transition);
  int err = rtf_put(shm->fifo_trans[f], (void *)transition, sz);  
  if (debug && err != (int)sz) {
    DEBUG("FSM %u error writing to state transition fifo, got %d, expected %lu -- free space is %d\n", f, err, sz, RTF_FREE(shm->fifo_trans[f]));
  }
}

static inline void historyPush(FSMID_t f, int event_id)
{
  volatile struct StateTransition * transition;

  /* increment current index.. it is ok to increment indefinitely since 
     indexing into array uses % MAX_HISTORY */
  ++rs[f].history.num_transitions;
  
  transition = historyTop(f);
  transition->previous_state = rs[f].previous_state;
  transition->state = rs[f].current_state;
  transition->ts = rs[f].current_ts;  
  transition->ext_ts = rs[f].ext_current_ts;
  transition->event_id = event_id;
  transitionNotifyUserspace(f, transition);
}

static int gotoState(FSMID_t f, unsigned state, int event_id)
{
  if (debug > 1) DEBUG("gotoState %u %u %d s: %u\n", f, state, event_id, rs[f].current_state);

  if (state >= NUM_ROWS(f)) {
    ERROR_INT("FSM %u state id %d is >= NUM_ROWS %d!\n", f, (int)state, (int)NUM_ROWS(f));
    return -1;
  }

  if (state == READY_FOR_TRIAL_JUMPSTATE(f) && rs[f].ready_for_trial_flg) {
    /* Special case of "ready for trial" flag is set so we don't go to 
       state 35, but instead to 0 */    
    state = 0;
    stopActiveWaves(f); /* since we are starting a new trial, force any
                           active timer waves to abort! */
  }

  if (state == 0) {
    /* Hack */
    rs[f].ready_for_trial_flg = 0;

    /* we are jumping to state 0, and there is a pending fsm swap flag,
       we need to enter into the new FSM, so swapFSMs now.. */
    if (rs[f].pending_fsm_swap) swapFSMs(f);
  }

  rs[f].previous_state = rs[f].current_state;
  rs[f].current_state = state;
  historyPush(f, event_id); /* now add this transition to the history  */

  if (rs[f].current_state == rs[f].previous_state) 
  {
      /* Ok, the old state == the new state, that means we:

         1. *DO NOT* do any trigger outputs
         2. *DO NOT* do any continuous lines (keep the same as before)
         3. *DO NOT* reset the timer (unless it was a timeout event)!
         4. *DO* record this state transition. (already happened above..) */

      /* Ok, on timeout event reset the timer anyway.. */
      if (event_id < 0)  RESET_TIMER(f); 

          
      return 0; /* No, was not a new state.. */

  } 
  else /* else, a new state .. */
  {    

      /* Ok, the old state != the new state, that means we:

         1. *DO* any triggers
         2. *DO* new continuous lines
         3. *DO* reset the timer!
         4. *DO* record this state transition. (already happened above..) */

      /* Reset the timer.. */
      RESET_TIMER(f);
      
      /* In new state, do output(s) (trig and cont).. */
      doOutput(f); 
    
      return 1; /* Yes, was a new state. */
  }

  return 0; /* Not reached.. */
}

static void doOutput(FSMID_t f)
{
  static struct NRTOutput nrt_out;

  unsigned i, ip_out_col = 0;
  DECLARE_STATE_PTR(state);
  unsigned trigs = 0, conts = 0, contmask = rs[f].do_chans_cont_mask; 
  
  GET_STATE(rs[f].states, state, rs[f].current_state);
  for (i = 0; i < state->n_outputs; ++i) {
    struct OutputSpec *spec = OUTPUT_ROUTING(f,i);
    switch (spec->type) {
    case OSPEC_DOUT:
      conts |= state->output[i] << spec->from;
      break;
    case OSPEC_TRIG:
      trigs |= state->output[i] << spec->from;
      break;
    case OSPEC_SOUND:
      /* Do Lynx 'virtual' triggers... */
      CHK_AND_DO_LYNX_TRIG(f, spec->sound_card, state->output[i]);      
      break;
    case OSPEC_SCHED_WAVE: 
      {
        /* HACK!! Untriggering is funny since you need to do:
           -(2^wave1_id+2^wave2_id) in your FSM to untrigger! */
        int swBits = state->output[i], op = 1;
        /* if it's negative, invert the bitpattern so we can identify
           the wave id in question, then use 'op' to supply a negative waveid to
           scheduleWave() */
        if (swBits < 0)  { op = -1; swBits = -swBits; }
        /* Do scheduled wave outputs, if any */
        while (swBits) {
          int wave = __ffs(swBits);
          swBits &= ~(0x1<<wave);
          scheduleWave(f, wave, op);
        }
      }
      break;
    case OSPEC_TCP:
    case OSPEC_UDP:  /* write non-realtime TCP/UDP packet to fifo */
      /* suppress output of a dupe trigger -- IP packet triggers only get
         sent when state machine column has changed since the last time
         a packet was sent.  These two arrays get cleared on a new
         state matrix though (in reconfigureIO) */
      if (!rs[f].last_ip_outs_is_valid[ip_out_col] 
          || rs[f].last_ip_outs[ip_out_col] != state->output[i]) {
        rs[f].last_ip_outs[ip_out_col] = state->output[i];
        rs[f].last_ip_outs_is_valid[ip_out_col] = 1;
        nrt_out.magic = NRTOUTPUT_MAGIC;
        nrt_out.state = rs[f].current_state;
        nrt_out.trig = state->output[i];
        nrt_out.ts_nanos = rs[f].current_ts;
        nrt_out.type = spec->type == OSPEC_TCP ? NRT_TCP : NRT_UDP;
        nrt_out.col = &state->output[i] - state->column;
        snprintf(nrt_out.ip_host, IP_HOST_LEN, "%s", spec->host);
        nrt_out.ip_port = spec->port;
        snprintf(nrt_out.ip_packet_fmt, FMT_TEXT_LEN, "%s", spec->fmt_text);
        rtf_put(shm->fifo_nrt_output[f], &nrt_out, sizeof(nrt_out));
      }
      ip_out_col++;
      break;
    }
  }

  /* Do trigger outputs */
  if ( trigs ) {
    /* is calling clearTriggerLines here really necessary?? It can interfere
       with really fast state transitioning but 'oh well'.. */
    clearTriggerLines(f); /* FIXME See what happens if you get two rapid triggers. */
    while (trigs) {
      i = __ffs(trigs);
      trigs &= ~(0x1<<i);
      dataWrite(i, 1);  
      lastTriggers |= 0x1<<i; 
    }
    resetTriggerTimer(f);
  }

  /* Do continuous outputs */
  while ( contmask ) {
    i = __ffs(contmask);
    contmask &= ~(0x1<<i);
    if ( (0x1<<i) & conts )  dataWrite(i, 1);
    else                     dataWrite(i, 0);
  }

}

static inline void clearTriggerLines(FSMID_t f)
{
  unsigned i;
  unsigned mask = rs[f].do_chans_trig_mask;
  while (mask) {
    i = __ffs(mask);
    mask &= ~(0x1<<i);
    if ( (0x1 << i) & lastTriggers ) {
      dataWrite(i, 0);
      lastTriggers &= ~(0x1<<i);
    }
  }
}

static unsigned long detectInputEvents(FSMID_t f)
{
  unsigned i, bits, bits_prev;
  unsigned long events = 0;
  
  switch(IN_CHAN_TYPE(f)) { 
  case DIO_TYPE: /* DIO input */
    bits = dio_bits;
    bits_prev = dio_bits_prev;
    break;
  case AI_TYPE: /* AI input */
    bits = ai_bits;
    bits_prev = ai_bits_prev;
    break;
  default:  
    /* Should not be reached, here to suppress warnings. */
    bits = bits_prev = 0; 
    break;
  }
  
  /* Loop through all our event channel id's comparing them to our DIO bits */
  for (i = FIRST_IN_CHAN(f); i < AFTER_LAST_IN_CHAN(f); ++i) {
    int bit = ((0x1 << i) & bits) != 0, 
        last_bit = ((0x1 << i) & bits_prev) != 0,
        event_id_edge_up = INPUT_ROUTING(f, i*2), /* Even numbered input event 
                                                  id's are edge-up events.. */
        event_id_edge_down = INPUT_ROUTING(f, i*2+1); /* Odd numbered ones are 
                                                      edge-down */

    /* Edge-up transitions */ 
    if (event_id_edge_up > -1 && bit && !last_bit) /* before we were below, now we are above,  therefore yes, it is an blah-IN */
      events |= 0x1 << event_id_edge_up; 
    
    /* Edge-down transitions */ 
    if (event_id_edge_down > -1 /* input event is actually routed somewhere */
        && last_bit /* Last time we were above */
        && !bit ) /* Now we are below, therefore yes, it is event*/
      events |= 0x1 << event_id_edge_down; /* Return the event id */		   
  }
  return events; 
}


static void dispatchEvent(FSMID_t f, unsigned event_id)
{
  unsigned next_state = 0;
  DECLARE_STATE_PTR(state);
  GET_STATE(rs[f].states, state, rs[f].current_state);
  if (event_id > NUM_INPUT_EVENTS(f)) {
    ERROR_INT("FSM %u event id %d is > NUM_INPUT_EVENTS %d!\n", f, (int)event_id, (int)NUM_INPUT_EVENTS(f));
    return;
  }
  next_state = (event_id == NUM_INPUT_EVENTS(f)) ? state->timeout_state : state->input[event_id]; 
  gotoState(f, next_state, event_id);
}

/* Set everything to zero to start fresh */
static void clearAllOutputLines(FSMID_t f)
{
  uint i, mask;
  mask = rs[f].do_chans_trig_mask|rs[f].do_chans_cont_mask;
  while (mask) {
    i = __ffs(mask);
    mask &= ~(0x1<<i);
    dataWrite(i, 0);
  }
}

static int buddyTaskCmds[NUM_STATE_MACHINES] = {0};

static void handleFifos(FSMID_t f)
{
# define buddyTaskCmd (buddyTaskCmds[f])  
# define BUDDY_TASK_BUSY (buddyTaskCmd > 0 ? buddyTaskCmd : 0)
# define BUDDY_TASK_DONE (buddyTaskCmd < 0 ? -buddyTaskCmd : 0)
# define BUDDY_TASK_CLEAR (buddyTaskCmd = 0)
# define BUDDY_TASK_PEND(arg) \
  do { \
    buddyTaskCmd = arg; \
    softTaskPend(buddyTask[f], (void *)f); \
  } while(0)

  FifoNotify_t dummy = 1;
  int errcode;
  int do_reply = 0;

  if (BUDDY_TASK_BUSY) {

    /* while our buddy task is processing,  do *NOT* handle any fifos! */
    return; 

  } else if (BUDDY_TASK_DONE) {
    /* our buddy task just finished its processing, now do:
       1. Any RT processing that needs to be done
       2. Indicate we should reply to user fifo by setting do_reply */

    switch(BUDDY_TASK_DONE) {
    case FSM: {
      int was_sane = 0;
      rs[f].states = OTHER_FSM_PTR(f); /* temporarily swap FSMs so
                                          than the sanity checks see the 
                                          new FSM.  The new FSM was in fact
                                          written-to by the buddy task.  */
      was_sane = !doSanityChecksRuntime(f);
      rs[f].states = OTHER_FSM_PTR(f);

      if (!was_sane) {
        
          /* uh-oh.. it's a bad FSM?  Reject it.. */
          initRunState(f);
          reconfigureIO();

      } else { 
          /* FSM good.. */   
        
          /* Swap FSM pointers immediately only if:
               1. the FSM specification wants to not use the 
                  "wait for jump to state 0 to swap FSM" feature.
              *or* 
               2. we are not using the inter-trial interval ready for trial 
                  flag stuff (no trial structure) */
          if(!OTHER_FSM_PTR(f)->wait_for_jump_to_state_0_to_swap_fsm || !rs[f].valid) {
            swapFSMs(f);
          } else {
            rs[f].pending_fsm_swap = 1;
          }
      }
      do_reply = 1;
      break;
    }
    case GETFSM:
      do_reply = 1;
      break;

    case RESET:
      /* these may have had race conditions with non-rt, so set them again.. */
      rs[f].current_ts = 0;
      RESET_TIMER(f);
      reconfigureIO(); /* to reset DIO config since our routing spec 
                           changed */
      do_reply = 1;
      break;

    case AOWAVE:
      /* need up upadte rs.states->has_sched_waves flag as that affects 
       * whether we check the last column of the FSM for sched wave triggers. */
      updateHasSchedWaves(f);
      /* we just finished processing/allocating an AO wave, reply to 
         userspace now */
      do_reply = 1;
      break;

    default:
      ERROR_INT(" Got bogus reply %d from non-RT buddy task!\n", BUDDY_TASK_DONE);
      break;
    }

    BUDDY_TASK_CLEAR; /* clear pending result */

  } else {     /* !BUDDY_TASK_BUSY */

    /* See if a message is ready, and if so, take it from the SHM */
    struct ShmMsg *msg = (struct ShmMsg *)&shm->msg[f];

    errcode = rtf_get(shm->fifo_in[f], &dummy, sizeof(dummy));

    /* errcode == 0 on no data available, that's ok */
    if (!errcode) return; 

    if (errcode != sizeof(dummy)) {
      static int once_only = 0;
      if (!once_only)
        ERROR_INT("(FSM No %u) got return value of (%d) when reading from fifo_in %d\n", f, errcode, shm->fifo_in[f]), once_only++;
      return;
    }
      
    switch (msg->id) {
        
    case RESET:
      /* Just to make sure we start off fresh ... */
      clearAllOutputLines(f);
      stopActiveWaves(f);
      rs[f].valid = 0; /* lock fsm so buddy task can safely manipulate it */
      
      BUDDY_TASK_PEND(RESET); /* slow operation because it clears FSM blob,
                                 pend it to non-RT buddy task. */
      reconfigureIO(); /* to reset DIO config since our routing spec 
                           changed */
      break;
        
    case TRANSITIONCOUNT:
      msg->u.transition_count = NUM_TRANSITIONS(f);
      do_reply = 1;
      break;
      
    case TRANSITIONS:
      {
        unsigned *from = &msg->u.transitions.from; /* Shorthand alias.. */
        unsigned *num = &msg->u.transitions.num; /* alias.. */
        unsigned i;

        if ( *from >= rs[f].history.num_transitions) 
          *from = NUM_TRANSITIONS(f) ? NUM_TRANSITIONS(f)-1 : 0;
        if (*num + *from > rs[f].history.num_transitions)
          *num = NUM_TRANSITIONS(f) - *from + 1;
        
        if (*num > MSG_MAX_TRANSITIONS)
          *num = MSG_MAX_TRANSITIONS;

        for (i = 0; i < *num; ++i)
          memcpy((void *)&msg->u.transitions.transitions[i],
                 (const void *)historyAt(f, *from + i),
                 sizeof(struct StateTransition));
        do_reply = 1;
      }
      break;
      
      
    case PAUSEUNPAUSE:
      rs[f].paused = !rs[f].paused;
      /* We reset the timer, just in case the new FSM's rs.current_state 
         had a timeout defined. */
      RESET_TIMER(f);
      /* Notice fall through to next case.. */
    case GETPAUSE:
      msg->u.is_paused = rs[f].paused;
      do_reply = 1;
      break;
      
    case INVALIDATE:
      rs[f].valid = 0;
      /* Notice fall through.. */
    case GETVALID:
      msg->u.is_valid = rs[f].valid;
      do_reply = 1;
      break;
      
    case FSM:
      /* rs.valid = 0; / * don't lock fsm since it will cause dropped input/output events! instead we have the buddy task write to the alternate fsm which we swap in as current when the buddy task completes (see beginning of this function) */
      
      DEBUG("handleFifos(%u) new FSM at cycle %s currentstate: %u\n", f,
            uint64_to_cstr(cycle), 
            rs[f].current_state);

      /*  NB: don't do this because ITI states might need these! */
      /*clearAllOutputLines();
        stopActiveWaves(); */
      
      BUDDY_TASK_PEND(FSM);      /* Since this is a *slow* operation,
                                    let's defer processing to non-RT
                                    buddy task. */
      break;
      
    case GETFSM:

      BUDDY_TASK_PEND(GETFSM); /* Another slow operation.. */

      break;
      
    case GETFSMSIZE:
      if (rs[f].valid) {
        
        rs[f].valid = 0; /* lock fsm? */       
        
        msg->u.fsm_size[0] = rs[f].states->n_rows;
        msg->u.fsm_size[1] = rs[f].states->n_cols;
        
        rs[f].valid = 1; /* Unlock FSM.. */
        
      } else {
        
        memset((void *)msg->u.fsm_size, 0, sizeof(msg->u.fsm_size));
        
      }
      
      do_reply = 1;
      
      break;        
    case GETNUMINPUTEVENTS:
      if (rs[f].valid) {
        rs[f].valid = 0; /* lock fsm? */
        msg->u.num_input_events = NUM_INPUT_EVENTS(f);
        rs[f].valid = 1; /* unlock fsm */
      } else {
        msg->u.num_input_events = 0;        
      }
      do_reply = 1;
      break;
    case FORCEEVENT:
        if (msg->u.forced_event < NUM_INPUT_EVENTS(f))
          rs[f].forced_event = msg->u.forced_event;
        do_reply = 1;
        break;
        
    case FORCETIMESUP:
        rs[f].forced_times_up = 1;
        do_reply = 1;
        break;

    case FORCESOUND:
      { /* umm.. have to figure out which soundcard they want from output 
           spec */
        unsigned whichCard = f, i;
        for (i = 0; i < NUM_OUT_COLS(f); ++i)
          if (OUTPUT_ROUTING(f, i)->type == OSPEC_SOUND) {
            whichCard = OUTPUT_ROUTING(f, i)->sound_card;
            break;
          }
        CHK_AND_DO_LYNX_TRIG(f, whichCard, msg->u.forced_triggers);
        do_reply = 1;
      }
      break;
        
    case FORCEOUTPUT:
      if (rs[f].do_chans_cont_mask) {
            unsigned forced_mask = rs[f].forced_outputs_mask;
            /* Clear previous forced outputs  */
            while (forced_mask) {
              unsigned chan = __ffs(forced_mask);
              forced_mask &= ~(0x1<<chan);
              dataWrite(chan, 0);
            }
            rs[f].forced_outputs_mask = (msg->u.forced_outputs << __ffs(rs[f].do_chans_cont_mask)) & rs[f].do_chans_cont_mask;
      }
      do_reply = 1;
      break;

      case GETRUNTIME:
        msg->u.runtime_us = Nano2USec(rs[f].current_ts);
        do_reply = 1;
        break;

      case READYFORTRIAL:
        if (rs[f].current_state == READY_FOR_TRIAL_JUMPSTATE(f)) {
          rs[f].ready_for_trial_flg = 0;
          gotoState(f, 0, -1);
        } else
          rs[f].ready_for_trial_flg = 1;
        do_reply = 1;
        break;

      case GETCURRENTSTATE:
        msg->u.current_state = rs[f].current_state;
        do_reply = 1;
        break;

      case FORCESTATE:
        if ( gotoState(f, msg->u.forced_state, -1) < 0 )
          msg->u.forced_state = -1; /* Indicate error.. */
        do_reply = 1;
        break;
	
      case STARTDAQ:
        msg->u.start_daq.range_min = ai_krange.min;        
        msg->u.start_daq.range_max = ai_krange.min;
        msg->u.start_daq.maxdata = maxdata_ai;
        {
          unsigned ch;
          rs[f].daq_ai_chanmask = 0;
          rs[f].daq_ai_nchans = 0;
          for (ch = 0; ch < NUM_AI_CHANS; ++ch)
            if (msg->u.start_daq.chan_mask & (0x1<<ch)) {
              rs[f].daq_ai_chanmask |= 0x1<<ch;
              ++rs[f].daq_ai_nchans;
            }
        }
        msg->u.start_daq.started_ok = rs[f].daq_ai_chanmask;
        msg->u.start_daq.chan_mask = rs[f].daq_ai_chanmask;
        do_reply = 1;
        break;

      case STOPDAQ:
        rs[f].daq_ai_nchans = rs[f].daq_ai_chanmask = 0;
        do_reply = 1;
        break;
        
      case GETAOMAXDATA:
        msg->u.ao_maxdata = maxdata_ao;
        do_reply = 1;
        break;

    case AOWAVE:
        
        BUDDY_TASK_PEND(AOWAVE); /* a slow operation -- it has to allocate
                                    memory, etc, so pend to a linux process
                                    context buddy task 
                                    (see buddyTaskHandler()) */

        break;

      default:
        rtl_printf(MODULE_NAME": Got unknown msg id '%d' in handleFifos(%u)!\n", 
                   msg->id, f);
        do_reply = 0;
        break;
    }
  }

  if (do_reply) {
    errcode = rtf_put(shm->fifo_out[f], &dummy, sizeof(dummy));
    if (errcode != sizeof(dummy)) {
      static int once_only = 0;
      if (!once_only) 
        ERROR_INT("rtos_fifo_put to fifo_out %d returned %d!\n", 
                  shm->fifo_out[f], errcode), once_only++;
      return;
    }
  }

# undef buddyTaskCmd
# undef BUDDY_TASK_BUSY
# undef BUDDY_TASK_DONE
# undef BUDDY_TASK_CLEAR
# undef BUDDY_TASK_PEND

}

static unsigned pending_output_bits = 0, pending_output_mask = 0;

static inline void dataWrite(unsigned chan, unsigned bit)
{
  unsigned bitpos = 0x1 << chan;
  if (!(bitpos & do_chans_in_use_mask)) {
    ERROR_INT("Got write request for a channel (%u) that is not in the do_chans_in_use_mask (%x)!  FIXME!\n", chan, do_chans_in_use_mask);
    return;
  }
  pending_output_mask |= bitpos;
  if (bit) /* set bit.. */
    pending_output_bits |= bitpos;
  else /* clear bit.. */
    pending_output_bits &= ~bitpos;
}

static void commitDataWrites(void)
{
  hrtime_t dio_ts = 0, dio_te = 0;
  FSMID_t f;
  
  for (f = 0; f < NUM_STATE_MACHINES; ++f) {
    /* Override with the 'forced' bits. */
    pending_output_mask |= rs[f].forced_outputs_mask;
    pending_output_bits |= rs[f].forced_outputs_mask;
  }

  if ( avoid_redundant_writes && (pending_output_bits & pending_output_mask) == (dio_bits & pending_output_mask) )
    /* Optimization, only do the writes if the bits we last saw disagree
       with the bits as we would like them */
    return;
 
  if (debug > 2)  dio_ts = gethrtime();
  comedi_dio_bitfield(dev, subdev, pending_output_mask, &pending_output_bits);
  if (debug > 2)  dio_te = gethrtime();
  
  if(debug > 2)
    DEBUG("WRITES: dio_out mask: %x bits: %x for cycle %s took %u ns\n", pending_output_mask, pending_output_bits, uint64_to_cstr(cycle), (unsigned)(dio_te - dio_ts));

  pending_output_bits = 0;
  pending_output_mask = 0;
}

static void grabAllDIO(void)
{
  /* Remember previous bits */
  dio_bits_prev = dio_bits;
  /* Grab all the input channels at once */
  comedi_dio_bitfield(dev, subdev, 0, (unsigned int *)&dio_bits);

  /* Debugging comedi reads.. */
  if (dio_bits && ullmod(cycle, sampling_rate) == 0 && debug > 1)
    DEBUG("READS 0x%x\n", dio_bits);
}

static void grabAI(void)
{
  int i;
  unsigned mask = ai_chans_in_use_mask;

  /* Remember previous bits */
  ai_bits_prev = ai_bits;

  /* Grab all the AI input channels that are masked as 'in-use' by an FSM */
  while (mask) {
    lsampl_t sample;

    i = __ffs(mask);    
    mask &= ~(0x1<<i);
    
    if (AI_MODE == SYNCH_MODE) {
      /* Synchronous AI, so do the slow comedi_data_read() */
      int err = comedi_data_read(dev_ai, subdev_ai, i, ai_range, AREF_GROUND, &sample);
      if (err != 1) {
        WARNING("comedi_data_read returned %d on AI chan %d!\n", err, i);
        return;
      }
      ai_samples[i] = sample; /* save the sample for doDAQ() function.. */
      
      if (i == 0 && debug) putDebugFifo(sample); /* write AI 0 to debug fifo*/
      
    } else { /* AI_MODE == ASYNCH_MODE */
      /* Asynch IO, read samples from our ai_aynch_samples which was populated
         by our comediCallback() function. */
      sample = ai_samples[i];
    }

    /* At this point, we don't care anymore about synch/asynch.. we just
       have a sample. 

       Next, we translate the sample into either a digital 1 or a digital 0.

       To do this, we have two threshold values, ai_thesh_hi and ai_thesh_low.

       The rule is: If we are above ai_thresh_hi, we are considered to have a 
                    digital '1', and if we are below ai_thresh_low, we consider
                    it a digital '0'.  Otherwise, we take the digital value of 
                    what we had the last scan.

       This avoids jittery 1/0/1/0 transitions.  Your thermostat works
       on the same principle!  :)
    */
    
    if (sample >= ai_thresh_hi) {
      /* It's above the ai_thresh_hi value, we think of it as a digital 1. */ 
      ai_bits |= 0x1<<i; /* set the bit, it's above our arbitrary thresh. */
    } else if (sample <= ai_thresh_low) {
      /* We just dropped below ai_thesh_low, so definitely clear the bit. */
      ai_bits &= ~(0x1<<i); /* clear the bit, it's below ai_thesh_low */
    } else {
      /* No change from last scan.
         This happens sometimes when we are between ai_thesh_low 
         and ai_thresh_high. */
    }
  } /* end while loop */
}

static void doDAQ(void)
{
  FSMID_t f;
  unsigned seen_chans = ai_chans_in_use_mask;

  for (f = 0; f < NUM_STATE_MACHINES; ++f) {
    static unsigned short samps[MAX_AI_CHANS];
    unsigned mask = rs[f].daq_ai_chanmask;
    unsigned ct = 0;
    while (mask) {
      unsigned ch = __ffs(mask);
      /* determine if this chan was already read by grabAI or by asynch task */
      int have_chan = ((0x1<<ch) & seen_chans) || (AI_MODE == ASYNCH_MODE && IN_CHAN_TYPE(f) == AI_TYPE);
      mask &= ~(0x1<<ch); /* clear bit */
      if (have_chan) {
        /* we already have this channel's  sample from the grabAI() function or from asynch daq */
        samps[ct] = ai_samples[ch];
      } else {
        /* we don't have this sample yet, so read it */
        lsampl_t samp;
        comedi_data_read(dev_ai, subdev_ai, ch, ai_range, AREF_GROUND, &samp);
        samps[ct] = samp;

        /* cache the sample so that if other FSMs need it they can read it from ai_samples[] array.. */
        ai_samples[ch] = samp; 
        seen_chans |= 0x1<<ch;
      }
      ++ct;
    }
    if (ct) {
      struct DAQScan scan;
      scan.magic = DAQSCAN_MAGIC;
      scan.ts_nanos = rs[f].current_ts;
      scan.nsamps = ct;
      rtf_put(shm->fifo_daq[f], &scan, sizeof(scan));
      rtf_put(shm->fifo_daq[f], samps, sizeof(samps[0])*ct);
    }
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
        *r = do_div(ull, uld);
        return ull;
}
static inline unsigned long ullmod(unsigned long long ull, unsigned long uld)
{         
        unsigned long ret;
        ulldiv(ull, uld, &ret);
        return ret;
}
static inline long long lldiv(long long ll, long ld, long *r)
{
  int neg1 = 0, neg2 = 0;
  
  if (ll < 0) (ll = -ll), neg1=1;
  if (ld < 0) (ld = -ld), neg2=1;
  *r = do_div(ll, ld);
  if ( (neg1 || neg2) && !(neg1&&neg2) ) ll = -ll;
  return ll;
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

static int uint64_to_cstr_r(char *buf, unsigned bufsz, uint64 num)
{
  static const uint64 ZEROULL = 0ULL;
  static const uint32 dividend = 10;
  int ct = 0, i;
  uint64 quotient = num;
  unsigned long remainder;
  char reversebuf[21];
  unsigned sz = 21;

  if (bufsz < sz) sz = bufsz;
  if (sz) buf[0] = 0;
  if (sz <= 1) return 0;

  /* convert to base 10... results will be reversed */
  do {
    remainder = do_div(quotient, dividend);
    reversebuf[ct++] = remainder + '0';
  } while (quotient != ZEROULL && ct < sz-1);

  /* now reverse the reversed string... */
  for (i = 0; i < ct && i < sz-1; i++) 
    buf[i] = reversebuf[(ct-i)-1];
  
  /* add nul... */
  buf[ct] = 0;
  
  return ct;
}

static const char *uint64_to_cstr(uint64 num)
{
  static char buf[21];
  uint64_to_cstr_r(buf, sizeof(buf), num);
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

static inline void UNSET_LYNX_TRIG(unsigned card, unsigned trig)
{
  if (debug > 1) DEBUG("Virtual Trigger %d unset for card %u\n", trig, card); 
  LYNX_UNTRIG(lynxTrigShm, card, trig); 
}

static inline void SET_LYNX_TRIG(unsigned card, unsigned trig)
{
  if (debug > 1) DEBUG("Virtual Trigger %d set for card %u\n", trig, card); 
  LYNX_TRIG(lynxTrigShm, card, trig); 
}

static inline void CHK_AND_DO_LYNX_TRIG(FSMID_t f, unsigned which_card, unsigned t) 
{
  int trig = *(int *)&t;
  if (!trig) return;
  if (trig < 0) /* Is 'last' bit set? */ 
      UNSET_LYNX_TRIG( which_card, -trig );
    else 
      SET_LYNX_TRIG( which_card, trig ); 
}

static inline void putDebugFifo(unsigned val)
{
  if (shm->fifo_debug >= 0) {
        /* DEBUGGING AI CHANNEL 0 .. put it to shm->fifo_debug.. */
        char line[64];
        int len;
        snprintf(line, sizeof(line), "%u\n", val);
        line[sizeof(line)-1] = 0;
        len = strlen(line);
        rtf_put(shm->fifo_debug, line, len);
  }
}

static unsigned long processSchedWaves(FSMID_t f)
{  
  unsigned wave_mask = rs[f].active_wave_mask;
  unsigned long wave_events = 0;

  while (wave_mask) {
    unsigned wave = __ffs(wave_mask);
    struct ActiveWave *w = &((struct RunState *)&rs[f])->active_wave[wave];
    wave_mask &= ~(0x1<<wave);

    if (w->edge_up_ts && w->edge_up_ts <= rs[f].current_ts) {
      /* Edge-up timer expired, set the wave high either virtually or
         physically or both. */
          int id = SW_INPUT_ROUTING(f, wave*2);
          if (id > -1 && id <= NUM_IN_EVT_COLS(f)) {
            wave_events |= 0x1 << id; /* mark the event as having occurred
                                         for the in-event of the matrix, if
                                         it's routed as an input event wave
                                         for edge-up transitions. */
          }
          id = SW_OUTPUT_ROUTING(f, wave);

          if ( id > -1 ) 
            dataWrite(id, 1); /* if it's routed to do output, do the output. */

          w->edge_up_ts = 0; /* mark this component done */
    }
    if (w->edge_down_ts && w->edge_down_ts <= rs[f].current_ts) {
      /* Edge-down timer expired, set the wave high either virtually or
         physically or both. */
          int id = SW_INPUT_ROUTING(f, wave*2+1);
          if (id > -1 && id <= NUM_IN_EVT_COLS(f)) {
            wave_events |= 0x1 << id; /* mark the event as having occurred
                                         for the in-event of the matrix, if
                                         it's routed as an input event wave
                                         for edge-up transitions. */
          }
          id = SW_OUTPUT_ROUTING(f, wave);

          if ( id > -1 ) 
            dataWrite(id, 0); /* if it's routed to do output, do the output. */

          w->edge_down_ts = 0; /* mark this wave component done */
    } 
    if (w->end_ts && w->end_ts <= rs[f].current_ts) {
          /* Refractory period ended and/or wave is deactivated */
          rs[f].active_wave_mask &= ~(0x1<<wave); /* deactivate the wave */
          w->end_ts = 0; /* mark this wave component done */
    }
  }
  return wave_events;
}

static unsigned long processSchedWavesAO(FSMID_t f)
{  
  unsigned wave_mask = rs[f].active_ao_wave_mask;
  unsigned long wave_events = 0;

  while (wave_mask) {
    unsigned wave = __ffs(wave_mask);
    volatile struct AOWaveINTERNAL *w = &rs[f].aowaves[wave];
    wave_mask &= ~(0x1<<wave);

    if (w->cur >= w->nsamples && w->loop) w->cur = 0;
    if (w->cur < w->nsamples) {
      int evt_col = w->evt_cols[w->cur];
      if (dev_ao && w->aoline < NUM_AO_CHANS) {
        lsampl_t samp = w->samples[w->cur];
        comedi_data_write(dev_ao, subdev_ao, w->aoline, ao_range, 0, samp);
      }
      if (evt_col > -1 && evt_col <= NUM_IN_EVT_COLS(f))
        wave_events |= 0x1 << evt_col;
      w->cur++;
    } else { /* w->cur >= w->nsamples, so wave ended.. unschedule it. */
      scheduleWaveAO(f, wave, -1);
      rs[f].active_ao_wave_mask &= ~(1<<wave);
    }
  }
  return wave_events;
}

static void scheduleWave(FSMID_t f, unsigned wave_id, int op)
{
  if (wave_id >= FSM_MAX_SCHED_WAVES)
  {
      DEBUG("Got wave request %d for an otherwise invalid scheduled wave %u!\n", op, wave_id);
      return;
  }
  scheduleWaveDIO(f, wave_id, op);
  scheduleWaveAO(f, wave_id, op);
}

static void scheduleWaveDIO(FSMID_t f, unsigned wave_id, int op)
{
  struct ActiveWave *w;
  const struct SchedWave *s;

  if (wave_id >= FSM_MAX_SCHED_WAVES  /* it's an invalid id */
      || !rs[f].states->sched_waves[wave_id].enabled /* wave def is not valid */ )
    return; /* silently ignore invalid wave.. */
  
  if (op > 0) {
    /* start/trigger a scheduled wave */
    
    if ( rs[f].active_wave_mask & 0x1<<wave_id ) /*  wave is already running! */
    {
        DEBUG("FSM %u Got wave start request %u for an already-active scheduled DIO wave!\n", f, wave_id);
        return;  
    }
    /* ugly casts below are to de-volatile-ify */
    w = &((struct RunState *)&rs[f])->active_wave[wave_id];
    s = &((struct RunState *)&rs[f])->states->sched_waves[wave_id];
    
    w->edge_up_ts = rs[f].current_ts + ((int64)s->preamble_us)*1000LL;
    w->edge_down_ts = w->edge_up_ts + ((int64)s->sustain_us)*1000LL;
    w->end_ts = w->edge_down_ts + ((int64)s->refraction_us)*1000LL;  
    rs[f].active_wave_mask |= 0x1<<wave_id; /* set the bit, enable */

  } else {
    /* Prematurely stop/cancel an already-running scheduled wave.. */

    if (!(rs[f].active_wave_mask & 0x1<<wave_id) ) /* wave is not running! */
    {
        DEBUG("Got wave stop request %u for an already-inactive scheduled DIO wave!\n", wave_id);
        return;  
    }
    rs[f].active_wave_mask &= ~(0x1<<wave_id); /* clear the bit, disable */
  }
}

static void scheduleWaveAO(FSMID_t f, unsigned wave_id, int op)
{
  volatile struct AOWaveINTERNAL *w = 0;
  if (wave_id >= FSM_MAX_SCHED_WAVES  /* it's an invalid id */
      || !rs[f].aowaves[wave_id].nsamples /* wave def is not valid */ )
    return; /* silently ignore invalid wave.. */
  w = &rs[f].aowaves[wave_id];
  if (op > 0) {
    /* start/trigger a scheduled AO wave */    
    if ( rs[f].active_ao_wave_mask & 0x1<<wave_id ) /* wave is already running! */
    {
        DEBUG("FSM %u Got wave start request %u for an already-active scheduled AO wave!\n", f, wave_id);
        return;  
    }
    w->cur = 0;
    rs[f].active_ao_wave_mask |= 0x1<<wave_id; /* set the bit, enable */

  } else {
    /* Prematurely stop/cancel an already-running scheduled wave.. */
    if (!(rs[f].active_ao_wave_mask & 0x1<<wave_id) ) /* wave is not running! */
    {
        DEBUG("FSM %u Got wave stop request %u for an already-inactive scheduled AO wave!\n", f, wave_id);
        return;  
    }
    rs[f].active_ao_wave_mask &= ~(0x1<<wave_id); /* clear the bit, disable */
    if (dev_ao && w->nsamples && w->aoline < NUM_AO_CHANS)
      /* write 0 on wave stop */
      comedi_data_write(dev_ao, subdev_ao, w->aoline, ao_range, 0, 0);
    w->cur = 0;
  }
}

static void stopActiveWaves(FSMID_t f) /* called when FSM starts a new trial */
{  
  while (rs[f].active_wave_mask) { 
    unsigned wave = __ffs(rs[f].active_wave_mask);
    struct ActiveWave *w = &((struct RunState *)&rs[f])->active_wave[wave];
    rs[f].active_wave_mask &= ~(1<<wave); /* clear bit */
    if (w->edge_down_ts && w->edge_down_ts <= rs[f].current_ts) {
          /* The wave was in the middle of a high, so set the line back low
             (if there actually is a line). */
          int id = SW_OUTPUT_ROUTING(f, wave);

          if (id > -1) 
            dataWrite(id, 0); /* if it's routed to do output, set it low. */
    }
    memset(w, 0, sizeof(*w));  
  }
  while (rs[f].active_ao_wave_mask) {
    unsigned wave = __ffs(rs[f].active_ao_wave_mask);
    scheduleWaveAO(f, wave, -1); /* should clear bit in rs.active_ao_wave_mask */
    rs[f].active_ao_wave_mask &= ~(0x1<<wave); /* just in case */
  }
}

static void buddyTaskHandler(void *arg)
{
  FSMID_t f = (FSMID_t)arg;
  int *req = &buddyTaskCmds[f];
  struct ShmMsg *msg = 0;

  if (f >= NUM_STATE_MACHINES) {
    ERROR_INT("buddyTask got invalid fsm id handle %u!\n", f);
    return; 
  }
  msg = (struct ShmMsg *)&shm->msg[f];
  switch (*req) {
  case FSM:
    /* use alternate FSM as temporary space during this interruptible copy 
       realtime task will swap the pointers when it realizes the copy
       is done */
    memcpy(OTHER_FSM_PTR(f), (void *)&msg->u.fsm, sizeof(*OTHER_FSM_PTR(f)));  
    /* NB: in the case where we have deferred FSM swapping (the jump
       to state 0 stuff) then this is a BUG!  We really should be cleaning 
       up the AO waves at that point, not now! */
    cleanupAOWaves(f); /* we have to free existing AO waves here because a new
                         FSM might not have a sched_waves column.. */
    break;
  case GETFSM:
    if (!rs[f].valid) {      
      memset((void *)&msg->u.fsm, 0, sizeof(msg->u.fsm));      
    } else {      
      memcpy((void *)&msg->u.fsm, FSM_PTR(f), sizeof(*FSM_PTR(f)));      
    }
    break;
  case RESET:
    cleanupAOWaves(f); /* frees any allocated AO waves.. */
    initRunState(f);
    break;
  case AOWAVE: {
      struct AOWave *w = &msg->u.aowave;
      if (w->id < FSM_MAX_SCHED_WAVES && w->aoline < NUM_AO_CHANS) {
        if (w->nsamples > AOWAVE_MAX_SAMPLES) w->nsamples = AOWAVE_MAX_SAMPLES;
        volatile struct AOWaveINTERNAL *wint = &rs[f].aowaves[w->id];
        cleanupAOWave(wint, f, w->id);
        if (w->nsamples) {
          int ssize = w->nsamples * sizeof(*wint->samples),
              esize = w->nsamples * sizeof(*wint->evt_cols);
          wint->samples = vmalloc(ssize);
          wint->evt_cols = vmalloc(esize);
          if (wint->samples && wint->evt_cols) {
            wint->aoline = w->aoline;
            wint->nsamples = w->nsamples;
            wint->loop = w->loop;
            wint->cur = 0;
            memcpy((void *)(wint->samples), w->samples, ssize);
            memcpy((void *)(wint->evt_cols), w->evt_cols, esize);
            DEBUG("FSM %u AOWave: allocated %d bytes for AOWave %u\n", f, ssize+esize, w->id);
          } else {
            ERROR("FSM %u In AOWAVE Buddy Task Handler: failed to allocate memory for an AO wave! Argh!!\n", f);
            cleanupAOWave(wint, f, w->id);
          }
        }
      }
    }
    break;
  }

  /* indicate to RT task that request is done.. */
  *req = -*req;
}

static void buddyTaskComediHandler(void *arg)
{
  int err;
  (void)arg;

  err = setupComediCmd();    
  if (err)
    ERROR("comediCallback: failed to restart acquisition after COMEDI_CB_OVERFLOW %d: error: %d!\n", ai_n_overflows, err);
  else
    LOG_MSG("comediCallback: restarted acquisition after %d overflows.\n", ai_n_overflows);
}

static inline long long timespec_to_nano(const struct timespec *ts)
{
  return ((long long)ts->tv_sec) * 1000000000LL + (long long)ts->tv_nsec;
}

static void cleanupAOWaves(FSMID_t f)
{
  unsigned i;
  for (i = 0; i < FSM_MAX_SCHED_WAVES; ++i) 
    cleanupAOWave(&rs[f].aowaves[i], f, i);
}

static void cleanupAOWave(volatile struct AOWaveINTERNAL *wint, FSMID_t f, int bufnum)
{
  int freed = 0, nsamps = 0;
  if (!wint) return;
  nsamps = wint->nsamples;
  wint->loop = wint->cur = wint->nsamples = 0; /* make fsm not use this? */
  mb();
  if (wint->samples) vfree(wint->samples), wint->samples = 0, freed += nsamps*sizeof(*wint->samples);
  if (wint->evt_cols) vfree(wint->evt_cols), wint->evt_cols = 0, freed += nsamps*sizeof(*wint->evt_cols);
  if (freed) 
    DEBUG("AOWave: freed %d bytes for AOWave wave buffer %u:%d\n", freed, f, bufnum);
}

static void updateHasSchedWaves(FSMID_t f)
{
	unsigned i;
	int yesno = 0;
	for (i = 0; i < NUM_OUT_COLS(f); ++i)
      yesno = yesno || (OUTPUT_ROUTING(f,i)->type == OSPEC_SCHED_WAVE);  	
	rs[f].states->has_sched_waves = yesno;
}

static void swapFSMs(FSMID_t f)
{
  /*LOG_MSG("Cycle: %lu  Swapping-in new FSM\n", (unsigned long)cycle);*/
  rs[f].states = OTHER_FSM_PTR(f);
  updateHasSchedWaves(f); /* just updates rs.states->has_sched_waves flag*/
  reconfigureIO(); /* to have new routing take effect.. */
  rs[f].valid = 1; /* Unlock FSM.. */
  rs[f].pending_fsm_swap = 0;
}

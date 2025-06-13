#ifndef LYNX_TRIG_H
#  define LYNX_TRIG_H

#ifdef __cplusplus
extern "C" {
#endif

  typedef int int32;
  typedef unsigned uint32;
  typedef long long int64;
  typedef unsigned long long uint64;

#define MSG_SND_SZ (1024*1024) /* 1MB per chunk of sound transferred to kernel.. */
#define MAX_SND_ID 0x80

#define MAX_CARDS 6 /* Keep this the same as L22_MAX_DEVS in LynxTWO-RT.h! */

enum FifoMsgID {
    GETPAUSE,  /* Query to find out if it is paused. */
    PAUSEUNPAUSE, /* Halt the trigger detect (temporarily).  No variables
                     are cleared but events cannot generate new snd play. */
    RESET, /* Reset/Initialize. */
    GETVALID,  /* Query to find out if it has any valid sound.*/
    INVALIDATE, /* Invalidate (clear) the state machine specification, 
                   but preserve other system variables. */
    SOUND, /* Load a sound. */    
    /*    GETSOUND, */
    FORCEEVENT, /* Force a particular event to have occurred. */
    GETLASTEVENT, /* Query the event we are playing/last played, if any.. */
    GETRUNTIME, /* The time we have been running.. */
    USER_LYNXTRIG_MSG_ID
};

struct FifoMsg {
    int id; /* One of FifoMsgID above.. */
    
    /* Which element of union is used depends on id above. */
    union {

      /* For id == SOUND */
      struct {
        /* Sound Specification */   
        unsigned char snd[MSG_SND_SZ];
        unsigned bits_per_sample; /* 8, 16, 24, or 32 are allowed */
        unsigned chans; /* 1 or 2 */
        unsigned rate; /* 8kHz - 200 kHz */
        unsigned id; /* The trigger id.  This corresponds to the digital lines 
                        used to trigger the sound.. */
        unsigned size;
        unsigned stop_ramp_tau_ms; /* The number of ms to do the cosine-squared
                                      amplitude ramp-down when stopping a sound
                                      prematurely. 0 to disable this. */
        unsigned long total_size; /* For multiple transfers, the final size..*/
        int is_looped; /* if true, this sound should play in a loop whenever
                          it is triggered.  Otherwise the sound will stop
                          normally after 1 playing. */
        int append; /* If true, append this sound buffer
                       to the previous one of the same id..
                       If false, no append, just overwrite and be done with it.
                       Note to overwite the current sound:
                       1. write a soundfile with no append.
                       2. Then keep writing the soundfile with append=1 until 
                          done.*/
        int transfer_ok; /* True is written by kernel to indicate transter was 
                            ok, otherwise writes 0 to indicate error..  */
      } sound;

      /* For id == GETPAUSE */
      unsigned is_paused; 

      /* For id == GETVALID */
      unsigned is_valid;

      /* For id == FORCEEVENT */
      int forced_event;

      /* For id == GETRUNTIME */ 
      long long runtime_us; /* Time since last reset, in seconds */

      /* For id == GETLASTEVENT */ 
      int last_event; /* The current/last event, or 0 if none */

    } u;
  };


  /** 
      The shared memory -- not every plugin needs shared memory but 
      it's a convenient way for userspace UI to communicate with your
      control (real-time kernel) plugin
  */
  struct Shm 
  { 
    int    magic;               /*< Should always equal SHM_MAGIC            */
    int fifo_out[MAX_CARDS]; /* The kernel-to-user FIFO */
    int fifo_in[MAX_CARDS];  /* The user-to-kernel FIFO */
    
    struct FifoMsg msg[MAX_CARDS]; /* When fifo_in gets an int, this value is read
                           by kernel-process.  (The alternative would have been
                           to write this msg to a FIFO but that's a lot of
                           wasteful double-copying.  It's faster to use
                           the shm directly, and only use the FIFO for 
                           synchronization and notification.                 */
    const unsigned num_cards;
  };


  typedef int FifoNotify_t;  /* Write one of these to the fifo to notify
                                that a new msg is available in the SHM       */
#define FIFO_SZ (sizeof(FifoNotify_t))

#ifndef __cplusplus
  typedef struct Shm Shm;
#endif

#define SHM_NAME "LynxTrigSHM"
#define SHM_MAGIC ((int)(0xf00d0607)) /*< Magic no. for shm... 'food0607'  */
#define SHM_SIZE (sizeof(struct Shm))
#ifdef __cplusplus
}
#endif

#endif

#ifndef LYNX_TRIG_VIRT_H
#define LYNX_TRIG_VIRT_H

#ifndef __KERNEL__
#   error This is a kernel header, and is not really compatible or intended to be used by userspace programs!
#endif

#include <linux/module.h>
#include <asm/atomic.h>

typedef int (* LynxTrigVirtFn_t)(unsigned, int); 
struct LynxTrigVirtShm
{
  int magic;
  atomic_t valid;
  LynxTrigVirtFn_t function;
};

/** The shm will contain a function pointer that should be
    called in RT context to do triggers! */
#define LYNX_TRIG_VIRT_SHM_NAME "LVirtShm"
#define LYNX_TRIG_VIRT_SHM_SIZE sizeof(struct LynxTrigVirtShm)
#define LYNX_TRIG_VIRT_SHM_MAGIC 0x220bce02


static inline int LYNX_TRIG_VIRT_SHM_IS_VALID(volatile struct LynxTrigVirtShm *shm)
{
  return  shm && shm->magic == LYNX_TRIG_VIRT_SHM_MAGIC
          && atomic_read(&shm->valid) && shm->function;
}

#if defined(MOD_INC_USE_COUNT) && defined(MOD_DEC_USE_COUNT)
#  define MINC MOD_INC_USE_COUNT
#  define MDEC MOD_DEC_USE_COUNT
#else 
/* Kernel 2.4 mechanism allowed for simple atomic increase of module use count
   to avoid race conditions.  2.6 uses a different mechanism that I am not
   sure is callable from RT-context.. 
   So we won't do any use count stuff in 2.6 :(  */
#  define MINC ((void)0)
#  define MDEC ((void)0)
#endif

static inline void LYNX_TRIG(volatile struct LynxTrigVirtShm *shm, unsigned card, int trig)
{
  if (LYNX_TRIG_VIRT_SHM_IS_VALID(shm)) 
  {
      MINC;
      shm->function(card, trig); 
      MDEC;
  }
  return;
}

static inline void LYNX_UNTRIG(volatile struct LynxTrigVirtShm *shm, unsigned card, int trig) 
{
  /* Make sure trig is negative.. */
  LYNX_TRIG(shm, card, trig < 0 ? trig : -trig);
  return;
  LYNX_UNTRIG(0, card, 0); /* Avoid compiler warnings for unused.. */
}

#endif

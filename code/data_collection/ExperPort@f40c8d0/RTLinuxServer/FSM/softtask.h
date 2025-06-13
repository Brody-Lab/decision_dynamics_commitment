#ifndef softtask_h
#define softtask_h
/**
   Soft tasks, by Calin A. Culianu <calin@ajvar.org>
   License: GPL.

   Soft tasks are pendable from RT and they run in linux process
   context (using the linux internal scheduler task queue).

   They are useful to defer costly work to non-realtime, within the kernel.
   
   This beats having to write a userspace buddy process which is error-prone
   and doesn't have access to kernel memory structures (sometimes you
   don't want to expose details of your RT task to userspace).

   Usage:  
   1. create your softtask function.
   2. create a softtask using softTaskCreate() in your module init.
   3. pend work to the softtask function using softTaskPend().  
      softTaskPend() is callable from rt!
   4. destroy your softtask function in your module cleanup.  Note this
      destroy function may block if the softtask happened to be running at
      the time.           
*/
struct SoftTask;

typedef void (*SoftTask_Handler)(void *);

/** This creates a soft task.  
    May return null of not enough resources are available to create 
    internal data structures, etc.
    Call this only from linux process context (such as init module).  */
extern struct SoftTask *softTaskCreate(SoftTask_Handler handler_function,
                                       const char *taskName);

/** This destroys a soft task.  May block if the softtask is currently 
    running.

    Call this only from linux process context (such as cleanup module). */
extern void softTaskDestroy(struct SoftTask *);

/** This function is callable from RT, it pends the soft task
    to run in linux process context. Pass your softtask handler an argument 
    if you wish.
    
    Returns 0 on success or errno on error. 
    Errors: EINVAL, EBUSY. */
extern int softTaskPend(struct SoftTask *, void *arg);

#endif

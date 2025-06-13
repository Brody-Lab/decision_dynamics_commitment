#include "softtask.h"
#include <rtl_tqueue.h>
#include <rtl_core.h>
#include <rtl_sync.h>
#include <linux/sched.h>
#include <linux/vmalloc.h>
#include <linux/wait.h>

static void soft_irq_handler(int, void *, struct pt_regs *);
static void task_wrapper(void *);

struct SoftTask
{
  struct list_head list;

  int sirq;
#define MAX_NAME_LEN 64
  char name[MAX_NAME_LEN];

  wait_queue_head_t WaitQ;
  struct tq_struct task;
  volatile int busy;

  SoftTask_Handler Func;
  void *Arg;  
};

typedef struct SoftTask SoftTask;

#define MAX_IRQ 256
static SoftTask *irqTasks[MAX_IRQ]; /* Table mapping irq -> SoftTask * */
static volatile int did_init = 0;

struct SoftTask *softTaskCreate(SoftTask_Handler handler_function,
                                const char *name)
{
  if (!did_init) {
    memset(irqTasks, 0, sizeof(*irqTasks)*MAX_IRQ);
    did_init = 1;
  }

  SoftTask *t = (SoftTask *)vmalloc(sizeof(*t));
  if (!t) return 0;

  memset(t, 0, sizeof(*t));
  init_waitqueue_head(&t->WaitQ);
  t->task.routine = task_wrapper;
  t->task.data = t;

  strncpy(t->name, name, MAX_NAME_LEN);
  t->name[MAX_NAME_LEN-1] = 0;
  t->Func = handler_function;
  
  t->sirq = rtl_get_soft_irq(soft_irq_handler, t->name);

  if (t->sirq < 0) {
    /* Argh, out of resources.. */
    vfree(t);
    return 0;
  }

  irqTasks[t->sirq] = t;

  return t;
}

int softTaskPend(struct SoftTask *task, void *arg)
{
  if (!task || !irqTasks[task->sirq]) return EINVAL;

  task->Arg = arg;
  
 /* pended twice? */
  if (task->busy) return EBUSY;

  task->busy = 1; /* tells destroy func to wait */
  rtl_global_pend_irq(task->sirq);

  return 0;
}

void softTaskDestroy(struct SoftTask *t)
{
  if (!t) return; /* paranoia */

  rtl_free_soft_irq(t->sirq);
  irqTasks[t->sirq] = 0;
  wait_event(t->WaitQ, !t->busy);
  
  vfree(t);
}

static void soft_irq_handler(int irq, void *arg, struct pt_regs *regs)
{
  SoftTask *task = 0;

  (void) arg; (void)regs; /* ignore unused params.. */

  if (irq >= 0 && irq < MAX_IRQ)
    task = irqTasks[irq];

  if (task) 
    schedule_task(&task->task);  
}

static void task_wrapper(void *arg)
{
  SoftTask *task = (void *) arg;  

  task->Func(task->Arg);

  task->busy = 0;  
  
  wake_up(&task->WaitQ);
}


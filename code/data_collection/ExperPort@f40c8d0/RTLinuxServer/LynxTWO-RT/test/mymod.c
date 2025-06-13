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
#include <linux/delay.h>
#include <asm/atomic.h>
#include <asm/io.h>
#include <asm/page.h>
#include <limits.h>

#include <math.h>


#include "LynxTWO-RT.h"

#define SAMPLING_RATE 200000
#define BUFSIZE (SAMPLING_RATE*5*2)
#define NBUFS 4

int play = (1<<0)|(1<<1)|(1<<2)|(1<<3);
s32 bufs[NBUFS][BUFSIZE];
int hzs[] = { 440, 660, 732, 880 };

MODULE_PARM(play, "i");

int init(void);
void cleanup(void);
void setupBufs(void);

int init(void)
{
  int i;

  printk("L22 Mixer overflow at start is %d\n", L22MixerOverflowed());

  setupBufs();
  L22SetSamplingRate(SAMPLING_RATE);
  for (i = 0; i < NBUFS; ++i)
    L22SetAudioBuffer(bufs[i], BUFSIZE, PCM32|MONO, i);
  for (i = 0; i < NBUFS; ++i) {
      if ( play & (0x1 << i) ) {
           L22Play(i);
      }
      msleep(250);
  }
  return 0;
}

void cleanup(void)
{
  int i;
  printk("L22 Mixer overflow at end is %d\n", L22MixerOverflowed());
  for (i = 0; i < NBUFS; ++i) {
    L22Stop(i);
    L22SetAudioBuffer(0, 0, 0, i);
  }
}

void setupBufs(void)
{
  int i,j;

  for (i = 0; i < NBUFS; ++i)
    for (j = 0; j < BUFSIZE/2; ++j) {
      double r = ((double)j*2)/((double)SAMPLING_RATE/(double)hzs[i]) - 1.0;
      double val = sin(2.0*r) * (double)INT_MAX;
      bufs[i][2*j] = bufs[i][2*j+1] = val;
  }
}

module_init(init);
module_exit(cleanup);
MODULE_LICENSE("GPL");

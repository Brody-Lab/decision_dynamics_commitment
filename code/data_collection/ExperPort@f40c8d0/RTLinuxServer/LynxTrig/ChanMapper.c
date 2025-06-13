#ifndef __KERNEL__
#  define __KERNEL__
#endif
#include "ChanMapper.h"
#include "LynxTWO-RT.h"
#include "LynxTrig.h"
#include <linux/kernel.h>
#include <linux/slab.h>

struct Channels
{
  s8 s2cMap[MAX_SND_ID];
  s8 c2sMap[L22_NUM_CHANS];
  u8 freeMask;
  unsigned last_chan;
  int debug;
  L22Dev_t dev;
  PrintFunc print;
};

#define DEBUG(x...) do { if (channels->print) channels->print(x); } while(0)

Channels * CM_Init(L22Dev_t dev, PrintFunc pf)
{
  Channels *c = kmalloc(sizeof(*c), GFP_KERNEL);
  if (c) {
    CM_Reset(c);  
    c->print = pf;
    c->dev = dev;
  }
  return c;
}

void CM_Destroy(Channels * c)
{
  if (c)  kfree(c);
}

void CM_Reset(Channels * channels)
{
  PrintFunc pf = channels->print;
  L22Dev_t d = channels->dev;
  /* don't clear the mutex! */
  memset(channels, -1, sizeof(*channels));
  channels->freeMask = (0x1<<L22_NUM_CHANS) - 1;
  channels->last_chan = 0;
  channels->print = pf;
  channels->dev = d;
}

unsigned CM_GrabChannel(Channels *channels, unsigned sound_id)
{
  int chan;

  DEBUG("CM_GrabChannel sound_id=%u\n", sound_id);

  /* if it's already  playing, stick to the same channel! */  
  chan = CM_LookupSound(channels, sound_id);
  /* otherwise, try and find a free channel id: note this code is kind
     of ugly.  */
  if (chan < 0) {
    /* loop to find a free channel as per the freemask */
    for (chan = 0; chan < L22_NUM_CHANS; ++chan) 
      if ( (channels->freeMask & (0x1<<chan)) && !L22IsPlaying(channels->dev, chan) ) 
        break; 
    /* if that failed, loop to find any free channel that isn't playing. */
    if (chan >= L22_NUM_CHANS)
      for (chan = 0; chan < L22_NUM_CHANS; ++chan) 
        if (!L22IsPlaying(channels->dev, chan) )  break;
    /* if none of the two above loops found a free channel, try and grab one
       by arbitrarily picking one off of the last_chan counter. */
    if (chan >= L22_NUM_CHANS) chan = ++channels->last_chan % L22_NUM_CHANS;
    else channels->last_chan = chan;
  }
  channels->freeMask &= ~(0x1<<chan); /* clear bit. */
  channels->s2cMap[sound_id] = chan;
  channels->c2sMap[chan] = sound_id;

  DEBUG("CM_GrabChannel ret=%u\n", chan);
  return chan;
}

int CM_LookupSound(Channels *channels, unsigned sound_id)
{  
  int chan = channels->s2cMap[sound_id];
  DEBUG("CM_LookupSound sound_id=%u\n", sound_id);
  if (chan < 0) { /* Lookup the chan in the c2s mapping? */
    int i;
    for (i = 0; i < L22_NUM_CHANS; ++i)
      if (channels->c2sMap[i] == sound_id) {
        chan = i;
        goto ok_out;
      }
/* not_ok_out: */
    chan = -1;
  ok_out:
    (void)0; /* to prevent compiler warnings */
  }
  DEBUG("CM_LookupSound ret=%d\n", chan);
  return chan;
}

int CM_LookupChannel(Channels *channels, unsigned chan)
{
  int snd = channels->c2sMap[chan];
  DEBUG("CM_LookupChannel chan=%u\n", chan);
  if (snd < 0) { /* Lookup the snd in the s2c mapping? */
    int i;
    for (i = 0; i < MAX_SND_ID; ++i)
      if (channels->s2cMap[i] == chan) {
        snd = i;
        break;
      }
  }
  DEBUG("CM_LookupChannel ret=%d\n", snd);
  return snd;
}

void CM_ClearSound(Channels *channels, unsigned sound_id)
{
  int chan;
  DEBUG("CM_ClearSound sound_id=%u\n", sound_id);
  chan = CM_LookupSound(channels, sound_id);
  channels->s2cMap[sound_id] = -1;
  if (chan < 0) return;
  channels->s2cMap[sound_id] = channels->c2sMap[chan] = -1;
  channels->freeMask |= 0x1<<chan;
  DEBUG("CM_ClearSound ret=(void)\n");
}

void CM_ClearChannel(Channels *channels, unsigned chan)
{
  int snd = CM_LookupChannel(channels, chan);
  DEBUG("CM_ClearSound chan=%u\n", chan);
  channels->c2sMap[chan] = -1;
  if (snd >= 0) channels->s2cMap[snd] = -1;
  channels->freeMask |= 0x1<<chan;
  DEBUG("CM_ClearSound ret=(void)\n");
}

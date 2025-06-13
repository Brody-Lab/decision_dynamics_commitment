#ifndef __KERNEL__
#  define __KERNEL__
#endif
#include "ChanMgr.h"
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
};

Channels * CM_Init(void)
{
  Channels *c = kmalloc(sizeof(*c), GFP_KERNEL);
  if (c) CM_Reset(c);
  return c;
}

void CM_Destroy(Channels * c)
{
  kfree(c);
}

void CM_Reset(Channels * channels)
{
  memset(channels, -1, sizeof(*channels));
  channels->freeMask = (0x1<<L22_NUM_CHANS) - 1;
  channels->last_chan = 0;
}

unsigned CM_GrabChannel(Channels *channels, unsigned sound_id)
{
  int chan;

  /* if it's already  playing, stick to the same channel! */  
  chan = CM_LookupSound(channels, sound_id);
  /* otherwise, try and find a free channel id: note this code is kind
     of ugly.  */
  if (chan < 0) { 
    /* loop to find a free channel as per the freemask */
    for (chan = 0; chan < L22_NUM_CHANS; ++chan) 
      if ( (channels->freeMask & (0x1<<chan)) && !L22IsPlaying(chan) ) 
        break; 
    /* if that failed, loop to find any free channel that isn't playing. */
    if (chan >= L22_NUM_CHANS)
      for (chan = 0; chan < L22_NUM_CHANS; ++chan) 
        if (!L22IsPlaying(chan) )  break;
    /* if none of the two above loops found a free channel, try and grab one
       by arbitrarily picking one off of the last_chan counter. */
    if (chan >= L22_NUM_CHANS) chan = ++channels->last_chan % L22_NUM_CHANS;
    else channels->last_chan = chan;
  }
  channels->freeMask &= ~0x1<<chan; /* clear bit. */
  channels->s2cMap[sound_id] = chan;
  channels->c2sMap[chan] = sound_id;
  return chan;
}

int CM_LookupSound(Channels *channels, unsigned sound_id)
{
  int chan = channels->s2cMap[sound_id];
  if (chan < 0) { /* Lookup the chan in the c2s mapping? */
    int i;
    for (i = 0; i < L22_NUM_CHANS; ++i)
      if (channels->c2sMap[i] == sound_id) {
        chan = i;
        break;
      }
  }
  return chan;
}

int CM_LookupChannel(Channels *channels, unsigned chan)
{
  int snd = channels->c2sMap[chan];
  if (snd < 0) { /* Lookup the snd in the s2c mapping? */
    int i;
    for (i = 0; i < MAX_SND_ID; ++i)
      if (channels->s2cMap[i] == chan) {
        snd = i;
        break;
      }
  }
  return snd;
}

void CM_ClearSound(Channels *channels, unsigned sound_id)
{
  int chan = CM_LookupSound(channels, sound_id);
  channels->s2cMap[sound_id] = -1;
  if (chan < 0) return;
  channels->s2cMap[sound_id] = channels->c2sMap[chan] = -1;
  channels->freeMask |= 0x1<<chan;
}

void CM_ClearChannel(Channels *channels, unsigned chan)
{
  int snd = CM_LookupChannel(channels, chan);
  channels->c2sMap[chan] = -1;
  if (snd >= 0) channels->s2cMap[snd] = -1;
  channels->freeMask |= 0x1<<chan;
}

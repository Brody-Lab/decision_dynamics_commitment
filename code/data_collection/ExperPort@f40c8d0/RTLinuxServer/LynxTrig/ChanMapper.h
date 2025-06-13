#ifndef ChanMgr_H
#define ChanMgr_H

#include "LynxTWO-RT.h"


struct Channels; /* Channel Manager 'object' */
typedef struct Channels Channels;

typedef int (*PrintFunc)(const char *, ...) __attribute__((__format__(printf, 1, 2)));

/** Initialize the Channel Manager object.  
    @return a Channel * pointer to a newly allocated Channel Manager
    object.  The object is allocated using kmalloc().  Free it with CM_Destroy.
*/
extern Channels * CM_Init(L22Dev_t dev, PrintFunc debugPrintfunc);
/** Frees the memory associated with the channel manager object obtained
    from CM_Init() */
extern void       CM_Destroy(Channels *);
/** Reset the channel manager mappings to their default state. */
extern void CM_Reset(Channels *);
/** Allocate a channel ID for a given sound_id.
    @param sound_id the sound id of the sound for which to allocate a channel
    @return the channel id, from 0-L22_NUM_CHANS of the allocated
    channel id.  Use this channel id when calling L22Play() 
*/
extern unsigned CM_GrabChannel(Channels *, unsigned sound_id);
/** Lookup the channel for a given sound id 
    @param sound_id the sound id
    @return the devchan long (see struct DevChan above) for the given sound_id, or -1 if mapping
    doesn't exist.  This can happen if the sound stopped playing. 
*/
extern int  CM_LookupSound(Channels *, unsigned sound_id);

/** Lookup the sound_id for a given channel id pair.
    @param chan the channel id to query
    @return the sound_id for the given dev,channel id, or -1 if the channel
    is not mapped to anything (can happen if it is no longer playing). */
extern int      CM_LookupChannel(Channels *, unsigned chan);
/** Clear a mapping by sound_id.
    @param sound_id the sound_id for which to clear the channel mapping. */
extern void     CM_ClearSound(Channels *, unsigned sound_id);
/** Clear a mapping by channel id.
    @param chan the channel id for which to clear the channel mapping. */
extern void     CM_ClearChannel(Channels *, unsigned chan);
#endif

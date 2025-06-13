#ifndef LYNX_TWO_RT_H
#define LYNX_TWO_RT_H

/** defines for format_code below.. */
#define PCM8 0
#define PCM16 1
#define PCM24 2
#define PCM32 3
#define MONO 0x0
#define STEREO 0x4

#define L22_MAX_DEVS 4
#define L22_MAX_VOLUME 0xFFFF
#define L22_NUM_CHANS 4
#define L22_ALL_CHANS ((unsigned)((int)-1))

typedef int L22Dev_t;

/** returns the number of L22 Devices that exist or 0 if none exist */
extern int L22GetNumDevices(void); 

#define L22DEV_OPEN_ERROR (-1)

/** Open an L22 device.  Pass a device number (from 0 -> L22GetNumDevices())
    Returns the handle to an L22 device that can be used with the rest
    of the functions in this API.
    Returns L22DEV_OPEN_ERROR on error.   */
extern L22Dev_t L22Open(int devno);

/** Close a previously-opened device */
extern void L22Close(L22Dev_t);

/** Specify an audio buffer for the audio data to play.  
    It is necessary to call this before L22Play() will actually play anything.
    It is ok to call this function from RT context.

    Note that since the L22 is 'always playing' calling this function
    is equivalent to calling L22Play(), except here you have the 
    opportunity to change the soundbuffer being played.

    Calling this function with a NULL buffer pointer will stop playing
    sounds (play silence) and is equivalent to calling L22Stop().

    Note that the sampling rate is taken from the preset used in 
    L22SetSamplingRate();

    @param buffer the pointer to the kernelspace memory area containing all
    the sound data to play.   Note: The bumber of bytes in buffer should be:
    num_samples * NUM_CHANS * (BITS_PER_SAMPLE/8) where NUM_CHANS is 1 for 
    mono, 2 for stereo and BITS_PER_SAMPLE pertains to the various PCM formats 
    above..

    @param format_code   OR of PCMxx define and one of MONO or STEREO defines

    @param chan_id       The mixer channel id to put this sound buffer on. Valid channel id's are from 0-7 (meaning up to 8 simultaneous sounds can play).  Use this same chan_id when calling L22Play() at a later time.

    @param looped if true, loop the sound infinitely (by wrapping around to beginning) after it is played.  The sound can only be stopped with an L22Stop()

    @returns true on success, false if there is some error (most likely due
    to sampling rate/format invalid)  */   
extern int L22SetAudioBuffer(L22Dev_t dev,
                             void *buffer, 
                             unsigned long num_bytes, /**< NB: It is imporant that this buffer be sized to be a multiple of a sample block.  A sample block is the number of bytes per sample * the number of channels in the stream.  The number of bytes per sample is a function of the PCMxx format... */
                             int format_code,
                             unsigned chan_id,
                             int looped);
/** Play the audio buffer specified by L22SetAudioBuffer.
    @param chan_id a number from 0-7, or L22_ALL_CHANS to indicate which sound
    channel is to play.  L22_ALL_CHANS plays all buffers simultaneously.
    It is safe to call this function from realtime context.  */
extern int L22Play(L22Dev_t dev, unsigned chan_id);

/** Stop playing if we were playing, otherwise noop. 
    @param chan_id the channel to stop, or L22_ALL_CHANS to stop them all.
    It is safe to call this function from realtime context.  */
extern void L22Stop(L22Dev_t dev, unsigned chan_id);

/** Return true if the L22 device is currently playing a sound, 
    false otherwise.
    @param chan_id The channel id to check if it is playing, or L22_ALL_CHANS to query if any channel is playing.
    It is safe to call this function from realtime context.  */
extern int L22IsPlaying(L22Dev_t dev, unsigned chan_id);

/** Return the currently-set sampling rate. Sorry, you cannot Set the sampling
    rate programmatically anymore due to implementation limitations.  Instead,
    it is set at module-load time.  This will change in the future. */
extern unsigned L22GetSampleRate(L22Dev_t);

/** Returns the current play volume, a value from 0 - L22_MAX_VOLUME */
extern unsigned long L22GetVolume(L22Dev_t dev, unsigned chan);
/** Sets the current play volume, a value from 0 - L22_MAX_VOLUME 
    returns 1 on success or 0 on error.                              */
extern int L22SetVolume(L22Dev_t dev, unsigned chan, unsigned long volume);

/** Returns true iff the L22 Hardware mixer has overflowed since the last
    call to this function. Note that calling this function resets 
    the overflow flag.   Overflow happens when the channels mixed together
    by the hardware mixer produce samples that are too loud and outside
    the maximum amplitude of the device.  This is a common problem when
    doing summation mixing (such as what the L22 has). */
extern int L22MixerOverflowed(L22Dev_t dev);

#endif

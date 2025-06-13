function [x, y, chord_sound_len, make_fn] = InitChord(x, y, side_list, n_done_trials, obj)
%
% [x, y, chord_sound_len, make_chord_fn] = InitChord(x, y, side_list, ...
%                                                    n_done_trials, obj)
%
% args:    x, y                 current UI position, in pixels
%          side_list            list of correct sides, one per trial
%          n_done_trials        number of completed trials
%          obj                  A locsamp3obj object
%
% returns: x, y                 updated UI pos
%          chord_sound_len      handle to length, in secs, of chord sound
%          make_chord_fn        Function that handles making the chord
%

GetSoloFunctionArgs;

if ~exist('SoundSPL', 'var'),
    EditParam(obj, 'SoundSPL',        60,    x, y);   next_row(y);
    EditParam(obj, 'SoundDur',        0.2,   x, y);   next_row(y);
    EditParam(obj, 'BaseFreq',        1,     x, y);   next_row(y);
    EditParam(obj, 'NTones',          16,    x, y);   next_row(y);
    EditParam(obj, 'RampDur',         0.005, x, y);   next_row(y);
    EditParam(obj, 'ValidSoundTime',  0.03,  x, y);   next_row(y);

    SoloParamHandle(obj, 'chord_sound_data');
    SoloParamHandle(obj, 'chord_sound_len');
    SoloParamHandle(obj, 'chord_uploaded', 'value', 0);
    
    set_callback({SoundSPL, SoundDur, BaseFreq, NTones, RampDur, ValidSoundTime}, ...
        {'InitChord'});

end;

make_chord(obj); % Make the first chord. Chosen side is side_list(n_done_trials+1)

make_fn = 'make_chord';
return;



function [x, y, chord_sound_len] = make_chord(obj, action, x, y)

GetSoloFunctionArgs;
% SoloFunction('make_chord', 'ro_args', {'side_list', 'n_done_trials'});

switch action,
    case 'init'
        EditParam(obj, 'SoundSPL',        60,    x, y);   next_row(y);
        EditParam(obj, 'SoundDur',        0.2,   x, y);   next_row(y);
        EditParam(obj, 'BaseFreq',        1,     x, y);   next_row(y);
        EditParam(obj, 'NTones',          16,    x, y);   next_row(y);
        EditParam(obj, 'RampDur',         0.005, x, y);   next_row(y);
        EditParam(obj, 'ValidSoundTime',  0.03,  x, y);   next_row(y);
        
        SoloParamHandle(obj, 'chord_sound_data');
        SoloParamHandle(obj, 'chord_sound_len');
        SoloParamHandle(obj, 'chord_uploaded', 'value', 0);
    
        set_callback({SoundSPL, SoundDur, BaseFreq, NTones, RampDur, ...
            ValidSoundTime}, {'make_chord', 'make'});
    
        make_chord(obj, 'make');

    case 'make'
        chord = MakeChord(50e6/1024,  70-SoundSPL, ...
            BaseFreq*1000, value(NTones), SoundDur*1000, RampDur*1000);
        if side_list(n_done_trials+1) == 1,
            chord_sound_data.value = [zeros(length(chord), 1), chord'];
        else
            chord_sound_data.value = [chord', zeros(length(chord), 1)];
        end;
        chord_sound_len.value = SoundDur;            
        chord_uploaded.value = 0;

    case 'upload'
        if value(chord_uploaded), return; end;
        rpbox('loadrp3stereosound1', chord_sound_data);
        chord_uploaded.value = 1;
        
    otherwise
        error(['Don''t know how to handle action ' action]);
end;


return;
    

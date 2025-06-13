function [x, y] = ChordSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
    case 'init'    % ------------- CASE 'INIT' ------------
        % make a collapsible figure for sound parameters
        fig = gcf;
        rpbox('InitRP3StereoSound');
        figure(fig);
        oldx = x; oldy = y;  x = 5; y = 5;
        SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable', 0);

        % SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);
        NumeditParam(obj, 'SoundSPL', 20, x, y); next_row(y);
        NumeditParam(obj, 'SoundDur', 0.1, x, y); next_row(y);
        NumeditParam(obj, 'RampDur',    0.005, x, y);   next_row(y);
        NumeditParam(obj, 'NTones', 1, x, y); next_row(y);
        NumeditParam(obj, 'BaseFreq3', 7, x, y); next_row(y);
        NumeditParam(obj, 'BaseFreq2', 4, x, y); next_row(y);
        NumeditParam(obj, 'BaseFreq1', 1, x, y); next_row(y);
        PushButtonParam(obj, 'reload', x, y, 'label', 'Reload Sound');
        set_callback({reload}, {'ChordSection', 'upload_sounds'});
        
        set(value(myfig), 'Position', [240  600  200  170], 'Visible', 'off', ...
            'MenuBar', 'none', 'Name', 'Chord Parameters', 'NumberTitle', 'off',...
            'CloseRequestFcn', ['ChordSection(' class(obj) '(''empty''), ''chord_param_hide'')']);
        
        x = oldx; y = oldy; figure(fig);
        MenuParam(obj, 'Tone_cue', {'OFF', 'ON'}, 1, x, y); next_row(y);

        MenuParam(obj, 'ChordParameters', {'hidden', 'view'}, 1, x, y); next_row(y);
        set_callback({ChordParameters}, {'ChordSection', 'chord_param_view'});

        SoloParamHandle(obj, 'sound_cue1');
        SoloParamHandle(obj, 'sound_cue2');
        SoloParamHandle(obj, 'sound_cue3');
        SoloParamHandle(obj, 'start_sound_data');
        
        SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', {'Tone_cue'});

        set_callback({SoundSPL, SoundDur, BaseFreq1, BaseFreq2, BaseFreq3, NTones, RampDur}, ...
            {'ChordSection', 'make'});

        
        SubheaderParam(obj, 'title', 'Sound Parameters', x, y);
        next_row(y, 1.5);
        
        ChordSection(obj, 'make');
        ChordSection(obj, 'upload_sounds');
        ChordSection(obj, 'make_upload_othersounds');

    case 'make'                 % ----------- case MAKE ----------------
        sound_cue1.value = MakeChord(5e6/1024,  70-SoundSPL, ...
            BaseFreq1*1000, value(NTones), SoundDur*1000, RampDur*1000);
        sound_cue2.value = MakeChord(5e6/1024,  70-SoundSPL, ...
            BaseFreq2*1000, value(NTones), SoundDur*1000, RampDur*1000);
        sound_cue3.value = MakeChord(5e6/1024,  70-SoundSPL, ...
            BaseFreq3*1000, value(NTones), SoundDur*1000, RampDur*1000);
        
    case 'upload_sounds'   % ------------- CASE 'UPLOAD_SOUNDS' ------------
        sm = rpbox('getsoundmachine');
        sm = SetSampleRate(sm, 5e6/1024);
        sm = LoadSound(sm, 1, value(sound_cue1), 'both', 0, 0);
        sm = LoadSound(sm, 2, value(sound_cue2), 'both', 0, 0);
        sm = LoadSound(sm, 3, value(sound_cue3), 'both', 0, 0);
        sm = rpbox('setsoundmachine', sm);
        

    case 'make_upload_othersounds'
        base_freq_start = 1;
        n_tones_start = 16;
        sound_dur_start = 0.05;
        ramp_dur_start = 0.005;
        sound_spl_start = SoundSPL;
        start_chord = MakeChord(50e6/1024,  70-sound_spl_start, ...
            base_freq_start*1000, value(n_tones_start), ...
            sound_dur_start*1000, ramp_dur_start*1000);
        start_chord_data = [start_chord; start_chord];

        sm = rpbox('getsoundmachine');
        sm = SetSampleRate(sm, 50e6/1024);
        sm = LoadSound(sm, 101, value(start_chord_data), 'both', 0, 0);
        sm = rpbox('setsoundmachine', sm);

    case 'delete'            , % ------------ case DELETE ----------
        delete(value(myfig));
        
    case 'chord_param_view',   % ------- case CHORD_PARAM_VIEW
        switch value(ChordParameters)
            case 'hidden',
                set(value(myfig), 'Visible', 'off');

            case 'view',
                set(value(myfig), 'Visible', 'on');
        end;

    case 'chord_param_hide',
        ChordParameters.value = 'hidden';
        set(value(myfig), 'Visible', 'off');

    otherwise
        error(['Don''t know how to handle action ' action]);
end;

return;


function [x, y, sound_len, go_dur] = ChordSection(obj, action, x, y)

GetSoloFunctionArgs;
% Read-only: maxtrials, n_started_trials, n_done_trials, side_list,
% vpd_list, task_list
% Read-write: super

% Generates non-penalty / non-ITI sounds for this protocol
% For duration_discobj, the method generates the following sound matrix:
% 1. A low frequency tone or hi frequency tone
% 2. Silence before the GO signal +
% 3. the GO signal itself.
%
% These three sounds are generated in one matrix because the current rig
% limits us to using only three sounds (two of which are used for ITI and
% the BadBoy sound).

switch action,
    case 'init'
        % parent protocol window
        fig = gcf; rpbox('InitRP3StereoSound'); figure(fig);
        parentfig_x = x; parentfig_y =  y;

        % new popup window
        x = 5; y = 5;   % coordinates for popup window
        SoloParamHandle(obj, 'chordfig', 'value', figure, 'saveable', 0);

        SoloParamHandle(obj, 'NTones', 'value', 16);
        SoloParamHandle(obj, 'RampDur', 'value', 0.005);

        col1_x = x;
        base_y = y;

        % generic parameters
        next_column(x);
        next_row(y, 0.5);
        MenuParam(obj, 'GO_Loc', {'on', 'off'}, 1, x, y, 'label', 'Localise GO', 'TooltipString', '"on": GO only on reward side, "off": Surround-sound'); next_row(y);
        next_row(y,0.5);
        EditParam(obj, 'GODur', 0.3, x, y, 'label', 'GO Duration', 'TooltipString', 'Length of GO signal sound (in secs)'); next_row(y);
        next_row(y,0.5);
        EditParam(obj, 'SoundSPL_R', 60, x, y, 'label', 'GO SPL (R)', 'TooltipString', 'GO sound intensity (Right channel)');     next_row(y);
        EditParam(obj, 'SoundSPL_L', 60, x, y, 'label','GO SPL (L)', 'TooltipString', 'Sound intensity / Volume (Left channel)'); next_row(y);
        next_row(y,0.5);
        EditParam(obj, 'BaseFreq',  1, x, y, 'label', 'GO Frequency', 'TooltipString', 'Starting pitch (in KHz) of GO chord');   next_row(y);
        next_row(y,0.5);
        EditParam(obj, 'ValidSoundTime', 0.03, x, y, 'label', 'Leave-after-GO', 'TooltipString', 'Time (in secs) after the onset of GO signal\nthat the rat may leave without penalty'); next_row(y);
        next_row(y,0.5);
        SubheaderParam(obj, 'snd_gen', 'GO Signal', x, y);next_row(y);
        %        next_row(y, 0.5);

        x = col1_x;
        y = base_y;
        % Task-specific parameters
        next_row(y, 0.5);
        MenuParam(obj, 'Tone_Loc', {'on', 'off'}, 1, x, y, 'label', 'Localise Tone', 'TooltipString', '"on": Cue is localised'); next_row(y);
        next_row(y,0.5);
        EditParam(obj, 'Trial_Length', 2.2, x, y, 'label', 'Trial Length', 'TooltipString', 'When set, preGO time is adjusted to keep trial length constant');next_row(y);
        EditParam(obj, 'HzdRt_2_GO', 0.01, x, y, 'label', 'Pre-GO (Hzd Rt)', 'TooltipString', 'Defines distribution of silent time before GO signal'); next_row(y);
        EditParam(obj, 'Max_2_GO', 0.3, x, y, 'label', 'Pre-GO (Max)', 'TooltipString', 'Upper-bound silence before GO signal (in secs)'); next_row(y);
        EditParam(obj, 'Min_2_GO', 0.3, x, y, 'label', 'Pre-GO (Min)', 'TooltipString', 'Lower-bound silence before GO signal (in secs)'); next_row(y);
        % Note: Default is to have fixed trial length
        MenuParam(obj, 'PreGO_type', {'Variable', 'Fixed Length'}, 1, x, y, 'label', 'Pre-GO Type', 'TooltipString', 'Random times till GO (variable) or time to have fixed trial length');next_row(y);

        set_callback(PreGO_type, {'ChordSection', 'update_prechord'});
        set_callback(Trial_Length,{'ChordSection', 'set_future_prechord_constant_trial'});
        %        set(get_ghandle(Min_2_GO), 'Enable', 'off');
        %       set(get_ghandle(Max_2_GO), 'Enable', 'off');
        %      set(get_ghandle(HzdRt_2_GO), 'Enable', 'off');
        set(get_ghandle(Trial_Length), 'Enable', 'off');

        % RELEVANT TONE begins here --------------
        next_row(y, 0.5);

        % Parameters for Pitch Discrimination begin here ------------------
        EditParam(obj, 'PD_Hi_Freq', 15, x, y, 'label', 'RIGHT Frequency', 'TooltipString', 'PITCH DISC: Frequency (KHz) to play for RHS (high) in PD blocks'); next_row(y);
        EditParam(obj, 'Duration_R', 1.0, x, y, 'label', 'RIGHT Duration', 'TooltipString', 'PITCH DISC: Duration (in ms) of both tones in PD blocks');next_row(y);
        next_row(y,0.5);

        EditParam(obj, 'PD_Low_Freq', 5, x, y, 'label', 'LEFT Frequency', 'TooltipString', 'PITCH DISC: Frequency (KHz) to play for LHS (low) in PD blocks'); next_row(y);
        EditParam(obj, 'Duration_L', 0.3, x, y, 'label', 'LEFT Duration', 'TooltipString', 'PITCH DISC: Duration (in ms) of both tones in PD blocks');next_row(y);
        next_row(y,0.5);

        % Common parameters
        EditParam(obj, 'Tone_SPL_R', 30, x, y, 'label', 'Tone SPL (R)', 'TooltipString', 'Sound intensity/volume of sample tones'); next_row(y);
        EditParam(obj, 'Tone_SPL_L', 30, x, y, 'label', 'Tone SPL (L)', 'TooltipString', 'Sound intensity/volume of sample tones'); next_row(y);
        next_row(y,0.5);

        SubheaderParam(obj, 'pitch_sbh', 'Pitch Discrimination Parameters', x,y); next_row(y);


        % FIGURE-specific and unseen SPHs ---------------
        set(value(chordfig), ...
            'Visible', 'off', 'MenuBar', 'none', 'Name', 'Chord Parameters', ...
            'NumberTitle', 'off', 'CloseRequestFcn', ...
            ['ChordSection(' class(obj) '(''empty''), ''chord_param_hide'')']);
        set(value(chordfig), 'Position', [836 485 435 272]);

        x = parentfig_x; y = parentfig_y; figure(fig);  % make master protocol figure gcf
        MenuParam(obj, 'ChordParameters', {'hidden', 'view'}, 1, x, y); next_row(y);
        set_callback({ChordParameters}, {'ChordSection', 'chord_param_view'});

        SoloParamHandle(obj, 'sound_data');    % raw sound matrix
        SoloParamHandle(obj, 'sound_len');     % length (in seconds)
        SoloParamHandle(obj, 'sound_uploaded', 'value', 0);
        % `	SoloParamHandle(obj, 'sound_type', 'value', 'stereo');
        SoloParamHandle(obj, 'go_dur', 'value', 0);	% duration of GO signal

        % All the variable sound elements
        SoloParamHandle(obj, 'prechord_list', 'value', zeros(1,value(maxtrials)) );  % Variable preGO durations

        % CALLBACKS ------------------------
        set_callback({ Tone_Loc, Tone_SPL_L, Tone_SPL_R, ...
            PD_Low_Freq, PD_Hi_Freq, Duration_L, Duration_R, ...
            SoundSPL_L, SoundSPL_R, BaseFreq, GODur, GO_Loc, ValidSoundTime}, ...
            {'ChordSection','make'});

        set_callback({Min_2_GO, Max_2_GO, HzdRt_2_GO}, {'ChordSection', 'set_future_prechord'; 'ChordSection', 'make'});

        ChordSection(obj, 'update_prechord');
        ChordSection(obj, 'make');
        ChordSection(obj, 'upload');

    case 'make'
        dummy = protocolobj('empty');
        left = get_generic(dummy, 'side_list_left');
        srate = get_generic(dummy, 'sampling_rate');

        % Part 1: Set the relevant sound
        tone_stat = '';

        if side_list(n_done_trials+1) == left
            tone_pitch = value(PD_Low_Freq);        % the pitch varies ...
            tone_dur = value(Duration_L);
            tone_stat = ['PD LEFT: Pitch is: ' num2str(tone_pitch)];
        else
            tone_pitch = value(PD_Hi_Freq);
            tone_dur = value(Duration_R);
            tone_stat = ['PD RIGHT: Pitch is: ' num2str(tone_pitch)];
        end;
        %     tone_dur = value(PD_Duration) * 1000;            % ... but duration is constant.
        tone_stat = [tone_stat ', duration = ' num2str(tone_dur)];
        tone_stat   % print type of tone presented --- for sanitys purposes

        % Make sound data matrix
        if tone_dur > 0
            main_tone_L = MakeChord(srate, 70-Tone_SPL_L, tone_pitch*1000, 1, tone_dur*1000, value(RampDur)*1000);
            main_tone_R = MakeChord(srate, 70-Tone_SPL_R, tone_pitch*1000, 1, tone_dur*1000, value(RampDur)*1000);
        else
            main_tone_L = 0; main_tone_R = 0;
        end;
%        tone_dur = tone_dur/1000;   % set back into seconds for addition

        if strcmp(value(Tone_Loc), 'on')
            if side_list(n_done_trials+1) == left
                main_tone = [main_tone_L' zeros(length(main_tone_L), 1)];
            else
                main_tone = [zeros(length(main_tone_R), 1) main_tone_R'];
            end;
        else
            main_tone = [main_tone_L' main_tone_R'];      % only make stereo if necessary
        end;

        % Part 2: Space till go
        curr_pc = prechord_list(n_done_trials+1);
        % ['space length is: ' num2str(curr_pc)]
        space = zeros(1, floor(curr_pc*srate));
        space = [space' space'];

        % Part 3: GO signal
        gosig_L = MakeChord(srate, 70-SoundSPL_L, 1000, value(NTones), value(GODur)*1000, value(RampDur)*1000);
        gosig_R = MakeChord(srate, 70-SoundSPL_R, 1000, value(NTones), value(GODur)*1000, value(RampDur)*1000);
        if strcmp(value(GO_Loc), 'on')                % localise GO signal means everybody is in stereo
            if side_list(n_done_trials+1) == left
                gosig = [gosig_L' zeros(length(gosig_L), 1)];
            else
                gosig = [zeros(length(gosig_R), 1) gosig_R'];
            end;
            % stitch together sound components
        else
            gosig = [gosig_L' gosig_R'];
        end;

        % Finally, set the value
        %        [' tone dur should be in seconds: ' num2str(tone_dur) ]
        sound_data.value = [main_tone; space; gosig]; % row matrices
        sound_len.value = tone_dur + curr_pc + value(GODur);
      %  ['Tone dur: ' num2str(tone_dur) ', spacer: ' num2str(curr_pc) ', go duration: ' num2str(GODur)]
%        ['sound_len value is: ' num2str(value(sound_len))]
        sound_uploaded.value = 0;
        go_dur.value = value(GODur);

    case 'upload'
        if value(sound_uploaded)==1, return; end;

        rpbox('loadrp3stereosound1', {value(sound_data)});
        sound_uploaded.value = 1;

    case 'get_ValidSoundTime',
        x = value(ValidSoundTime);

    case 'get_ChordSoundLen',
        x = value(sound_len);

    case 'get_GoDur',
        x = value(go_dur);

    case 'delete'
        delete(value(chordfig));

    case 'chord_param_view'
        switch value(ChordParameters)
            case 'hidden',
                set(value(chordfig), 'Visible', 'off');

            case 'view',
                set(value(chordfig), 'Visible', 'on');
        end;

    case 'chord_param_hide'
        ChordParameters.value = 'hidden';
        set(value(chordfig), 'Visible', 'off');


    case 'set_future_prechord'
        if Min_2_GO > Max_2_GO
            Max_2_GO.value = value(Min_2_GO);
        end;
        len = length(prechord_list)-(n_started_trials+1)+1;

        list = generate_variability(value(Min_2_GO), value(Max_2_GO), HzdRt_2_GO, len);
        prechord_list(n_started_trials+1:length(prechord_list)) = list;

    case 'set_future_prechord_constant_trial'
        tlen = value(Trial_Length);

        % get entire array of tone_duration
        dummy = protocolobj('empty');
        left = get_generic(dummy, 'side_list_left');
        tone_list = side_list;

        left_ind = find(side_list == left);
        tone_list(left_ind) = value(Duration_L);

        right_ind = find(side_list ~= left);
        tone_list(right_ind) = value(Duration_R);

        % Compute time left over after pre-sound time + relevant tone
        left_over = vpd_list + tone_list;  % time so far
        left_over = value(Trial_Length) - left_over;
        min_prechord = get_generic(dummy, 'min_prechord_time');
        left_over = max(left_over, min_prechord);

        prechord_list(n_started_trials+1:length(prechord_list)) = left_over(n_started_trials+1:length(prechord_list));

    case 'update_prechord'
        if ~strcmpi(value(PreGO_type),'variable')   % fixed trial length
            % turn off params for other prechord type
            set(get_ghandle(Min_2_GO), 'Enable', 'off');
            set(get_ghandle(Max_2_GO), 'Enable', 'off');
            set(get_ghandle(HzdRt_2_GO), 'Enable', 'off');

            % turn on params for current prechord type
            set(get_ghandle(Trial_Length), 'Enable', 'on');
            ChordSection(obj, 'set_future_prechord_constant_trial');

        else    % variable trial length
            set(get_ghandle(Min_2_GO), 'Enable', 'on');
            set(get_ghandle(Max_2_GO), 'Enable', 'on');
            set(get_ghandle(HzdRt_2_GO), 'Enable', 'on');
            set(get_ghandle(Trial_Length), 'Enable', 'off');
            ChordSection(obj, 'set_future_prechord');
        end;

    otherwise
        error(['Don''t know how to handle action ' action]);
end;

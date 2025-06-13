function [x, y, sound_len, go_dur] = ChordSection(obj, action, x, y)

GetSoloFunctionArgs;
% Read-only: maxtrials, n_started_trials, n_done_trials, side_list
% Read-write: super

% Generates non-penalty / non-ITI sounds for this protocol
% For duration_discobj, the method generates the following sound matrix:
% 1. A tone of short/long duration +
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
        MenuParam(obj, 'PreGO_type', {'Variable', 'Fixed Length'}, 2, x, y, 'label', 'Pre-GO Type', 'TooltipString', 'Random times till GO (variable) or time to have fixed trial length');next_row(y);

       
        set(get_ghandle(Min_2_GO), 'Enable', 'off');
        set(get_ghandle(Max_2_GO), 'Enable', 'off');
        set(get_ghandle(HzdRt_2_GO), 'Enable', 'off');

        % RELEVANT TONE begins here --------------
        next_row(y, 0.5);
        % right tone
        EditParam(obj, 'Tone_SPL_R', 50, x, y, 'label', 'Tone SPL (R)', 'TooltipString', 'Sound intensity/volume of sample tone (RIGHT)'); next_row(y);
        EditParam(obj, 'Tone_Dur_R', 0.5, x, y, 'label', 'Tone Duration (R)', 'TooltipString', 'Duration (in sec) of sample tone (RIGHT)'); next_row(y);
        EditParam(obj, 'Tone_Freq_R', 15, x, y, 'label', 'Tone Frequency (R)', 'TooltipString', 'Frequency (in KHz) of sample tone'); next_row(y);
        
        next_row(y,0.5);
        
        EditParam(obj, 'Tone_SPL_L', 50, x, y, 'label', 'Tone SPL (L)', 'TooltipString', 'Sound intensity/volume of sample tone (LEFT)'); next_row(y);
        EditParam(obj, 'Tone_Dur_L', 0.5, x, y, 'label', 'Tone Duration (L)', 'TooltipString', 'Duration (in sec) of sample tone (LEFT)'); next_row(y);
        EditParam(obj, 'Tone_Freq_L', 1.0, x, y, 'label', 'Tone Frequency (L)', 'TooltipString', 'Frequency (in KHz) of sample tone'); next_row(y);      
        next_row(y,0.5);

        % Tone 2
%         nextrow_y = y;  next_row(y);
%         EditParam(obj, 'Tone_Dur2', 1.0, x, y, 'label', 'RIGHT Tone Dur.', 'TooltipString', 'Duration of tone for RIGHT trials(in secs)');
%         col1_x = x; next_column(x);
%         MenuParam(obj, 'Tone2_random', {'on', 'off'}, 2, x, y, 'label', 'T2 Sampling', 'TooltipString', '''on'' allows random sampling from range; ''off'' allows fixed tone duration');
%         y = nextrow_y;x = col1_x;
%         EditParam(obj, 'Tone2_from', value(Tone_Dur2), x, y, 'label', 'from', ...
%             'TooltipString', 'Min. RIGHT trial duration (random sampling)', ...
%             'position', [x y 75 gui_position('get_default_height')]);
%         col1_x = x; next_column(x, 0.5);
%         EditParam(obj, 'Tone2_to', value(Tone_Dur2), x, y, 'label', 'to', ...
%             'TooltipString', 'Max. RIGHT trial duration (random sampling)', ...
%             'position', [x y 100 gui_position('get_default_height')]);
%         next_row(y);next_row(y);x = col1_x;
%        next_row(y,0.5);

        % Tone 1
%        nextrow_y = y; next_row(y);
%        EditParam(obj, 'Tone_Dur1', 0.5, x, y, 'label', 'LEFT Duration.', 'TooltipString', 'Duration of tone for LEFT trials(in secs)');
%        col1_x = x; next_column(x);
%        MenuParam(obj, 'Tone1_random', {'on', 'off'}, 2, x, y, 'label', 'T1 Sampling', 'TooltipString', '''on'' allows random sampling from range; ''off'' allows fixed tone duration');
%         y = nextrow_y; x = col1_x;
%         EditParam(obj, 'Tone1_from', value(Tone_Dur1), x, y, 'label', 'from', ...
%             'TooltipString', 'Min. LEFT trial duration (random sampling)', ...
%             'position', [x y 75 gui_position('get_default_height')]);
%         col1_x = x; next_column(x,0.5);
%  %       EditParam(obj, 'Tone1_to', value(Tone_Dur1), x, y, 'label', 'to', ...
%             'TooltipString', 'Max. LEFT trial duration (random sampling)', ...
%             'position', [x y 100 gui_position('get_default_height')]);
%         next_row(y); next_row(y); x = col1_x;
%         next_row(y,0.5);

        SubheaderParam(obj, 'snd_spf', 'Relevant Tone', x, y); next_row(y);

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
%         SoloParamhandle('tone1_list', 'value', zeros(1,value(maxtrials)) ); % Potentially variable tone1 durations
%         SoloParamHandle(obj, 'tone2_list', 'value', zeros(1,value(maxtrials)) ); % Potentially varaible tone2 durations
        SoloParamHandle(obj, 'prechord_list', 'value', zeros(1,value(maxtrials)) );  % Variable preGO durations

        % CALLBACKS ------------------------
        set_callback({ Tone_Loc, SoundSPL_L, SoundSPL_R, BaseFreq, GODur, GO_Loc, ValidSoundTime}, ...
            {'ChordSection','make'});
        set_callback({Tone_SPL_L, Tone_Dur_L, Tone_Freq_L, Tone_SPL_R, Tone_Dur_R, Tone_Freq_R}, {'ChordSection', 'make'});
        set_callback({Min_2_GO, Max_2_GO, HzdRt_2_GO}, {'ChordSection', 'set_future_prechord'; 'ChordSection', 'make'});

        set_callback(PreGO_type, {'ChordSection', 'update_prechord'});
        set_callback(Trial_Length,{'ChordSection', 'set_future_prechord_constant_trial'});

   %     set_callback({Tone1_random, Tone2_random}, {'ChordSection', 'update_tone_schedule'; 'ChordSection', 'update_tones'; 'ChordSection', 'make'});
   %     set_callback({Tone_Dur1,Tone_Dur2}, {'ChordSection', 'update_prechord'; 'ChordSection', 'update_tones'; 'ChordSection', 'make'});
   %     set_callback({Tone1_from, Tone1_to, Tone2_from, Tone2_to}, {'ChordSection', 'update_tones'; 'ChordSection', 'make'});

        ChordSection(obj, 'update_prechord');
%         ChordSection(obj, 'update_tone_schedule');
%         ChordSection(obj, 'update_tones');
        ChordSection(obj, 'make');
        ChordSection(obj, 'upload');

    case 'make'
        dummy = protocolobj('empty');
        left = get_generic(dummy, 'side_list_left');
        srate = get_generic(dummy, 'sampling_rate');

        % Part 1: The prolonged tone
        if side_list(n_done_trials+1) == left
            tone_dur = Tone_Dur_L * 1000;
            tone_pitch = Tone_Freq_L;
            ['LEFT: Tone is ' num2str(tone_dur)]
        else
            tone_dur = Tone_Dur_R * 1000;
            tone_pitch = Tone_Freq_R;
            ['RIGHT: Tone is: ' num2str(tone_dur)]
        end;
        if tone_dur > 0
            main_tone_L = MakeChord(srate, 70-Tone_SPL_L, tone_pitch*1000, 1, tone_dur, value(RampDur)*1000);
            main_tone_R = MakeChord(srate, 70-Tone_SPL_R, tone_pitch*1000, 1, tone_dur, value(RampDur)*1000);
        else
            main_tone_L = 0; main_tone_R = 0;
        end;
        ['Tone is : ' num2str(tone_dur)]
        tone_dur = tone_dur/1000;   % set back into seconds for addition
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
            %	   sound_type.value = 'stereo';
        else
            gosig = [gosig_L' gosig_R'];
            %          sound_data.value = [main_tone space gosig];
            %	   sound_type.value = 'mono';
        end;

        % Finally, set the value
        sound_data.value = [main_tone; space; gosig]; % row matrices
        sound_len.value = tone_dur + curr_pc + value(GODur);
        sound_uploaded.value = 0;
        go_dur.value = value(GODur);

    case 'upload'
        if value(sound_uploaded)==1, return; end;
        %	if strcmp(value(sound_type),'stereo')
        rpbox('loadrp3stereosound1', {value(sound_data)});
        %       else
        %	    rpbox('loadrp3sound1', {value(sound_data)});
        %       end;
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
        %%% SP: You were trying to figure out how to get vpd_list in here
        %%% to compute your prechord_list.
        tlen = value(Trial_Length);

        % get entire array of tone_duration
        dummy = protocolobj('empty');
        left = get_generic(dummy, 'side_list_left');
        tone_list = side_list;

        left_ind = find(side_list == left);
        tone_list(left_ind) = Tone_Dur_L;
        %   tone_list(find(side_list == left)) = value(Tone_Dur1);

        right_ind = find(side_list ~= left);
        tone_list(right_ind) = Tone_Dur_R;
        %   tone_list(find(side_list ~= left)) = value(Tone_Dur2);

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

%     case 'update_tone_schedule'
%         % first Tone 1
%         if strcmp(value(Tone1_random), 'on')
%             set(get_ghandle(Tone1_from), 'Enable', 'inactive');
%             set(get_ghandle(Tone1_to), 'Enable', 'inactive');
%             set(get_ghandle(Tone_Dur1), 'Enable', 'off');
% 
%             Tone1_from.value = value(Tone_Dur1);
%             Tone1_to.value =   sqrt(value(Tone_Dur1) * value(Tone_Dur2));
%         else
%             set(get_ghandle(Tone1_from), 'Enable', 'off');
%             set(get_ghandle(Tone1_to), 'Enable', 'off');
%             set(get_ghandle(Tone_Dur1), 'Enable', 'on');
%         end;
% 
%         % then Tone 2
%         if strcmp(value(Tone2_random), 'on')
%             set(get_ghandle(Tone2_from), 'Enable', 'inactive');
%             set(get_ghandle(Tone2_to), 'Enable', 'inactive');
%             set(get_ghandle(Tone_Dur2), 'Enable', 'off');
% 
%             Tone2_from.value = sqrt(value(Tone_Dur1) * value(Tone_Dur2));
%             Tone2_to.value =   value(Tone_Dur2);
%         else
%             set(get_ghandle(Tone2_from), 'Enable', 'off');
%             set(get_ghandle(Tone2_to), 'Enable', 'off');
%             set(get_ghandle(Tone_Dur2), 'Enable', 'on');
%         end;

%     case 'update_tones'
%         commence = n_started_trials+1; fin = length(tone1_list);
% 
%         if strcmp(value(Tone1_random), 'on')
%             % update tone 1
%             if value(Tone1_from) > value(Tone1_to)
%                 Tone1_to.value = value(Tone1_from);
%             end;
%             new_tones = ( rand(1,fin-commence+1) * (value(Tone1_to) - value(Tone1_from)) ) + value(Tone1_from);
%             tone1_list(commence:fin) = new_tones;
%         else
%             tone1_list(commence:fin) = value(Tone_Dur1);
%         end;
% 
%         % now update tone 2
%         if strcmp(value(Tone2_random), 'on')
%             if value(Tone2_from) > value(Tone2_to)
%                 Tone2_to.value = value(Tone2_from);
%             end;
%             new_tones = ( rand(1,fin-commence+1) * (value(Tone2_to) - value(Tone2_from)) )  + value(Tone2_from);
%             tone2_list(commence:fin) = new_tones;
%         else
%             tone2_list(commence:fin) = value(Tone_Dur2);
%         end;

    otherwise
        error(['Don''t know how to handle action ' action]);
end;

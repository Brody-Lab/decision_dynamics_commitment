function [x, y, ...
    sound_len, error_len, tone1_list, tone2_list, prechord_list, go_dur, ...
    LegalSkipOut, Granularity, volume_factor] = ChordSection(obj, action, x, y)

GetSoloFunctionArgs;
% Read-only: maxtrials, n_started_trials, n_done_trials, side_list
% Read-write: super

% Generates non-penalty / non-ITI sounds for this protocol
% For duration_discobj, the method generates the following sound matrix:
% 0. A period of silence (pre-sound time) +
% 1. A tone of short/long duration +
% 2. Silence before the GO signal +
% 3. the GO signal itself.
%
% These three sounds are generated in one matrix because the current rig
% limits us to using only three sounds (two of which are used for ITI and
% the BadBoy sound).

switch action,
    case 'init'
        addpath('Analysis/duration_disc');
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

        % GO signal parameters
        next_column(x);
        next_row(y, 0.5);
        MenuParam(obj, 'GO_Loc', {'on', 'off'}, 1, x, y, 'label', 'Localise GO', 'TooltipString', '"on": GO only on reward side, "off": Surround-sound'); next_row(y);
        EditParam(obj, 'GODur', 0.3, x, y, 'label', 'GO Duration', 'TooltipString', 'Length of GO signal sound (in secs)'); next_row(y);
        EditParam(obj, 'SoundSPL', 60, x, y, 'label','GO SPL', 'TooltipString', 'Sound intensity / Volume'); next_row(y);
        EditParam(obj, 'BaseFreq',  1, x, y, 'label', 'GO Frequency', 'TooltipString', 'Starting pitch (in KHz) of GO chord');   next_row(y);
        EditParam(obj, 'ValidSoundTime', 0.03, x, y, 'label', 'Leave-after-GO', 'TooltipString', 'Time (in secs) after the onset of GO signal\nthat the rat may leave without penalty'); next_row(y);
        SubheaderParam(obj, 'snd_gen', 'GO Signal', x, y);next_row(y,2);

        % SPL randomization max and min
        ToggleParam(obj,'SPLmix', 0, x,y, ...
            'OnString', 'SPL Randomization ON', 'OffString', 'SPL Randomization OFF', 'OffFontWeight', 'normal');
        next_row(y);
        NumeditParam(obj,'SPL_min', 60, x, y, 'label', 'Min', 'TooltipString', 'Minimum SPL used in randomization','labelfraction', 0.7);
        NumeditParam(obj,'SPL_max',75, x+100,y, 'label','Max','TooltipString', 'Maximum SPL used in randomization','labelfraction',0.7);
        next_row(y);
        set(get_ghandle(SPL_min), 'Enable','off');
        set(get_ghandle(SPL_max), 'Enable', 'off');

        x = col1_x;
        y = base_y;
        % Params for localization and trial structure
        next_row(y, 0.5);
        MenuParam(obj, 'Tone_Loc', {'on', 'off'}, 1, x, y, 'label', 'Localise Tone', 'TooltipString', '"on": Cue is localised'); next_row(y);
        next_row(y,0.5);
        EditParam(obj, 'HzdRt_2_GO', 0.01, x, y, 'label', 'Pre-GO (Hzd Rt)', 'TooltipString', 'Defines distribution of silent time before GO signal'); next_row(y);
        EditParam(obj, 'Max_2_GO', 0, x, y, 'label', 'Pre-GO (Max)', 'TooltipString', 'Upper-bound silence before GO signal (in secs)'); next_row(y);
        EditParam(obj, 'Min_2_GO', 0, x, y, 'label', 'Pre-GO (Min)', 'TooltipString', 'Lower-bound silence before GO signal (in secs)'); next_row(y);

        set(get_ghandle(Min_2_GO), 'Enable', 'off');
        set(get_ghandle(Max_2_GO), 'Enable', 'off');
        set(get_ghandle(HzdRt_2_GO), 'Enable', 'off');


        % RELEVANT TONE begins here --------------
        next_row(y, 0.5);
        EditParam(obj, 'Tone_Freq', 10.0, x, y, 'label', 'Tone Frequency', 'TooltipString', 'Frequency (in KHz) of sample tone'); next_row(y);
        EditParam(obj, 'Tone_SPL', 30, x, y, 'label', 'Tone SPL', 'TooltipString', 'Sound intensity/volume of sample tones'); next_row(y);

        next_row(y);
        DispParam(obj,'tone_extent', 'blah blah', x, y, 'labelfraction', 0.01); next_row(y);
        halvsies = gui_position('get_default_width')/2; gui_position('set_width', halvsies);
        next_row(y,0.5);

        % here be controls for vanilla set training
        EditParam(obj, 'MP', 316.23, x, y, 'label', 'StdInt', 'labelfraction', 0.4, ...
            'TooltipString', 'The geometric mean of the endpoints; used to vanilla train animals before psychometric sampling');
        col1_x = x; next_column(x);
        MenuParam(obj, 'logdiff', {[1:-0.05:0.2]}, 1, x, y, 'label', 'LogDiff', 'labelfraction', 0.4, ...
            'TooltipString', 'Sets the log-distance separation of the LHS and RHS tone durations');
        SoloParamHandle(obj, 'duration_sets', 'value', 0);


        gui_position('reset_width');
        next_row(y,1.5); x = col1_x;
        this_y = y;
        ToggleParam(obj,'vanilla_on', 0, x, y, ...
            'OnString', 'Vanilla training', 'OffString', 'Initial endpoints', 'OffFontWeight', 'normal');
        next_row(y, 1.5);
        EditParam(obj, 'Tone_Dur2', 0.5, x, y, 'label', 'RIGHT Duration', 'TooltipString', 'Duration of tone for RIGHT trials(in secs)');        next_row(y);
        EditParam(obj, 'Tone_Dur1', 0.2, x, y, 'label', 'LEFT Duration', 'TooltipString', 'Duration of tone for LEFT trials(in secs)');        next_row(y);
        SoloParamHandle(obj, 'Tone1_from', 'value', value(Tone_Dur1));
        SoloParamHandle(obj, 'Tone1_to', 'value', value(Tone_Dur1));
        SoloParamHandle(obj, 'Tone2_from', 'value', value(Tone_Dur2));
        SoloParamHandle(obj, 'Tone2_to', 'value', value(Tone_Dur2));

        next_row(y,0.5);

        SubheaderParam(obj, 'snd_spf', 'Tone Duration', x, y); next_row(y, 1.5);
        SubheaderParam(obj, 'snd_status', '0', x, y);next_row(y,1.5);
        SubheaderParam(obj, 'block_status','off',x,y);
        set(get_ghandle(block_status),'BackgroundColor','g','FontSize',14);
        g = get_ghandle(snd_status); set(g,'BackgroundColor', [1 0.6 0.6], 'FontWeight','normal');

        next_column(x);
        y = this_y;
        ToggleParam(obj, 'psych_on', 0, x, y, ...
            'OnString', 'Psychometric sampling ON', 'OffString', 'Psychometric sampling OFF', 'OffFontWeight', 'normal');
        next_row(y);
        ToggleParam(obj, 'binsamp_on', 0, x, y, ...
            'OnString', 'Bin tones only', ...
            'OffString', 'Randomly-sampled tones', ...
            'OffFontWeight','normal');

        % Trial-start sound and Granularity stuff
        next_row(y);
        NumeditParam(obj,'volume_factor',0.08,x,y,'label','Volume Factor','TooltipString', sprintf('\nValue range:[0-1]\n1: Full speaker output, 0: No speaker output. Linear scaling'));next_row(y);
        set_callback(volume_factor,{'make_and_upload_state_matrix','update_wn_sound'; ...
            'make_and_upload_state_matrix','update_bb_sound'; ...
            'ChordSection','make'});
        MenuParam(obj, 'Cluck', {'on','off'}, 2, x, y, 'label', 'Trial Start Sound', 'TooltipString', '\nWhen on, plays ''cluck'' sound on initiatory poke');
        next_row(y);
        NumeditParam(obj, 'LegalSkipOut', 75, x, y, 'TooltipString', ...
            sprintf(['\nTime, in milliseconds, that rat can\n' ...
            'move out of Center port without incurring\n' ...
            'in a TimeOut. If he moves back in before\n' ...
            'this number of ms elapses, all is well.']));
        next_row(y);
        NumeditParam(obj, 'Granularity', 25, x, y, 'TooltipString', ...
            sprintf(['\nResolution, in milliseconds, with which\n' ...
            'time is counted for Center Poke/Skip Out purposes.']));
        set(get_ghandle(Granularity), 'Enable', 'off');
        next_row(y); next_row(y,0.5);
        SubheaderParam(obj, 'other_sbh', 'Other', x, y);

        % FIGURE-specific and unseen SPHs ---------------
        set(value(chordfig), ...
            'Visible', 'off', 'MenuBar', 'none', 'Name', 'Chord Parameters', ...
            'NumberTitle', 'off', 'CloseRequestFcn', ...
            ['ChordSection(' class(obj) '(''empty''), ''chord_param_hide'')']);
        set(value(chordfig), 'Position', [836 485 418 400]);

        x = parentfig_x; y = parentfig_y; figure(fig);  % make master protocol figure gcf
        MenuParam(obj, 'ChordParameters', {'hidden', 'view'}, 1, x, y); next_row(y);
        set_callback({ChordParameters}, {'ChordSection', 'chord_param_view'});

        SoloParamHandle(obj, 'sound_data');    % raw sound matrix
        SoloParamHandle(obj, 'error_sound');
        SoloParamHandle(obj, 'error_len');
        SoloParamHandle(obj, 'sound_len');     % length (in seconds)
        SoloParamHandle(obj, 'sound_uploaded', 'value', 0);
        SoloParamHandle(obj, 'go_dur', 'value', 0);	% duration of GO signal

        % All the variable sound elements
        SoloParamHandle(obj, 'tone1_list', 'value', zeros(1,value(maxtrials)) ); % Potentially variable tone1 durations
        SoloParamHandle(obj, 'tone2_list', 'value', zeros(1,value(maxtrials)) ); % Potentially variable tone2 durations
        SoloParamHandle(obj, 'tones_list', 'value', zeros(1,value(maxtrials)) ); % Tone Durations for block trials only
        SoloParamHandle(obj, 'spl_list', 'value', zeros(1,value(maxtrials)) ); % Potentially variable tone intensities
        SoloParamHandle(obj, 'prechord_list', 'value', zeros(1,value(maxtrials)) );  % Variable preGO durations
        SoloParamHandle(obj, 'num_bins', 'value', 8);    % used to generate tones in 'bin sampling only' situation
        SoloParamHandle(obj, 'yesterdays_setting', 'value', 0); % placeholder var to accommodate different ramp rates for review vs. new lesson

        % CALLBACKS ------------------------
        set_callback({Tone_SPL}, {'ChordSection','randomize_SPL'; 'ChordSection','make'});
        set_callback({ Tone_Freq, Tone_Loc, ...
            SoundSPL, BaseFreq, GODur, GO_Loc, ValidSoundTime, ...
            Cluck}, ...
            {'ChordSection','make'});

        set_callback({SPLmix, SPL_min, SPL_max}, {'ChordSection', 'randomize_SPL'});

        set_callback(vanilla_on, {'ChordSection', 'switch2vanilla'});
        set_callback(MP, {'ChordSection', 'get_new_logdiffs'});
        set_callback(logdiff,  {'ChordSection', 'change_vanilla_set'});
        set_callback(psych_on, {'ChordSection', 'update_tone_schedule'; 'ChordSection', 'update_tones'; 'ChordSection', 'make' });
        set_callback(binsamp_on, {'ChordSection', 'update_tones_bins_only'; 'ChordSection', 'make'});
        set_callback({Tone_Dur1,Tone_Dur2}, {'ChordSection', 'update_prechord'; 'ChordSection', 'update_tones'; 'ChordSection', 'make'});
        set_callback({Tone1_from, Tone1_to, Tone2_from, Tone2_to}, {'ChordSection', 'update_tones'; 'ChordSection', 'make'});
        set_callback({Min_2_GO, Max_2_GO, HzdRt_2_GO}, {'ChordSection', 'set_future_prechord'; 'ChordSection', 'make'});

        ChordSection(obj, 'switch2vanilla');
        ChordSection(obj, 'update_prechord');
        ChordSection(obj, 'update_tone_schedule');
        ChordSection(obj, 'update_tones');
        ChordSection(obj, 'randomize_SPL');
        ChordSection(obj, 'make');
        ChordSection(obj, 'upload');

    case 'make'
        left = get_generic('side_list_left');
        srate = get_generic('sampling_rate');

        % Part 0: Pre-sound tone
        prst = vpd_list(n_done_trials+1);   % this is in seconds
        pre_sound = zeros(1, floor(prst*srate));
        if strcmp(value(Cluck),'on')
            cluck_sound = MakeCluck;
            pre_sound(1,1:length(cluck_sound)) = cluck_sound;   % put cluck at start of pre-sound time.
        end;
        pre_sound = [ pre_sound' pre_sound'];

        % Part 1: The prolonged tone
        if value(Blocks_Switch) >0
            tone_dur = tones_list(n_done_trials+1)*1000;
            if n_done_trials ==0
               tone_dur = 500;
            end;
            if side_list(n_done_trials+1) == left
                tone1_list(n_done_trials+1) = tone_dur / 1000;
                tone2_list(n_done_trials+1) = 0;
                 snd_string = sprintf('Left: (%2.1f KHz for %3.2fms)', value(Tone_Freq), tone_dur);
            else
                tone2_list(n_done_trials+1) = tone_dur / 1000;
                tone1_list(n_done_trials+1) = 0;
                               snd_string = sprintf('Right: (%2.1f KHz for %3.2fms)', value(Tone_Freq), tone_dur);
            end;
        else
            if side_list(n_done_trials+1) == left
                tone_dur = tone1_list(n_done_trials+1) * 1000;
                snd_string = sprintf('Left: (%2.1f KHz for %3.2fms)', value(Tone_Freq), tone_dur);
            else
                tone_dur = tone2_list(n_done_trials+1) * 1000;
                snd_string = sprintf('Right: (%2.1f KHz for %3.2fms)', value(Tone_Freq), tone_dur);
            end;
        end;
        if tone_dur > 0
            main_tone_L = MakeChord2(srate, 70-spl_list(n_done_trials+1), Tone_Freq*1000, 1, tone_dur, ...
                'RiseFall', value(RampDur)*1000,'volume_factor',value(volume_factor));
            main_tone_R = MakeChord2(srate, 70-spl_list(n_done_trials+1), Tone_Freq*1000, 1, tone_dur, ...
                'RiseFall',value(RampDur)*1000,'volume_factor',value(volume_factor));
        else
            main_tone_L = 0; main_tone_R = 0;
        end;
        set(get_ghandle(snd_status), 'String', snd_string);
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
        space = zeros(1, floor(curr_pc*srate));
        space = [space' space'];

        % Part 3: GO signal
        gosig_L = MakeChord2(srate, 70-SoundSPL, 1000, value(NTones), ...
            value(GODur)*1000, 'RiseFall',value(RampDur)*1000,'volume_factor',value(volume_factor));
        gosig_R = MakeChord2(srate, 70-SoundSPL, 1000, value(NTones), ...
            value(GODur)*1000, 'RiseFall',value(RampDur)*1000,'volume_factor',value(volume_factor));
        if strcmp(value(GO_Loc), 'on')                % localise GO signal means everybody is in stereo
            if side_list(n_done_trials+1) == left
                gosig = [gosig_L' zeros(length(gosig_L), 1)];
            else
                gosig = [zeros(length(gosig_R), 1) gosig_R'];
            end;
        else
            gosig = [gosig_L' gosig_R'];
        end;

        % Finally, set the value
        sound_data.value = [pre_sound; main_tone; space; gosig]; % row matrices
        % values are in seconds
        sound_len.value = prst + tone_dur + curr_pc + value(GODur);
        sound_uploaded.value = 0;
        go_dur.value = value(GODur);

        % Construct the error sound
        errsnd = MakeChord2(srate, 70-67, 17*1000, 8, 300, ...
            'RiseFall',value(RampDur)*1000, 'volume_factor',value(volume_factor));
        error_sound.value = [errsnd' errsnd']';
        error_len.value = 0.3;

    case 'upload'
        if value(sound_uploaded)==1, return; end;
        global fake_rp_box;
        if fake_rp_box == 2
            sound_data.value = value(sound_data)';
            LoadSound(rpbox('getsoundmachine'),1, value(sound_data), 'both', 3,0);
            LoadSound(rpbox('getsoundmachine'),4, value(error_sound), 'both',3,0);
        else
            rpbox('loadrp3stereosound1', {value(sound_data)});
        end;
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

        pc = value(prechord_list);
        if Min_2_GO > Max_2_GO
            Max_2_GO.value = value(Min_2_GO);
        end;
        len = length(pc)-(n_started_trials+1)+1;

        list = generate_variability(value(Min_2_GO), value(Max_2_GO), HzdRt_2_GO, len);
        pc(n_started_trials+1:length(pc)) = list;
        prechord_list.value = pc;
    case 'update_prechord'
        set(get_ghandle(Min_2_GO), 'Enable', 'on');
        set(get_ghandle(Max_2_GO), 'Enable', 'on');
        set(get_ghandle(HzdRt_2_GO), 'Enable', 'on');
        ChordSection(obj, 'set_future_prechord');

    case 'update_tone_schedule'
        % Simply activates/inactivates the tone1_from/to textboxes
        % if strcmp(value(Tone1_random), 'on')
        if value(psych_on) > 0
            set(get_ghandle(Tone_Dur1), 'Enable', 'off');
            Tone1_from.value = value(Tone_Dur1);
            Tone1_to.value =   sqrt(value(Tone_Dur1) * value(Tone_Dur2));
            % then make tone 2
            set(get_ghandle(Tone_Dur2), 'Enable', 'off');
            Tone2_from.value = sqrt(value(Tone_Dur1) * value(Tone_Dur2));
            Tone2_to.value =   value(Tone_Dur2);

            set(get_ghandle(tone_extent), 'String', sprintf('L: %3.1f - %3.1fms; R: %3.1f - %3.1fms', value(Tone1_from)*1000, ...
                value(Tone1_to) * 1000, value(Tone2_from) * 1000, value(Tone2_to)*1000));
        else
            set(get_ghandle(Tone_Dur1), 'Enable', 'on');
            set(get_ghandle(Tone_Dur2), 'Enable', 'on');
            set(get_ghandle(tone_extent), 'String', sprintf('L: %3.1f ms only; R: %3.1fms only', value(Tone_Dur1)*1000, value(Tone_Dur2)*1000));
        end;

    case 'update_tones'
        commence = n_started_trials+1; fin = length(tone1_list);
        t1from = log(value(Tone1_from)); t1to = log(value(Tone1_to));
        t2from = log(value(Tone2_from)); t2to = log(value(Tone2_to));

        if value(psych_on) > 0
            if value(binsamp_on)>0 && value(n_done_trials) > 0,
                ChordSection(obj, 'update_tones_bins_only');
                return;
            end;
            %        if strcmp(value(Tone1_random), 'on')
            % update tone 1
            if value(Tone1_from) > value(Tone1_to), Tone1_to.value = value(Tone1_from);end;
            new_tones = ( rand(1,fin-commence+1) * (t1to - t1from) ) + t1from;
            tone1_list(commence:fin) = exp(new_tones);
            % now update tone 2
            if value(Tone2_from) > value(Tone2_to), Tone2_to.value = value(Tone2_from);end;
            new_tones = (rand(1,fin-commence+1) * (t2to - t2from) ) + t2from;
            tone2_list(commence:fin) = exp(new_tones);
        else
            tone1_list(commence:fin) = value(Tone_Dur1);
            tone2_list(commence:fin) = value(Tone_Dur2);
        end;

    case 'update_tones_bins_only'
        if value(psych_on) == 0, return; end;

        if value(psych_on) == 0,
            error('Shouldn''t be here if psychometric sampling isn''t on!');
        end;
        if value(binsamp_on) > 0
            bin_no = value(num_bins);
            commence = n_started_trials+1; fin = length(tone1_list);
            [dummy bins] = generate_bins(value(Tone1_from) *1000, value(Tone2_to) * 1000, value(num_bins)-1);
            mp = sqrt(bins(1) * bins(end));
            trials = (fin-commence)+1; out = zeros(1, trials);

            ctr = 1;
            for k = 1:floor(trials/bin_no)
                out(ctr:ctr+(bin_no-1)) = bins(randperm(bin_no));
                ctr = ctr + bin_no;
            end;
            leftie = find(out <= mp); rightie = find(out>mp);
            indL = leftie + (commence-1); indR = rightie+ (commence-1);

            if indL(1) < commence | indR(1) < commence
                error('Uh oh, about to overwrite past tone indices!');
            end;

            tone1_list(indL) = out(leftie) / 1000; tone1_list(indR) = 0;
            tone2_list(indR) = out(rightie) / 1000; tone2_list(indL) = 0;

            % now update the sides ...ever...so...carefully
            sl = zeros(1,trials); indL = indL - (commence-1); indR = indR - (commence-1);
            left = get_generic('side_list_left');
            sl(indL) = left; sl(indR) = 1-left;
            SidesSection(value(super), 'fix_future_sides', sl);
        else
            ChordSection(obj,'update_tones');
            SidesSection(obj,'set_future_sides');
        end;

    case 'get_new_logdiffs'
        duration_sets.value = get_new_duration_sets(value(MP));
        temp = value(duration_sets);
        set(get_ghandle(logdiff),'String', {temp(:,3)});
        %        logdiff.value = 0.6;    % arbitrary new value.
        ChordSection(obj, 'change_vanilla_set');
    case 'change_vanilla_set'
        if value(vanilla_on) > 0
            temp = value(duration_sets); ind = 0;
            if temp == 0, return; end;
            for k=1:length(temp(:,3)), if strcmp(num2str(temp(k,3)), num2str(value(logdiff))), ind = k; end;end;
            Tone_Dur1.value = temp(ind,1)/1000;
            Tone_Dur2.value = temp(ind,2)/1000;

            ChordSection(obj, 'update_tones');
            ChordSection(obj, 'make');
        end;
    case 'switch2vanilla'
        if value(vanilla_on) > 0
            set(get_ghandle(MP), 'Enable', 'on'); set(get_ghandle(logdiff), 'Enable', 'on');
            set(get_ghandle(Tone_Dur1), 'Enable', 'off'); set(get_ghandle(Tone_Dur2), 'Enable','off');
            trials_since_last_chng.value = 0;
            ChordSection(obj, 'get_new_logdiffs');
        else
            set(get_ghandle(MP), 'Enable', 'off'); set(get_ghandle(logdiff), 'Enable', 'off');
            set(get_ghandle(Tone_Dur1), 'Enable', 'on'); set(get_ghandle(Tone_Dur2), 'Enable','on');
        end;

    case 'randomize_SPL',
        str = 'off'; antistr = 'on'; if value(SPLmix) > 0, str='on'; antistr='off'; end;
        set(get_ghandle(SPL_min), 'Enable',str);
        set(get_ghandle(SPL_max), 'Enable', str);
        set(get_ghandle(Tone_SPL), 'Enable', antistr);

        commence = n_started_trials+1; fin = length(spl_list);
        if value(SPLmix) > 0
            splmin = value(SPL_min); splmax = value(SPL_max);
            if value(splmin) > value(splmax), SPL_max.value = value(SPL_min); end;

            spl_list(commence:fin) = ( rand(1,fin-commence+1) * (splmax - splmin) ) + splmin;
        else
            spl_list(commence:fin) = value(Tone_SPL);
        end;

    case 'make_blocks',
        starting_at = n_started_trials+1;
        flist = {'Tone_Dur1','Tone_Dur2','psych_on','vanilla_on'};

        b = get_ghandle(block_status);

        if value(Blocks_Switch) == 0

            tones_list(starting_at:end) = 0;
            ChordSection(obj,'update_tone_schedule');
            for idx=1:length(flist)
                set(get_ghandle(eval(flist{idx})), 'Enable','on');
            end;
            set(b,'BackgroundColor','g',...
                'String','Regular tone schedule', 'FontWeight','normal');
            return;
        end;
        set(b,'BackgroundColor','r',...
            'String','BLOCK MODE','FontWeight','bold');

        for idx=1:length(flist)
            set(get_ghandle(eval(flist{idx})), 'Enable','off');
        end;

        starting_at = n_started_trials+1;
        binmin = value(Tone_Dur1)*1000;
        binmax = value(Tone_Dur2)*1000;
        sl = side_list;

        % Building block START >>--------------
        n2m = value(Num2Make);
        blocksize = sum(n2m);
        numbins = value(Num_Bins);

        trials_left = (maxtrials-starting_at)+1;
        blocks_left = round(floor(trials_left) / blocksize);
        rem = trials_left - (blocks_left * blocksize);
        % << END BUilding blocks ---------------

        bins = generate_bins(binmin, binmax, numbins,'pitches',0);
        logbins = log(bins);logmin = log(binmin);
        logmax =log(binmax);

        sidx = starting_at;
        temp_list = tones_list;
        curr_block = {};
        for blocknum = 1:blocks_left
            eidx = (sidx+blocksize)-1;
   %         fprintf(1,'%i: %i to %i\n', blocknum, sidx, eidx);
            final_block=block_maker(logmin,logmax, logbins, n2m,sl(sidx:eidx));
            temp_list(sidx:eidx) = final_block;
            curr_block{end+1} = final_block;
            sidx = eidx+1;
        end;

        
       final_block=block_maker(logmin,logmax, logbins, n2m,sl(eidx+1:end));
        temp_list(eidx+1:end) = final_block;

        fprintf(1,'Blocking tones list ...\n');
        tones_list.value = exp(value(temp_list)) / 1000;

    otherwise
        error(['Don''t know how to handle action ' action]);
end;

% generates tones for a given block
function [final_block] = block_maker(logmin,logmax, logbins, n2m,sl)

numbins= length(logbins);
block_tones = [];

% make the tones to be presented in the block
for idx=1:numbins
    if idx == 1, bin_from = logmin;
    else bin_from = (logbins(idx-1)+logbins(idx))/2; end;

    if idx == numbins, bin_to = logmax;
    else bin_to = (logbins(idx)+logbins(idx+1))/2; end;

    new_tones = (rand(1,n2m(idx)) * (bin_to - bin_from) ) + bin_from;
    block_tones = horzcat(block_tones, new_tones);
end;

% now permute the tones.
left_trials = sum(n2m(1:numbins/2));
right_trials = sum(n2m((numbins/2)+1:numbins));

left_tones = block_tones(1:left_trials);
mix = randperm(length(left_tones));
left_tones = left_tones(mix);

right_tones = block_tones(left_trials+1:end);
mix = randperm(length(right_tones));
right_tones = right_tones(mix);

% now stitch the mixed tones together using the mixed sides list
final_block = zeros(size(sl));
final_block(find(sl > 0)) = left_tones(1:length(find(sl>0)));
final_block(find(sl==0)) = right_tones(1:length(find(sl==0)));

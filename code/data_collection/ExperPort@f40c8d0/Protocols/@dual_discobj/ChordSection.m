function [x, y, ...
    sound_len, error_len, tone1_list, tone2_list, prechord_list, go_dur, ...
    LegalSkipOut, Granularity,volume_factor] = ChordSection(obj, action, x, y)

GetSoloFunctionArgs;
% Read-only: maxtrials, n_started_trials, n_done_trials, side_list
% Read-write: super

% Generates non-penalty / non-ITI sounds for this protocol
% For duration_discobj, the method generates the following sound matrix:
% 1. A tone of short/long duration +
% 2. Silence before the GO signal +
% 3. the GO signal itself.
%
% For pitch discrimination, the method generates a low or high pitch and
% 2. and 3. as in duration discrimination.
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
        EditParam(obj, 'GODur', 0.1, x, y, 'label', 'GO Duration', 'TooltipString', 'Length of GO signal sound (in secs)'); next_row(y);
        next_row(y,0.5);
        EditParam(obj, 'SoundSPL', 0, x, y, 'label','GO SPL', 'TooltipString', 'Sound intensity / Volume'); next_row(y);
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
        EditParam(obj, 'HzdRt_2_GO', 0.01, x, y, 'label', 'Pre-GO (Hzd Rt)', 'TooltipString', 'Defines distribution of silent time before GO signal'); next_row(y);
        EditParam(obj, 'Max_2_GO', 0.3, x, y, 'label', 'Pre-GO (Max)', 'TooltipString', 'Upper-bound silence before GO signal (in secs)'); next_row(y);
        EditParam(obj, 'Min_2_GO', 0.3, x, y, 'label', 'Pre-GO (Min)', 'TooltipString', 'Lower-bound silence before GO signal (in secs)'); next_row(y);

        set(get_ghandle(Min_2_GO), 'Enable', 'off');
        set(get_ghandle(Max_2_GO), 'Enable', 'off');
        set(get_ghandle(HzdRt_2_GO), 'Enable', 'off');

        % RELEVANT TONE begins here --------------
        next_row(y, 0.5);
        % right tone
        EditParam(obj, 'Tone_OFF_Prob', 0.20, x, y, 'label', 'P(Tone SPL=0)', 'TooltipString', 'Probability of a catch trial in which cue intensity is switched completely off.'); next_row(y);        
        EditParam(obj, 'Tone_SPL', 70, x, y, 'label', 'Tone SPL', 'TooltipString', 'Sound intensity/volume of sample tone'); next_row(y);
        EditParam(obj, 'Tone_Dur_R', 0.35, x, y, 'label', 'Tone Duration (R)', 'TooltipString', 'Duration (in sec) of sample tone (RIGHT)'); next_row(y);
        EditParam(obj, 'Tone_Freq_R', 16, x, y, 'label', 'Tone Frequency (R)', 'TooltipString', 'Frequency (in KHz) of sample tone'); next_row(y,1.5);

        % SPL randomization max and min
        col1 = x; next_column(x);
        ypos = y;
        ToggleParam(obj,'SPLmix', 0, x,y, ...
            'OnString', 'SPL Randomization ON', 'OffString', 'SPL Randomization OFF', 'OffFontWeight', 'normal');
        next_row(y);
        NumeditParam(obj,'SPL_min', 60, x, y, 'label', 'Min', 'TooltipString', 'Minimum SPL used in randomization','labelfraction', 0.7);
        NumeditParam(obj,'SPL_max',75, x+100,y, 'label','Max','TooltipString', 'Maximum SPL used in randomization','labelfraction',0.7);
        next_row(y);
        set(get_ghandle(SPL_min), 'Enable','off');
        set(get_ghandle(SPL_max), 'Enable', 'off');
        next_row(y);

        SubheaderParam(obj, 'snd_status', '0', x, y); next_row(y,1.5);

        x = col1;

        g = get_ghandle(snd_status); set(g,'BackgroundColor', [1 0.6 0.6], 'FontWeight','normal');
        next_row(y);
        next_row(y,0.5);

        x = col1; y = ypos;


        EditParam(obj, 'Tone_Dur_L', 0.35, x, y, 'label', 'Tone Duration (L)', 'TooltipString', 'Duration (in sec) of sample tone (LEFT)'); next_row(y);
        EditParam(obj, 'Tone_Freq_L', 8, x, y, 'label', 'Tone Frequency (L)', 'TooltipString', 'Frequency (in KHz) of sample tone');
        next_row(y);

        SubheaderParam(obj, 'snd_spf', 'Relevant Tone', x, y); next_row(y);
        x_upper = x; y_upper = y;



        % "OTHER" section ------------------

        %      MenuParam(obj, 'PD_Cue', {'Chirp', 'off'}, 1, x, y, 'label', 'PD Cue', 'TooltipString', ' "Chirp" plays a single chirp at the start of every pitch discrimination trial'); next_row(y);
        MenuParam(obj, 'Priming', {'Pitch', 'Duration', 'off'}, 3, x, y, 'label', 'Priming Sound', 'TooltipString', 'Plays sounds of different pitches/durations - used only when protocol is OFF (replaces main tone)'); next_row(y);
        set(get_ghandle(Priming), 'visible', 'off');
        set(get_lhandle(Priming),'visible','off');

        NumeditParam(obj,'volume_factor',0.08,x,y,'label','Volume Factor','TooltipString', sprintf('\nValue range:[0-1]\n1: Full speaker output, 0: No speaker output. Linear scaling'));next_row(y);
        set_callback(volume_factor,{'make_and_upload_state_matrix','update_wn_sound'; ...
            'make_and_upload_state_matrix','update_bb_sound'; ...
            'ChordSection','make'});

        MenuParam(obj, 'Task_Type', {'Pitch Disc', 'Duration Disc'}, 1, ...
            x, y, 'label', 'Task Type', 'TooltipString', 'Set to have trials of either pitch discrimination or duration discrimination');
        set(get_ghandle(Task_Type), 'Enable','off');
        next_row(y);

        MenuParam(obj, 'Cluck', {'on','off'}, 2, x, y, 'label', 'Trial Start Sound', 'TooltipString', '\nWhen on, plays ''cluck'' sound on initiatory poke');
        next_row(y,1.5);
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

        SubheaderParam(obj, 'other_sbh', 'Other', x, y); next_row(y);

        SubheaderParam(obj, 'block_status','off',x,y); next_row(y,1.5);
        set(get_ghandle(block_status),'BackgroundColor','g','FontSize',14);
        SubheaderParam(obj, 'snd_status', '0', x, y); next_row(y,1.5);



        % PSYCHOMETRIC section -------------------
        x = x_upper; next_column(x);
        y = y_upper;
        ToggleParam(obj,'right_is_low', 0, x, y, ...
            'OnString', 'Go RIGHT for "short"', 'OffString', 'Go LEFT for "short"', 'OffFontWeight','normal');
        set_callback({right_is_low}, {'ChordSection', 'make'});
        next_row(y);
        ToggleParam(obj, 'pitch_psych', 0, x, y, ...
            'label','PD Psychometric', ...
            'TooltipString', 'Turns on pitch sampling to determine psychometric threshold');
        g = get_ghandle(pitch_psych);
        set_callback({pitch_psych}, {'ChordSection','sample_pitches'});

        next_row(y,1.5);

        SubheaderParam(obj, 'psych_sbh', 'Psychometric Sampling', x, y); next_row(y);


        % VANILLA NARROWING section ---------------------
        % here be controls for vanilla set training
        ToggleParam(obj,'vanilla_on', 0, x, y, ...
            'OnString', 'Vanilla training', 'OffString', 'Initial endpoints', 'OffFontWeight', 'normal');
        next_row(y, 1.5);

        EditParam(obj, 'MP', 11.31, x, y, 'label', 'StdInt', 'labelfraction', 0.4, ...
            'TooltipString', 'The geometric mean of the endpoints; used to vanilla train animals before psychometric sampling');
        next_row(y);
        %        col1_x = x; next_column(x);
        NumeditParam(obj, 'logdiff', 1, x, y, 'label', 'Separation (Log)', 'labelfraction', 0.4, ...
            'TooltipString', 'Sets the log-distance separation of the LHS and RHS tone durations');
        next_row(y,1.5);
        SoloParamHandle(obj, 'pitch_sets', 'value', 0);

        SubheaderParam(obj, 'van_sbh', 'Vanilla Narrowing', x, y);

        % Section for generating FM WIGGLE stimuli -----------------------
        next_row(y,1.5);
        ToggleParam(obj,'wiggle_on', 0, x, y, ...
            'OnString', 'Turn OFF FM wiggle stim', 'OffString', 'Turn ON FM wiggle stim', 'OffFontWeight', 'normal');
        next_row(y);
        NumEditParam(obj, 'FM_freq', 10, x, y, 'label', 'FM freq', 'labelfraction', 0.7, ...
            'TooltipString', 'Stimulus will be modulated from:  (c-f) to (c+f) where c is cue frequence and f is this parameter, FM Frequency');
        EditParam(obj, 'FM_amp', 2, x+100, y, 'label', 'FM Amp', 'labelfraction', 0.7, ...
            'TooltipString', 'Controls rate of FM');

        next_row(y,1.5);
        SubheaderParam(obj, 'fm_sbh', 'FM Setting', x, y);
        set_callback({wiggle_on, FM_freq, FM_amp},  {'ChordSection', 'make'});



        % FIGURE-specific and unseen SPHs ---------------
        set(value(chordfig), ...
            'Visible', 'off', 'MenuBar', 'none', 'Name', 'Chord Parameters', ...
            'NumberTitle', 'off', 'CloseRequestFcn', ...
            ['ChordSection(' class(obj) '(''empty''), ''chord_param_hide'')']);
        set(value(chordfig), 'Position', [836   361   442   496]);

        x = parentfig_x; y = parentfig_y; figure(fig);  % make master protocol figure gcf
        MenuParam(obj, 'ChordParameters', {'hidden', 'view'}, 1, x, y); next_row(y);
        set_callback({ChordParameters}, {'ChordSection', 'chord_param_view'});

        SoloParamHandle(obj, 'sound_data', 'saveable',0);    % raw sound matrix
        SoloParamHandle(obj, 'sound_len');     % length (in seconds)
        SoloParamHandle(obj, 'error_sound','saveable',0);
        SoloParamHandle(obj, 'error_len');

        SoloParamHandle(obj, 'sound_uploaded', 'value', 0);
        %	SoloParamHandle(obj, 'sound_type', 'value', 'stereo');
        SoloParamHandle(obj, 'go_dur', 'value', 0);	% duration of GO signal

        % All the variable sound elements
        SoloParamHandle(obj, 'tone1_list', 'value', zeros(1,value(maxtrials)) ); % Potentially variable tone1 durations
        SoloParamHandle(obj, 'tone2_list', 'value', zeros(1,value(maxtrials)) ); % Potentially varaible tone2 durations
        SoloParamHandle(obj, 'pitch1_list', 'value', zeros(1,value(maxtrials)) );        
        SoloParamHandle(obj, 'pitch2_list', 'value', zeros(1,value(maxtrials)) );
        SoloParamHandle(obj, 'tones_list', 'value', zeros(1,value(maxtrials)) ); % Tone Durations for block trials only
        SoloParamHandle(obj,'effective_pitch','value',zeros(1,value(maxtrials))); % which pitch was presented? REquired when right-is-low flag is on
        SoloParamHandle(obj, 'spl_list', 'value', zeros(1,value(maxtrials)) );
        SoloParamHandle(obj, 'prechord_list', 'value', zeros(1,value(maxtrials)) );  % Variable preGO durations

        % CALLBACKS ------------------------
        set_callback({ Tone_Loc, SoundSPL, BaseFreq, ...
            GODur, GO_Loc, ValidSoundTime, Cluck}, ...
            {'ChordSection','make'});
        set_callback({Tone_Dur_L, Tone_Dur_R}, {'ChordSection', 'make'});
        set_callback({Min_2_GO, Max_2_GO, HzdRt_2_GO}, {'ChordSection', 'set_future_prechord'; 'ChordSection', 'make'});
        set_callback({Tone_Freq_L, Tone_Freq_R},{'ChordSection','sample_pitches'; 'ChordSection', 'make'});
        set_callback({Tone_SPL}, {'ChordSection','randomize_SPL'; 'ChordSection','make'});
        set_callback({SPLmix, SPL_min, SPL_max}, {'ChordSection', 'randomize_SPL'});

        set_callback(Task_Type, {'ChordSection', 'change_task_type'; 'ChordSection', 'make'});
        %      set_callback(PD_Cue, {'ChordSection', 'make'});
        set_callback(Priming, {'ChordSection', 'make_priming'});
        set_callback(vanilla_on, {'ChordSection', 'switch2vanilla'});
        set_callback(MP, {'ChordSection', 'get_new_logdiffs'});
        set_callback(logdiff,  {'ChordSection', 'get_new_logdiffs'});


        ChordSection(obj, 'switch2vanilla');
        ChordSection(obj, 'update_prechord');
        ChordSection(obj, 'sample_pitches');
        %         ChordSection(obj, 'update_tone_schedule');
        %         ChordSection(obj, 'update_tones');
        ChordSection(obj, 'randomize_SPL');
        ChordSection(obj, 'make');
        ChordSection(obj, 'upload');

    case 'make'               
        
        Tone_OFF_Prob.value=0;
        left = get_generic('side_list_left');
        srate = get_generic('sampling_rate');

        % Part 0: Pre-sound tone
        prst = vpd_list(n_done_trials+1);   % this is in seconds
        pre_sound = zeros(1, floor(prst*srate));
        if strcmp(value(Cluck),'on')
            if strcmp(value(Task_Type),'Pitch Disc')
                cluck_sound = MakeSwoop(srate, 3, 2000, 8000, 8, 4);
            else
                cluck_sound = MakeCluck;
            end;
            pre_sound(1,1:length(cluck_sound)) = cluck_sound;   % put cluck at start of pre-sound time.
        end;
        pre_sound = [ pre_sound' pre_sound'];
        
          if value(volume_factor) < 0.25, 
            volume_factor.value = 0.25;
        end;    

        upcoming_side = side_list(n_done_trials+1);
        stated_side = upcoming_side;
        % flip sides if flag is set
       if value(Blocks_Switch) == 0 % flip sides if flag is set ---                     
            if value(right_is_low) > 0, upcoming_side = 1-upcoming_side; end;     % sides only need to be flipped if creating a tone now. If the tone was premade
                                                                                  % as it is in Blocks Section, you don't need to flip sides
        end;
        
        if stated_side == left, sidetxt= 'Left'; else sidetxt='Right';end;

        % Part 1: The prolonged tone
        if value(Blocks_Switch)>0 % psychometric trials in blocks
            tone_pitch = tones_list(n_done_trials+1);        
                       
                temp = value(tone1_list);
                temp(n_done_trials+1:end) = value(Tone_Dur_L);
                tone1_list.value = temp;
            
                temp = value(tone2_list);
                temp(n_done_trials+1:end) = value(Tone_Dur_R);
                tone2_list.value = temp;
                
            if upcoming_side == left          
                tone_dur = value(Tone_Dur_L) * 1000;     
                pitch1_list(n_done_trials+1) = tone_pitch;
                pitch2_list(n_done_trials+1) =0; 
            else              
             tone_dur = value(Tone_Dur_R) * 1000;
                pitch2_list(n_done_trials+1) = tone_pitch;
                pitch1_list(n_done_trials+1) =0;           
            end;
        else
            if upcoming_side == left % non-psych trials
                tone_dur = value(Tone_Dur_L) * 1000;
                tone_pitch = pitch1_list(n_done_trials+1);%value(Tone_Freq_L);

                temp = value(tone1_list);
                temp(n_done_trials+1:end) = value(Tone_Dur_L);
                tone1_list.value = temp;
              
            else
                tone_dur = value(Tone_Dur_R) * 1000;
                tone_pitch = pitch2_list(n_done_trials+1); % value(Tone_Freq_R);

                temp = value(tone2_list);
                temp(n_done_trials+1:end) = value(Tone_Dur_R);
                tone2_list.value = temp;
              
            end;
        end;
          effective_pitch(n_done_trials+1) = tone_pitch;
          
        snd_string = sprintf('%s: (%2.1f KHz for %3.2fms)', sidetxt,tone_pitch, tone_dur);
        g = get_ghandle(snd_status); set(g, 'String', snd_string);
        
        if n_done_trials < 1,rand('twister', sum(100*clock));end; % reset state

        if tone_dur > 0
            if value(wiggle_on) > 0 % make FM wiggle stimulus
                fmfreq = value(FM_freq);
                fmamp = value(FM_amp);
                main_tone_L = MakeFMWiggle(srate, 70-spl_list(n_done_trials+1), tone_dur/1000, tone_pitch*1000, fmfreq, fmamp,...
                    value(RampDur)*1000, 'volume_factor',value(volume_factor));                
            else % pure tone
                main_tone_L = MakeChord2(srate, 70-spl_list(n_done_trials+1), tone_pitch*1000, 1, tone_dur, ...
                    'RiseFall',value(RampDur)*1000,'volume_factor',value(volume_factor));
            end;
          
            if rand < value(Tone_OFF_Prob)
                main_tone_L=zeros(size(main_tone_L));                                
                spl_list(n_done_trials+1)=0;
            end;  
            
            main_tone_R = main_tone_L;
            
        else
            main_tone_L = 0; main_tone_R = 0;
        end;
        tone_dur = tone_dur/1000;   % set back into seconds for addition
        if strcmp(value(Tone_Loc), 'on')
            if stated_side == left
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
        gosig_L = MakeChord2(srate, 70-SoundSPL, 1000, value(NTones), value(GODur)*1000, ...
            'RiseFall',value(RampDur)*1000,'volume_factor',value(volume_factor));
        gosig_R = MakeChord2(srate, 70-SoundSPL, 1000, value(NTones), value(GODur)*1000, ...
            'RiseFall',value(RampDur)*1000,'volume_factor',value(volume_factor));
        if strcmp(value(GO_Loc), 'on')                % localise GO signal means everybody is in stereo
            if stated_side == left
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
        sound_data.value = [pre_sound; main_tone; space; gosig]'; % row matrices
        sound_len.value = prst + tone_dur + curr_pc + value(GODur);
        %         end;
        sound_uploaded.value = 0;
        go_dur.value = value(GODur);

        % Construct the error sound
        errsnd = MakeChord2(srate, 70-67, 17*1000, 8, 300, ...
            'RiseFall', value(RampDur)*1000, 'volume_factor',value(volume_factor));
        error_sound.value = [errsnd' errsnd']';
        error_len.value = 0.3;

    case 'upload'
      if value(sound_uploaded)==1, return; end;
        global fake_rp_box;
        if fake_rp_box == 2
            LoadSound(rpbox('getsoundmachine'),1, value(sound_data), 'both', 3,0);
            LoadSound(rpbox('getsoundmachine'),4, value(error_sound), 'both',3,0);
        else
            rpbox('loadrp3stereosound__withid', value(sound_data), 1);
            rpbox('loadrp3stereosound__withid', value(error_sound), 4);
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
        if Min_2_GO > Max_2_GO
            Max_2_GO.value = value(Min_2_GO);
        end;
        len = length(prechord_list)-(n_started_trials+1)+1;

        list = generate_variability(value(Min_2_GO), value(Max_2_GO), HzdRt_2_GO, len);
        prechord_list(n_started_trials+1:length(prechord_list)) = list;

    case 'update_prechord'
        set(get_ghandle(Min_2_GO), 'Enable', 'on');
        set(get_ghandle(Max_2_GO), 'Enable', 'on');
        set(get_ghandle(HzdRt_2_GO), 'Enable', 'on');
        ChordSection(obj, 'set_future_prechord');

    case 'change_task_type'
        return; % Task-changing feature has been disabled; dual_discobj is
        % currently used solely for pitch discrimination
        if strcmpi(value(Task_Type),'Pitch Disc')   % set to pitch discrimination
            Tone_Dur_L.value = 0.3;
            Tone_Dur_R.value = 0.3;

            Tone_Freq_L.value = 1;
            Tone_Freq_R.value = 15;

        else                                        % set to duration discrimination
            Tone_Freq_L.value = sqrt(1*15);
            Tone_Freq_R.value = sqrt(1*15);

            Tone_Dur_L.value = 0.3;
            Tone_Dur_R.value = 0.8;
        end;

        ChordSection(obj, 'sample_pitches');        % pitches should reflect whatever the task is right now

    case 'make_priming'

        % stitching more sounds means adding more rows
        % columns refer to sound channels
        pitches = [1 10];
        tone_dur = Tone_Dur_L * 1000;

        low_pitch = 4*1000;
        high_pitch = 4*1000;
        low_dur = 0.3*1000;
        high_dur = 0.3*1000;

        play_pitch = 0;
        if strcmpi(value(Priming),'pitch')
            low_pitch = 1000;
            high_pitch = 10*1000;
        elseif strcmpi(value(Priming),'duration')
            low_dur = 0.3 * 1000;
            med_dur = 0.5 * 1000;
            high_dur = 1.0* 1000;
        end;

        if ~strcmpi(value(Priming),'off')
            dummy = protocolobj('empty');
            srate = get_generic('sampling_rate');

            tone_low = MakeChord2(srate, 70-spl_list(n_done_trials+1), low_pitch, 1, low_dur, ...
                'RiseFall',value(RampDur)*1000,'volume_factor',value(volume_factor)); % (1 x len)
            tone_high = MakeChord2(srate, 70-spl_list(n_done_trials+1), high_pitch, 1, high_dur, ...
                'RiseFall',value(RampDur)*1000,'volume_factor',value(volume_factor));

            space_dur = 0.4; space_len = space_dur * srate;
            space = zeros(1,floor(space_len));


            if strcmpi(value(Priming),'pitch')
                main_tone_unit = [tone_low space tone_high space];  % one unit
            elseif strcmpi(value(Priming), 'duration')
                tone_med = MakeChord2(srate,70-spl_list(n_done_trials+1), low_pitch, 1, med_dur, ...
                    'RiseFall',value(RampDur)*1000,'volume_factor',value(volume_factor));
                main_tone_unit = [tone_low space tone_high space tone_med space];  % one unit
            end;

            % put together multiple such units
            block_size = 5;
            main_tone_L = [main_tone_unit main_tone_unit main_tone_unit main_tone_unit main_tone_unit];
            main_tone_R = main_tone_L;
            main_tone = [main_tone_L' main_tone_R'];
            block_len = floor(size(main_tone_L, 2)/srate);

            % Now upload
            sound_data.value = main_tone;
            sound_len.value = block_len;
            sound_uploaded.value = 0;
            sound_uploaded.value = 0;
        else   % set regular tone
            ChordSection(obj,'make');
        end;

        ChordSection(obj,'upload');

    case 'sample_pitches'
        lower = value(Tone_Freq_L); higher = value(Tone_Freq_R);
        if lower > higher,
            lower = higher;
            Tone_Freq_L.value = value(Tone_Freq_R);
        end;

        mid = sqrt(lower*higher);
        % Scenarios in which you get to this state:
        % PD - sample off - 1 & 15
        % PD - sample on - all over
        % DD - sample off - 4 and 4
        % DD - sample on - 4 and 4

        if value(pitch_psych) > 0 && strcmpi(value(Task_Type),'Pitch Disc')
            lower = log2(lower); higher = log2(higher); mid = log2(mid);
            g = get_ghandle(pitch_psych); set(g, 'String', 'PD Psychometric ON', 'FontWeight','bold');

            % first the left - sample in log space
            temp = value(pitch1_list);
            temp(n_done_trials+1:end) = (rand(size(temp(n_done_trials+1:end))) * (mid-lower)) + lower;
            temp(n_done_trials+1:end) = 2.^(temp(n_done_trials+1:end));
            pitch1_list.value = temp;

            % then the right - sample in log space
            temp = value(pitch2_list);
            temp(n_done_trials+1:end) = (rand(size(temp(n_done_trials+1:end))) * (higher-mid)) + mid;
            temp(n_done_trials+1:end) = 2.^(temp(n_done_trials+1:end));
            pitch2_list.value = temp;
        else
            if value(pitch_psych) == 0
                g = get_ghandle(pitch_psych); set(g,'String', 'PD Psychometric OFF', 'FontWeight', 'normal');
            end;
            temp = value(pitch1_list); temp(n_done_trials+1:end) = lower; pitch1_list.value= temp;
            temp = value(pitch2_list); temp(n_done_trials+1:end) = higher; pitch2_list.value = temp;
        end;

    case 'get_new_logdiffs'
        [a b] = get_new_pitch_sets(value(MP), value(logdiff));
        pitch_sets.value = [a b];
        %        set(get_ghandle(logdiff),'String', temp(:,3));
        %        logdiff.value = 0.6;    % arbitrary new value.
        ChordSection(obj, 'change_vanilla_set');
    case 'change_vanilla_set'
        if value(vanilla_on) > 0
            temp = value(pitch_sets);
            if temp == 0, return; end;
            Tone_Freq_L.value = temp(1);
            Tone_Freq_R.value = temp(2);

            ChordSection(obj, 'sample_pitches');
            ChordSection(obj, 'make');
        end;
    case 'switch2vanilla'
        if value(vanilla_on) > 0
            set(get_ghandle(MP), 'Enable', 'on'); set(get_ghandle(logdiff), 'Enable', 'on');
            set(get_ghandle(Tone_Freq_L), 'Enable', 'off'); set(get_ghandle(Tone_Freq_R), 'Enable','off');
            trials_since_last_chng.value = 0;
            ChordSection(obj, 'get_new_logdiffs');
        else
            set(get_ghandle(MP), 'Enable', 'off'); set(get_ghandle(logdiff), 'Enable', 'off');
            set(get_ghandle(Tone_Freq_L), 'Enable', 'on'); set(get_ghandle(Tone_Freq_R), 'Enable','on');
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
        flist = {'Tone_Freq_L','Tone_Freq_R','pitch_psych','vanilla_on'};
        b = get_ghandle(block_status);
        if value(Blocks_Switch) == 0

            tones_list(starting_at:end) = 0;
            ChordSection(obj,'sample_pitches');
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
        binmin = value(Tone_Freq_L);
        binmax = value(Tone_Freq_R);
        sl = side_list;
       % if value(right_is_low) > 0, sl = 1-sl; end;


        % Building block START >>--------------
        n2m = value(Num2Make);
        blocksize = sum(n2m);
        numbins = value(Num_Bins);

        trials_left = (maxtrials-starting_at)+1;
        blocks_left = round(floor(trials_left) / blocksize);
        rem = trials_left - (blocks_left * blocksize);
        % << END BUilding blocks ---------------

        bins = generate_bins(binmin, binmax, numbins,'pitches',1);
        logbins = log2(bins);logmin = log2(binmin);
        logmax =log2(binmax);

        sidx = starting_at;
        temp_list = tones_list;
        curr_block = {};
        for blocknum = 1:blocks_left
            eidx = (sidx+blocksize)-1;
            final_block=sub__block_maker(logmin,logmax, logbins, n2m,sl(sidx:eidx),value(right_is_low));
            temp_list(sidx:eidx) = final_block;
            curr_block{end+1} = final_block;
            sidx = eidx+1;
        end;


        final_block=sub__block_maker(logmin,logmax, logbins, n2m,sl(eidx+1:end), value(right_is_low));
        temp_list(eidx+1:end) = final_block;

        fprintf(1,'Blocking tones list ...\n');
        tones_list.value = 2.^(value(temp_list));
  
    otherwise
        error(['Don''t know how to handle action ' action]);
end;


function [new_lo new_hi] = get_new_pitch_sets(mp, logdiff)
% Given the current standard interval with end points,
% generates a new set of duration pairs whose midpoint is multiple_of_mid
% times the old midpoint.

dist = logdiff/2; % we want tones half-dist away from the midpoint, so that half+half=whole
new_mp = log2(mp);

new_lo = 2^(new_mp - dist);
new_hi = 2^(new_mp + dist);

fprintf(1, 'New set: (%2.1f, %2.1f)ms, Midpoint = %2.1fms\n', ...
    new_lo, new_hi, 2^(new_mp));

% generates tones for a given block
function [final_block] = sub__block_maker(logmin,logmax, logbins, n2m,sl, r_is_lo)

numbins= length(logbins);
block_tones = [];

if r_is_lo == 0 % the tones in Bin i depend on whether tones are flipped or not
     idxset = 1:numbins;
else
    idxset = numbins:-1:1;
end;

% make the tones to be presented in the block
for idx=idxset
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

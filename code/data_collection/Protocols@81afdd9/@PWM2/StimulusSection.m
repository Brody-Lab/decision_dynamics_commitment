% Stimulus Section
%
% Given the side for the current trial (determined by SideSection), Stimulus
% Section generates the appropriate sounds using SoundInterface.
%
% Important variables:
%   stim_values : set of frequencies/decibels/durations that Sa / Sb may draw from
%   stimulus_pairs : list of Sa-Sb pairs constructed from stim_values.
%   stimulus_type : string, 'Frequency [Hz]', 'Loudness [dB]', or 'Classical [dB]'
%   current_sa : value of Sa on current trial
%   current_sb : value of Sb on current trial
%   rule : string, 'Sa < Sb Left' or 'Sa < Sb Right'. Defaults to first option.
%
% stim_table columns
% ------------------
% 1: pprob
% 2: side
% 3: Sa
% 4: Sb
% 5: frachit
% 6: fracviol
% 7: nvalid
% 8: ntotal
%
% TODO Incorporate multibias
% TODO Add option for click frequency comparison
% 
% jyanar, March 2022 initial draft

function [x, y] = StimulusSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action

    %---------------------------------------------------------------%
    %          init                                                 %
    %---------------------------------------------------------------%
    case 'init'
        x = varargin{1}; y = varargin{2};

        % Initialize with defaults for frequency task.
        SoloParamHandle(obj, 'stim_values', 'value', [], 'save_with_settings', 1);
        SoloParamHandle(obj, 'stim_table', 'value', {}, 'save_with_settings', 1);

        MenuParam(obj, 'stimulus_type', {'Frequency [Hz]', 'Loudness [dB]', 'Classical [dB]'}, ...
            2, x, y, 'position', [x y 170 20], 'label', 'Stim. type', 'labelfraction', 0.4,...
            'TooltipString', 'Stimulus type');
        PushbuttonParam(obj, 'stimulus_type_ok', x, y, 'position', [x+170 y 30 20], 'label', 'OK');
        set_callback(stimulus_type_ok, {mfilename, 'stimulus_type_ok_callback'});

        DispParam(obj, 'current_sa', '6000', x, y, 'labelfraction', 0.4, 'label',...
            'Sa [Hz]', 'position', [x+200 y 100 20]);
        DispParam(obj, 'current_sb', '12000', x, y, 'labelfraction', 0.4, 'label',...
            'Sb [Hz]', 'position', [x+300, y, 100, 20]);
        SoloParamHandle(obj, 'current_pair', 'value', 1);

        next_row(y);
        MenuParam(obj, 'rule', {'Sa < Sb Left','Sa < Sb Right'}, 1, x, y, ...
            'position', [x y 170 20], 'label', 'Rule', 'labelfraction', 0.4, ...
            'TooltipString', ['Rule dictating whether Sa < Sb results in reward being delivered\n', ...
                              'in the Left port or the Right port.']);
        PushbuttonParam(obj, 'rule_ok', x, y, 'position', [x+170 y 30 20], 'label', 'OK');
        set_callback(rule_ok, {mfilename, 'compute_left_right_pairs'});

        ToggleParam(obj, 'stimuli_on', 1, x, y, 'position', [x+200 y 100 20],...
            'OnString', 'Sounds ON', 'OffString', 'Sounds OFF',...
            'TooltipString', 'Turn all sounds on or off');
        ToggleParam(obj, 'sasb_on', 1, x, y, 'position', [x+300 y 100 20],...
            'OnString', 'Sa/Sb ON', 'OffString', 'Sa/Sb OFF',...
            'TooltipString', 'Turn Sa/Sb on or off');

        %%% Subwindow toggles
        next_row(y);
        ToggleParam(obj, 'stim_table_toggle', 0, x, y, 'position', [x y 200 20],...
            'OnString', 'Stimulus pairs table showing',...
            'OffString', 'Stimulus pairs table hidden',...
            'TooltipString', 'Show/hide stimulus pairs table');
        set_callback(stim_table_toggle, {mfilename, 'show_hide_stim_table_window'});
        ToggleParam(obj, 'soundui_toggle', 0, x, y, 'position', [x+200 y 200 20],...
            'OnString', 'Sa/Sb SoundUI params showing', ...
            'OffString', 'Sa/Sb SoundUI params hidden', ...
            'TooltipString', 'Show/hide SoundUI params');
        set_callback(soundui_toggle, {mfilename, 'show_hide_soundui_window'});

        %%% --- SOUNDUI SA / SB SUBWINDOW START ---
        oldx = x; oldy = y; mainfig = double(gcf);
        SoloParamHandle(obj, 'soundui_window', 'saveable', 0, 'value',...
            figure('position', [50 100 210 300],...
                   'MenuBar', 'none',...
                   'NumberTitle', 'off',...
                   'Name', 'SoundUI: Sa Sb',...
                   'CloseRequestFcn', [mfilename '(' class(obj) ', ''hide_soundui_window'');']));
        set(value(soundui_window), 'Visible', 'off');
        x = 5; y = 5;
        [x, y] = SoundInterface(obj, 'add', 'SaSound', x, y, 'Duration', value(stimulus_dur)); next_row(y, 0.5);
        [x, y] = SoundInterface(obj, 'add', 'SbSound', x, y, 'Duration', value(stimulus_dur));
        x = oldx; y = oldy; figure(mainfig);
        %%% --- SOUNDUI SA / SB SUBWINDOW END ---


        %%% --- SOUND PAIRS TABLE SUBWINDOW START ---
        oldx = x; oldy = y; mainfig = double(gcf);

        SoloParamHandle(obj, 'stim_table_window', 'saveable', 0, 'value', ...
            figure('position', [409 300 930 285], ...
                   'MenuBar', 'none', ...
                   'NumberTitle', 'off', ...
                   'Name', 'Sound Pairs Table', ...
                   'CloseRequestFcn', [mfilename ...
                   '(' class(obj) ', ''hide_stim_table_window'');']));
        set(value(stim_table_window), 'Visible', 'off');

        x = 10; y = 5; boty = 5; col_wid = 100;

        col_wid = 100;
        NumeditParam(obj, 'pprob', 0.5, x, y, 'position', [x y+20 col_wid 20], ...
          'labelfraction', 0.6, ...
          'TooltipString', 'Prior probability of choosing this stimulus pair; must be [0,1]');
        PushbuttonParam(obj, 'update_pprob', x, y, 'position', [x y col_wid 20], 'label', 'Update');
        set_callback(update_pprob, {mfilename, 'update_pprob_callback'});

        MenuParam(obj, 'side', {'L','R'}, 1, x, y, 'position', [x+col_wid+10 y+20 col_wid*0.75 20],...
            'labelfraction', 0.5, ...
            'TooltipString', 'Correct side choice for this stimulus pair');
        PushbuttonParam(obj, 'update_side', x, y, 'position', [x+col_wid+10 y col_wid*0.75 20],...
            'label', 'Update');
        set_callback(update_side, {mfilename, 'update_side_callback'});

        NumeditParam(obj, 'Sa', 25, x, y, 'position', [x+(2*col_wid) y+20 col_wid 20], ...
          'labelfraction', 0.3);
        PushbuttonParam(obj, 'update_sa', x, y, 'position', [x+(2*col_wid) y col_wid 20],...
            'label', 'Update');
        set_callback(update_sa, {mfilename, 'update_sa_callback'});

        NumeditParam(obj, 'Sb', 25, x, y, 'position', [x+(3*col_wid)+5 y+20 col_wid 20], ...
            'labelfraction', 0.3);
        PushbuttonParam(obj, 'update_sb', x, y, 'position', [x+(3*col_wid)+5 y col_wid 20],...
            'label', 'Update');
        set_callback(update_sb, {mfilename, 'update_sb_callback'});

        NumeditParam(obj, 'watermult', 1.5, x, y, 'position', [x+(4*col_wid)+10 y+20 col_wid 20], ...
            'labelfraction', 0.6);
        PushbuttonParam(obj, 'update_wtrmlt', x, y, 'position', [x+(4*col_wid)+10 y col_wid 20], ...
            'label', 'Update');
        set_callback(update_wtrmlt, {mfilename, 'update_wtrmlt_callback'});

        x = 530;
        PushbuttonParam(obj, 'add_pair_button', x, y, 'position', [x y+20 col_wid 20], 'label', 'Add Pair');
        PushbuttonParam(obj, 'del_pair_button', x, y, 'position', [x y col_wid 20], 'label', 'Delete Pair');
        PushbuttonParam(obj, 'upd_pair_button', x, y, 'position', [x+col_wid+5 y+20 col_wid 20], 'label', 'Update Pair', ...
          'TooltipString', 'replaces the currently selected row with values in the gui elements above');
        PushbuttonParam(obj, 'play_snd', x, y, 'position', [x+(2*col_wid)+10 y+20 80 20], 'label', 'Play Sound');
        PushbuttonParam(obj, 'stop_snd', x, y, 'position', [x+(2*col_wid)+10 y 80 20], 'label', 'Stop Sound');
        PushbuttonParam(obj, 'play_all_snd', x, y, 'position', [x+(3*col_wid)+10 y+20 80 20], 'label', 'Play All');
        set_callback(add_pair_button, {mfilename, 'add_pair'});
        set_callback(del_pair_button, {mfilename, 'delete_pair'});
        set_callback(upd_pair_button, {mfilename, 'update_pair'});
        set_callback(play_snd, {mfilename, 'play_sound'});
        set_callback(stop_snd, {mfilename, 'stop_sound'});
        set_callback(play_all_snd, {mfilename, 'play_all_sounds'});
        next_row(y, 2.1);
        x = 10;

        switch value(stimulus_type)
            case 'Loudness [dB]'
                header_str = {'PProb   Side   Sa [dB]   Sb [dB]   frachit   fracviol   nvalid  ntotal watermult'};
            case 'Frequency [Hz]'
                header_str = {'PProb   Side   Sa [Hz]   Sb [Hz]   frachit   fracviol   nvalid  ntotal watermult'};
            case 'Classical [dB]'
                header_str = {'PProb   Side   Sa [dB]   Sb [Hz]   frachit   fracviol   nvalid  ntotal watermult'};
        end
        SoloParamHandle(obj, 'dtable', 'value', header_str, 'saveable', 0);
        ListboxParam(obj, 'stable', value(dtable), ...
            rows(value(dtable)), ...
            x, y, 'position', [x y 920 210], ...
            'FontName', 'Courier', 'FontSize', 14, ...
            'saveable', 0);
        set(get_ghandle(stable), 'BackgroundColor', [255 240 255]/255);
        set_callback(stim_table, {mfilename, 'display_table'});
        set_callback_on_load(stim_table, 1);

        y = y+210;
        HeaderParam(obj, 'panel_title', 'Sound Stimulus Pairs', x, y, 'position', [x y 140 20]);
        set(get_ghandle(panel_title), 'BackgroundColor', [215 190 200]/255);

        %%%%%%%%%%%%%%%%%%%%%%%%
        %%% STIMULUS PRESETS %%%
        %%%%%%%%%%%%%%%%%%%%%%%%
        MenuParam(obj, 'presets', {'Custom',...
                                   'Set A akrami (2 symmetric)',...
                                   'Set A akrami (sa discrim)',...
                                   'Set A akrami (sa discrim, add sb)',...
                                   'Set A akrami (add middle pairs)',...
                                   'Set A akrami',...
                                   'Set A base*1.65 (sa discrim)',...
                                   'Set A base*1.65 (sa discrim, add sb)',...
                                   'Set A base*1.65 (add middle pairs)',...
                                   'Set A base*1.65',...
                                   'Set A classical (sa discrim)', ...
                                   'Set A classical (sa discrim, add sb)',...
                                   'Set A classical (add middle pairs)', ...
                                   'Set A classical', ...
                                   'Asymmetric 2 pairs',...
                                   'Asymmetric 4 pairs',...
                                   },...
            6, x, y, 'position', [x+145 y 200 20], ...
            'TooltipString', ['\nSelect preset stimulus set such as the classic Romo set A/B,\n'...
                              'crosses, or set to custom and manually specify set.'],...
            'labelfraction', 0.35, 'labelpos', 'left');
        set_callback(presets, {mfilename, 'set_preset'});

        PushbuttonParam(obj, 'normal', x, y, 'position', [x+360 y 80 20], ...
            'label', 'Normalize PProb', ...
            'TooltipString', ['Normalizes the PProb (prior probabilities) column so that it sums to unity '...
                              '\nWhen RED, the sum is incorrect and this button needs to be pressed!']);
        set_callback(normal, {mfilename, 'normalize_pprob'});

        PushbuttonParam(obj, 'LRassign_button', x, y, 'position', [x+440 y 80 20], ...
            'label', 'L/R Assign', ...
            'TooltipString', 'Assigns Left/Right to each pair based on the current rule.');
        set_callback(LRassign_button, {mfilename, 'LRassign_button_callback'});
        figure(mainfig); x = oldx; y = oldy;
        %%% --- SOUND PAIRS TABLE SUBWINDOW END ---

        %%% add draw button for plot
        next_row(y);
        PushbuttonParam(obj, 'draw', x, y, 'position', [x y 30 20], 'label', 'draw');
        set_callback(draw, {mfilename, 'plot_pairs'});
        x = x + 200;

        %%% Multibias
        NumeditParam(obj, 'multibias_scaling', 0, x, y, 'position', [x y 200 20], ...
            'label', 'Multibias scaling', 'labelfraction', 0.7, 'TooltipString', ...
            ['Multibias scaling parameter. At 1, pair probabilities are determined by hit rate.' ...
             'At 0, pair probabilities are determined by prior prob (first col in stim_table)']);
        set_callback(multibias_scaling, {mfilename, 'multibias_scaling_callback'});
        next_row(y);

        %%% Functionality to play Sa/Sb from different speakers or stereo
        MenuParam(obj, 'channel_type', {'Mono', 'Stereo'}, 2, x, y, 'position', [x y 200 20],...
            'label', 'Channel type', 'labelfraction', 0.4, 'TooltipString', ...
            'Whether to play Sa, Sb from separate speakers or stereo.');
        next_row(y);

        %%% Sb extra functionality (extend Sb for longer than stimulus_dur)
        NumeditParam(obj, 'sb_extra', 0, x, y, 'label', 'Sb extra', 'labelfraction', 0.5,...
            'position', [x y 100 20], 'TooltipString', ...
            'How long to keep Sb on after spoke. NB: Using auditory go cue forces sb_extra <= post_dur.');
        set_callback(sb_extra, {mfilename, 'set_soundui_properties'});

        %%% Generate plot of stimulus set
        next_row(y);
        newaxes = axes;
        SoloParamHandle(obj, 'pairsfig', 'saveable', 0, 'value', double(newaxes));
        set(value(pairsfig), 'position', [.3 .7 .18 .18]);

        StimulusSection(obj, 'set_preset');
        StimulusSection(obj, 'plot_pairs');

        %%% Title
        x = x - 200;
        next_row(y, 6);
        SubheaderParam(obj, 'lab0', 'Stimulus Section',x, y, 'position', [x y 400 20]);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%    SEND OUT VARS    %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%

        SoloFunctionAddVars('HistorySection', 'ro_args', 'stim_table');

        % Variables to send out to trainingsection
        training_section_vars = {'stim_values', 'stimulus_type', 'rule',...
                                 'stimuli_on', 'sasb_on', 'presets', 'stim_table'...
                                 'sb_extra', 'current_pair'};

        SoloFunctionAddVars('TrainingSection',   'rw_args', training_section_vars);
        SoloFunctionAddVars('TS_JY_spoke_fix',   'rw_args', training_section_vars);
        SoloFunctionAddVars('TS_JY_rulefirst',   'rw_args', training_section_vars);
        SoloFunctionAddVars('TS_PWM_classical',  'rw_args', training_section_vars);
        SoloFunctionAddVars('TS_LG_GNP_snds',    'rw_args', training_section_vars);
        SoloFunctionAddVars('TS_classicv2_full', 'rw_args', training_section_vars);
        SoloFunctionAddVars('TS_LGS_v2',         'rw_args', training_section_vars);

        SoloFunctionAddVars('SMA_cpoke', 'rw_args', training_section_vars);
        SoloFunctionAddVars('SMA_spoke', 'rw_args', training_section_vars);

        % If user sets an auditory go cue, sb cannot stretch beyond the Go cue (and is
        % thus of length post_dur). Allow ShapingSection to check this. Also needs
        % access to the stim_table in order to turn on the light guide for low-perf pairs.
        SoloFunctionAddVars('ShapingSection', 'rw_args', training_section_vars);

        DeclareGlobals(obj, 'ro_args', ...
            {'stimuli_on', 'current_pair', 'current_sa', 'current_sb',...
             'stimulus_type', 'rule', 'sasb_on'});


    %---------------------------------------------------------------%
    %          prepare_next_trial                                   %
    %---------------------------------------------------------------%
    case 'prepare_next_trial'
        % Update current_sa and current_sb based on current_side
        StimulusSection(obj, 'select_random_pair');

        % Set appropriate sound properties via SoundUI
        StimulusSection(obj, 'set_soundui_properties');

        % Update plot to show stimulus set and current Sa/Sb pair
        StimulusSection(obj, 'plot_pairs');


    case 'stimulus_type_ok_callback'
        % User manually pressed button, let's load up appropriate default
        switch value(stimulus_type)
        case 'Frequency [Hz]'
            StimulusSection(obj, 'set_preset', 'Set A base*1.65');
        case 'Loudness [dB]'
            StimulusSection(obj, 'set_preset', 'Set A akrami');
        case 'Classical [dB]'
            StimulusSection(obj, 'set_preset', 'Set A classical')
        end
        ShapingSection(obj, 'set_soundui_properties');


    %---------------------------------------------------------------%
    %          set_preset                                           %
    %---------------------------------------------------------------%
    case 'set_preset'
        if length(varargin) == 1
            presets.value = varargin{1};
        end
        switch value(presets)
            case 'Custom'
                % Leave the current pairs intact, but reset performance information
                st = value(stim_table);
                for irow = 1 : size(st, 1)
                    st{irow, 5} = NaN; % frachit
                    st{irow, 6} = NaN; % fracviol
                    st{irow, 7} = 0;   % nvalid
                    st{irow, 8} = 0;   % ntotal
                end
                stim_table.value = st;


            case 'Set A akrami (2 symmetric)'
                stim_table.value = {};
                switch value(stimulus_type)
                case 'Loudness [dB]'
                    Sa.value = 0.03; Sb.value = 0.2;  StimulusSection(obj, 'add_pair');
                    Sa.value = 0.2;  Sb.value = 0.03; StimulusSection(obj, 'add_pair');
                    StimulusSection(obj, 'compute_left_right_pairs');
                end

            case 'Set A akrami (sa discrim)'
                stim_table.value = {};
                switch value(stimulus_type)
                case 'Loudness [dB]'
                    Sa.value = 0.03; Sb.value = 0.08; StimulusSection(obj, 'add_pair');
                    Sa.value = 0.2;  Sb.value = 0.08; StimulusSection(obj, 'add_pair');
                    StimulusSection(obj, 'compute_left_right_pairs');
                end

            case 'Set A akrami (sa discrim, add sb)'
                stim_table.value = {};
                switch value(stimulus_type)
                case 'Loudness [dB]'
                    Sa.value = 0.03; Sb.value = 0.08; StimulusSection(obj, 'add_pair');
                    Sa.value = 0.2;  Sb.value = 0.08; StimulusSection(obj, 'add_pair');
                    Sa.value = 0.03; Sb.value = 0.011; StimulusSection(obj, 'add_pair');
                    Sa.value = 0.2;  Sb.value = 0.48; StimulusSection(obj, 'add_pair');
                    StimulusSection(obj, 'compute_left_right_pairs');
                end

            case 'Set A akrami (add middle pairs)'
                stim_table.value = {};
                switch value(stimulus_type)
                case 'Loudness [dB]'
                    Sa.value = 0.03; Sb.value = 0.08;  StimulusSection(obj, 'add_pair');
                    Sa.value = 0.2;  Sb.value = 0.08;  StimulusSection(obj, 'add_pair');
                    Sa.value = 0.03; Sb.value = 0.011; StimulusSection(obj, 'add_pair');
                    Sa.value = 0.2;  Sb.value = 0.48;  StimulusSection(obj, 'add_pair');
                    Sa.value = 0.08; Sb.value = 0.03;  StimulusSection(obj, 'add_pair');
                    Sa.value = 0.08; Sb.value = 0.2;   StimulusSection(obj, 'add_pair');
                    StimulusSection(obj, 'compute_left_right_pairs');
                end

            case 'Set A akrami'
                stim_table.value = {};
                switch value(stimulus_type)
                    case 'Loudness [dB]'
                        % In Akrami et al. 2018, the following stimulus set was used:
                        %                       60    68   76   84  92 dB
                        stim_values.value = [0.011 0.03 0.08 0.2 0.48];
                        % 10 June 2023: recalculated using volume_to_db() in utils.jl
                        % Previous values were closer to:
                        %                     61.7  69.4 77   84   90.6
                        % New values:
                        % TODO Change all of set a akrami to this
                        % stim_values.value = [0.009 0.03 0.07 0.202 0.573];
                        StimulusSection(obj, 'compute_symmetric_pairs');
                        StimulusSection(obj, 'compute_left_right_pairs');
                end


            case 'Set A base*1.65 (sa discrim)'
                stim_table.value = {};
                switch value(stimulus_type)
                case 'Frequency [Hz]'
                    Sa.value = 4950;  Sb.value = 8168; StimulusSection(obj, 'add_pair');
                    Sa.value = 13477; Sb.value = 8168; StimulusSection(obj, 'add_pair');
                    StimulusSection(obj, 'compute_left_right_pairs');
                end

            case 'Set A base*1.65 (sa discrim, add sb)'
                stim_table.value = {};
                switch value(stimulus_type)
                case 'Frequency [Hz]'
                    Sa.value = 4950;  Sb.value = 8168;  StimulusSection(obj, 'add_pair');
                    Sa.value = 13477; Sb.value = 8168;  StimulusSection(obj, 'add_pair');
                    Sa.value = 4950;  Sb.value = 3000;  StimulusSection(obj, 'add_pair');
                    Sa.value = 13477; Sb.value = 22236; StimulusSection(obj, 'add_pair');
                    StimulusSection(obj, 'compute_left_right_pairs');
                end

            case 'Set A base*1.65 (add middle pairs)'
                stim_table.value = {};
                switch value(stimulus_type)
                case 'Frequency [Hz]'
                    Sa.value = 4950;  Sb.value = 8168;  StimulusSection(obj, 'add_pair');
                    Sa.value = 13477; Sb.value = 8168;  StimulusSection(obj, 'add_pair');
                    Sa.value = 4950;  Sb.value = 3000;  StimulusSection(obj, 'add_pair');
                    Sa.value = 13477; Sb.value = 22236; StimulusSection(obj, 'add_pair');
                    Sa.value = 8168;  Sb.value = 4850;  StimulusSection(obj, 'add_pair');
                    Sa.value = 8168;  Sb.value = 13477; StimulusSection(obj, 'add_pair');
                    StimulusSection(obj, 'compute_left_right_pairs');
                end

            case 'Set A base*1.65'
                stim_table.value = {};
                switch value(stimulus_type)
                    case 'Frequency [Hz]'
                        stim_values.value = [3000 4950 8168 13477 22236];
                        StimulusSection(obj, 'compute_symmetric_pairs');
                        StimulusSection(obj, 'compute_left_right_pairs');
                end


            case 'Set A classical (sa discrim)'
                stim_table.value = {};
                Sa.value = 0.0027; Sb.value = 0.0073; StimulusSection(obj, 'add_pair');
                Sa.value = 0.0197; Sb.value = 0.0073; StimulusSection(obj, 'add_pair');
                StimulusSection(obj, 'compute_left_right_pairs');

            case 'Set A classical (sa discrim, add sb)'
                stim_table.value = {};
                Sa.value = 0.0027; Sb.value = 0.0073; StimulusSection(obj, 'add_pair');
                Sa.value = 0.0197; Sb.value = 0.0073; StimulusSection(obj, 'add_pair');
                Sa.value = 0.0027; Sb.value = 0.0010; StimulusSection(obj, 'add_pair');
                Sa.value = 0.0197; Sb.value = 0.0531; StimulusSection(obj, 'add_pair');
                StimulusSection(obj, 'compute_left_right_pairs');

            case 'Set A classical (add middle pairs)'
                stim_table.value = {};
                Sa.value = 0.0027; Sb.value = 0.0073; StimulusSection(obj, 'add_pair');
                Sa.value = 0.0197; Sb.value = 0.0073; StimulusSection(obj, 'add_pair');
                Sa.value = 0.0027; Sb.value = 0.0010; StimulusSection(obj, 'add_pair');
                Sa.value = 0.0197; Sb.value = 0.0531; StimulusSection(obj, 'add_pair');
                Sa.value = 0.0073; Sb.value = 0.0027; StimulusSection(obj, 'add_pair');
                Sa.value = 0.0073; Sb.value = 0.0197; StimulusSection(obj, 'add_pair');
                StimulusSection(obj, 'compute_left_right_pairs');

            case 'Set A classical'
                stim_table.value = {};
                stim_values.value = [0.0010 0.0027 0.0073 0.0197 0.0531];
                StimulusSection(obj, 'compute_symmetric_pairs');
                StimulusSection(obj, 'compute_left_right_pairs');

            case 'Asymmetric 2 pairs'
                stim_table.value = {};
                Sa.value = 0.011; Sb.value = 0.055; StimulusSection(obj, 'add_pair');
                Sa.value = 0.441; Sb.value = 0.092; StimulusSection(obj, 'add_pair');
                StimulusSection(obj, 'compute_left_right_pairs');

            case 'Asymmetric 4 pairs'
                stim_table.value = {};
                Sa.value = 0.011; Sb.value = 0.055; StimulusSection(obj, 'add_pair');
                Sa.value = 0.055; Sb.value = 0.011; StimulusSection(obj, 'add_pair');
                Sa.value = 0.092; Sb.value = 0.441; StimulusSection(obj, 'add_pair');
                Sa.value = 0.441; Sb.value = 0.092; StimulusSection(obj, 'add_pair');
                StimulusSection(obj, 'compute_left_right_pairs');

        end
        StimulusSection(obj, 'normalize_pprob');
        StimulusSection(obj, 'select_random_pair');
        StimulusSection(obj, 'set_soundui_properties');
        StimulusSection(obj, 'plot_pairs');
        StimulusSection(obj, 'display_table');

    %---------------------------------------------------------------%
    %          stim table buttons                                   %
    %---------------------------------------------------------------%

    % Add new pair. Use current values of pprob, side, Sa, Sb, wtrmlt
    case 'add_pair'
        idx = rows(stim_table) + 1;
        stim_table{idx,1} = value(pprob);
        stim_table{idx,2} = value(side);
        stim_table{idx,3} = value(Sa);
        stim_table{idx,4} = value(Sb);
        stim_table{idx,5} = NaN;  % frachit
        stim_table{idx,6} = NaN;  % fracviol
        stim_table{idx,7} = 0;    % nvalid
        stim_table{idx,8} = 0;    % ntotal
        stim_table{idx,9} = value(watermult);    % water multiplier

        newrow = format_row_str(obj, value(pprob), value(side), value(Sa), ...
            value(Sb), NaN, NaN, 0, 0, value(watermult));
        dtable.value = [value(dtable) ; cell(1,1)];
        dtable{rows(dtable)} = newrow;
        set(get_ghandle(stable), 'string', value(dtable));
        stable.value = length(value(dtable));

    % Update currently-selected pair, using current values of pprob, side, etc
    case 'update_pair'
        n = get(get_ghandle(stable), 'value');
        n = n(1);
        if n == 1, return; end; % if label row selected, do nothing

        % the nth row in the table corresponds to the (n-1)th row in
        % stim_table
        k = n - 1;

        temp = value(dtable);
        newrow = format_row_str(obj, value(pprob), value(side), value(Sa), ...
            value(Sb), stim_table{k,5}, stim_table{k,6}, stim_table{k,7}, ...
            stim_table{k,8}, value(watermult));
        dtable.value = [temp(1:n-1); cell(1,1); temp(n+1:end)];
        dtable{n} = newrow;

        set(get_ghandle(stable), 'string', value(dtable));
        stable.value = length(value(dtable));

        stim_table{k,1} = value(pprob);
        stim_table{k,2} = value(side);
        stim_table{k,3} = value(Sa);
        stim_table{k,4} = value(Sb);
        stim_table{k,9} = value(watermult);

    % Delete currently-selected pair.
    case 'delete_pair'
        n = get(get_ghandle(stable), 'value');
        n = n(1);
        if n == 1, return; end; % if the label row was selected, do nothing
        temp = value(dtable);
        dtable.value = temp([1:n-1 n+1:end],:);
        celltable = cellstr(value(dtable));
        set(get_ghandle(stable), 'string', celltable);
        stable.value = min(n, rows(dtable));

        % the nth row in table corresponds to the (n-1)th row in stim_table
        k = n - 1;
        stim_table.value = stim_table([1:k-1 k+1:rows(stim_table)],:);

    case 'normalize_pprob'
        if isempty(stim_table), return; end;
        st = value(stim_table);
        prb = [st{:,1}]';
        % Prevent bug where all pairs are accidentally set to 0 probability
        if sum(prb) == 0
            prb = zeros(length(prb), 1) + 0.25;
        end
        prb = prb./sum(prb);
        for i = 1 : size(value(stim_table), 1)
            stim_table{i,1} = prb(i);
        end
        StimulusSection(obj, 'display_table');

    case 'update_pprob_callback'
        n = get(get_ghandle(stable), 'value'); n = n(1);
        if n == 1, return; end; % if label row selected, do nothing
        k = n - 1; % the nth row in the table corresponds to the (n-1)th row in stim_table
        stim_table{k,1} = value(pprob);
        temp = value(dtable);
        newrow_str = format_row_str(obj, stim_table{k,1}, stim_table{k,2}, stim_table{k,3}, ...
            stim_table{k,4}, stim_table{k,5}, stim_table{k,6}, stim_table{k,7}, stim_table{k,8},...
            stim_table{k,9});
        dtable.value = [temp(1:n-1); cell(1,1); temp(n+1:end)];
        dtable{n} = newrow_str;
        set(get_ghandle(stable), 'string', value(dtable));
        stable.value = length(value(dtable));

    case 'update_side_callback'
        n = get(get_ghandle(stable), 'value'); n = n(1);
        if n == 1, return; end; % if label row selected, do nothing
        k = n - 1; % the nth row in the table corresponds to the (n-1)th row in stim_table
        stim_table{k,2} = value(side);
        temp = value(dtable);
        newrow_str = format_row_str(obj, stim_table{k,1}, stim_table{k,2}, stim_table{k,3}, ...
            stim_table{k,4}, stim_table{k,5}, stim_table{k,6}, stim_table{k,7}, stim_table{k,8},...
            stim_table{k,9});
        dtable.value = [temp(1:n-1); cell(1,1); temp(n+1:end)];
        dtable{n} = newrow_str;
        set(get_ghandle(stable), 'string', value(dtable));
        stable.value = length(value(dtable));

    case 'update_sa_callback'
        n = get(get_ghandle(stable), 'value'); n = n(1);
        if n == 1, return; end; % if label row selected, do nothing
        k = n - 1; % the nth row in the table corresponds to the (n-1)th row in stim_table
        stim_table{k,3} = value(Sa);
        temp = value(dtable);
        newrow_str = format_row_str(obj, stim_table{k,1}, stim_table{k,2}, stim_table{k,3}, ...
            stim_table{k,4}, stim_table{k,5}, stim_table{k,6}, stim_table{k,7}, stim_table{k,8},...
            stim_table{k,9});
        dtable.value = [temp(1:n-1); cell(1,1); temp(n+1:end)];
        dtable{n} = newrow_str;
        set(get_ghandle(stable), 'string', value(dtable));
        stable.value = length(value(dtable));

    case 'update_sb_callback'
        n = get(get_ghandle(stable), 'value'); n = n(1);
        if n == 1, return; end; % if label row selected, do nothing
        k = n - 1; % the nth row in the table corresponds to the (n-1)th row in stim_table
        stim_table{k,4} = value(Sb);
        temp = value(dtable);
        newrow_str = format_row_str(obj, stim_table{k,1}, stim_table{k,2}, stim_table{k,3}, ...
            stim_table{k,4}, stim_table{k,5}, stim_table{k,6}, stim_table{k,7}, stim_table{k,8},...
            stim_table{k,9});
        dtable.value = [temp(1:n-1); cell(1,1); temp(n+1:end)];
        dtable{n} = newrow_str;
        set(get_ghandle(stable), 'string', value(dtable));
        stable.value = length(value(dtable));

    case 'update_wtrmlt_callback'
        n = get(get_ghandle(stable), 'value'); n = n(1);
        if n == 1, return; end; % if label row selected, do nothing
        k = n - 1; % the nth row in the table corresponds to the (n-1)th row in stim_table
        stim_table{k,9} = value(watermult);
        temp = value(dtable);
        newrow_str = format_row_str(obj, stim_table{k,1}, stim_table{k,2}, stim_table{k,3}, ...
            stim_table{k,4}, stim_table{k,5}, stim_table{k,6}, stim_table{k,7}, stim_table{k,8},...
            stim_table{k,9});
        dtable.value = [temp(1:n-1); cell(1,1); temp(n+1:end)];
        dtable{n} = newrow_str;
        set(get_ghandle(stable), 'string', value(dtable));
        stable.value = length(value(dtable));

    case 'display_table'
        if isempty(stim_table), return; end;
        temp = value(dtable);
        temp = temp(1);
        for k = 1 : rows(stim_table)
            newrow = format_row_str(obj, stim_table{k,1}, stim_table{k,2}, ...
                                         stim_table{k,3}, stim_table{k,4}, ...
                                         stim_table{k,5}, stim_table{k,6}, ...
                                         stim_table{k,7}, stim_table{k,8}, ...
                                         stim_table{k,9});
            temp = [temp; cell(1,1)];
            temp{end} = newrow;
        end
        dtable.value = temp;
        set(get_ghandle(stable), 'string', value(dtable));
        stable.value = length(value(dtable));

    case 'play_all_sounds'
        for isnd = 1 : length(value(dtable))
            stable.value = isnd;
            StimulusSection(obj, 'play_sound');
        end

    case 'play_sound'
        n = get(get_ghandle(stable), 'value'); % get selected row
        n = n(1);
        if n==1, return; end;  %if the label row was selected, do nothing
        k = n-1;

        % If channel type is mono, then we play the louder sound on the correct
        % side. Determine which side that is based on the current trial and the
        % rule. -1=left, 0=stereo, 1=right
        sa_bal = 0;
        sb_bal = 0;
        if strcmp(channel_type, 'Mono')
            if strcmp(current_side, 'LEFT')
                if strcmp(rule, 'Sa < Sb Left')
                    sa_bal =  1; sb_bal = -1;
                elseif strcmp(rule, 'Sa < Sb Right')
                    sa_bal = -1; sb_bal =  1;
                end
            elseif strcmp(current_side, 'RIGHT')
                if strcmp(rule, 'Sa < Sb Left')
                    sa_bal = -1; sb_bal =  1;
                elseif strcmp(rule, 'Sa < Sb Right')
                    sa_bal =  1; sb_bal = -1;
                end
            end
        end

        % Set current SaSound and SbSound to these pairs temporarily, using SoundInterface
        switch value(stimulus_type)
        case 'Frequency [Hz]'
            SoundInterface(obj, 'set', 'SaSound',...
                                       'Style', 'Tone',...
                                       'Vol', 0.005,...
                                       'Freq1', stim_table{k,3},...
                                       'Dur1', value(stimulus_dur),...
                                       'Loop', 0, 'Bal', sa_bal);

            SoundInterface(obj, 'set', 'SbSound',...
                                       'Style', 'Tone',...
                                       'Vol', 0.005,...
                                       'Freq1', stim_table{k,4},...
                                       'Dur1', value(stimulus_dur) + value(sb_extra),...
                                       'Loop', 0, 'Bal', sb_bal);

        case 'Loudness [dB]'
            SoundInterface(obj, 'set', 'SaSound',...
                                       'Style', 'PinkNoise',...
                                       'Vol', stim_table{k,3},...
                                       'Dur1', value(stimulus_dur),...
                                       'Loop', 0, 'Bal', sa_bal);

            SoundInterface(obj, 'set', 'SbSound',...
                                       'Style', 'PinkNoise',...
                                       'Vol', stim_table{k,4},...
                                       'Dur1', value(stimulus_dur) + value(sb_extra),...
                                       'Loop', 0, 'Bal', sb_bal);

        case 'Classical [dB]'
            srate = SoundManagerSection(obj, 'get_sample_rate');
            [AUD1, AUD2] = classical_loudness_stim(2000, 20000,...
                                                   value(stimulus_dur),...
                                                   stim_table{k,3}, stim_table{k,4},...
                                                   110, srate, 'GAUS');
            SoundManagerSection(obj, 'set_sound', 'SaSound', [AUD1' ; AUD1']);
            SoundManagerSection(obj, 'set_sound', 'SbSound', [AUD2' ; AUD2']);
            
        end
        StimulusSection(obj, 'push_sounds_bpod');
        SoundManagerSection(obj, 'play_sound', 'SaSound');
        pause(value(stimulus_dur) + value(delay_dur));
        SoundManagerSection(obj, 'play_sound', 'SbSound');
        pause(value(stimulus_dur) + value(post_dur));
        SoundManagerSection(obj, 'play_sound', 'GoSound');
        % Set them back to current_sa and current_sb
        StimulusSection(obj, 'set_soundui_properties');


    %---------------------------------------------------------------%
    %          play_sasb_replay                                     %
    %---------------------------------------------------------------%
    % Called from ShapingSection when user hits the "PLAY" button to
    % test the shortened Sa/delay/Sb that can optionally be played during
    % the reward period
    case 'play_sasb_replay'
        n = get(get_ghandle(stable), 'value'); % get selected row
        n = n(1);
        if n==1, return; end;  %if the label row was selected, do nothing
        k = n-1;

        % If channel type is mono, then we play the louder sound on the correct
        % side. Determine which side that is based on the current trial and the
        % rule. -1=left, 0=stereo, 1=right
        sa_bal = 0;
        sb_bal = 0;
        if strcmp(channel_type, 'Mono')
            if strcmp(current_side, 'LEFT')
                if strcmp(rule, 'Sa < Sb Left')
                    sa_bal =  1; sb_bal = -1;
                elseif strcmp(rule, 'Sa < Sb Right')
                    sa_bal = -1; sb_bal =  1;
                end
            elseif strcmp(current_side, 'RIGHT')
                if strcmp(rule, 'Sa < Sb Left')
                    sa_bal = -1; sb_bal =  1;
                elseif strcmp(rule, 'Sa < Sb Right')
                    sa_bal =  1; sb_bal = -1;
                end
            end
        end

        % Set current SaSound and SbSound to these pairs temporarily, using SoundInterface
        switch value(stimulus_type)
        case 'Frequency [Hz]'
            SoundInterface(obj, 'set', 'SaSound',...
                                       'Style', 'Tone',...
                                       'Vol', 0.005,...
                                       'Freq1', stim_table{k,3},...
                                       'Dur1', value(sa_replay_dur),...
                                       'Loop', 0, 'Bal', sa_bal);

            SoundInterface(obj, 'set', 'SbSound',...
                                       'Style', 'Tone',...
                                       'Vol', 0.005,...
                                       'Freq1', stim_table{k,4},...
                                       'Dur1', value(sb_replay_dur),...
                                       'Loop', 0, 'Bal', sb_bal);

        case 'Loudness [dB]'
            SoundInterface(obj, 'set', 'SaSound',...
                                       'Style', 'PinkNoise',...
                                       'Vol', stim_table{k,3},...
                                       'Dur1', value(sa_replay_dur),...
                                       'Loop', 0, 'Bal', sa_bal);

            SoundInterface(obj, 'set', 'SbSound',...
                                       'Style', 'PinkNoise',...
                                       'Vol', stim_table{k,4},...
                                       'Dur1', value(sb_replay_dur),...
                                       'Loop', 0, 'Bal', sb_bal);

        case 'Classical [dB]'
            srate = SoundManagerSection(obj, 'get_sample_rate');
            [AUD1, AUD2] = classical_loudness_stim(2000, 20000,...
                                                   value(sa_replay_dur),...
                                                   stim_table{k,3}, stim_table{k,4},...
                                                   110, srate, 'GAUS');
            % TODO sa_bal and sb_bal here too
            SoundManagerSection(obj, 'set_sound', 'SaSound', [AUD1' ; AUD1']);
            SoundManagerSection(obj, 'set_sound', 'SbSound', [AUD2' ; AUD2']);
        end
        StimulusSection(obj, 'push_sounds_bpod');
        SoundManagerSection(obj, 'play_sound', 'SaSound');
        pause(value(sa_replay_dur) + value(delay_replay_dur));
        SoundManagerSection(obj, 'play_sound', 'SbSound');
        pause(value(sb_replay_dur));
        % Set them back to current_sa and current_sb
        StimulusSection(obj, 'set_soundui_properties');



    %---------------------------------------------------------------%
    %          update_performance                                   %
    %---------------------------------------------------------------%
    % Called from HistorySection when evaluating the result of a given trial,
    % and updates the corresponding frachit or fracviol column for the
    % current pair. varargin{1} is an integer between 1 and 4, representing:
    % 1: hit, 2: error, 3: violation, 4: temperror
    case 'update_performance'

        result = value(varargin{1});
        nvalid = stim_table{value(current_pair), 7}; % Num of valid trials for this pair
        ntotal = stim_table{value(current_pair), 8}; % Num of total presentations for this pair

        switch result
        %%% Hit, error, or temperror
        case {1, 2, 4}
            % update frachit for this pair
            if result == 1 washit = 1; else washit = 0; end
            frachit = stim_table{value(current_pair), 5};
            stim_table{value(current_pair), 5} = compute_cumulative_avg(frachit, washit, nvalid);

            % update fracviol for this pair
            fracviol = stim_table{value(current_pair), 6};
            stim_table{value(current_pair), 6} = compute_cumulative_avg(fracviol, 0, ntotal);

            % update counters
            stim_table{value(current_pair), 7} = nvalid + 1;
            stim_table{value(current_pair), 8} = ntotal + 1;

        %%% Violation
        case 3
            fracviol = stim_table{value(current_pair), 6};
            stim_table{value(current_pair), 6} = compute_cumulative_avg(fracviol, 1, ntotal);
            stim_table{value(current_pair), 8} = ntotal + 1;

        otherwise
            error(sprintf('PWM2/StimulusSection/update_performance: Invalid result: %d', result))
        end

        StimulusSection(obj, 'display_table');


    case 'plot_pairs'
        axes(value(pairsfig));
        cla(value(pairsfig)); % clear the figure
        st = value(stim_table);
        savals = log10([st{:,3}]');
        sbvals = log10([st{:,4}]');
        hold on;
        h1 = plot(savals, sbvals, 'k.');
        sa_log = log10(value(current_sa));
        sb_log = log10(value(current_sb));
        h2 = plot(sa_log, sb_log, 'md');
        set(value(pairsfig), 'XTick', [], 'YTick', []);
        hold off;


    %---------------------------------------------------------------%
    %          set_soundui_properties                               %
    %---------------------------------------------------------------%
    % This method sets SaSound and SbSound to the appropriate style,
    % duration, and value. In `prepare_next_trial`, it is called after
    % a random pair has been selected from the stim_table.
    case 'set_soundui_properties'

        % If channel type is mono, then we play the louder sound on the correct
        % side. Determine which side that is based on the current trial and the
        % rule. -1=left, 0=stereo, 1=right
        % TODO Implement this for Frequency and Classical
        sa_bal = 0;
        sb_bal = 0;
        if strcmp(channel_type, 'Mono')
            if strcmp(current_side, 'LEFT')
                if strcmp(rule, 'Sa < Sb Left')
                    sa_bal =  1; sb_bal = -1;
                elseif strcmp(rule, 'Sa < Sb Right')
                    sa_bal = -1; sb_bal =  1;
                end
            elseif strcmp(current_side, 'RIGHT')
                if strcmp(rule, 'Sa < Sb Left')
                    sa_bal = -1; sb_bal =  1;
                elseif strcmp(rule, 'Sa < Sb Right')
                    sa_bal =  1; sb_bal = -1;
                end
            end
        end

        switch value(stimulus_type)
            case 'Frequency [Hz]'
                SoundInterface(obj, 'set', 'SaSound',...
                                    'Style', 'Tone',...
                                    'Vol', 0.005,...
                                    'Freq1', value(current_sa),...
                                    'Dur1', value(stimulus_dur),...
                                    'Loop', 0, 'Bal', 0);
                SoundInterface(obj, 'set', 'SbSound',...
                                    'Style', 'Tone',...
                                    'Vol', 0.005,...
                                    'Freq1', value(current_sb),...
                                    'Dur1', value(stimulus_dur) + value(sb_extra),...
                                    'Loop', 0, 'Bal', 0);

            case 'Loudness [dB]'
                SoundInterface(obj, 'set', 'SaSound',...
                                    'Style', 'PinkNoise',...
                                    'Vol', value(current_sa),...
                                    'Dur1', value(stimulus_dur),...
                                    'Loop', 0, 'Bal', sb_bal);
                SoundInterface(obj, 'set', 'SbSound',...
                                    'Style', 'PinkNoise',...
                                    'Vol', value(current_sb),...
                                    'Dur1', value(stimulus_dur) + value(sb_extra),...
                                    'Loop', 0, 'Bal', sa_bal);

            case 'Classical [dB]'
                % TODO Make Sb and Sa dur separable
                srate = SoundManagerSection(obj, 'get_sample_rate');
                [AUD1, AUD2] = classical_loudness_stim(2000, 20000,...
                                                       value(stimulus_dur),...
                                                       value(current_sa), value(current_sb),...
                                                       110, srate, 'GAUS');
                SoundManagerSection(obj, 'set_sound', 'SaSound', [AUD1' ; AUD1']);
                SoundManagerSection(obj, 'set_sound', 'SbSound', [AUD2' ; AUD2']);

        end

        % If Sa/Sb or all stimuli are set to off, set volumes to 0
        % TODO Remove in favor of flexible wave construction
        if ~value(sasb_on) || ~value(stimuli_on)
            SoundInterface(obj, 'set', 'SaSound', 'Vol', 0);
            SoundInterface(obj, 'set', 'SbSound', 'Vol', 0);
        end
        StimulusSection(obj, 'push_sounds_bpod');


    %---------------------------------------------------------------%
    %          push_sounds_bpod                                     %
    %---------------------------------------------------------------%
    % This case should be called anytime sounds get modified via SoundInterface.
    % See: https://github.com/Brody-Lab/ExperPort/commit/2bd0c6c5ea1f84b6d2742c0b86e39f924251d913
    case 'push_sounds_bpod'
        if bSettings('get', 'RIGS', 'bpod') == 1 && ...
            strcmp(bSettings('get','RIGS','sound_machine_server'), 'localhost')
            global BpodSystem
            if strcmp(class(BpodSystem.PluginObjects.SoundServer), 'BpodAudioPlayer')
                SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
                BpodSystem.PluginObjects.SoundServer.push;
            end
        end


    %---------------------------------------------------------------%
    %          set_pairs                                            %
    %---------------------------------------------------------------%
    % Manually specify pairs to be added to stim_table. Example call:
    %   pairs = [3000 6000; 3000 6000; 6000 12000; 12000 6000];
    %   StimulusSection(obj, 'set_pairs', pairs);
    case 'set_pairs'
        pairs = varargin{1};
        stim_values.value = unique(pairs);
        stim_table.value = {};
        for ipair = 1 : size(pairs, 1)
            pprob.value = 1 / size(pairs, 1);
            side.value = 'L';
            Sa.value = pairs(ipair, 1);
            Sb.value = pairs(ipair, 2);
            StimulusSection(obj, 'add_pair');
        end
        StimulusSection(obj, 'compute_left_right_pairs')


    %---------------------------------------------------------------%
    %          compute_symmetric_pairs                              %
    %---------------------------------------------------------------%
    % Given a list of stimulus points, computes a list of possible
    % Sa-Sb pairs that maintain symmetry across the decision boundary.
    case 'compute_symmetric_pairs'
        stim_table.value = {};
        pairs = [];
        svals = sort(value(stim_values));
        for ival = 1 : length(svals) - 1
            pairs = [value(pairs) ; perms([svals(ival), svals(ival+1)])];
        end
        for ipair = 1 : size(pairs, 1)
            pprob.value = 1 / ((length(svals) - 1) * 2);
            side.value = 'L';
            Sa.value = pairs(ipair, 1);
            Sb.value = pairs(ipair, 2);
            watermult.value = 1.0;
            StimulusSection(obj, 'add_pair');
        end

    %---------------------------------------------------------------%
    %          compute_all_possible_pairs                           %
    %---------------------------------------------------------------%
    % Given a list of stimulus points, computes the list of all possible
    % pairs, excluding the Sa == Sb case.
    case 'compute_all_possible_pairs'
        pairs_base = nchoosek(stim_values, 2);
        for irow = 1 : size(pairs_base, 1)
            stimulus_pairs.value = [stimulus_pairs.value; perms(pairs_base(irow, :))];
        end

    %---------------------------------------------------------------%
    %          compute_left_right_pairs                             %
    %---------------------------------------------------------------%
    case 'compute_left_right_pairs'
        for ipair = 1 : size(value(stim_table), 1)
            switch value(rule)
                case 'Sa < Sb Right'
                    if stim_table{ipair,3} < stim_table{ipair,4}
                        stim_table{ipair,2} = 'R';
                    else
                        stim_table{ipair,2} = 'L';
                    end
                case 'Sa < Sb Left'
                    if stim_table{ipair,3} < stim_table{ipair,4}
                        stim_table{ipair,2} = 'L';
                    else
                        stim_table{ipair,2} = 'R';
                    end
            end
        end


    %---------------------------------------------------------------%
    %          select_random_pair                                   %
    %---------------------------------------------------------------%
    % Selects random Sa/Sb pair based on current value of current_side
    % and updates current_sa and current_sb to reflect it.
    case 'select_random_pair'
        st = value(stim_table);
        probs = [st{:,1}]';
        sides = [st{:,2}]';
        hrate = [st{:,5}]';
        requestedside = value(current_side);
        requestedside = requestedside(1); % 'L' or 'R'

        probs(sides ~= requestedside) = 0; % Set p of nonrequested pairs to 0
        probs = probs / sum(probs);        % Re-normalize probs

        % We set the hits for the nonrequested side all to 1. This ensures that if
        % using multibias (where probability of choosing a pair is inversely
        % proportional to the hit rate), these are never picked.
        hrate(sides ~= requestedside) = 1.0; 
        % It is possible for some pairs to have hrate = NaN (100% violation rate).
        % For these, we assume their hit rate is at chance level.
        hrate(isnan(hrate)) = 0.5;
        hrate = hrate / sum(hrate);

        % If hitScaling = 0, we use the prior probs column. If hitScaling = 1,
        % then probabilities are dictated by the performance.
        probs = ((1 - value(multibias_scaling)) * probs) + (value(multibias_scaling) * (1 - hrate));
        probs = probs / sum(probs);

        % finally, select a pair
        current_pair.value = randsample(1 : size(st, 1), 1, true, probs);
        current_sa.value = st{value(current_pair),3};
        current_sb.value = st{value(current_pair),4};


    %---------------------------------------------------------------%
    %          multibias_scaling_callback                           %
    %---------------------------------------------------------------%
    case 'multibias_scaling_callback'
        % Ensure that multibias scaling is between 0 and 1
        multibias_scaling.value = clamp(value(multibias_scaling), 0, 1);

    %---------------------------------------------------------------%
    %          LRassign_button_callback                             %
    %---------------------------------------------------------------%
    case 'LRassign_button_callback'
        StimulusSection(obj, 'compute_left_right_pairs');
        StimulusSection(obj, 'display_table');

    %---------------------------------------------------------------%
    %          show/hide/close                                      %
    %---------------------------------------------------------------%
    case 'show_hide_soundui_window'
        if soundui_toggle == 0, set(value(soundui_window), 'Visible', 'off');
        else                    set(value(soundui_window), 'Visible', 'on');
        end
    case 'hide_soundui_window'
        set(value(soundui_window), 'Visible', 'off'); soundui_toggle.value = 0;

    case 'show_hide_stim_table_window'
        if stim_table_toggle == 0, set(value(stim_table_window), 'Visible', 'off');
        else                       set(value(stim_table_window), 'Visible', 'on');
        end
    case 'hide_stim_table_window'
        set(value(stim_table_window), 'Visible', 'off'); stim_table_toggle.value = 0;
    case 'close'
        delete(value(stim_table_window));
        delete(value(soundui_window));


    otherwise
        warning('PWM2/StimulusSection - Unknown action: %s\n', action);

end
end


function avg = compute_cumulative_avg(curravg, x, n)
    if isnan(curravg) avg = x;
    else avg = (x + n*curravg)/(n + 1);
    end
end

function x = clamp(x, lowerbound, upperbound)
    x = min(max(x, lowerbound), upperbound);
end

function rowstr = format_row_str(obj, pprob, side, Sa, Sb, frachit, fracviol, nvalid, ntotal, watermult)
    if ~exist('frachit','var') frachit = NaN; end
    if ~exist('fracviol','var') fracviol = NaN; end
    if ~exist('nvalid','var') nvalid = 0; end
    if ~exist('ntotal','var') ntotal = 0; end
    if ~exist('watermult','var') watermult = 1; end
    rowstr = sprintf('%5.3f   %s      %5.5g     %5.5g     %5.2g     %5.2g     %5d     %3d  %5.2g', ...
        pprob, side, Sa, Sb, frachit, fracviol, nvalid, ntotal, watermult);
end


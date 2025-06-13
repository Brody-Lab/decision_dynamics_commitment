% Stimulus Section
% 
% Taken from PWM2 written by Jorge Yanar, upated by Jess Breda for DMS
% 
% Goal:
%   this section creates and manages the sa and sb sound stimuli 
%
%   given the side for the current trial (determined by SideSection), 
%   generates the appropriate sounds given rule using SoundInterface.
%
% Case Info:
%   init
%           this is where all the gui information is initatied
%   
%   prepare_next_trial
%           where sa and sb are updated, sent and plotted for the next trial
%
%   set_preset
%           if a preset stimulus group is selected from the stimulus table in GUI
%           update the sound pairs to represent this
%   add_pair
%           add an sa, sb pair to the stimulus table
%
%   update_pair
%           update the values of a modified sa, sb pair that was already
%           in the stimulus table
%
%   delete_pair
%           remove sa, sb pair from stimulus table
%
%   normalize_pprob
%           normalizes the probability of all pairs in stimulus table
%           to sum to 1
%
%   display_table
%           displays the stimulus table to the GUI (i think? -JRB)
%
%   play_sound
%           plays sound pair highlightend in dispaly table with
%           current trial delay lengths and go sound
%
%   plot_pairs
%           plots the current valid sa, sb pairs and highlights the
%           pair used for the current trial
%
%   set_soundui_properties
%           updates SoundInterface given selected sa and sb
%
%   set_pairs
%           given an array of pairs, manually specifies pairs to be
%           added to the stim table
%   
%   compute_match_nonmatch_set (not currently written 2022-06)
%           given an sa and sb pair, generates a complete set for a
%           symmetric match/non-match set 
%
%   compute_left_right_pairs
%           given the pairs in the stimulus table and the current
%           rule, side column in stimulus table
%
%   select_random_pair
%           given current side, valid pairs and pair probabilities,
%           selects an sa,sb pair at random
%
%   show/hide/close
%           multiple cases used to control the subwindows created within this file

% TODO Incorporate multibias
% TODO write compute_match_nonmatch_set (see speicfic todos)

function [x, y] = StimulusSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action

    %---------------------------------------------------------------%
    %          init                                                 %
    %---------------------------------------------------------------%
    case 'init'
        x = varargin{1}; y = varargin{2};

        % Initialize with defaults for frequency task.
        SoloParamHandle(obj, 'stim_values', 'value', [3000 12000]);
        SoloParamHandle(obj, 'stim_table', 'value', {}, 'save_with_settings', 1);
        
        %%% Sb extra functionality (extend Sb for longer than stimulus_dur)
        NumeditParam(obj, 'sb_extra', 0, x, y, 'label', 'Sb extra',...
            'labelfraction', 0.5, 'position', [x+300 y 100 20],...
            'TooltipString', ['Extra duration in sec to play sb for in addition \nto ',...
                              'stimulus_dur. So total time is sb_extra + stim_dur,,\nand',...
                              'this allows for the sound to be played into reward']);                           
        set_callback(sb_extra, {mfilename, 'set_soundui_properties'}); 
        next_row(y);
        
        MenuParam(obj, 'stimulus_type', {'Frequency [Hz]', 'Loudness [dB]'}, 1, x, y,...
            'position', [x y 170 20], 'label', 'Stim. type', 'labelfraction', 0.4,...
            'TooltipString', 'Stimulus type.');
        PushbuttonParam(obj, 'stimulus_type_ok', x, y, 'position', [x+170 y 30 20],...
            'label', 'OK', 'TooltipString', 'Set stimulus type.');
        set_callback(stimulus_type_ok, {mfilename, 'stimulus_type_ok_callback'});
        
        DispParam(obj, 'current_sa', '3000', x, y, 'labelfraction', 0.4, 'label',...
            'Sa [Hz]', 'position', [x+200 y 100 20]);
        DispParam(obj, 'current_sb', '12000', x, y, 'labelfraction', 0.4, 'label',...
            'Sb [Hz]', 'position', [x+300, y, 100, 20]);
        % keep track of current pair for stim table updates
        SoloParamHandle(obj, 'current_pair_idx', 'value', 1); 
        
        next_row(y);
        MenuParam(obj, 'rule', {'Match = Left','Match = Right'}, 1, x, y, ...
            'position', [x y 170 20], 'label', 'Rule', 'labelfraction', 0.4, ...
            'TooltipString', ['Rule dictating whether match = L port or R port\n', ...
                              'with nonmatch being the opposing port.']);
        PushbuttonParam(obj, 'rule_ok', x, y, 'position', [x+170 y 30 20], 'label', 'OK');
        set_callback(rule_ok, {mfilename, 'compute_left_right_pairs'});
        
        %TODO update this to sasb_on like PWM2 (need to update
        %trainingsection calls as well)
        ToggleParam(obj, 'stimuli_on', 1, x, y, 'position', [x+200 y 100 20],...
            'OnString', 'Stimuli ON', 'OffString', 'Stimuli OFF',...
            'TooltipString', 'Turn sa/sb on or off');
        
        %%% --- SOUND VOLS SUBWINDOW START ---
        ToggleParam(obj, 'sound_vol_params_toggle', 0, x,y, 'position', [x+300 y 100 20],...
            'OnString', 'Sound Vols Showing',...
            'OffString', 'Sound Vols Hidden', 'TooltipString', 'Show/hide freq dependent sound vol info');
        set_callback(sound_vol_params_toggle, {mfilename, 'show_hide_sound_vol_params_window'});
        oldx=x; oldy=y; parentfig=double(gcf);
        
        SoloParamHandle(obj, 'sound_vol_params_window', 'value',...
            figure('Position', [100 100 400 190],...
                   'MenuBar', 'none',...
                   'Name', 'Sound Vol Params',...
                   'NumberTitle', 'off',...
                   'CloseRequestFcn', [mfilename '(' class(obj) ', ''hide_sound_vol_params_window'');']));
        set(gcf, 'Visible', 'off');
        x=5;y=5;
   
        NumeditParam(obj, 'vol_12_khz',0.005, x, y,'labelfraction',0.5,...
            'TooltipString', 'Volume at which to play 12khz to target ~65 dB',...
            'label', '12khz Vol', 'position', [x y 200 20]);next_row(y,1.1);
        NumeditParam(obj, 'vol_3_khz',0.0002, x, y,'labelfraction',0.5,...
            'TooltipString', 'Volume at which to play 3khz to target ~65 dB',...
            'label', '3khz Vol', 'position', [x y 200 20]);       
        x=oldx; y=oldy;
        figure(parentfig);
        %%% --- SOUND VOLS SUBWINDOW END ---
        
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
            figure('position', [50 150 210 300],...
                   'MenuBar', 'none',...
                   'NumberTitle', 'off',...
                   'Name', 'SoundUI: Sa Sb',...
                   'CloseRequestFcn', [mfilename '(' class(obj) ', ''hide_soundui_window'');']));
        set(value(soundui_window), 'Visible', 'off');
        x = 5; y = 5;

        [x, y] = SoundInterface(obj, 'add', 'SaSound', x, y, 'Duration', value(stimulus_dur)); next_row(y, 0.5);
        [x, y] = SoundInterface(obj, 'add', 'SbSound', x, y, 'Duration', value(stimulus_dur)); next_row(y, 0.5);
        
        % TODO add in SileceSound as done in PWM2
        x = oldx; y = oldy; figure(mainfig);
        %%% --- SOUNDUI SA / SB SUBWINDOW END ---


        %%% --- SOUND PAIRS TABLE SUBWINDOW START ---
        oldx = x; oldy = y; mainfig = double(gcf);
        
        SoloParamHandle(obj, 'stim_table_window', 'saveable', 0, 'value', ...
            figure('position', [409 300 1000 285], ...
                   'MenuBar', 'none', ...
                   'NumberTitle', 'off', ...
                   'Name', 'Sound Pairs Table', ...
                   'CloseRequestFcn', [mfilename ...
                   '(' class(obj) ', ''hide_stim_table_window'');']));      
        set(value(stim_table_window), 'Visible', 'off');

        x = 10; y = 5; boty = 5; col_wid=100;
        
        % Footer Parameters
        %%% Pair Probability
        %TODO add in update_pprob_callback
        NumeditParam(obj, 'pprob', 0.5, x, y, 'position', [x y+20 col_wid 20], ...
            'labelfraction', 0.6, ...
            'TooltipString', 'Prior probability of choosing this stimulus pair; must be [0,1]');
        % TODO
        PushbuttonParam(obj, 'update_pprob', x, y, 'position', [x y col_wid 20],...
            'TooltipString', 'not yet implemented');
        % set_callback(update_pprob, {mfilename, 'update_pprob_callback'});

        %%% Pair Side
        MenuParam(obj, 'side', {'L','R'}, 1, x, y, 'position', [x+col_wid+10 y+20 col_wid*0.75 20],...
            'labelfraction', 0.5, ...
            'TooltipString', 'Correct side choice for this stimulus pair');
        % TODO
        PushbuttonParam(obj, 'update_side', x, y, 'position', [x+col_wid+10 y col_wid*0.75 20],...
            'TooltipString', 'not yet implemented');
        % set_callback(update_side, {mfilename, 'update_side_callback'});

        %%% Sa value (if frequency then Hz)
        NumeditParam(obj, 'Sa', 25, x, y, 'position', [x+(2*col_wid) y+20 col_wid 20], ...
          'labelfraction', 0.3);
        % TODO
        PushbuttonParam(obj, 'update_sa', x, y, 'position', [x+(2*col_wid) y col_wid 20],...
            'TooltipString', 'not yet implemented');
        % set_callback(update_sa, {mfilename, 'update_sa_callback'});

        %%% Sb value (if frequency then Hz)    
        NumeditParam(obj, 'Sb', 25, x, y, 'position', [x+(3*col_wid)+5 y+20 col_wid 20], ...
          'labelfraction', 0.3);
        % TODO
        PushbuttonParam(obj, 'update_sb', x, y, 'position', [x+(3*col_wid)+5 y col_wid 20],...
            'TooltipString', 'not yet implemented');
        % set_callback(update_sb, {mfilename, 'update_sb_callback'});

        %%% Water Multiplier
        NumeditParam(obj, 'watermult', 1.0, x, y, 'position', [x+(4*col_wid)+10 y+20 col_wid 20], ...
            'labelfraction', 0.6);
        PushbuttonParam(obj, 'update_wtrmlt', x, y, 'position', [x+(4*col_wid)+10 y col_wid 20],...
            'TooltipString', 'not yet implemented');
        % TODO
        % set_callback(update_wtrmlt, {mfilename, 'update_wtrmlt_callback'});

        x = 530;
        PushbuttonParam(obj, 'add_pair_button', x, y, 'position', [x y+20 col_wid 20], 'label', 'Add Pair');
        PushbuttonParam(obj, 'del_pair_button', x, y, 'position', [x y col_wid 20], 'label', 'Delete Pair');
        PushbuttonParam(obj, 'upd_pair_button', x, y, 'position', [x+col_wid+5 y+20 col_wid 20], 'label', 'Update Pair', ...
          'TooltipString', 'replaces the currently selected row with values in the gui elements above');
        PushbuttonParam(obj, 'play_snd', x, y, 'position', [x+(2*col_wid)+10 y+20 80 20], 'label', 'Play Sound');
        PushbuttonParam(obj, 'stop_snd', x, y, 'position', [x+(2*col_wid)+10 y 80 20], 'label', 'Stop Sound');
        set_callback(add_pair_button, {mfilename, 'add_pair'});
        set_callback(del_pair_button, {mfilename, 'delete_pair'});
        set_callback(upd_pair_button, {mfilename, 'update_pair'});
        set_callback(play_snd, {mfilename, 'play_sound'});
        set_callback(stop_snd, {mfilename, 'stop_sound'});
        next_row(y, 2.1);
        x = 10;

        % Column values of table
        switch value(stimulus_type)
            case 'Loudness [dB]' % ! Not currently in use in DMS
                header_str = {'PProb   Side  Sa [dB]   Sb [dB]   wtrmlt  frachit   fracviol   nvalid  ntotal'};
            case 'Frequency [Hz]'
                header_str = {'PProb   Side  Sa [Hz]   Sb [Hz]   wtrmlt  frachit   fracviol   nvalid  ntotal'};
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

        % Header Parameters    
        y = y+210;
        HeaderParam(obj, 'panel_title', 'Sound Stimulus Pairs', x, y, ...
            'position', [x y 140 20]);
        set(get_ghandle(panel_title), 'BackgroundColor', [215 190 200]/255);

        MenuParam(obj, 'presets', {'3-12 Cross',...
                                   'Sa Discrim Btm','Sa Btm to 1/2 XOR',...
                                   'Sb Discrim L','Sb L to 1/2 XOR',...
                                   'Custom'},...
            1, x, y, 'position', [x+145 y 200 20], ...
            'TooltipString', ['\nSelect preset stimulus set such as a simple cross,\n'...
                              'w/ 3 & 12 kHz or custom manual settings.'],...
            'labelfraction', 0.35, 'labelpos', 'left');
        set_callback(presets, {mfilename, 'set_preset'});
        
        PushbuttonParam(obj, 'normal', x, y, 'position', [x+360 y 80 20], ...
            'label', 'Normalize PProb', ...
            'TooltipString', ['Normalizes the PProb (prior probabilities) column so that it sums to unity '...
                              '\nWhen RED, the sum is incorrect and this button needs to be pressed!']); 
        set_callback(normal, {mfilename, 'normalize_pprob'});
        
        PushbuttonParam(obj, 'fsave', x, y, 'position', [x+460 y 80 20], ...
            'label', 'Save to File', ...
            'TooltipString', 'not yet implemented');
        
        PushbuttonParam(obj, 'fload', x, y, 'position', [x+540 y 80 20], ...
            'label', 'Load from File',...
            'TooltipString', 'not yet implemented');
        
        figure(mainfig); x = oldx; y = oldy;
        %%% --- SOUND PAIRS TABLE SUBWINDOW END ---


         
        %%% Generate some sound pairs based off the initialized stimuli
        StimulusSection(obj, 'compute_match_nonmatch_set', value(stim_values)); %!Still being written
        StimulusSection(obj, 'compute_left_right_pairs');
        StimulusSection(obj, 'display_table');
        
        %%% Generate plot of stimulus set
        next_row(y,1.5);
        PushbuttonParam(obj, 'draw', x, y, 'position', [x+200 y 30 20], 'label', 'draw');
        newaxes = axes;
        SoloParamHandle(obj, 'pairsfig', 'saveable', 0, 'value', double(newaxes));
        set(value(pairsfig), 'position', [.3 .7 .18 .18]);
        StimulusSection(obj, 'plot_pairs');
        set_callback(draw, {mfilename, 'plot_pairs'});
        
        %%% Title
        next_row(y, 8);
        SubheaderParam(obj, 'lab0', 'Stimulus Section',x, y, 'position', [x y 400 20]);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% SETUP INTERNAL VARS %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        SoloParamHandle(obj, 'sa_vol', 'value', 0.001);
        SoloParamHandle(obj, 'sb_vol', 'value', 0.001);
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%    SEND OUT VARS    %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        SoloFunctionAddVars('TrainingSection', 'rw_args', {...
            'stim_values', 'stimulus_type', 'rule', 'stimuli_on',...
            'presets', 'sb_extra'})
            
        DeclareGlobals(obj, 'ro_args', ...
             {'stimuli_on', 'current_pair_idx', 'current_sa',...
             'current_sb', 'stimulus_type', 'rule', 'stim_table'});

        % % TODO Sennding the stim_table to history section for
        % % TODO perf based updates
        % SoloFunctionAddVars('HistorySection', 'ro_args', 'stim_table');

        
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
        
    %---------------------------------------------------------------%
    %          stimulus_type_ok_callback                            %
    %---------------------------------------------------------------%
    case 'stimulus_type_ok_callback'
        StimulusSection(obj, 'set_preset');
        ShapingSection(obj, 'set_soundui_properties'); % Updates GoSound, ViolationSound, etc
        
    %---------------------------------------------------------------%
    %          set_preset                                           %
    %---------------------------------------------------------------%
    case 'set_preset'
        switch value(presets)
            case 'Custom'
                % do nothing- let the user add their own info, but
                % leave the current pairs intact, and reset performance information
                % TODO- test if works
                % st = value(stim_table);
                % st(:, 5) = NaN; % frachit
                % st(:, 6) = NaN; % fracviol
                % st(:, 7) = 0;   % nvalid
                % st(:, 8) = 0;   % ntotal
                % stim_table.value = st;
                
            case '3-12 Cross'
                stim_table.value = {};
                switch value(stimulus_type)
                    case 'Frequency [Hz]'
                        Sa.value = 3000;  Sb.value = 12000;  StimulusSection(obj, 'add_pair');
                        Sa.value = 3000;  Sb.value = 3000;   StimulusSection(obj, 'add_pair');
                        Sa.value = 12000; Sb.value = 3000;   StimulusSection(obj, 'add_pair');
                        Sa.value = 12000; Sb.value = 12000;  StimulusSection(obj, 'add_pair');
                        StimulusSection(obj, 'compute_left_right_pairs');                    
                end
            
            case 'Sa Discrim Btm'
                stim_table.value = {};
                switch value(stimulus_type)
                    case 'Frequency [Hz]'
                        Sa.value = 3000;  Sb.value = 3000;   StimulusSection(obj, 'add_pair');
                        Sa.value = 12000; Sb.value = 3000;   StimulusSection(obj, 'add_pair');
                        StimulusSection(obj, 'compute_left_right_pairs');                    
                end
                
            case 'Sa Btm to 1/2 XOR'
                stim_table.value = {};
                switch value(stimulus_type)
                    case 'Frequency [Hz]'
                        Sa.value = 3000;  Sb.value = 3000; pprob.value = 0.25;   
                        StimulusSection(obj, 'add_pair');
                        Sa.value = 12000; Sb.value = 3000; pprob.value = 0.5;    
                        StimulusSection(obj, 'add_pair');
                        Sa.value = 12000; Sb.value = 12000; pprob.value = 0.25; 
                        StimulusSection(obj, 'add_pair');      
                        StimulusSection(obj, 'compute_left_right_pairs'); 
                end    
                
            case 'Sb Discrim L'
                stim_table.value = {};
                switch value(stimulus_type)
                    case 'Frequency [Hz]'
                        Sa.value = 3000;  Sb.value = 3000;   StimulusSection(obj, 'add_pair');
                        Sa.value = 3000; Sb.value = 12000;   StimulusSection(obj, 'add_pair');
                        StimulusSection(obj, 'compute_left_right_pairs');                    
                end
            case 'Sb L to 1/2 XOR'
                stim_table.value = {};
                switch value(stimulus_type)
                    case 'Frequency [Hz]'
                        Sa.value = 3000;  Sb.value = 3000; pprob.value = 0.25;
                        StimulusSection(obj, 'add_pair');
                        Sa.value = 3000; Sb.value = 12000; pprob.value = 0.5;
                        StimulusSection(obj, 'add_pair');
                        Sa.value = 12000; Sb.value = 12000; pprob.value = 0.25;
                        StimulusSection(obj, 'add_pair');                        
                        StimulusSection(obj, 'compute_left_right_pairs');                    
                end              
            
        end
        StimulusSection(obj, 'normalize_pprob');
        StimulusSection(obj, 'select_random_pair');
        StimulusSection(obj, 'set_soundui_properties');
        StimulusSection(obj, 'plot_pairs');
        StimulusSection(obj, 'display_table');
    %---------------------------------------------------------------%
    %          stim table buttons                                   %
    %---------------------------------------------------------------%
    case 'add_pair'
        % Add new pair. Use current values of pprob, side, Sa, Sb, wtrmlt
        idx = rows(stim_table) + 1;
        stim_table{idx,1} = value(pprob);
        stim_table{idx,2} = value(side);
        stim_table{idx,3} = value(Sa);
        stim_table{idx,4} = value(Sb);
        stim_table{idx,5} = value(watermult);
        stim_table{idx,6} = NaN;  % frachit
        stim_table{idx,7} = NaN;  % fracviol
        stim_table{idx,8} = 0;    % nvalid
        stim_table{idx,9} = 0;    % ntotal
        
        newrow = format_row_str(obj, value(pprob), value(side), value(Sa), ...
            value(Sb), value(watermult), NaN, NaN, 0, 0);
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
        newrow = format_row_str(obj, value(pprob), value(side),...
                                     value(Sa), value(Sb), value(watermult),...
                                    stim_table{k,6}, stim_table{k,7},...
                                    stim_table{k,8}, stim_table{k,9});
        dtable.value = [temp(1:n-1); cell(1,1); temp(n+1:end)];
        dtable{n} = newrow;
        
        set(get_ghandle(stable), 'string', value(dtable));
        stable.value = length(value(dtable));

        stim_table{k,1} = value(pprob);
        stim_table{k,2} = value(side);
        stim_table{k,3} = value(Sa);
        stim_table{k,4} = value(Sb);
        stim_table{k,5} = value(watermult);

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
        prb = prb./sum(prb);
        for i = 1 : size(value(stim_table), 1)
            stim_table{i,1} = prb(i);
        end
        StimulusSection(obj, 'display_table');

    % TODO
    case 'update_pprob'
    case 'update_side'
    case 'update_sa'
    case 'update_sb'
    case 'update_wtrmlt'        

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
    
    case 'play_sound'
        n = get(get_ghandle(stable), 'value'); % get selected row
        n = n(1);
        if n==1, return; end;  %if the label row was selected, do nothing
        k = n-1;

        % Set current SaSound and SbSound to these pairs temporarily, using SoundInterface
        % TODO update with the vols for each sound?
        switch value(stimulus_type)
        case 'Frequency [Hz]' 
            SoundInterface(obj, 'set', 'SaSound',...
                                'Style', 'Tone',...
                                'Vol', 0.001,...
                                'Freq1', stim_table{k,3},...
                                'Dur1', value(stimulus_dur),...
                                 'Loop', 0, 'Bal', 0);
            SoundInterface(obj, 'set', 'SbSound',... 
                                'Style', 'Tone',...
                                'Vol', 0.001,...
                                'Freq1', stim_table{k,4},...
                                'Dur1', value(stimulus_dur) + value(sb_extra),...
                                'Loop', 0, 'Bal', 0);
        end

        StimulusSection(obj, 'push_sounds_bpod');
        SoundManagerSection(obj, 'play_sound', 'SaSound');
        pause(value(stimulus_dur) + value(delay_dur));
        SoundManagerSection(obj, 'play_sound', 'SbSound');
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
        nvalid = stim_table{value(current_pair_idx), 8}; % Num of valid trials for this pair
        ntotal = stim_table{value(current_pair_idx), 9}; % Num of total presentations for this pair
        
        switch result
        %%% Hit, error, or temperror
        case {1, 2, 4}
           
            % update frachit for this pair (was_hit from HistorySection)
            frachit = stim_table{value(current_pair_idx), 6};
            stim_table{value(current_pair_idx), 6} = compute_cumulative_avg(frachit, was_hit, nvalid);
    
            % update fracviol for this pair (was_viol from HistorySection)
            fracviol = stim_table{value(current_pair_idx), 7};
            stim_table{value(current_pair_idx), 7} = compute_cumulative_avg(fracviol, was_viol, ntotal);
    
            % update counters
            stim_table{value(current_pair_idx), 8} = nvalid + 1;
            stim_table{value(current_pair_idx), 9} = ntotal + 1;
        
        %%% Violation
        case 3
            % update fracviol & counter for this pair (was_viol from HistorySection)
            fracviol = stim_table{value(current_pair_idx), 7};
            stim_table{value(current_pair_idx), 7} = compute_cumulative_avg(fracviol, was_viol, ntotal);
            stim_table{value(current_pair_idx), 9} = ntotal + 1;

        otherwise
            error(sprintf('PWM2/StimulusSection/update_performance: Invalid result: %d', result))
        end
    
        StimulusSection(obj, 'display_table');

    %---------------------------------------------------------------%
    %          plot_pairs                                           %
    %---------------------------------------------------------------%    
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
    case 'set_soundui_properties'
        % Update stimuli to reflect current parameters set in the GUI.
        switch value(stimulus_type)
            case 'Frequency [Hz]'
                
                StimulusSection(obj, 'calculate_sound_volume', 'sa', value(current_sa));
                StimulusSection(obj, 'calculate_sound_volume', 'sb', value(current_sb));

                SoundInterface(obj, 'set', 'SaSound', 'Style', 'Tone', 'Vol', value(sa_vol),...
                    'Freq1', value(current_sa), 'Dur1', value(stimulus_dur), 'Loop', 0, 'Bal', 0);
                SoundInterface(obj, 'set', 'SbSound', 'Style', 'Tone', 'Vol', value(sb_vol),...
                    'Freq1', value(current_sb), 'Dur1', value(stimulus_dur) + value(sb_extra), 'Loop', 0, 'Bal', 0);
        end
        if ~value(stimuli_on) % set volume to 0 if stimuli turned off
            %! this is already taken care of by the state machine having different
            %! logic if stimuli are off & reward type is give, keeping for redundancy
            SoundInterface(obj, 'set', 'SaSound', 'Vol', 0);
            SoundInterface(obj, 'set', 'SbSound', 'Vol', 0);
        end
        StimulusSection(obj, 'push_sounds_bpod');
        
    %---------------------------------------------------------------%
    %          push_sounds_bpod                                     %
    %---------------------------------------------------------------%
    case 'push_sounds_bpod'
        % This case should be called anytime sounds get modified via SoundInterface.
        % See: https://github.com/Brody-Lab/ExperPort/commit/2bd0c6c5ea1f84b6d2742c0b86e39f924251d913
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
    %          compute_match_nonmatch_set                           %
    %---------------------------------------------------------------%
    case 'compute_match_nonmatch_set'
        % Given an sa,sb pair, will generate the three remaining 
        % pairs for symmetry. Example call:
        %   pair = [3000 12000] 
        %   StimulusSection(obj, 'computer_match_nonmatch_set', pair);
        %   returns to table : [3000 12000; 12000 3000 ; 12000 12000 ; 3000 3000]
        stimuli = varargin{1};
        % stim_table.value = {} 
        
        % duplicate the stimuli to create combinations
        stimuli_for_combo = cat(2, stimuli, stimuli);
        % find all combinations of pairs of 2 & grab unique (rows)
        pairs = unique(nchoosek(stimuli_for_combo, 2), 'rows');
        for ipair = 1 : length(pairs)
            % check if already in stim table?
            
            pprob.value = 1 / length(pairs);
            side.value = 'L'; % will be corrected
            Sa.value = pairs(ipair, 1);
            Sb.value = pairs(ipair, 2);
            StimulusSection(obj, 'add_pair');
        end
        StimulusSection(obj, 'compute_left_right_pairs');

        % TODO using the delete pair code, implment this to be able 
        % TODO to grab selected table value and then apply the set update
        % TODO to it to create the rest of the set
        % TODO might have to make a separate case that calls this one within it?


    %---------------------------------------------------------------%
    %          compute_left_right_pairs                             %
    %---------------------------------------------------------------%
    case 'compute_left_right_pairs'
        for ipair = 1 : size(value(stim_table), 1)
            switch value(rule)
                case 'Match = Left'
                    if stim_table{ipair,3} == stim_table{ipair,4}
                        stim_table{ipair,2} = 'L';
                    else
                        stim_table{ipair,2} = 'R';
                    end
                case 'Match = Right'
                    if stim_table{ipair,3} == stim_table{ipair,4}
                        stim_table{ipair,2} = 'R';
                    else
                        stim_table{ipair,2} = 'L';
                    end
            end
        end
        
    %---------------------------------------------------------------%
    %          select_random_pair                                   %
    %---------------------------------------------------------------%
    case 'select_random_pair'
        % Selects random Sa/Sb pair based on current value of current_side
        % and updates current_sa and current_sb to reflect it.
        st = value(stim_table);
        probs = [st{:,1}]';
        sides = [st{:,2}]';
        requestedside = value(current_side);
        requestedside = requestedside(1); % 'L' or 'R'
        probs(sides ~= requestedside) = 0;
        probs = probs / sum(probs);
        
        current_pair_idx.value = randsample(1:size(st,1), 1, true, probs);
        current_sa.value = st{value(current_pair_idx),3};
        current_sb.value = st{value(current_pair_idx),4};



    %---------------------------------------------------------------%
    %          calculate_sound_volume                               %
    %---------------------------------------------------------------%
    case 'calculate_sound_volume'
        % this is specifically for frequency tones and is a hacky way
        % to adjust the volume so that both tones play at roughly the
        % same dB as calculted by Wynne & Jess measuring on rigs with
        % rigtester and both speakers on = 70 dB.

        sound_name = varargin{1}; % 'sa' or 'sb'
        sound_freq = varargin{2}; % freq in Hz

        if sound_freq == 3000
            eval([sound_name '_vol.value = value(vol_3_khz);']);
        elseif sound_freq == 12000
            eval([sound_name '_vol.value = value(vol_12_khz);']);
        else
            error('sound freq volume not known!')
        end
    %---------------------------------------------------------------%
    %          show/hide/close                                      %
    %---------------------------------------------------------------%
    case 'show_hide_sound_vol_params_window'
        if sound_vol_params_toggle == 0, set(value(sound_vol_params_window), 'Visible', 'off');
        else                    set(value(sound_vol_params_window), 'Visible', 'on');
        end
    case 'hide_sound_vol_params_window'
        set(value(sound_vol_params_window), 'Visible', 'off'); sound_vol_params_toggle.value = 0;    
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
        warning('DMS/StimulusSection - Unknown action: %s\n', action);

end
end

    %---------------------------------------------------------------%
    %          helper function                                      %
    %---------------------------------------------------------------%

function avg = compute_cumulative_avg(curravg, x, n)
    % currave is the current avg of the event on t-1
    % x is if the event happened or not on trial t (ie was_hit)
    % n is number of trials, including t
    if isnan(curravg) avg = x;
    else avg = (x + n*curravg)/(n + 1);
    end
end

function rowstr = format_row_str(obj, pprob, side, Sa, Sb, frachit, fracviol, nvalid, ntotal, watermult)
    if ~exist('watermult','var') watermult = 1; end
    if ~exist('frachit','var') frachit = NaN; end
    if ~exist('fracviol','var') fracviol = NaN; end
    if ~exist('nvalid','var') nvalid = 0; end
    if ~exist('ntotal','var') ntotal = 0; end
    rowstr = sprintf('%5.3f   %s      %5.5g     %5.5g   %5.2g    %5.2g     %5.2g     %5d     %3d  %5.2g', ...
        pprob, side, Sa, Sb, frachit, fracviol, nvalid, ntotal, watermult);
end

        






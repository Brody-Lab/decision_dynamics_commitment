%% ShapingSection 
%  Written by Jess Breda & Jorge Yanar April 2022
% 
% Goal:
%   this section contains and manages information on variables used to shape animal behavior
%
%   in here you can toggle: duration growth (adaptive, non-adaptive) for penalties and task
%   events, penalty sounds, poking requirements, SMA values, reward type, rule strictness
%   (e.g. retry allowed), fixation and more 
%
% Case Info :
%   init:             
%           this is where all the gui information is initated
% 
%   prepare_next_trial :
%           where infomration (growing, durations, penalties) is prepared for the
%           next trial based on what happened on the previou trial
% 
%   update_fixed :
%           given a variable to grow, will apply fixed growth adjustment
%           based on specified rate and units
%
%   update_adaptive : (not implmented as of 2022-06)
%           given a variable to grow, will apply adaptive growth adjustment
%           based on specified alpha and beta values
% 
%   update_sampled :
%           given a variable to grow, will update a value from a gaussian 
%           distrbution based on specified mean and standard deviation
%
%   check_duration_boundaries :
%           check if all updated durations are within min/max boundaries and reset
%           them within boundaries if needed
%
%   check_and_set_sound_durations :
%           used to update penalty sound durations if changed from previous trial
%
%   end_session :
%           for growing task variables, save the final duration for potential
%           warm up in next session
%
%   show/hide/close :
%           multiple cases used to control the subwindows created within this file
% 
% TODO - implement JY warm up case

%% CODE
function [x,y] = ShapingSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action,

    % ------------------------------------------------------------------
    %              INIT
    % ------------------------------------------------------------------
        
    case 'init'
        % grab move over a column and grab x and y positions 
        x=varargin{1};
        y=varargin{2};

        %TODO: update water multiplier params box

        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%  SETUP PENALTY VARS %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%

        
        %%% --- PENALTY PARAMETERS SUBWINDOW START ---
        % create window & build from bottom up
        ToggleParam(obj, 'penalty_parameters', 0, x,y, 'position', [x y 200 20],...
            'OnString', 'Penalty Parameters Showing',...
            'OffString', 'Penalty Parameters Hidden', 'TooltipString', 'Show/hide penalty growth info');
        set_callback(penalty_parameters, {mfilename, 'show_hide_penalty_params_window'});
        oldx=x; oldy=y; parentfig=double(gcf);
        
        SoloParamHandle(obj, 'penalty_params_window', 'value',...
            figure('Position', [160 100 400 190],...
                   'MenuBar', 'none',...
                   'Name', 'Penalty paramaters',...
                   'NumberTitle', 'off',...
                   'CloseRequestFcn', [mfilename '(' class(obj) ', ''hide_penalty_params_window'');']));
        set(gcf, 'Visible', 'off');
        x=5;y=5;
        
        % Units for fixed penalty growth 
        MenuParam(obj, 'violation_fixed_growth_unit', {'s';'%'},...
            1, x, y, 'label', 'unit', 'TooltipString',...
            'units of growth rate', 'labelfraction',0.4,'position', [x y 75 20]);
        MenuParam(obj, 'temp_error_fixed_growth_unit', {'s';'%'},...
            1, x, y, 'label', 'unit',...
            'labelfraction',0.4,'position', [x+75 y 75 20]);
        MenuParam(obj, 'error_fixed_growth_unit', {'s';'%'},...
            1, x, y, 'label', 'unit',...
            'labelfraction',0.4,'position', [x+150 y 75 20]);next_row(y,1.1);
        
        % Rate of fixed growth
        NumeditParam(obj, 'violation_fixed_growth_rate',0.002, x, y,'labelfraction',0.5,...
            'TooltipString', 'Rate at which growth is occuring',...
            'label', 'rate', 'position', [x y 75 20]);
        NumeditParam(obj, 'temp_error_fixed_growth_rate',0.002, x, y,'labelfraction',0.5,...
            'label', 'rate', 'position', [x+75 y 75 20]);
        NumeditParam(obj, 'error_fixed_growth_rate',0.002, x, y,'labelfraction',0.5,...
            'label', 'rate','position', [x+150 y 75 20]);next_row(y,1.1);
   
        % stadard deviation value for sample type
        NumeditParam(obj, 'violation_sample_std',0.5, x, y,'labelfraction',0.5,...
            'TooltipString', 'Std of normal distribution to sample violation penalty from',...
            'label', 'std', 'position', [x y 75 20]);
        NumeditParam(obj, 'temp_error_sample_std',0.5, x, y,'labelfraction',0.5,...
            'label', 'std', 'position', [x+75 y 75 20]);        
        NumeditParam(obj, 'error_sample_std',0.5, x, y,'labelfraction',0.5,...
            'label', 'std', 'position', [x+150 y 75 20]);
        NumeditParam(obj, 'inter_trial_sample_std',0.5, x, y,'labelfraction',0.5,...
            'label', 'std', 'position', [x+225 y 75 20]);
        % (same row) error itd multiplier
        NumeditParam(obj, 'inter_trial_error_multiplier',1, x, y,'labelfraction',0.5,...
            'TooltipString', 'If error, multiple base duration by this to get value',...
            'label', 'error', 'position', [x+300 y 75 20]); next_row(y,1.1);

        % Mean value for sample time
        NumeditParam(obj, 'violation_sample_mean',0.5, x, y,'labelfraction',0.5,...
            'TooltipString', 'Mean of normal distribution to sample violation penalty from',...
            'label', 'mean', 'position', [x y 75 20]);
        NumeditParam(obj, 'temp_error_sample_mean',0.5, x, y,'labelfraction',0.5,...
            'label', 'mean', 'position', [x+75 y 75 20]);
        NumeditParam(obj, 'error_sample_mean',0.5, x, y,'labelfraction',0.5,...
            'label', 'mean', 'position', [x+150 y 75 20]);
        NumeditParam(obj, 'inter_trial_sample_mean',0.5, x, y,'labelfraction',0.5,...
            'label', 'mean', 'position', [x+225 y 75 20]); 
        % (same row) violation idt multiplier
        NumeditParam(obj, 'inter_trial_violation_multiplier',1, x, y,'labelfraction',0.5,...
            'TooltipString', 'If viol, multiple base duration by this to get value',...
            'label', 'viol.', 'position', [x+300 y 75 20]); next_row(y,1.1);
        
        % Maximum duration allowed for penalty
        NumeditParam(obj, 'violation_max',5, x, y,'labelfraction',0.5,...
            'TooltipString', 'Maximum penalty duration',...
            'label', 'max', 'position', [x y 75 20]);
        NumeditParam(obj, 'temp_error_max',5, x, y,'labelfraction',0.5,...
            'label', 'max', 'position', [x+75 y 75 20]);
        NumeditParam(obj, 'error_max',5, x, y,'labelfraction',0.5,...
            'label', 'max','position', [x+150 y 75 20]);
        NumeditParam(obj, 'inter_trial_max',5, x, y,'labelfraction',0.5,...
            'label', 'max','position', [x+225 y 75 20]);
        % (same row) hit idt multiplier
        NumeditParam(obj, 'inter_trial_hit_multiplier',1, x, y,'labelfraction',0.5,...
            'TooltipString', 'If hit, multiple base duration by this to get value',...
            'label', 'hit.', 'position', [x+300 y 75 20]); next_row(y,1.1);        
        
        % Minimum (or starting) penalty value allowed 
        NumeditParam(obj, 'violation_min',0.001, x, y,'labelfraction',0.5,...
            'TooltipString', 'Minimum penalty duration used at start',...
            'label', 'min', 'position', [x y 75 20]);
        NumeditParam(obj, 'temp_error_min',0.001, x, y,'labelfraction',0.5,...
            'label', 'min', 'position', [x+75 y 75 20]);
        NumeditParam(obj, 'error_min',0.001, x, y,'labelfraction',0.5,...
            'label', 'min','position', [x+150 y 75 20]);
        NumeditParam(obj, 'inter_trial_min',1, x, y,'labelfraction',0.5,...
            'label', 'min','position', [x+225 y 75 20]);
        SubheaderParam(obj,'lab0', 'perf. mult.',x,y,'position', [x+300 y 70 20]);
        next_row(y,1.2);

        % headers
        SubheaderParam(obj,'lab1', 'violation',x,y,'position', [x y 70 20]);
        SubheaderParam(obj,'lab2', 'temp error',x,y,'position', [x+75 y 70 20]);
        SubheaderParam(obj,'lab3', 'error',x,y,'position', [x+150 y 70 20]);
        SubheaderParam(obj,'lab4', 'inter trial',x,y,'position', [x+225 y 140 20]);
      
        %%% --- PENALTY PARAMETERS SUBWINDOW END ---
        % back to main window
        x=oldx; y=oldy;
        figure(parentfig);
        
        %%% --- PENALTY & GO SOUNDUI SUBWINDOW START ---
        ToggleParam(obj, 'penalty_go_sounds', 0, x,y, 'position', [x+200 y 200 20],...
            'OnString', 'Penalty & Go SoundUI Showing',...
            'OffString', 'Penalty & Go SoundUI Hidden', 'TooltipString', 'Show/hide penalty & go sound info');
        set_callback(penalty_go_sounds, {mfilename, 'show_hide_soundui_window'});
        next_row(y);
        oldx=x; oldy=y; parentfig=double(gcf);
        
        SoloParamHandle(obj, 'soundui_window', 'value', ...
            figure('Position', [950 100 500 300],...
                   'MenuBar', 'none',...
                   'Name', 'SoundUI: Penalties & Go',...
                   'NumberTitle', 'off',...
                   'CloseRequestFcn', [mfilename '(' class(obj) ', ''hide_soundui_window'');']));
        set(gcf, 'Visible', 'off');
        x=5;y=5;
        
        % create penalty sound UI
        [x, y] = SoundInterface(obj, 'add', 'ViolationSound', x, y); 
        [x, y] = SoundInterface(obj, 'add', 'GoSound', x+200, y-140); next_row(y, 0.5);
        [x, y] = SoundInterface(obj, 'add', 'TempErrorSound', x-200, y); 
        [x, y] = SoundInterface(obj, 'add', 'ErrorSound', x+200, y-140);

        SoundInterface(obj, 'set', 'TempErrorSound',... 
                                   'Style', 'SpectrumNoise',...
                                   'Vol', 0.0005,... % 0.003 is 72 dB
                                   'Freq1', 5000,...
                                   'Freq2', 1000,...
                                   'Dur1', 0.5);
        SoundInterface(obj, 'set', 'ErrorSound',...
                                   'Style', 'SpectrumNoise',... 
                                   'Vol', 0.003,... % 72 dB is 0.03 but seems too loud
                                   'Freq1', 10000,...
                                   'Freq2', 10000,...
                                   'Dur1', 0.5);
        SoundInterface(obj, 'set', 'GoSound',...
                                   'Style', 'WhiteNoise',...
                                   'Vol', 0.001,... % 72 dB
                                   'Dur1', 0.05 );
        SoundInterface(obj, 'set', 'ViolationSound',... 
                                   'Style', 'ToneFMWiggle',...
                                   'Vol', 0.001,... % 74 dB
                                   'Freq1', 5000,...
                                   'Dur1', 0.5);
        
        %%% --- PENALTY & GO SOUNDUI SUBWINDOW END ---
        % back to main window
        x=oldx; y=oldy;
        figure(parentfig);
        
        %%% Type determining how duration of penalty is determined 
        MenuParam(obj, 'violation_dur_type', {'stable';'sampled';'growing'},...
            1, x, y, 'label', 'type', 'TooltipString',...
            'how the duration of the violation penalty is being determined', 'labelfraction',0.4,'position', [x y 100 20]);
        MenuParam(obj, 'temp_error_dur_type', {'stable';'sampled';'growing'},...
            1, x, y, 'label', 'type',...
            'labelfraction',0.4,'position', [x+100 y 100 20]);
        MenuParam(obj, 'error_dur_type', {'stable';'sampled';'growing'},...
            1, x, y, 'label', 'type',...
            'labelfraction',0.4,'position', [x+200 y 100 20]);
        MenuParam(obj, 'inter_trial_dur_type', {'stable';'sampled'},...
            1, x, y, 'label', 'type',...
            'labelfraction',0.4,'position', [x+300 y 100 20]);next_row(y,1.1);
        
        %%% Toggle sounds matching timout
        ToggleParam(obj, 'violation_sound_match_timeout', 1, x, y, 'position', [x y 100 20],...
            'OffString', 'Sound != Tout', 'OnString', 'Sound == Tout', ...
            'TooltipString', 'If on, sound will match penalty duration above');
        ToggleParam(obj, 'temp_error_sound_match_timeout', 1, x, y, 'position', [x+100 y 100 20],...
            'OffString', 'Sound != Tout', 'OnString', 'Sound == Tout', ...
            'TooltipString', 'If on, sound will match penalty duration above');
        ToggleParam(obj, 'error_sound_match_timeout', 1, x, y, 'position', [x+200 y 100 20],...
            'OffString', 'Sound != Tout', 'OnString', 'Sound == Tout', ...
            'TooltipString', 'If on, sound will match penalty duration above');
        ToggleParam(obj, 'inter_trial_perf_multiplier', 0, x, y, 'position', [x+300 y 100 20], ...
            'OffString', 'P Mult OFF', 'OnString', 'P Mult ON', ...
            'TooltipString', 'If on, stable itd multiplied by performance type');
        next_row(y,1.1);

        %%% Current penalty timeout duration
        NumeditParam(obj, 'violation_dur',0.1, x, y,'labelfraction',0.6,...
            'TooltipString', 'Timeout duration',...
            'label', 'current', 'position', [x y 100 20]);
        NumeditParam(obj, 'temp_error_dur',0.1, x, y,'labelfraction',0.6,...
            'TooltipString', 'Timeout duration',...
            'label', 'current', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'error_dur',0.1, x, y,'labelfraction',0.6,...
            'TooltipString', 'Timeout duration',...
            'label', 'current','position', [x+200 y 100 20]);
        NumeditParam(obj, 'inter_trial_dur',1, x, y,'labelfraction',0.6,...
            'TooltipString', 'Timeout duration',...
            'label', 'current', 'position', [x+300 y 100 20]);next_row(y,1.1);
       
        %%% sub headers 
        SubheaderParam(obj,'lab1', 'violation',x,y,'position', [x y 65 20]);
        ToggleParam(obj, 'violation_penalty', 0, x,y, 'position', [x+65 y 25 20],...
            'OnString', 'ON',...
            'OffString', 'OFF', 'TooltipString', 'If violation state is being used');
        SubheaderParam(obj,'lab2', 'temp error',x+100,y,'position', [x+100 y 90 20]);
        SubheaderParam(obj,'lab3', 'error',x+200,y,'position', [x+200 y 90 20]);
        SubheaderParam(obj,'lab4', 'inter trial',x+300,y,'position', [x+300 y 90 20]);next_row(y,1.5);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% SETUP FIXATION, REWARD & WATER VARS %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % fixation: total duration & LED
        NumeditParam(obj, 'cp_fixation_dur',1.1, x, y, 'labelfraction', 0.5,...
            'label', 'dur', 'position',[x y 75 20],...
            'TooltipString',  sprintf(['\nadding up the duration of the delays and sounds \nbefore',...
                             ' the go cue. Used to time fixation wave in the SMA. \nDepending',...
                             ' on curriculum, animal may not have to poke whole period']));
        ToggleParam(obj, 'fixation_led', 0, x, y, 'position', [x+75 y 75 20], ...
            'OffString', 'NIC LED OFF', 'OnString',  'NIC LED ON', ...
            'TooltipString', 'If on, center port will light up in different color when animal has nose in center (NIC)');

        % reward: water multiplier
        %%% --- WATER MULTIPLIER SUBWINDOW START ---
        ToggleParam(obj, 'water_multiplier_parameters', 0, x,y, 'position', [x+150 y 125 20],...
            'OnString', 'Water Mult. Showing',...
            'OffString', 'Water Mult. Hidden', 'TooltipString', 'Show/hide water multiplier window');
        set_callback(water_multiplier_parameters, {mfilename, 'show_hide_water_mult_window'});
%         next_row(y); % sharing a row with other GUI param
        oldx=x; oldy=y; parentfig=double(gcf);
        
        SoloParamHandle(obj, 'water_mult_window', 'value', ...
            figure('Position', [300 100 200 200],...
                   'MenuBar', 'none',...
                   'Name', 'Water multiplier parameters',...
                   'NumberTitle', 'off',...
                   'CloseRequestFcn', [mfilename '(' class(obj) ', ''hide_water_mult_window'');']));
        set(gcf, 'Visible', 'off');
        x=5;y=5;
        
        % subheader label place holders
        SubheaderParam(obj,'lab1', 'fixation',x,y,'position', [x y 100 20]);
        SubheaderParam(obj,'lab2', 'performance', x, y, 'position', [x+100 y 100 20]);
        
        %%% --- WATER MULTIPLIER SUBWINDOW END ---
        % back to main window
        x=oldx; y=oldy;
        figure(parentfig);
        
        % reward: drinking duration
        NumeditParam(obj, 'drinking_dur',2, x, y,'labelfraction',0.65,...
            'TooltipString', 'duration of drink state in SMA before Tup --> final state',...
            'label', 'drink dur', 'position', [x+150+125 y 125 20]);
        next_row(y,1.1);
       
        % fixation: leagal cbreak duration
        SliderParam(obj,'legal_cbreak_dur',0.01,0.05,0.2,x, y,'label','cbreak', 'position', [x y 150 20],...
            'TooltipString', 'how long animal can break fixation within a trial');
        % reward: retry type
        MenuParam(obj, 'retry_type', {'single';'multi';'N/A';},...
            1, x, y, 'label', 'retry type',...
            'TooltipString', 'If temperror, how many retries',...
            'labelfraction',0.45,'position', [x+150 y 125 20]);
        % reward: temp error water delay
        NumeditParam(obj, 'temp_error_water_delay',0.5, x, y,'labelfraction',0.65,...
            'TooltipString', 'if terror --> hit, how long until water is delivered',...
            'label', 'water delay', 'position', [x+150+125 y 125 20]);
        next_row(y,1.1);
        
        % fixation: settling in duration
        SliderParam(obj,'settling_in_dur',0.05,0.05,0.2,x, y,'label','settling', 'position', [x y 150 20],...
            'TooltipString', 'how long animal needs to cpoke for to start trial');
        % reward: swtich to toggle temp error penalty
        ToggleParam(obj, 'temp_error_penalty', 1, x, y, 'position', [x+150 y 125 20], ...
            'OffString', 'Temp Error OFF', 'OnString',  'Temp Error ON',...
            'TooltipString', sprintf(['TempError allows animal to retry \nsingle',...
                                      ' or multiple times after an incorrect \nanswer',...
                                      ' penalty can be sound + timeout before \nretry',...
                                      ' and/or delayed reward delivery upon second hit']));
        % reward: wait for spoke Tup forgiveness
        ToggleParam(obj, 'wait_for_spoke_Tup_forgiveness', 1, x, y, 'position', [x+150+125 y 125 20], ...
            'OffString', 'wfsTup forgive OFF', 'OnString',  'wfsTup forgive ON',...
            'TooltipString', sprintf(['if on sends \nSMA',...
                                      ' back to wait_for_cpoke to restart trial \nif',...
                                      ' off, goes to violation state']));next_row(y,1.1);
        
        % fixation: initial poke type & if fixation is required
        MenuParam(obj, 'init_poke_type', {'cpoke_fix';'cpoke_nofix';'spoke';},...
            1, x, y, 'label', 'init + fix. type',...
            'TooltipString', 'What type of poke starts a trial and if fixation is req. on cpoke',...
            'labelfraction',0.45,'position', [x y 150 20]);
        % reward: type
        MenuParam(obj, 'reward_type', {'give';'poke';},...
            1, x, y, 'label', 'type',...
            'labelfraction',0.4,'position', [x+150 y 125 20]);
        % reward: wait for spoke Tup duration
        NumeditParam(obj, 'wait_for_spoke_dur',8, x, y,'labelfraction',0.65,...
            'TooltipString', sprintf(['\nduration of time to wait for response \nonce',...
                             ' stimuli are played and/or reward is given. \ndetermines',...
                             ' duration of wait for spoke in SMA']),...
            'label', 'wfspoke dur', 'position', [x+150+125 y 125 20]); 
        next_row(y,1.2);
        
        %%% subheaders
        SubheaderParam(obj,'lab1', 'fixation',x,y,'position', [x y 145 20]);
        SubheaderParam(obj,'lab3', 'reward', x, y, 'position', [x+150 y 245 20]);next_row(y,1.1);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%   SETUP TASK VARS   %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%% --- TASK GROWTH PARAMETERS SUBWINDOW START ---
        % create window & build from bottom up
        ToggleParam(obj, 'task_growing_parameters', 0, x,y, 'position', [x y 200 20],...
            'OnString', 'Task Growing Params Showing',...
            'OffString', 'Task Growing Params Hidden', 'TooltipString', 'Show/hide task duration growth info');
        set_callback(task_growing_parameters, {mfilename, 'show_hide_growth_params_window'});
        oldx=x; oldy=y; parentfig=double(gcf);
        
        SoloParamHandle(obj, 'growth_params_window', 'value', ...
            figure('Position', [925 350 425 200],...
                   'MenuBar', 'none',...
                   'Name', 'Task growth parameters',...
                   'NumberTitle', 'off',...
                   'CloseRequestFcn', [mfilename '(' class(obj) ', ''hide_growth_params_window'');']));
        set(gcf, 'Visible', 'off');
        x=5;y=5;
        
        % Discrete growth values
        NumeditParam(obj, 'delay_discrete_values',[1.35, 2.0, 2.4], x, y,'labelfraction',0.3,...
            'TooltipString', 'values used for discrete delays',...
            'label', 'discrete', 'position', [x+200 y 150 20]);next_row(y,1.1);
    
        % Adaptive growth parameters 
        NumeditParam(obj, 'pre_alpha_adaptive',0.5, x, y,'labelfraction',0.3,...
            'TooltipString', 'Adaptive growth alpha value',...
            'label', 'a', 'position', [x y 50 20]);
        NumeditParam(obj, 'pre_beta_adaptive',0.5, x, y,'labelfraction',0.3,...
            'TooltipString', 'Adaptive growth beta value',...
            'label', 'b', 'position', [x+50 y 50 20]);
        NumeditParam(obj, 'stimulus_alpha_adaptive',0.5, x, y,'labelfraction',0.3,...
            'label', 'a', 'position', [x+100 y 50 20]);
        NumeditParam(obj, 'stimulus_beta_adaptive',0.5, x, y,'labelfraction',0.3,...
            'label', 'b', 'position', [x+150 y 50 20]); 
        NumeditParam(obj, 'delay_alpha_adaptive',0.5, x, y,'labelfraction',0.3,...
            'label', 'a', 'position', [x+200 y 50 20]);
        NumeditParam(obj, 'delay_beta_adaptive',0.5, x, y,'labelfraction',0.3,...
            'label', 'b', 'position', [x+250 y 50 20]);
        NumeditParam(obj, 'post_alpha_adaptive',0.5, x, y,'labelfraction',0.3,...
            'label', 'a', 'position', [x+300 y 50 20]);
        NumeditParam(obj, 'post_beta_adaptive',0.5, x, y,'labelfraction',0.3,...
            'label', 'b', 'position', [x+350 y 50 20]); next_row(y,1.1);
        
        % Units for fixed growth 
        MenuParam(obj, 'pre_fixed_growth_unit', {'s';'%'},...
            1, x, y, 'label', 'unit', 'TooltipString',...
            'units of fixed growth rate', 'labelfraction',0.4,'position', [x y 100 20]);
        MenuParam(obj, 'stimulus_fixed_growth_unit', {'s';'%'},...
            1, x, y, 'label', 'unit',...
            'labelfraction',0.4,'position', [x+100 y 100 20]);
        MenuParam(obj, 'delay_fixed_growth_unit', {'s';'%'},...
            1, x, y, 'label', 'unit',...
            'labelfraction',0.4,'position', [x+200 y 100 20]);
        MenuParam(obj, 'post_fixed_growth_unit', {'s';'%'},...
            1, x, y, 'label', 'unit',...
            'labelfraction',0.4,'position', [x+300 y 100 20]);next_row(y,1.1);
        
        % Rate for fixed growth
        NumeditParam(obj, 'pre_fixed_growth_rate',0.002, x, y,'labelfraction',0.6,...
            'TooltipString', 'Rate at which fixed growth is occuring',...
            'label', 'rate', 'position', [x y 100 20]);
        NumeditParam(obj, 'stimulus_fixed_growth_rate',0.001, x, y,'labelfraction',0.6,...
            'label', 'rate', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'delay_fixed_growth_rate',0.002, x, y,'labelfraction',0.6,...
            'label', 'rate','position', [x+200 y 100 20]);
        NumeditParam(obj, 'post_fixed_growth_rate',0.002, x, y,'labelfraction',0.6,...
            'label', 'rate', 'position', [x+300 y 100 20]);next_row(y,1.1);
        
        % Maximum duration to grow to
        NumeditParam(obj, 'pre_max',0.25, x, y,'labelfraction',0.6,...
            'TooltipString', 'Maximum duration to grow to',...
            'label', 'max', 'position', [x y 100 20]);
        NumeditParam(obj, 'stimulus_max',0.2, x, y,'labelfraction',0.6,...
            'label', 'max', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'delay_max',2.5, x, y,'labelfraction',0.6,...
            'label', 'max','position', [x+200 y 100 20]);
        NumeditParam(obj, 'post_max',0.25, x, y,'labelfraction',0.6,...
            'label', 'max', 'position', [x+300 y 100 20]);next_row(y,1.1);
        
        % Previous session duration 
        NumeditParam(obj, 'pre_prev_session',0.1, x, y,'labelfraction',0.6,...
            'TooltipString', 'Value of duration in last session',...
            'label', 'prev sess', 'position', [x y 100 20]);
        NumeditParam(obj, 'stimulus_prev_session',0.1, x, y,'labelfraction',0.6,...
            'label', 'prev sess', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'delay_prev_session',0.1, x, y,'labelfraction',0.6,...
            'label', 'prev sess','position', [x+200 y 100 20]);
        NumeditParam(obj, 'post_prev_session',0.1, x, y,'labelfraction',0.6,...
            'label', 'prev sess', 'position', [x+300 y 100 20]);next_row(y,1.1);
        
        % Starting (or minimum) duration for the seesion 
        NumeditParam(obj, 'pre_min',0.05, x, y,'labelfraction',0.6,...
            'TooltipString', 'Minimum duration used at start of warm up',...
            'label', 'min', 'position', [x y 100 20]);
        NumeditParam(obj, 'stimulus_min',0.03, x, y,'labelfraction',0.6,...
            'label', 'min', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'delay_min',0.001, x, y,'labelfraction',0.6,...
            'label', 'min','position', [x+200 y 100 20]);
        NumeditParam(obj, 'post_min',0.10, x, y,'labelfraction',0.6,...
            'label', 'min', 'position', [x+300 y 100 20]);next_row(y,1.1);
        
        % headers
        SubheaderParam(obj,'lab1', 'pre',x,y,'position', [x y 90 20]);
        SubheaderParam(obj,'lab2', 'stim',x+100,y,'position', [x+100 y 90 20]);
        SubheaderParam(obj,'lab3', 'delay',x+200,y,'position', [x+200 y 90 20]);
        SubheaderParam(obj,'lab4', 'post',x+300,y,'position', [x+300 y 90 20]);
        
        %%% --- TASK GROWTH PARAMETERS SUBWINDOW END ---
        % back to main window
        x=oldx; y=oldy;
        figure(parentfig);
        
        %%% number of trials for warm up (ubiquitous to all durations)
        NumeditParam(obj, 'n_warm_up_trials',20, x, y,'labelfraction',0.6,...
            'label', 'warm up trials', 'position', [x+200 y 200 20]);next_row(y,1.1);
        
        %%% Type of growth (fixed/adaptive/discrete)
        MenuParam(obj, 'pre_growth_type', {'fixed';'adaptive'},...
            1, x, y, 'label', 'type', 'TooltipString',...
            'type of growth occuring', 'labelfraction',0.4,'position', [x y 100 20]);
        MenuParam(obj, 'stimulus_growth_type', {'fixed';'adaptive'},...
            1, x, y, 'label', 'type',...
            'labelfraction',0.4,'position', [x+100 y 100 20]);
        MenuParam(obj, 'delay_growth_type', {'fixed';'adaptive';'discrete'},...
            1, x, y, 'label', 'type',...
            'labelfraction',0.4,'position', [x+200 y 100 20]);
        MenuParam(obj, 'post_growth_type', {'fixed';'adaptive'},...
            1, x, y, 'label', 'type',...
            'labelfraction',0.4,'position', [x+300 y 100 20]);next_row(y,1.1);
        
        %%% Switcht to turn on growth warm up 
        ToggleParam(obj, 'pre_warm_up', 0, x, y, 'position', [x y 100 20], ...
            'OffString', 'Warm Up OFF', 'OnString',  'Warm Up ON', ...
            'TooltipString', sprintf(['\nIf on & var is growing, will start at min and \ngrow',...
                             'from min to previous dat duration in n_warm_up_trials']));
        ToggleParam(obj, 'stimulus_warm_up', 0, x, y, 'position', [x+100 y 100 20], ...
            'OffString', 'Warm Up OFF', 'OnString',  'Warm Up ON');
        ToggleParam(obj, 'delay_warm_up', 0, x, y, 'position', [x+200 y 100 20], ...
            'OffString', 'Warm Up OFF', 'OnString',  'Warm Up ON');
        ToggleParam(obj, 'post_warm_up', 0, x, y, 'position', [x+300 y 100 20], ...
            'OffString', 'Warm Up OFF', 'OnString',  'Warm Up ON'); next_row(y,1.1);
        
        %%% Switch to turn growing on or off 
        ToggleParam(obj, 'pre_growth', 0, x, y, 'position', [x y 100 20], ...
            'OffString', 'Grow OFF', 'OnString',  'Grow ON', ...
            'TooltipString', 'If on, will grow this duration after valid trials given params below');
        ToggleParam(obj, 'stimulus_growth', 0, x, y, 'position', [x+100 y 100 20], ...
            'OffString', 'Grow OFF', 'OnString',  'Grow ON');
        ToggleParam(obj, 'delay_growth', 0, x, y, 'position', [x+200 y 100 20], ...
            'OffString', 'Grow OFF', 'OnString',  'Grow ON');
        ToggleParam(obj, 'post_growth', 0, x, y, 'position', [x+300 y 100 20], ...
            'OffString', 'Grow OFF', 'OnString',  'Grow ON'); next_row(y,1.1);
        
        %%% Current trial duration
        NumeditParam(obj, 'pre_dur',0.1, x, y,'labelfraction',0.6,...
            'TooltipString', 'Duration on current trial',...
            'label', 'current', 'position', [x y 100 20]);
        NumeditParam(obj, 'stimulus_dur',0.1, x, y,'labelfraction',0.6,...
            'label', 'current', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'delay_dur',0.1, x, y,'labelfraction',0.6,...
            'label', 'current','position', [x+200 y 100 20]);
        NumeditParam(obj, 'post_dur',0.05, x, y,'labelfraction',0.6,...
            'label', 'current', 'position', [x+300 y 100 20]);next_row(y,1.1);
    
        SubheaderParam(obj,'lab1', 'pre',x,y,'position', [x y 90 20]);
        SubheaderParam(obj,'lab2', 'stimulus',x+100,y,'position', [x+100 y 90 20]);
        SubheaderParam(obj,'lab3', 'delay',x+200,y,'position', [x+200 y 90 20]);
        SubheaderParam(obj,'lab4', 'post',x+300,y,'position', [x+300 y 90 20]);next_row(y);

        SubheaderParam(obj, 'lab0', 'Shaping Section',x+200,y, 'position', [x y 400 20]); next_row(y);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% SETUP INTERNAL VARS %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        SoloParamHandle(obj, 'task_prefixes', 'value', {'pre', 'stimulus', 'delay', 'post'});
        SoloParamHandle(obj, 'penalty_prefixes', 'value', {'violation', 'temp_error', 'error', 'inter_trial'});
        
        SoloParamHandle(obj, 'violation_prev_sound_dur', 'value', 0);
        SoloParamHandle(obj, 'temp_error_prev_sound_dur', 'value', 0);
        SoloParamHandle(obj, 'error_prev_sound_dur', 'value', 0);
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%    SEND OUT VARS    %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Allows us to select the appropriate SMA in DMS.m. Write access
        % required in order to allow TrainingSection to set it appropriately.
        DeclareGlobals(obj, 'rw_args', {'init_poke_type'});
        
        %%% TrainingSection
        SoloFunctionAddVars('TrainingSection', 'rw_args', {...
        'violation_fixed_growth_unit', 'temp_error_fixed_growth_unit', 'error_fixed_growth_unit',...
        'violation_fixed_growth_rate', 'temp_error_fixed_growth_rate', 'error_fixed_growth_rate',...
        'violation_sample_std', 'temp_error_sample_std', 'error_sample_std',...
        'inter_trial_sample_std', 'inter_trial_error_multiplier', 'violation_sample_mean',...
        'temp_error_sample_mean', 'error_sample_mean', 'inter_trial_sample_mean',...
        'inter_trial_violation_multiplier', 'violation_max', 'temp_error_max', 'error_max',...
        'inter_trial_max', 'inter_trial_hit_multiplier', 'violation_min', 'temp_error_min',...
        'error_min', 'inter_trial_min', 'inter_trial_perf_multiplier', 'violation_dur_type',...
        'temp_error_dur_type', 'error_dur_type', 'inter_trial_dur_type', 'violation_dur',...
        'temp_error_dur', 'error_dur', 'inter_trial_dur', 'cp_fixation_dur','fixation_led',...
        'drinking_dur', 'legal_cbreak_dur', 'retry_type', 'temp_error_water_delay',...
        'settling_in_dur', 'temp_error_penalty', 'wait_for_spoke_Tup_forgiveness',...
        'reward_type', 'wait_for_spoke_dur', 'delay_discrete_values',...
        'pre_alpha_adaptive', 'pre_beta_adaptive', 'stimulus_alpha_adaptive',...
        'stimulus_beta_adaptive', 'delay_alpha_adaptive', 'delay_beta_adaptive',...
        'post_alpha_adaptive', 'post_beta_adaptive', 'pre_fixed_growth_unit',...
        'stimulus_fixed_growth_unit', 'delay_fixed_growth_unit', 'post_fixed_growth_unit',...
        'pre_fixed_growth_rate', 'stimulus_fixed_growth_rate', 'delay_fixed_growth_rate',...
        'post_fixed_growth_rate', 'pre_max', 'stimulus_max', 'delay_max', 'post_max',...
        'pre_prev_session', 'stimulus_prev_session', 'delay_prev_session', 'post_prev_session',...
        'pre_min', 'stimulus_min', 'delay_min', 'post_min', 'n_warm_up_trials',...
        'pre_growth_type', 'stimulus_growth_type', 'delay_growth_type', 'post_growth_type',...
        'pre_warm_up', 'stimulus_warm_up', 'delay_warm_up', 'post_warm_up', 'pre_growth',...
        'stimulus_growth', 'delay_growth', 'post_growth', 'pre_dur', 'stimulus_dur',...
        'delay_dur', 'post_dur', 'violation_penalty'});

        %%% SMA
        SoloFunctionAddVars('SMA', 'ro_args', {...
        'inter_trial_perf_multiplier', 'inter_trial_hit_multiplier', 'inter_trial_error_multiplier',...
        'inter_trial_violation_multiplier', 'violation_dur', 'temp_error_dur', 'error_dur',...
        'inter_trial_dur','cp_fixation_dur', 'fixation_led', 'legal_cbreak_dur', 'retry_type',...
        'temp_error_water_delay', 'settling_in_dur', 'temp_error_penalty',...
        'wait_for_spoke_Tup_forgiveness', 'reward_type' 'wait_for_spoke_dur',...
        'pre_dur','stimulus_dur', 'delay_dur', 'post_dur', 'drinking_dur', 'violation_penalty'});
   
        SoloFunctionAddVars('SMA_spoke', 'ro_args', {...
        'inter_trial_perf_multiplier', 'inter_trial_hit_multiplier', 'inter_trial_error_multiplier',...
        'inter_trial_violation_multiplier', 'violation_dur', 'temp_error_dur', 'error_dur',...
        'inter_trial_dur','cp_fixation_dur', 'fixation_led', 'legal_cbreak_dur', 'retry_type',...
        'temp_error_water_delay', 'settling_in_dur', 'temp_error_penalty',...
        'wait_for_spoke_Tup_forgiveness', 'reward_type' 'wait_for_spoke_dur',...
        'pre_dur', 'delay_dur', 'post_dur', 'drinking_dur'});

        %%% HistorySection
        SoloFunctionAddVars('HistorySection', 'ro_args', {...
        'violation_dur', 'temp_error_dur', 'error_dur', 'cp_fixation_dur','delay_dur'});

        %%% StimulusSection
        SoloFunctionAddVars('StimulusSection', 'ro_args', {'stimulus_dur','delay_dur','post_dur'});
        

    % ------------------------------------------------------------------
    %              PREPARE NEXT TRIAL
    % ------------------------------------------------------------------
        
    case 'prepare_next_trial'
        if n_done_trials == 0
            return; 
        end 
        
        %! Could use was_violation here to be more readable
        % Last trial was not a violation, so update any duration that is growing
        if result_history(end) ~= 3
            for iperiod = 1 : length(task_prefixes)
                period = task_prefixes{iperiod};
                growth = value(eval([period '_growth']));
                growth_type = value(eval([period '_growth_type']));
                warm_up = value(eval([period '_warm_up']));

                if growth
                    % warm up growth
                    if warm_up && (n_trials_stage < n_warm_up_trials)
                        cur_dur = value(eval([period '_dur']));
                        prev_dur = value(eval([period '_prev_session']));
                        step_size = (prev_dur - cur_dur)/n_warm_up_trials;
                        ShapingSection(obj, 'update_fixed', period, step_size, 's');
                    % non-warm up growth
                    else
                        switch growth_type
                        case 'adaptive'
                            ShapingSection(obj, 'update_adaptive', period);
                        case 'fixed'
                            ShapingSection(obj, 'update_fixed', period);
                        end
                    end
                elseif strcmp(growth_type, 'discrete') % only applies to delay_dur
                            % randomly select delay dur from array
                            random_idx = randi(length(delay_discrete_values), 1);
                            delay_dur.value = value(delay_discrete_values(random_idx));      
                end
            end
        end

        % Update the penalty lengths if last result was not a hit.
        switch result_history(end)
        case 3 % Violation
            switch value(violation_dur_type)
            case 'growing'
                ShapingSection(obj, 'update_fixed', 'violation');
            case 'sampled'
                ShapingSection(obj, 'update_sampled', 'violation');
            end

        case 4 % temp_error
            switch value(temp_error_dur_type)
            case 'growing'
                ShapingSection(obj, 'update_fixed', 'temp_error');
            case 'sampled'
                ShapingSection(obj, 'update_sampled', 'temp_error');
            end

        case 2 % error
            switch value(error_dur_type)
            case 'growing'
                ShapingSection(obj, 'update_fixed', 'error');
            case 'sampled'
                ShapingSection(obj, 'update_sampled', 'error');
            end
        end
        
        switch value(inter_trial_dur_type)
        case 'sampled'
            ShapingSection(obj, 'update_sampled', 'inter_trial');
        end
        
        % make sure durations are within min/max range
        ShapingSection(obj, 'check_duration_boundaries');
        
        % update sound durations if needed
        ShapingSection(obj, 'check_and_set_sound_durations');
        
        % Update duration of cp fixation
        cp_fixation_dur.value = value(pre_dur) + 2 * value(stimulus_dur) + value(delay_dur) + value(post_dur);
        
        % Ensure that settling in does not exceed pre
        if value(settling_in_dur) > value(pre_dur)
            settling_in_dur.value = value(pre_dur);
        end
    

    %---------------------------------------------------------------%
    %          update_fixed                                         %
    %---------------------------------------------------------------%
    case 'update_fixed'
        % Performs fixed rate update to specified variable, which can
        % be any of the task_prefixes or penalty_prefixes. 
        % Parameters:
        %   varargin{1}: string, the variable to grow
        %   varargin{2}: int, the rate of fixed growth
        %   varargin{3}: sring, the unit of fixed growth ('s' or '%')
        % TODO assert varargin{1} is in task_prefixes or penalty_prefixes
        if length(varargin) == 1
            task_var = varargin{1};
            cur_dur = value(eval([task_var '_dur']));
            growth_rate = value(eval([task_var '_fixed_growth_rate']));
            growth_unit = value(eval([task_var '_fixed_growth_unit']));
            switch growth_unit
            case 's'
                eval([task_var '_dur.value = cur_dur + growth_rate;']);
            case '%'
                eval([task_var '_dur.value = cur_dur * growth_rate;']);
            end
        elseif length(varargin) > 1
            task_var = varargin{1};
            growth_rate = varargin{2};
            growth_unit = varargin{3};
            cur_dur = value(eval([task_var '_dur']));
            switch growth_unit
            case 's'
                eval([task_var '_dur.value = cur_dur + growth_rate;']);
            case '%'
                eval([task_var '_dur.value = cur_dur * growth_rate;']);
            end
        end

    %---------------------------------------------------------------%
    %          update_adaptive                                      %
    %---------------------------------------------------------------%
    % case 'update_adaptive'

    %---------------------------------------------------------------%
    %          update_sampled                                       %
    %---------------------------------------------------------------%
    case 'update_sampled'
        task_var = varargin{1};
        sample_mean = value(eval([task_var '_sample_mean']));
        sample_std = value(eval([task_var '_sample_std']));
        eval([task_var '_dur.value = normrnd(sample_mean, sample_std, 1);']);

    %---------------------------------------------------------------%
    %          check_duration_boundaries                            %
    %---------------------------------------------------------------%
    case 'check_duration_boundaries'
        % ensure all durations are within min/max boundaries set in GUI
        task_vars = cat(2, value(task_prefixes), value(penalty_prefixes));
        for ivar = 1 : length(task_vars)
            var_dur = value(eval([task_vars{ivar} '_dur']));
            var_min = value(eval([task_vars{ivar} '_min']));
            var_max = value(eval([task_vars{ivar} '_max']));
            if var_dur < var_min
                eval([task_vars{ivar} '_dur.value = var_min;']);
            elseif var_dur > var_max
                eval([task_vars{ivar} '_dur.value = var_max;']);
            end
        end

    %---------------------------------------------------------------%
    %          check_and_set_sound_durations                        %
    %---------------------------------------------------------------%
    case 'check_and_set_sound_durations'
        % For violation, temp error and error sounds, checks to see
        % if they should match timeout penalty durations and update
        % if the timeout duration has changed from previous trial. 
        % Otherwise, ensures the penalty sound duration is not longer
        % than the timeout.

        for ivar = 1 : length(value(penalty_prefixes)) - 1 % skip itd prefix
            % determine penalty sound being updated 
            penalty_var = penalty_prefixes{ivar};
            if strcmp(penalty_var, 'violation')
                sound_name = 'ViolationSound';
            elseif strcmp(penalty_var, 'temp_error')
                sound_name = 'TempErrorSound';
            elseif strcmp(penalty_var, 'error')
                sound_name = 'ErrorSound';
            else
                warning('Penalty prefix not recognized');
            end

            % get previous sound info, timeout info and bool if they should match
            prev_sound_dur      = value(eval([penalty_var '_prev_sound_dur']));
            timeout_dur         = value(eval([penalty_var '_dur']));
            match_sound_timeout = value(eval([penalty_var '_sound_match_timeout']));

            if match_sound_timeout
                % if matching to timeout, update sound duration if timeout
                % duration changed from previous trial
                if prev_sound_dur ~= timeout_dur 
                    SoundInterface(obj, 'set', sound_name, 'Dur1', timeout_dur);
                end
            else
                % if not matched to timeout, ensure sound doesn't play longer
                % than the timeout period
                if prev_sound_dur > timeout_dur
                    SoundInterface(obj, 'set', sound_name, 'Dur1', timeout_dur);
                end
            end

            % update prev_sound info for next trial
            current_sound_dur = SoundInterface(obj, 'get', sound_name, 'Dur1');
            eval([penalty_var '_prev_sound_dur.value = current_sound_dur;']);
        end
        % update AOM with any new durations
        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');

    %---------------------------------------------------------------%
    %            end_session                                        %
    %---------------------------------------------------------------%
    case 'end_session'
        % save out final trial values for any growable param for 
        % tomorrows warm up target
        for ivar = 1 : length(task_prefixes)
            var_dur = value(eval([task_prefixes{ivar} '_dur']));
            eval([task_prefixes{ivar} '_prev_session.value = var_dur;']);
        end
        
    %---------------------------------------------------------------%
    %          show/hide/close                                      %
    %---------------------------------------------------------------%
    case 'show_hide_penalty_params_window'
        if penalty_parameters == 0, set(value(penalty_params_window), 'Visible', 'off');
        else                        set(value(penalty_params_window), 'Visible', 'on');
        end
    case 'hide_penalty_params_window'
        set(value(penalty_params_window), 'Visible', 'off'); penalty_parameters.value = 0;
   
    case 'show_hide_soundui_window'
        if penalty_go_sounds == 0, set(value(soundui_window), 'Visible', 'off');
        else                       set(value(soundui_window), 'Visible', 'on');
        end
    case 'hide_soundui_window'
        set(value(soundui_window), 'Visible', 'off'); penalty_go_sounds.value = 0;

    case 'show_hide_water_mult_window'
        if water_multiplier_parameters == 0, set(value(water_mult_window), 'Visible', 'off');
        else                                 set(value(water_mult_window), 'Visible', 'on');
        end
    case 'hide_water_mult_window'
        set(value(water_mult_window), 'Visible', 'off'); water_multiplier_parameters.value = 0;

    case 'show_hide_growth_params_window'
        if task_growing_parameters == 0, set(value(growth_params_window), 'Visible', 'off');
        else                             set(value(growth_params_window), 'Visible', 'on');
        end
    case 'hide_growth_params_window'
        set(value(growth_params_window), 'Visible', 'off'); task_growing_parameters.value = 0;


    case 'close'
        delete(value(penalty_params_window));
        delete(value(soundui_window));
        delete(value(water_mult_window));
        delete(value(growth_params_window));

end

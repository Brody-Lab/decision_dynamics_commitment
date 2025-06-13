
%% ShapingSection 
%  Written by Jess Breda July 2024
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

        %% Section 3
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%  SETUP PENALTY VARS %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Section 3, Row 4
        %% --- PENALTY PARAMETERS SUBWINDOW START ---
        % create window & build from bottom up
        ToggleParam(obj, 'penalty_parameters', 0, x,y, 'position', [x y 200 20],...
            'OnString', 'Penalty Parameters Showing',...
            'OffString', 'Penalty Parameters Hidden', 'TooltipString', 'Show/hide penalty growth info');
        set_callback(penalty_parameters, {mfilename, 'show_hide_penalty_params_window'});
        oldx=x; oldy=y; parentfig=double(gcf);
        
        SoloParamHandle(obj, 'penalty_params_window', 'value',...
            figure('Position', [160 100 400 210],...
                   'MenuBar', 'none',...
                   'Name', 'Penalty paramaters',...
                   'NumberTitle', 'off',...
                   'CloseRequestFcn', [mfilename '(' class(obj) ', ''hide_penalty_params_window'');']));
        set(gcf, 'Visible', 'off');
        x=5;y=5;
        
        % Penalty subwindow, Row 7
        NumeditParam(obj, 'temp_error_water_delay',0.5, x, y,'labelfraction',0.70,...
            'TooltipString', 'if terror --> hit, how long until water is delivered',...
             'label', 'terr h20 del', 'position', [x+100 y 100 20]);
         NumeditParam(obj, 'terror_water_frac',0.5, x, y,'labelfraction',0.70,...
            'TooltipString', 'if terror --> hit, what fraction of full reward volume to deliver',...
             'label', 'terr h20 frac', 'position', [x+200 y 100 20]);
        next_row(y,1.1);

        MenuParam(obj, 'retry_type', {'single';'multi';'N/A';},...
            1, x, y, 'label', 'retry','labelfraction',0.45,'position', [x+100 y 100 20],...
            'TooltipString', 'If temperror_penalty on, how many retries');
        set_callback(retry_type, {mfilename, 'error_penalty_callback'});
        next_row(y,1.1);

        % Penalty subwindow, Row 6
        MenuParam(obj, 'violation_fixed_growth_unit', {'s';'%'},...
            1, x, y, 'label', 'unit', 'TooltipString',...
            'units of growth rate', 'labelfraction',0.4,'position', [x y 100 20]);
        MenuParam(obj, 'temp_error_fixed_growth_unit', {'s';'%'},...
            1, x, y, 'label', 'unit',...
            'labelfraction',0.4,'position', [x+100 y 100 20]);
        MenuParam(obj, 'error_fixed_growth_unit', {'s';'%'},...
            1, x, y, 'label', 'unit',...
            'labelfraction',0.4,'position', [x+200 y 100 20]);
        MenuParam(obj, 'inter_trial_dur_type', {'stable';'sampled'},...
            1, x, y, 'label', 'itd type',...
            'TooltipString', sprintf(['\nHow inter trial dur type should be \ndetermined',...
                                      'from the penalty params subwindow']),...
            'labelfraction',0.4,'position', [x+300 y 100 20]);
        next_row(y,1.1);
        
        % Penalty subwindow, Row 5
        NumeditParam(obj, 'violation_fixed_growth_rate',0.002, x, y,'labelfraction',0.5,...
            'TooltipString', 'Rate at which growth is occuring',...
            'label', 'rate', 'position', [x y 100 20]);
        NumeditParam(obj, 'temp_error_fixed_growth_rate',0.002, x, y,'labelfraction',0.5,...
            'label', 'rate', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'error_fixed_growth_rate',0.002, x, y,'labelfraction',0.5,...
            'label', 'rate','position', [x+200 y 100 20]);
        next_row(y,1.1);
   
        % Penalty subwindow, Row 4
        NumeditParam(obj, 'violation_sample_std',0.5, x, y,'labelfraction',0.5,...
            'TooltipString', 'Std of normal distribution to sample violation penalty from',...
            'label', 'std', 'position', [x y 100 20]);
        NumeditParam(obj, 'temp_error_sample_std',0.5, x, y,'labelfraction',0.5,...
            'label', 'std', 'position', [x+100 y 100 20]);        
        NumeditParam(obj, 'error_sample_std',0.5, x, y,'labelfraction',0.5,...
            'label', 'std', 'position', [x+200 y 100 20]);
        NumeditParam(obj, 'inter_trial_sample_std',0.5, x, y,'labelfraction',0.5,...
            'label', 'std', 'position', [x+300 y 100 20]);
        next_row(y,1.1);

        % Penalty subwindow, Row 3
        NumeditParam(obj, 'violation_sample_mean',0.5, x, y,'labelfraction',0.5,...
            'TooltipString', 'Mean of normal distribution to sample violation penalty from',...
            'label', 'mean', 'position', [x y 100 20]);
        NumeditParam(obj, 'temp_error_sample_mean',0.5, x, y,'labelfraction',0.5,...
            'label', 'mean', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'error_sample_mean',0.5, x, y,'labelfraction',0.5,...
            'label', 'mean', 'position', [x+200 y 100 20]);
        NumeditParam(obj, 'inter_trial_sample_mean',0.5, x, y,'labelfraction',0.5,...
            'label', 'mean', 'position', [x+300 y 100 20]); 
        next_row(y,1.1);
        
        % Penalty subwindow, Row 2
        NumeditParam(obj, 'violation_max',5, x, y,'labelfraction',0.5,...
            'TooltipString', 'Maximum penalty duration',...
            'label', 'max', 'position', [x y 100 20]);
        NumeditParam(obj, 'temp_error_max',5, x, y,'labelfraction',0.5,...
            'label', 'max', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'error_max',5, x, y,'labelfraction',0.5,...
            'label', 'max','position', [x+200 y 100 20]);
        NumeditParam(obj, 'inter_trial_max',60, x, y,'labelfraction',0.5,...
            'label', 'max','position', [x+300 y 100 20]); 
        next_row(y,1.1);        
        
        % Penalty subwindow, Row 1
        NumeditParam(obj, 'violation_min',0.001, x, y,'labelfraction',0.5,...
            'TooltipString', 'Minimum penalty duration used at start',...
            'label', 'min', 'position', [x y 100 20]);
        NumeditParam(obj, 'temp_error_min',0.001, x, y,'labelfraction',0.5,...
            'label', 'min', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'error_min',0.001, x, y,'labelfraction',0.5,...
            'label', 'min','position', [x+200 y 100 20]);
        NumeditParam(obj, 'inter_trial_min',1, x, y,'labelfraction',0.5,...
            'label', 'min','position', [x+300 y 100 20]);
        next_row(y,1.2);

        % headers
        SubheaderParam(obj,'lab1', 'violation',x,y,'position', [x y 90 20]);
        SubheaderParam(obj,'lab2', 'temp error',x,y,'position', [x+100 y 90 20]);
        SubheaderParam(obj,'lab3', 'error',x,y,'position', [x+200 y 90 20]);
        SubheaderParam(obj,'lab4', 'inter trial',x,y,'position', [x+300 y 90 20]);
        
        % back to main window
        x=oldx; y=oldy; figure(parentfig);
        %%% --- PENALTY PARAMETERS SUBWINDOW END ---
        
        %% --- PENALTY & GO SOUNDUI SUBWINDOW START ---
        ToggleParam(obj, 'penalty_go_sounds', 0, x,y, 'position', [x+200 y 200 20],...
            'OnString', 'Penalty/Go SoundUI Showing',...
            'OffString', 'Penalty/Go SoundUI Hidden', 'TooltipString', 'Show/hide penalty sound info');
        set_callback(penalty_go_sounds, {mfilename, 'show_hide_soundui_window'});
        oldx=x; oldy=y; parentfig=double(gcf);
        
        SoloParamHandle(obj, 'soundui_window', 'value', ...
            figure('Position', [950 100 500 300],...
                   'MenuBar', 'none',...
                   'Name', 'SoundUI: Penalty/Go Sounds',...
                   'NumberTitle', 'off',...
                   'CloseRequestFcn', [mfilename '(' class(obj) ', ''hide_soundui_window'');']));
        set(gcf, 'Visible', 'off');
        x=5;y=5;
        
        % create penalty sound UI
        [x, y] = SoundInterface(obj, 'add', 'ViolationSound', x, y); 
        [x, y] = SoundInterface(obj, 'add', 'GoSound', x+200, y-140); next_row(y, 0.5);
        [x, y] = SoundInterface(obj, 'add', 'TempErrorSound', x-200, y); 
        [x, y] = SoundInterface(obj, 'add', 'ErrorSound', x+200, y-140);

        %%% edit july 2023- not really using any penalty sounds so rather
        %%% than having to the volume off in each stage, will have them
        %%% default to being off. 
        SoundInterface(obj, 'set', 'TempErrorSound',... 
                                   'Style', 'SpectrumNoise',...
                                   'Vol', 0,... % 0.003 is 72 dB
                                   'Freq1', 5000,...
                                   'Freq2', 1000,...
                                   'Dur1', 0.5);
        SoundInterface(obj, 'set', 'ErrorSound',...
                                   'Style', 'SpectrumNoise',... 
                                   'Vol', 0,... % 72 dB is 0.03 but seems too loud
                                   'Freq1', 10000,...
                                   'Freq2', 10000,...
                                   'Dur1', 0.5);
        SoundInterface(obj, 'set', 'GoSound',...
                                   'Style', 'WhiteNoise',...
                                   'Vol', 0.001,... % 72 dB
                                   'Dur1', 0.2 );
        SoundInterface(obj, 'set', 'ViolationSound',... 
                                   'Style', 'ToneFMWiggle',...
                                   'Vol', 0,... % 74 dB
                                   'Freq1', 5000,...
                                   'Dur1', 0.5);
  

        % back to main window
        x=oldx; y=oldy; figure(parentfig);
        next_row(y);
        %%% --- PENALTY & GO SOUNDUI SUBWINDOW END ---
        
        %% Section 3, Row 3
        %%% Type determining how duration of penalty is determined & fixation lgl break
        MenuParam(obj, 'violation_dur_type', {'stable';'sampled';'growing'},...
            1, x, y, 'label', 'type', 'TooltipString',...
            'how the duration of the violation penalty is being determined', 'labelfraction',0.4,'position', [x y 133 20]);
        MenuParam(obj, 'temp_error_dur_type', {'stable';'sampled';'growing'},...
            1, x, y, 'label', 'type',...
            'labelfraction',0.4,'position', [x+133 y 133 20]);
        MenuParam(obj, 'error_dur_type', {'stable';'sampled';'growing'},...
            1, x, y, 'label', 'type',...
            'labelfraction',0.4,'position', [x+(2*133) y 133 20]);
        next_row(y,1.1)
        
        %% Section 3, Row 2
        %%% Toggle sounds matching timout & fixation nic
        ToggleParam(obj, 'violation_sound_match_timeout', 1, x, y, 'position', [x y 133 20],...
            'OffString', 'Sound != Tout', 'OnString', 'Sound == Tout', ...
            'TooltipString', sprintf(['If on, sound will match penalty duration above',...
                                        '\nhowever, in current (2024) use, no penalty sound',...
                                        '\nis played a volumes are set to 0, so this doesnt have',...
                                        '\nutility even if turned on']));
        ToggleParam(obj, 'temp_error_sound_match_timeout', 1, x, y, 'position', [x+133 y 133 20],...
            'OffString', 'Sound != Tout', 'OnString', 'Sound == Tout', ...
            'TooltipString', 'If on, sound will match penalty duration above');
        ToggleParam(obj, 'error_sound_match_timeout', 1, x, y, 'position', [x+(2*133) y 133 20],...
            'OffString', 'Sound != Tout', 'OnString', 'Sound == Tout', ...
            'TooltipString', 'If on, sound will match penalty duration above');
        next_row(y,1.1);
        
        %% Section 3, Row 1
        %%% Current penalty timeout duration & callback for fixation duration
        NumeditParam(obj, 'violation_dur',0.1, x, y,'labelfraction',0.6,...
            'TooltipString', 'Timeout duration',...
            'label', 'current', 'position', [x y 133 20]);
        NumeditParam(obj, 'temp_error_dur',0.1, x, y,'labelfraction',0.6,...
            'TooltipString', 'Timeout duration',...
            'label', 'current', 'position', [x+133 y 133 20]);
        NumeditParam(obj, 'error_dur',0.1, x, y,'labelfraction',0.6,...
            'TooltipString', 'Timeout duration',...
            'label', 'current','position', [x+(2*133) y 133 20]);
        next_row(y,1.2);
        
        %% Section 3, Headers
        SubheaderParam(obj,'lab1', 'violation',x,y,'position', [x y 120 20]);
        SubheaderParam(obj,'lab2', 'temp error',x+100,y,'position', [x+140 y 95 20]);
        ToggleParam(obj, 'temp_error_penalty', 0, x,y, 'position', [x+230 y 25 20],...
        'OnString', 'ON', 'OffString', 'OFF',...
        'TooltipString', sprintf(['TempError allows animal to retry \nsingle',...
                                      ' or multiple times after an incorrect \nanswer',...
                                      ' penalty can be sound + timeout before \nretry',...
                                      ' and/or delayed reward delivery upon second hit']));
        set_callback(temp_error_penalty, {mfilename, 'temp_error_penalty_callback'});
        set_callback(temp_error_penalty, {mfilename, 'error_penalty_callback'});
    
        SubheaderParam(obj,'lab3', 'error',x+200,y,'position', [x+(2*140) y 120 20]);
        next_row(y,1.5);
        
        
        %% Section 1
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%     SETUP REWARD & TIMING VARS      %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        
        %% Section 2, Row 2
        NumeditParam(obj, 'inter_trial_dur',3, x, y,'labelfraction',0.65,...
                'TooltipString', 'Duration of pause time between trials',...
                'label', 'itd dur', 'position', [x y 133 20]);
        %% --- EXP Sample PARAMS SUBWINDOW START --- %%% Section 2, Row 2
        ToggleParam(obj, 'exp_sample_params', 0, x,y, 'position', [x+(133) y 133 20],...
            'OnString', 'Exp Sample params Showing',...
            'OffString', 'Exp Sample params Hidden', 'TooltipString', 'Show/hide exp sample params window');
        set_callback(exp_sample_params, {mfilename, 'show_hide_exp_sample_params_window'});
        oldx=x; oldy=y; parentfig=double(gcf);
        
        SoloParamHandle(obj, 'exp_sample_params_window', 'value', ...
            figure('Position', [200 300 475 120],...
                   'MenuBar', 'none',...
                   'Name', 'Parameters for exp_sample Sampling',...
                   'NumberTitle', 'off',...
                   'CloseRequestFcn', [mfilename '(' class(obj) ', ''hide_exp_sample_params_window'');']));
        set(gcf, 'Visible', 'off');
        x=5;y=5;
        
        NumeditParam(obj, 'exp_upper_bound_min',1.2, x, y,'labelfraction',0.55,...
            'TooltipString', 'Minimum value of upper bound of exp distribution',...
            'label', 'upper min ', 'position', [x y 100 20]);
        NumeditParam(obj, 'exp_upper_bound_max',8, x, y,'labelfraction',0.55,...
            'TooltipString', 'max value of upper bound of exp distribution',...
            'label', 'upper max ', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'exp_upper_bound_fixed_growth_rate',0.001, x, y,'labelfraction',0.55,...
            'TooltipString', 'Rate of growth in ms for exp upper bound',...
            'label', 'upper rate ', 'position', [x+(100*2) y 100 20]);
        % DistribUI
        DistribInterface(obj, 'add', 'exp_sample', x+(105*3), y, 'Style', ...
            'exponential', 'Tau', 0.5, 'Min', 0.1, 'Max', 1.2);
        next_row(y,1.1);
        
        NumeditParam(obj, 'exp_tau_min',0.1, x, y,'labelfraction',0.55,...
            'TooltipString', 'Minimum value of tau (mean) of exp distribution',...
            'label', 'tau min ', 'position', [x y 100 20]);
        NumeditParam(obj, 'exp_tau_max',4, x, y,'labelfraction',0.55,...
            'TooltipString', 'max value of tau of exp distribution',...
            'label', 'tau max ', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'exp_tau_fixed_growth_rate',0.001, x, y,'labelfraction',0.55,...
            'TooltipString', 'Rate of growth in ms for exp tau',...
            'label', 'tau rate ', 'position', [x+(100*2) y 100 20]);
        next_row(y,1.1);
        
        NumeditParam(obj, 'exp_lower_bound_min',0.1, x, y,'labelfraction',0.55,...
            'TooltipString', 'Minimum value of lower bound of exp distribution',...
            'label', 'lower min ', 'position', [x y 100 20]);
        NumeditParam(obj, 'exp_lower_bound_max',4, x, y,'labelfraction',0.55,...
            'TooltipString', 'max value of lower bound of exp distribution',...
            'label', 'lower max ', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'exp_lower_bound_fixed_growth_rate',0.001, x, y,'labelfraction',0.55,...
            'TooltipString', 'Rate of growth in ms for exp lower bound',...
            'label', 'lower rate ', 'position', [x+(100*2) y 100 20]);

        next_row(y,1.2);
        
        % subheader
        SubheaderParam(obj,'lab1', 'Exp grow params',x,y,'position', [x y 100*3 20]);


        % back to main window
        x=oldx; y=oldy;figure(parentfig);
        next_row(y,1.1);
        %%% --- EXP SAMPLE PARAMS SUBWINDOW END ---%%%
            
            
        %% Section 2, Row 1
        MenuParam(obj, 'SMA_set', {'cpoke';'spoke';'habituation';},...
            1, x, y, 'label', 'SMA',...
            'TooltipString','Which SMA to use. Note Cpoke = SMA.m',...
            'labelfraction',0.45,'position', [x y 133 20]);
        
        %% --- SMA SUBWINDOW START --- %%% Section 2, Row 1
        ToggleParam(obj, 'SMA_params', 0, x,y, 'position', [x+133 y 133 20],...
            'OnString', 'SMA params Showing',...
            'OffString', 'SMA params Hidden', 'TooltipString', 'Show/hide SMA params window');
        set_callback(SMA_params, {mfilename, 'show_hide_SMA_params_window'});
        oldx=x; oldy=y; parentfig=double(gcf);
        
        SoloParamHandle(obj, 'SMA_params_window', 'value', ...
            figure('Position', [400 100 300 100],...
                    'MenuBar', 'none',...
                    'Name', 'Additional SMA parameters',...
                    'NumberTitle', 'off',...
                    'CloseRequestFcn', [mfilename '(' class(obj) ', ''hide_SMA_params_window'');']));
        set(gcf, 'Visible', 'off');
        x=5;y=5;

        % SMA Subwindow, Row 2
        NumeditParam(obj, 'drinking_dur',1, x, y,'labelfraction',0.65,...
            'TooltipString', 'Length of drink_state if rewarded',...
            'label', 'drink_dur', 'position', [x y 150 20]);
        NumeditParam(obj, 'adjusted_pre_dur',0.001, x, y,'labelfraction',0.65,...
            'TooltipString', sprintf(['\ngiven settling in dur, this is \nthe',...
                ' actual pre dur sent to the SMA to \nuse',...
                ' for the sa_sound and other wave preambles']),...
            'label', 'adj pre', 'position', [x+150 y 150 20]);
        next_row(y,1.1);  

        % SMA Subwindow, Row 1
        NumeditParam(obj, 'wait_for_spoke_dur',8, x, y,'labelfraction',0.65,...
            'TooltipString', sprintf(['\nduration of time to wait for response \nonce',...
                                ' stimuli are played and/or reward is given. \ndetermines',...
                                ' duration of wait for spoke in SMA']),...
            'label', 'wfspoke dur', 'position', [x y 150 20]);
        ToggleParam(obj, 'reward_light', 0, x,y, 'position', [x+150 y 150 20],...
            'OnString', 'Drink LED ON',...
            'OffString', 'Drink LED OFF',...
            'TooltipString', 'If light should come on during drink state when animal gets reward');
        next_row(y,1.1);

        % SMA subwindow, Header
        SubheaderParam(obj,'lab1', 'Add. SMA Params',x,y,'position', [x y 300 20]);
        
        % back to main window
        x=oldx; y=oldy; figure(parentfig);
        %%% --- SMA PARAMS SUBWINDOW END --- %%%
        
        %% --- TASK GROWTH PARAMETERS SUBWINDOW START --- Section 2, Row 1
        % create window & build from bottom up
        ToggleParam(obj, 'task_growing_parameters', 0, x,y, 'position', [x+(2*133) y 133 20],...
            'OnString', 'Grow Params Showing',...
            'OffString', 'Grow Params Hidden', 'TooltipString', 'Show/hide task duration growth info');
        set_callback(task_growing_parameters, {mfilename, 'show_hide_growth_params_window'});
        oldx=x; oldy=y; parentfig=double(gcf);
        
        SoloParamHandle(obj, 'growth_params_window', 'value', ...
            figure('Position', [925 350 625 200],...
                   'MenuBar', 'none',...
                   'Name', 'Task growth parameters',...
                   'NumberTitle', 'off',...
                   'CloseRequestFcn', [mfilename '(' class(obj) ', ''hide_growth_params_window'');']));
        set(gcf, 'Visible', 'off');
        x=5;y=5;
        
        % Growth subwindow, Row 7
        NumeditParam(obj, 'settling_in_init_decrease_rate',.05, x, y,'labelfraction',0.6,...
            'label', 'init decrease [s]', 'position', [x y 150 20]);
        NumeditParam(obj, 'delay_discrete_values',[1.35, 2.0, 2.4], x, y,'labelfraction',0.3,...
            'TooltipString', 'values used for discrete delays',...
            'label', 'discrete', 'position', [x+300 y 150 20]);
        NumeditParam(obj, 'n_warm_up_trials',20, x, y,'labelfraction',0.6,...
            'label', 'warm up trials', 'position', [x+450 y 150 20]);
        next_row(y,1.1);
    
        % Growth subwindow, Row 6
        MenuParam(obj, 'settling_in_fixed_growth_unit', {'s';'%'},...
            1, x, y, 'label', 'unit', 'TooltipString',...
            'units of fixed growth rate', 'labelfraction',0.4,'position', [x y 100 20]);
        MenuParam(obj, 'pre_fixed_growth_unit', {'s';'%'},...
            1, x, y, 'label', 'unit',...
            'labelfraction',0.4,'position', [x+100 y 100 20]);
        MenuParam(obj, 'stimulus_fixed_growth_unit', {'s';'%'},...
            1, x, y, 'label', 'unit',...
            'labelfraction',0.4,'position', [x+200 y 100 20]);
        MenuParam(obj, 'delay_fixed_growth_unit', {'s';'%'},...
            1, x, y, 'label', 'unit',...
            'labelfraction',0.4,'position', [x+300 y 100 20]);
        MenuParam(obj, 'post_fixed_growth_unit', {'s';'%'},...
            1, x, y, 'label', 'unit',...
            'labelfraction',0.4,'position', [x+400 y 100 20]);
        MenuParam(obj, 'give_del_fixed_growth_unit', {'s';'%'},...
            1, x, y, 'label', 'unit',...
            'labelfraction',0.4,'position', [x+500 y 100 20]);
        next_row(y,1.1);
        
        % Growth subwindow, Row 5
        NumeditParam(obj, 'settling_in_fixed_growth_rate',0.001, x, y,'labelfraction',0.6,...
            'TooltipString', 'Rate at which fixed growth is occuring',...
            'label', 'rate', 'position', [x y 100 20]);
        NumeditParam(obj, 'pre_fixed_growth_rate',0.001, x, y,'labelfraction',0.6,...
            'label', 'rate', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'stimulus_fixed_growth_rate',0.001, x, y,'labelfraction',0.6,...
            'label', 'rate', 'position', [x+200 y 100 20]);
        NumeditParam(obj, 'delay_fixed_growth_rate',0.001, x, y,'labelfraction',0.6,...
            'label', 'rate','position', [x+300 y 100 20]);
        NumeditParam(obj, 'post_fixed_growth_rate',0.002, x, y,'labelfraction',0.6,...
            'label', 'rate', 'position', [x+400 y 100 20]);
        NumeditParam(obj, 'give_del_fixed_growth_rate',0.001, x, y,'labelfraction',0.6,...
            'label', 'rate', 'position', [x+500 y 100 20]);
        next_row(y,1.1);
        
        % Growth subwindow, Row 4
        NumeditParam(obj, 'settling_in_max',5, x, y,'labelfraction',0.6,...
            'TooltipString', 'Maximum duration to grow to',...
            'label', 'max', 'position', [x y 100 20]);
        NumeditParam(obj, 'pre_max',0.25, x, y,'labelfraction',0.6,...
            'label', 'max', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'stimulus_max',0.4, x, y,'labelfraction',0.6,...
            'label', 'max', 'position', [x+200 y 100 20]);
        NumeditParam(obj, 'delay_max',6, x, y,'labelfraction',0.6,...
            'label', 'max','position', [x+300 y 100 20]);
        NumeditParam(obj, 'post_max',0.5, x, y,'labelfraction',0.6,...
            'label', 'max', 'position', [x+400 y 100 20]);
        NumeditParam(obj, 'give_del_max',3, x, y,'labelfraction',0.6,...
            'label', 'max', 'position', [x+500 y 100 20]);
        next_row(y,1.1);
        
        % Growth subwindow, Row 3
         NumeditParam(obj, 'settling_in_prev_session',0.3, x, y,'labelfraction',0.6,...
            'TooltipString', 'Value of duration in last session',...
            'label', 'prev sess', 'position', [x y 100 20]);       
        NumeditParam(obj, 'pre_prev_session',0.1, x, y,'labelfraction',0.6,...
            'label', 'prev sess', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'stimulus_prev_session',0.1, x, y,'labelfraction',0.6,...
            'label', 'prev sess', 'position', [x+200 y 100 20]);
        NumeditParam(obj, 'delay_prev_session',0.1, x, y,'labelfraction',0.6,...
            'label', 'prev sess','position', [x+300 y 100 20]);
        NumeditParam(obj, 'post_prev_session',0.1, x, y,'labelfraction',0.6,...
            'label', 'prev sess', 'position', [x+400 y 100 20]);
        NumeditParam(obj, 'give_del_prev_session',0.1, x, y,'labelfraction',0.6,...
            'label', 'prev sess', 'position', [x+500 y 100 20]);        
        next_row(y,1.1);
        
        % Growth subwindow, Row 2
        NumeditParam(obj, 'settling_in_min',0.150, x, y,'labelfraction',0.6,...
            'TooltipString', 'Minimum duration allowed, sometimes used to start warmup',...
            'label', 'min', 'position', [x y 100 20]);
        NumeditParam(obj, 'pre_min',0.001, x, y,'labelfraction',0.6,...
            'label', 'min', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'stimulus_min',0.001, x, y,'labelfraction',0.6,...
            'label', 'min', 'position', [x+200 y 100 20]);
        NumeditParam(obj, 'delay_min',0.001, x, y,'labelfraction',0.6,...
            'label', 'min','position', [x+300 y 100 20]);
        NumeditParam(obj, 'post_min',0.001, x, y,'labelfraction',0.6,...
            'label', 'min', 'position', [x+400 y 100 20]);
        NumeditParam(obj, 'give_del_min',0.001, x, y,'labelfraction',0.6,...
            'label', 'min', 'position', [x+500 y 100 20]);
        next_row(y,1.1);
        
        % Growth subwindow, Row 1
        ToggleParam(obj, 'settling_in_warm_up', 0, x, y, 'position', [x y 100 20], ...
            'OffString', 'Warm Up OFF', 'OnString',  'Warm Up ON', ...
            'TooltipString', sprintf(['\nIf on & var is growing, will start at min and \ngrow',...
                             'from min to previous dat duration in n_warm_up_trials']));
        ToggleParam(obj, 'pre_warm_up', 0, x, y, 'position', [x+100 y 100 20], ...
            'OffString', 'Warm Up OFF', 'OnString',  'Warm Up ON');
        ToggleParam(obj, 'stimulus_warm_up', 0, x, y, 'position', [x+200 y 100 20], ...
            'OffString', 'Warm Up OFF', 'OnString',  'Warm Up ON');
        ToggleParam(obj, 'delay_warm_up', 0, x, y, 'position', [x+300 y 100 20], ...
            'OffString', 'Warm Up OFF', 'OnString',  'Warm Up ON');
        ToggleParam(obj, 'post_warm_up', 0, x, y, 'position', [x+400 y 100 20], ...
            'OffString', 'Warm Up OFF', 'OnString',  'Warm Up ON');
        ToggleParam(obj, 'give_del_warm_up', 0, x, y, 'position', [x+500 y 100 20], ...
            'OffString', 'Warm Up OFF', 'OnString',  'Warm Up ON');
        next_row(y,1.1);

        
        % Growth subwindow, headers
        SubheaderParam(obj,'lab1', 'settling',x,y,'position', [x y 90 20]);
        SubheaderParam(obj,'lab1', 'pre',x,y,'position', [x+100 y 90 20]);
        SubheaderParam(obj,'lab2', 'stim',x+100,y,'position', [x+200 y 90 20]);
        SubheaderParam(obj,'lab3', 'delay',x+200,y,'position', [x+300 y 90 20]);
        SubheaderParam(obj,'lab4', 'post',x+300,y,'position', [x+400 y 90 20]);
        SubheaderParam(obj,'lab4', 'give del',x+500,y,'position', [x+500 y 90 20]);
        
        % back to main window
        x=oldx; y=oldy; figure(parentfig);
        next_row(y,1.1);
        %%% --- TASK GROWTH PARAMETERS SUBWINDOW END ---
        SubheaderParam(obj,'lab1', 'SMA, Task Timing & Penalties',x,y,'position', [x+50 y 300 20]);
        next_row(y,1.3);

        %% Section 1, Row 2
        NumeditParam(obj, 'give_del_dur',0.001, x, y,'labelfraction',0.65,...
            'TooltipString', 'duration of delay before the post-go-give comes (if on)',...
            'label', 'give del [s]', 'position', [x y 133 20]);
        MenuParam(obj, 'give_del_growth', {'none';'fixed';'adaptive';},...
            1, x, y, 'label', 'give del grow',...
            'TooltipString', 'if post-go give delay period should grow, and if so what kind',...
            'labelfraction',0.6,'position', [x+133 y 133 20]);

        %% --- GIVE PARAMS SUBWINDOW START --- %%% Section 1, Row 2
        ToggleParam(obj, 'give_params', 0, x,y, 'position', [x+(2*133) y 133 20],...
            'OnString', 'Give params Showing',...
            'OffString', 'Give params Hidden', 'TooltipString', 'Show/hide give params window');
        set_callback(give_params, {mfilename, 'show_hide_give_params_window'});
        oldx=x; oldy=y; parentfig=double(gcf);
        
        SoloParamHandle(obj, 'give_params_window', 'value', ...
            figure('Position', [200 250 310 300],...
                   'MenuBar', 'none',...
                   'Name', 'Additional give parameters',...
                   'NumberTitle', 'off',...
                   'CloseRequestFcn', [mfilename '(' class(obj) ', ''hide_give_params_window'');']));
        set(gcf, 'Visible', 'off');
        x=5;y=5;
        
        
        % ROW 11
        NumeditParam(obj, 'give_del_adaptive_threshold',0.75, x, y,'labelfraction',0.70,...
            'TooltipString', sprintf(['\nparameter thatcan be used to have different',...
                                  '\ngrowth rates above different thresholds of performance',...
                                  '\n not currently in use']),...
            'label', 'adaptive thresh NOT IN USE', 'position', [x y 200 20]);
        ToggleParam(obj, 'give_delay_strict_mode',0, x,y, 'position', [x+200 y 100 20],...
            'OnString', 'Strict Mode ON',...
            'OffString', 'Strict Mode OFF',...
            'TooltipString', sprintf(['\nIf give delay is on, wheter an incorrect',...
                            '\nanswer during the delay sends you to error state (strict)',...
                            '\nor does nothing']));
        next_row(y,1.1);
        
        % ROW 10  
        NumeditParam(obj, 'give_del_perf_trial_window',20, x, y,'labelfraction',0.7,...
            'TooltipString', 'previous window of subset trials to look at for perf',...
            'label', 'perf window', 'position', [x y 175 20]);
        DispParam(obj, 'give_del_perf_trial_subset',0, x, y,'labelfraction',0.70,...
            'TooltipString', 'given trial subset and window, what the current performance is',...
            'label', 'subset perf', 'position', [x+175 y 125 20]);
        next_row(y,1.1);
        
        % ROW 9
         NumeditParam(obj, 'give_del_adaptive_step_sec',0.005, x, y,'labelfraction',0.70,...
            'TooltipString', 'step size of adaptive growth in seconds',...
            'label', 'step size [s]', 'position', [x y 175 20]); 
        DispParam(obj, 'give_del_adaptive_alpha_plus',0.23, x, y,'labelfraction',0.70,...
            'TooltipString', sprintf(['\nfor viewing purposes only- alpha plus is 1 - alpha minues ',...
                                    '\nand is used to factor the step size after a hit']),...
            'label', 'alpha +', 'position', [x+175 y 125 20]);
        next_row(y,1.1);

        % ROW 8
        MenuParam(obj, 'give_del_growth_trial_subset', {'all';},...
             1, x, y, 'labelfraction',0.55,...
            'TooltipString', sprintf(['\ntthe trials where give delay growth can happen on',...
                                 '\nand have performance analyzed for growth']),...
            'label', 'give del grow trials','position', [x y 175 20]);
        NumeditParam(obj, 'give_del_adaptive_alpha_minus',0.75, x, y,'labelfraction',0.70,...
            'TooltipString', sprintf(['\n post error, growth decreaes by alpha minus * step size',...
                                    '\nbecuase alpha minus + alpha plus is fixed to equal 1,',...
                                    '\nalpha minus also approximates the perf at which no growth happens']),...
            'label', 'alpha -', 'position', [x+175 y 125 20]);
        set_callback(give_del_adaptive_alpha_minus, {mfilename, 'compute_alpha_plus_callback'});
        next_row(y,1.1);
        
        % ROW 7 subheader 
        SubheaderParam(obj,'lab1', 'Adaptive Growth',x,y,'position', [x+75 y 150 20]);
        next_row(y,1.5);
        
        % ROW 6
        NumeditParam(obj, 'give_light_dur',1, x, y,'labelfraction',0.65,...
            'TooltipString', 'fraction of water reward to use as a give cue',...
            'label', 'light dur', 'position', [x y 100 20]);
        NumeditParam(obj, 'extra_give_light_del_dur',0, x, y,'labelfraction',0.65,...
            'TooltipString', sprintf(['\ngive light specific delay, controls',...
                            '\npreamble of give light wave and acts in addition to the',...
                            '\npre_give_delay']),...
            'label', 'xtra light del', 'position', [x+100 y 100 20]);
        ToggleParam(obj, 'give_light_persist', 1, x,y, 'position', [x+(2*100) y 100 20],...
            'OnString', 'Light Persist ON',...
            'OffString', 'Light Persist OFF',...
            'TooltipString', sprintf(['\nIf give light should loop infinitely and',...
                            '\nuse state entry to turn off, or if it should only loop',...
                            '\nonce and last for duration of give_light_dur']));
        next_row(y,1.1);

        % ROW 5
        NumeditParam(obj, 'give_water_frac',0.3, x, y,'labelfraction',0.65,...
            'TooltipString', 'fraction of water reward to use as a give cue',...
            'label', 'water frac', 'position', [x y 100 20]);
        % TODO add callbacks, etcetc
        NumeditParam(obj, 'give_water_min_vol',3, x, y,'labelfraction',0.65,...
            'TooltipString', sprintf(['floor water volume to use for give, that',...
                             '\n will override and set the give frac']),...
            'label', 'TODO', 'position', [x+100 y 100 20]);
        % TODO- add callbacks to calculate etc
        DispParam(obj, 'give_water_vol',3, x, y,'labelfraction',0.65,...
            'TooltipString', sprintf(['given the current water amounts and,...' ...
                             '\nfrac and min, what vol will be delivered for water give']),...
            'label', 'TODO', 'position', [x+(2*100) y 100 20]);
        next_row(y,1.5);
        
        % ROW 4- decrease params
        NumeditParam(obj, 'give_frac_decrease_rate',0.10, x, y,'labelfraction',0.65,...
            'TooltipString', 'when give_frac is being reduced, by how much',...
            'label', 'frac decrease rate', 'position', [x y 150 20]);        
        NumeditParam(obj, 'no_give_perf_threshold',0.7, x, y,'labelfraction',0.70,...
            'TooltipString', sprintf(['\nthreshold of performance on non-give',...
                                '\ntrials to use in TS curriculum for dropping give']),...
            'label', 'non-give perf thresh', 'position',[x+150 y 150 20]);
        next_row(y,1.1);
        
        % ROW 3- day tracking
        NumeditParam(obj, 'n_days_at_give_frac',0, x, y,'labelfraction',0.65,...
            'TooltipString', 'number of days at give frac (if less than 1)',...
            'label', 'n days', 'position', [x y 150 20]);
        NumeditParam(obj, 'max_days_at_init_frac',3, x, y,'labelfraction',0.65,...
            'TooltipString', 'max number of days to stay at init frac value',...
            'label', 'max days', 'position', [x+(1*150) y 150 20]);
        next_row(y,1.1);
        
        % ROW 2 probabilisitic give rate
        NumeditParam(obj, 'give_frac',1, x, y,'labelfraction',0.65,...
            'TooltipString', 'fraction of trials where give is used',...
            'label', 'give frac', 'position', [x y 150 20]);
        NumeditParam(obj, 'inital_give_frac',0.60, x, y,'labelfraction',0.65,...
            'TooltipString', sprintf(['\nif give_frac is being reduced, what is the',...
                                '\nstarting rate it will be reduced from']),...
            'label', 'init give frac', 'position', [x+(1*150) y 150 20]);  
        next_row(y,1.1);
        
        %ROW 1 TODO- consider disabling this so no one messes w/ it
        MenuParam(obj, 'give_type_implemented', {'none';'water';'light';'water_and_light'},...
             4, x, y, 'labelfraction',0.45,...
            'TooltipString', sprintf(['\nthe give type actually sent to the SMA based off of',...
                                 'the give_frac and the give_type_set for post-go give']),...
            'label', 'give type impl','position', [x y 200 20]);
        ToggleParam(obj, 'decrease_give_frac',0, x,y, 'position', [x+200 y 100 20],...
            'OnString', 'Decrease ON',...
            'OffString', 'Decrease OFF',...
            'TooltipString', sprintf(['\nIf on, give frac will be adjusted overnight',...
                            '\nto be lower if performance was above threshold this is',...
                            '\nuse for weaning animal off give']));
        next_row(y,1.1);

        
        % ROW 0 subheader
        SubheaderParam(obj,'lab1', 'Give Params',x,y,'position', [x y 300 20]);
        
        % back to main window
        x=oldx; y=oldy;figure(parentfig);
        next_row(y,1.1);
        %%% --- GIVE PARAMS SUBWINDOW END ---%%%  
        
        %% Section 1, Row 1
        NumeditParam(obj, 'go_dur',0.2, x, y,'labelfraction',0.65,...
            'TooltipString', sprintf(['\nduration of go cue if go type is set',...
                    '\nnote this also sets the GoSound Dur in SoundUI during PNT']),...
            'label', 'go dur', 'position', [x y 133 20]);
        MenuParam(obj, 'go_type', {'none';'sound'; 'sound_localized';'LED_persist';'LED_flash'},...
            2, x, y, 'label', 'go type',...
            'TooltipString', 'type of go cue used (if any)',...
            'labelfraction',0.45,'position', [x+133 y 133 20]); 
        MenuParam(obj, 'give_type_set', {'none';'water';'light';'water_and_light'},...
            1, x, y, 'label', 'give type set',...
            'TooltipString', sprintf(['\nwhat type of post-go reward guide give to use (if any)',...
                                      '\nnote this does NOT take into account a localized go cue!']),...
            'labelfraction',0.6,'position', [x+(2*133) y 133 20]);
        set_callback(go_type, {mfilename, 'ensure_correct_go_type'});
        set_callback(give_type_set, {mfilename, 'ensure_correct_go_type'});
        set_callback(give_type_set, {mfilename, 'give_type_callback'});
        next_row(y,1.2);
        
       SubheaderParam(obj,'lab1', 'Go & Give',x,y,'position', [x+50 y 300 20]);
       next_row(y,1.3);
        
        %% Section 0 - Fixation
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%   SETUP TASK VARS   %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Section 0, Row 5     
        MenuParam(obj, 'pre_growth', {'none';'fixed';},...
            1, x, y, 'label', 'growth', 'TooltipString',...
            'type of growth occuring', 'labelfraction',0.4,'position', [x y 100 20]);
        MenuParam(obj, 'stimulus_growth', {'none';'fixed'; 'fill_delay'},...
            1, x, y, 'label', 'growth',...
            'labelfraction',0.4,'position', [x+100 y 100 20]);
        MenuParam(obj, 'delay_growth', {'none';'fixed';'discrete';'exp';...
            'exp_fixed_growth';'overnight_sampled'; 'overnight_growth';},...
            1, x, y, 'label', 'growth',...
            'labelfraction',0.4,'position', [x+200 y 100 20]);
        set_callback(delay_growth, {mfilename, 'exponential_growth_callback'});
        MenuParam(obj, 'post_growth', {'none';'fixed';},...
            1, x, y, 'label', 'growth',...
            'labelfraction',0.4,'position', [x+300 y 100 20]);
        next_row(y,1.1);
  
        %% Section 0, Row 4
        NumeditParam(obj, 'pre_dur',0.1, x, y,'labelfraction',0.5,...
            'TooltipString', 'Duration on current trial',...
            'label', 'dur', 'position', [x y 100 20]);
        set_callback(pre_dur, {mfilename, 'calculate_pre_and_settling_durs'});
        set_callback(pre_dur, {mfilename, 'calculate_fixation_and_pre_go_durs'});
        NumeditParam(obj, 'stimulus_dur',0.1, x, y,'labelfraction',0.5,...
            'label', 'dur', 'position', [x+100 y 100 20]);
        set_callback(stimulus_dur, {mfilename, 'calculate_fixation_and_pre_go_durs'});
        NumeditParam(obj, 'delay_dur',0.1, x, y,'labelfraction',0.5,...
            'label', 'dur','position', [x+200 y 100 20]);
        set_callback(delay_dur, {mfilename, 'calculate_fixation_and_pre_go_durs'});
        NumeditParam(obj, 'post_dur',0.05, x, y,'labelfraction',0.5,...
            'label', 'dur', 'position', [x+300 y 100 20]);
        set_callback(post_dur, {mfilename, 'calculate_fixation_and_pre_go_durs'});
        next_row(y,1.1);
        
        %% Section , Headers
        SubheaderParam(obj,'lab1', 'pre',x,y,'position', [x y 90 20]);
        SubheaderParam(obj,'lab2', 'stimulus',x+100,y,'position', [x+100 y 90 20]);
        SubheaderParam(obj,'lab3', 'delay',x+200,y,'position', [x+200 y 90 20]);
        SubheaderParam(obj,'lab4', 'post',x+300,y,'position', [x+300 y 90 20]);next_row(y, 1.5);
        
        
        %% Section 0, Row 3
         NumeditParam(obj, 'initial_fixation_dur',0.35, x, y,'labelfraction',0.65,...
            'TooltipString', sprintf(['\ninitial fixation dur on first day of center poking',...
                                      '\nif animal does not perform well, determining_tomorrows_fixation',...
                                      '\nwill decresae this by the adjust amount until animal can engage']),...
            'label', 'initial', 'position', [x y 100 20]);
         NumeditParam(obj, 'fixation_adjustment',0.05, x, y,'labelfraction',0.65,...
            'TooltipString', sprintf(['\nto be used by the determine_tomorrows_fixation case when',...
                                      '\na "bad" day was had, how much should we decrease fixation by in seconds',...
                                      '\nthis is primarily used when initially starting fixation at a high',...
                                      '\nvalue, or when an animal does no trials and we have no data on their',...
                                      '\naverage poke length']),...
            'label', 'adjustement', 'position', [x+(1*100) y 100 20]);
         NumeditParam(obj, 'target_fixation_dur',2, x, y,'labelfraction',0.65,...
            'TooltipString', sprintf(['\ntarget duration that fixation grows to',...
                                      '\nused for EOS logic as well as determining_tomorrows_fixation']),...
            'label', 'target', 'position', [x+(2*100) y 100 20]);

        ToggleParam(obj, 'has_reached_fixation_target',0, x,y, 'position', [x+(3*100) y 100 20],...
            'OnString', 'Target Reached',...
            'OffString', 'Target Not Reached',...
            'TooltipString', sprintf(['\nIf animal has reached the fixation target yet',...
                            '\nthis toggle is used to determine growth when animal has reached',...
                            '\nfixation target prior to finishing the pre-prob stages in determine_tomorrows_fixation',...
                            '\nand fixation becomes sampled (rather than growing beyond the target']));
        next_row(y,1.2);
        
        %% Section 0, Row 2
        MenuParam(obj, 'settling_in_growth', {'none';'overnight_growth';'overnight_sampled';'fixed';},...
                1, x, y, 'label', 'settling growth',...
                'TooltipString', '\ntype of growth occuring for settling in period, if any',...
                'labelfraction',0.6,'position', [x y 133 20]);
         NumeditParam(obj, 'legal_cbreak_dur',0.05, x, y,'labelfraction',0.6,...
            'TooltipString', sprintf(['\nif violation penalty is on (i.e. settling in does not',...
                                      '\ndetermine fication, how long an animal can be in the cpoke out',...
                                      '\nstate before returning to the center port without penalty']),...
            'label', 'lgl cbreak', 'position', [x+133 y 133 20]);
        ToggleParam(obj, 'cled_mapped_to_fixation_dur',1, x,y, 'position', [x+(2*133) y 133 20],...
            'OnString', 'CLED mapped to fix',...
            'OffString', 'CLED mapped to cpoke',...
            'TooltipString', sprintf(['\nIf on, the center LED stays on until the fixation dur ends',...
                                       '\nthis means that the animal can violate and leave the cport',...
                                       '\nand the light stays on until they were supposed to fixate, however',...
                                       '\nthe go cue does NOT play. If off, the LED is mapped to the animal',...
                                       '\nand turns off either when they violate or when the go cue plays']));
       next_row(y,1.2);
        
        %% Section 0, Row 1- settling_in, pre_go, fication
        NumeditParam(obj, 'settling_in_dur',0.001, x, y,'labelfraction',0.65,...
            'TooltipString', sprintf(['\nduration of cpoke needed to trigger a trial',...
                                      '\nnote that if settling in dur determines fixation',...
                                      '\nthis is equivalent to learning with no viol penalty and immediate',...
                                      '\nretry. Handled by calculate_fixation_and_pre_go_durs and if stimuli on',...
                                      '\nand settling in does NOT determine fixation, also handled by',...
                                      '\ncalculate_pre_and_settling_durs']),...
            'label', 'settling in dur', 'position', [x y 133 20]);
        set_callback(settling_in_dur, {mfilename, 'calculate_pre_and_settling_durs'});
        set_callback(settling_in_dur, {mfilename, 'calculate_fixation_and_pre_go_durs'});
            
        
        DispParam(obj, 'pre_go_dur',0.1, x, y,'labelfraction',0.6,...
                'TooltipString', sprintf(['\nThis is the duration of time an animal needs to fixate',...
                                           '\nonce the settling in period ends, in other words the duration',... 
                                           '\nof time in which violations can occur and stim etc play',...
                                           '\nHandled by calculate_fixation_and_pre_go_durs',...
                                           '\nif settling in dets fix, this is fixed to 0.001',...
                                           '\nelse if stimuli are off, only determined by delay_dur',...
                                           '\nif stimuli are on determined by pre, 2*stim, delay, post',...
                                           '\nand assumes a delayed comparison task structure']),...
                'label', 'pre go dur', 'position', [x+133 y 133 20]);
            
        DispParam(obj, 'fixation_dur', 0.1, x, y, 'labelfraction',0.6,... 
            'TooltipString', sprintf(['\nThis is the total fixation duration for the whole trial',...
                                      '\nHandled by calculate_fixation_and_pre_go_durs',...
                                      '\nand is equal to the settling in dur + pre go dur']),...
            'label', 'fix dur', 'position', [x+(2*133) y 133 20]);
        next_row(y,1.2);
       
       
        %% Section 0, Header

        SubheaderParam(obj,'lab1', 'Fixation',x,y,'position', [x+50 y 300 20]); 
        ToggleParam(obj, 'settling_in_determines_fixation',1, x,y, 'position', [x y 133 20],...
            'OnString', 'Settling Dets Fix ON',...
            'OffString', 'Settling Dets Fix OFF',...
            'TooltipString', sprintf(['\nIf on, settling in dur determines the required',...
                            '\nfixation length allowing for unlimited retries (i.e. no viol penalty)',...
                            '\nfor leaving NIC, trial will not clean up until fixation',...
                            '\nis completed. pre_go_dur is set to 0.001 which makes a violation',...
                            '\npenalty impossible unless R/L ports are being used',...
                            '\nsee SMA google drawing for more info']));
        set_callback(settling_in_determines_fixation, {mfilename, 'calculate_fixation_and_pre_go_durs'});
          
        next_row(y,1.1);
              
        %% TOP OF SHAPING SECTION- Header

        SubheaderParam(obj, 'lab0', 'Shaping Section',x+200,y, 'position', [x y 400 20]); next_row(y);

        %% Callbacks to ensure correct settings of GUI params/format
        ShapingSection(obj, 'calculate_fixation_and_pre_go_durs');
        ShapingSection(obj, 'temp_error_penalty_callback');
        ShapingSection(obj, 'error_penalty_callback');
        ShapingSection(obj, 'exponential_growth_callback');
        ShapingSection(obj, 'give_type_callback');
        ShapingSection(obj, 'compute_alpha_plus_callback');
%         ShapingSection(obj, 'check_and_set_sound_durations');
        
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% SETUP INTERNAL VARS %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        SoloParamHandle(obj, 'task_prefixes', 'value', {'settling_in','pre', 'stimulus', 'delay', 'post', 'give_del'});
        SoloParamHandle(obj, 'penalty_prefixes', 'value', {'violation', 'temp_error', 'error', 'inter_trial'});
        
        SoloParamHandle(obj, 'violation_prev_sound_dur', 'value', 0);
        SoloParamHandle(obj, 'temp_error_prev_sound_dur', 'value', 0);
        SoloParamHandle(obj, 'error_prev_sound_dur', 'value', 0);

        
        SoloParamHandle(obj, 'settling_in_warm_up_step_size', 'value', 0);
        SoloParamHandle(obj, 'pre_warm_up_step_size', 'value', 0);
        SoloParamHandle(obj, 'stimulus_warm_up_step_size', 'value', 0);
        SoloParamHandle(obj, 'delay_warm_up_step_size', 'value', 0);
        SoloParamHandle(obj, 'post_warm_up_step_size', 'value', 0);
        SoloParamHandle(obj, 'give_del_warm_up_step_size', 'value', 0);
        SoloParamHandle(obj, 'give_del_in_adaptive_warm_up', 'value', 0);
        SoloParamHandle(obj, 'warm_up_implemented', 'value', 0);
        
        min_state_time = 0.0003;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%    SEND OUT VARS    %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        DeclareGlobals(obj, 'rw_args', {'SMA_set'});
        SoloFunctionAddAllVars(obj, 'TrainingSection', 'rw_args');
        SoloFunctionAddAllVars(obj, 'SMA_cpoke', 'ro_args');
        SoloFunctionAddAllVars(obj, 'SMA_spoke', 'ro_args');
        SoloFunctionAddAllVars(obj, 'SMA_habituation', 'ro_args');
        SoloFunctionAddAllVars(obj, 'HistorySection', 'ro_args');
        SoloFunctionAddVars('StimulusSection', 'ro_args', {'stimulus_dur','delay_dur'});
        
        % Add to all active TS_ files
        for i = 1:numel(value(active_curricula))
            % Construct the function call with the updated curriculum name
            current_curricula = value(active_curricula{i});
            function_call = sprintf("SoloFunctionAddAllVars(obj, 'TS_%s', 'rw_args');", current_curricula );
            eval(function_call);
        end
        
    % ------------------------------------------------------------------
    %              PREPARE NEXT TRIAL
    % ------------------------------------------------------------------
        
    case 'prepare_next_trial'
        if n_done_trials == 0
            % if warm-up is on for a given task variable, compute the step size
            % necessary to grow that parameter up to prev_session's value in
            % n_warm_up_trials steps.
            ShapingSection(obj, 'initialze_fixed_growth_warm_up_parameters');
            return; 
        end 

        
        % if none, fixed or discrete growth set for any of the task
        % prefixes, call the growth cases to assess if they should grow and
        % implement the growth.
        for iperiod = 1 : length(task_prefixes)
            % get variables for the prefix in the loop (e.g. pre_)
            period = task_prefixes{iperiod};
            growth = value(eval([period '_growth']));
            fixed_growth_rate = value(eval([period '_fixed_growth_rate']));
            warm_up = value(eval([period '_warm_up']));
            warm_up_step_size = value(eval([period '_warm_up_step_size']));

            switch growth
            case 'none'
                disp('') % do nothing, but can set a breakpoint here
                % note other growth types that are will never be 
                % implemented on a trial by-trial basis are 
                % overnight_growth and overnight_sampled
            case 'fixed'

                % implement warm up or fixed growth depending on if warm up
                % is on
                if warm_up && (n_trials_stage < n_warm_up_trials) 
                    ShapingSection(obj, 'update_fixed', period, warm_up_step_size, 's')
                    warm_up_implemented.value = 1;
                else
                    ShapingSection(obj, 'update_fixed', period);
                    warm_up_implemented.value = 0;
                end

            case 'discrete'
                % only possible for delay_dur, select at random and assign
                random_idx = randi(length(delay_discrete_values), 1);
                delay_dur.value = value(delay_discrete_values(random_idx));
            
            case 'adaptive' 
                %% note the cases for this function are more modern and take
                % care of dealing with warm up and trial types internally

                ShapingSection(obj, 'update_adaptive', period);
            end % growth switch
        end % task prefix

        % Growth types that are not dependent on if previous trial was a
        % violation
        if strcmp(delay_growth, 'exp')
            randvalue = DistribInterface(obj, 'get_new_sample', 'exp_sample');
            delay_dur.value = randvalue;
        end
        
            
        if strcmp(stimulus_growth, 'fill_delay')
            % only possible for stimulus_dur. this is used when
            % fixation length isn't changing, but sounds are
            % growing so delay dur needs to become smaller in
            % tandem.
            if value(frac_violations) < 0.5 && ...
                    value(stimulus_dur) < value(stimulus_max)

                stimulus_dur.value = value(stimulus_dur) + value(stimulus_fixed_growth_rate);
                delay = value(delay_dur) - (2 * value(stimulus_fixed_growth_rate));
                delay_dur.value = max(0.2, delay); % ensure delay is never less than 0.2
            else
                disp('fill_delay selected, but not evaluated');
            end
        end

        % Update the penalty lengths if last result was not a hit
        switch result_history(end)
        case was_violation
            switch value(violation_dur_type)
            case 'growing'
                ShapingSection(obj, 'update_fixed', 'violation');
            case 'sampled'
                ShapingSection(obj, 'update_sampled', 'violation');
            end

        case was_temp_error 
            switch value(temp_error_dur_type)
            case 'growing'
                ShapingSection(obj, 'update_fixed', 'temp_error');
            case 'sampled'
                ShapingSection(obj, 'update_sampled', 'temp_error');
            end

        case was_error 
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
        
        
        % update prenatly sound durations if needed
        ShapingSection(obj, 'check_and_set_sound_durations');
        
        % calculate time before sound a for SMA
        ShapingSection(obj, 'calculate_pre_and_settling_durs');
       
        % make sure durations are not out of min/max windows
        ShapingSection(obj, 'check_duration_boundaries');
        
        % given stimuli on/off and if settling in determines fixation
        % determine the total required fixation length (fixation_dur) as
        % well as the duration of fixation that will lead to a violation if
        % not completed (pre_go_dur).
        ShapingSection(obj, 'calculate_fixation_and_pre_go_durs');
        
        % make sure go and give do not interfear with eachother if on
        ShapingSection(obj, 'ensure_correct_go_type');

        % if give_type_set is not none, check what frac of give trials is 
        % and implment, also check water isn't piling up at the port.
        ShapingSection(obj, 'set_give_based_on_frac_and_hist');

        % make GUI cleaner 
        ShapingSection(obj, 'temp_error_penalty_callback');
        ShapingSection(obj, 'error_penalty_callback');
        ShapingSection(obj, 'exponential_growth_callback');
        ShapingSection(obj, 'give_type_callback');
        ShapingSection(obj, 'compute_alpha_plus_callback');
       
 
    %---------------------------------------------------------------%
    %          GUI param callbacks                                  %
    %---------------------------------------------------------------%
    %%
    case 'calculate_fixation_and_pre_go_durs' 
        %%
        if settling_in_determines_fixation
            disable(pre_dur); disable(stimulus_dur); disable(delay_dur); disable(post_dur);
            disable(violation_dur); disable(violation_sound_match_timeout); disable(violation_dur_type);
            pre_go_dur.value = 0.001;
             
        else
            enable(violation_dur); enable(violation_sound_match_timeout); enable(violation_dur_type);
            if ~value(stimuli_on)
                % we don't need pre/post/stim durs here. But, we do want to
                % count the time the animal alredy fixated in the settling
                % in period towards the valid fixation length 
                enable(delay_dur); disable(pre_dur); disable(stimulus_dur); disable(post_dur);
                
                % ensure pre_go_dur isn't negative bc delay < settling
                if value(delay_dur) <= value(settling_in_dur)
                    pre_go_dur.value = 0.001;
                else
                    pre_go_dur.value = value(delay_dur) - value(settling_in_dur);
                end
            else
                enable(pre_dur); enable(stimulus_dur); enable(delay_dur); enable(post_dur);
                % adjusted pre dur takes into account settling in dur in
                % separate case
                pre_go_dur.value = value(adjusted_pre_dur) + 2*(value(stimulus_dur)) + value(delay_dur) + value(post_dur);
                
            end
            
        end
        
        fixation_dur.value = value(settling_in_dur) + value(pre_go_dur);
        
        
    
    case 'ensure_correct_go_type'
    %%
        % you can't have a persistent go cue if you need to flash the lights for the give as well
        % so this callback will adjust it to be a flash 
        switch value(go_type)
        case 'LED_persist'
            disable(go_dur); % not used in this case
            
            if strcmp(value(give_type_set), 'light') || strcmp(value(give_type_set), 'water_and_light')
                go_type.value = 'LED_flash';
                disp('if give type is light, go type cannot be LED persist!');
            end
        case 'LED_flash' 
            enable(go_dur);
        case 'sound'
            enable(go_dur);
        case 'sound_localized'
            enable(go_dur);
        case 'none'
            disable(go_dur);  
        end
        
        
    case 'temp_error_penalty_callback'
    %%   
        % enabling & disabling params based off of toggle
        if value(temp_error_penalty)
            enable(temp_error_dur);
            enable(temp_error_sound_match_timeout);
            enable(temp_error_dur_type);
            enable(retry_type);
        else
            disable(temp_error_dur);
            disable(temp_error_sound_match_timeout);
            disable(temp_error_dur_type);
            disable(retry_type);
        end
        
    case 'error_penalty_callback'
    %%
        if value(temp_error_penalty) && strcmp(value(retry_type), 'multi')
            disable(error_dur);
            disable(error_sound_match_timeout);
            disable(error_dur_type);
        else
            enable(error_dur);
            enable(error_sound_match_timeout);
            enable(error_dur_type);
        end
    
    case 'give_type_callback'
     %%
        if strcmp(value(give_type_set),'none')
            disable(give_del_dur);
            disable(give_del_growth);
        else
            enable(give_del_dur);
            enable(give_del_growth);
        end
    
    case 'compute_alpha_plus_callback'
      %%  
        give_del_adaptive_alpha_plus.value = 1 - value(give_del_adaptive_alpha_minus);

    case 'exponential_growth_callback'
        %%
        % TODO make this a for loop
        if strcmp(delay_growth, 'exp_fixed_growth')

            enable(exp_lower_bound_fixed_growth_rate); enable(exp_lower_bound_max);
            enable(exp_lower_bound_min); enable(exp_tau_fixed_growth_rate);
            enable(exp_tau_max); enable(exp_tau_min); enable(exp_upper_bound_fixed_growth_rate);
            enable(exp_upper_bound_max); enable(exp_upper_bound_min);
        else
            disable(exp_lower_bound_fixed_growth_rate); disable(exp_lower_bound_max);
            disable(exp_lower_bound_min); disable(exp_tau_fixed_growth_rate);
            disable(exp_tau_max); disable(exp_tau_min);
            disable(exp_upper_bound_fixed_growth_rate);
            disable(exp_upper_bound_max); disable(exp_upper_bound_min);
        end


    %---------------------------------------------------------------%
    %          initialze_fixed_growth_warm_up_parameters            %
    %---------------------------------------------------------------%
    case 'initialze_fixed_growth_warm_up_parameters'
        %%
        % case to calculate the appropriate warm up step size to use
        % during n_warm_up_trials for a specified variable. Modified to
        % take into account settling_in_determiens_fixationa and only
        % applied for fixed growth warm up
        disp('*********Initializing Fixed Growth Warm Up!');
        for iperiod = 1 : length(task_prefixes)
            
            period = task_prefixes{iperiod};
            warm_up_on =  value(eval([period '_warm_up']));
            growth_type = value(eval([period '_growth']));
            fixed_growth_rate = value(eval([period '_fixed_growth_rate']));
            fixed_growth_unit = value(eval([period '_fixed_growth_unit']));
            
            if warm_up_on && strcmp(growth_type, 'fixed')
                cur_dur = value(eval([period '_dur']));
                prev_dur = value(eval([period '_prev_session']));
                initial_fixation_dur = value(initial_fixation_dur);

               if ~settling_in_determines_fixation && strcmp(period, 'delay') && ~value(stimuli_on)
                   % delay dur is determning fixation value but we do not
                   % need to warm up unless previous day is greater than
                   % the settling in dur
                   if prev_dur >= initial_fixation_dur
                       starting_value = initial_fixation_dur; 
                   else 
                       starting_value = prev_dur; % stay where we are, no warm up needed
                   end

                   delay_dur.value = starting_value; % initialize today's value

               elseif settling_in_determines_fixation && strcmp(period, 'settling_in') && ~value(stimuli_on)
                   % settling in determines fixation value and should be
                   % grown from initial starting value to previous

                   if settling_in_dur >= initial_fixation_dur
                       starting_value = initial_fixation_dur;% start warm up initial fixation dur 
                   else
                       starting_value = prev_dur; % stay where we are, no warm up needed (not really possible but keeping for symmetry)
                   end

                   settling_in_dur.value = starting_value;% initialize today's value
                   
               else
                   % otherwise, assume we start from the periods min value
                   starting_value = value(eval([period '_min']));
                   eval([period '_dur.value = starting_value;']); 
               end
               
               % calculate linear fixed 's' growth given starting value
               step_size = (prev_dur - starting_value)/n_warm_up_trials;
               
               % if the warm up is smaller than the original growth, just
               % do the original growth. If growing by %, will always
               % implement warm up step size.
               if strcmp(fixed_growth_unit, 's')
                   step_size = max(step_size, fixed_growth_rate);
               end

               eval([period '_warm_up_step_size.value = step_size;']);
               ShapingSection(obj, 'calculate_fixation_and_pre_go_durs');
                       
            else
                disp('') % do no calculations if warm up is off for period
            end %end if warmup on and fixed growth
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
        elseif length(varargin) > 1
            task_var = varargin{1};
            growth_rate = varargin{2};
            growth_unit = varargin{3};
            cur_dur = value(eval([task_var '_dur']));
        end
        
        % some variables grow with different logic. for example, give_del
        % should only grow after a hit, while the other task_prefixes
        % should only grow after a non-violation
        grow_var = false;
        if strcmp(task_var, 'give_del')
            if was_hit
                grow_var = true;
            end
        else
            if ~was_violation
                grow_var = true;
            end
        end
        
        if grow_var
            switch growth_unit
            case 's'
                eval([task_var '_dur.value = cur_dur + growth_rate;']);
            case '%'
                % ensure step is not smaller than 1 ms, if so then do a
                % linear step by 1 ms (ie this is the floor)
                step = max((cur_dur * growth_rate), 0.001);
                eval([task_var '_dur.value = cur_dur + step;']);
            end
        else
            sprintf('task growth on for %s, but wrong trial condition', task_var)
        end
        
  

    %---------------------------------------------------------------%
    %          update_sampled                                       %
    %---------------------------------------------------------------%
    case 'update_sampled'
        task_var = varargin{1};
        sample_mean = value(eval([task_var '_sample_mean']));
        sample_std = value(eval([task_var '_sample_std']));
        eval([task_var '_dur.value = normrnd(sample_mean, sample_std, 1);']);
        

    %---------------------------------------------------------------%        
    %          adaptive growth                                      %
    %---------------------------------------------------------------%
     case 'update_adaptive'
        %% Implement adaptive growth
        
        % The logic is as follows Given: alpha+, alpha-, stepsize s and 
        % the fact that alpha+ + alpha- = 1
        
        % if positive event (hit, etc): grow var by step size * alpha+
        % if negetive event (miss, etc): grow var by step size * alpha-
        
        % this means that when performance is ~= alpha-, no growth occurs
        % and adaptive growth stabilizes
        % ===
        
        task_var = varargin{1};
        current_dur = value(eval([task_var '_dur']));
        alpha_minus = value(eval([task_var '_adaptive_alpha_minus']));
        alpha_plus = value(eval([task_var '_adaptive_alpha_plus']));
        
        % first check if warm up is on, then check if we are in it- this
        % will determine how big the step size is. warm up = accelerated
        % growth to reach previous sessions duration in n_warm_up_trials
        ShapingSection(obj, 'determine_if_in_warm_up_for_adaptive', task_var);
        in_warm_up = value(eval([task_var '_in_adaptive_warm_up']));

        if in_warm_up
            step = value(eval([task_var '_warm_up_step_size']));
        else
            step = value(eval([task_var '_adaptive_step_sec']));
        end

        % given step size and alpha+,- update var duration
        % update logic specific to task variable, currently only have
        % adaptive growth implemented for give_del and violations/no
        % answers should lead to no growth.
        if strcmp(task_var, 'give_del') 
            if was_hit
                new_dur = current_dur + (step * alpha_plus);
            elseif was_error
                new_dur = current_dur - (step * alpha_minus);
            else
                new_dur = current_dur;
            end
        end
        
        eval([task_var '_dur.value = new_dur;']);     


        
        
    case 'determine_if_in_warm_up_for_adaptive'
        %% determine if the variable is in a warm-up phase or not. 
        % this involved checking if how many trials of the specified subset
        % where adaptive growth is happening have elapsed. Right now, there
        % are no subsets, but this could be changed
        
        task_var = varargin{1};
        warm_up_on = value(eval([task_var '_warm_up']));
        
        % check if warm up on!!!
        trial_subset = value(eval([task_var '_growth_trial_subset']));
        
        if strcmp(trial_subset, 'all')
            n_trials = value(n_trials_stage);
        end
            
        if n_trials < value(n_warm_up_trials) && warm_up_on
            in_warm_up = 1;
        else
            in_warm_up = 0;
        end
        
        eval([task_var '_in_adaptive_warm_up.value = in_warm_up;']);
                 

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
        
        % go sound
        if strcmp(value(go_type), 'sound_localized')
            % TODO- make a GUI variable called go_sound_balance so it can
            % be parameterized when reducing strength of localization cue
            if strcmp(value(current_side), 'LEFT') 
                go_sound_balance = -1; % left speaker only 
            else
                go_sound_balance = 1; % right speaker only
            end
        else
            go_sound_balance = 0;
        end
        SoundInterface(obj, 'set', 'GoSound',...
                            'Dur1', value(go_dur),...
                            'Bal', go_sound_balance);
        
        % update AOM with any new durations
        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');

    %---------------------------------------------------------------%
    %          calculate_pre_and_settling_durs                      %
    %---------------------------------------------------------------%
    case 'calculate_pre_and_settling_durs'
        if value(stimuli_on)
            % Ensure that settling in does not exceed pre
            if value(settling_in_dur) > value(pre_dur)
                settling_in_dur.value = value(pre_dur);
            end

            % given settling_in has already elapsed,
            % subtract that time off of pre_dur 
            if value(pre_dur) == value(settling_in_dur)
                adjusted_pre_dur.value = 0.001;
            else
                adjusted_pre_dur.value = max(value(pre_dur) - value(settling_in_dur), 0.001);
            end
        else
            % if the stimuli aren't on, we aren't using pre_dur for
            % anything, so we don't need to adjust it at all.
            adjusted_pre_dur.value = value(pre_dur);
        end
    
    %---------------------------------------------------------------%
    %          set_give_based_on_frac_and_hist                      %
    %---------------------------------------------------------------%    

    case 'set_give_based_on_frac_and_hist'

        % determine if give is on given the frac where 1 = always on
        give = rand(1) < value(give_frac);

        % no give if above threshold, or type is already none
        if give == 0 || strcmp(value(give_type_set), 'none')
            give_type_implemented.value = 'none';
        else
            give_type_implemented.value = value(give_type_set);
        end

        % check to make sure the water delivered on the a previous trial was
        % drunk and don't deliver on this trial if it wasn't. This only
        % applied to the SMA_spoke where many 'gives' can pile up and put a
        % lot of water in the port
        if strcmp(value(SMA_implemented), 'spoke') && value(give_water_not_drunk)
            if strcmp(value(give_type_set), 'water')
                give_type_implemented.value = 'none';
            elseif strcmp(value(give_type_set), 'water_and_light')
                give_type_implemented.value = 'light';
            end
        end
    %---------------------------------------------------------------%
    %          adjust_give_frac_based_on_performance                %
    %---------------------------------------------------------------%        
    case 'adjust_give_frac_based_on_performance'
        
        % if animal does above chance on no-give trials, decrease the
        % number of no-give trials
        if value(give_frac) == 0 % turn off
            give_type_set.value = 'none';
            decrease_give_frac.value = 0;
        elseif value(give_frac) == 1 % first day of decrease
            give_frac.value = value(inital_give_frac);
            
        % if you're fraction correct without give is above the threshold OR
        % you've been at init give frac for 3 days, decreaes the give frac
        % this is because init is usually at 60% and some animals need that
        % extra push to 45% to start guessing
        elseif (value(frac_correct_no_give) > value(no_give_perf_threshold)) || ...
                (value(give_frac) == value(inital_give_frac) && ...
                value(n_days_at_give_frac) > value(max_days_at_init_frac))
            give_frac.value = max(value(give_frac) - value(give_frac_decrease_rate), 0);
            n_days_at_give_frac.value = 0;
            
        else
            n_days_at_give_frac.value = value(n_days_at_give_frac) + 1;
        end
        
    %---------------------------------------------------------------%
    %            determine_tomorrows_fixation_dur                   %
    %---------------------------------------------------------------%
    case 'determine_tomorrows_fixation_dur'
        %% Determine Tomorrows Fixation Dur
        %
        % This case is written to be run at the end of a session to
        % determine what the  fixation dur should be for tomorrow given the
        % variable that determines fixation (settling_in or delay_dur), the
        % type of growth (overnight_growth, overnight_sampled, fixed) and
        % the animals performance on the day.
        %
        % This case also takes care of dealing with "high start" issue.
        % When an animal is asked on the first day of center poking to
        % fixated for > ~200 ms (reaction time). Some animals really
        % struggle and can't get the first day. This case takes care of
        % lowering this initial value by an adjuster for both overnight and
        % fixed growth regimes.
        %
        % It should also be noted that once an animal reaches the fixation
        % target if they are in a overnight growth regime they will be
        % randomly sampled from exp. If they are in a fixed growth regime,
        % their warm up target will be randomly sampled from the same exp.
        %
        % Otherwise, the bulk of this case is written for implenting
        % overnight growth such that tomorrows fixation dur is determine by
        % today's center poking statistics.
        
        %% Checks & SPH Access
        if value(stimuli_on) 
            warning("***Stimuli are on, case is not currently written for this ");
            return
        end
        
        % get valid trial indices
        try
            vh = value(violation_history);
            vh(isnan(vh)) = 0; %nan is when there are no answer trials
            valid_trials = ~vh;

            % get duration of cpokes for each trial (pre-calculated from peh)
            cpoke_dur_handle = get_sphandle('fullname', 'HistorySection_cpoke_dur');
            cpoke_durs       = value(cpoke_dur_handle{1}); % unpack from SPH struct
            if isempty(cpoke_durs)&& length(cpoke_dur_handle) > 1
                % sometimes when debugging on homepod, multiple cpoke durs are 
                % reutrned with the first being empty
                cpoke_durs = value(cpoke_dur_handle{2}); 
            end

            %% Toggle variables based on if settling in determines fixation
            % if settling in determines fixation, then violation penalty for
            % leaving the center port before the go cue is off. In other words,
            % this means settling_in_dur is what is being primarily being used
            % fixation_dur such that:
            %   pre_go_dur = 0.001 to keep SMA happy
            %   fixation_dur = settling_in_dur + pre_do_dur
            %
            % A trial is only counted here if the cpoke was completed. The only
            % possible way to violate is if the animal side pokes during the
            % pre_go_dur window (which is very, very small). So, in general
            % n_done_trials ~= n_valid trials.

            if value(settling_in_determines_fixation)
                task_var = 'settling_in';
                task_var_value = value(settling_in_dur);

                % failed pokes for a trial are summarized by avg_settling_in_durs which
                % is the average of all the failed pokes that were below the
                % fixation_dur threshold for a trial
                avg_settling_in_dur_handle = get_sphandle('fullname', 'HistorySection_avg_settling_in_history');
                avg_settling_in_durs = value(avg_settling_in_dur_handle{1}); % unpack from SPH struct
                avg_failed_cpoke_dur = mean(avg_settling_in_durs, 'omitnan');

                % growth is determined by if settling in dur > initial
                if task_var_value <= value(initial_fixation_dur)
                    havent_started_growing = 1;
                else
                    havent_started_growing = 0;
                end

            % if settling in dur does not determine fixation, then the
            % violation penalty is on for the pre_go_dur period- which is now,
            % in theory, larger than 0.001. Therefore, fixation_dur is
            % parameterized by settling_in_dur and delay_dur such that pre go
            % dur is the time during fixation where violations are possible.
            % And if an animal makes it through settling_in, this counts to
            % their overal fixation goal for the trail
            %   pre_go_dur = max(0.001, delay_dur - settling_in_dur) 
            %   fixation_dur = settling_in_dur + pre_go_dur

            else 
                task_var = 'delay';
                task_var_value = value(delay_dur);

                % Failed poked for a trial are the cpokes on violation trials
                violation_cpokes     = cpoke_durs(~valid_trials);
                failed_cpoke_durs    = value(cpoke_durs(~valid_trials)); 
                avg_failed_cpoke_dur = mean(failed_cpoke_durs, 'omitnan');

                % note! this is written assuming V1 protocol where fixation dur
                % is low (~10ms) and no adjustments are needed. If there is a
                % protocol where delay dur starts high, additional logical will
                % need to be implemented here and some sort of variable
                % distinguishing the high start from the low start. Will need
                % to adjust the delay dur for the day as well as the prev delay
                % dur for the warm up (if any)
                havent_started_growing = 0;

            end

            %% Compute shared varibles for logic below
            fixation_dur = value(fixation_dur);
            growth_type = value(eval([task_var '_growth']));

            %% Logic for Growth
            switch growth_type

            case 'overnight_growth'
                % calculate logic parameters
                n_valid_trials = sum(valid_trials, 'omitnan');

                enough_data = n_done_trials > 5 || ~isnan(avg_failed_cpoke_dur); % 5
                was_bad_day = value(n_valid_trials) <= 20; %20
                was_good_day = value(n_valid_trials) >= 50; %50

                valid_cpoke_durs     = value(cpoke_durs(valid_trials));
                avg_valid_cpoke_dur  = mean(valid_cpoke_durs, 'omitnan');

                % check to see if animal has started to understand fixation yet
                if (havent_started_growing && was_bad_day) 

                    adjusted_fixation_dur = task_var_value - value(fixation_adjustment);
                    updated_task_var_value = max(value(settling_in_min), adjusted_fixation_dur);

                % check to see if animal has reached fixation target and sample
                % from distribution if so
                elseif fixation_dur >= value(target_fixation_dur) && was_good_day
                   has_reached_fixation_target.value = 1;
                   eval([task_var '_growth.value = ''overnight_sampled'';']); 
                   updated_task_var_value = DistribInterface(obj, 'get_new_sample', 'exp_sample');

                % Animal  hasn't grown to full target yet-
                % If it was a good day, let's grow to the average valid cpoke.
                % If it was a bad day we will decrease the requirement a bit.
                % If it was inbetween bad and good don't do anything.
                elseif ~value(has_reached_fixation_target)
                    if was_good_day
                        updated_task_var_value = min(value(settling_in_max), avg_valid_cpoke_dur); 
                    elseif was_bad_day && enough_data
                        % if we have enough data and it was bad, set fixation
                        % to halfway between average failed and today's requirement
                        delta_from_required = max(0.001, fixation_dur - avg_failed_cpoke_dur);
                        adjusted_fixation_dur = task_var_value - (0.5 * delta_from_required);
                        updated_task_var_value = max(value(initial_fixation_dur), adjusted_fixation_dur);
                    else %do nothing- just keep things as is!
                        updated_task_var_value = task_var_value;
                    end
                end

                % Set new duration for variable given overnight_growth
                eval([task_var '_dur.value = updated_task_var_value;']);

            case 'overnight_sampled'
                % Simple case here- just sample a new value & set it
                updated_task_var_value = DistribInterface(obj, 'get_new_sample', 'exp_sample');
                eval([task_var '_dur.value = updated_task_var_value;']);

            case 'fixed'
                % Check to see if target fixation value was reached today
                if fixation_dur > value(target_fixation_dur)
                    has_reached_fixation_target.value = 1;
                end

                if value(has_reached_fixation_target)
                    % randomly sample duration to warm up to & then grow from
                    updated_task_var_value = DistribInterface(obj, 'get_new_sample', 'exp_sample');
                    eval([task_var '_prev_session.value = updated_task_var_value;']);
                else
                    % do nothing! this is taken care of in ShapingSection warm up 
                    % and fixed_growth cases
                    disp('');
                end
            end % switch growth type
        catch me
            CommentsSection(obj, 'append_line', me.message)
        end
            
     
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
        
        if value(decrease_give_frac)
           ShapingSection(obj, 'adjust_give_frac_based_on_performance')
        end
        
        ShapingSection(FixationGrower, 'determine_tomorrows_fixation_dur');
        
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

    case 'show_hide_SMA_params_window'
        if SMA_params == 0, set(value(SMA_params_window), 'Visible', 'off');
        else                set(value(SMA_params_window), 'Visible', 'on');
        end
    case 'hide_SMA_params_window'
        set(value(SMA_params_window), 'Visible', 'off'); SMA_params.value = 0;
    
    case 'show_hide_give_params_window'
        if give_params == 0, set(value(give_params_window), 'Visible', 'off');
        else                set(value(give_params_window), 'Visible', 'on');
        end
    case 'hide_give_params_window'
        set(value(give_params_window), 'Visible', 'off'); give_params.value = 0;

    case 'show_hide_growth_params_window'
        if task_growing_parameters == 0, set(value(growth_params_window), 'Visible', 'off');
        else                             set(value(growth_params_window), 'Visible', 'on');
        end
    case 'hide_growth_params_window'
        set(value(growth_params_window), 'Visible', 'off'); task_growing_parameters.value = 0;

    case 'show_hide_exp_sample_params_window'
        if exp_sample_params == 0, set(value(exp_sample_params_window), 'Visible', 'off');
        else                   set(value(exp_sample_params_window), 'Visible', 'on');
        end
    case 'hide_exp_sample_params_window'
        set(value(exp_sample_params_window), 'Visible', 'off'); exp_sample_params.value = 0;

    case 'close'
        delete(value(penalty_params_window));
        delete(value(soundui_window));
        delete(value(SMA_params_window));
        delete(value(give_params_window));
        delete(value(growth_params_window));

end

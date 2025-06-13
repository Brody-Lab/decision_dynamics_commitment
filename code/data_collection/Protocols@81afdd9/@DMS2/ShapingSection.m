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
        %%% --- PENALTY PARAMETERS SUBWINDOW START ---
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
        
        %%% --- PENALTY & GO SOUNDUI SUBWINDOW START ---
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
            'how the duration of the violation penalty is being determined', 'labelfraction',0.4,'position', [x y 100 20]);
        MenuParam(obj, 'temp_error_dur_type', {'stable';'sampled';'growing'},...
            1, x, y, 'label', 'type',...
            'labelfraction',0.4,'position', [x+100 y 100 20]);
        MenuParam(obj, 'error_dur_type', {'stable';'sampled';'growing'},...
            1, x, y, 'label', 'type',...
            'labelfraction',0.4,'position', [x+200 y 100 20]);
        NumeditParam(obj, 'legal_cbreak_dur',0.05, x, y,'labelfraction',0.6,...
        'TooltipString', 'how long animal can break fixation within a trial',...
        'label', 'lgl cbreak', 'position', [x+300 y 100 20]);
        next_row(y,1.1)
        
        %% Section 3, Row 2
        %%% Toggle sounds matching timout & fixation nic
        ToggleParam(obj, 'violation_sound_match_timeout', 1, x, y, 'position', [x y 100 20],...
            'OffString', 'Sound != Tout', 'OnString', 'Sound == Tout', ...
            'TooltipString', 'If on, sound will match penalty duration above');
        ToggleParam(obj, 'temp_error_sound_match_timeout', 1, x, y, 'position', [x+100 y 100 20],...
            'OffString', 'Sound != Tout', 'OnString', 'Sound == Tout', ...
            'TooltipString', 'If on, sound will match penalty duration above');
        ToggleParam(obj, 'error_sound_match_timeout', 1, x, y, 'position', [x+200 y 100 20],...
            'OffString', 'Sound != Tout', 'OnString', 'Sound == Tout', ...
            'TooltipString', 'If on, sound will match penalty duration above');
        ToggleParam(obj, 'fixation_led', 0, x, y, 'position', [x+300 y 100 20], ...
            'OffString', 'NIC LED OFF', 'OnString',  'NIC LED ON', ...
            'TooltipString', sprintf(['\nIf on, center port will light up in \ndifferent',...
                                      'color when animal has nose in center (NIC)']));
        next_row(y,1.1);
        
        %% Section 3, Row 1
        %%% Current penalty timeout duration & callback for fixation duration
        NumeditParam(obj, 'violation_dur',0.1, x, y,'labelfraction',0.6,...
            'TooltipString', 'Timeout duration',...
            'label', 'current', 'position', [x y 100 20]);
        NumeditParam(obj, 'temp_error_dur',0.1, x, y,'labelfraction',0.6,...
            'TooltipString', 'Timeout duration',...
            'label', 'current', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'error_dur',0.1, x, y,'labelfraction',0.6,...
            'TooltipString', 'Timeout duration',...
            'label', 'current','position', [x+200 y 100 20]);
        DispParam(obj, 'fixation_dur', 0.1, x, y, 'labelfraction',0.6,... 
            'label', 'fix dur', 'position', [x+300 y 100 20],...
            'TooltipString', 'callback of viol_off_dur to display fix req.');
        next_row(y,1.2);
        
        %% Section 3, Headers
        SubheaderParam(obj,'lab1', 'violation',x,y,'position', [x y 65 20]);
        ToggleParam(obj, 'violation_penalty', 0, x,y, 'position', [x+65 y 25 20],...
            'OnString', 'ON', 'OffString', 'OFF',...
            'TooltipString', sprintf(['If an early poke or break in fixation \n(if req)',...
                                      'during viol_offate leads to a penalty']));
            % ? this may no longer be a thing with decoupling? 
        SubheaderParam(obj,'lab2', 'temp error',x+100,y,'position', [x+100 y 65 20]);
        ToggleParam(obj, 'temp_error_penalty', 0, x,y, 'position', [x+165 y 25 20],...
        'OnString', 'ON', 'OffString', 'OFF',...
        'TooltipString', sprintf(['TempError allows animal to retry \nsingle',...
                                      ' or multiple times after an incorrect \nanswer',...
                                      ' penalty can be sound + timeout before \nretry',...
                                      ' and/or delayed reward delivery upon second hit']));
        set_callback(temp_error_penalty, {mfilename, 'temp_error_penalty_callback'});
        set_callback(temp_error_penalty, {mfilename, 'error_penalty_callback'});
    
        SubheaderParam(obj,'lab3', 'error',x+200,y,'position', [x+200 y 90 20]);
        SubheaderParam(obj,'lab4', 'fixation',x+300,y,'position', [x+300 y 65 20]);
        ToggleParam(obj, 'fixation_required', 0, x,y, 'position', [x+365 y 25 20],...
        'OnString', 'ON', 'OffString', 'OFF',...
        'TooltipString', sprintf(['If animal is required to fixate during the \nviol_off',...
                                      ' time window, or not. This variable is a key \nlogic',...
                                      ' point in the structure of the SMA']));
        set_callback(fixation_required, {mfilename, 'calculate_fixation_dur'});
        next_row(y,1.5);
        %% Section 2
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%     SETUP REWARD & TIMING VARS      %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        
        %% Section 2, Row 5
        NumeditParam(obj, 'inter_trial_dur',3, x, y,'labelfraction',0.65,...
                'TooltipString', 'Duration of pause time between trials',...
                'label', 'itd dur', 'position', [x y 133 20]);
        MenuParam(obj, 'SMA_set', {'cpoke';'spoke';'habituation';},...
            1, x, y, 'label', 'SMA',...
            'TooltipString','Which SMA to use. Note Cpoke = SMA.m',...
            'labelfraction',0.45,'position', [x+133 y 133 20]);
        
        %%% --- SMA SUBWINDOW START --- %%%
        ToggleParam(obj, 'SMA_params', 0, x,y, 'position', [x+(2*133) y 133 20],...
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
        NumeditParam(obj, 'settling_in_dur',0.01, x, y,'labelfraction',0.65,...
            'TooltipString', 'duration of cpoke needed to trigger a trial',...
            'label', 'settling', 'position', [x y 150 20]);
        NumeditParam(obj, 'adjusted_pre_dur',0.09, x, y,'labelfraction',0.65,...
            'TooltipString', sprintf(['\ngiven settling in dur, this is \nthe',...
                ' actual pre dur sent to the SMA to \nuse',...
                ' for the sa_sound and other wave preambles']),...
            'label', 'adj pre', 'position', [x+150 y 150 20]);
        set_callback(settling_in_dur, {mfilename, 'calculate_pre_and_settling_durs'});
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
        next_row(y,1.2);
        %%% --- SMA PARAMS SUBWINDOW END --- %%%
        

        %% Section 2, Row 4
        NumeditParam(obj, 'go_dur',0.2, x, y,'labelfraction',0.65,...
            'TooltipString', sprintf(['\nduration of go cue if go type is set',...
                    '\nnote this also sets the GoSound Dur in SoundUI during PNT']),...
            'label', 'go dur', 'position', [x y 133 20]);
        MenuParam(obj, 'go_type', {'none';'sound'; 'sound_localized';'LED_persist';'LED_flash'},...
            1, x, y, 'label', 'go type',...
            'TooltipString', 'type of go cue used (if any)',...
            'labelfraction',0.45,'position', [x+133 y 133 20]); 
        set_callback(go_type, {mfilename, 'ensure_correct_go_type'});
        
        %%% --- REPLAY PARAMS SUBWINDOW START --- %%%
        ToggleParam(obj, 'replay_params', 0, x,y, 'position', [x+(133*2) y 100 20],...
            'OnString', 'Replay Showing',...
            'OffString', 'Replay Hidden', 'TooltipString', 'Show/hide replay params window');
        set_callback(replay_params, {mfilename, 'show_hide_replay_params_window'});
        oldx=x; oldy=y; parentfig=double(gcf);
        
        SoloParamHandle(obj, 'replay_params_window', 'value', ...
            figure('Position', [100 100 410 250],...
                'MenuBar', 'none',...
                'Name', 'Additional replay parameters',...
                'NumberTitle', 'off',...
                'CloseRequestFcn', [mfilename '(' class(obj) ', ''hide_replay_params_window'');']));
        set(gcf, 'Visible', 'off');
        x=5;y=5;

        [x, y] = SoundInterface(obj, 'add', 'SaReplaySound', x, y); 
        [x, y] = SoundInterface(obj, 'add', 'SbReplaySound', x+200, y-140);
        SoundInterface(obj, 'set', 'SaReplaySound',...
                            'Style', 'Tone',...
                            'Vol', 0.001,...
                            'Dur1', 0.1);
        SoundInterface(obj, 'set', 'SbReplaySound',...
                            'Style', 'Tone',...
                            'Vol', 0.001,...
                            'Dur1', 0.1);
        next_row(y, 0.5); x = x-200;

        MenuParam(obj, 'replay_n_loops', {'-1','1','2','3','4','5','6','7'},...
            3, x, y, 'position', [x y 200 20], 'label', 'n loops','labelfraction',0.60,...
            'TooltipString', sprintf(['\nnumber of types the replay sound wave will loop after',...
                               '\nbeing triggered in drink state. -1 means infinite loop',...
                               '\n user should use this instead of SoundUI loops!!']));
        next_row(y,1.1);

        DispParam(obj, 'replay_single_loop_dur',0.6, x, y,'labelfraction',0.6,...
                'TooltipString', 'duration of time for a single replay in seconds',...
                'label', '1 loop [s]', 'position', [x y 100 20]);
        DispParam(obj, 'replay_dur',1.8, x, y,'labelfraction',0.6,...
                'TooltipString', 'duration of full replay sequence in seconds',...
                'label', 'all loop [s]', 'position', [x+100 y 100 20]);
        DispParam(obj, 'replay_loop_ratio',0.9, x, y,'labelfraction',0.6,...
                'TooltipString', sprintf(['\nif less than 1, replay will finish,'... 
                               '\nif more than 1, replay will get cut off by state switch']),...
                'label', 'ratio', 'position', [x+(100*2) y 100 20]);
        NumeditParam(obj, 'drinking_dur',2, x, y,'labelfraction',0.6,...
            'TooltipString', sprintf(['duration of drink state in SMA before Tup',...
                            'into final_state. Also the maximum duration of a replay wave']),...
            'label', 'drinking dur', 'position', [x+(100*3) y 100 20]); 
        next_row(y,1.1);

        NumeditParam(obj, 'replay_sa_dur',0.1, x, y,'labelfraction',0.60,...
            'TooltipString', 'sets soundUI in PNT- duration of sb in replay',...
            'label', 'r sa dur', 'position', [x y 100 20]);
        NumeditParam(obj, 'replay_delay_dur',0.15, x, y,'labelfraction',0.60,...
            'TooltipString', 'time between sa and sb',...
            'label', 'r delay dur', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'replay_sb_dur',0.1, x, y,'labelfraction',0.60,...
            'TooltipString', 'sets soundUI in PNT- duration of sb in replay',...
            'label', 'r sb dur', 'position', [x+(100*2) y 100 20]);
        NumeditParam(obj, 'replay_post_dur',0.25, x, y,'labelfraction',0.60,...
            'TooltipString', 'time between sb and sa of next loop (if looping)',...
            'label', 'r post dur', 'position', [x+(100*3) y 100 20]);   
        next_row(y,1.1);

        set_callback({replay_sa_dur; replay_delay_dur; replay_sb_dur;...
                      replay_post_dur; replay_n_loops; drinking_dur},...
            {mfilename, 'calculate_replay_params'});
                
        % subheader
        SubheaderParam(obj,'lab1', 'Replay Params',x,y,'position', [x y 400 20]);
        
        % back to main window
        x=oldx; y=oldy;figure(parentfig);

%         next_row(y,1.1);
        %%% --- REPLAY PARAMS SUBWINDOW END ---%%%
        ToggleParam(obj, 'replay_on', 0, x,y, 'position', [x+((2*133)+100) y 33 20],...
            'OnString', 'ON', 'OffString', 'OFF',...
            'TooltipString', sprintf(['If sa/sb should be played during the \ndrink state',...
                                          ' for an animal. See replay params for more info']));
        next_row(y,1.1);

        %% Section 2, Row 3
        NumeditParam(obj, 'give_del_dur',0.001, x, y,'labelfraction',0.65,...
            'TooltipString', 'duration of delay before the post-go-give comes (if on)',...
            'label', 'give del [s]', 'position', [x y 133 20]);
        MenuParam(obj, 'give_del_growth', {'none';'fixed';'adaptive';},...
            1, x, y, 'label', 'give del grow',...
            'TooltipString', 'if post-go give delay period should grow, and if so what kind',...
            'labelfraction',0.6,'position', [x+133 y 133 20]);
        %%
        %%% --- GIVE PARAMS SUBWINDOW START --- %%%
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
        MenuParam(obj, 'give_del_growth_trial_subset', {'anti';'pro';'all';},...
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

        %% Section 2, Row 2
        DispParam(obj, 'pre_go_dur',0.1, x, y,'labelfraction',0.65,...
                'TooltipString', sprintf(['\n duration of pre_go_wave that \nis',...
                                   ' set via callback adding up the timing \nvars:',...
                                   ' pre + 2(stim) + delay + post, \nand ',...
                                   ' when pre_go_wave goes hi, SMA moves into go_state']),...
                'label', 'pre go [s]', 'position', [x y 133 20]);
        MenuParam(obj, 'give_type_set', {'none';'water';'light';'water_and_light'},...
            1, x, y, 'label', 'give type set',...
            'TooltipString', sprintf(['\nwhat type of post-go reward guide give to use (if any)',...
                                      '\nnote this does NOT take into account a localized go cue!']),...
            'labelfraction',0.6,'position', [x+133 y 133 20]);
        set_callback(give_type_set, {mfilename, 'ensure_correct_go_type'});
        set_callback(give_type_set, {mfilename, 'give_type_callback'});
        %%% --- EXP DELAY PARAMS SUBWINDOW START --- %%%
        ToggleParam(obj, 'exp_delay_params', 0, x,y, 'position', [x+(2*133) y 133 20],...
            'OnString', 'Exp delay params Showing',...
            'OffString', 'Exp delay params Hidden', 'TooltipString', 'Show/hide exp delay params window');
        set_callback(exp_delay_params, {mfilename, 'show_hide_exp_delay_params_window'});
        oldx=x; oldy=y; parentfig=double(gcf);
        
        SoloParamHandle(obj, 'exp_delay_params_window', 'value', ...
            figure('Position', [200 300 475 120],...
                   'MenuBar', 'none',...
                   'Name', 'Parameters for Exp Delay Sampling',...
                   'NumberTitle', 'off',...
                   'CloseRequestFcn', [mfilename '(' class(obj) ', ''hide_exp_delay_params_window'');']));
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
        DistribInterface(obj, 'add', 'exp_delay', x+(105*3), y, 'Style', ...
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
        %%% --- EXP DELAY PARAMS SUBWINDOW END ---%%%
       
        %% Section 2, Row 1
        NumeditParam(obj, 'viol_off_dur',0.1, x, y,'labelfraction',0.65,...
            'label', 'viol off [s]', 'position', [x y 133 20],...
            'TooltipString', sprintf(['\nduration of time in trial where an early poke \nor',...
                                      ' leaving the center port (if fix req) will send you \nto',...
                                      ' a violation penalty. Decouples trial timing (pre_go) \nfrom',...
                                      ' motor requirements']));
        set_callback(viol_off_dur, {mfilename, 'set_viol_off_durs'});
        
        MenuParam(obj, 'viol_off_growth', {'none';'fixed';'match_pre_go'},...
                1, x, y, 'label', 'viol off grow',...
                'TooltipString', 'if viol_off duration should grow, and if so what kind',...
                'labelfraction',0.6,'position', [x+133 y 133 20]);              
        %%% --- TASK GROWTH PARAMETERS SUBWINDOW START ---
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
        NumeditParam(obj, 'n_warm_up_trials',20, x, y,'labelfraction',0.6,...
            'label', 'warm up trials', 'position', [x y 150 20]);
        NumeditParam(obj, 'delay_discrete_values',[1.35, 2.0, 2.4], x, y,'labelfraction',0.3,...
            'TooltipString', 'values used for discrete delays',...
            'label', 'discrete', 'position', [x+200 y 150 20]);next_row(y,1.1);
    
        % Growth subwindow, Row 6
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
            'labelfraction',0.4,'position', [x+300 y 100 20]);
        MenuParam(obj, 'viol_off_fixed_growth_unit', {'s';'%'},...
            1, x, y, 'label', 'unit',...
            'labelfraction',0.4,'position', [x+400 y 100 20]);
        MenuParam(obj, 'give_del_fixed_growth_unit', {'s';'%'},...
            1, x, y, 'label', 'unit',...
            'labelfraction',0.4,'position', [x+500 y 100 20]);
        next_row(y,1.1);
        
        % Growth subwindow, Row 5
        NumeditParam(obj, 'pre_fixed_growth_rate',0.002, x, y,'labelfraction',0.6,...
            'TooltipString', 'Rate at which fixed growth is occuring',...
            'label', 'rate', 'position', [x y 100 20]);
        NumeditParam(obj, 'stimulus_fixed_growth_rate',0.001, x, y,'labelfraction',0.6,...
            'label', 'rate', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'delay_fixed_growth_rate',0.002, x, y,'labelfraction',0.6,...
            'label', 'rate','position', [x+200 y 100 20]);
        NumeditParam(obj, 'post_fixed_growth_rate',0.002, x, y,'labelfraction',0.6,...
            'label', 'rate', 'position', [x+300 y 100 20]);
        NumeditParam(obj, 'viol_off_fixed_growth_rate',0.001, x, y,'labelfraction',0.6,...
            'label', 'rate', 'position', [x+400 y 100 20]);
        NumeditParam(obj, 'give_del_fixed_growth_rate',0.001, x, y,'labelfraction',0.6,...
            'label', 'rate', 'position', [x+500 y 100 20]);
        next_row(y,1.1);
        
        % Growth subwindow, Row 4
        NumeditParam(obj, 'pre_max',0.25, x, y,'labelfraction',0.6,...
            'TooltipString', 'Maximum duration to grow to',...
            'label', 'max', 'position', [x y 100 20]);
        NumeditParam(obj, 'stimulus_max',0.4, x, y,'labelfraction',0.6,...
            'label', 'max', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'delay_max',6, x, y,'labelfraction',0.6,...
            'label', 'max','position', [x+200 y 100 20]);
        NumeditParam(obj, 'post_max',0.5, x, y,'labelfraction',0.6,...
            'label', 'max', 'position', [x+300 y 100 20]);
        DispParam(obj, 'viol_off_max',0.45, x, y,'labelfraction',0.6,...
            'label', 'max', 'position', [x+400 y 100 20],...
            'TooltipString', 'NOTE: callback to pre_go_dur sets the viol max');
        set_callback(viol_off_max, {mfilename, 'set_viol_off_durs'});
        NumeditParam(obj, 'give_del_max',3, x, y,'labelfraction',0.6,...
            'label', 'max', 'position', [x+500 y 100 20]);
        next_row(y,1.1);
        
        % Growth subwindow, Row 3
        NumeditParam(obj, 'pre_prev_session',0.1, x, y,'labelfraction',0.6,...
            'TooltipString', 'Value of duration in last session',...
            'label', 'prev sess', 'position', [x y 100 20]);
        NumeditParam(obj, 'stimulus_prev_session',0.1, x, y,'labelfraction',0.6,...
            'label', 'prev sess', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'delay_prev_session',0.1, x, y,'labelfraction',0.6,...
            'label', 'prev sess','position', [x+200 y 100 20]);
        NumeditParam(obj, 'post_prev_session',0.1, x, y,'labelfraction',0.6,...
            'label', 'prev sess', 'position', [x+300 y 100 20]);
        NumeditParam(obj, 'viol_off_prev_session',0.1, x, y,'labelfraction',0.6,...
            'label', 'prev sess', 'position', [x+400 y 100 20]);
        NumeditParam(obj, 'give_del_prev_session',0.1, x, y,'labelfraction',0.6,...
            'label', 'prev sess', 'position', [x+500 y 100 20]);        
        next_row(y,1.1);
        
        % Growth subwindow, Row 2
        NumeditParam(obj, 'pre_min',0.001, x, y,'labelfraction',0.6,...
            'TooltipString', 'Minimum duration used at start of warm up',...
            'label', 'min', 'position', [x y 100 20]);
        NumeditParam(obj, 'stimulus_min',0.001, x, y,'labelfraction',0.6,...
            'label', 'min', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'delay_min',0.001, x, y,'labelfraction',0.6,...
            'label', 'min','position', [x+200 y 100 20]);
        NumeditParam(obj, 'post_min',0.001, x, y,'labelfraction',0.6,...
            'label', 'min', 'position', [x+300 y 100 20]);
        NumeditParam(obj, 'viol_off_min',0.001, x, y,'labelfraction',0.6,...
            'label', 'min', 'position', [x+400 y 100 20]);
        NumeditParam(obj, 'give_del_min',0.001, x, y,'labelfraction',0.6,...
            'label', 'min', 'position', [x+500 y 100 20]);
        next_row(y,1.1);
        
        % Growth subwindow, Row 1
        ToggleParam(obj, 'pre_warm_up', 0, x, y, 'position', [x y 100 20], ...
            'OffString', 'Warm Up OFF', 'OnString',  'Warm Up ON', ...
            'TooltipString', sprintf(['\nIf on & var is growing, will start at min and \ngrow',...
                             'from min to previous dat duration in n_warm_up_trials']));
        ToggleParam(obj, 'stimulus_warm_up', 0, x, y, 'position', [x+100 y 100 20], ...
            'OffString', 'Warm Up OFF', 'OnString',  'Warm Up ON');
        ToggleParam(obj, 'delay_warm_up', 0, x, y, 'position', [x+200 y 100 20], ...
            'OffString', 'Warm Up OFF', 'OnString',  'Warm Up ON');
        ToggleParam(obj, 'post_warm_up', 0, x, y, 'position', [x+300 y 100 20], ...
            'OffString', 'Warm Up OFF', 'OnString',  'Warm Up ON');
        ToggleParam(obj, 'viol_off_warm_up', 0, x, y, 'position', [x+400 y 100 20], ...
            'OffString', 'Warm Up OFF', 'OnString',  'Warm Up ON');
        ToggleParam(obj, 'give_del_warm_up', 0, x, y, 'position', [x+500 y 100 20], ...
            'OffString', 'Warm Up OFF', 'OnString',  'Warm Up ON');
        next_row(y,1.1);

        
        % Growth subwindow, headers
        SubheaderParam(obj,'lab1', 'pre',x,y,'position', [x y 90 20]);
        SubheaderParam(obj,'lab2', 'stim',x+100,y,'position', [x+100 y 90 20]);
        SubheaderParam(obj,'lab3', 'delay',x+200,y,'position', [x+200 y 90 20]);
        SubheaderParam(obj,'lab4', 'post',x+300,y,'position', [x+300 y 90 20]);
        SubheaderParam(obj,'lab4', 'viol off',x+400,y,'position', [x+400 y 90 20]);
        SubheaderParam(obj,'lab4', 'give del',x+500,y,'position', [x+500 y 90 20]);
        
        % back to main window
        x=oldx; y=oldy; figure(parentfig);
        next_row(y,1.2);
        %%% --- TASK GROWTH PARAMETERS SUBWINDOW END ---
        
        %% Section 2, Header
        SubheaderParam(obj,'lab1', 'Timing & Reward',x,y,'position', [x+50 y 300 20]);
        next_row(y,1.3);
        
        %% Section 1
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%   SETUP TASK VARS   %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Section 1, Row 2     
        %TODO switch this param name to pre_type with {'stable'; 'fixed
        %growth' etc. Need to change below code for this
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
  
        %% Section 1, Row 1
        NumeditParam(obj, 'pre_dur',0.1, x, y,'labelfraction',0.6,...
            'TooltipString', 'Duration on current trial',...
            'label', 'dur', 'position', [x y 100 20]);
        set_callback(pre_dur, {mfilename, 'calculate_pre_and_settling_durs'});
        set_callback(pre_dur, {mfilename, 'calculate_pre_go_dur'});
        NumeditParam(obj, 'stimulus_dur',0.1, x, y,'labelfraction',0.6,...
            'label', 'dur', 'position', [x+100 y 100 20]);
        set_callback(stimulus_dur, {mfilename, 'calculate_pre_go_dur'});
        NumeditParam(obj, 'delay_dur',0.1, x, y,'labelfraction',0.6,...
            'label', 'dur','position', [x+200 y 100 20]);
        set_callback(delay_dur, {mfilename, 'calculate_pre_go_dur'});
        NumeditParam(obj, 'post_dur',0.05, x, y,'labelfraction',0.6,...
            'label', 'dur', 'position', [x+300 y 100 20]);
        set_callback(post_dur, {mfilename, 'calculate_pre_go_dur'});
        next_row(y,1.1);
        
        %% Section 1, Headers
        SubheaderParam(obj,'lab1', 'pre',x,y,'position', [x y 90 20]);
        SubheaderParam(obj,'lab2', 'stimulus',x+100,y,'position', [x+100 y 90 20]);
        SubheaderParam(obj,'lab3', 'delay',x+200,y,'position', [x+200 y 90 20]);
        SubheaderParam(obj,'lab4', 'post',x+300,y,'position', [x+300 y 90 20]);next_row(y);

        SubheaderParam(obj, 'lab0', 'Shaping Section',x+200,y, 'position', [x y 400 20]); next_row(y);

        %% Callbacks to ensure correct settings of GUI params/format
        ShapingSection(obj, 'calculate_pre_go_dur');
        ShapingSection(obj, 'set_viol_off_durs');
        ShapingSection(obj, 'calculate_replay_params');
        ShapingSection(obj, 'calculate_fixation_dur');
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
    
        SoloParamHandle(obj, 'task_prefixes', 'value', {'pre', 'stimulus', 'delay', 'post', 'viol_off', 'give_del'});
        SoloParamHandle(obj, 'penalty_prefixes', 'value', {'violation', 'temp_error', 'error', 'inter_trial'});
        
        SoloParamHandle(obj, 'violation_prev_sound_dur', 'value', 0);
        SoloParamHandle(obj, 'temp_error_prev_sound_dur', 'value', 0);
        SoloParamHandle(obj, 'error_prev_sound_dur', 'value', 0);

        SoloParamHandle(obj, 'pre_warm_up_step_size', 'value', 0);
        SoloParamHandle(obj, 'stimulus_warm_up_step_size', 'value', 0);
        SoloParamHandle(obj, 'delay_warm_up_step_size', 'value', 0);
        SoloParamHandle(obj, 'post_warm_up_step_size', 'value', 0);
        SoloParamHandle(obj, 'viol_off_warm_up_step_size', 'value', 0);
        SoloParamHandle(obj, 'give_del_warm_up_step_size', 'value', 0);
        SoloParamHandle(obj, 'give_del_in_adaptive_warm_up', 'value', 0);
        
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
            ShapingSection(obj, 'set_warm_up_step_sizes');
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

                % implement warm up- give del has a special case where it
                % only warms up on anti trials
                if (warm_up && (n_trials_stage < n_warm_up_trials)) || ...
                        (warm_up && (n_anti < n_warm_up_trials))
                    if strcmp(period, 'give_del')
                        if value(pro_anti_on) &&...
                            strcmp(value(pro_anti_block_type), 'anti') &&...
                            (value(n_anti) < n_warm_up_trials)

                            ShapingSection(obj, 'update_fixed', period, warm_up_step_size, 's');
                        end
                        
                    else
                        if (n_trials_stage < n_warm_up_trials)
                            ShapingSection(obj, 'update_fixed', period, warm_up_step_size, 's');
                        end
                    end
         
                else
                    ShapingSection(obj, 'update_fixed', period);
                end

            case 'discrete'
                % only possible for delay_dur, select at random and assign
                random_idx = randi(length(delay_discrete_values), 1);
                delay_dur.value = value(delay_discrete_values(random_idx));
            
            case 'adaptive' 
                %% note the cases for this function are more modern and take
                % care of dealing with warm up and trial types internally
                
                % no adaptive growth if it's set to anti and we're in pro
                % block or vice verse
                trial_subset = value(eval([period '_growth_trial_subset']));
                if strcmp(trial_subset, 'all') || ...
                        strcmp(trial_subset, value(pro_anti_block_type))
                    ShapingSection(obj, 'update_adaptive', period);
                end
            end
        end

        % Growth types that are not dependent on if previous trial was a
        % violation
        if strcmp(delay_growth, 'exp')
            randvalue = DistribInterface(obj, 'get_new_sample', 'exp_delay');
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

        % calculate pre_go dur which times the trial, 
        ShapingSection(obj, 'calculate_pre_go_dur');

        % make sure viol_off_max is not greater the pre_go and make them
        % equal if they should be matched
        ShapingSection(obj, 'set_viol_off_durs');
        
        % calculate time before sound a for SMA
        ShapingSection(obj, 'calculate_pre_and_settling_durs');
       
        % make sure durations are not out of min/max windows
        ShapingSection(obj, 'check_duration_boundaries');
        
        % given viol_off dur, set fixation_dur
        ShapingSection(obj, 'calculate_fixation_dur');
        
        % make sure go and give do not interfear with eachother if on
        ShapingSection(obj, 'ensure_correct_go_type');

        % if give_type_set is not none, check what frac of give trials is 
        % and implment, also check water isn't piling up at the port.
        ShapingSection(obj, 'set_give_based_on_frac_and_hist');

        % calculate duration of replay variables for ease of use
        ShapingSection(obj, 'calculate_replay_params');
        
        % make GUI cleaner 
        ShapingSection(obj, 'temp_error_penalty_callback');
        ShapingSection(obj, 'error_penalty_callback');
        ShapingSection(obj, 'exponential_growth_callback');
        ShapingSection(obj, 'give_type_callback');
        ShapingSection(obj, 'compute_alpha_plus_callback');
       
 
    %---------------------------------------------------------------%
    %          GUI param callbacks                                  %
    %---------------------------------------------------------------%
    case 'calculate_pre_go_dur' 
        pre_go_dur.value = value(pre_dur) + (2 * value(stimulus_dur)) + value(delay_dur) + value(post_dur);
        
    case 'calculate_fixation_dur' 
       fixation_dur.value = value(viol_off_dur);
        
       if value(fixation_required)
           enable(fixation_dur);
       else
           disable(fixation_dur);
       end
   
    case 'set_viol_off_durs'
        if value(viol_off_max) ~= value(pre_go_dur)
            viol_off_max.value = value(pre_go_dur);
        end

        if strcmp(value(viol_off_growth), 'match_pre_go')
            viol_off_dur.value = value(pre_go_dur) - 0.002;
        end
    
    case 'ensure_correct_go_type'
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

    case 'calculate_replay_params'
        replay_single_loop_dur.value = value(replay_sa_dur) + value(replay_delay_dur) +...
                                       value(replay_sb_dur) + value(replay_post_dur);

        if value(replay_n_loops) == -1 % infinte loop for as long as drink state
            n_loops = ceil(value(drinking_dur) / value(replay_single_loop_dur));
        else
            n_loops = value(replay_n_loops);
        end
        replay_dur.value = value(replay_single_loop_dur) * n_loops;

        replay_loop_ratio.value = value(replay_dur) / value(drinking_dur);

    case 'temp_error_penalty_callback'
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
        if strcmp(value(give_type_set),'none')
            disable(give_del_dur);
            disable(give_del_growth);
        else
            enable(give_del_dur);
            enable(give_del_growth);
        end
    
    case 'compute_alpha_plus_callback'
        
        give_del_adaptive_alpha_plus.value = 1 - value(give_del_adaptive_alpha_minus);

           
    case 'growth_type_callback'
%         TODO not functional yet
%         for iperiod = 1 : length(task_prefixes)
% 
%             get variables for the prefix in the loop (e.g. pre_)
%             period = task_prefixes{iperiod};
%             growth = value(eval([period '_growth']));
%                   
%             if strcmp(growth, 'none')
%                 don't think this will actually work :/
%                 eval([disable(period '_warm_up')]);
%             end        
%         end
    case 'exponential_growth_callback'
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
    %          set_warmup_stepsizes                                 %
    %---------------------------------------------------------------%
    case 'set_warm_up_step_sizes'
        % case to calculate the appropriate warm up step size to use
        % during n_warm_up_trials for a specified variable
        % only implmented if smaller than the prespecified growth rate
        disp('********************** set_warm up step sizes');
        for iperiod = 1 : length(task_prefixes)
    
            period = task_prefixes{iperiod};
            cur_dur = value(eval([period '_dur']));
            prev_dur = value(eval([period '_prev_session']));
            fixed_growth_rate = value(eval([period '_fixed_growth_rate']));
            fixed_growth_unit = value(eval([period '_fixed_growth_unit']));
            
            step_size = (prev_dur - cur_dur)/n_warm_up_trials;
            
            if (step_size < fixed_growth_rate) && (strcmp (fixed_growth_unit, 's'))
                step_size = fixed_growth_rate;
            end

            eval([period '_warm_up_step_size.value = step_size;']);
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
            if value(pro_anti_on)
                % TODO: consider making a variable named pro_anti_give_on
                % that can be either 'pro' 'anti' or 'pro-anti' and if the
                % block type contains the give_on then this statement
                % passes. right now, it's hard coded for anti only
                if was_hit && strcmp(value(pro_anti_block_type), 'anti')
                    grow_var = true;
                end
            else
                if was_hit
                    grow_var = true;
                end
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
                eval([task_var '_dur.value = cur_dur * growth_rate;']);
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
        
        % OPTIONAL EXTENSION: if you want to have a different alpha+ based
        % on performance, you can use the 'compute_prev_perf_for_adaptive'
        % case to get the past performance for a subset of trials (e.g.
        % anti) over a given window size. This is not currently in use.
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
        
    case 'compute_prev_perf_for_adaptive'
        %% compute performance history to determine adaptive growth 
        % this function looks at a given subset of trials (pro, anti or
        % all) and determined the preformance over a given window. It does
        % not take into account violation trials.
        
        %% set up vars
        task_var = varargin{1};  
        trial_subset = value(eval([task_var '_growth_trial_subset']));
        trial_window_size = value(eval([task_var '_perf_trial_window']));
    
        %% Determine the valid hit history
        if strcmp(value(give_del_growth_trial_subset), 'all')
            valid_hit_history = value(hit_history);
        else
            % either pro or anti- making an assumtion we are in a block
            % here, lets find all the trials of subset in current block
            
            if strcmp(value(block_switch_type), 'none') % TODO switch 
                warning(['!!!adaptive performance being calculated with,'...
                    'block assumptions, but blocks are off!!!']);
            end
      
            % determine block boundaries
            block_switch_idxs = find(get_history('was_block_switch').');
            if length(block_switch_idxs) == 1
                block_start = block_switch_idxs;
            elseif isempty(block_switch_idxs)
                block_start = 1;
            else
                block_start = block_switch_idxs(end); 
            end
            
            % filter hit history based off of block boundaries and subset
            % type
            if strcmp(trial_subset, 'anti') && ...
                strcmp(value(pro_anti_block_type), 'anti')
            
                anti_indices = find(strcmp(value(pro_anti_block_type_history), 'anti'));
                valid_anti_indices = anti_indices(anti_indices >= block_start);
                valid_hit_history = value(hit_history(valid_anti_indices));
           
            
            elseif strcmp(trial_subset, 'pro') && ...
                strcmp(value(pro_anti_block_type), 'pro')
           
                pro_indices = find(strcmp(value(pro_anti_block_type_history), 'pro'));
                valid_pro_indices = pro_indices(pro_indices >= block_start);
                valid_hit_history = value(hit_history(valid_pro_indices));
            end  
        end
        
        %% Compute performance over window
        
        if exist('valid_hit_history', 'var') 
            window_size = min(length(valid_hit_history), trial_window_size);

            hit_window = valid_hit_history(end-(window_size-1):end);

            perf = round(mean(hit_window, 'omitnan'), 2);

            eval([task_var '_perf_trial_subset.value = perf;']);
        end

        
        
    case 'determine_if_in_warm_up_for_adaptive'
        %% determine if the variable is in a warm-up phase or not. 
        % this involved checking if how many trials of the specified subset
        % where adaptive growth is happening have elapsed. E.g. for anti
        % adaptive growth, we only want to count anti trials
        
        
        task_var = varargin{1};
        warm_up_on = value(eval([task_var '_warm_up']));
        
        % check if warm up on!!!
        trial_subset = value(eval([task_var '_growth_trial_subset']));
        
        if strcmp(trial_subset, 'all')
            n_trials = value(n_trials_stage);
        elseif strcmp(trial_subset, 'pro')
            n_trials = value(n_pro);
        elseif strcmp(trial_subset, 'anti')
            n_trials = value(n_anti);
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

        % For replay, check to make sure the sound duraton matches what is
        % listed in the GUI params

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

        % replay - only duration is set here, the frequncies are
        % set in StimulusSection
        SoundInterface(obj, 'set', 'SaReplaySound', 'Dur1', value(replay_sa_dur));
        SoundInterface(obj, 'set', 'SbReplaySound', 'Dur1', value(replay_sb_dur));
        
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
        end
    
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

    case 'show_hide_replay_params_window'
        if replay_params == 0, set(value(replay_params_window), 'Visible', 'off');
        else                   set(value(replay_params_window), 'Visible', 'on');
        end
    case 'hide_replay_params_window'
        set(value(replay_params_window), 'Visible', 'off'); replay_params.value = 0;

    case 'show_hide_exp_delay_params_window'
        if exp_delay_params == 0, set(value(exp_delay_params_window), 'Visible', 'off');
        else                   set(value(exp_delay_params_window), 'Visible', 'on');
        end
    case 'hide_exp_delay_params_window'
        set(value(exp_delay_params_window), 'Visible', 'off'); exp_delay_params.value = 0;

    case 'close'
        delete(value(penalty_params_window));
        delete(value(soundui_window));
        delete(value(SMA_params_window));
        delete(value(give_params_window));
        delete(value(growth_params_window));

end

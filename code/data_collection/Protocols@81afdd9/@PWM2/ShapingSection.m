%% ShapingSection Notes
% Initial draft by JRB 2022-04

% Goal: this section contains and manages information on growth (adaptive, non-adaptive),
% penalties, reward type (temp-error or not), temp-error delay, adaptive growth of violation/error
% ITI, etc.

% To consider:having a small section within ShapingSection to deal with delay
% between sounds, etc, or a different section? e.g. DurationSection
% [x, y] = ShapingSection(obj, 'init', x, y);

% Inspiration: Using the SMA written for PWM2, SideSection from PWM


% Case Info:
%     init case: this is where all the gui information is initated
%     prepare_next_trial: where infomration is prepared for the next trial
%     based on what happened on the previou trial
%     grow_duration: given a variable to grow, will apply adaptive or fixed
%     growth adjustment to the variable based on specified rate
%
% TODO Implement get function to grab values, instead of doing evals
% TODO add dispparams to show warm up step sizes

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

        % TODO: update water multiplier params box

        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% SETUP INTERNAL VARS %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%

        SoloParamHandle(obj, 'task_prefixes', 'value', {'pre', 'stimulus', 'delay', 'post'});
        SoloParamHandle(obj, 'penalty_prefixes', 'value', {'violation', 'temp_error', 'error', 'inter_trial'});

        SoloParamHandle(obj, 'violation_prev_sound_dur', 'value', 0);
        SoloParamHandle(obj, 'temp_error_prev_sound_dur', 'value', 0);
        SoloParamHandle(obj, 'error_prev_sound_dur', 'value', 0);

        SoloParamHandle(obj, 'pre_warmup_stepsize', 'value', 0);
        SoloParamHandle(obj, 'stimulus_warmup_stepsize', 'value', 0);
        SoloParamHandle(obj, 'delay_warmup_stepsize', 'value', 0);
        SoloParamHandle(obj, 'post_warmup_stepsize', 'value', 0);
        SoloParamHandle(obj, 'cp_fixation_warmup_stepsize', 'value', 0);


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

        SoloParamHandle(obj, 'penalty_params_window', 'saveable', 0, 'value',...
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

        SoloParamHandle(obj, 'soundui_window', 'saveable', 0, 'value', ...
            figure('Position', [950 100 615 300],...
                   'MenuBar', 'none',...
                   'Name', 'SoundUI: Penalties & Go',...
                   'NumberTitle', 'off',...
                   'CloseRequestFcn', [mfilename '(' class(obj) ', ''hide_soundui_window'');']));
        set(gcf, 'Visible', 'off');
        x=5;y=5;

        % create penalty sound UI
        [x, y] = SoundInterface(obj, 'add', 'ViolationSound', x, y);
        [x, y] = SoundInterface(obj, 'add', 'GoSound', x, y);
        next_column(x, 1); y = 5;
        [x, y] = SoundInterface(obj, 'add', 'TempErrorSound', x, y);
        [x, y] = SoundInterface(obj, 'add', 'ErrorSound', x, y);
        next_column(x, 1); y = 5;
        [x, y] = SoundInterface(obj, 'add', 'RewardSound', x, y,...
            'Style','Bups','Volume',0.01,'Freq',5,'Duration',1.5);
        [x, y] = SoundInterface(obj, 'add', 'ExtraFixSound', x, y,...
            'Style', 'Bups', 'Volume', 0.005, 'Freq', 5, 'Duration', 1.5);

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
        set_callback(violation_sound_match_timeout, {mfilename, 'set_soundui_properties'});
        set_callback(temp_error_sound_match_timeout, {mfilename, 'set_soundui_properties'});
        set_callback(error_sound_match_timeout, {mfilename, 'set_soundui_properties'});
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
        ToggleParam(obj, 'violation_penalty', 0, x, y, 'position', [x+65 y 25 20],...
            'OnString', 'ON',...
            'OffString', 'OFF', 'TooltipString', 'If violation state is being used');
        SubheaderParam(obj,'lab2', 'temp error',x+100,y,'position', [x+100 y 90 20]);
        SubheaderParam(obj,'lab3', 'error',x+200,y,'position', [x+200 y 90 20]);
        SubheaderParam(obj,'lab4', 'inter trial',x+300,y,'position', [x+300 y 90 20]);
        next_row(y,1.5);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% SETUP FIXATION, REWARD & WATER VARS %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % reward: scale proportional to time spent fixated
        ToggleParam(obj, 'extrafix_toggle', 0, x, y, 'position', [x y 130 20], ...
            'OffString', 'Reward Scaling OFF', 'OnString', 'Reward Scaling ON', ...
            'TooltipString', 'Whether to scale reward with time spent fixated');
        NumeditParam(obj, 'extrafix_length_multiplier', 1.3, x, y, 'labelfraction', 0.6, ...
            'label', 'fix. required', 'position', [x+135 y 130 20], 'TooltipString', ...
            'Fixation required (multiplier) to scale reward');
        NumeditParam(obj, 'extrafix_reward_multiplier', 2, x, y, 'labelfraction', 0.6, ...
            'label', 'rwd multiplier', 'position', [x+270 y 130 20], 'TooltipString', ...
            'Reward multiplier for trials where fixation exceeded extrafix_length_multiplier');

        next_row(y, 1.1);

        % fixation: total duration & LED
        NumeditParam(obj, 'cp_fixation_dur',0.05, x, y, 'labelfraction', 0.3,...
            'label', 'dur', 'position',[x y 75 20],...
            'TooltipString',  sprintf(['\nadding up the duration of the delays and sounds \nbefore',...
                             ' the go cue. Used to time fixation wave in the SMA. \nIn',...
                             ' early stages animal may not have to poke whole period']));
        ToggleParam(obj, 'fixation_led', 0, x, y, 'position', [x+75 y 75 20], ...
            'OffString', 'NIC LED OFF', 'OnString',  'NIC LED ON', ...
            'TooltipString', 'If on, center port will light up in different color when animal has nose in center (NIC)');
        % reward: retry type
        MenuParam(obj, 'retry_type', {'single';'multi';'N/A';},...
            1, x, y, 'label', 'retry type',...
            'TooltipString', 'If temperror, how many retries',...
            'labelfraction',0.45,'position', [x+150 y 125 20]);
        % reward: drinking duration
        NumeditParam(obj, 'drinking_dur',5, x, y,'labelfraction',0.65,...
            'TooltipString', 'duration of drink state in SMA before Tup --> final state',...
            'label', 'drink dur', 'position', [x+150+125 y 125 20]);

        next_row(y,1.1);

        % fixation: leagal cbreak duration
        SliderParam(obj,'legal_cbreak_dur',0.01,0.05,0.2,x, y,'label','cbreak', 'position', [x y 150 20],...
            'TooltipString', 'how long animal can break fixation within a trial');
        % reward: swtich to toggle temp error penalty
        ToggleParam(obj, 'temp_error_penalty', 0, x, y, 'position', [x+150 y 125 20], ...
            'OffString', 'Temp Error OFF', 'OnString',  'Temp Error ON',...
            'TooltipString', sprintf(['TempError allows animal to retry \nsingle',...
                                      ' or multiple times after an incorrect \nanswer',...
                                      ' penalty can be sound + timeout before \nretry',...
                                      ' and/or delayed reward delivery upon second hit']));
        % reward: temp error water delay
        NumeditParam(obj, 'temp_error_water_delay',0.5, x, y,'labelfraction',0.65,...
            'TooltipString', 'if terror --> hit, how long until water is delivered',...
            'label', 'water delay', 'position', [x+150+125 y 125 20]);

        next_row(y,1.1);

        % fixation: settling in duration
        SliderParam(obj,'settling_in_dur',0.05,0.05,0.2,x, y,'label','settling', 'position', [x y 150 20],...
            'TooltipString', 'how long animal needs to cpoke for to start trial');
        % probability of give reward on a trial, assuming reward_type = give
        NumeditParam(obj, 'give_prob', 0, x, y, 'position', [x+150, y 125 20], ...
            'labelfraction', 0.65, 'label', 'Give prob.', 'TooltipString', ...
            'Probability of water "give" being on/off on a given trial. Defaults to 0.')
        % reward: wait for spoke Tup forgiveness
        ToggleParam(obj, 'wait_for_spoke_Tup_forgiveness', 1, x, y, 'position', [x+150+125 y 125 20], ...
            'OffString', 'wfsTup forgive OFF', 'OnString',  'wfsTup forgive ON',...
            'TooltipString', sprintf(['if on sends \nSMA',...
                                      ' back to wait_for_cpoke to restart trial \nif',...
                                      ' off, goes to violation state']));

        next_row(y,1.1);

        % fixation: initial poke type & if fixation is required
        MenuParam(obj, 'init_poke_type', {'cpoke_fix';'cpoke_nofix';'cpoke_fix_decoupled';'spoke';},...
            1, x, y, 'label', 'init + fix. type',...
            'TooltipString', 'What type of poke starts a trial and if fixation is req. on cpoke',...
            'labelfraction',0.45,'position', [x y 150 20]);
        set_callback(init_poke_type, {mfilename, 'init_poke_type_callback'});
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
        ToggleParam(obj, 'task_growing_parameters', 0, x,y, 'position', [x y 300 20],...
            'OnString',  'Task growth, go cue, guide params Showing',...
            'OffString', 'Task growth, go cue, guide params Hidden', 'TooltipString', 'Show/hide task duration growth info');
        set_callback(task_growing_parameters, {mfilename, 'show_hide_growth_params_window'});
        oldx=x; oldy=y; parentfig=double(gcf);

        GROWTH_PARAMS_WINDOW_HEIGHT = 410;
        SoloParamHandle(obj, 'growth_params_window', 'saveable', 0, 'value', ...
            figure('Position', [925 370 525 GROWTH_PARAMS_WINDOW_HEIGHT],...
                   'MenuBar', 'none',...
                   'Name', 'Task growth parameters',...
                   'NumberTitle', 'off',...
                   'CloseRequestFcn', [mfilename '(' class(obj) ', ''hide_growth_params_window'');']));
        set(gcf, 'Visible', 'off');

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Go cue and light guide options %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Note, the cue can double as a light guide provided that go_light_type is
        % set to 'Guide' and go_cue_dur is long enough.
        x = 5; y = 5;

        next_row(y, 1);
        MenuParam(obj, 'fixation_led_type', {'center1led', 'center2led'}, 1, x, y,...
            'position', [x y 150 20], 'label', 'Fix. LED type', 'labelfraction', 0.5,...
            'TooltipString', 'If NIC LED On, whether to use the center1led or center2led for fixation');

        next_row(y, 1);
        NumeditParam(obj, 'go_cue_dur', 0.05, x, y, 'position', [x y 150 20],...
            'label', 'Go cue length [s]', 'labelfraction', 0.6, 'TooltipString',...
            'Length of the light-based go cue.');

        next_row(y, 1);
        MenuParam(obj, 'go_light_type', {'Ambiguous', 'Guide', 'Antiguide'}, 1,...
            x, y, 'position', [x y 150 20], 'label', 'Type', 'labelfraction', 0.3,...
            'TooltipString', 'Type of light go cue to use. Default is ambiguous (both sideports).');

        next_row(y, 1);
        ToggleParam(obj, 'go_light_toggle', 1, x, y, 'position', [x y 150 20],...
            'OnString', 'Light go cue ON',...
            'OffString', 'Light go cue OFF',...
            'TooltipString', 'Whether to use a light-based go cue');

        next_row(y, 1);
        ToggleParam(obj, 'go_aud_toggle', 0, x, y, 'position', [x y 150, 20],...
            'OnString', 'Aud. go cue ON',...
            'OffString', 'Aud. go cue OFF',...
            'TooltipString', 'Whether to use an auditory go cue. Note, this forces sb_extra <= post_dur.');
        set_callback(go_aud_toggle, {mfilename, 'go_aud_toggle_callback'});

        next_row(y, 1);
        SubheaderParam(obj, 'gocuehdr', 'Go cue options', x, y, 'position', [x y 150 20]);

        %----------------------%
        % Light guide options  %
        %----------------------%
        x = 160; y = 5;

        NumeditParam(obj, 'guide_cue_dur', 0, x, y, 'position', [x y 155 20],...
            'label', 'Guide cue length [s]', 'labelfraction', 0.6, 'TooltipString',...
            'Length of the light guide.');

        next_row(y, 1);
        NumeditParam(obj, 'guide_pre_rate', 0, x, y, 'position', [x y 155 20],...
            'label', 'Guide pre rate [s]', 'labelfraction', 0.6, 'TooltipString',...
            'Rate of growth for light guide preamble.');

        next_row(y, 1);
        NumeditParam(obj, 'guide_pre_dur', 0.05, x, y, 'position', [x y 155 20],...
            'label', 'Guide pre dur [s]', 'labelfraction', 0.6, 'TooltipString',...
            'Length of the light guide preamble (time after go cue ends). Default 0.05 s.');

        next_row(y, 1);
        MenuParam(obj, 'guide_type', {'Ambiguous', 'Guide', 'Antiguide'}, 2,...
            x, y, 'position', [x y 155 20], 'label', 'Type', 'labelfraction', 0.3,...
            'TooltipString', 'Type of light guide to use. Default is "Guide" (rewarded port).');

        next_row(y, 1);
        NumeditParam(obj, 'guide_prob', 0, x, y, 'position', [x y 155 20],...
            'label', 'Guide probability', 'labelfraction', 0.65, 'TooltipString',...
            'Probability of the light guide being turned on.');

        next_row(y, 1);
        ToggleParam(obj, 'guide_toggle', 0, x, y, 'position', [x y 155 20],...
            'OnString', 'Light guide ON',...
            'OffString', 'Light guide OFF',...
            'TooltipString', 'Whether to use a light guide');

        next_row(y, 1);
        NumeditParam(obj, 'guide_perf_threshold', 0.6, x, y, 'position', [x y 155 20],...
            'label', 'Perf. threshold', 'labelfraction', 0.65, 'TooltipString',...
            ['Hitrate threshold under which we turn on the light guide, assuming ',...
             'guide_perf_toggle above is on.']);

        next_row(y, 1);
        ToggleParam(obj, 'guide_perf_toggle', 0, x, y, 'position', [x y 155 20],...
            'OnString', 'Perf. light guide ON',...
            'OffString', 'Perf. light guide OFF',...
            'TooltipString', 'Whether to turn on a light guide for low-performance pairs.');

        next_row(y, 1);
        SubheaderParam(obj, 'guidecuehdr', 'Light guide options', x, y, 'position', [x y 155 20]);

        %----------------------%
        % Reward state options %
        %----------------------%
        x = 320; y = 5;

        PushbuttonParam(obj, 'play_replay', x, y, 'position', [x y 155 20], 'label',...
            'PLAY', 'TooltipString', 'Test the shortened Sa/delay/Sb replay');
        set_callback(play_replay, {mfilename, 'play_replay_callback'});

        next_row(y, 1);
        NumeditParam(obj, 'delay_replay_dur', 0.05, x, y, 'position', [x y 155 20],...
            'label', 'Delay replay dur [s]', 'labelfraction', 0.6, 'TooltipString',...
            'Length of replayed delay');

        next_row(y, 1);
        NumeditParam(obj, 'sb_replay_dur', 0.2, x, y, 'position', [x y 155 20],...
            'label', 'Sb replay dur [s]', 'labelfraction', 0.6, 'TooltipString',...
            'Length of replayed Sb sound');

        next_row(y, 1);
        NumeditParam(obj, 'sa_replay_dur', 0.2, x, y, 'position', [x y 155 20],...
            'label', 'Sa replay dur [s]', 'labelfraction', 0.6, 'TooltipString',...
            'Length of replayed Sa sound');

        next_row(y, 1);
        MenuParam(obj, 'reward_sound_option', {'N/A', 'Reward sound', 'Sa/Sb replay'},...
            1, x, y, 'position', [x y 155 20], 'labelfraction', 0.4, 'label', 'Sound',...
            'TooltipString', 'Reward sound options');

        next_row(y, 1);
        ToggleParam(obj, 'reward_light_toggle', 0, x, y, 'position', [x y 155 20],...
            'OnString', 'Reward light ON',...
            'OffString', 'Reward light OFF',...
            'TooltipString', 'Whether side LED turns on with reward state');

        next_row(y, 1);
        SubheaderParam(obj, 'replayhdr', 'Reward period options', x, y, 'position', [x y 155 20]);


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Task growth options (min, max, rates, etc) %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        x = 5; y = GROWTH_PARAMS_WINDOW_HEIGHT - 180;

        % Discrete growth values
        NumeditParam(obj, 'delay_discrete_values',[1.35, 2.0, 2.4], x, y,'labelfraction',0.3,...
            'TooltipString', 'values used for discrete delays',...
            'label', 'discrete', 'position', [x+200 y 150 20]); next_row(y,1.1);

        yanchor = y;

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
            'label', 'b', 'position', [x+350 y 50 20]);
        NumeditParam(obj, 'cp_fixation_alpha_adaptive',0.5, x, y, 'labelfraction',0.3,...
            'label', 'a', 'position', [x+400 y 50 20]);
        NumeditParam(obj, 'cp_fixation_beta_adaptive',0.5, x, y, 'labelfraction',0.3,...
            'label', 'b', 'position', [x+450 y 50 20]);
        next_row(y,1.1);

        % Units for fixed growth
        MenuParam(obj, 'pre_fixed_growth_unit', {'s';'%'},...
            1, x, y, 'label', 'unit', 'TooltipString',...
            'units of fixed growth rate', 'labelfraction',0.4,'position', [x y 100 20]);
        MenuParam(obj, 'stimulus_fixed_growth_unit', {'s';'%'},...
            1, x, y, 'label', 'unit',...
            'labelfraction',0.4,'position', [x+100 y 100 20]);
        MenuParam(obj, 'delay_fixed_growth_unit', {'s';'%'},...
            2, x, y, 'label', 'unit',...
            'labelfraction',0.4,'position', [x+200 y 100 20]);
        MenuParam(obj, 'post_fixed_growth_unit', {'s';'%'},...
            1, x, y, 'label', 'unit',...
            'labelfraction',0.4,'position', [x+300 y 100 20]);
        MenuParam(obj, 'cp_fixation_fixed_growth_unit', {'s';'%'},...
            1, x, y, 'label', 'unit',...
            'labelfraction',0.4,'position', [x+400 y 100 20]);
        next_row(y,1.1);

        % Rate for fixed growth
        NumeditParam(obj, 'pre_fixed_growth_rate',0.002, x, y,'labelfraction',0.6,...
            'TooltipString', 'Rate at which fixed growth is occuring',...
            'label', 'rate', 'position', [x y 100 20]);
        NumeditParam(obj, 'stimulus_fixed_growth_rate',0.002, x, y,'labelfraction',0.6,...
            'label', 'rate', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'delay_fixed_growth_rate',0.015, x, y,'labelfraction',0.6,...
            'label', 'rate','position', [x+200 y 100 20]);
        NumeditParam(obj, 'post_fixed_growth_rate',0.002, x, y,'labelfraction',0.6,...
            'label', 'rate', 'position', [x+300 y 100 20]);
        NumeditParam(obj, 'cp_fixation_fixed_growth_rate',0.002, x, y,'labelfraction',0.6,...
            'label', 'rate', 'position', [x+400 y 100 20]);
        next_row(y,1.1);

        % Maximum duration to grow to
        NumeditParam(obj, 'pre_max',0.25, x, y,'labelfraction',0.6,...
            'TooltipString', 'Maximum duration to grow to',...
            'label', 'max', 'position', [x y 100 20]);
        NumeditParam(obj, 'stimulus_max',0.2, x, y,'labelfraction',0.6,...
            'label', 'max', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'delay_max',2.5, x, y,'labelfraction',0.6,...
            'label', 'max','position', [x+200 y 100 20]);
        NumeditParam(obj, 'post_max',0.25, x, y,'labelfraction',0.6,...
            'label', 'max', 'position', [x+300 y 100 20]);
        NumeditParam(obj, 'cp_fixation_max',5, x, y,'labelfraction',0.6,...
            'label', 'max', 'position', [x+400 y 100 20]);
        next_row(y,1.1);

        % Previous session duration
        NumeditParam(obj, 'pre_prev_session',0.1, x, y,'labelfraction',0.6,...
            'TooltipString', 'Value of duration in last session',...
            'label', 'prev sess', 'position', [x y 100 20]);
        NumeditParam(obj, 'stimulus_prev_session',0.1, x, y,'labelfraction',0.6,...
            'label', 'prev sess', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'delay_prev_session',0.1, x, y,'labelfraction',0.6,...
            'label', 'prev sess','position', [x+200 y 100 20]);
        NumeditParam(obj, 'post_prev_session',0.1, x, y,'labelfraction',0.6,...
            'label', 'prev sess', 'position', [x+300 y 100 20]);
        NumeditParam(obj, 'cp_fixation_prev_session',0.1, x, y,'labelfraction',0.6,...
            'label', 'prev sess', 'position', [x+400 y 100 20]);
        next_row(y,1.1);

        % Starting (or minimum) duration for the seesion
        NumeditParam(obj, 'pre_min',0.05, x, y,'labelfraction',0.6,...
            'TooltipString', 'Minimum duration used at start of warm up',...
            'label', 'min', 'position', [x y 100 20]);
        NumeditParam(obj, 'stimulus_min',0.03, x, y,'labelfraction',0.6,...
            'label', 'min', 'position', [x+100 y 100 20]);
        NumeditParam(obj, 'delay_min',0.001, x, y,'labelfraction',0.6,...
            'label', 'min','position', [x+200 y 100 20]);
        NumeditParam(obj, 'post_min',0.10, x, y,'labelfraction',0.6,...
            'label', 'min', 'position', [x+300 y 100 20]);
        NumeditParam(obj, 'cp_fixation_min',0.001, x, y,'labelfraction',0.6,...
            'label', 'min', 'position', [x+400 y 100 20]);
        next_row(y,1.1);

        % headers
        SubheaderParam(obj,'lab1', 'pre',x,y,'position', [x y 90 20]);
        SubheaderParam(obj,'lab2', 'stim',x+100,y,'position', [x+100 y 90 20]);
        SubheaderParam(obj,'lab3', 'delay',x+200,y,'position', [x+200 y 90 20]);
        SubheaderParam(obj,'lab4', 'post',x+300,y,'position', [x+300 y 90 20]);
        SubheaderParam(obj,'lab5', 'cp_fixation',x+400,y,'position', [x+400 y 90 20],...
            'TooltipString', 'Generally disabled unless init_poke_type is set to cpoke_fix_decoupled');

        % add editable dur param, and growth/warmup toggles for cp_fixation
        x = 5 ; y = yanchor - (4 * 20);
        NumeditParam(obj, 'cp_fixation_dur_manual', value(cp_fixation_dur), x, y,...
            'position', [x+400 y 70 20], 'label', 'dur', 'TooltipString',...
            sprintf(['Field for manually setting the value of cp_fixation_dur. \n' ...
             'Only enabled for init_poke_type == cp_fix_decoupled.']));
        set_callback(cp_fixation_dur_manual, {mfilename, 'cp_fixation_dur_manual_callback'})
        next_row(y,1);
        MenuParam(obj, 'cp_fixation_growth_type', {'fixed';'adaptive'},...
            1, x, y, 'label', 'type', 'labelfraction', 0.4, 'position', [x+400 y 100 20]);
        next_row(y,1);
        ToggleParam(obj, 'cp_fixation_growth', 0, x, y, 'position', [x+400 y 100 20], ...
            'OffString', 'Grow OFF', 'OnString',  'Grow ON');
        next_row(y,1);
        ToggleParam(obj, 'cp_fixation_warm_up', 0, x, y, 'position', [x+400 y 100 20], ...
            'OffString', 'Warm Up OFF', 'OnString',  'Warm Up ON', 'TooltipString',...
            'NOT YET IMPLEMENTED');


        % disable all cp_fixation growth settings if init_poke_type is not cpoke_fix_decoupled
        ShapingSection(obj, 'init_poke_type_callback');

        %%% --- TASK GROWTH PARAMETERS SUBWINDOW END ---
        % back to main window
        x=oldx; y=oldy;
        figure(parentfig);

        %%% number of trials for warm up (ubiquitous to all durations)
        NumeditParam(obj, 'n_warm_up_trials',20, x, y,'labelfraction',0.7,...
            'label', 'warm up trials', 'position', [x+300 y 100 20]);next_row(y,1.1);

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

        %%% Switch to turn on growth warm up
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
        NumeditParam(obj, 'post_dur',0.1, x, y,'labelfraction',0.6,...
            'label', 'current', 'position', [x+300 y 100 20]);next_row(y,1.1);

        SubheaderParam(obj,'lab1', 'pre',x,y,'position', [x y 90 20]);
        SubheaderParam(obj,'lab2', 'stimulus',x+100,y,'position', [x+100 y 90 20]);
        SubheaderParam(obj,'lab3', 'delay',x+200,y,'position', [x+200 y 90 20]);
        SubheaderParam(obj,'lab4', 'post',x+300,y,'position', [x+300 y 90 20]);next_row(y);

        SubheaderParam(obj, 'lab0', 'Shaping Section',x+200,y, 'position', [x y 400 20]); next_row(y);


        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%    SEND OUT VARS    %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Allows us to select the appropriate SMA in PWM2.m. Write access
        % required in order to allow TrainingSection to set it appropriately.
        DeclareGlobals(obj, 'rw_args', {'init_poke_type'});

        %%% TrainingSection
        training_section_vars = {...
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
            'fixation_led_type', 'drinking_dur', 'legal_cbreak_dur', 'retry_type', 'temp_error_water_delay',...
            'settling_in_dur', 'temp_error_penalty', 'wait_for_spoke_Tup_forgiveness',...
            'reward_type', 'give_prob', 'wait_for_spoke_dur', 'delay_discrete_values',...
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
            'delay_dur', 'post_dur', 'violation_penalty', 'cp_fixation_min', 'cp_fixation_max',...
            'reward_light_toggle', 'go_cue_dur', 'go_aud_toggle', 'go_light_type', 'go_light_toggle',...
            'guide_cue_dur', 'guide_pre_rate', 'guide_pre_dur', 'guide_type', 'guide_toggle',...
            'guide_prob', 'guide_perf_threshold', 'guide_perf_toggle', 'sa_replay_dur', 'sb_replay_dur',...
            'delay_replay_dur', 'reward_sound_option', 'violation_sound_match_timeout',...
            'temp_error_sound_match_timeout', 'error_sound_match_timeout',...
            'extrafix_toggle', 'extrafix_length_multiplier', 'extrafix_reward_multiplier'};
        SoloFunctionAddVars('TrainingSection',   'rw_args', training_section_vars);
        SoloFunctionAddVars('TS_JY_spoke_fix',   'rw_args', training_section_vars);
        SoloFunctionAddVars('TS_JY_rulefirst',   'rw_args', training_section_vars);
        SoloFunctionAddVars('TS_PWM_classical',  'rw_args', training_section_vars);
        SoloFunctionAddVars('TS_LG_GNP_snds',    'rw_args', training_section_vars);
        SoloFunctionAddVars('TS_classicv2_full', 'rw_args', training_section_vars);
        SoloFunctionAddVars('TS_LGS_v2',         'rw_args', training_section_vars);

        %%% SMA
        sma_vars = {'inter_trial_perf_multiplier', 'inter_trial_hit_multiplier', 'inter_trial_error_multiplier',...
            'inter_trial_violation_multiplier', 'violation_dur', 'temp_error_dur', 'error_dur',...
            'inter_trial_dur','cp_fixation_dur', 'fixation_led', 'fixation_led_type', 'legal_cbreak_dur', 'retry_type',...
            'temp_error_water_delay', 'settling_in_dur', 'temp_error_penalty',...
            'wait_for_spoke_Tup_forgiveness', 'reward_type', 'give_prob', 'wait_for_spoke_dur',...
            'pre_dur', 'stimulus_dur', 'delay_dur', 'post_dur', 'drinking_dur', 'violation_penalty',...
            'reward_light_toggle', 'go_cue_dur', 'go_aud_toggle', 'go_light_type', 'go_light_toggle',...
            'guide_cue_dur', 'guide_pre_rate', 'guide_pre_dur', 'guide_type', 'guide_toggle',...
            'guide_prob', 'sa_replay_dur', 'sb_replay_dur', 'delay_replay_dur', 'reward_sound_option', 'extrafix_toggle',...
            'extrafix_length_multiplier', 'extrafix_reward_multiplier'};
        SoloFunctionAddVars('SMA_cpoke', 'ro_args', sma_vars);
        SoloFunctionAddVars('SMA_spoke', 'ro_args', sma_vars);

        %%% HistorySection
        SoloFunctionAddVars('HistorySection', 'ro_args', {...
        'violation_dur', 'temp_error_dur', 'error_dur', 'cp_fixation_dur','delay_dur',...
        'delay_growth_type', 'delay_discrete_values', 'reward_type', 'guide_toggle',...
        'extrafix_toggle'});

        %%% StimulusSection
        SoloFunctionAddVars('StimulusSection', 'ro_args', {'stimulus_dur','delay_dur','post_dur',...
            'sa_replay_dur', 'sb_replay_dur', 'delay_replay_dur'});


    %------------------------------------------------------------------%
    %              PREPARE NEXT TRIAL                                  %
    %------------------------------------------------------------------%
    case 'prepare_next_trial'

        if n_done_trials == 0
            % initialize sounds to be specific to protocol
            ShapingSection(obj, 'set_soundui_properties');
            % if warm-up is on for a given task variable, compute the step size
            % necessary to grow that parameter up to prev_session's value in
            % n_warm_up_trials steps.
            ShapingSection(obj, 'set_warmup_stepsizes');
            return;
        end

        % if give_prob is not 0, allows reward_type to switch between 'give'
        % and 'poke' probabilistically
        ShapingSection(obj, 'draw_reward_type');

        % if guide_prob is not 0, allows the light guide to switch between on
        % and off probabilistically
        ShapingSection(obj, 'draw_guide');

        %! Could use was_violation here to be more readable
        % Last trial was not a violation, so update any duration that is growing
        if result_history(end) ~= 3

            % If using a light guide and preamble growth is nonzero, grow it
            if value(guide_toggle) && value(guide_pre_rate) > 0
                guide_pre_dur.value = value(guide_pre_dur) + value(guide_pre_rate);
            end

            % Grow any task epochs for which growth is on
            for iperiod = 1 : length(task_prefixes)
                period  = task_prefixes{iperiod};
                curdur  = value(eval([period '_dur']));
                prevdur = value(eval([period '_prev_session']));
                growth  = value(eval([period '_growth']));
                growth_type       = value(eval([period '_growth_type']));
                fixed_growth_rate = value(eval([period '_fixed_growth_rate']));
                warm_up           = value(eval([period '_warm_up']));
                warm_up_step_size = value(eval([period '_warmup_stepsize']));

                % TODO: Currently warm-up only works if growth is also on. But there
                %       are situations where you would want warm up on, but not growth.
                % TODO: Make discrete a separate path.
                if growth
                    fprintf('******************* Growing: %s\n', period);
                    % Warm up growth.
                    % This is only executed if the following conditions are met:
                    %   * warm up toggle is on for this epoch
                    %   * the animal has not yet reached previous session's length
                    %   * computed warm up step size is larger than the fixed growth rate
                    if warm_up && (curdur < prevdur) && (warm_up_step_size > fixed_growth_rate)
                        ShapingSection(obj, 'update_fixed', period, warm_up_step_size, 's');
                    % Non-warm up growth
                    else
                        switch growth_type
                        case 'adaptive'
                            ShapingSection(obj, 'update_adaptive', period);
                        case 'fixed'
                            ShapingSection(obj, 'update_fixed', period);
                        case 'discrete'
                            % randomly select delay dur from array
                            random_idx = randi(length(delay_discrete_values), 1);
                            delay_dur.value = value(delay_discrete_values(random_idx));
                        end
                    end
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

        % Update duration of cp fixation, unless init_poke_type == cpoke_fix_decoupled
        % -- in which case, this was already computed above.
        switch value(init_poke_type)
        case 'cpoke_fix'
            cp_fixation_dur.value = value(pre_dur)      + ...
                                    value(stimulus_dur) + ...
                                    value(delay_dur)    + ...
                                    value(stimulus_dur) + ...
                                    value(post_dur);
        case 'cpoke_nofix'
            cp_fixation_dur.value = 0;
        end

        % Ensure that settling in does not exceed pre
        if value(settling_in_dur) > value(pre_dur)
            settling_in_dur.value = value(pre_dur);
        end

    %---------------------------------------------------------------%
    %          draw_reward_type                                     %
    %---------------------------------------------------------------%
    % Randomly sets the reward type to 'give' or 'poke', based on the value of 'give_prob'.
    case 'draw_reward_type'
        if rand(1) < value(give_prob) reward_type.value = 'give';
        else                          reward_type.value = 'poke';
        end

    %---------------------------------------------------------------%
    %          draw_guide                                           %
    %---------------------------------------------------------------%
    % Randomly sets the light guide on or off, based on the value of 'guide_prob'.
    case 'draw_guide'
        if rand(1) < value(guide_prob) guide_toggle.value = true;
        else                           guide_toggle.value = false;
        end
    
    %---------------------------------------------------------------%
    %          set_lightguide_lowhitrate_pairs                      %
    %---------------------------------------------------------------%
    % Checks whether we've toggled on light guide for low-performance pairs, and the current
    % stimulus pair. If we have and the current pair has low performance, then make sure that
    % the light guide toggle is set to true.
    case 'set_lightguide_lowhitrate_pairs'
        % Is the performance-specific toggle turned on?
        if ~value(guide_perf_toggle)
            return;
        end
        % Is the current pair a low-performance pair?
        hitrate = stim_table{value(current_pair), 5};
        if hitrate > value(guide_perf_threshold) || isnan(hitrate)
            % It is not, or we don't have any valid trials for this pair yet.
            % Ensure that the light guide is off.
            guide_toggle.value = false;
            guide_prob.value = 0;
            return;            
        end
        % We are in a current low-performance pair. Let's turn on the light guide.
        guide_toggle.value = true;
        guide_prob.value = 1.0;


    %---------------------------------------------------------------%
    %          set_soundui_properties                               %
    %---------------------------------------------------------------%
    % 2022-09-24: Setting go sound vol to 0, reduce auditory clutter
    % TODO: Update these in stimulus_section? That way all sound properties are set there.
    case 'set_soundui_properties'
        if value(temp_error_sound_match_timeout) tedur = value(temp_error_dur); else tedur = 0.5; end
        if value(error_sound_match_timeout)      edur  = value(error_dur);      else edur  = 0.5; end
        if value(violation_sound_match_timeout)  vdur  = value(violation_dur);  else vdur  = 0.5; end
        switch value(stimulus_type)
        case 'Frequency [Hz]'
            SoundInterface(obj, 'set', 'TempErrorSound',...
                                       'Style', 'SpectrumNoise',...
                                       'Vol', 0.001,...
                                       'Freq1', 5000,...
                                       'Freq2', 1000,...
                                       'Dur1', tedur);
            SoundInterface(obj, 'set', 'ErrorSound',...
                                       'Style', 'WhiteNoise',...
                                       'Vol', 0.001,...
                                       'Dur1', edur);
            SoundInterface(obj, 'set', 'ViolationSound',...
                                       'Style', 'WhiteNoise',...
                                       'Vol', 0.001,...
                                       'Dur1', vdur);
            SoundInterface(obj, 'set', 'GoSound',...
                                       'Style', 'WhiteNoise',...
                                       'Vol', 0.005);
        case 'Loudness [dB]'
            SoundInterface(obj, 'set', 'TempErrorSound',...
                                       'Style', 'SpectrumNoise',...
                                       'Vol', 0.001,...
                                       'Freq1', 5000,...
                                       'Freq2', 1000,...
                                       'Dur1', tedur);
            SoundInterface(obj, 'set', 'ErrorSound',...
                                       'Style', 'ToneFMWiggle',...
                                       'Vol', 0.001,...
                                       'Freq1', 5000,...
                                       'FMFreq', 100,...
                                       'FMAmp', 1000,...
                                       'Dur1', edur);
            SoundInterface(obj, 'set', 'GoSound',...       % Akrami 2018 GoSound
                                       'Style', 'Tone',...
                                       'Freq1', 6000,...
                                       'Dur1', 0.05,...
                                       'Vol', 0.001);
            SoundInterface(obj, 'set', 'ViolationSound',...
                                       'Style', 'ToneFMWiggle',...
                                       'Vol', 0.001,...
                                       'Freq1', 5000,...
                                       'FMFreq', 100,...
                                       'FMAmp', 1000,...
                                       'Dur1', vdur);
        case 'Classical [dB]'
            SoundInterface(obj, 'set', 'TempErrorSound',...
                                       'Style', 'WhiteNoise',...
                                       'Vol', 0.001,...
                                       'Dur1', tedur);
            SoundInterface(obj, 'set', 'ErrorSound',...
                                       'Style', 'WhiteNoise',...
                                       'Vol', 0.001,...
                                       'Dur1', edur);
            SoundInterface(obj, 'set', 'GoSound', ...
                                       'Style', 'PClick',...
                                       'Vol', 0.01,...
                                       'Freq1', 3000,...
                                       'Freq1', 6000,...
                                       'Dur1', 0.05,...
                                       'Width', 3,...
                                       'FreqS', 0);
            SoundInterface(obj, 'set', 'ViolationSound',...
                                       'Style', 'Tone',...
                                       'Vol', 0.001,...
                                       'Freq1', 9000,...
                                       'Dur1', 0.05);
        end


    %---------------------------------------------------------------%
    %          init_poke_type_callback                              %
    %---------------------------------------------------------------%
    case 'init_poke_type_callback'
        disp('****************** init_poke_type_callback!');
        % if cpoke_fix_decoupled is selected, add cp_fixation to the list of
        % task_prefixes and enable its growth parameters.
        if strcmp(init_poke_type, 'cpoke_fix_decoupled')
            enable(cp_fixation_growth);
            enable(cp_fixation_warm_up);
            enable(cp_fixation_alpha_adaptive);
            enable(cp_fixation_beta_adaptive);
            enable(cp_fixation_growth_type);
            enable(cp_fixation_fixed_growth_unit);
            enable(cp_fixation_fixed_growth_rate);
            enable(cp_fixation_max);
            enable(cp_fixation_prev_session);
            enable(cp_fixation_min);
            enable(cp_fixation_dur_manual);
            if ~any(strcmp(task_prefixes, 'cp_fixation'))
                task_prefixes{end+1} = 'cp_fixation';
            end
        else
            disable(cp_fixation_growth);
            disable(cp_fixation_warm_up);
            disable(cp_fixation_alpha_adaptive);
            disable(cp_fixation_beta_adaptive);
            disable(cp_fixation_growth_type);
            disable(cp_fixation_fixed_growth_unit);
            disable(cp_fixation_fixed_growth_rate);
            disable(cp_fixation_max);
            disable(cp_fixation_prev_session);
            disable(cp_fixation_min);
            disable(cp_fixation_dur_manual);
            if any(strcmp(task_prefixes, 'cp_fixation'))
                idx = find(strcmp(task_prefixes, 'cp_fixation'));
                task_prefixes(idx) = [];
            end
        end


    %---------------------------------------------------------------%
    %          cp_fixation_dur_manual_callback                      %
    %---------------------------------------------------------------%
    case 'cp_fixation_dur_manual_callback'
        cp_fixation_dur.value = value(cp_fixation_dur_manual);

    %---------------------------------------------------------------%
    %          play_replay_callback                                 %
    %---------------------------------------------------------------%
    case 'play_replay_callback'
        StimulusSection(obj, 'play_sasb_replay');

    %---------------------------------------------------------------%
    %          go_aud_toggle_callback                               %
    %---------------------------------------------------------------%
    % If we turn on the auditory go cue, then sb_extra cannot be longer
    % than post_dur. This is because the AOM cannot play multiple sounds
    % simultaneously: playing the go cue would disrupt Sb.
    case 'go_aud_toggle_callback'
        if value(go_aud_toggle)
            if value(sb_extra) > value(post_dur)
                sb_extra.value = value(post_dur);
            end
        end

    %---------------------------------------------------------------%
    %          set_warmup_stepsizes                                 %
    %---------------------------------------------------------------%
    case 'set_warmup_stepsizes'
        disp('********************** set_warmup_stepsizes');
        for iperiod = 1 : length(task_prefixes)
            period = task_prefixes{iperiod};
            growth = value(eval([period '_growth']));
            warmup = value(eval([period '_warm_up']));
            cur_dur = value(eval([period '_dur']));
            prev_dur = value(eval([period '_prev_session']));
            step_size = (prev_dur - cur_dur)/n_warm_up_trials;
            eval([period '_warmup_stepsize.value = step_size;']);
        end


    %---------------------------------------------------------------%
    %          update_adaptive                                      %
    %---------------------------------------------------------------%
    % case 'update_adaptive' TODO


    %---------------------------------------------------------------%
    %          update_fixed                                         %
    %---------------------------------------------------------------%
    case 'update_fixed'
        % Performs fixed rate update to specified variable, which can
        % be any of the task_prefixes or penalty_prefixes.
        % Parameters:
        %   varargin{1}: string, the variable to grow
        %   varargin{2}: (optional) double, the rate of fixed growth
        %   varargin{3}: (optional) string, the unit of fixed growth ('s' or '%')
        %
        % Example call:
        %   ShapingSection(obj, 'update_fixed', 'delay');
        %       This updates delay_dur according to the current settings of
        %       delay_fixed_growth_rate and delay_fixed_growth_unit
        %   ShapingSection(obj, 'update_fixed', 'delay', 0.001, 's');
        %       This increases delay_dur by 0.001 seconds, ignoring whatever
        %       delay_fixed_growth_rate and delay_fixed_growth_unit are set
        %       to.
        %
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
        switch growth_unit
        case 's'
            eval([task_var '_dur.value = cur_dur + growth_rate;']);
        case '%'
            eval([task_var '_dur.value = cur_dur * growth_rate;']);
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
                error(sprintf('Penalty prefix: %s not recognized', penalty_var));
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
                if prev_sound_dur > timeout_dur && timeout_dur ~= 0
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
        if strcmp(value(init_poke_type), 'cpoke_fix_decoupled')
            cp_fixation_prev_session.value = value(cp_fixation_dur);
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

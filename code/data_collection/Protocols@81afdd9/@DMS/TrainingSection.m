
%% TrainingSection Notes
% Initial draft by JRB 2022-05

% Goal:this section replaces a SessionDefinition file and creates the logical
% for trial-by-trial training to occur. It also allows for multiple
% curriculum to run form the same file. For example, you could have 
% a curriculum where animal is light guided for the first stages and a second
% one where they are not. This allows all animals to run from one common 
% file that can be easily tracked on git and is more readable than a Session
% Definition. If you want to keep a variable flexible, you can initiate it only
% on the first day in a stage, and then modify it in the GUI in the days 
% to follow while animal remains in the stage.

% Inspiration: Using TrainingSection from TaskSwitch6

% Case Info:
%       init : 
%           this is where all the gui information is initated
%    
%       set_stage_list :
%           given the current curriculum, creates the corresponding
%           stage list menu param & then gets curriculum update
% 
%       stage_name_callback :
%           if user selects new stage manually from stage_list in GUI,
%           updates the current/previous stage values & then gets
%           curriculum update
%       
%       increment_stage : 
%           when end of stage logic is hit in curriculum stage & autotrain
%           is on, updates current stage the next stage & resets stage
%           specific history variables
%       
%       prepare_next_trial : 
%           tracks strials in stage & gets a curriculum update, also
%           checks to see if helper is on (helper not currently in use 2022-06)
% 
%       get_curriculum_update :
%           acts like SessionDefinition file. Given a curriculum & currrent stage,
%           inits session w/ specific variables (e.g. growth on) and then 
%           can modulate variables during a session. Also has logic to progress
%           to next stage.
%       
%       implement_helper : (not in use as of 2022-06)
%           if on, will check to see if animal performance is below a specified
%           threshold and if so, will give a specified amount of easier trials.
%           For example, temp error can be turned on for 10 trials to get motivation
%           back up and then will turn off. 
% 
%       end_session: 
%           tracks the number of days in a stage & training. One could add
%           EOD logic here, but as written stage swtich logic happens within
%           a session (like a completion string)
%

%% TODO - JY updates to set_stage
%% TODO - cohort 2 specific clean up

%% CODE
function [x, y] = TrainingSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action,

    % ------------------------------------------------------------------
    %              INIT
    % ------------------------------------------------------------------

    case 'init'
        x=varargin{1};
        y=varargin{2};
        
        %%% violation threshold & toggle for helper
        NumeditParam(obj, 'helper_violation_threshold',0.70, x, y,'labelfraction',0.65,...
            'TooltipString', 'violation rate to trigger a subset of eaiser trials',...
            'label', 'violation threshold', 'position', [x y 150 20]);
        ToggleParam(obj, 'violation_helper', 1, x, y, 'position', [x+150 y 50 20], ...
            'OffString', 'OFF', 'OnString',  'ON', ...
            'TooltipString', 'If on, & helper on will be used a threshold for setting animal back');
        next_row(y, 1);
        
        %%% hit threshold & toggle for helper
        NumeditParam(obj, 'helper_hit_threshold',0.55, x, y,'labelfraction',0.65,...
            'TooltipString', 'hit rate to trigger a subset of eaiser trials',...
            'label', 'hit threshold', 'position', [x y 150 20]);
        ToggleParam(obj, 'hit_helper', 1, x, y, 'position', [x+150 y 50 20], ...
            'OffString', 'OFF', 'OnString',  'ON', ...
            'TooltipString', 'If on, & helper on will be used a threshold for setting animal back');
        next_row(y, 1);
        
        %%% helper block params: helper_type and counter for number of helper blocks
        MenuParam(obj, 'helper_type', {'reward'; 'error'; 'both'},...
            1, x, y, 'position', [x y 100 20], 'label', 'type', 'labelfraction', 0.40,...
            'TooltipString', 'type of help given if block is entered');
        DispParam(obj, 'helper_block_counter', 0, x,y, 'labelfraction', 0.5,...
            'label', 'n blocks', 'position', [x+100 y 100 20],...
            'TooltipString', 'number of times a helper block has been entered this session');
        next_row(y, 1);
        
        %%% helper block params: n trials back to assess, n easier trials to give and
        %%% internal counter for exiting out of block
        MenuParam(obj, 'helper_trials_back', {'10'; '25'; '50'; '75'; '100'},...
            2, x, y, 'position', [x y 100 20], 'label', 'n back', 'labelfraction', 0.40,...
            'TooltipString', 'number trials back to look at to apply threshold');
        NumeditParam(obj, 'helper_trials_give',10, x, y,'labelfraction',0.5,...
            'TooltipString', 'number of easier trials to give',...
            'label', 'give', 'position', [x+100 y 100 20]);
        SoloParamHandle(obj, 'helper_trial_counter', 'value', 0);
        next_row(y, 1);

        %%% helper: performance based logic to temporarily move into an easier version
        %%% of the current trial structure
        ToggleParam(obj, 'helper', 0, x, y, 'position', [x y 100 20], ...
            'OffString', 'Helper OFF', 'OnString',  'Helper ON', ...
            'TooltipString', 'If on, search over window given thresholds to determine short setback');
        DispParam(obj, 'in_helper_block', 'FALSE', x, y, 'position', [x+100 y 100 20],...
            'label', 'In Block', 'labelfraction', 0.55,...
            'TooltipString', 'Whether the animal is currently in a helper block.');
        next_row(y, 1.5);

        %%% Stage history
        NumeditParam(obj, 'n_days_stage',0, x, y, 'labelfraction', 0.55,...
            'label','n days','position', [x y 100 20],...
            'TooltipString', 'number of consecutive days in training stage');
        NumeditParam(obj, 'n_days_training',0, x, y, 'labelfraction', 0.55,...
            'label','total sess.','position', [x+100 y 100 20],...
            'TooltipString', 'number of days/sessions total');
        next_row(y,1);
       
        DispParam(obj, 'n_trials_stage',0, x, y, 'labelfraction', 0.55,...
            'label','n trials','position', [x y 100 20],...
            'save_with_settings', 1,...
            'TooltipString', 'number of trials done in stage in a session');
        %%% Auto stage switch upon completion logic
        ToggleParam(obj, 'stage_switch_auto', 1, x, y, 'position', [x+100 y 100 20], ...
            'OffString', 'Autotrain OFF', 'OnString',  'Autotrain ON', ...
            'TooltipString', 'If on, switches automatically between training stages');
        next_row(y, 6);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Curriculum. Used to specify training stages. %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        SubheaderParam(obj, 'title', mfilename, x, y); next_row(y, -1);
        MenuParam(obj, 'curriculum', {'JB_cpoke_nofix';'JB_cpoke_fix'},...
            1, x, y, 'position', [x y 200 20], 'label', 'Curriculum',...
            'labelfraction', 0.35, 'TooltipString', 'The current curriculum.');
        next_row(y, -1);
        DispParam(obj, 'curriculum_description', 'Curriculum description',...
            x, y, 'label', '', 'position', [x y 200 20], 'labelfraction', 0.01,...
            'TooltipString', 'Description of the current curriculum.');
        next_row(y, -1);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Generate list of training stages. %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage info
        SoloParamHandle(obj, 'stage_list', 'value', {});
        SoloParamHandle(obj, 'stage_number', 'value', 1);
        SoloParamHandle(obj, 'stage_name', 'value', '');
        % Mirrors stage name, but not reinstantiated each trial
        SoloParamHandle(obj, 'stage_name_persist', 'value', '');
        % GUI locations for creation of curriculum specific stage param
        SoloParamHandle(obj, 'x_stage_name', 'value', x);
        SoloParamHandle(obj, 'y_stage_name', 'value', y);

        % Set the stage init & given a curriculum change
        TrainingSection(obj, 'set_stage_list', value(x_stage_name), value(y_stage_name));
        set_callback(curriculum, {mfilename, 'set_stage_list', value(x_stage_name),...
            value(y_stage_name)});
        next_row(y, -1.6);
        % Describe the given curriculums stage
        DispParam(obj, 'stage_description', 'Stage description', x, y, 'label',...
            '', 'position', [x y-5 200 35], 'labelfraction', 0.01, 'TooltipString',...
            'Description of the current stage.');
        next_row(y, 2.4);

        %%% Send out vars
        SoloFunctionAddVars('HistorySection', 'ro_args',...
          {'stage_name', 'curriculum', 'stage_number', 'stage_name_persist',...
          'in_helper_block'});
        SoloFunctionAddVars('HistorySection', 'rw_args',...
            {'n_trials_stage', 'n_days_stage', 'n_days_training'}); 
        SoloFunctionAddVars('ShapingSection', 'ro_args',...
          {'n_trials_stage', 'n_days_stage', 'n_days_training'});
        DeclareGlobals(obj, 'ro_args', {'stage_name', 'stage_number', 'stage_name_persist'});

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Set appropriate initial values, toggles, etc for this stage. %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        TrainingSection(obj, 'get_curriculum_update');

    %---------------------------------------------------------------%
    %          set_stage_list                                           %
    %---------------------------------------------------------------%
    case 'set_stage_list'
        % Generates the appropriate stage list from the current curriculum, and
        % constructs the stage_name MenuParam to allow the user to select stages.
        % We set stage_number, stage_name, stage_name_persist, and pervious_stage
        % to default values (i.e., the first stage).
        disp('running set_stage_list !!!!!!!!!!!!!!!!!!!!');
        x = varargin{1};
        y = varargin{2};
        switch value(curriculum)

        case 'JB_cpoke_nofix'
            stage_list.value = {'1: spoke autorewd',...
                                '2: center side no snds give',...
                                '3: center snds side give no viol',...
                                '4: grow stim',...
                                '5: grow pre',...
                                '6: grow post',...
                                '7: grow delay (0.2)',...
                                '8: require rule, never',...
                                '9: grow delay btw snds (2.4)',...
                                '10: discrete delays',...
                                '11: add stimuli'};
        case 'JB_cpoke_fix' % currently not in use!
            stage_list.value = {'1: center side no snds give',...
                                '2: gnp 1sec gosnd give',...
                                '3: all snds give',...
                                '4: require rule (temperror)',...
                                '5: require rule (temperror off)',...
                                '6: gnp 3.1sec grow delay',...
                                '7: discrete delay lengths',...
                                '8: add stimuli'};
        end % end curriculum switch
        MenuParam(obj, 'stage_name', value(stage_list), 1, x, y, 'label', 'Stage',...
            'labelfraction', 0.35, 'TooltipString', 'The current training stage');
        set_callback(stage_name, {mfilename, 'stage_name_callback'});
        stage_name_persist.value = value(stage_name);
        previous_stage.value = value(stage_name);
        TrainingSection(obj, 'get_curriculum_update');
    
    %---------------------------------------------------------------%
    %          stage_name_callback                                  %
    %---------------------------------------------------------------%
    case 'stage_name_callback'
        %%% new stage selected manually from list, update values
         % save previous stage
        previous_stage.value = value(stage_name_persist);
        % grab stage number selected
        stage_number.value = find(strcmp(value(stage_name), value(stage_list)));
        % update the persistent name
        stage_name_persist.value = value(stage_name);
        % update counters 
        n_trials_stage.value = 0;
        if n_done_trials ~= 0 % don't overwrite trials on load
            n_days_stage.value = 1;
        end
        % get new curriculum presets
        TrainingSection(obj, 'get_curriculum_update');

    %---------------------------------------------------------------%
    %          increment_stage                                      %
    %---------------------------------------------------------------%   
    case 'increment_stage'
        % end of stage logic was hit, move into new stage if auto train
        if value(stage_switch_auto)
            % save previous stage string
            previous_stage.value = value(stage_name_persist);
            
            % move to a specified stage
            if length(varargin) == 1 
                next_stage = varargin{1}
                stage_number.value = next_stage;
            else
                % move to next numerical stage
                stage_number.value = value(stage_number) + 1;
            end 
            
            % update stage name strings
            stage_name.value = stage_list{value(stage_number)};
            stage_name_persist.value = value(stage_name);
            % update counters
            n_trials_stage.value = 0;
            n_days_stage.value = 1;
            % get new curriculum presets
            TrainingSection(obj, 'get_curriculum_update');
        else
            disp('Stage completed, but auto switch is off')
        end
    
    %---------------------------------------------------------------%
    %          prepare_next_trial                                   %
    %---------------------------------------------------------------%
    case 'prepare_next_trial'
        % check to see if we need to switch into a new stage given
        % performance & toggle
        if n_done_trials > 0
            n_trials_stage.value = value(n_trials_stage) + 1;
            feval(mfilename, obj, 'get_curriculum_update');
        end
        % check to see if helper needs to be turned on given
        % performance & toggle
        if value(helper)
            TrainingSection(obj, 'implement_helper', value(helper_tyle));
        end


    %---------------------------------------------------------------%
    %          get_curriculum_update                                %
    %---------------------------------------------------------------%
    case 'get_curriculum_update'
        %%% Set parameters across sections for the curriculum/training stage
        switch value(curriculum)

        %---------------------------------------------------%
        %         JB_cpoke_nofix                            %
        %---------------------------------------------------%
        % DMS protocol that does not require animal to fixate,
        % written by JRB June 2022. 
        % Goal: learn cpoke, learn rule, grow sa/sb delay, extend stim
        case 'JB_cpoke_nofix'
            switch value(stage_number)
            case 1
                stage_description.value = 'spoke --> rwd';
                %%% initialize on the first trial
                if (value(n_trials_stage)==0)
                    %%% task parameters
                    init_poke_type.value = 'spoke';
                    stimuli_on.value = false;
                    inter_trial_dur_type.value = 'sampled';
                    inter_trial_sample_mean.value = 1;
                end

                %%% Auto stage-switch logic
                if (value(n_done_trials) >= value(helper_trials_give))
                   TrainingSection(obj, 'increment_stage');
                end

            case 2
                stage_description.value = 'cpoke spoke --> rwd';
                %%% initialize on the first trial
                if (value(n_trials_stage)==0)
                    %%% task parameters
                    reward_type.value = 'give';
                    init_poke_type.value = 'cpoke_nofix';
                    stimuli_on.value = false;
                    wait_for_spoke_Tup_forgiveness.value = true;
                    temp_error_penalty.value = true;
                    retry_type.value = 'multi';
                    inter_trial_perf_multiplier.value = false;
                end

                %%% Auto stage-switch logic
                if (value(n_done_trials) >= 50) && (value(frac_correct) > .7) && ...
                   (value(n_days_stage) > 0)
                   TrainingSection(obj, 'increment_stage');
                end

            case 3
                stage_description.value = 'cpoke snd spoke, no viol';
                %%% initialize on the first trial
                if (value(n_trials_stage)==0)
                    %%% task parameters
%                     reward_type.value = 'give';
%                     stimuli_on.value = true;
%                     wait_for_spoke_Tup_forgiveness.value = true;
%                     temp_error_penalty.value = true;
%                     retry_type.value = 'single';
                    inter_trial_perf_multiplier.value = false;
                    violation_penalty.value = false;
                
                    %%% durations 
                    pre_dur.value = 0.1;
                    delay_dur.value = 0.1;
                    stimulus_dur.value = 0.2;
                    post_dur.value = 0.1;

                    %%% delays (incase of reset)
                    delay_growth.value = false;
                    delay_warm_up.value = false;
                 end

                %%% Auto stage-switch logic
                %%% TODO- make this early spoke based
                if (value(n_trials_stage) >= 100) &&...
                        (value(n_early)/value(n_trials_stage)) < 0.5 
                    TrainingSection(obj, 'increment_stage');
                end

            case 4
                stage_description.value = 'grow stim';
                %%% initialize on the first trial
                if (value(n_trials_stage)==0)
                    %%% task parameters
                    stimuli_on.value = true;
                    inter_trial_perf_multiplier.value = false;
                    violation_penalty.value = true;
                    violation_dur.value = 0.5;
                    violation_dur_type.value = 'growing';
                    violation_fixed_growth_rate.value = 0.025;
                    error_dur.value = 0.5;
                    error_dur_type.value = 'stable';
                    
                    if value(n_days_stage) == 0
                        temp_error_penalty.value = false;
                        retry_type.value = 'N/A';
                        reward_type.value = 'poke';
                        wait_for_spoke_Tup_forgiveness.value = false;                        
                    end
                        
                
                    % growth stimulus
                    stimulus_min.value = 0.1;
                    stimulus_dur.value = value(stimulus_min);
                    stimulus_growth.value = true;
                    stimulus_warm_up.value = true;
                    pre_growth.value = false;
                    delay_growth.value = false;
                    post_growth.value = false;
                    
                end
                              
                %%% Auto stage-switch logic
                if (value(frac_violations) < 0.5) && (value(stimulus_dur) >= value(stimulus_max))
                    TrainingSection(obj, 'increment_stage');
                end
               
            case 5   
                stage_description.value = 'grow pre';
                %%% initialize on the first trial
                if (value(n_trials_stage)==0)
                    %%% task parameters
                    stimuli_on.value = true;
                    inter_trial_perf_multiplier.value = false;
                    violation_penalty.value = true;
                    violation_dur.value = 0.5;
                    violation_dur_type.value = 'growing';
                    violation_fixed_growth_rate.value = 0.025;
                    error_dur.value = 0.5;
                    error_dur_type.value = 'stable';
                    
                    if value(n_days_stage) == 0
                        temp_error_penalty.value = false;
                        wait_for_spoke_Tup_forgiveness.value = false;
                        retry_type.value = 'N/A';
                        reward_type.value = 'poke';                        
                    end                    
                
                    % grow pre
                    pre_min.value = 0.1;
                    pre_dur.value = value(pre_min);
                    pre_growth.value = true;
                    pre_warm_up.value = true;
                    % turn off other growth
                    stimulus_growth.value = false;
                    delay_growth.value = false;
                    post_growth.value = false;
                else
                    % grow settling in dur to 0.2 in tandem
                    if value(settling_in_dur) < 0.2
                        settling_in_dur.value = value(pre_dur);
                    end
                end
                
                %%% Auto stage-switch logic
                if (value(frac_violations) < 0.5) && (value(pre_dur) >= value(pre_max))
                    TrainingSection(obj, 'increment_stage');
                end
            case 6   
                stage_description.value = 'grow post';
                %%% initialize on the first trial
                if (value(n_trials_stage)==0)
                    %%% task parameters
                    stimuli_on.value = true;
                    inter_trial_perf_multiplier.value = false;
                    violation_penalty.value = true;
                    violation_dur.value = 0.5;
                    violation_dur_type.value = 'growing';
                    violation_fixed_growth_rate.value = 0.025;
                    error_dur.value = 0.5;
                    error_dur_type.value = 'stable';

                    if value(n_days_stage) == 0
                        temp_error_penalty.value = false;
                        retry_type.value = 'N/A';
                        reward_type.value = 'poke';
                        wait_for_spoke_Tup_forgiveness.value = false;
                    end                         
                    
                    post_min.value = 0.05;
                    post_dur.value = value(post_min);
                    post_growth.value = true;
                    post_warm_up.value = true;
                    % turn off other growth
                    pre_growth.value = false; 
                    stimulus_growth.value = false;
                    delay_growth.value = false;

                end
                
                %%% Auto stage-switch logic
                if (value(frac_violations) < 0.5) && (value(post_dur) >= value(post_max))
                    TrainingSection(obj, 'increment_stage');
                end
            case 7  
                stage_description.value = 'grow delay (0.2)';
                %%% initialize on the first trial
                if (value(n_trials_stage)==0)
                    %%% task parameters
                    stimuli_on.value = true;
                    inter_trial_perf_multiplier.value = false;
                    violation_penalty.value = true;
                    violation_dur.value = 0.5;
                    violation_dur_type.value = 'growing';
                    violation_fixed_growth_rate.value = 0.025;
                    error_dur.value = 0.5;
                    error_dur_type.value = 'stable';               

                    if value(n_days_stage) == 0
                        temp_error_penalty.value = false;
                        retry_type.value = 'N/A';
                        reward_type.value = 'poke';
                        wait_for_spoke_Tup_forgiveness.value = false;
                    end      
                    
                    delay_min.value = 0.1;
                    delay_max.value = 0.2;
                    delay_dur.value = value(delay_min);
                    delay_growth.value = true;
                    delay_warm_up.value = true;
                    % turn off other growth
                    pre_growth.value = false;
                    stimulus_growth.value = false;
                    post_growth.value = false;

                end
                
                %%% Auto stage-switch logic
                if (value(frac_violations) < 0.5) && (value(delay_dur) >= 0.2)
                    TrainingSection(obj, 'increment_stage');
                end                   
            
            case 8
                stage_description.value = 'learn rule w/ never reward';
                %%% initialize on the first trial
                if (value(n_trials_stage)==0)
                    %%% task parameters
                    
                    stimuli_on.value = true;
                    wait_for_spoke_Tup_forgiveness.value = false;

                    inter_trial_perf_multiplier.value = false; %TODO upate inits

%                     helper_hit_threshold.value = 0.5;
%                     helper_violation_threshold.value = 0.7;
                
                    %%% delays (incase of reset)
                    pre_growth.value = false;
                    stimulus_growth.value = false;
                    delay_growth.value = false;
                    post_growth.value = false;
                    
                    %%% initializations for first day in the stage give
                    %%% user more flexibility to modify these on animal
                    %%% by animal basis since this stage takes the longest
                    if (value(n_days_stage) == 1)
                        reward_type.value = 'poke';
                        violation_penalty.value = true;
                        violation_dur.value = 0.5;
                        violation_dur_type.value = 'growing';
                        error_dur.value = 0.5;
                        error_dur_type.value = 'growing';
                        temp_error_penalty.value = false;
                        retry_type.value = 'N/A';
                    end
                    
                end
                                    
%                 %%% helper
%                 if (value(n_trials_stage) >= 30) && (value(n_days_stage) < 5) && ...
%                     (value(helper_block_counter) < 3)
%                     helper.value = true;
%                     helper_type.value = 'error'; 
%                 end

                %%% Auto stage-switch logic
                if (value(n_trials_stage) >= 100) && (value(frac_correct) > .9) && ...
                    (value(frac_violations) < 0.4)
                    TrainingSection(obj, 'increment_stage');
                end

            case 9
                stage_description.value = 'grow delay between sa/sb';
                %%% initialize on the first trial
                if (value(n_trials_stage) == 0)
                    %%% task parameters
                    reward_type.value = 'poke';
                    stimuli_on.value = true;
                    wait_for_spoke_Tup_forgiveness.value = false;
                    temp_error_penalty.value = false;
                    retry_type.value = 'N/A';

                    %%% growth
                    delay_min.value = 0.2;
                    delay_max.value = 2.5;
                    delay_dur.value = value(delay_min);
                    delay_growth.value = true;
                    delay_warm_up.value = true;

                    if value(n_days_stage) == 1
                        delay_growth_type.value = 'fixed';
                        delay_fixed_growth_rate.value = 1.50; % ~360 valid trials to reach
                        delay_fixed_growth_unit.value = '%';
                    end 
                end
                %%% Auto stage-switch logic
                if (value(delay_dur) >= value(delay_max)) && (value(frac_violations) < 0.3) && ...
                    (value(frac_correct) > 0.7)
                    TrainingSection(obj, 'increment_stage');
                end 

            case 10
                stage_description.value = 'discrete delays';
                %%% initialize on the first trial                
                if (value(n_trials_stage) == 0)
                    %%% task parameters
                    reward_type.value = 'poke';
                    stimuli_on.value = true;
                    wait_for_spoke_Tup_forgiveness.value = false;
                    temp_error_penalty.value = false;
                    retry_type.value = 'N/A';
                    
                    %%% disrete delays
                    delay_growth.value = false;
                    delay_warm_up.value = false;
                    delay_growth_type.value = 'discrete';
                end
%                 %%% Auto stage-switch logic
%                 if (value(n_days_stage) > 0) && (value(frac_violations) < 0.3) && ...
%                         (value(n_done_trials) > 5)
%                     stage_number.value = 7;
%                 end 
%                 
            case 11
                stage_description.value = 'add stimuli';
                % TODO

            end % End JB_cpoke_nofix stage_number

            

        %---------------------------------------------------%
        %         JB_cpoke_fix                              %
        %---------------------------------------------------%
        % DMS protocol that does require animal to fixate,
        % written by JRB June 2022. 
        % Goal: learn cpoke, grow delay a little, learn rule, 
        % grow sa/sb delay, extend stim
        case 'JB_cpoke_fix'
            switch value(stage_number)
            % cpoke --> give reward in side
            % trial availability LED
            case 1
                stage_description.value= 'center to side no sounds';
                %%% updated only on the first trial
                if(value(n_trials_stage)==0)
                    %%% task parameters
                    reward_type.value = 'give';
                    init_poke_type = 'cpoke_nofix';
                    stimuli_on.value = false;
                    wait_for_spoke_Tup_forgiveness.value = true;
                    temp_error_penalty.value = true;
                    

                    if value(n_days_stage) > 2
                        retry_type.value = 'single';
                    else
                        retry_type.value = 'multi';
                    end

                    inter_trial_perf_multiplier.value = false;
                end
                %%% EOS logic
                if value(n_done_trials) >= 70 && value(percent_correct) > .7
                    stage_number.value = 2;
                    n_trials_stage.value = 0;
                    n_days_stage.value = 1;
                end


            case 2
                stage_description.value = 'center to side, gnp with go cue and give reward';
                if value(n_trials_stage) == 0
                    %%% task parameters
                    reward_type.value = 'give';
                    init_poke_type = 'cpoke_fix';
                    stimuli_on.value = true;
                    wait_for_spoke_Tup_forgiveness.value = false;
                    temp_error_penalty.value = true;

                    if value(n_days_stage) > 2
                        retry_type.value = 'single';
                    else
                        retry_type.value = 'multi';
                    end

                    inter_trial_perf_multiplier.value = false;

                    %%% sound parameters
                    SoundInterface_SaSound_Vol.value = 0;
                    SoundInterface_SbSound_Vol.value = 0;

                    %%% duration & growth inits 
                    pre_min.value = 0.1;
                    pre_dur.value = value(pre_min);
                    pre_growth.value = true;
                    pre_growth_type.value = 'fixed';
                    pre_fixed_growth_unit.value = 's';
                    pre_warm_up.value = true;
                    %! if you change pre_fixed_growth_rate will it be maintained 
                    % into the next session?
                     
                    delay_dur.value = 0.001;
                    delay_growth.value = false;
                    stimulus_dur.value = 0.001;
                    stimulus_growth.value = false;
                    post_dur.value = 0.001;
                    post_growth.value = false;
                end
                %%% algorithm: grow pre_dur
                if value(pre_dur) >= 1.0
                    stage_number.value = 3;
                    n_trials_stage.value = 0;
                    n_days_stage.value = 1;
                end


            case 3
                stage_description.value = 'center to side, play stimuli and give reward'; 

                if(value(n_trials_stage)==0) || strcmp(value(in_helper_block), 'TRUE')
                    %%% task parameters
                    reward_type.value = 'give';
                    init_poke_type = 'cpoke_fix';
                    stimuli_on.value = true;
                    wait_for_spoke_Tup_forgiveness.value = false;
                    temp_error_penalty.value = true;
                    retry_type.value = 'single';
                    inter_trial_perf_multiplier.value = false;

                    %%% sound parameters'
                    % TODO: change these to be correct when ready
                    SoundInterface_SaSound_Vol.value = 0.1;
                    SoundInterface_SbSound_Vol.value = 0.1;

                    %%% duration and growth inits
                    % TODO: make stimulus_dur and soundUI interact
                    pre_dur.value = 0.2;
                    pre_growth.value = false;
                    delay_dur.value = 0.2;
                    delay_growth.value = false;
                    stimulus_dur.value = 0.2;
                    stimulus_growth.value = false;
                    post_dur.value = 0.2;
                    post_growth.value = false;
                    
%                     StimulusSection(obj, 'set_pairs', [3000 6000 ; 6000 3000 ; 6000 12000 ; 12000 6000]);
                end
                %%% algorithm
                if strcmp(in_helper_block, 'TRUE')
                    if ~exists('var', 'ctr')
                        ctr = value(helper_trials_give);
                    end
                    ctr = ctr - 1;
                    if ctr == 0
                        in_helper_block.value = 'FALSE';
                        stage_number.value = 4;
                        clear ctr;
                    end
                end
                if value(n_trials_stage) >= 100 && value(last100trialperf) > .7 && ...
                   value(violation_rate) < .5 && strcmp(in_helper_block, 'FALSE')
                    stage_number.value = 4;
                    n_trials_stage.value = 0;
                    n_days_stage.value = 1;elpe
                end


            case 4
                stage_description.value = 'center to side, play stimuli required rule (temperror)';
                if value(n_trials_stage) == 0
                    %%% task parameters
                    reward_type.value = 'poke';
                    init_poke_type = 'cpoke_fix';
                    stimuli_on.value = true;
                    wait_for_spoke_Tup_forgiveness.value = false;
                    temp_error_penalty.value = true;
                    retry_type.value = 'single';
                    inter_trial_perf_multiplier.value = true;

                    %%% duration and growth inits
                    % TODO: make stimulus_dur and soundUI interact
                    pre_dur.value = 0.2;
                    pre_growth.value = false;
                    delay_dur.value = 0.2;
                    delay_growth.value = false;
                    stimulus_dur.value = 0.2;
                    stimulus_growth.value = false;
                    post_dur.value = 0.2;
                    post_growth.value = false;

                    if value(n_days_stage) > 3
                        helper.value = false;
                    else
                        helper.value = true;
                    end

                    % TODO: Set which stimuli you want to use?
                    %StimulusSection(obj, 'set_preset', 'Cross (4 pairs)');
                    % OR
                    %StimulusSection(obj, 'set_pairs', [3000 6000 ; 6000 12000 ; ...]);
                end
                %%% algorithm
                if value(n_trials_stage) >= 150 && value(last150trialperf) > .7 && value(violation_rate) < .3
                    stage_number.value = 5;
                    n_trials_stage.value = 0;
                    n_days_stage.value = 1;
                elseif value(helper)
                    % TODO
                    %if perf_over_helper_window < threshold
                    %    in_helper_block.value = 'TRUE';
                    %    stage_number.value = 'Stage 3';
                    %end
                end
                

            case 5
                stage_description.value = 'center to side, play stimuli required rule (temp error off)';
                if value(n_trials_stage) == 0
                    %%% task parameters
                    reward_type.value = 'poke';
                    init_poke_type = 'cpoke_fix';
                    stimuli_on.value = true;
                    wait_for_spoke_Tup_forgiveness.value = false;
                    temp_error_penalty.value = false;
                    retry_type = 'N/A';
                    inter_trial_perf_multiplier.value = true;

                    %%% duration and growth inits
                    % TODO: make stimulus_dur and soundUI interact
                    pre_dur.value = 0.2;
                    pre_growth.value = false;
                    delay_dur.value = 0.2;
                    delay_growth.value = false;
                    stimulus_dur.value = 0.2;
                    stimulus_growth.value = false;
                    post_dur.value = 0.2;
                    post_growth.value = false;
                end
                
                %%% algorithm
                if value(n_trials_stage) >= 150 && value(last150trialperf) > .7 && value(violation_rate) < .3
                    stage_number.value = 6;
                    n_trials_stage.value = 0;
                    n_days_stage.value = 1;
                end 

            case 6
                stage_description.value = 'growth of delay btwn stimuli';
                if value(n_trials_stage) == 0
                    %%% task parameters
                    reward_type.value = 'poke';
                    init_poke_type = 'cpoke_fix';
                    stimuli_on.value = true;
                    wait_for_spoke_Tup_forgiveness.value = false;
                    temp_error_penalty.value = false;
                    retry_type = 'N/A';
                    inter_trial_perf_multiplier.value = true;

                    %%% duration and growth inits
                    % TODO: make stimulus_dur and soundUI interact
                    pre_dur.value = 0.2;
                    pre_growth.value = false;
                    stimulus_dur.value = 0.2;
                    stimulus_growth.value = false;
                    post_dur.value = 0.2;
                    post_growth.value = false;

                    delay_min.value = 0.2;
                    delay_dur.value = value(delay_min);
                    delay_growth.value = true;
                    delay_warm_up.value = true;
                end
                %%% algorithm
                if value(delay_dur) >= value(delay_max) && value(violation_rate) < 0.3 && value(last100trialperf) > 0.7
                    stage_number.value = 7;
                    n_trials_stage.value = 0;
                    n_days_stage.value = 1;
                end 

            case 7
                stage_description.value = 'delay with discrete values';

            case 8
                stage_description.value = 'add stimuli';

            end % End JB_cpoke_fix stage_number

        end % end switch value(curriculum)
    
    %---------------------------------------------------------------%
    %          implement_helper                                     %
    %---------------------------------------------------------------%
    case 'implement_helper'
        % This cased is called if helper is on. Allows you to check 
        % animal performance (hit and/or violation rate) to determine if
        % animal should get a specififed number of easier trials. 
        % Trials can be modulated by reward (give vs. poke), error
        % (temp error on vs. off) or both. Once helper trials are up, will
        % switch back to original curriculum. This function does not
        % change the stage the animal is in, but helper trials are tracked
        % in the history section
        %
        % NOTE: currently no logic determining how many trials between
        % helper blocks, only the maximum number of blocks

        helper_type = varargin{1};

        %%% If not already in helper block, check if performance qualifies
        %%% and if so switch to helper block based on helper_type
        if strcmp(value(in_helper_block), 'FALSE')
            % Check hit performance
            if value(hit_helper)
                % grab performance metric from historysection
                hit_performance = value(eval(['Last' helper_trials_back 'TrialPerf']));
                if hit_performance < value(helper_hit_threshold)
                    hit_setback = 1; % reched threshold
                else
                    hit_setback = -1; % haven't reached threshold
                end
            else
                hit_setback = 0; % hit based helper is not on, ingore
            end
            % Check violation performance
            if value(violation_helper)
                % grab performance metric from historysection
                violation_performance = value(eval(['Last' helper_trials_back 'TrialViol']));
                if violation_performance < value(helper_violation_threshold)
                    violation_setback = 1; % reached threshold
                else
                    violation_setback = -1; % haven't reached threshold
                end
            else
                violation_setback = 0; % violation based helper is not on, ignore
            end
            % Turn on helper if threshold(s) hit
            if (hit_setback + violation_setback) > 0
                in_helper_block.value = 'TRUE';
                helper_trial_counter.value = value(helper_trials_give);
                
                % set values based on helper_type
                switch value(helper_type)
                case 'reward'
                    reward_type.value        = 'give';
                case 'error'
                    temp_error_penalty.value = true;
                    retry_type.value         = 'single';
                case 'both'
                    reward_type.value        = 'give';
                    temp_error_penalty.value = true;
                    retry_type.value         = 'single';
                otherwise
                    error('helper type unknown! cannot switch into helper block');
                end
            end 
        %%% If we are already in a helper block, check if we need to switch
        %%% back out of it
        elseif strcmp(value(in_helper_block), 'TRUE')
            helper_trial_counter.value = value(helper_trial_counter) - 1;
            if value(helper_trial_counter) == 0
                in_helper_block.value = 'FALSE';
                helper_block_counter.value = value(helper_block_counter) + 1;

                % set values based on helper_type
                switch value(helper_type)
                case 'reward'
                    reward_type.value        = 'poke';
                case 'error'
                    temp_error_penalty.value = false;
                    retry_type.value         = 'N/A';
                case 'both'
                    reward_type.value        = 'poke';
                    temp_error_penalty.value = false;
                    retry_type.value         = 'N/A';
                otherwise
                    error('helper type unknown! cannot switch out of helper block');
                end
            end 
        end

    %---------------------------------------------------------------%
    %          end_session                                          %
    %---------------------------------------------------------------%

    case 'end_session'
        % update history of stage
        n_days_stage.value = value(n_days_stage) + 1;
        n_days_training.value = value(n_days_training) + 1;

        % clean up helper if ended in block
        helper_block_counter.value = 0;
        helper_trial_counter.value = 0;
        in_helper_block.value = 'FALSE';
      
        % how to implement EOD stage logic
        %         if(value(stage_switch_auto)==1)
        %             
        %             feval(mfilename, obj, 'increment_stage'); 
        % 
        %         end

    otherwise
        warning('DMS/TrainingSection - Unknown action: %s\n', action);


end
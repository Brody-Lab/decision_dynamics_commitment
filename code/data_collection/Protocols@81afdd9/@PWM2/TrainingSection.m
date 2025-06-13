% Training Section
% Initial draft by JRB 2022-05
% Modifications and improvements by JRB/JY throughout 2022.
%
% This section replaces and improves on the functionality of the @sessionmodel
% plugin (aka Session Definition). Like with the @sessionmodel plugin, it allows
% users to specify a set of sequential training stages and their appropriate
% parameters, as well as logic for automatically switching between stages based
% on performance. Unlike @sessionmodel, TrainingSection.m allows for easy on-the-fly
% switching between different training curricula, using a simple MenuParam, and
% allows the user to turn automated stage incrementing on or off.
% 
% Inspiration: TrainingSection from TaskSwitch6
% 
% Case Info:
%       init : this is where all the gui information is initated
%
%       update_stage_button: if manual update of stage occurs, and button is pressed will reboot history
%                            and then call update_stage
%
%       get_curriculum_update: does all the work to figure out which stage/trial type the animal will be getting given
%                     the stage number and curriculum written
%
%       end_session: adds a day to the days in stage
%                    TODO: have check EOD logic for moving to new stage
%    
% TODO: Implement helper stage switching logic

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
        NumeditParam(obj, 'helper_violation_threshold',0.50, x, y,'labelfraction',0.65,...
            'TooltipString', 'violation rate to trigger a subset of eaiser trials',...
            'label', 'viol threshold', 'position', [x y 150 20]);
        ToggleParam(obj, 'violation_helper', 0, x, y, 'position', [x+150 y 50 20], ...
            'OffString', 'OFF', 'OnString',  'ON', ...
            'TooltipString', 'If on, & helper on will be used a threshold for setting animal back');
        next_row(y, 1);
        
        %%% hit threshold & toggle for helper
        NumeditParam(obj, 'helper_hit_threshold',0.5, x, y,'labelfraction',0.65,...
            'TooltipString', 'hit rate to trigger a subset of eaiser trials',...
            'label', 'hit threshold', 'position', [x y 150 20]);
        ToggleParam(obj, 'hit_helper', 0, x, y, 'position', [x+150 y 50 20], ...
            'OffString', 'OFF', 'OnString',  'ON', ...
            'TooltipString', 'If on, & helper on will be used a threshold for setting animal back');
        next_row(y, 1);
        
        
        % n_trials back to look at & n_easy trials to give if helper is on
        NumeditParam(obj, 'helper_trials_back',25, x, y,'labelfraction',0.5,...
            'TooltipString', 'number trials back to look at to apply threshold',...
            'label', 'back', 'position', [x y 100 20]);
        NumeditParam(obj, 'helper_trials_give',10, x, y,'labelfraction',0.5,...
            'TooltipString', 'number of easier trials to give',...
            'label', 'give', 'position', [x+100 y 100 20]);
        next_row(y, 1);

        %%% helper: performance based logic to temporarily move animal back
        %%% to previous, easier stage
        ToggleParam(obj, 'helper', 0, x, y, 'position', [x y 100 20], ...
            'OffString', 'Helper OFF', 'OnString',  'Helper ON', ...
            'TooltipString', 'If on, search over window given thresholds to determine short setback');
        DispParam(obj, 'in_helper_block', 'FALSE', x, y, 'position', [x+100 y 100 20],...
            'label', 'In Block', 'labelfraction', 0.55,...
            'TooltipString', 'Whether the animal is currently in a helper block.');
        next_row(y, 1.5);


        
        %%% Stage history
        NumeditParam(obj, 'n_days_stage',1, x, y, 'labelfraction', 0.55,...
            'label','n days','position', [x y 100 20],...
            'TooltipString', 'number of consecutive days in training stage');
        NumeditParam(obj, 'n_days_training',1, x, y, 'labelfraction', 0.55,...
            'label','total sess.','position', [x+100 y 100 20],...
            'TooltipString', 'number of days/sessions total');
        next_row(y,1);
       
        DispParam(obj, 'n_trials_stage',0, x, y, 'labelfraction', 0.55,...
            'label','n trials','position', [x y 100 20],...
            'TooltipString', 'number of trials done in stage in a session');
        %%% Auto stage switch upon completion logic
        ToggleParam(obj, 'stage_switch_auto', 1, x, y, 'position', [x+100 y 100 20], ...
            'OffString', 'Autotrain OFF', 'OnString',  'Autotrain ON', ...
            'TooltipString', 'If on, switches automatically between training stages');

        next_row(y, 6); % Provide enough space for curriculum and stage stuff

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Curriculum. Used to specify training stages. %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        SubheaderParam(obj, 'title', mfilename, x, y); next_row(y, -1);
        MenuParam(obj, 'curriculum', {'JY_spoke_fix',  ...
                                      'JY_grow_np_go', ... 
                                      'PWM_classical', ...
                                      'LG_GNP_snds',   ...
                                      'classicv2_full',...
                                      'LGS_v2'},...
            2, x, y, 'position', [x y 200 20], 'label', 'Curriculum',...
            'labelfraction', 0.35, 'TooltipString', 'The current curriculum.');
        next_row(y, -1);
        DispParam(obj, 'curriculum_description', 'Curriculum description',...
            x, y, 'label', '', 'position', [x y 200 20], 'labelfraction', 0.01,...
            'TooltipString', 'Description of the current curriculum.');
        next_row(y, -1.8);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Generate list of training stages. %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        SoloParamHandle(obj, 'stage_list', 'value', {});
        SoloParamHandle(obj, 'stage_name', 'value', '');
        % Mirrors the value of stage_name, but is not subject to frequent
        % deletion and reinstantiation.
        SoloParamHandle(obj, 'stage_name_persist', 'value', '');

        % Set the default stage list and callback
        MenuParam(obj, 'stage_number', {'1','2','3','4','5','6','7','8','9','10','11','12'},...
            1, x, y, 'position', [x y 40 35], 'label', '', 'labelfraction', 0.1,...
            'TooltipString', 'Current stage');
        set_callback(stage_number, {mfilename, 'stage_number_callback'});
        SoloParamHandle(obj, 'x_stage_name', 'value', x);
        SoloParamHandle(obj, 'y_stage_name', 'value', y);
        set_callback(curriculum, {mfilename, 'set_stage_list', value(x_stage_name), value(y_stage_name)});

        next_row(y, -1.1);
        DispParam(obj, 'stage_description', 'Stage description', x, y, 'label',...
            '', 'position', [x y 200 35], 'labelfraction', 0.01, 'TooltipString',...
            'Description of the current stage.');
        next_row(y, 2.4);

        %%% Send out vars
        SoloFunctionAddVars('HistorySection', 'ro_args',...
            {'stage_name', 'curriculum', 'stage_number', 'stage_name_persist'});         
        SoloFunctionAddVars('HistorySection', 'rw_args', ...
            {'n_trials_stage', 'n_days_stage', 'n_days_training'});
        SoloFunctionAddVars('ShapingSection', 'ro_args',...
            {'n_trials_stage', 'n_days_stage', 'n_days_training'});

        % Send out vars to individual curriculum files
        training_section_vars = {'n_trials_stage', 'n_days_stage', 'n_days_training', 'stage_number',...
            'stage_name_persist', 'stage_description', 'stage_list', 'curriculum_description',...
            'stage_switch_auto', 'in_helper_block', 'helper', 'helper_hit_threshold', 'helper_trials_back',...
            'hit_helper', 'violation_helper', 'helper_violation_threshold'};
        SoloFunctionAddVars('TS_JY_spoke_fix',   'rw_args', training_section_vars);
        SoloFunctionAddVars('TS_JY_rulefirst',   'rw_args', training_section_vars);
        SoloFunctionAddVars('TS_PWM_classical',  'rw_args', training_section_vars);
        SoloFunctionAddVars('TS_LG_GNP_snds',    'rw_args', training_section_vars);
        SoloFunctionAddVars('TS_classicv2_full', 'rw_args', training_section_vars);
        SoloFunctionAddVars('TS_LGS_v2',         'rw_args', training_section_vars);


        DeclareGlobals(obj, 'ro_args', {'stage_name', 'stage_number', 'stage_name_persist'});

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Set appropriate initial values, toggles, etc for this stage. %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        TrainingSection(obj, 'set_stage_list', value(x_stage_name), value(y_stage_name));


    %---------------------------------------------------------------%
    %          set_stage_list                                       %
    %---------------------------------------------------------------%
    case 'set_stage_list' % TODO change to curriculum_callback
        % Generates the appropriate stage list from the current curriculum, and
        % constructs the stage_name MenuParam to allow the user to select stages.
        % We set stage_number, stage_name, stage_name_persist, and pervious_stage
        % to default values (i.e., the first stage).
        x = varargin{1};
        y = varargin{2};
        switch value(curriculum)
        case 'JB_cpoke_fix'
            stage_list.value = TS_JB_cpoke_fix(obj, 'get_stage_list');

        case 'JY_spoke_fix'
            stage_list.value = TS_JY_spoke_fix(obj, 'get_stage_list');

        case 'JY_grow_np_go'
            stage_list.value = TS_JY_rulefirst(obj, 'get_stage_list');

        case 'PWM_classical'
            stage_list.value = TS_PWM_classical(obj, 'get_stage_list');

        case 'LG_GNP_snds'
            stage_list.value = TS_LG_GNP_snds(obj, 'get_stage_list');

        case 'classicv2_full'
            stage_list.value = TS_classicv2_full(obj, 'get_stage_list');

        case 'LGS_v2'
            stage_list.value = TS_LGS_v2(obj, 'get_stage_list');

        end
        MenuParam(obj, 'stage_name', value(stage_list), value(stage_number),...
            x, y, 'label', 'Stage', 'position', [x+40 y 160 35], 'labelfraction',...
            0.35, 'TooltipString', 'The current training stage.\nFor display purposes only.');
        stage_name_persist.value = value(stage_name);
        previous_stage.value = value(stage_name);
        % Update protocol parameters for new curriculum
        TrainingSection(obj, 'get_curriculum_update');


    %---------------------------------------------------------------%
    %          stage_number_callback                                %
    %---------------------------------------------------------------%
    case 'stage_number_callback'
        fprintf('************************* stage_number_callback called!\n');
        % set to highest defined stage if user selected one out of range
        if value(stage_number) > length(value(stage_list))
            stage_number.value = length(value(stage_list));
        end
        % update counters
        n_trials_stage.value = 0;
        % Only set n_days_stage back to 1 if we're modifying stage number while running.
        % TODO: Modify so that it resets if we change stage_number before we start running,
        %       but does not trigger if we're loading.
        if n_done_trials ~= 0
            n_days_stage.value = 1;
        end
        % update the stage name to reflect new stage
        previous_stage.value = value(stage_name_persist);
        stage_name.value = stage_list{value(stage_number)};
        stage_name_persist.value = stage_list{value(stage_number)};
        % set stage-specific settings
        TrainingSection(obj, 'get_curriculum_update');


    %---------------------------------------------------------------%
    %          increment_stage                                      %
    %---------------------------------------------------------------%
    case 'increment_stage'
        %%% Note that increment_stage only occurs if we have the auto stage
        %%% switching toggle on. 
        if value(stage_switch_auto) && value(stage_number) < length(value(stage_list))
            fprintf('****** Current stage number: %i\n', value(stage_number));
            previous_stage.value = value(stage_name_persist);
            stage_number.value = value(stage_number) + 1;
            stage_name.value = stage_list{value(stage_number)};   %% has a callback
            n_trials_stage.value = 0;
            n_days_stage.value = 1;
            TrainingSection(obj, 'get_curriculum_update');
            fprintf('****** Updated stage number: %i\n', value(stage_number));
        else
            fprintf('******** Stage %s\n******** completed, but auto switch is off.',...
                value(stage_name));
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
        % TODO Helper logic
        % % check to see if helper needs to be turned on given
        % % performance & toggle
        % if value(helper)
        %     TrainingSection(obj, 'implement_helper', value(helper_tyle));
        % end
   
    %---------------------------------------------------------------%
    %          get_curriculum_update                                %
    %---------------------------------------------------------------%
    case 'get_curriculum_update'
        fprintf('************************* get_curriculum_update called!\n');
        % This function gets called on every trial. It handles the setting of
        % stage-specific variable values, performs end-of-stage checks to
        % automatically move the animal into the next stage, and implements
        % helper logic (providing easier trials when performance flounders).

        %%% Set parameters across sections for the curriculum/training stage
        switch value(curriculum)

        case 'JY_spoke_fix'
            TS_JY_spoke_fix(obj, 'get_curriculum_update', value(stage_number));

        case 'JY_grow_np_go'
            TS_JY_rulefirst(obj, 'get_curriculum_update', value(stage_number));

        case 'PWM_classical'
            TS_PWM_classical(obj, 'get_curriculum_update', value(stage_number));

        case 'LG_GNP_snds'
            TS_LG_GNP_snds(obj, 'get_curriculum_update', value(stage_number));

        case 'classicv2_full'
            TS_classicv2_full(obj, 'get_curriculum_update', value(stage_number));

        case 'LGS_v2'
            TS_LGS_v2(obj, 'get_curriculum_update', value(stage_number));

        end


    case 'end_session'
        % NB: Can potentially switch stages here too, at the
        %     end of the day.
        n_days_stage.value = value(n_days_stage) + 1;
        n_days_training.value = value(n_days_training) + 1;
        
        
    case 'get'
        val = varargin{1};
        eval(['x=value(' val ');']);


    otherwise
        warning('PWM2/TrainingSection - Unknown action: %s\n', action);

    end

end

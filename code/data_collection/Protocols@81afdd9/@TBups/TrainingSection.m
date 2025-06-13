
%% TrainingSection.m
%
% Function that replaces SessionDefinition in Bcontrol. Creates GUI
% interface to switch between multiple curricula (each their own .m file)
% and stages within. Allows animals to run from common file that can be
% easily tracked on git.
% 
% Copied from Jess in FixationGrower and modified to remove additional variables in July 2024
%
% Case Info:
%       init : 
%           where all internal and gui variables are created
%    
%       get_curriculum_stage_list :
%           Callback to curriculum variable. Given the slected curriculum,
%           will call 'get_stage_list' and return the appropriate menuparm
%           for the stage_name variable in the main DMS2 window that
%           contains all the stage info for the curriculum. Then calls
%           'get_curriculum_update' given the selected stage_number.
% 
%       update_stage_info :
%           Callback to stage_number variable. Given the selected stage_
%           number (within a curriculum), this will update all the
%           variables defined in that stage_number via 'get_curriculum_update' 
%           and update the stage_name menu item to match the satge_number. 
%       
%       increment_stage : 
%           When end of stage logic is hit in curriculum stage number and
%           autotrain is on, this will update to the next stage. Will reset
%           the stage specific history variables (e.g. n_days_stage) upon
%           stage switch and call get_curriculum_update to update stage
%           variables.
%
%           The next stage can be passed as an argument, or assumed to be 
%           the next numerical stage. 
%           
%           Example call from stage 4:
%               TrainingSection(obj, 'increment_stage'); % goes to stage 5
%               TrainingSection(obj, 'increment_stage', 3); % goes to stage 3
%       
%       prepare_next_trial : 
%           On every trial, calls 'get_curriculum_update' and tracks the
%           number of trials in stage. 
% 
%       get_curriculum_update :
%           Given a selected curriculum, calls 'get_update' to update any
%           variables specific to that stage/trial count/previous result/etc.
%           This is the workhorse of TrainingSection and the 'get_update'
%           case for a specific curriculum will read like a
%           SessionDefintion file (but better!).
%       
%       implement_helper : (NOT IN USE)
%           The idea behind this case is to have a paramerterized way of
%           giving animals a set of easier trials if performance in a
%           previous window is poor. The type of easy trial is up to the
%           user. For example, you could turn on water give for 10 trials,
%           or turn off delay growth for 50 trials. 
%
%           It's not currently in use because there is still a lot of fine
%           tuning that needs to be done in this protocol before automated
%           setbacks can happen. Keeping it here for future user.
% 
%       end_session: 
%           Tracks the number of days in a stage & training. One could also
%           add End of Day (EOD) logic here. But as currently written,
%           stage switch logic happens within a session (like a completion
%           string in SessionDefinition).
%

function [x, y] = TrainingSection(obj, action, varargin)

    GetSoloFunctionArgs(obj);
    
    switch action,
    
        % ------------------------------------------------------------------
        %              INIT
        % ------------------------------------------------------------------
    
        case 'init'
            x=varargin{1};
            y=varargin{2};
            
    
            %% STAGE & CURRICULA INFORMATION
            %%% --- TRAINING HISTORY VARS SUBWINDOW START ---
            % create window & build from bottom up
            ToggleParam(obj, 'train_history_vars', 0, x,y, 'position', [x y 200 20],...
                'OnString', 'Train History Vars Showing',...
                'OffString', 'Train History Vars Hidden', 'TooltipString', 'Show/hide train history vars info');
            set_callback(train_history_vars, {mfilename, 'show_hide_train_history_vars_window'});
            oldx=x; oldy=y; parentfig=double(gcf);
            
            SoloParamHandle(obj, 'train_history_vars_window', 'value',...
                figure('Position', [750 600 400 300],...
                       'MenuBar', 'none',...
                       'Name', 'Train History Vars',...
                       'NumberTitle', 'off',...
                       'CloseRequestFcn', [mfilename '(' class(obj) ', ''hide_train_history_vars_window'');']));
            set(gcf, 'Visible', 'off');
            x=5;y=5;
           
            
    
            % Type of block swtich
            MenuParam(obj, 'block_switch_type', {'static'; 'sampled';'none';},...
                1, x, y, 'position', [x y 200 20], 'label', 'blk switch type',...
                'labelfraction', 0.5,...
                'TooltipString', sprintf(['\ntype of block switch that will be used',...
                                '\nif block switch is on ',...
                                '\nif static, uses block_size to swtich, if sampled',... 
                                '\nblock_size is sampled from blk_size_gauss distribui',...
                                '\n**assuming** logic is implmented in curriculum file']));
                            
            % DistribUI for block size
            DistribInterface(obj, 'add', 'blk_size_gaus', x+(105*2), y, 'Style', ...
                'gaussian', 'Mu', 15, 'Sd', 2, 'Min', 5, 'Max', 25);
            next_row(y,1);       
            
            DispParam(obj, 'n_blocks',1, x, y, 'labelfraction', 0.55,...
                'label','n blks','position', [x y 100 20],...
                'save_with_settings', 1,...
                'TooltipString', 'number of blocks in a session');
            DispParam(obj, 'n_trials_in_block',0, x, y, 'labelfraction', 0.55,...
                'label','blk trials','position', [x+100 y 100 20],...
                'save_with_settings', 1,...
                'TooltipString', 'number of trial in a block');
           next_row(y,1);
           
            % curriculum vars in GUI (primarily used for spoke only stages) 
            ToggleParam(obj, 'was_block_switch', 0, x, y, 'position', [x y 200 20],...
                'OnString', 'was block switch',...
                'OffString', 'was not block switch',...
                'TooltipString', 'If in a left block of trials');
            
            next_row(y,1);
            ToggleParam(obj, 'in_left_block', 0, x, y, 'position', [x y 100 20],...
                'OnString', 'In L Blk',...
                'OffString', 'Not In L Blk',...
                'TooltipString', 'If in a left block of trials');        
            ToggleParam(obj, 'in_right_block', 0, x, y, 'position', [x+100 y 100 20],...
                'OnString', 'In R Blk',...
                'OffString', 'Not In R Blk',...
                'TooltipString', 'If in a right block of trials');
            next_row(y,1);
            NumeditParam(obj, 'max_blocks',5, x, y,'labelfraction',0.65,...
                'TooltipString', 'not currently in use, another metric for determiining when blocks end',...
                'label', 'max blks', 'position', [x y 100 20]);   
            next_row(y,1);
            % DB 3 -> 15?
            NumeditParam(obj, 'block_size', 15, x, y, 'labelfraction',0.5,...
                'TooltipString', 'number of trials in a block',...
                'label', 'blk size', 'position', [x y 100 20]);
            % DB 15 -> 80
            NumeditParam(obj, 'blocks_end', 70, x, y, 'labelfraction',0.5,...
                'TooltipString', 'number of trials in stage where blocks turn off',...
                'label', 'blk end', 'position', [x+100 y 100 20]);
            next_row(y,1);
            % DB
            
            ToggleParam(obj, 'right_poke_stage_complete', 0, x, y, 'position', [x y 200 20],...
                'OnString', 'Right poke stg Complete',...
                'OffString', 'Right poke stg NOT Complete',...
                'TooltipString', 'If EOS logic was hit for right poke only stage for a given animal');
            next_row(y,1);
            ToggleParam(obj, 'left_poke_stage_complete', 0, x, y, 'position', [x y 200 20],...
                'OnString', 'Left poke stg Complete',...
                'OffString', 'Left poke stg NOT Complete',...
                'TooltipString', 'If EOS logic was hit for left poke only for a given animal');
            next_row(y,1);
                ToggleParam(obj, 'auto_advance_spoke_to_cpoke', 0, x, y, 'position', [x y 200 20],...
                'OnString', 'Auto Spoke --> Cpoke ON',...
                'OffString', 'Auto Spoke --> Cpoke OFF',...
                'TooltipString', sprintf(['\nIf on, animal will automatically move from',...
                                        '\nspoke starter into a cpoke stage in the next curriculum',...
                                        '\nas opposed to moving into an identical spoke stage in the',...
                                        '\ncpoke curriculum and waiting for manual adjument to a cpoke stage']));
            next_row(y,1);
            SubheaderParam(obj,'lab1', 'Spoke TS Params',x,y,'position', [x+10 y 180 20]);
           
            
            % back to main window
            x=oldx; y=oldy; figure(parentfig);
            %%% --- TRAINING HISTORY VARS SUBWINDOW END ---
    
            %%% Stage history
            next_row(y,1);
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
                'TooltipString', sprintf(['\nIf on, switches automatically between training',... 
                                'stages via increment_stage assuming end of stage logic is',...
                                'written in .m file for the selected curriculum & stage']));
            
            % big jump up and building from the top down
            % save coords to be able to build ontop of this section in GUI
            next_row(y, 8);
            topx = x; topy=y; 
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Curriculum. Used to specify training stages. %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % active_curricula is located in TBups.m init
            SubheaderParam(obj, 'title', mfilename, x, y); next_row(y, -1);
            MenuParam(obj, 'curriculum', value(active_curricula),...
                1, x, y, 'position', [x y 200 20], 'label', 'Curriculum',...
                'labelfraction', 0.35, 'TooltipString', 'The current curriculum.');
            next_row(y, -1);
            DispParam(obj, 'curriculum_description', 'Curriculum description',...
                x, y, 'label', '', 'position', [x y 200 20], 'labelfraction', 0.01,...
                'TooltipString', 'Description of the current curriculum.');
            DeclareGlobals(obj, 'ro_args', {'curriculum'});
            next_row(y, -2);
    
    
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Generate list of training stages. %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % %% Stage info (internal)
            SoloParamHandle(obj, 'stage_list', 'value', {});
            SoloParamHandle(obj, 'stage_name', 'value', '');
            SoloParamHandle(obj, 'previous_stage', 'value', '');
            
            % persits mirrors stage name, but not reinstantiated each trial
            SoloParamHandle(obj, 'stage_name_persist', 'value', '');
            
            %%% Stage info (GUI)
            MenuParam(obj, 'stage_number', {'1','2','3','4','5','6','7','8','9','10','11',...
                                             '12', '13', '14', '15', '16', '17'},...
                1, x, y, 'position', [x y 40 35], 'label', '', 'labelfraction', 0.1,...
                'TooltipString', sprintf(['given selected curriculum, what stage',...
                                '\nthe animal is currently in. This is also how you',...
                                '\nmanually switch stages']));
            % called stage_number_callback in PWM2
            set_callback(stage_number, {mfilename, 'update_stage_info'});
            
            
            % GUI locations for stage name param because the menuparam needs to
            % change depending on the curricula selected (stages are different)
            % set_stage_list makes this menuparam
            SoloParamHandle(obj, 'x_stage_name', 'value', x);
            SoloParamHandle(obj, 'y_stage_name', 'value', y);
            % called set_stage_list in PWM2
            set_callback(curriculum, {mfilename, 'get_curriculum_stage_list', value(x_stage_name), value(y_stage_name)});
            next_row(y, -1.7);
            
            % Describe the given curriculums stage
            DispParam(obj, 'stage_description', 'Stage description', x, y, 'label',...
                '', 'position', [x y-5 200 35], 'labelfraction', 0.01, 'TooltipString',...
                'Description of the current stage.');
    
            %% SEND OUT VARIABLES
            SoloFunctionAddVars('HistorySection', 'ro_args',...
              {'stage_name', 'curriculum', 'stage_number',...
              'stage_name_persist', 'block_switch_type',...
              'auto_advance_spoke_to_cpoke'});
            SoloFunctionAddVars('HistorySection', 'rw_args',...
                {'n_trials_stage', 'n_days_stage', 'n_days_training'}); 
            SoloFunctionAddVars('ShapingSection', 'ro_args',...
              {'n_trials_stage', 'n_days_stage', 'n_days_training'});

            SoloFunctionAddVars('SidesSection', 'ro_args', {'stage_name',...
                'stage_number', 'stage_name_persist', 'was_block_switch',...
                'block_switch_type', 'auto_advance_spoke_to_cpoke', ...
                'in_left_block', 'left_poke_stage_complete',...
                'in_right_block', 'right_poke_stage_complete'});
            DeclareGlobals(obj, 'ro_args', {...
                'stage_name', 'stage_number', 'stage_name_persist',...
                'was_block_switch', 'block_size', 'block_switch_type',...
                'n_trials_in_block'});
            
            % Send out vars to individual curriculum files for any of the
            % curricula listed as active
            training_section_send_out_vars = get_name(get_sphandle('owner', '@TBups', 'funcowner', 'TrainingSection'));
            for i = 1:numel(value(active_curricula))
                % Construct the function call with the updated curriculum name
                current_curricula = value(active_curricula{i});
                function_call = sprintf("SoloFunctionAddVars('TS_%s', 'rw_args', training_section_send_out_vars);", current_curricula );
                eval(function_call);
            end
    
            %% INITALIZES STAGE INFO GIVEN LOAD
            % Set appropriate initial values, toggles, etc for this curriculum/stage
            TrainingSection(obj, 'get_curriculum_stage_list', value(x_stage_name), value(y_stage_name));
            TrainingSection(obj, 'get_curriculum_update');
            x = topx; y=topy;
    
        %---------------------------------------------------------------%
        %          get_curriculum_stage_list                            %
        %---------------------------------------------------------------%
        case 'get_curriculum_stage_list'
            % Loads the appropriate stage list from the current curriculum, and
            % constructs the stage_name MenuParam to allow the user to view
            % stage numbers and names.
            
            disp('running get_curriculum_stage_list !!!!!!!!!!!!!!!!!!!!');
            x = varargin{1};
            y = varargin{2};
            
            % evelcualte 'get_stage_list' case for the current curriculum
            function_call = sprintf("TS_%s(obj, 'get_stage_list')", value(curriculum));
            stage_list.value = eval(function_call);
            
            % create menu param
            MenuParam(obj, 'stage_name', value(stage_list), value(stage_number),...
                x, y, 'label', 'Stage', 'position', [x+40 y 160 35],...
                'labelfraction', 0.35,...
                'TooltipString', sprintf(['FOR DISPLAY ONLY use this for context',...
                                          '\nfor picking your next stage number',...
                                          '\ncontains stage name for all stages in curricula']));
            
            % update internal vars
            stage_name_persist.value = value(stage_name);
            previous_stage.value = value(stage_name);
            
            % update variables given curricula
            TrainingSection(obj, 'get_curriculum_update');
        
        %---------------------------------------------------------------%
        %          update_stage_info                                    %
        %---------------------------------------------------------------%
        case 'update_stage_info'
            % Callback that is triggered when the stage_number menu param is
            % changed. Will take the selected stage number and the currently
            % selected curricula to update (1) all the variables defined in the
            % curricula's selected stage number (2) the selected value in
            % stage_name for visual purposes.
    
            fprintf('************************* update_stage_info callback called!\n');
    
            % set to highest defined stage if user selected one out of range
            if value(stage_number) > length(value(stage_list))
                  stage_number.value = length(value(stage_list));
                warning('stage is out of range for this curricula!');
            end
    
            % update counters
            n_trials_stage.value = 0;
                % Only set n_days_stage back to 1 if we're modifying stage number while running.
                % TODO: Modify so that it resets if we change stage_number before we start running,
                %       but does not trigger if we're loading.
            if n_done_trials ~= 0
                n_days_stage.value = 1;
            end
            
            % update the internal tracking vars
            previous_stage.value = value(stage_name_persist);
            stage_name.value = stage_list{value(stage_number)};
            stage_name_persist.value = stage_list{value(stage_number)};
            
            % set stage-specific settings for the selected curricula
            TrainingSection(obj, 'get_curriculum_update');
        
    
        %---------------------------------------------------------------%
        %          increment_stage                                      %
        %---------------------------------------------------------------%   
        case 'increment_stage'        
            % Move into next stage if auto train was on (this is the case that
            % does end of stage or day logic)
            %   input (optional): stage (num) to switch to, Otherwise will move
            %                     to the next numerical stage (e.g. 4 -> 5)
            
            if value(stage_switch_auto)
                fprintf('****** Current stage number: %i\n', value(stage_number));
                
                % save previous stage string
                previous_stage.value = value(stage_name_persist);
                
                % move to a specified stage if specified by the case call,
                % otherwise just move to the next numerical stage
                if length(varargin) == 1 
                    next_stage = varargin{1};
                    stage_number.value = next_stage;  
                else
                    % move up if you're not in the last stage
                    if value(stage_number) < length(value(stage_list)) 
                        stage_number.value = value(stage_number) + 1;  
                    end
                end 
                
                % update stage name strings
                stage_name.value = stage_list{value(stage_number)};
                stage_name_persist.value = value(stage_name); % might not need?
                
                % update counters
                n_trials_stage.value = 0;
                n_days_stage.value = 1;
                
                % get new curriculum presets for stage
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
            
            %TODO add in the callback for the block type
    
    
        %---------------------------------------------------------------%
        %          get_curriculum_update                                %
        %---------------------------------------------------------------%
        case 'get_curriculum_update'
            %%% Set parameters across sections for the curriculum/training stage
            
            % evaluate 'get_update' case for the current curriculum given the
            % current stage number
            function_call = sprintf("TS_%s(obj, 'get_update', value(stage_number))", value(curriculum));
            eval(function_call);
    
    
        %---------------------------------------------------------------%
        %          get_curriculum_eod_logic                             %
        %---------------------------------------------------------------%
        case 'get_curriculum_eod_logic'
            
            % Evaluate eod logic given current curriculum and stage
            function_call = sprintf("TS_%s(obj, 'get_eod_logic', value(stage_number))", value(curriculum));
            eval(function_call);
    
        %---------------------------------------------------------------%
        %          end_session                                          %
        %---------------------------------------------------------------%
    
        case 'end_session'
            % update history of stage
            n_days_stage.value = value(n_days_stage) + 1;
            n_days_training.value = value(n_days_training) + 1;
    
            TrainingSection(obj, 'get_curriculum_eod_logic');
    
        %---------------------------------------------------------------%
        %          show/hide/close                                      %
        %---------------------------------------------------------------%
    
        case 'show_hide_train_history_vars_window'
            if train_history_vars == 0, set(value(train_history_vars_window), 'Visible', 'off');
            else                        set(value(train_history_vars_window), 'Visible', 'on');
            end
        case 'hide_train_history_vars_window'
            set(value(train_history_vars_window), 'Visible', 'off'); train_history_vars.value = 0;
        case 'close'
            delete(value(train_history_vars_window));
       
    
        otherwise
            warning('TBups/TrainingSection - Unknown action: %s\n', action);
    
    
    end
    
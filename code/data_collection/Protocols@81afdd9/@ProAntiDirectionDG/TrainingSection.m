function [x, y] = TrainingSection(obj, action, varargin)


GetSoloFunctionArgs(obj);


switch action
    
    
    % -----------------
    
    case 'init'
        
        x = varargin{1};
        y = varargin{2};
        
        % auto stage switch parameters
        ToggleParam(obj, 'stage_switch_auto', 1, x, y, 'position', [x y 200 20], ...
            'OffString', 'Autotrain OFF', 'OnString', 'Autotrain ON', ...
            'TooltipString','If on, switches automatically between training stages');
        next_row(y,1);
        
        NumeditParam(obj, 'nDays_stage', 1, x, y, 'labelfraction', 0.55, 'label', 'nDays', 'position', [x y 100 20]);
        NumeditParam(obj, 'nTrials_stage', 0, x, y, 'labelfraction', 0.55, 'label', 'nTrials', 'position', [x+100 y 100 20]); next_row(y);
        
        % manually set the stage
        DispParam(obj, 'stage_explanation', sprintf('Stage description'),...
            x, y, 'label','', 'position', [ x y 200 20], 'labelfraction', 0.01, ...
            'TooltipString', 'Description of current stage'); next_row(y);
        
        MenuParam(obj, 'training_stage', {'Stage 1'; 'Stage 2'; 'Stage 3';...
            'Stage 4'; 'Stage 5'; 'Stage 6';'Stage 7'; 'Stage grow NIC'}, 1, x, y,...
            'label', 'Active Stage','TooltipString','the current training stage');
        
        PushbuttonParam(obj, 'update_active_stage', x, y, 'position', [x+170 y 30 20],'label', 'OK');
        set_callback(update_active_stage, {mfilename, 'update_stage_button'});
        next_row(y);
        
        SubheaderParam(obj, 'title', mfilename, x, y);
        next_row(y, 1.5);
        
        SoloFunctionAddVars('HistorySection','ro_args',{'training_stage';'nDays_stage'});
        SoloFunctionAddVars('HistorySection','rw_args', {'nTrials_stage'});
        
        % -------------------
        
        
    case 'next_trial'
        if (n_done_trials>1 && value(stage_switch_auto) ==1)
            feval(mfilename, obj, 'update_stage');
        end
        
        % -------------------
        
        
    case 'update_stage_button'
        
        % reboot stage
        nTrials_stage.value = 0;
        nDays_stage.value = 1;
        previous_stage.value = value(training_stage);
        
        % set parameters
        feval(mfilename, obj, 'update_stage');
        
        
        % -------------------
        
        
    case 'update_stage'
        
        % new stage
        if (~strcmp(value(previous_stage), value(training_stage)))
            nTrials_stage.value = 0;
            nDays_stage.value = 1;
            previous_stage.value = value(training_stage);
        end
        
        
        switch value(training_stage)
            
            case 'Stage 1'
                stage_explanation.value = sprintf('Progressively grow NIC');
                
                % updated only on the first trial
                if (value(nTrials_stage) == 0)
                    ThisTask.value = 'Pro';
                    randomize_first_task.value = 0;
                    task_switch_auto.value = 0;
                    task_switch_min_perf.value = 0.5;
                    
                    gamma_values.value = 4;
                    durations.value = 1.3;
                    nose_in_center.value = 0.05;
                    antibias_type.value = 'Side antibias';
                end
                
                % algorithm to grow NIC
                if (value(nose_in_center) ==  1.3)
                    nose_in_center.value = 1.3;
                    training_stage.value = 'Stage 2';
                    nTrials_stage.value = 0;
                    nDays_stage.value = 1;
                elseif (value(nTrials_stage)>0&& value(nose_in_center)< 1.3 && value(was_hit)==1)
                    nose_in_center.value = value(nose_in_center) + 0.001;
                end
                
            case 'Stage 2'
                stage_explanation.value = sprintf('pro only: wait for good endpoints');
                
                % updated only on the first trial
                if (value(nTrials_stage) == 0)
                    ThisTask.value = 'Pro';
                    randomize_first_task.value = 0;
                    task_switch_auto.value = 0;
                    gamma_values.value = 4;
                    durations.value = 1.3;
                    nose_in_center.value = 1.3;
                    antibias_type.value = 'Side antibias';
                end
                
                % algorithm: wait for good endpoints
                if (n_done_trials>150 && value(nValid)>150 && value(pro_correct)> 0.75...
                        && value(left_correct)>0.7 && value(right_correct)>0.7 ...
                        && value(nDays_stage)>2 && value(nTrials_stage)>150)
                    training_stage.value = 'Stage 3';
                    nTrials_stage.value = 0;
                    nDays_stage.value = 1;
                end
                
                
            case 'Stage 3'
                stage_explanation.value = sprintf('pro and anti: add easy anti trials');
                
                % updated only on the first trial
                if(value(nTrials_stage) == 0)
                    ThisTask.value = 'Pro';
                    randomize_first_task.value = 0;
                    task_switch_auto.value = 1;
                    task_switch_min_perf.value = 0.8;
                    gamma_values.value = 4;
                    durations.value = 1.3;
                    nose_in_center.value = 1.3;
                    antibias_type.value = 'Side antibias';
                    % anti task help paramters
                    helper_lights_anti.value = 1;
                    error_forgiveness_anti.value = 1;
                    wait_delay_anti.value = 0.2;
                end
                
                % algorithm: turn light off, increase wait delay
                if (value(nTrials_stage)>30)
                    helper_lights_anti.value = 0;
                    if (value(wait_delay_anti)<8)
                        if (strcmp(value(ThisTask),'Anti') && value(result) == 5)
                            wait_delay_anti.value = value(wait_delay_anti) + 0.01;
                        end
                    else
                        wait_delay_anti.value = 8;
                        error_forgiveness_anti.value = 0;
                        durations.value = 1.3;
                        training_stage.value = 'Stage 4';
                        nTrials_stage.value = 0;
                        nDays_stage.value = 1;
                    end
                end
                
                
            case 'Stage 4'
                stage_explanation.value = sprintf('pro+anti: train on anti with forgiveness on');
                
                % updated only on the first trial
                if (value(nTrials_stage)==0)
                    ThisTask.value = 'Pro';
                    randomize_first_task.value = 0;
                    task_switch_auto.value = 1;
                    task_switch_min_perf.value = 0.8;
                    gamma_values.value = 4;
                    durations.value = 1.3;
                    nose_in_center.value = 1.3;
                    antibias_type.value = 'Side antibias';
                    % anti task help parameters
                    helper_lights_anti.value = 0;
                    error_forgiveness_anti.value = 1;
                end
                
                % algorithm: wait for good endpoints
                if (n_done_trials> 150 && value(nValid)>150 && value(pro_correct)> 0.7 ...
                        && value(anti_correct)>0.7 && value(left_correct)> 0.7 && value(right_correct)>0.7 ...
                        && value(nDays_stage)>2 && value(nTrials_stage)>150)
                    training_stage.value = 'Stage 5';
                    nTrials_stage.value = 0;
                    nDays_stage.value = 1;
                end
                
                
                case 'Stage 5'
                stage_explanation.value = sprintf('pro+anti: achieve good endpoints');
                
                % updated only on the first trial
                if (value(nTrials_stage)==0)
                    ThisTask.value = 'Pro';
                    randomize_first_task.value = 1;
                    task_switch_auto.value = 1;
                    task_switch_min_perf.value = 0.8;
                    gamma_values.value = 4;
                    durations.value = 1.3;
                    nose_in_center.value = 1.3;
                    antibias_type.value = 'Side antibias';
                    % anti task help parameters
                    helper_lights_anti.value = 0;
                    error_forgiveness_anti.value = 0;
                end
                
                % algorithm: wait for good endpoints
                if (n_done_trials> 150 && value(nValid)>150 && value(pro_correct)> 0.7 ...
                        && value(anti_correct)>0.7 && value(left_correct)> 0.7 && value(right_correct)>0.7 ...
                        && value(nDays_stage)>2 && value(nTrials_stage)>150)
                    training_stage.value = 'Stage 6';
                    nTrials_stage.value = 0;
                    nDays_stage.value = 1;
                end
                
                
            case 'Stage 6'
                stage_explanation.value = sprintf('pro+anti: introduce intermediate hard trials');
                
                % updated only on the first trial
                if (value(nTrials_stage) == 0)
                    ThisTask.value = 'Pro';
                    randomize_first_task.value = 0;
                    task_switch_auto.value = 1;
                    task_switch_min_perf.value = 0.8;
                    gamma_values.value = [2.5 4];
                    durations.value = 1.3;
                    nose_in_center.value = 1.3;
                    antibias_type.value = 'Side antibias';
                    % anti task help parameters
                    helper_lights_anti.value = 0;
                    error_forgiveness_anti.value = 0;
                end
                
                % algorithm: wait for good endpoints
                if (n_done_trials>150 && value(nValid)>150 && value(pro_correct)>0.7...
                        && value(freq_correct)> 0.7 && value(left_correct) > 0.7 && value(right_correct) > 0.7...
                        && value(nDays_stage)>2 && value(nTrials_stage)> 150)
                    training_stage.value = 'Stage 7';
                    nTrials_stage.value = 0;
                    nDays_stage.value = 1;
                end
                
                
            case 'Stage 7'
                stage_explanation.value = sprintf('pro+anti: introduce hardest trials');
                
                % updated only on the first trial
                if (value(nTrials_stage) == 0)
                    ThisTask.value = 'Pro';
                    randomize_first_task.value = 0;
                    task_switch_auto.value = 1;
                    task_switch_min_perf.value = 0.8;
                    gamma_values.value = [1 2.5 4];
                    durations.value = 1.3;
                    nose_in_center.value = 1.3;
                    antibias_type.value = 'Side antibias';
                    % anti task help parameters
                    helper_lights_anti.value = 0;
                    error_forgiveness_anti.value = 0;
                end
                
                
            case 'Stage grow NIC'
                stage_explanation.value = sprintf('progressively frow NIC');
                
                % updated only on the first trial
                if (value(nTrials_stage) == 0)
                    nose_in_center.value = 0.8;
                end
                
                % algorithm: grow NIC
                if (value(nose_in_center)>=1.3)
                    nose_in_center.value = 1.3;
                elseif (value(nTrials_stage)>0 && value(mose_in_center)<1.3 && value(was_hit)==1)
                    nose_in_center.value = value(nose_in_center)+ 0.05;
                end
                
        end
        
        
        % -------------------
        
        
    case 'end_session'
        nDays_stage.value = value(nDays_stage) + 1;
        
        
        % -------------------
        
        
    case 'get'
        val = varargin{1};
        eval(['x = value(' val ');']);
        
    
end
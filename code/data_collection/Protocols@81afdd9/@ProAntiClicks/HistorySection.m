function [x, y] = HistorySection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action
    
    case 'init'
        x = varargin{1};
        y = varargin{2};
        
        %%% info about last trial
        DispParam(obj, 'last_result','', x, y, 'labelfraction', 0.5,'position', [x y 200 20]); next_row(y,1.1);
        
        %%% percent correct left/right
        DispParam(obj, 'left_correct',0, x, y, 'labelfraction', 0.55,'label','%hit left','position', [x y 100 20]);
        DispParam(obj, 'right_correct',0, x, y, 'labelfraction', 0.55,'label','%hit right','position', [x+100 y 100 20]);next_row(y);
        
        %%% percent correct pro/anti
        DispParam(obj, 'pro_correct',0, x, y, 'labelfraction', 0.55,'label','%hit pro','position', [x y 100 20]);
        DispParam(obj, 'anti_correct',0, x, y, 'labelfraction', 0.55,'label','%hit anti','position', [x+100 y 100 20]);next_row(y, 1.1);
        
        %%% percent correct, violations, total trials, valid trials
        DispParam(obj, 'total_correct',0, x, y, 'labelfraction', 0.55,'label','%hit','position', [x y 100 20]);
        DispParam(obj, 'percent_violations',0, x, y, 'labelfraction', 0.55,'label','%viol','position', [x+100 y 100 20]);next_row(y);
        DispParam(obj, 'nTrials',0, x, y, 'labelfraction', 0.55,'position', [x y 100 20]);
        DispParam(obj, 'nValid',0, x, y, 'labelfraction', 0.55,'position', [x+100 y 100 20]);next_row(y);
        
        SubheaderParam(obj, 'title', mfilename,x,y); next_row(y);
        
        
        %%% internal variables %%%
        
        % trial variables
        % binary
        SoloParamHandle(obj, 'was_hit', 'value', 0);
        SoloParamHandle(obj, 'was_err', 'value', 0);
        SoloParamHandle(obj, 'was_nic_err', 'value', 0);
        SoloParamHandle(obj, 'was_timeout', 'value', 0);
        SoloParamHandle(obj, 'was_wait', 'value', 0);
        SoloParamHandle(obj, 'was_block_switch', 'value', 0);
        SoloParamHandle(obj, 'result', 'value', 0);
        
        % history variables
        SoloParamHandle(obj, 'hit_history', 'value', []);
        SoloParamHandle(obj, 'side_history', 'value', []);
        SoloParamHandle(obj, 'task_history', 'value', []);
        SoloParamHandle(obj, 'gamma_history', 'value', []);
        SoloParamHandle(obj, 'result_history', 'value', []);
        
        % history within this block/task
        SoloParamHandle(obj, 'hit_history_task', 'value', []);
        SoloParamHandle(obj, 'previous_task', 'value', []);
        
        % previous training stage
        SoloParamHandle(obj, 'previous_stage', 'value', []);
        
        
        %%% send out variables %%%
        
        % to training section
        SoloFunctionAddVars('TrainingSection', 'ro_args', {'was_hit'; 'was_block_switch';...
            'result';'nValid';'total_correct';'pro_correct';'anti_correct';'left_correct';'right_correct'});
        SoloFunctionAddVars('TrainingSection', 'rw_args', {'previous_stage'});
        
        % to stimulus section
        SoloFunctionAddVars('StimulusSection','ro_args',{'hit_history';'side_history';'task_history';...
            'gamma_history'; 'result'});
        SoloFunctionAddVars('StimulusSection', 'rw_args', {'was_block_switch'});
        
        
        
        
        
    case 'next_trial'
        
        % if it is the first trial, there is no history to save but do initialise stuff
        if(n_done_trials == 0 || isempty(parsed_events) || ~isfield(parsed_events, 'states'))
            previous_stage.value = value(training_stage);
            return;
        end
        
        
        % binary variables about trial result
        if isfield(parsed_events.states, 'hit_state')
            was_hit.value = rows(parsed_events.states.hit_state)>0;
            if (value(was_hit) == 1)
                result.value = 1;
                last_result.value = 'correct';
            end
        end
        if isfield(parsed_events.states,'error_state')
            was_err.value = rows(parsed_events.states.error_state)>0;
            if (value(was_err)==1)
                result.value = 2;
                last_result.value = 'error';
            end
        end
        if isfield(parsed_events.states, 'nic_error_state')
            was_nic_err.value = rows(parsed_events.states.nic_error_state)>0;
            if(value(was_nic_err)==1)
                result.value = 3;
                last_result.value = 'nic_viol';
            end
        end
        if isfield(parsed_events.states, 'timeout_state')
            was_timeout.value = rows(parsed_events.states.timeout_state)>0;
            if(value(was_timeout) == 1)
                result.value = 4;
                last_result.value = 'timeout viol';
            end
        end
        
        % rat got it wrong and then got it right
        if isfield(parsed_events.states, 'delayrew_state')
            was_wait.value = rows(parsed_events.states.delayrew_state)>0;
            % gets it wrong and then gets it right
            if (value(was_wait) == 1 && value(was_timeout) ==0)
                result.value = 5;
                last_result.value = 'forgive->right';
            end
      %      % gets it wrong first and then doesnt get it right
        %    if (value(was_wait) == 1 && value(was_hit) == 0)
         %       result.value = 6;
         %       last_result.value = 'wait->err';
          %  end
        end
        
        
        % history variables %
        res = value(result);
        if (res == 1)
            hit_history.value = [value(hit_history) 1];
            nTrials.value = value(nTrials) + 1;
            nValid.value = value(nValid) + 1;
  %      elseif (res == 2 || res == 5 || res == 6)
        elseif (res == 2 || res == 5)
            hit_history.value = [value(hit_history) 0];
            nTrials.value = value(nTrials) + 1;
            nValid.value = value(nValid) + 1;
        else
            hit_history.value = [value(hit_history) NaN];
            nTrials.value = value(nTrials) + 1;
        end
        
        
        % result history %
        result_history.value = [value(result_history) res];
        
        
        % side history %
        if strcmp(value(ThisSide),'LEFT')
            s = 'l';
        else
            s = 'r';
        end
        side_history.value = [value(side_history) s];
        
        
        % task history %
        if (strcmp(value(ThisTask),'Pro'))
            t = 'p';
        else
            t = 'a';
        end
        task_history.value = [value(task_history) t];
        
        
        % gamma history %
        gamma_history.value = [value(gamma_history) value(ThisGamma)]; % ThisGamma might not be defined
        
        
        
        
        %%% general performances %%%
        
        % save overall percent correct
        vec_hit = value(hit_history);
        total_correct.value = nanmean(vec_hit);
        
        % save NIC violations
        vec_res = value(result_history);
        num_violations = length(find(vec_res == 3));
        num_total = length(vec_res);
        percent_violations.value = num_violations/num_total;
        
        % save left/right percent correct
        vec_side = value(side_history);
        left_correct.value = nanmean(vec_hit(vec_side == 'l'));
        right_correct.value = nanmean(vec_hit(vec_side == 'r'));
        
        % save pro/anti percent correct
        vec_task = value(task_history);
        if length(~isnan(vec_hit(vec_task == 'p'))) > 0
            pro_correct.value = nanmean(vec_hit(vec_task == 'p'));
        else pro_correct.value = 0;
        end
        if length(~isnan(vec_hit(vec_task == 'a'))) > 0
            anti_correct.value = nanmean(vec_hit(vec_task == 'a'));
        else anti_correct.value = 0;
        end
        
        
        
        %%% task performances %%%
        
        % new task?
        if (~strcmp(value(previous_task), value(ThisTask)))
            nTrials_task.value = 1;
            hit_history_task.value = [];
            total_correct_task.value = NaN;
            previous_task.value = value(ThisTask);
        else
            if (res == 1)
                nTrials_task.value = value(nTrials_task) + 1;
                hit_history_task.value = [value(hit_history_task) 1];
            elseif (res == 2 | res == 5)
                nTrials_task.value = value(nTrials_task) + 1;
                hit_history_task.value = [value(hit_history_task) 0];
            else
                hit_history_task.value = [value(hit_history_task) NaN];
            end
            
            
            
            %%% compute performances on the current task block %%%
            
            % total correct
            if value(nTrials_task) > 20
                vec_hit_task = vec_hit(~isnan(vec_hit));
                total_correct_task.value = mean(vec_hit_task(end-19:end));
            else
                total_correct_task.value = NaN;
            end
            
            
            
%             vec_hit_task = value(hit_history_task);
%             vec = vec_hit_task;
%             vec = vec(~isnan(vec));
%             
%             if(length(vec)>20)
%                 total_correct_task.value = nansum(vec(end-19:end))/20;
%             else
%                 total_correct_task.value = NaN;
%             end
            
        end
        
        %%% stage performaces %%%
        
        % new stage?
        if (n_done_trials>1 && ~strcmp(value(previous_stage), value(training_stage)))
            nTrials_stage.value = 0;
            nDays_stage.value = 1;
            nTrials_task.value = 0;
            previous_stage.value = value(training_stage);
        else
            nTrials_stage.value = value(nTrials_stage) + 1;
        end
        
        
    case 'end_session'
        CommentsSection(obj, 'append_line', [value(training_stage) ' ; ']);
        CommentsSection(obj, 'append_line', ['days: ' num2str(value(nDays_stage)) ' ; ']);
        CommentsSection(obj, 'append_line', ['valid: ' num2str(value(nValid)) ' ; ']);
        CommentsSection(obj, 'append_line', ['pro: ' num2str(round(value(pro_correct)*100)/100) ' ; ']);
        CommentsSection(obj, 'append_line', ['anti: ' num2str(round(value(anti_correct)*100)/100) ' ; ']);
        
        
        
    case 'get'
        val = varargin{1};
        eval(['x = value(' val ');']);
        
        
        
    case 'make_and_send_summary'
        pd.hits = value(hit_history);
        pd.sides = value(side_history);
        pd.tasks = value(task_history);
        pd.stage = value(training_stage);
        sendsummary(obj, 'sides', pd.sides, 'protocol_data', pd);
        
        
        
        
        
end
end
function [x, y] = HistorySection(obj, action, varargin)

GetSoloFunctionArgs(obj);


switch action,

    % ------------------------------------------------------------------
    %              INIT
    % ------------------------------------------------------------------

    case 'init'
        x=varargin{1};
        y=varargin{2};


        DispParam(obj, 'last_result',  '', x, y,'label','Last Result');
        next_row(y);

        NumeditParam(obj, 'lastNtrials', 20, x, y, ...
            'TooltipString', 'number of last N trials'); next_row(y);
        DispParam(obj, 'total_correct_lastN', 0.5, x, y, ...
            'label','%hit last N'); next_row(y);
        DispParam(obj, 'correct_incoherent',  0, x, y); next_row(y);
        
        

        DispParam(obj, 'left_correct',0, x, y,'label','%hit left','position', [x y 100 20]);
        DispParam(obj, 'right_correct',0, x, y,'label','%hit right','position', [x+100 y 100 20]);next_row(y);       
        

        
        DispParam(obj, 'percent_violations',  0, x, y); next_row(y);
        DispParam(obj, 'total_correct',  0, x, y,'label','%hit'); next_row(y);
        DispParam(obj, 'nTrials',  0, x, y); next_row(y);

        
        SubheaderParam(obj,'title',mfilename,x,y); next_row(y, 1.5);

        
        

% 
%         temp.result = 0;
%         temp.result = 0;
%         SoloParamHandle(obj, 'last_trial', 'value', temp);
% 


       
        
        
        
        %trial variables
        %binary
        SoloParamHandle(obj, 'was_hit', 'value', 0);
        SoloParamHandle(obj, 'was_err', 'value', 0);
        SoloParamHandle(obj, 'was_nic_err', 'value', 0);
        SoloParamHandle(obj, 'was_timeout', 'value', 0);
        SoloParamHandle(obj, 'was_wait', 'value', 0);
        
        SoloParamHandle(obj, 'result', 'value', 0);
        
        
        %history variables
        SoloParamHandle(obj, 'hit_history', 'value',[]);
        SoloParamHandle(obj, 'violation_history', 'value',[]);
        SoloParamHandle(obj, 'hit_history_left', 'value',[]);
        SoloParamHandle(obj, 'hit_history_right', 'value',[]);
        SoloParamHandle(obj, 'side_history', 'value',[]);        
        SoloParamHandle(obj, 'result_history', 'value',[]);
        SoloParamHandle(obj, 'hit_history_incoherent', 'value',[]);
        
        SoloParamHandle(obj, 'hit_streak', 'value',0);
        
        
        %history task
        SoloParamHandle(obj, 'hit_history_task', 'value',[]);
        SoloParamHandle(obj, 'hit_history_incoherent_task', 'value',[]);
        SoloParamHandle(obj, 'previous_task', 'value',[]);
        
        %history stage
        SoloParamHandle(obj, 'hit_history_stage', 'value',[]);
        SoloParamHandle(obj, 'previous_stage', 'value',[]);
        
        
        
        SoloFunctionAddVars('TrainingSection', 'ro_args',{'was_hit'});        
        SoloFunctionAddVars('TrainingSection', 'rw_args',{'previous_stage';...
            'hit_history_stage'});
        SoloFunctionAddVars('StimulusSection', 'ro_args',{'hit_history';'side_history'});
        SoloFunctionAddVars('RewardSection', 'ro_args',{'hit_history';'side_history'});
        SoloFunctionAddVars('SMA1', 'ro_args',{'hit_streak'});


    case 'next_trial',
        
        if(n_done_trials==0 || isempty(parsed_events) || ~isfield(parsed_events,'states'))
            return;
        end
        
        
        %%%% BINARY VARIABLES ABOUT TRIAL RESULT %%%%
        if isfield(parsed_events.states,'hit_state')
            was_hit.value=rows(parsed_events.states.hit_state)>0;
            if(value(was_hit)==1)
                result.value=1;
                last_result.value='correct';
            end
        end
        if isfield(parsed_events.states,'error_state')
            was_err.value=rows(parsed_events.states.error_state)>0;
            if(value(was_err)==1)
                result.value=2;
                last_result.value='correct';
            end
        end
        if isfield(parsed_events.states,'nic_error_state')
            was_nic_err.value=rows(parsed_events.states.nic_error_state)>0;
            if(value(was_nic_err)==1)
                result.value=3;
                last_result.value='nic_viol';
            end
        end
        if isfield(parsed_events.states,'timeout_state')
            was_timeout.value=rows(parsed_events.states.timeout_state)>0;
            if(value(was_timeout)==1)
                result.value=4;
                last_result.value='timeout viol';
            end
        end
        %%% rat got it wrong and then got it right
        if isfield(parsed_events.states,'wait_state')
            was_wait.value=rows(parsed_events.states.wait_state)>0;
            %gets it wrong first and then gets it right
            if(value(was_wait)==1 && value(was_hit)==1)
                result.value=5; 
                last_result.value='wait->right';
            end
            %gets it wrong first and then doestn't get it right (how?)
            if(value(was_wait)==1 && value(was_hit)==0)
                result.value=6; 
                last_result.value='wait->err';
            end
        end
        
            
        
            
        
        
        %%% HISTORY VARIABLES %%%
        res=value(result);
        if(res==1)
            hit_history.value=[value(hit_history) 1];
            violation_history.value=[value(violation_history) 0];            
            if strcmp(value(ThisSide), 'LEFT'),
                hit_history_left.value=[value(hit_history_left) 1];
                hit_history_right.value=[value(hit_history_right) NaN];
            else
                hit_history_left.value=[value(hit_history_left) NaN];
                hit_history_right.value=[value(hit_history_right) 1];
            end
            if(value(incoherent_trial)==1)
                hit_history_incoherent.value=[value(hit_history_incoherent) 1];
            end
        elseif(res==2 || res==5 || res==6)
            hit_history.value=[value(hit_history) 0];
            violation_history.value=[value(violation_history) 0];           
            if strcmp(value(ThisSide), 'LEFT'),
                hit_history_left.value=[value(hit_history_left) 0];
                hit_history_right.value=[value(hit_history_right) NaN];
            else
                hit_history_left.value=[value(hit_history_left) NaN];
                hit_history_right.value=[value(hit_history_right) 0];
            end
            if(value(incoherent_trial)==1)
                hit_history_incoherent.value=[value(hit_history_incoherent) 0];
            end
        else
            hit_history.value=[value(hit_history) NaN];
            violation_history.value=[value(violation_history) 1];
            hit_history_left.value=[value(hit_history_left) NaN];
            hit_history_right.value=[value(hit_history_right) NaN];
            if(value(incoherent_trial)==1)
                hit_history_incoherent.value=[value(hit_history_incoherent) NaN];
            end
        end
        
        
        %%%% RESULT HISTORY %%%%
        result_history.value=[value(result_history) res];
        
        
        %%%% SIDE HISTORY %%%%
        if strcmp(value(ThisSide), 'LEFT'), 
            s = 'l';
        else
            s = 'r';
        end
        side_history.value=[value(side_history) s];
        
        
        
        
        %%%%%%%% GENERAL PERFORMANCES %%%%%%%%
        
        %n trials
        nTrials.value = value(nTrials) + 1;
        
        %perc correct & percent violations
        
        total_correct.value = nanmean(value(hit_history));
        percent_violations.value = nanmean(value(violation_history));
        left_correct.value = nanmean(value(hit_history_left));
        right_correct.value = nanmean(value(hit_history_right));
        correct_incoherent.value = nanmean(value(hit_history_incoherent));
        
        % perc last N trials
        n=value(lastNtrials);
        if(length(value(hit_history)) >= n)
            vec=value(hit_history);
            total_correct_lastN.value = nanmean(vec(end-n+1:end));
        else
            total_correct_lastN.value = 0;
        end

        %hit streak
        if n_done_trials > 1,
            if (hit_history(end)==1 && hit_history(end-1)==1) 
                hit_streak.value = hit_streak + 1;
            else
                hit_streak.value = 0;
            end;
        else
            hit_streak.value = 0;
        end
        
        
        
        
        %%%%%%%% TASK PERFORMANCES %%%%%%%%
        
        
        %new task?
        if(~strcmp(value(previous_task),value(ThisTask)))
            nTrials_task.value= 0;
            hit_history_task.value=[];
            hit_history_incoherent_task.value=[];
            total_correct_task.value = 0;
            correct_incoherent_task.value = 0;
            total_correct_lastN_task.value = 0;
            previous_task.value=value(ThisTask);
        else
            
            if(res==1)
                nTrials_task.value = value(nTrials_task) + 1;
                hit_history_task.value=[value(hit_history_task) 1];
                if(value(incoherent_trial)==1)
                    hit_history_incoherent_task.value=[value(hit_history_incoherent_task) 1];
                end
            elseif(res==2)
                nTrials_task.value = value(nTrials_task) + 1;
                hit_history_task.value=[value(hit_history_task) 0];
                if(value(incoherent_trial)==1)
                    hit_history_incoherent_task.value=[value(hit_history_incoherent_task) 0];
                end
            else
                hit_history_task.value=[value(hit_history_task) NaN];
                if(value(incoherent_trial)==1)
                    hit_history_incoherent_task.value=[value(hit_history_incoherent_task) NaN];
                end
            end

            total_correct_task.value = nanmean(value(hit_history_task));
            correct_incoherent_task.value = nanmean(value(hit_history_incoherent_task));

            % perc last N trials
            n=value(lastNtrials_task);
            if(length(value(hit_history_task)) >= n)
                vec=value(hit_history_task);
                total_correct_lastN_task.value = nanmean(vec(end-n+1:end));
            else
                total_correct_lastN_task.value = 0;
            end
        end


        
        
        %%%%%%%% STAGE PERFORMANCES %%%%%%%%
        
        %new stage?
        if(~strcmp(value(previous_stage),value(training_stage)))
            nTrials_stage.value= 0;
            hit_history_stage.value=[];
            total_correct_stage.value = 0;
            total_correct_lastN_stage.value = 0;
            previous_stage.value=value(training_stage);
        else
            nTrials_stage.value = value(nTrials_stage) + 1;
            
            if(res==1)
                hit_history_stage.value=[value(hit_history_stage) 1];
            elseif(res==2)
                hit_history_stage.value=[value(hit_history_stage) 0];
            else
                hit_history_stage.value=[value(hit_history_stage) NaN];
            end

            total_correct_stage.value = nanmean(value(hit_history_stage));
            
            % perc last N trials
            n=value(lastNtrials_stage);
            if(length(value(hit_history_stage)) >= n)
                vec=value(hit_history_stage);
                total_correct_lastN_stage.value = nanmean(vec(end-n+1:end));
            else
                total_correct_lastN_stage.value = 0;
            end
        end


        

    case 'get'
        
        val=varargin{1};
        
        eval(['x=value(' val ');']);
        
       
        
        
    case 'make_and_send_summary',
        
        pd.hits       = value(hit_history);
        pd.hits_left       = value(hit_history_left);
        pd.hits_right       = value(hit_history_right);
        pd.violations = value(violation_history);
        pd.sides      = value(side_history);
        pd.stage      = value(training_stage);
        sendsummary(obj, 'sides', pd.sides, 'protocol_data', pd);


end



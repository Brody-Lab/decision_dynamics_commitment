function [x, y] = HistorySection(obj, action, varargin)

GetSoloFunctionArgs(obj);


switch action,

    % ------------------------------------------------------------------
    %              INIT
    % ------------------------------------------------------------------

    case 'init'
        x=varargin{1};
        y=varargin{2};

        
        %%%%% DISPLAYED VARIABLES

        DispParam(obj, 'last_result',  '', x, y,'label','Last Result'); next_row(y);

%         DispParam(obj, 'correct_incoh_last10', 0.5, x, y, 'label','%hit incoh last 10'); next_row(y);

        DispParam(obj, 'correct_coherent',0, x, y, 'labelfraction', 0.55,'label','%hit coh','position', [x y 100 20]);
        DispParam(obj, 'correct_incoherent',0, x, y, 'labelfraction', 0.55,'label','%hit incoh','position', [x+100 y 100 20]);next_row(y);       
        
        DispParam(obj, 'left_correct',0, x, y, 'labelfraction', 0.55,'label','%hit left','position', [x y 100 20]);
        DispParam(obj, 'right_correct',0, x, y, 'labelfraction', 0.55,'label','%hit right','position', [x+100 y 100 20]);next_row(y);       
        
        DispParam(obj, 'dir_correct',0, x, y, 'labelfraction', 0.55,'label','%hit dir','position', [x y 100 20]);
        DispParam(obj, 'freq_correct',0, x, y, 'labelfraction', 0.55,'label','%hit freq','position', [x+100 y 100 20]);next_row(y);       
        
        DispParam(obj, 'percent_violations',  0, x, y); next_row(y);
        DispParam(obj, 'total_correct',  0, x, y,'label','%hit'); next_row(y);
        DispParam(obj, 'nValid',  0, x, y); next_row(y);
        DispParam(obj, 'nTrials',  0, x, y); next_row(y);

        
        SubheaderParam(obj,'title',mfilename,x,y); next_row(y, 1.5);

      
        
        %%%%% INTERNAL VARIABLES
        
        
        %trial variables
        %binary
        SoloParamHandle(obj, 'was_hit', 'value', 0);
        SoloParamHandle(obj, 'was_err', 'value', 0);
        SoloParamHandle(obj, 'was_nic_err', 'value', 0);
        SoloParamHandle(obj, 'was_timeout', 'value', 0);
        SoloParamHandle(obj, 'was_wait', 'value', 0);
        
        SoloParamHandle(obj, 'was_block_switch', 'value', 0);
        
        SoloParamHandle(obj, 'result', 'value', 0);
        
        
        %history variables
        SoloParamHandle(obj, 'hit_history', 'value',[]);
        
        SoloParamHandle(obj, 'side_history', 'value',[]);  
        SoloParamHandle(obj, 'task_history', 'value',[]);  
        SoloParamHandle(obj, 'incoh_history', 'value',[]);             
        SoloParamHandle(obj, 'gammadir_history', 'value',[]); 
        SoloParamHandle(obj, 'gammafreq_history', 'value',[]);   
        
        SoloParamHandle(obj, 'result_history', 'value',[]);
        
        
        
        %history within this block/task
        SoloParamHandle(obj, 'hit_history_task', 'value',[]);
        SoloParamHandle(obj, 'incoh_history_task', 'value',[]);  
        SoloParamHandle(obj, 'previous_task', 'value',[]);
        
        %history within this training stage
        SoloParamHandle(obj, 'hit_history_stage', 'value',[]);
        SoloParamHandle(obj, 'previous_stage', 'value',[]);
        
        
        SoloFunctionAddVars('TaskSection', 'rw_args',{'was_block_switch'});
        SoloFunctionAddVars('TrainingSection', 'ro_args',{'was_hit';'was_block_switch';'result';'dir_correct';'freq_correct';'total_correct'});        
        SoloFunctionAddVars('TrainingSection', 'rw_args',{'previous_stage';'hit_history_stage'});
        SoloFunctionAddVars('StimulusSection', 'ro_args',{'hit_history';'side_history';'task_history';...
            'incoh_history';'gammadir_history';'gammafreq_history'});
        


        
        
        
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
                last_result.value='error';
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
            nTrials.value = value(nTrials) + 1;
            nValid.value = value(nValid) + 1;
        elseif(res==2 || res==5 || res==6)
            hit_history.value=[value(hit_history) 0];
            nTrials.value = value(nTrials) + 1;
            nValid.value = value(nValid) + 1;
        else
            hit_history.value=[value(hit_history) NaN];
            nTrials.value = value(nTrials) + 1;
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
        
        
        %%%% TASK HISTORY %%%%
        if(strcmp(value(ThisTask),'Direction'))
            t = 'd';
        else
            t = 'f';
        end
        task_history.value=[value(task_history) t];
        
        
        %%%% INCOH HISTORY %%%%
        if(value(incoherent_trial)==1)
            c = 1;
        else
            c = 0;
        end
        incoh_history.value=[value(incoh_history) c];
        
        
        %%%% GAMMA_DIR HISTORY %%%%
        gammadir_history.value=[value(gammadir_history) value(ThisGamma_dir)];
        
        
        %%%% GAMMA_FREQ HISTORY %%%%
        gammafreq_history.value=[value(gammafreq_history) value(ThisGamma_freq)];
        
        
        
        
        
        
        %%%%%%%% GENERAL PERFORMANCES %%%%%%%%
        
        vec_hit=value(hit_history);
        
        total_correct.value = nanmean(vec_hit);
        
        num_violations=length(find(isnan(vec_hit)));
        num_total=length(vec_hit);
        percent_violations.value=num_violations/num_total;
        
        vec_side=value(side_history);        
        left_correct.value = nanmean(vec_hit(vec_side=='l'));
        right_correct.value = nanmean(vec_hit(vec_side=='r'));
        
        vec_task=value(task_history);        
        dir_correct.value = nanmean(vec_hit(vec_task=='d'));
        freq_correct.value = nanmean(vec_hit(vec_task=='f'));
        
        vec_incoh=value(incoh_history);        
        correct_coherent.value = nanmean(vec_hit(vec_incoh==0));
        correct_incoherent.value = nanmean(vec_hit(vec_incoh==1));
        
        
        
        
        
        

        
        %%%%%%%% TASK PERFORMANCES %%%%%%%%
        
        
        %new task?
        if(~strcmp(value(previous_task),value(ThisTask)))
            
            nTrials_task.value=1;
            
            if(value(incoherent_trial)==1)
                nTrials_incoh_task.value=1;
                nTrials_coh_task.value=0;
            else
                nTrials_incoh_task.value=0;
                nTrials_coh_task.value=1;
            end
            
            hit_history_task.value=[];
            incoh_history_task.value=[];
            
            total_correct_lastN_task.value=NaN;
            total_correct_coherent_lastN_task.value=NaN;
            total_correct_incoherent_lastN_task.value=NaN;
            
            previous_task.value=value(ThisTask);
            
            
        else
            
            if(res==1)
                nTrials_task.value = value(nTrials_task) + 1;
                
                hit_history_task.value=[value(hit_history_task) 1];
                
                if(value(incoherent_trial)==1)
                    nTrials_incoh_task.value = value(nTrials_incoh_task) + 1;
                    incoh_history_task.value=[value(incoh_history_task) 1];
                else
                    nTrials_coh_task.value = value(nTrials_coh_task) + 1;
                    incoh_history_task.value=[value(incoh_history_task) 0];
                end
                
                
                
            elseif(res==2)
                nTrials_task.value = value(nTrials_task) + 1;
                
                hit_history_task.value=[value(hit_history_task) 0];
                
                if(value(incoherent_trial)==1)
                    nTrials_incoh_task.value = value(nTrials_incoh_task) + 1;
                    incoh_history_task.value=[value(incoh_history_task) 1];
                else
                    nTrials_coh_task.value = value(nTrials_coh_task) + 1;
                    incoh_history_task.value=[value(incoh_history_task) 0];
                end
                
                
            else
                hit_history_task.value=[value(hit_history_task) NaN];
                
                if(value(incoherent_trial)==1)
                    incoh_history_task.value=[value(incoh_history_task) NaN];
                else
                    incoh_history_task.value=[value(incoh_history_task) NaN];
                end
                
            end

            

            %%% compute performances over last n trials for coh and incoh trials
            
            n=value(lastNtrials_task);
            vec_hit_task=value(hit_history_task);
            vec_incoh_task=value(incoh_history_task);
            
            
            % perc last N trials - all
            vec=vec_hit_task;
            vec=vec(~isnan(vec));
            if(length(vec) >= n)
                total_correct_lastN_task.value = mean(vec(end-n+1:end));
            else
                total_correct_lastN_task.value = NaN;
            end
            
            
            % perc last N trials - incoherent
            vec=vec_hit_task(vec_incoh_task==1);
            if(length(vec) >= n)
                total_correct_incoherent_lastN_task.value = mean(vec(end-n+1:end));
            else
                total_correct_incoherent_lastN_task.value = NaN;
            end
            

            % perc last N trials - coherent
            vec=vec_hit_task(vec_incoh_task==0);
            if(length(vec) >= n)
                total_correct_coherent_lastN_task.value = mean(vec(end-n+1:end));
            else
                total_correct_coherent_lastN_task.value = NaN;
            end
                        
            
            
        end
        
        
        
        
        
        %%%%%%%% STAGE PERFORMANCES %%%%%%%%
        
        %new stage?
        if(~strcmp(value(previous_stage),value(training_stage)))
            nTrials_stage.value= 0;
            previous_stage.value=value(training_stage);
        else
            nTrials_stage.value = value(nTrials_stage) + 1;
        end




        

        
        
        
        
    case 'end_session'
        
        CommentsSection(obj, 'append_line', [value(training_stage) ' ; ']);
        CommentsSection(obj, 'append_line', ['days: ' num2str(value(nDays_stage)) ' ; ']);
        CommentsSection(obj, 'append_line', ['valid: ' num2str(value(nValid)) ' ; ']);
        CommentsSection(obj, 'append_line', ['dir: ' num2str(round(value(dir_correct)*100)/100) ' ; ']);
        CommentsSection(obj, 'append_line', ['freq: ' num2str(round(value(freq_correct)*100)/100) ' ; ']);
        CommentsSection(obj, 'append_line', ['coh: ' num2str(round(value(correct_coherent)*100)/100) ' ; ']);
        CommentsSection(obj, 'append_line', ['incoh: ' num2str(round(value(correct_incoherent)*100)/100)]);
        
        
        

    case 'get'
        
        val=varargin{1};
        
        eval(['x=value(' val ');']);
        
       
        
        
    case 'make_and_send_summary',
        
        pd.hits       = value(hit_history);
        pd.sides      = value(side_history);
        pd.tasks      = value(task_history);
        pd.stage      = value(training_stage);
        sendsummary(obj, 'sides', pd.sides, 'protocol_data', pd);


end



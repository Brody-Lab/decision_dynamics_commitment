function [x, y] = HistorySection(obj, action, varargin)

GetSoloFunctionArgs(obj);


switch action,

    % ------------------------------------------------------------------
    %              INIT
    % ------------------------------------------------------------------

    
    %%% list all the way the rat can do well/bad : nose, perf etc.
    
    case 'init'
        x=varargin{1};
        y=varargin{2};

        %%% info about last trial
        DispParam(obj, 'last_result','', x, y, 'labelfraction', 0.5,'position', [x y 200 20]); next_row(y,1.1);

        %%% percent correct coh/incoh
        DispParam(obj, 'correct_coherent',0, x, y, 'labelfraction', 0.55,'label','%hit coh','position', [x y 100 20]);
        DispParam(obj, 'correct_incoherent',0, x, y, 'labelfraction', 0.55,'label','%hit incoh','position', [x+100 y 100 20]);next_row(y);
        
        %%% percent correct left/right
        DispParam(obj, 'left_correct',0, x, y, 'labelfraction', 0.55,'label','%hit left','position', [x y 100 20]);
        DispParam(obj, 'right_correct',0, x, y, 'labelfraction', 0.55,'label','%hit right','position', [x+100 y 100 20]);next_row(y);       
        
        %%% percent correct dir/freq
        DispParam(obj, 'dir_correct',0, x, y, 'labelfraction', 0.55,'label','%hit dir','position', [x y 100 20]);
        DispParam(obj, 'freq_correct',0, x, y, 'labelfraction', 0.55,'label','%hit freq','position', [x+100 y 100 20]);next_row(y,1.1);       
        
        %%% percent correct
        DispParam(obj, 'total_correct',0, x, y, 'labelfraction', 0.55,'label','%hit','position', [x y 100 20]);        
        %%% violations
        DispParam(obj, 'percent_violations',0, x, y, 'labelfraction', 0.55,'label','%viol','position', [x+100 y 100 20]);next_row(y,1.1);               
        %%% total number of trials
        DispParam(obj, 'nTrials',0, x, y, 'labelfraction', 0.55,'position', [x y 100 20]);        
        %%% number of valid trials
        DispParam(obj, 'nValid',0, x, y, 'labelfraction', 0.55,'position', [x+100 y 100 20]);next_row(y);       
        
        SubheaderParam(obj,'title',mfilename,x,y); next_row(y);

      
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%% INTERNAL VARIBLES %%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
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
        SoloParamHandle(obj, 'quadrant_history', 'value',[]);  
        SoloParamHandle(obj, 'task_history', 'value',[]);  
        SoloParamHandle(obj, 'incoh_history', 'value',[]);             
        SoloParamHandle(obj, 'gammadir_history', 'value',[]); 
        SoloParamHandle(obj, 'gammafreq_history', 'value',[]);   
        
        SoloParamHandle(obj, 'result_history', 'value',[]);
        
        
        
        %history within this block/task
        SoloParamHandle(obj, 'hit_history_task', 'value',[]);
        SoloParamHandle(obj, 'incoh_history_task', 'value',[]);  
        SoloParamHandle(obj, 'previous_task', 'value',[]);
        
        %previous training stage
        SoloParamHandle(obj, 'previous_stage', 'value',[]);
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%% SEND OUT VARIBLES %%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
%         
%         %%% percent correct coh/incoh
%         DispParam(obj, 'correct_coherent',0, x, y, 'labelfraction', 0.55,'label','%hit coh','position', [x y 100 20]);
%         DispParam(obj, 'correct_incoherent',0, x, y, 'labelfraction', 0.55,'label','%hit incoh','position', [x+100 y 100 20]);next_row(y);
%         
%         %%% percent correct left/right
%         DispParam(obj, 'left_correct',0, x, y, 'labelfraction', 0.55,'label','%hit left','position', [x y 100 20]);
%         DispParam(obj, 'right_correct',0, x, y, 'labelfraction', 0.55,'label','%hit right','position', [x+100 y 100 20]);next_row(y);       
%         

        
        
        %to training section
        SoloFunctionAddVars('TrainingSection', 'ro_args',{'was_hit';'was_block_switch';...
            'result';'nValid';'total_correct';'dir_correct';'freq_correct';'left_correct';...
            'right_correct';'correct_coherent';'correct_incoherent'});        
        SoloFunctionAddVars('TrainingSection', 'rw_args',{'previous_stage'});
        
        %to stimulus section
        SoloFunctionAddVars('StimulusSection', 'ro_args',{'hit_history';'side_history';'quadrant_history';'task_history';...
            'incoh_history';'gammadir_history';'gammafreq_history';'result'});        
        SoloFunctionAddVars('StimulusSection', 'rw_args',{'was_block_switch'});
        

        
        
        
        
        
        
    case 'next_trial',
        
        %%% if we haven't done any trial yet, no reason to save any history
        if(n_done_trials==0 || isempty(parsed_events) || ~isfield(parsed_events,'states'))
            
            
            %%% initialize stuff
            previous_stage.value=value(training_stage);
            
            
            
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
            %gets it wrong first and then doesn't get it right (how?)
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
        
        
        %%%% QUADRANT HISTORY %%%%
        quadrant_history.value=[value(quadrant_history) value(ThisQuadrant)];
        
        
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
        
        
        %%% save overall percent correct
        vec_hit=value(hit_history);
        total_correct.value = nanmean(vec_hit);
        
        %%% save NIC violations
        vec_res=value(result_history);
        num_violations=length(find(vec_res==3));
        num_total=length(vec_res);
        percent_violations.value=num_violations/num_total;
        
        %%% save left/right percent correct
        vec_side=value(side_history);        
        left_correct.value = nanmean(vec_hit(vec_side=='l'));
        right_correct.value = nanmean(vec_hit(vec_side=='r'));
        
        %%% save dir/freq percent correct
        vec_task=value(task_history);        
        dir_correct.value = nanmean(vec_hit(vec_task=='d'));
        freq_correct.value = nanmean(vec_hit(vec_task=='f'));
        
        %%% save coh/incoh percent correct
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
            
            total_correct_task.value=NaN;
            total_correct_coherent_task.value=NaN;
            total_correct_incoherent_task.value=NaN;
            
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

            

            
            
            %%% compute performances for current task block

            %total correct
            vec_hit_task=value(hit_history_task);
            vec=vec_hit_task;
            vec=vec(~isnan(vec)); 
            
            %%% kernel function: last few trials are the most important
            kernel = exp(-(0:length(vec)-1)/5);
            kernel = kernel(end:-1:1);
            
            if(~isempty(vec))
                total_correct_task.value = nansum(vec .* kernel)/sum(kernel);
            else
                total_correct_task.value = NaN;
            end
            
            
            
            
            %incoherent correct
            vec_hit_task=value(hit_history_task);
            vec_incoh_task=value(incoh_history_task);
            vec=vec_hit_task(vec_incoh_task==1);
            vec=vec(~isnan(vec));
            
            %%% kernel function: last few trials are the most important
            kernel = exp(-(0:length(vec)-1)/5);
            kernel = kernel(end:-1:1);
            
            if(~isempty(vec))
                total_correct_incoherent_task.value = nansum(vec .* kernel)/sum(kernel);
            else
                total_correct_incoherent_task.value = NaN;
            end

            
            
            
            %coherent correct
            vec_hit_task=value(hit_history_task);
            vec_incoh_task=value(incoh_history_task);
            vec=vec_hit_task(vec_incoh_task==0);
            vec=vec(~isnan(vec));
            
            %%% kernel function: last few trials are the most important
            kernel = exp(-(0:length(vec)-1)/5);
            kernel = kernel(end:-1:1);
            
            if(~isempty(vec))
                total_correct_coherent_task.value = nansum(vec .* kernel)/sum(kernel);
            else
                total_correct_coherent_task.value = NaN;
            end

            
        end

        
        
        
        
        %%%%%%%% STAGE PERFORMANCES %%%%%%%%
        
        %new stage?
        if(n_done_trials>1 && ~strcmp(value(previous_stage),value(training_stage)))
            nTrials_stage.value= 0;
            nDays_stage.value= 1;
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



function [x, y] = TaskSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action,

    % ------------------------------------------------------------------
    %              INIT
    % ------------------------------------------------------------------

    case 'init'
        x=varargin{1};
        y=varargin{2};

        
        
        %%%% task switching
        NumeditParam(obj, 'task_switch_min_perf', .7, x, y, 'position', [x y 200 20], ...
            'label', 'Min perf', 'TooltipString', 'Minimum performance to allow switching');next_row(y);
        NumeditParam(obj, 'task_switch_mintrials', 30, x, y, 'position', [x y 200 20], ...
            'label', 'Min trials', 'TooltipString', 'Minimum number of trials before switching');next_row(y);
        ToggleParam(obj, 'task_switch_auto', 0, x, y, 'position', [x y 200 20], ...
            'OffString', 'Auto task switch OFF', 'OnString',  'Auto task switch ON', ...
            'TooltipString', 'If on, switches automatically between tasks');next_row(y);
   
        
        
        
        ToggleParam(obj, 'randomize_first_task', 0, x, y, 'position', [x y 200 20], ...
            'OffString', 'Start with direction', 'OnString',  'Randomize first task', ...
            'TooltipString', 'If on, picks randomly the first task');next_row(y);

        
        
        
        NumeditParam(obj, 'lastNtrials_task', 15, x, y, ...
            'TooltipString', 'number of last N trials'); next_row(y);

        
        
        DispParam(obj, 'nTrials_incoh_task', 0, x, y,'labelfraction', 0.55,'label','nTri incoh','position', [x y 100 20]);        
        DispParam(obj, 'total_correct_incoherent_lastN_task',0, x, y, 'labelfraction', 0.55,'label','%hit incoh','position', [x+100 y 100 20]);next_row(y);       
        
        
        DispParam(obj, 'nTrials_coh_task',0, x, y, 'labelfraction', 0.55,'label','nTri coh','position', [x y 100 20]);
        DispParam(obj, 'total_correct_coherent_lastN_task',0, x, y, 'labelfraction', 0.55,'label','%hit coh','position', [x+100 y 100 20]);next_row(y);
        
        
        
        DispParam(obj, 'nTrials_task',0, x, y, 'labelfraction', 0.55,'label','nTri all','position', [x y 100 20]);
        DispParam(obj, 'total_correct_lastN_task', 0, x, y,'labelfraction', 0.55,'label','%hit all','position', [x+100 y 100 20]);next_row(y);       
        
        
        
        
        
%         
%         DispParam(obj, 'total_correct_coherent_lastN_task',0, x, y, 'labelfraction', 0.55,'label','%hit coh','position', [x y 100 20]);
%         DispParam(obj, 'total_correct_incoherent_lastN_task',0, x, y, 'labelfraction', 0.55,'label','%hit incoh','position', [x+100 y 100 20]);next_row(y);       
%         
%         
%         DispParam(obj, 'nTrials_coh_task',0, x, y, 'labelfraction', 0.55,'label','nTri coh','position', [x y 100 20]);
%         DispParam(obj, 'nTrials_incoh_task', 0, x, y,'labelfraction', 0.55,'label','nTri incoh','position', [x+100 y 100 20]);next_row(y);       
%         
%         
%         
%         
%         DispParam(obj, 'nTrials_task',  0, x, y); next_row(y);


        %%%% current task
        MenuParam(obj, 'ThisTask', {'Direction'; 'Frequency'}, 1, x, y, ...
            'TooltipString', 'the task of the present trial'); next_row(y);


        SubheaderParam(obj,'title',mfilename,x,y); next_row(y, 1.5);

        
        
        SoloFunctionAddVars('SMA1', 'ro_args', {'ThisTask'});
        
        SoloFunctionAddVars('StimulusSection', 'ro_args', {'nTrials_task';'ThisTask';...
            'task_switch_auto'});
        
        SoloFunctionAddVars('TrainingSection', 'rw_args', {'ThisTask';'randomize_first_task';...
            'task_switch_auto';'task_switch_mintrials';'task_switch_min_perf';'lastNtrials_task'});
        
        SoloFunctionAddVars('HistorySection', 'ro_args', {'ThisTask';'lastNtrials_task'});
         
        SoloFunctionAddVars('HistorySection', 'rw_args', {'nTrials_task';'nTrials_coh_task';'nTrials_incoh_task';...
            'total_correct_lastN_task';'total_correct_incoherent_lastN_task';'total_correct_coherent_lastN_task'});
        
        
        
    case 'next_trial',

        
        
        was_block_switch.value=0;
        %%% if specified, randomize first trial in the session
        if(n_done_trials<=1)
            if(value(randomize_first_task)==1)
                if(rand(1)>0.5)
                    ThisTask.value='Direction';
                else
                    ThisTask.value='Frequency';
                end
            else
                ThisTask.value='Direction';
            end
        elseif(value(task_switch_auto)==1)  
            %%% requirement 1: at least N trials in this task
            flag1=value(nTrials_task)>=value(task_switch_mintrials);
            if(value(exist_incoherent))
                %%% requirement 2: performances in the last N trials coherent above min
                flag2a=value(total_correct_coherent_lastN_task)>=value(task_switch_min_perf);
                %%% requirement 3: performances in the last N trials incoherent above min
                flag2b=value(total_correct_incoherent_lastN_task)>=value(task_switch_min_perf);
                flag2=(flag2a && flag2b);
            else
                %%% requirement 2: performances in the last N trials above min
                flag2=value(total_correct_lastN_task)>=value(task_switch_min_perf);
            end
            if(flag1 && flag2)
                
                was_block_switch.value=1;
                
                if(strcmp(value(ThisTask),'Direction'))
                    
                    %switch task
                    ThisTask.value='Frequency';                
                    
                else
                    %switch task
                    ThisTask.value='Direction';       
                    
                end
            end
        end
        
        
        
        

        
        
        
        
        
        
        
        
    case 'get'
        
        val=varargin{1};
        
        eval(['x=value(' val ');']);
        
       

end



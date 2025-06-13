function [x, y] = TrainingSection(obj, action, varargin)

%%%% TODO:

%%% training stages and substages : when nic grows etc. -> make explicit

%%% add the possibility to go back in training (???)
%manual
%%% reward more the harder task / make it easier???
%manual
%%% put some constant checks: bias -> update antibias ; motiviation -> increase water ; incoherent trial performance is low -> pump up incoh delay+reward
%manual

GetSoloFunctionArgs(obj);


switch action,

    % ------------------------------------------------------------------
    %              INIT
    % ------------------------------------------------------------------

    case 'init'
        x=varargin{1};
        y=varargin{2};

        %%%% AUTO STAGE SWITCH PARAMETERS


%         NumeditParam(obj, 'stage_switch_perf', .8, x, y, 'position', [x y 200 20], ...
%             'label', 'Min perf', 'TooltipString', 'Minimum performance to allow switching');
%         next_row(y);
% 
%         NumeditParam(obj, 'stage_switch_mintrials', 20, x, y, 'position', [x y 200 20], ...
%             'label', 'Min trials', 'TooltipString', 'Minimum number of trials before switching');
%         next_row(y);

        ToggleParam(obj, 'stage_switch_auto', 1, x, y, 'position', [x y 200 20], ...
            'OffString', 'Autotrain OFF', 'OnString',  'Autotrain ON', ...
            'TooltipString', 'If on, switches automatically between training stages');
        next_row(y,1.25);


        %%%% STAGE STATUS VARIABLES

        %         NumeditParam(obj, 'stage_switch_perf_ntrials', .8, x, y, 'position', [x y 200 20], ...
        %             'label', 'Ntrials for min perf', 'TooltipString', 'Num. of last trials to compute performance');
        %         next_row(y);
        %         DispParam(obj, 'stage_progress', 0, x, y, ...
        %             'TooltipString', 'fractional progress in current stage'); next_row(y);
        %         DispParam(obj, 'stage_incoh_hitfrac', 0, x, y, ...
        %             'TooltipString', 'average hit frac in this stage for incoherent trials'); next_row(y);
        %         DispParam(obj, 'stage_last_N_hitfrac', 0, x, y, ...
        %             'TooltipString', 'average hit frac over the last N trials in this stage'); next_row(y);
        %         DispParam(obj, 'stage_hitfrac', 0, x, y, ...
        %             'TooltipString', 'average hit frac in this stage'); next_row(y);
        %         DispParam(obj, 'stage_ntrials', 0, x, y, ...
        %             'TooltipString', 'number of trials in this stage'); next_row(y);

%         DispParam(obj, 'stage_progress', 0, x, y, ...
%             'TooltipString', 'fractional progress in current stage'); next_row(y,1.25);

        next_row(y,0.25);

        NumeditParam(obj, 'lastNtrials_stage', 20, x, y, ...
            'TooltipString', 'number of last N trials'); next_row(y);
        DispParam(obj, 'total_correct_lastN_stage', 0.5, x, y,'label','%hit last N trials', ...
            'TooltipString', 'average hit frac in the last N trials ignoring violations'); next_row(y);
        DispParam(obj, 'total_correct_stage',  0, x, y,'label','%hit stage'); next_row(y);
        DispParam(obj, 'nTrials_stage',  0, x, y); next_row(y,1.25);
        



        %%%% MANUALLY SET THE STAGE

        DispParam(obj, 'stage_explanation', sprintf('This field is supposed to provide an explanation of the current stage.'),...
            x, y, 'label','','position', [x y 200 40], 'labelfraction', 0.01,...
            'TooltipString', 'Explanation of the current stage');next_row(y);next_row(y,1.25);

        MenuParam(obj, 'training_stage', {'Stage 1'; 'Stage 2'; 'Stage 3';...
            'Stage 4'; 'Stage 5'; 'Stage 6'; 'Stage 7'; 'Stage 8'}, 1, x, y, ...
            'label', 'Active Stage', 'TooltipString', 'the current training stage');

        PushbuttonParam(obj,'update_active_stage', x, y, 'position', [x+170 y 30 20],'label', 'OK');
        set_callback(update_active_stage, {mfilename, 'update_stage_button'});
        next_row(y);


        SubheaderParam(obj,'title',mfilename,x,y);
        next_row(y, 1.5);

        
        SoloFunctionAddVars('HistorySection', 'ro_args', {'training_stage';...
            'lastNtrials_stage'});
         
        SoloFunctionAddVars('HistorySection', 'rw_args', {'nTrials_stage';...
            'total_correct_stage';'total_correct_lastN_stage'});
        
        
        
    case 'next_trial',

            
        if(value(stage_switch_auto)==1)
            
            feval(mfilename, obj, 'update_stage'); 

        end

        


    case 'update_stage_button',

        nTrials_stage.value= 0;
        hit_history_stage.value=[];
        total_correct_stage.value = 0;
        total_correct_lastN_stage.value = 0;
        previous_stage.value=value(training_stage);
        feval(mfilename, obj, 'update_stage');

     
        
        

    case 'update_stage',




        switch value(training_stage)


            case 'Stage 1',  %%% direction - grow NIC
                
                %%% updated always
                stage_explanation.value=sprintf(['direction only\n '...
                    'grow NIC without violations']);
                
                %%% updated only on the first trial
                if(value(nTrials_stage)==0)

                    %%%%% TaskSection %%%%%
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=0;

                    %%%%% StimulusSection %%%%%
                    dir_modulation_only.value=1;
                    gamma_dir_values_dir.value=5;
                    durations_dir.value=2;
                    nose_in_center.value=0.05;
                end
                    
                %%% algorithm
                if(value(nose_in_center)>=1.5)
                    training_stage.value='Stage 2';                    
                elseif(value(nTrials_stage)>0 && value(nose_in_center)<1.5 && value(was_hit)==1)
                    nose_in_center.value=value(nose_in_center)+0.05;                    
                end

                    

                

            case 'Stage 2',  %%% direction - wait 4 endpoint
                
                %%% updated always
                stage_explanation.value=sprintf(['direction only\n'...
                    'wait for good endpoints']);
                
                %%% updated only on the first trial
                if(value(nTrials_stage)==0)

                    %%%%% TaskSection %%%%%
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=0;

                    %%%%% StimulusSection %%%%%
                    dir_modulation_only.value=1;
                    gamma_dir_values_dir.value=5;
                    durations_dir.value=2;
%                     nose_in_center.value=1.5;
                end
                
                %%% algorithm
                if(value(nTrials_stage)>150 && value(total_correct_stage)>0.8)
                    training_stage.value='Stage 3';
                end
                    
                
                

            case 'Stage 3',  %%% add frequency
                
                %%% updated always
                stage_explanation.value=sprintf(['add frequency\n'...
                    'very easy']);

                %%% updated only on the first trial
                if(value(nTrials_stage)==0)
                    
                    %%%%% TaskSection %%%%%
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=1;
                    task_switch_min_perf.value=0.8;
                    task_switch_mintrials.value=30;
                    
                    %%%%% StimulusSection %%%%%
                    dir_modulation_only.value=1;
                    gamma_dir_values_dir.value=5;
                    gamma_freq_values_dir.value=0;
                    durations_dir.value=2;
                    
                    freq_modulation_only.value=1;
                    gamma_dir_values_freq.value=0;
                    gamma_freq_values_freq.value=5;
                    
                    helper_lights_freq.value=1;
                    
                    durations_freq.value=10;
                    error_forgiveness_freq.value=1;
                    wait_delay_freq.value=0.2; 
                    
%                     nose_in_center.value=1.5;
                end



                %%% algorithm
                if(value(nTrials_stage)>10) 
                    
                    helper_lights_freq.value=0;
                    
                    if(value(wait_delay_freq)<3)
                        if(strcmp(value(ThisTask),'Frequency') && value(result)==5)
                            wait_delay_freq.value=value(wait_delay_freq)+0.2;
                        end
                    else
                        wait_delay_freq.value=3;
                        error_forgiveness_freq.value=0;
                        durations_freq.value=2;
                        training_stage.value='Stage 4';
                    end
                        
                end
                    
                
                
            case 'Stage 4', %%% frequency - wait 4 endpoint
                
                %%% updated always
                stage_explanation.value=sprintf(['direction + frequency\n'...
                    'wait for good endpoints']);

                %%% updated only on the first trial
                if(value(nTrials_stage)==0)
                    
                    %%%%% TaskSection %%%%%
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=1;
                    task_switch_min_perf.value=0.8;
                    task_switch_mintrials.value=30;
                    
                    %%%%% StimulusSection %%%%%
                    dir_modulation_only.value=1;
                    gamma_dir_values_dir.value=5;
                    gamma_freq_values_dir.value=0;
                    durations_dir.value=2;
                    
                    freq_modulation_only.value=1;
                    gamma_dir_values_freq.value=0;
                    gamma_freq_values_freq.value=5;
                    durations_freq.value=2;
                    
                    
                    helper_lights_freq.value=0;
                    error_forgiveness_freq.value=0;
                    
%                     nose_in_center.value=1.5;
                end



                %%% algorithm
                if(value(nTrials_stage)>150 && value(dir_correct)>0.8 ...
                        && value(freq_correct)>0.8)
                    
                    dir_modulation_only.value=0.5;
                    freq_modulation_only.value=0.5;
                    
                    training_stage.value='Stage 5';
                end
                    
                
                
                
            case 'Stage 5',  % decrease purity of stimuli to 0
                
                %%% updated always
                stage_explanation.value=sprintf(['direction + frequency\n'...
                    'make stimuli less pure']);

                %%% updated only on the first trial
                if(value(nTrials_stage)==0)
                    
                    %%%%% TaskSection %%%%%
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=1;
                    task_switch_min_perf.value=0.8;
                    task_switch_mintrials.value=30;
                    
                    %%%%% StimulusSection %%%%%
%                     dir_modulation_only.value=0.5;
                    gamma_dir_values_dir.value=5;
                    gamma_freq_values_dir.value=0;
                    durations_dir.value=2;
                    
%                     freq_modulation_only.value=0.5;
                    gamma_dir_values_freq.value=0;
                    gamma_freq_values_freq.value=5;
                    durations_freq.value=2;
                    
%                     nose_in_center.value=1.5;
                end


                
                
                %%% algorithm: at the end of each block 
                %%% decrease the degree of purity 
                
                if(value(dir_modulation_only)>0 || value(freq_modulation_only)>0)
                    if(value(was_block_switch)==1)


                        if(strcmp(value(ThisTask),'Direction'))

                            if(value(freq_modulation_only)>0.15)
                                freq_modulation_only.value=value(freq_modulation_only)-0.1;
                            elseif(value(freq_modulation_only)<=0.15 && value(freq_modulation_only)>0)
                                freq_modulation_only.value=value(freq_modulation_only)-0.025;
                            end
                            
                            if(value(freq_modulation_only)<0)
                                freq_modulation_only.value=0;
                            end
                            
                        else
                            
                            
                            if(value(dir_modulation_only)>0.15)
                                dir_modulation_only.value=value(dir_modulation_only)-0.1;
                            elseif(value(dir_modulation_only)<=0.15 && value(dir_modulation_only)>0)
                                dir_modulation_only.value=value(dir_modulation_only)-0.025;
                            end
                            
                            if(value(dir_modulation_only)<0)
                                dir_modulation_only.value=0;
                            end
                            
                            
                            
                        end


                    end
                end


                


        end
        
        

    case 'get'
        
        val=varargin{1};
        
        eval(['x=value(' val ');']);
        
       
        




end



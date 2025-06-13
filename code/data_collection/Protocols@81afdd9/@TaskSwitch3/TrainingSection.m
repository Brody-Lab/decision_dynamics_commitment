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

        

        ToggleParam(obj, 'stage_switch_auto', 0, x, y, 'position', [x y 200 20], ...
            'OffString', 'Autotrain OFF', 'OnString',  'Autotrain ON', ...
            'TooltipString', 'If on, switches automatically between training stages');
        next_row(y,1);


        
        
        NumeditParam(obj, 'nDays_stage', 1, x, y); next_row(y);
        NumeditParam(obj, 'nTrials_stage', 0, x, y); next_row(y);
%         DispParam(obj, 'nTrials_stage',  0, x, y); next_row(y);
        


        %%%% MANUALLY SET THE STAGE

%         DispParam(obj, 'stage_explanation', sprintf('This field is supposed to provide an explanation of the current stage.'),...
%             x, y, 'label','','position', [x y 200 40], 'labelfraction', 0.01,...
%             'TooltipString', 'Explanation of the current stage');next_row(y);next_row(y,1.25);

        MenuParam(obj, 'training_stage', {'Stage 1'; 'Stage 2'; 'Stage 3';...
            'Stage 4'; 'Stage 5'; 'Stage 6'; 'Stage 7'; 'Stage 8'}, 1, x, y, ...
            'label', 'Active Stage', 'TooltipString', 'the current training stage');

        PushbuttonParam(obj,'update_active_stage', x, y, 'position', [x+170 y 30 20],'label', 'OK');
        set_callback(update_active_stage, {mfilename, 'update_stage_button'});
        next_row(y);


        SubheaderParam(obj,'title',mfilename,x,y);
        next_row(y, 1.5);

        
        SoloFunctionAddVars('HistorySection', 'ro_args', {'training_stage';'nDays_stage'});
         
        SoloFunctionAddVars('HistorySection', 'rw_args', {'nTrials_stage'});
         
        
        
        
    case 'next_trial',

%             
        if(value(stage_switch_auto)==1)
            
            feval(mfilename, obj, 'update_stage'); 

        end

        


    case 'update_stage_button',
        
        %reboot stage
        nTrials_stage.value= 0;
        nDays_stage.value= 1;
        hit_history_stage.value=[];
        previous_stage.value=value(training_stage);
        
        %set parameters
        feval(mfilename, obj, 'update_stage');

     
        
        

    case 'update_stage',



        
        %%%%%%%% STAGE PERFORMANCES %%%%%%%%
        
        %new stage?
        if(~strcmp(value(previous_stage),value(training_stage)))
            nTrials_stage.value= 0;
            nDays_stage.value= 1;
            hit_history_stage.value=[];
            previous_stage.value=value(training_stage);
        end
        
        
        
        

        switch value(training_stage)


            case 'Stage 1',  %%% direction - grow NIC
                
%                 %%% updated always
%                 stage_explanation.value=sprintf(['direction only\n '...
%                     'grow NIC without violations']);
                
                %%% updated only on the first trial
                if(value(nTrials_stage)==0)

                    %%%%% TaskSection %%%%%
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=0;

                    %%%%% StimulusSection %%%%%
                    dir_modulation_only.value=1;
                    gamma_dir_values_dir.value=4;
                    durations_dir.value=2;
                    nose_in_center.value=0.05;
                end
                    
                %%% algorithm
                if(value(nose_in_center)>=1.3)
                    nose_in_center.value=1.3;
                    training_stage.value='Stage 2';                    
                elseif(value(nTrials_stage)>0 && value(nose_in_center)<1.3 && value(was_hit)==1)
                    nose_in_center.value=value(nose_in_center)+0.05;                    
                end

                    

                

            case 'Stage 2',  %%% direction - wait 4 endpoint
                
%                 %%% updated always
%                 stage_explanation.value=sprintf(['direction only\n'...
%                     'wait for good endpoints']);
                
                %%% updated only on the first trial
                if(value(nTrials_stage)==0)

                    %%%%% TaskSection %%%%%
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=0;

                    %%%%% StimulusSection %%%%%
                    dir_modulation_only.value=1;
                    gamma_dir_values_dir.value=4;
                    durations_dir.value=2;
                end
                
                %%% algorithm
                if(n_done_trials>150 && value(total_correct)>0.8 && value(nDays_stage)>1)
                    training_stage.value='Stage 3';
                end
                    
                
                

            case 'Stage 3',  %%% add frequency
                
%                 %%% updated always
%                 stage_explanation.value=sprintf(['add frequency\n'...
%                     'very easy']);

                %%% updated only on the first trial
                if(value(nTrials_stage)==0)
                    
                    %%%%% TaskSection %%%%%
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=1;
                    task_switch_min_perf.value=0.8;
                    
                    %%%%% StimulusSection %%%%%
                    dir_modulation_only.value=1;
                    gamma_dir_values_dir.value=4;
                    gamma_freq_values_dir.value=0;
                    durations_dir.value=2;
                    
                    freq_modulation_only.value=1;
                    gamma_dir_values_freq.value=0;
                    gamma_freq_values_freq.value=4;
                    
                    helper_lights_freq.value=1;
                    
                    durations_freq.value=10;
                    error_forgiveness_freq.value=1;
                    wait_delay_freq.value=0.2; 
                    
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
%                 
%                 %%% updated always
%                 stage_explanation.value=sprintf(['direction + frequency\n'...
%                     'wait for good endpoints']);

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
                if(n_done_trials>150 && value(dir_correct)>0.8 ...
                        && value(freq_correct)>0.8 && value(nDays_stage)>1)
                    
                    dir_modulation_only.value=0.5;
                    freq_modulation_only.value=0.5;
                    
                    training_stage.value='Stage 5';
                end
                    
                
                
                
            case 'Stage 5',  % decrease purity of stimuli to 0
                
%                 %%% updated always
%                 stage_explanation.value=sprintf(['direction + frequency\n'...
%                     'make stimuli less pure']);

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
                    gamma_dir_values_dir.value=4;
                    gamma_freq_values_dir.value=0;
                    durations_dir.value=2;
                    
%                     freq_modulation_only.value=0.5;
                    gamma_dir_values_freq.value=0;
                    gamma_freq_values_freq.value=4;
                    durations_freq.value=2;
                    
                    
                end


                
                
                %%% algorithm: at the end of each block 
                %%% decrease the degree of purity 
                
                if(value(dir_modulation_only)>0 || value(freq_modulation_only)>0)
                    if(value(was_block_switch)==1)


                        if(strcmp(value(ThisTask),'Direction'))

                            if(value(freq_modulation_only)>0.1)
                                freq_modulation_only.value=value(freq_modulation_only)-0.1;
                            elseif(value(freq_modulation_only)<=0.1 && value(freq_modulation_only)>0)
                                freq_modulation_only.value=value(freq_modulation_only)-0.05;
                            end
                            
                            if(value(freq_modulation_only)<0.0001)
                                freq_modulation_only.value=0;
                            end
                            
                        else
                            
                            
                            if(value(dir_modulation_only)>0.1)
                                dir_modulation_only.value=value(dir_modulation_only)-0.1;
                            elseif(value(dir_modulation_only)<=0.1 && value(dir_modulation_only)>0)
                                dir_modulation_only.value=value(dir_modulation_only)-0.05;
                            end
                            
                            if(value(dir_modulation_only)<0.0001)
                                dir_modulation_only.value=0;
                            end
                            
                            
                            
                        end


                    end
                end


        end
        
        
    case 'end_session'
        
        
        %%%%%%%%% HERE YOU MIGHT WANT TO IMPLEMENT CHECKS AND SWITCH STAGE
        %%%%%%%%% IF NECESSARY!!!
        
%         
%         if(value(stage_switch_auto)==1)
%             
%             feval(mfilename, obj, 'update_stage'); 
% 
%         end

        
        nDays_stage.value = value(nDays_stage) + 1;
        
        
        
        
    case 'get'
        
        val=varargin{1};
        
        eval(['x=value(' val ');']);
        
       
        




end



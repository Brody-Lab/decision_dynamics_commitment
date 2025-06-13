function [x, y] = TrainingSection(obj, action, varargin)

%%%% TODO:

%%% training stages and substages : when nic grows etc. -> make explicit

%%% add the possibility to go back in training (???)
%manual
%%% reward more the harder task / make it easier???
%manual
%%% put some constant checks: bias -> update antibias ; motivation -> increase water ; incoherent trial performance is low -> pump up incoh delay+reward
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

        

        ToggleParam(obj, 'stage_switch_auto', 1, x, y, 'position', [x y 200 20], ...
            'OffString', 'Autotrain OFF', 'OnString',  'Autotrain ON', ...
            'TooltipString', 'If on, switches automatically between training stages');
        next_row(y,1);


        
        
        NumeditParam(obj, 'nDays_stage',1, x, y, 'labelfraction', 0.55,'label','nDays','position', [x y 100 20]);
        NumeditParam(obj, 'nTrials_stage',0, x, y, 'labelfraction', 0.55,'label','nTrials','position', [x+100 y 100 20]);next_row(y);       
        


        %%%% MANUALLY SET THE STAGE

        DispParam(obj, 'stage_explanation', sprintf('Stage description'),...
            x, y, 'label','','position', [x y 200 20], 'labelfraction', 0.01,...
            'TooltipString', 'Description of current stage');next_row(y);

        
        MenuParam(obj, 'training_stage', {'Stage 1'; 'Stage 2'; 'Stage 3';...
            'Stage 4'; 'Stage 5'; 'Stage 6'; 'Stage 7'; 'Stage 8a'; 'Stage 8b';...
            'Stage 8'; 'Stage 9a'; 'Stage 9b'; 'Stage 9'; 'Stage 10a'; 'Stage 10b';...
            'Stage 10'; 'Stage grow NIC'}, 1, x, y, ...
            'label', 'Active Stage', 'TooltipString', 'the current training stage');

        PushbuttonParam(obj,'update_active_stage', x, y, 'position', [x+170 y 30 20],'label', 'OK');
        set_callback(update_active_stage, {mfilename, 'update_stage_button'});
        next_row(y);

        SubheaderParam(obj,'title',mfilename,x,y);
        next_row(y, 1.5);
        
        SoloFunctionAddVars('HistorySection', 'ro_args', {'training_stage';'nDays_stage'});         
        SoloFunctionAddVars('HistorySection', 'rw_args', {'nTrials_stage'});
         
        
        
        
    case 'next_trial', 
        if(n_done_trials>1 && value(stage_switch_auto)==1)            
            feval(mfilename, obj, 'update_stage'); 
        end

        

        
    case 'update_stage_button',
        
        %reboot stage
        nTrials_stage.value= 0;
        nDays_stage.value= 1;
        previous_stage.value=value(training_stage);
        
        %set parameters
        feval(mfilename, obj, 'update_stage');

        
        

    case 'update_stage',

        %new stage?
        if(~strcmp(value(previous_stage),value(training_stage)))
            nTrials_stage.value= 0;
            nDays_stage.value= 1;
            previous_stage.value=value(training_stage);
        end
        
        
        
        switch value(training_stage)

            case 'Stage 1', 
                stage_explanation.value=sprintf('dir only: progressively grow NIC');                
                %%% updated only on the first trial
                if(value(nTrials_stage)==0)
                    %%% task parameters
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=0;                    
                    %%% direction task parameters
                    stimulus_mixing_dir.value=0;
                    gamma_dir_values_dir.value=4;
                    gamma_freq_values_dir.value=0;
                    durations_dir.value=1.3;
                    %%% other parameters
                    nose_in_center.value=0.05;
                    antibias_type.value='Side antibias';
                end 
                %%% algorithm: grow NIC
                if(value(nose_in_center)>=1.3)
                    nose_in_center.value=1.3;
                    training_stage.value='Stage 2';    
                    nTrials_stage.value= 0;
                    nDays_stage.value= 1;
                elseif(value(nTrials_stage)>0 && value(nose_in_center)<1.3 && value(was_hit)==1)
                    nose_in_center.value=value(nose_in_center)+0.001;                    
                end
                    
            case 'Stage 2',  
                stage_explanation.value=sprintf('dir only: wait for good endpoints');               
                %%% updated only on the first trial
                if(value(nTrials_stage)==0)
                    %%% task parameters
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=0;             
                    %%% direction task parameters
                    stimulus_mixing_dir.value=0;
                    gamma_dir_values_dir.value=4;
                    gamma_freq_values_dir.value=0;
                    durations_dir.value=1.3;
                    %%% other parameters
                    nose_in_center.value=1.3;
                    antibias_type.value='Side antibias';
                end
                %%% algorithm: wait for good endpoints
                if(n_done_trials>150 && value(nValid)>150 && value(dir_correct)>0.75 ...
                        && value(left_correct)>0.7 && value(right_correct)>0.7 ...
                        && value(nDays_stage)>2 && value(nTrials_stage)>150)
                    training_stage.value='Stage 3';
                    nTrials_stage.value= 0;
                    nDays_stage.value= 1;
                end
                    
            case 'Stage 3',
                stage_explanation.value=sprintf('dir+freq: add easy frequency trials');
                %%% updated only on the first trial
                if(value(nTrials_stage)==0)
                    %%% task parameters
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=1;
                    task_switch_min_perf.value=0.8;       
                    %%% direction task parameters
                    stimulus_mixing_dir.value=0;
                    gamma_dir_values_dir.value=4;
                    gamma_freq_values_dir.value=0;
                    durations_dir.value=1.3;
                    %%% frequency task parameters
                    stimulus_mixing_freq.value=0;
                    gamma_dir_values_freq.value=0;
                    gamma_freq_values_freq.value=4;
                    durations_freq.value=10;                    
                    %%% frequency task help parameters
                    helper_lights_freq.value=1;                   
                    error_forgiveness_freq.value=1;
                    wait_delay_freq.value=0.2; 
                    %%% other parameters
                    nose_in_center.value=1.3;
                    antibias_type.value='Side antibias';
                end
                %%% algorithm: turn lights off, increase wait delay
                if(value(nTrials_stage)>30) 
                    %%% after 30 trials turn off the helper lights
                    helper_lights_freq.value=0;    
                    %%% slowly increase the wait delay
                    if(value(wait_delay_freq)<3)
                        if(strcmp(value(ThisTask),'Frequency') && value(result)==5)
                            wait_delay_freq.value=value(wait_delay_freq)+0.1;
                        end
                    else
                        wait_delay_freq.value=3;
                        error_forgiveness_freq.value=0;
                        durations_freq.value=1.3;
                        training_stage.value='Stage 4';
                        nTrials_stage.value= 0;
                        nDays_stage.value= 1;
                    end 
                end
                
            case 'Stage 4',
                stage_explanation.value=sprintf('dir+freq: wait for good endpoints');
                %%% updated only on the first trial
                if(value(nTrials_stage)==0)
                    %%% task parameters
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=1;
                    task_switch_min_perf.value=0.8;    
                    %%% direction task parameters
                    stimulus_mixing_dir.value=0;
                    gamma_dir_values_dir.value=4;
                    gamma_freq_values_dir.value=0;
                    durations_dir.value=1.3;
                    %%% frequency task parameters
                    stimulus_mixing_freq.value=0;
                    gamma_dir_values_freq.value=0;
                    gamma_freq_values_freq.value=4;
                    durations_freq.value=1.3;       
                    %%% frequency task help parameters
                    helper_lights_freq.value=0;
                    error_forgiveness_freq.value=0;
                    %%% other parameters
                    nose_in_center.value=1.3;
                    antibias_type.value='Side antibias';
                end
                %%% algorithm: wait for good endpoints
                if(n_done_trials>150 && value(nValid)>150 && value(dir_correct)>0.7 ...
                        && value(freq_correct)>0.7 ...
                        && value(left_correct)>0.7 && value(right_correct)>0.7 ...
                        && value(nDays_stage)>2 && value(nTrials_stage)>150)
                    training_stage.value='Stage 5';
                    nTrials_stage.value= 0;
                    nDays_stage.value= 1;
                end
                
            case 'Stage 5',             
                stage_explanation.value=sprintf('dir+freq: progressively mix stimuli');
                %%% updated only on the first trial
                if(value(nTrials_stage)==0)
                    %%% task parameters
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=1;
                    task_switch_min_perf.value=0.8; 
                    %%% direction task parameters
                    gamma_dir_values_dir.value=4;
                    gamma_freq_values_dir.value=0;
                    durations_dir.value=1.3;
                    %%% frequency task parameters
                    gamma_dir_values_freq.value=0;
                    gamma_freq_values_freq.value=4;
                    durations_freq.value=1.3;    
                    %%% frequency task help parameters
                    helper_lights_freq.value=0;
                    error_forgiveness_freq.value=0;
                    %%% other parameters
                    nose_in_center.value=1.3;
                    antibias_type.value='Side antibias';
                end                
                %%% algorithm: at the end of each block increase mixing
                if(value(stimulus_mixing_dir)<0.99 || value(stimulus_mixing_freq)<0.99)
                    if(value(was_block_switch)==1)
                        if(strcmp(value(ThisTask),'Direction'))
                            stimulus_mixing_dir.value=value(stimulus_mixing_dir)+0.1;                            
                            if(value(stimulus_mixing_dir)>1)
                                stimulus_mixing_dir.value=1;
                            end
                        else
                            stimulus_mixing_freq.value=value(stimulus_mixing_freq)+0.1;                            
                            if(value(stimulus_mixing_freq)>1)
                                stimulus_mixing_freq.value=1;
                            end
                        end
                    end
                else
                    training_stage.value='Stage 6';
                    nTrials_stage.value= 0;
                    nDays_stage.value= 1;
                end

            case 'Stage 6',
                stage_explanation.value=sprintf('mixed stimuli: wait for endpoints');
                %%% updated only on the first trial
                if(value(nTrials_stage)==0)
                    %%% task parameters
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=1;
                    task_switch_min_perf.value=0.8;    
                    %%% direction task parameters
                    stimulus_mixing_dir.value=1;
                    gamma_dir_values_dir.value=4;
                    gamma_freq_values_dir.value=0;
                    durations_dir.value=1.3;
                    %%% frequency task parameters
                    stimulus_mixing_freq.value=1;
                    gamma_dir_values_freq.value=0;
                    gamma_freq_values_freq.value=4;
                    durations_freq.value=1.3;     
                    %%% frequency task help parameters
                    helper_lights_freq.value=0;
                    error_forgiveness_freq.value=0; 
                    %%% other parameters
                    nose_in_center.value=1.3;     
                    antibias_type.value='Side antibias';
                end
                %%% algorithm: wait for good endpoints
                if(n_done_trials>150 && value(nValid)>150 && value(dir_correct)>0.7 ...
                        && value(freq_correct)>0.7 ...
                        && value(left_correct)>0.7 && value(right_correct)>0.7 ...
                        && value(nDays_stage)>2 && value(nTrials_stage)>150)
                    training_stage.value='Stage 7';
                    nTrials_stage.value= 0;
                    nDays_stage.value= 1;
                end

            case 'Stage 7',
                stage_explanation.value=sprintf('incongruent 1 (4; 1,4)');
                %%% updated only on the first trial
                if(value(nTrials_stage)==0)
                    %%% task parameters
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=1;
                    task_switch_min_perf.value=0.7;    
                    %%% direction task parameters
                    stimulus_mixing_dir.value=1;
                    gamma_dir_values_dir.value=4;
                    gamma_freq_values_dir.value=[1 4];
                    durations_dir.value=1.3;
                    %%% frequency task parameters
                    stimulus_mixing_freq.value=1;
                    gamma_dir_values_freq.value=[1 4];
                    gamma_freq_values_freq.value=4;
                    durations_freq.value=1.3;      
                    %%% frequency task help parameters
                    helper_lights_freq.value=0;
                    error_forgiveness_freq.value=0;
                    %%% other parameters
                    nose_in_center.value=1.3;
                    antibias_type.value='Quadrant antibias';
                end
                %%% algorithm: wait for good endpoints
                if(n_done_trials>150 && value(nValid)>150 && value(dir_correct)>0.68 ...
                        && value(freq_correct)>0.68 ...
                        && value(left_correct)>0.68 && value(right_correct)>0.68 ...
                        && value(correct_coherent)>0.68 && value(correct_incoherent)>0.63 ...
                        && value(nDays_stage)>2 && value(nTrials_stage)>150)
                    training_stage.value='Stage 8a';
                    nTrials_stage.value= 0;
                    nDays_stage.value= 1;
                end
                
                
            case 'Stage 8a',
                stage_explanation.value=sprintf('incongruent 2a (4; 1,1.5,3.5,4)');
                %%% updated only on the first trial
                if(value(nTrials_stage)==0)
                    %%% task parameters
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=1;
                    task_switch_min_perf.value=0.7;    
                    %%% direction task parameters
                    stimulus_mixing_dir.value=1;
                    gamma_dir_values_dir.value=4;
                    gamma_freq_values_dir.value=[1 1.5 3.5 4];
                    durations_dir.value=1.3;
                    %%% frequency task parameters
                    stimulus_mixing_freq.value=1;
                    gamma_dir_values_freq.value=[1 1.5 3.5 4];
                    gamma_freq_values_freq.value=4;
                    durations_freq.value=1.3;      
                    %%% frequency task help parameters
                    helper_lights_freq.value=0;
                    error_forgiveness_freq.value=0;
                    %%% other parameters
                    nose_in_center.value=1.3;
                    antibias_type.value='Quadrant antibias';
                end
                %%% algorithm: wait for good endpoints
                if(n_done_trials>150 && value(nValid)>150 && value(dir_correct)>0.68 ...
                        && value(freq_correct)>0.68 ...
                        && value(left_correct)>0.68 && value(right_correct)>0.68 ...
                        && value(correct_coherent)>0.68 && value(correct_incoherent)>0.63 ...
                        && value(nDays_stage)>2 && value(nTrials_stage)>150)
                    training_stage.value='Stage 8b';
                    nTrials_stage.value= 0;
                    nDays_stage.value= 1;
                end


            case 'Stage 8b',
                stage_explanation.value=sprintf('incongruent 2b (4; 1,2,3,4)');
                %%% updated only on the first trial
                if(value(nTrials_stage)==0)
                    %%% task parameters
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=1;
                    task_switch_min_perf.value=0.7;    
                    %%% direction task parameters
                    stimulus_mixing_dir.value=1;
                    gamma_dir_values_dir.value=4;
                    gamma_freq_values_dir.value=[1 2 3 4];
                    durations_dir.value=1.3;
                    %%% frequency task parameters
                    stimulus_mixing_freq.value=1;
                    gamma_dir_values_freq.value=[1 2 3 4];
                    gamma_freq_values_freq.value=4;
                    durations_freq.value=1.3;      
                    %%% frequency task help parameters
                    helper_lights_freq.value=0;
                    error_forgiveness_freq.value=0;
                    %%% other parameters
                    nose_in_center.value=1.3;
                    antibias_type.value='Quadrant antibias';
                end
                %%% algorithm: wait for good endpoints
                if(n_done_trials>150 && value(nValid)>150 && value(dir_correct)>0.68 ...
                        && value(freq_correct)>0.68 ...
                        && value(left_correct)>0.68 && value(right_correct)>0.68 ...
                        && value(correct_coherent)>0.68 && value(correct_incoherent)>0.63 ...
                        && value(nDays_stage)>2 && value(nTrials_stage)>150)
                    training_stage.value='Stage 8';
                    nTrials_stage.value= 0;
                    nDays_stage.value= 1;
                end

                
                

                
            case 'Stage 8',
                stage_explanation.value=sprintf('incongruent 2 (4; 1,2.5,4)');
                %%% updated only on the first trial
                if(value(nTrials_stage)==0)
                    %%% task parameters
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=1;
                    task_switch_min_perf.value=0.7;    
                    %%% direction task parameters
                    stimulus_mixing_dir.value=1;
                    gamma_dir_values_dir.value=4;
                    gamma_freq_values_dir.value=[1 2.5 4];
                    durations_dir.value=1.3;
                    %%% frequency task parameters
                    stimulus_mixing_freq.value=1;
                    gamma_dir_values_freq.value=[1 2.5 4];
                    gamma_freq_values_freq.value=4;
                    durations_freq.value=1.3;      
                    %%% frequency task help parameters
                    helper_lights_freq.value=0;
                    error_forgiveness_freq.value=0;
                    %%% other parameters
                    nose_in_center.value=1.3;
                    antibias_type.value='Quadrant antibias';
                end
                %%% algorithm: wait for good endpoints
                if(n_done_trials>150 && value(nValid)>150 && value(dir_correct)>0.68 ...
                        && value(freq_correct)>0.68 ...
                        && value(left_correct)>0.68 && value(right_correct)>0.68 ...
                        && value(correct_coherent)>0.68 && value(correct_incoherent)>0.63 ...
                        && value(nDays_stage)>2 && value(nTrials_stage)>150)
                    training_stage.value='Stage 9a';
                    nTrials_stage.value= 0;
                    nDays_stage.value= 1;
                end


            case 'Stage 9a',
                stage_explanation.value=sprintf('harder 1a (3.5,4; 1,2.5,4)');
                %%% updated only on the first trial
                if(value(nTrials_stage)==0)
                    %%% task parameters
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=1;
                    task_switch_min_perf.value=0.7;    
                    %%% direction task parameters
                    stimulus_mixing_dir.value=1;
                    gamma_dir_values_dir.value=[3.5 4];
                    gamma_freq_values_dir.value=[1 2.5 4];
                    durations_dir.value=1.3;
                    %%% frequency task parameters
                    stimulus_mixing_freq.value=1;
                    gamma_dir_values_freq.value=[1 2.5 4];
                    gamma_freq_values_freq.value=[3.5 4];
                    durations_freq.value=1.3;      
                    %%% frequency task help parameters
                    helper_lights_freq.value=0;
                    error_forgiveness_freq.value=0;
                    %%% other parameters
                    nose_in_center.value=1.3;
                    antibias_type.value='Quadrant antibias';
                end
                %%% algorithm: wait for good endpoints
                if(n_done_trials>150 && value(nValid)>150 && value(dir_correct)>0.68 ...
                        && value(freq_correct)>0.68 ...
                        && value(left_correct)>0.68 && value(right_correct)>0.68 ...
                        && value(correct_coherent)>0.68 && value(correct_incoherent)>0.63 ...
                        && value(nDays_stage)>2 && value(nTrials_stage)>150)
                    training_stage.value='Stage 9b';
                    nTrials_stage.value= 0;
                    nDays_stage.value= 1;
                end

                
            case 'Stage 9b',
                stage_explanation.value=sprintf('harder 1b (3,4; 1,2.5,4)');
                %%% updated only on the first trial
                if(value(nTrials_stage)==0)
                    %%% task parameters
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=1;
                    task_switch_min_perf.value=0.7;    
                    %%% direction task parameters
                    stimulus_mixing_dir.value=1;
                    gamma_dir_values_dir.value=[3 4];
                    gamma_freq_values_dir.value=[1 2.5 4];
                    durations_dir.value=1.3;
                    %%% frequency task parameters
                    stimulus_mixing_freq.value=1;
                    gamma_dir_values_freq.value=[1 2.5 4];
                    gamma_freq_values_freq.value=[3 4];
                    durations_freq.value=1.3;      
                    %%% frequency task help parameters
                    helper_lights_freq.value=0;
                    error_forgiveness_freq.value=0;
                    %%% other parameters
                    nose_in_center.value=1.3;
                    antibias_type.value='Quadrant antibias';
                end
                %%% algorithm: wait for good endpoints
                if(n_done_trials>150 && value(nValid)>150 && value(dir_correct)>0.68 ...
                        && value(freq_correct)>0.68 ...
                        && value(left_correct)>0.68 && value(right_correct)>0.68 ...
                        && value(correct_coherent)>0.68 && value(correct_incoherent)>0.6 ...
                        && value(nDays_stage)>2 && value(nTrials_stage)>150)
                    training_stage.value='Stage 9';
                    nTrials_stage.value= 0;
                    nDays_stage.value= 1;
                end

                
                
                
            case 'Stage 9',
                stage_explanation.value=sprintf('harder 1 (2.5,4; 1,2.5,4)');
                %%% updated only on the first trial
                if(value(nTrials_stage)==0)
                    %%% task parameters
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=1;
                    task_switch_min_perf.value=0.7;    
                    %%% direction task parameters
                    stimulus_mixing_dir.value=1;
                    gamma_dir_values_dir.value=[2.5 4];
                    gamma_freq_values_dir.value=[1 2.5 4];
                    durations_dir.value=1.3;
                    %%% frequency task parameters
                    stimulus_mixing_freq.value=1;
                    gamma_dir_values_freq.value=[1 2.5 4];
                    gamma_freq_values_freq.value=[2.5 4];
                    durations_freq.value=1.3;      
                    %%% frequency task help parameters
                    helper_lights_freq.value=0;
                    error_forgiveness_freq.value=0;
                    %%% other parameters
                    nose_in_center.value=1.3;
                    antibias_type.value='Quadrant antibias';
                end
                %%% algorithm: wait for good endpoints
                if(n_done_trials>150 && value(nValid)>150 && value(dir_correct)>0.68 ...
                        && value(freq_correct)>0.68 ...
                        && value(left_correct)>0.68 && value(right_correct)>0.68 ...
                        && value(correct_coherent)>0.68 && value(correct_incoherent)>0.6 ...
                        && value(nDays_stage)>2 && value(nTrials_stage)>150)
                    training_stage.value='Stage 10a';
                    nTrials_stage.value= 0;
                    nDays_stage.value= 1;
                end
                

                
            case 'Stage 10a',
                stage_explanation.value=sprintf('harder 2a (2,2.5,4; 1,2.5,4)');
                %%% updated only on the first trial
                if(value(nTrials_stage)==0)
                    %%% task parameters
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=1;
                    task_switch_min_perf.value=0.7;    
                    %%% direction task parameters
                    stimulus_mixing_dir.value=1;
                    gamma_dir_values_dir.value=[2 2.5 4];
                    gamma_freq_values_dir.value=[1 2.5 4];
                    durations_dir.value=1.3;
                    %%% frequency task parameters
                    stimulus_mixing_freq.value=1;
                    gamma_dir_values_freq.value=[1 2.5 4];
                    gamma_freq_values_freq.value=[2 2.5 4];
                    durations_freq.value=1.3;      
                    %%% frequency task help parameters
                    helper_lights_freq.value=0;
                    error_forgiveness_freq.value=0;
                    %%% other parameters
                    nose_in_center.value=1.3;
                    antibias_type.value='Quadrant antibias';
                end
                %%% algorithm: wait for good endpoints
                if(n_done_trials>150 && value(nValid)>150 && value(dir_correct)>0.68 ...
                        && value(freq_correct)>0.68 ...
                        && value(left_correct)>0.68 && value(right_correct)>0.68 ...
                        && value(correct_coherent)>0.68 && value(correct_incoherent)>0.6 ...
                        && value(nDays_stage)>2 && value(nTrials_stage)>150)
                    training_stage.value='Stage 10b';
                    nTrials_stage.value= 0;
                    nDays_stage.value= 1;
                end
                

            case 'Stage 10b',
                stage_explanation.value=sprintf('harder 2b (1.5,2.5,4; 1,2.5,4)');
                %%% updated only on the first trial
                if(value(nTrials_stage)==0)
                    %%% task parameters
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=1;
                    task_switch_min_perf.value=0.7;    
                    %%% direction task parameters
                    stimulus_mixing_dir.value=1;
                    gamma_dir_values_dir.value=[1.5 2.5 4];
                    gamma_freq_values_dir.value=[1 2.5 4];
                    durations_dir.value=1.3;
                    %%% frequency task parameters
                    stimulus_mixing_freq.value=1;
                    gamma_dir_values_freq.value=[1 2.5 4];
                    gamma_freq_values_freq.value=[1.5 2.5 4];
                    durations_freq.value=1.3;      
                    %%% frequency task help parameters
                    helper_lights_freq.value=0;
                    error_forgiveness_freq.value=0;
                    %%% other parameters
                    nose_in_center.value=1.3;
                    antibias_type.value='Quadrant antibias';
                end
                %%% algorithm: wait for good endpoints
                if(n_done_trials>150 && value(nValid)>150 && value(dir_correct)>0.68 ...
                        && value(freq_correct)>0.68 ...
                        && value(left_correct)>0.68 && value(right_correct)>0.68 ...
                        && value(correct_coherent)>0.68 && value(correct_incoherent)>0.6 ...
                        && value(nDays_stage)>2 && value(nTrials_stage)>150)
                    training_stage.value='Stage 10';
                    nTrials_stage.value= 0;
                    nDays_stage.value= 1;
                end
                
                
                
                

            case 'Stage 10',
                stage_explanation.value=sprintf('harder 2 (1,2.5,4; 1,2.5,4)');
                %%% updated only on the first trial
                if(value(nTrials_stage)==0)
                    %%% task parameters
                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=1;
                    task_switch_min_perf.value=0.7;    
                    %%% direction task parameters
                    stimulus_mixing_dir.value=1;
                    gamma_dir_values_dir.value=[1 2.5 4];
                    gamma_freq_values_dir.value=[1 2.5 4];
                    durations_dir.value=1.3;
                    %%% frequency task parameters
                    stimulus_mixing_freq.value=1;
                    gamma_dir_values_freq.value=[1 2.5 4];
                    gamma_freq_values_freq.value=[1 2.5 4];
                    durations_freq.value=1.3;      
                    %%% frequency task help parameters
                    helper_lights_freq.value=0;
                    error_forgiveness_freq.value=0;
                    %%% other parameters
                    nose_in_center.value=1.3;
                    antibias_type.value='Quadrant antibias';
                end

            case 'Stage grow NIC', 
                stage_explanation.value=sprintf('progressively grow NIC');                
                %%% updated only on the first trial
                if(value(nTrials_stage)==0)
                    %%% task parameters
                    nose_in_center.value=0.8;
                end 
                %%% algorithm: grow NIC
                if(value(nose_in_center)>=1.3)
                    nose_in_center.value=1.3;                 
                elseif(value(nTrials_stage)>0 && value(nose_in_center)<1.3 && value(was_hit)==1)
                    nose_in_center.value=value(nose_in_center)+0.05;                    
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



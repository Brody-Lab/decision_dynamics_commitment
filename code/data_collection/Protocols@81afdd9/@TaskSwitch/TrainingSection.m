function [x, y] = TrainingSection(obj, action, varargin)

%%%% TODO:

%%% training stages and substages : when nic grows etc. -> make explicit

%%% add the possibility to go back in training (?)

%%% reward more the harder task / make it easier???

%%% put some constant checks: bias -> update antibias ; motiviation -> increase water ; incoherent trial performance is low -> pump up incoh delay+reward


GetSoloFunctionArgs(obj);


switch action,

    % ------------------------------------------------------------------
    %              INIT
    % ------------------------------------------------------------------

    case 'init'
        x=varargin{1};
        y=varargin{2};

        %%%% AUTO STAGE SWITCH PARAMETERS


        NumeditParam(obj, 'stage_switch_perf', .8, x, y, 'position', [x y 200 20], ...
            'label', 'Min perf', 'TooltipString', 'Minimum performance to allow switching');
        next_row(y);

        NumeditParam(obj, 'stage_switch_mintrials', 20, x, y, 'position', [x y 200 20], ...
            'label', 'Min trials', 'TooltipString', 'Minimum number of trials before switching');
        next_row(y);

        ToggleParam(obj, 'stage_switch_auto', 0, x, y, 'position', [x y 200 20], ...
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

        MenuParam(obj, 'training_stage', {'Stage 1'; 'Stage 2'; 'Stage 3'}, 1, x, y, ...
            'label', 'Active Stage', 'TooltipString', 'the current training stage');

        PushbuttonParam(obj,'update_active_stage', x, y, 'position', [x+170 y 30 20],'label', 'OK');
        set_callback(update_active_stage, {mfilename, 'update_stage_button'});
        next_row(y);


        SubheaderParam(obj,'title',mfilename,x,y);
        next_row(y, 1.5);

        
        SoloFunctionAddVars('HistorySection', 'ro_args', {'training_stage';...
            'stage_switch_mintrials';'lastNtrials_stage'});
         
        SoloFunctionAddVars('HistorySection', 'rw_args', {'nTrials_stage';...
            'total_correct_stage';'total_correct_lastN_stage'});
        
        
        
    case 'next_trial',

        
            
        if(value(stage_switch_auto)==1)
            
            feval(mfilename, obj, 'stage_algorithm');
            
            feval(mfilename, obj, 'stage_conditions');
            
            %this is not executed unless it's the first trial in the stage
            feval(mfilename, obj, 'update_stage'); 

        end

        


    case 'update_stage_button',

        nTrials_stage.value= 0;
        hit_history_stage.value=[];
        total_correct_stage.value = 0;
        total_correct_lastN_stage.value = 0;
        previous_stage.value=value(training_stage);
        feval(mfilename, obj, 'update_stage');

        
    case 'stage_algorithm',

        
        

        switch value(training_stage)

            case 'Stage Grow NIC', % Stage Grow NIC
                
                if(value(nose_in_center)<1)
                    
                    
                end
                
                
        end
        
        %%%% THIS SECTION MUST ALSO UPDATE STAGE_PROGRESS

                %%%%% here algorithm+conditions part: update what needs to be updated
                %%%%% and check whether we can switch to the next stage
                %                 if ~was_viol  % if last trial was violation don't increment.
                %                     if settling_time<0.25
                %                         settling_time.value=settling_time+0.005;
                %                     else
                %                         delay_time.value=delay_time+0.0005;
                %                     end
                %                     if delay_time>0.05
                %                         allow_nic_breaks.value=0; %#ok<*STRNU>
                %                     else
                %                         allow_nic_breaks.value=1;
                %                     end
                %                     if delay_time>0.2
                %                         ignore_errors.value=0;
                %                     else
                %                         ignore_errors.value=1;
                %                     end
                %                     if delay_time>2
                %                         training_stage.value=2;
                %                         trials_in_stage.value=0;
                %                         side_lights.value=3;
                %                     else
                %                         side_lights.value=3;
                %                     end
                %                 end

                

    case 'stage_conditions',

        
        
        
        

    case 'update_stage',




        switch value(training_stage)


            case 'Stage 1', % Stage 1

                if(value(nTrials_stage)==0)

                    stage_explanation.value=sprintf(['Stage 1: learn direction task:\n' ...
                        '0 nose in center time, easy trials + super helper lights']);

                    %%%%% TaskSection %%%%%

                    ThisTask.value='Direction';
                    randomize_first_task.value=0;
                    task_switch_auto.value=0;
%                     task_switch_mintrials.value
%                     task_switch_min_perf.value

                    %%%%% SidesSection %%%%%

                    side_antibias_toggle.value=1;
                    water_antibias_toggle.value=1;
                    LR_Beta.value=3;
                    LR_BiasTau.value=30;
                    MaxSame.value=7;

                    %%%%% StimulusSection %%%%%

                    stim_type.value='Direction only';
                    gamma_dir_values_dir.value=5;
                    gamma_dir_values_freq.value=5;
                    gamma_freq_values_dir.value=5;
                    gamma_freq_values_freq.value=5;
                    
                    durations_dir.value=10;
                    durations_freq.value=10;

                    %%%%% RewardSection %%%%%

                    higher_reward_incoh_trials.value=0;
                    incoherent_reward.value=0;
                    helper_lights_dir.value=1;
                    helper_lights_freq.value=1;

                    %%%%% PunishSection %%%%%

                    settling_time.value=0.001;
                    reward_delay.value=0.001;
                    nose_in_center.value=0.001;
                    nic_delay.value=3;
                    error_forgiveness_dir.value=1;
                    error_forgiveness_freq.value=1;
                    error_delay.value=0.1; %-> increase this one
                    wait_for_cpoke_timeout.value=600;
                    wait_for_spoke_timeout.value=60;
                    timeout_delay.value=3;
                    longer_punish_incoh_trials.value=0;
                    incoherent_delay.value=0;

                end

                
                

            case 'Stage 2', % Stage 3




        end
        
        

    case 'get'
        
        val=varargin{1};
        
        eval(['x=value(' val ');']);
        
       
        




end



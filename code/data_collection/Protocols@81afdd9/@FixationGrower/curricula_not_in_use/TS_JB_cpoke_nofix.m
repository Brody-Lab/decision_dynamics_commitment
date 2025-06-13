
% CURRICULUM DESCRIPTION HERE.
% Goal: cpoke first, grow fixation, then add sounds, then req. rule
function varargout = TS_JB_cpoke_nofix(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action,
    
    %---------------------------------------------------------------%
    %          get_stage_list                                       %
    %---------------------------------------------------------------%
    case 'get_stage_list'
        varargout{1} = {...
                        '1: spoke light chase',...
                        '2: center side no snds give',...
                        '3: center snds side give no viol',...
                        '4: grow stim',...
                        '5: grow pre',...
                        '6: grow post',...
                        '7: grow delay (0.2)',...
                        '8: require rule, never',...
                        '9: grow delay btw snds (2.4)',...
                        '10: discrete delays',...
                        '11: add stimuli'
                };
    %---------------------------------------------------------------%
    %          get_curriculum_update                                %
    %---------------------------------------------------------------%
    case 'get_update'
    	curriculum_stage_num = value(varargin{1});
        switch curriculum_stage_num
        % cpoke --> give reward in side
        % trial availability LED
        case 1
            stage_description.value = 'spoke --> rwd';
            %%% initialize on the first trial
            if (value(n_trials_stage)==0)
                %%% task parameters
                init_poke_type.value = 'spoke';
                stimuli_on.value = false;
                inter_trial_dur_type.value = 'sampled';
                inter_trial_sample_mean.value = 1;
            end

            %%% Auto stage-switch logic
            if (value(n_done_trials) >= value(helper_trials_give))
               TrainingSection(obj, 'increment_stage');
            end
        case 2
            stage_description.value = 'cpoke spoke --> rwd';
            %%% initialize on the first trial
            if (value(n_trials_stage)==0)
                %%% task parameters
                give_type_set.value = 'water';
                SMA_set.value = 'cpoke';
                stimuli_on.value = false;
                wait_for_spoke_Tup_forgiveness.value = true;
                temp_error_penalty.value = true;
                retry_type.value = 'multi';
                inter_trial_perf_multiplier.value = false;
            end

            %%% Auto stage-switch logic
            if (value(n_done_trials) >= 50) && (value(frac_correct) > .7) && ...
               (value(n_days_stage) > 0)
               TrainingSection(obj, 'increment_stage');
            end

        case 3
            stage_description.value = 'cpoke snd spoke, no viol';
            %%% initialize on the first trial
            if (value(n_trials_stage)==0)
                %%% task parameters
    %                     reward_type.value = 'give';
    %                     stimuli_on.value = true;
    %                     wait_for_spoke_Tup_forgiveness.value = true;
    %                     temp_error_penalty.value = true;
    %                     retry_type.value = 'single';
                inter_trial_perf_multiplier.value = false;
                violation_penalty.value = false;

                %%% durations 
                pre_dur.value = 0.1;
                delay_dur.value = 0.1;
                stimulus_dur.value = 0.2;
                post_dur.value = 0.1;

                %%% delays (incase of reset)
                delay_growth.value = false;
                delay_warm_up.value = false;
             end

            %%% Auto stage-switch logic
            %%% TODO- make this early spoke based
            if (value(n_trials_stage) >= 100) &&...
                    (value(n_early)/value(n_trials_stage)) < 0.5 
                TrainingSection(obj, 'increment_stage');
            end

        case 4
            stage_description.value = 'grow stim';
            %%% initialize on the first trial
            if (value(n_trials_stage)==0)
                %%% task parameters
                stimuli_on.value = true;
                inter_trial_perf_multiplier.value = false;
                violation_penalty.value = true;
                violation_dur.value = 0.5;
                violation_dur_type.value = 'growing';
                violation_fixed_growth_rate.value = 0.025;
                error_dur.value = 0.5;
                error_dur_type.value = 'stable';

                if value(n_days_stage) == 0
                    temp_error_penalty.value = false;
                    retry_type.value = 'N/A';
                    reward_type.value = 'poke';
                    wait_for_spoke_Tup_forgiveness.value = false;                        
                end


                % growth stimulus
                stimulus_min.value = 0.1;
                stimulus_dur.value = value(stimulus_min);
                stimulus_growth.value = true;
                stimulus_warm_up.value = true;
                pre_growth.value = false;
                delay_growth.value = false;
                post_growth.value = false;

            end

            %%% Auto stage-switch logic
            if (value(frac_violations) < 0.5) && (value(stimulus_dur) >= value(stimulus_max))
                TrainingSection(obj, 'increment_stage');
            end

        case 5   
            stage_description.value = 'grow pre';
            %%% initialize on the first trial
            if (value(n_trials_stage)==0)
                %%% task parameters
                stimuli_on.value = true;
                inter_trial_perf_multiplier.value = false;
                violation_penalty.value = true;
                violation_dur.value = 0.5;
                violation_dur_type.value = 'growing';
                violation_fixed_growth_rate.value = 0.025;
                error_dur.value = 0.5;
                error_dur_type.value = 'stable';

                if value(n_days_stage) == 0
                    temp_error_penalty.value = false;
                    wait_for_spoke_Tup_forgiveness.value = false;
                    retry_type.value = 'N/A';
                    reward_type.value = 'poke';                        
                end                    

                % grow pre
                pre_min.value = 0.1;
                pre_dur.value = value(pre_min);
                pre_growth.value = true;
                pre_warm_up.value = true;
                % turn off other growth
                stimulus_growth.value = false;
                delay_growth.value = false;
                post_growth.value = false;
            else
                % grow settling in dur to 0.2 in tandem
                if value(settling_in_dur) < 0.2
                    settling_in_dur.value = value(pre_dur);
                end
            end

            %%% Auto stage-switch logic
            if (value(frac_violations) < 0.5) && (value(pre_dur) >= value(pre_max))
                TrainingSection(obj, 'increment_stage');
            end
        case 6   
            stage_description.value = 'grow post';
            %%% initialize on the first trial
            if (value(n_trials_stage)==0)
                %%% task parameters
                stimuli_on.value = true;
                inter_trial_perf_multiplier.value = false;
                violation_penalty.value = true;
                violation_dur.value = 0.5;
                violation_dur_type.value = 'growing';
                violation_fixed_growth_rate.value = 0.025;
                error_dur.value = 0.5;
                error_dur_type.value = 'stable';

                if value(n_days_stage) == 0
                    temp_error_penalty.value = false;
                    retry_type.value = 'N/A';
                    reward_type.value = 'poke';
                    wait_for_spoke_Tup_forgiveness.value = false;
                end                         

                post_min.value = 0.05;
                post_dur.value = value(post_min);
                post_growth.value = true;
                post_warm_up.value = true;
                % turn off other growth
                pre_growth.value = false; 
                stimulus_growth.value = false;
                delay_growth.value = false;

            end

            %%% Auto stage-switch logic
            if (value(frac_violations) < 0.5) && (value(post_dur) >= value(post_max))
                TrainingSection(obj, 'increment_stage');
            end
        case 7  
            stage_description.value = 'grow delay (0.2)';
            %%% initialize on the first trial
            if (value(n_trials_stage)==0)
                %%% task parameters
                stimuli_on.value = true;
                inter_trial_perf_multiplier.value = false;
                violation_penalty.value = true;
                violation_dur.value = 0.5;
                violation_dur_type.value = 'growing';
                violation_fixed_growth_rate.value = 0.025;
                error_dur.value = 0.5;
                error_dur_type.value = 'stable';               

                if value(n_days_stage) == 0
                    temp_error_penalty.value = false;
                    retry_type.value = 'N/A';
                    reward_type.value = 'poke';
                    wait_for_spoke_Tup_forgiveness.value = false;
                end      

                delay_min.value = 0.1;
                delay_max.value = 0.2;
                delay_dur.value = value(delay_min);
                delay_growth.value = true;
                delay_warm_up.value = true;
                % turn off other growth
                pre_growth.value = false;
                stimulus_growth.value = false;
                post_growth.value = false;

            end

            %%% Auto stage-switch logic
            if (value(frac_violations) < 0.5) && (value(delay_dur) >= 0.2)
                TrainingSection(obj, 'increment_stage');
            end                   

        case 8
            stage_description.value = 'learn rule w/ never reward';
            %%% initialize on the first trial
            if (value(n_trials_stage)==0)
                %%% task parameters

                stimuli_on.value = true;
                wait_for_spoke_Tup_forgiveness.value = false;

                inter_trial_perf_multiplier.value = false; %TODO upate inits

    %                     helper_hit_threshold.value = 0.5;
    %                     helper_violation_threshold.value = 0.7;

                %%% delays (incase of reset)
                pre_growth.value = false;
                stimulus_growth.value = false;
                delay_growth.value = false;
                post_growth.value = false;

                %%% initializations for first day in the stage give
                %%% user more flexibility to modify these on animal
                %%% by animal basis since this stage takes the longest
                if (value(n_days_stage) == 1)
                    reward_type.value = 'poke';
                    violation_penalty.value = true;
                    violation_dur.value = 0.5;
                    violation_dur_type.value = 'growing';
                    error_dur.value = 0.5;
                    error_dur_type.value = 'growing';
                    temp_error_penalty.value = false;
                    retry_type.value = 'N/A';
                end

            end

    %                 %%% helper
    %                 if (value(n_trials_stage) >= 30) && (value(n_days_stage) < 5) && ...
    %                     (value(helper_block_counter) < 3)
    %                     helper.value = true;
    %                     helper_type.value = 'error'; 
    %                 end

            %%% Auto stage-switch logic
            if (value(n_trials_stage) >= 100) && (value(frac_correct) > .9) && ...
                (value(frac_violations) < 0.4)
                TrainingSection(obj, 'increment_stage');
            end

        case 9
            stage_description.value = 'grow delay between sa/sb';
            %%% initialize on the first trial
            if (value(n_trials_stage) == 0)
                %%% task parameters
                reward_type.value = 'poke';
                stimuli_on.value = true;
                wait_for_spoke_Tup_forgiveness.value = false;
                temp_error_penalty.value = false;
                retry_type.value = 'N/A';

                %%% growth
                delay_min.value = 0.2;
                delay_max.value = 2.5;
                delay_dur.value = value(delay_min);
                delay_growth.value = true;
                delay_warm_up.value = true;

                if value(n_days_stage) == 1
                    delay_growth_type.value = 'fixed';
                    delay_fixed_growth_rate.value = 1.50; % ~360 valid trials to reach
                    delay_fixed_growth_unit.value = '%';
                end 
            end
            %%% Auto stage-switch logic
            if (value(delay_dur) >= value(delay_max)) && (value(frac_violations) < 0.3) && ...
                (value(frac_correct) > 0.7)
                TrainingSection(obj, 'increment_stage');
            end 

        case 10
            stage_description.value = 'discrete delays';
            %%% initialize on the first trial                
            if (value(n_trials_stage) == 0)
                %%% task parameters
                reward_type.value = 'poke';
                stimuli_on.value = true;
                wait_for_spoke_Tup_forgiveness.value = false;
                temp_error_penalty.value = false;
                retry_type.value = 'N/A';

                %%% disrete delays
                delay_growth.value = false;
                delay_warm_up.value = false;
                delay_growth_type.value = 'discrete';
            end
    %                 %%% Auto stage-switch logic
    %                 if (value(n_days_stage) > 0) && (value(frac_violations) < 0.3) && ...
    %                         (value(n_done_trials) > 5)
    %                     stage_number.value = 7;
    %                 end 
    %                 
        case 11
            stage_description.value = 'add stimuli';
            % TODO

        end % End JB_cpoke_nofix stage_number

    end

end

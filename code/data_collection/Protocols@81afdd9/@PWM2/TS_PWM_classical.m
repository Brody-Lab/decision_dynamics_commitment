% PWM2 version of the typical training protocol found in PWM. In this protocol,
% animals learn to side poke for reward, then to center and then side poke, and
% then grow center port fixation in order to make enough space to play Sa, Sb,
% and the Go cue while fixated. All of these stages are done under light guidance.
% 
% Once fixation of ~5.5 seconds is learned, light guides are turned
% off and the animals must use the sounds in order to perform the task. The
% delay no longer grows with every trial, but is instead randomly picked from
% a discrete set of 2, 3, or 4 seconds.
% 
% The first stage of rule learning, termed always, does not punish animals
% for poking into the incorrect port. The second, termed delayed, delays water
% reward if animals poke into the incorrect port prior to poking into the
% correct one. The last stage of rule learning, termed never, provides no
% reward if animals poke into the incorrect port.
% 
% Reference SessionDefinition file:
% https://github.com/Brody-Lab/TrainingPipelines/blob/master/ParametricWorkingMemory/PWMauto_tone_frequency_20210920_rulesecond_godur1_increaseaud2gotime.m
% 
% jyanar, April 2023
% 
function varargout = TS_PWM_classical(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action,

    %---------------------------------------------------------------%
    %          get_stage_list                                       %
    %---------------------------------------------------------------%
    case 'get_stage_list'
        varargout{1} = {...
            '1: right poke light',...
            '2: left poke light',...
            '3: center poke blocks',...
            '4: gnp (0.2s) no snds',...
            '5: gnp (0.62s) go cue',...
            '6: gnp (1.15s) Sa-Sb-Go',...
            '7: gnp grow delay',...
            '8: always rwd (learn rule)',...
            '9: delayed rwd (learn rule)',...
            '10: never rwd (learn rule)',...
            '11: add psychometrics',...
        };

    %---------------------------------------------------------------%
    %          get_curriculum_update                                %
    %---------------------------------------------------------------%
    %%%%%%%%%%%%%%%%%%
    % TODO Will likely need to refactor SMA_spoke to keep light guide on for longer than
    % 10 seconds -- can just set it to stay on.
    case 'get_curriculum_update'
        stage_num = value(varargin{1});

        disp('get_currirculum_update called.')
        disp('current stage:')
        disp(stage_num)

        switch stage_num

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 1
            stage_description.value = 'right poking light guided';
            if n_trials_stage == 0
                % -- SMA --
                init_poke_type.value = 'spoke';

                % -- Task epochs and growing --
                pre_growth.value  = false;
                pre_warm_up.value = false;
                pre_min.value     = 0.05;
                pre_dur.value     = 0.05;
                pre_max.value     = 0.2;

                stimulus_growth.value  = false;
                stimulus_warm_up.value = false;
                stimulus_min.value     = 0.001;
                stimulus_dur.value     = 0.001;
                stimulus_max.value     = 0.001;

                delay_growth.value    = false;
                delay_warm_up.value   = false;
                delay_min.value       = 0.001;
                delay_dur.value       = 0.001;
                delay_max.value       = 0.001;

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.001;
                post_dur.value        = 0.001;
                post_max.value        = 0.001;
                
                % -- Antibias and sides --
                % Set probability of side completely to right
                antibias_toggle.value = false;
                LeftProb.value = 0;
                
                % -- Go cue --
                % Turn on light guide, no auditory go cue
                wait_for_spoke_dur.value = 8;
                go_aud_toggle.value = false;
                go_light_toggle.value = true;
                go_light_type.value = 'Guide';
                go_cue_dur.value = 8;
                
                % -- Temp error --
                temp_error_penalty.value = true;
                temp_error_water_delay.value = 0;
                retry_type.value = 'single';
                
                % -- Reward period --
                reward_light_toggle.value = false;
                reward_sound_option.value = 'N/A';
                reward_type.value = 'poke';
                
                % -- ITI --
                inter_trial_dur_type.value = 'sampled';
                inter_trial_dur.value = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value = 0.5;
                
                % -- Timeouts --
                violation_dur.value = 0;
                error_dur.value = 0;
                temp_error_dur.value = 0;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                sasb_on.value = false;

                % -- Miscellaneous --
                % PWM has rewardcollection_dur (10s) and drink_time (1s)
                drinking_dur.value = 10;
            end
            if n_trials_stage >= 90 && value(frac_correct) > 0.75
                TrainingSection(obj, 'increment_stage');
            end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 2
            stage_description.value = 'left poking light guided';
            if n_trials_stage == 0
                % -- SMA --
                init_poke_type.value = 'spoke';

                % -- Task epochs and growing --
                pre_growth.value  = false;
                pre_warm_up.value = false;
                pre_min.value     = 0.05;
                pre_dur.value     = 0.05;
                pre_max.value     = 0.2;

                stimulus_growth.value  = false;
                stimulus_warm_up.value = false;
                stimulus_min.value     = 0.001;
                stimulus_dur.value     = 0.001;
                stimulus_max.value     = 0.001;

                delay_growth.value    = false;
                delay_warm_up.value   = false;
                delay_min.value       = 0.001;
                delay_dur.value       = 0.001;
                delay_max.value       = 0.001;

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.001;
                post_dur.value        = 0.001;
                post_max.value        = 0.001;
                
                % -- Antibias and sides --
                % Set probability of side completely to right
                antibias_toggle.value = false;
                LeftProb.value = 1;
                
                % -- Go cue --
                % Turn on light guide, no auditory go cue
                wait_for_spoke_dur.value = 8;
                go_aud_toggle.value = false;
                go_light_toggle.value = true;
                go_light_type.value = 'Guide';
                go_cue_dur.value = 8;
                
                % -- Temp error --
                temp_error_penalty.value = true;
                temp_error_water_delay.value = 0;
                retry_type.value = 'single';
                
                % -- Reward period --
                reward_light_toggle.value = false;
                reward_sound_option.value = 'N/A';
                reward_type.value = 'poke';
                
                % -- ITI --
                inter_trial_dur_type.value = 'sampled';
                inter_trial_dur.value = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value = 0.5;
                
                % -- Timeouts --
                violation_dur.value = 0;
                error_dur.value = 0;
                temp_error_dur.value = 0;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                sasb_on.value = false;

                % -- Miscellaneous --
                % PWM has rewardcollection_dur (10s) and drink_time (1s)
                drinking_dur.value = 10;
            end
            if n_trials_stage >= 90 && value(frac_correct) > 0.75
                TrainingSection(obj, 'increment_stage');
            end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 3
            stage_description.value = 'center poking switching blocks w reward snds';
            if n_trials_stage == 0
                % -- SMA --
                init_poke_type.value = 'cpoke_fix';

                % -- Task epochs and growing --
                pre_growth.value  = false;
                pre_warm_up.value = false;
                pre_min.value     = 0.05;
                pre_dur.value     = 0.05;
                pre_max.value     = 0.2;

                stimulus_growth.value  = false;
                stimulus_warm_up.value = false;
                stimulus_min.value     = 0.001;
                stimulus_dur.value     = 0.001;
                stimulus_max.value     = 0.001;

                delay_growth.value    = false;
                delay_warm_up.value   = false;
                delay_min.value       = 0.001;
                delay_dur.value       = 0.001;
                delay_max.value       = 0.001;

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.001;
                post_dur.value        = 0.001;
                post_max.value        = 0.001;
                
                % -- Antibias and sides --
                antibias_toggle.value = false;
                LeftProb.value = 1;
                
                % -- Go cue --
                % Turn on light guide, no auditory go cue
                wait_for_spoke_dur.value = 8;
                go_aud_toggle.value = false;
                go_light_toggle.value = true;
                go_light_type.value = 'Guide';
                go_cue_dur.value = 8;
                
                % -- Temp error --
                temp_error_penalty.value = true;
                temp_error_water_delay.value = 0;
                retry_type.value = 'single';
                
                % -- Reward period --
                % Turn on reward sounds
                reward_light_toggle.value = false;
                reward_sound_option.value = 'Reward sound';
                reward_type.value = 'poke';
                
                % -- ITI --
                inter_trial_dur_type.value = 'sampled';
                inter_trial_dur.value = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value = 0.5;
                
                % -- Timeouts --
                violation_dur.value = 0;
                error_dur.value = 0;
                temp_error_dur.value = 0;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;


                % -- Sounds --
                sasb_on.value = false;

                % -- Miscellaneous --
                % PWM has rewardcollection_dur (10s) and drink_time (1s)
                drinking_dur.value = 10;
            end
            % Hardcode a block length of 20
            if mod(value(n_trials_stage), 20) == 0
                if LeftProb == 1
                    LeftProb.value = 0;
                else
                    LeftProb.value = 1;
                end
            end
            if n_trials_stage >= 250 && value(frac_correct) > 0.8
                TrainingSection(obj, 'increment_stage');
            end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 4
            stage_description.value = 'grow nose poke 0.2 sec, no Sa/Sb/Go';
            if n_trials_stage == 0
                % -- SMA --
                init_poke_type.value = 'cpoke_fix';

                % -- Task epochs and growing --
                % Grow pre up to 0.2 seconds
                pre_growth.value  = true;
                pre_warm_up.value = true;
                pre_min.value     = 0.05;
                pre_dur.value     = 0.05;
                pre_max.value     = 0.2;

                stimulus_growth.value  = false;
                stimulus_warm_up.value = false;
                stimulus_min.value     = 0.001;
                stimulus_dur.value     = 0.001;
                stimulus_max.value     = 0.001;

                delay_growth.value    = false;
                delay_warm_up.value   = false;
                delay_min.value       = 0.001;
                delay_dur.value       = 0.001;
                delay_max.value       = 0.001;

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.001;
                post_dur.value        = 0.001;
                post_max.value        = 0.001;
                
                % -- Antibias and sides --
                % Turn antibias back on, set LeftProb to 0.5
                antibias_toggle.value = true;
                LeftProb.value = 0.5;
                
                % -- Go cue --
                % Turn on light guide, no auditory go cue
                wait_for_spoke_dur.value = 8;
                go_aud_toggle.value = false;
                go_light_toggle.value = true;
                go_light_type.value = 'Guide';
                go_cue_dur.value = 8;
                
                % -- Temp error --
                temp_error_penalty.value = true;
                temp_error_water_delay.value = 0;
                retry_type.value = 'single';
                
                % -- Reward period --
                % Turn on reward sounds
                reward_light_toggle.value = false;
                reward_sound_option.value = 'Reward sound';
                reward_type.value = 'poke';
                
                % -- ITI --
                inter_trial_dur_type.value = 'sampled';
                inter_trial_dur.value = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value = 0.5;

                % -- Timeouts --
                violation_dur.value = 0;
                error_dur.value = 0;
                temp_error_dur.value = 0;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                sasb_on.value = false;

                % -- Miscellaneous --
                % PWM has rewardcollection_dur (10s) and drink_time (1s)
                drinking_dur.value = 10;
            end
            if cp_fixation_dur >= 0.2
                TrainingSection(obj, 'increment_stage');
            end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Introduce the go cue and grow nose poke to 0.62 seconds (0.05 + 0.03 + 0.1 + 0.03 + 0.2)
        case 5
            stage_description.value = 'grow nose poke 0.62 sec, go cue';
            if n_trials_stage == 0
                % -- SMA --
                init_poke_type.value = 'cpoke_fix';

                % -- Task epochs and growing --
                % Grow pre 0.2 -> 0.62 seconds
                pre_growth.value  = true;
                pre_warm_up.value = true;
                pre_min.value     = 0.05;
                pre_dur.value     = 0.2;
                pre_max.value     = 0.62;

                stimulus_growth.value  = false;
                stimulus_warm_up.value = false;
                stimulus_min.value     = 0.001;
                stimulus_dur.value     = 0.001;
                stimulus_max.value     = 0.001;

                delay_growth.value    = false;
                delay_warm_up.value   = false;
                delay_min.value       = 0.001;
                delay_dur.value       = 0.001;
                delay_max.value       = 0.001;

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.001;
                post_dur.value        = 0.001;
                post_max.value        = 0.001;

                % -- Antibias and sides --
                % Turn antibias back on, set LeftProb to 0.5
                antibias_toggle.value = true;
                LeftProb.value = 0.5;
                
                % -- Go cue --
                % Turn on light guide, turn on aud go cue
                wait_for_spoke_dur.value = 8;
                go_aud_toggle.value = true;
                go_light_toggle.value = true;
                go_light_type.value = 'Guide';
                go_cue_dur.value = 8;
                
                % -- Temp error --
                temp_error_penalty.value = true;
                temp_error_water_delay.value = 0;
                retry_type.value = 'single';
                
                % -- Reward period --
                % Turn on reward sounds
                reward_light_toggle.value = false;
                reward_sound_option.value = 'Reward sound';
                reward_type.value = 'poke';
                
                % -- ITI --
                inter_trial_dur_type.value = 'sampled';
                inter_trial_dur.value = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value = 0.5;

                % -- Timeouts --
                violation_dur.value = 0;
                error_dur.value = 0;
                temp_error_dur.value = 0;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                sasb_on.value = false;

                % -- Miscellaneous --
                % PWM has rewardcollection_dur (10s) and drink_time (1s)
                drinking_dur.value = 10;
            end
            if cp_fixation_dur >= 0.62
                TrainingSection(obj, 'increment_stage');
            end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % GNP from 0.62 -> 1.4 sec, from:
        % pre  | stim | delay | stim | post | GO
        % 0.05 | 0.13 |  0.1  | 0.13 | 0.2  |    => total: 0.61
        % 
        % to
        % 
        % pre  | stim | delay | stim | post | GO
        % 0.05 | 0.4  |  0.1  | 0.4  | 0.2  |    => total: 1.15
        %
        case 6
            stage_description.value = 'grow nose poke 1.15 sec, Sa/Sb & go cue';
            if n_trials_stage == 0
                % -- SMA --
                init_poke_type.value = 'cpoke_fix';

                % -- Task epochs and growing --
                pre_growth.value  = false;
                pre_warm_up.value = false;
                pre_min.value     = 0.05;
                pre_dur.value     = 0.05;
                pre_max.value     = 0.05;

                % Set stimulus epoch to grow
                stimulus_growth.value  = true;
                stimulus_warm_up.value = true;
                stimulus_min.value     = 0.001;
                stimulus_dur.value     = 0.13;
                stimulus_max.value     = 0.4;

                delay_growth.value    = false;
                delay_warm_up.value   = false;
                delay_min.value       = 0.001;
                delay_dur.value       = 0.1;
                delay_max.value       = 0.1;

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.001;
                post_dur.value        = 0.2;
                post_max.value        = 0.2;

                % -- Antibias and sides --
                % Turn antibias back on, set LeftProb to 0.5
                antibias_toggle.value = true;
                LeftProb.value = 0.5;
                
                % -- Go cue --
                % Turn on light guide, turn on aud go cue
                wait_for_spoke_dur.value = 8;
                go_aud_toggle.value = true;
                go_light_toggle.value = true;
                go_light_type.value = 'Guide';
                go_cue_dur.value = 8;

                % -- Temp error --
                temp_error_penalty.value = true;
                temp_error_water_delay.value = 0;
                retry_type.value = 'single';
                
                % -- Reward period --
                % Turn on reward sounds
                reward_light_toggle.value = false;
                reward_sound_option.value = 'Reward sound';
                reward_type.value = 'poke';
                
                % -- ITI --
                inter_trial_dur_type.value = 'sampled';
                inter_trial_dur.value = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value = 0.5;

                % -- Timeouts --
                violation_dur.value = 0;
                error_dur.value = 0;
                temp_error_dur.value = 0;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                sasb_on.value = true;

                % -- Miscellaneous --
                % PWM has rewardcollection_dur (10s) and drink_time (1s)
                drinking_dur.value = 10;
            end
            if value(stimulus_dur) >= value(stimulus_max)
                TrainingSection(obj, 'increment_stage');
            end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % In @PWM, this stage grows to 5.5 total fixation. This results in a max
        % delay length of 5.5 s - 0.05 (pre) - 0.4*2 (stim) - 0.2 (post) = 4.45 s.
        case 7
            stage_description.value = 'grow delay between Sa Sb light guided';
            if n_trials_stage == 0
                % -- SMA --
                init_poke_type.value = 'cpoke_fix';

                % -- Task epochs and growing --
                pre_growth.value  = false;
                pre_warm_up.value = false;
                pre_min.value     = 0.05;
                pre_dur.value     = 0.05;
                pre_max.value     = 0.05;

                stimulus_growth.value  = false;
                stimulus_warm_up.value = false;
                stimulus_min.value     = 0.001;
                stimulus_dur.value     = 0.4;
                stimulus_max.value     = 0.4;

                % Set delay to grow
                delay_growth.value    = true;
                delay_warm_up.value   = false;
                delay_fixed_growth_rate.value = 0.002;
                delay_fixed_growth_unit.value = 's';
                delay_min.value       = 0.1;
                delay_dur.value       = value(delay_prev_session);
                delay_max.value       = 4.45;

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.001;
                post_dur.value        = 0.2;
                post_max.value        = 0.2;

                % -- Antibias and sides --
                % Turn antibias back on, set LeftProb to 0.5
                antibias_toggle.value = true;
                LeftProb.value = 0.5;
                
                % -- Go cue --
                % Turn on light guide, turn on aud go cue
                wait_for_spoke_dur.value = 8;
                go_aud_toggle.value = true;
                go_light_toggle.value = true;
                go_light_type.value = 'Guide';
                go_cue_dur.value = 8;
                
                % -- Temp error --
                temp_error_penalty.value = true;
                temp_error_water_delay.value = 0;
                retry_type.value = 'single';

                % -- Reward period --
                % Turn on reward sounds
                reward_light_toggle.value = false;
                reward_sound_option.value = 'Reward sound';
                reward_type.value = 'poke';
                
                % -- ITI --
                inter_trial_dur_type.value = 'sampled';
                inter_trial_dur.value = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value = 0.5;

                % -- Timeouts --
                violation_dur.value = 0.3;
                error_dur.value = 0;
                temp_error_dur.value = 0;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                sasb_on.value = true;

                % -- Miscellaneous --
                % PWM has rewardcollection_dur (10s) and drink_time (1s)
                drinking_dur.value = 10;
            end
            if value(delay_dur) >= value(delay_max)
                TrainingSection(obj, 'increment_stage');
            end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % In always, we turn off the light guide and introduce variable delays.
        % The animal will always get rewarded if they poke incorrectly first.
        case 8
            stage_description.value = 'learn rule but always reward';

            if n_trials_stage == 0
                % -- SMA --
                init_poke_type.value = 'cpoke_fix';

                % -- Task epochs and growing --
                pre_growth.value  = false;
                pre_warm_up.value = false;
                pre_min.value     = 0.05;
                pre_dur.value     = 0.05;
                pre_max.value     = 0.05;

                stimulus_growth.value  = false;
                stimulus_warm_up.value = false;
                stimulus_min.value     = 0.001;
                stimulus_dur.value     = 0.4;
                stimulus_max.value     = 0.4;

                % Set delay randomly select from [2, 3, 4]
                delay_growth.value    = true; % as currently written this needs to be on
                delay_warm_up.value   = false;
                delay_min.value       = 1;
                delay_dur.value       = 3;
                delay_max.value       = 5;
                delay_growth_type.value = 'discrete';
                delay_discrete_values.value = [2 3 4];

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.001;
                post_dur.value        = 0.2;
                post_max.value        = 0.2;

                % -- Antibias and sides --
                antibias_toggle.value = true;
                LeftProb.value = 0.5;
                
                % -- Go cue --
                % Turn light guide OFF
                go_aud_toggle.value = true;
                go_light_toggle.value = false;
                go_cue_dur.value = 0.2;

                % -- Temp error --
                temp_error_penalty.value = true;
                temp_error_water_delay.value = 0.001;
                retry_type.value = 'single';

                % -- Reward period --
                reward_light_toggle.value = false;
                reward_sound_option.value = 'Reward sound';
                reward_type.value = 'poke';

                % -- ITI --
                inter_trial_dur_type.value = 'sampled';
                inter_trial_dur.value = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value = 0.5;

                % -- Timeouts --
                violation_dur.value = 0.5;
                error_dur.value = 0.2;
                temp_error_dur.value = 0.2;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                sasb_on.value = true;

                % -- Miscellaneous --
                % PWM has rewardcollection_dur (10s) and drink_time (1s)
                drinking_dur.value = 10;
            end
            if n_trials_stage >= 120 && frac_violations < 0.5 && frac_correct > 0.5
                TrainingSection(obj, 'increment_stage');
            end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % In delayed, we begin to delay water reward for poking incorrectly first.
        case 9
            stage_description.value = 'learn rule but delayed reward';
            if n_trials_stage == 0
                % -- SMA --
                init_poke_type.value = 'cpoke_fix';

                % -- Task epochs and growing --
                pre_growth.value  = false;
                pre_warm_up.value = false;
                pre_min.value     = 0.05;
                pre_dur.value     = 0.05;
                pre_max.value     = 0.05;

                stimulus_growth.value  = false;
                stimulus_warm_up.value = false;
                stimulus_min.value     = 0.001;
                stimulus_dur.value     = 0.4;
                stimulus_max.value     = 0.4;

                % Set delay randomly select from [2, 3, 4]
                delay_growth.value    = true; % as currently written this needs to be on
                delay_warm_up.value   = false;
                delay_min.value       = 1;
                delay_dur.value       = 3;
                delay_max.value       = 5;
                delay_growth_type.value = 'discrete';
                delay_discrete_values.value = [2 3 4];

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.001;
                post_dur.value        = 0.2;
                post_max.value        = 0.2;

                % -- Antibias and sides --
                antibias_toggle.value = true;
                LeftProb.value = 0.5;
                
                % -- Go cue --
                go_aud_toggle.value = true;
                go_light_toggle.value = false;
                go_cue_dur.value = 0.2;

                % -- Temp error --
                % Technically, @PWM grows the water_delay, but that's not implemented in @PWM2.
                % Instead, we'll grow the timeout period for temp_error (basically equivalent).
                temp_error_penalty.value = true;
                temp_error_water_delay.value = 0.001;
                temp_error_dur.value = 0.2;
                temp_error_dur_type.value = 'growing';
                retry_type.value = 'single';

                % -- Reward period --
                reward_light_toggle.value = false;
                reward_sound_option.value = 'Reward sound';
                reward_type.value = 'poke';

                % -- ITI --
                inter_trial_dur_type.value = 'sampled';
                inter_trial_dur.value = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value = 0.5;
                
                % -- Timeouts --
                error_dur.value = 0;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                sasb_on.value = true;

                % -- Miscellaneous --
                drinking_dur.value = 10;
            end
            if n_trials_stage >= 120 && frac_correct > 0.7 && frac_violations < 0.3
                TrainingSection(obj, 'increment_stage');
            end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % No reward for incorrect pokes. Full task.
        case 10
            stage_description.value = 'learn rule but no reward for incorrect';
            if n_trials_stage == 0
                % -- SMA --
                init_poke_type.value = 'cpoke_fix';

                % -- Task epochs and growing --
                pre_growth.value  = false;
                pre_warm_up.value = false;
                pre_min.value     = 0.05;
                pre_dur.value     = 0.05;
                pre_max.value     = 0.05;

                stimulus_growth.value  = false;
                stimulus_warm_up.value = false;
                stimulus_min.value     = 0.001;
                stimulus_dur.value     = 0.4;
                stimulus_max.value     = 0.4;

                % Set delay randomly select from [2, 3, 4]
                delay_growth.value    = true; % as currently written this needs to be on
                delay_warm_up.value   = false;
                delay_min.value       = 1;
                delay_dur.value       = 3;
                delay_max.value       = 5;
                delay_growth_type.value = 'discrete';
                delay_discrete_values.value = [2 3 4];

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.001;
                post_dur.value        = 0.2;
                post_max.value        = 0.2;

                % -- Antibias and sides --
                antibias_toggle.value = true;
                LeftProb.value = 0.5;
                
                % -- Go cue --
                go_aud_toggle.value = true;
                go_light_toggle.value = false;
                go_cue_dur.value = 0.2;

                % -- Temp error --
                % Turn temp error OFF
                temp_error_penalty.value = false;

                % -- Reward period --
                reward_light_toggle.value = false;
                reward_sound_option.value = 'Reward sound';
                reward_type.value = 'poke';

                % -- ITI --
                inter_trial_dur_type.value = 'sampled';
                inter_trial_dur.value = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value = 0.5;
                
                % -- Timeouts --
                % error_dur.value = 0; % 21 April 2023 let's allow this to be experimenter controlled
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                sasb_on.value = true;

                % -- Miscellaneous --
                drinking_dur.value = 10;
            end

        case 11
            stage_description.value = 'add psychometrics';
            % TODO add psychometrics to stimsection
        end
        
    end
end



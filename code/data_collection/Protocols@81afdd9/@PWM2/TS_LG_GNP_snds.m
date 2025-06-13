% TS_LG_GNP_snds
% 
% A training curriculum formulated for the April 2023 mouse cohort.
% 
% The curriculum starts by teaching mice light-guided poking. Once a center-out
% motor movement is established, center poke fixation is progressively grown
% until mice are capable of fixating for sufficient time that the sounds can be
% played.
% 
% Stage 1: right poke habituation
% Stage 2: left poke habituation
% Stage 3: cpoke blocked (20 trial blocks, 10 give)
% Stage 4: cpoke blocked (20 trial blocks, 5 give)
% Stage 5: cpoke randomized
% Stage 6: gnp (1.4s) with go cue
% 
% One thing we're teaching them with the first two stages is, you need to keep
% an eye on the ports and be aware of when a light turns on. The light indicates
% that reward is available. If you don't pay attention, you don't get reward.
% 
% TODO Add increment criteria to stage 1 - 6
% TODO Perhaps get rid of stage 5 -- reduces time for mice to learn fast poke
% TODO Add auditory go cue to all stages
% 
% jyanar, April 2023

function varargout = TS_LG_GNP_snds(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action,

    %---------------------------------------------------------------%
    %          get_stage_list                                       %
    %---------------------------------------------------------------%
    case 'get_stage_list'
        varargout{1} = {...
            '1: right poke light',...
            '2: left poke light',...
            '3: cpoke blocks (10 give)',...
            '4: cpoke blocks (5 give)',...
            '5: cpoke random',...
            '6: gnp (1.4s) go cue',...
            '7: introduce sounds',...
            '8: ',...
            '9: ',...
            '10: ',...
            '11: ',...
        };

    %---------------------------------------------------------------%
    %          get_curriculum_update                                %
    %---------------------------------------------------------------%
    case 'get_curriculum_update'
        stage_num = value(varargin{1});

        fprintf('TS_LG_GNP_snds/get_curriculum_update called.\n');
        fprintf('Current stage: %i\n', value(stage_num));

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
                temp_error_penalty.value = false;
                temp_error_water_delay.value = 0;
                retry_type.value = 'single';
                
                % -- Reward period --
                % We start with give on, but turn it off after 25 trials
                reward_light_toggle.value = false;
                reward_sound_option.value = 'N/A';
                reward_type.value = 'give';
                give_prob.value = 1;
                
                % -- ITI --
                inter_trial_dur_type.value = 'sampled';
                inter_trial_dur.value = 40;
                inter_trial_sample_mean.value = 40;
                inter_trial_sample_std.value = 10;
                inter_trial_max.value = 60;
                
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
                drinking_dur.value = 5;
            end

            % Provide light and give guidance in the first 25 trials
            if n_trials_stage == 25
                reward_type.value = 'poke';
                give_prob.value = 0;
            end

            %%%%%%%%%%%%%%%%%%%%%%%


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
                % Set probability of side completely to left
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
                temp_error_penalty.value = false;
                temp_error_water_delay.value = 0;
                retry_type.value = 'single';
                
                % -- Reward period --
                % We start with give on, but turn it off after 25 trials
                reward_light_toggle.value = false;
                reward_sound_option.value = 'N/A';
                reward_type.value = 'give';
                give_prob.value = 1;
                
                % -- ITI --
                inter_trial_dur_type.value = 'sampled';
                inter_trial_dur.value = 40;
                inter_trial_sample_mean.value = 40;
                inter_trial_sample_std.value = 10;
                inter_trial_max.value = 60;
                
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
                drinking_dur.value = 5;
            end

            % Provide light and give guidance in the first 25 trials
            if n_trials_stage == 25
                reward_type.value = 'poke';
                give_prob.value = 0;
            end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 3
            stage_description.value = 'center poking switch blocks (10 give)';
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
                temp_error_penalty.value = false;
                temp_error_water_delay.value = 0;
                retry_type.value = 'single';
                
                % -- Reward period --
                reward_light_toggle.value = false;
                reward_sound_option.value = 'N/A';
                
                % -- ITI --
                %%% Set ITIs to be a bit shorter (40 s -> 15 s)
                inter_trial_dur_type.value = 'sampled';
                inter_trial_dur.value = 15;
                inter_trial_sample_mean.value = 15;
                inter_trial_sample_std.value = 5;
                inter_trial_max.value = 20;
                
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
                drinking_dur.value = 5;
            end

            %%% Block structure

            % Start with give on, and keep on for 10 trials
            if n_trials_stage == 0
                give_prob.value = 1;
                reward_type.value = 'give';
            end
            if n_trials_stage == 10
                give_prob.value = 0;
                reward_type.value = 'poke';
            end

            % At trial 20, switch to center->right and turn on give again
            % for 10 trials
            if n_trials_stage == 20
                LeftProb.value = 0;
                give_prob.value = 1;
                reward_type.value = 'give';
            end
            if n_trials_stage == 30
                give_prob.value = 0;
                reward_type.value = 'poke';
            end

            % Now switch L/R blocks every 20 trials
            if n_trials_stage > 30 && mod(value(n_trials_stage), 20) == 0
                if LeftProb == 1
                    LeftProb.value = 0;
                else
                    LeftProb.value = 1;
                end
            end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 4
            stage_description.value = 'center poking switch blocks (5 give)';
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
                LeftProb.value = 0;
                
                % -- Go cue --
                % Turn on light guide, no auditory go cue
                wait_for_spoke_dur.value = 8;
                go_aud_toggle.value = false;
                go_light_toggle.value = true;
                go_light_type.value = 'Guide';
                go_cue_dur.value = 8;
                
                % -- Temp error --
                temp_error_penalty.value = false;
                temp_error_water_delay.value = 0;
                retry_type.value = 'single';
                
                % -- Reward period --
                reward_light_toggle.value = false;
                reward_sound_option.value = 'N/A';
                
                % -- ITI --
                inter_trial_dur_type.value = 'sampled';
                inter_trial_dur.value = 15;
                inter_trial_sample_mean.value = 15;
                inter_trial_sample_std.value = 5;
                inter_trial_max.value = 20;
                
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
                drinking_dur.value = 5;
            end

            %%% Block structure

            % Start with give on, and keep on for 5 trials
            if n_trials_stage == 0
                give_prob.value = 1;
                reward_type.value = 'give';
            end
            if n_trials_stage == 5
                give_prob.value = 0;
                reward_type.value = 'poke';
            end

            % At trial 20, switch to center->left and turn on give again
            % for 5 trials
            if n_trials_stage == 20
                LeftProb.value = 1;
                give_prob.value = 1;
                reward_type.value = 'give';
            end
            if n_trials_stage == 25
                give_prob.value = 0;
                reward_type.value = 'poke';
            end

            % Now switch L/R blocks every 20 trials
            if n_trials_stage > 30 && mod(value(n_trials_stage), 20) == 0
                if LeftProb == 1
                    LeftProb.value = 0;
                else
                    LeftProb.value = 1;
                end
            end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 5
            stage_description.value = 'center poking random';
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
                % Turn antibias back on (with beta=3) and set LeftProb to 0.5
                antibias_toggle.value = true;
                Beta.value = 3;
                LeftProb.value = 0.5;
                
                % -- Go cue --
                wait_for_spoke_dur.value = 8;
                go_aud_toggle.value = false;
                go_light_toggle.value = true;
                go_light_type.value = 'Guide';
                go_cue_dur.value = 8;
                
                % -- Temp error --
                temp_error_penalty.value = false;
                temp_error_water_delay.value = 0;
                retry_type.value = 'single';
                
                % -- Reward period --
                reward_light_toggle.value = false;
                reward_sound_option.value = 'N/A';
                
                % -- ITI --
                inter_trial_dur_type.value = 'sampled';
                inter_trial_dur.value = 15;
                inter_trial_sample_mean.value = 15;
                inter_trial_sample_std.value = 5;
                inter_trial_max.value = 20;
                
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
                drinking_dur.value = 5;
            end

            % Let's keep give on for the first 20 trials, and then turn it off.
            if n_trials_stage == 0
                give_prob.value = 1;
                reward_type.value = 'give';
            end

            if n_trials_stage == 20
                give_prob.value = 0;
                reward_type.value = 'poke';
            end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % This stage grows center poke fixation up to 1.4 seconds.
        case 6
            stage_description.value = 'gnp 1.4 sec intro snds';
            if n_trials_stage == 0
                % -- SMA --
                init_poke_type.value = 'cpoke_fix';

                % -- Task epochs and growing --
                % Start the animal on half of what they grew to yesterday.
                % If they've reached final fixation, start them at that instead.
                pre_growth.value  = true;
                pre_warm_up.value = true;
                pre_min.value     = 0.05;
                pre_max.value     = 1.4;
                pre_dur.value     = 0.05;
                if value(pre_prev_session) >= 0.1 && value(pre_prev_session) < value(pre_max)
                    pre_dur.value = value(pre_prev_session)/2;
                elseif value(pre_prev_session) == value(pre_max)
                    pre_dur.value = value(pre_max);
                end

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
                antibias_toggle.value = true;
                Beta.value = 3;
                LeftProb.value = 0.5;

                % -- Go cue --
                % The go cue will be the center light turning off, as well as the ambiguous
                % light flash.
                go_light_toggle.value = true;
                go_light_type.value = 'Ambiguous';
                fixation_led.value = true;
                fixation_led_type.value = 'center1led';
                % Also, turn on the auditory go cue
                go_aud_toggle.value = true;

                % -- Light guide --
                % For light guidance, we turn on the correct sidelight.
                wait_for_spoke_dur.value = 8;
                guide_prob.value = 1;
                guide_type.value = 'Guide';
                guide_pre_dur.value = 0.05;
                guide_cue_dur.value = 8;

                
                % -- Temp error --
                temp_error_penalty.value = false;
                temp_error_water_delay.value = 0;
                retry_type.value = 'single';
                
                % -- Reward period --
                % Turn off give, begin playing Sa/Sb during reward period.
                give_prob.value = 0;
                reward_type.value = 'poke';
                reward_light_toggle.value = false;
                reward_sound_option.value = 'Sa/Sb replay';
                
                % -- ITI --
                inter_trial_dur.value = 1;
                inter_trial_dur_type.value = 'stable';
                
                % -- Timeouts --
                violation_dur.value = 1;
                % Note -- for now we'll allow this to be individually controlled. Final protocol,
                % these two should likely be off. The only sound the animal hears is the go cue.
                % SoundInterface(obj, 'set', 'ViolationSound', 'Dur1', 0.150, 'Vol', 0.001);
                % SoundInterface(obj, 'set', 'ErrorSound', 'Vol', 0);
                error_dur.value = 0.5;
                temp_error_dur.value = 0.5;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                sasb_on.value = false;

                % -- Miscellaneous --
                drinking_dur.value = 5;
            end
            if value(pre_dur) >= 0.1
                extrafix_toggle.value = true;
            end

            %%% Increment criteria %%%
            % Animal has grown to maximum duration and violation rate has lowered sufficiently
            if value(pre_dur) >= value(pre_max) && value(frac_violations) < 0.3
                TrainingSection(obj, 'increment_stage');
            end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % This stage introduces sounds to the animal.
        case 7
            stage_description.value = 'intro sounds';
            if n_trials_stage == 0
                % -- SMA --
                init_poke_type.value = 'cpoke_fix';

                % -- Task epochs and growing --
                pre_growth.value  = false;
                pre_warm_up.value = false;
                pre_min.value     = 0.2;
                pre_max.value     = 0.2;
                pre_dur.value     = 0.2;

                stimulus_growth.value  = false;
                stimulus_warm_up.value = false;
                stimulus_min.value     = 0.2;
                stimulus_dur.value     = 0.2;
                stimulus_max.value     = 0.2;

                delay_growth.value    = false;
                delay_warm_up.value   = false;
                delay_min.value       = 0.4;
                delay_dur.value       = 0.4;
                delay_max.value       = 0.4;

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.4;
                post_dur.value        = 0.4;
                post_max.value        = 0.4;
                
                % -- Antibias and sides --
                antibias_toggle.value = true;
                Beta.value = 3;
                LeftProb.value = 0.5;

                % -- Go cue --
                % Compound go cue:
                % * Center light turning off
                % * Ambiguous light flash (50 ms)
                % * Auditory go sound (for loudness, a pclick)
                go_aud_toggle.value = true;
                go_light_toggle.value = true;
                go_light_type.value = 'Ambiguous';
                fixation_led.value = true;
                fixation_led_type.value = 'center1led';

                % -- Light guide --
                % For light guidance, we turn on the correct sidelight.
                wait_for_spoke_dur.value = 8;
                guide_prob.value = 1;
                guide_type.value = 'Guide';
                guide_pre_dur.value = 0.05;
                guide_cue_dur.value = 8;
                
                % -- Temp error --
                temp_error_penalty.value = false;
                temp_error_water_delay.value = 0;
                retry_type.value = 'single';
                
                % -- Reward period --
                % Turn off give, begin playing Sa/Sb during reward period.
                give_prob.value = 0;
                reward_type.value = 'poke';
                reward_light_toggle.value = false;
                reward_sound_option.value = 'Sa/Sb replay';
                
                % -- ITI --
                inter_trial_dur.value = 1;
                inter_trial_dur_type.value = 'stable';
                
                % -- Timeouts --
                violation_dur.value = 1;
                % Note -- for now we'll allow this to be individually controlled. Final protocol,
                % these two should likely be off. The only sound the animal hears is the go cue.
                % SoundInterface(obj, 'set', 'ViolationSound', 'Dur1', 0.150, 'Vol', 0.001);
                % SoundInterface(obj, 'set', 'ErrorSound', 'Vol', 0);
                error_dur.value = 0.5;
                temp_error_dur.value = 0.5;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                % 8 June 2023: Leaving sounds to be manually specified for now, so no preset.
                sasb_on.value = true;

                % -- Miscellaneous --
                drinking_dur.value = 5;
            end

            % Turn off the light guide after 30 trials
            if n_trials_stage == 30
                guide_prob.value = 0;
            end





        %%% END stage switch statement
        end
    end
end


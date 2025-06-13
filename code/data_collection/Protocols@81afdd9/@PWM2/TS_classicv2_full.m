% PWM2 version of the typical training protocol found in @PWM. In this curriculum,
% animals learn to side poke for reward, then to center and then side poke, and then
% grow center port fixation in order to make enough space to play Sa, Sb, and the Go
% cue while fixated. All of these stages are donew under light guidance.
% 
% Once fixation of ~5.5 seconds is learned, light guides are turned off and the animals
% must use the sounds in order to do the task. The delay no longer grows with every
% trial, but is instead randomly picked from a discrete set of 2, 3, or 4 seconds.
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
% jyanar, June 2023 (v2)
function varargout = TS_classicv2_full(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action,

    %---------------------------------------------------------------%
    %          get_stage_list                                       %
    %---------------------------------------------------------------%
    case 'get_stage_list'
        varargout{1} = {...
            '1: right poke light',...
            '2: left poke light',...
            '3: center poke blocks 20',...
            '4: gnp (0.2s) no snds',...
            '5: gnp (0.62s) go cue',...
            '6: gnp (1.15s) Sa-Sb-Go',...
            '7: gnp (2.85s) grow post',...
            '8: wean off lightguide',...
            '9: custom',...
            '10: pair-dependent lightguide',...
            '11: ',...
        };

    %---------------------------------------------------------------%
    %          get_curriculum_update                                %
    %---------------------------------------------------------------%
    case 'get_curriculum_update'
        stage_num = value(varargin{1});

        disp('get_curriculum_update called.')
        disp('current stage:')
        disp(stage_num)

        switch stage_num

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 1:
        %   Habituation to the sidepokes via a light guide. Here the animal pokes
        % into a lit up sideport to receive water reward. No sounds are played.
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
                stimulus_min.value  = 0.05;
                stimulus_dur.value  = 0.05;
                stimulus_max.value  = 0.05;
                delay_growth.value  = false;
                delay_warm_up.value = false;
                delay_min.value     = 0.001;
                delay_dur.value     = 0.001;
                delay_max.value     = 0.001;
                post_growth.value   = false;
                post_warm_up.value  = false;
                post_min.value      = 0.001;
                post_dur.value      = 0.001;
                post_max.value      = 0.001;
                
                % -- Antibias and sides --
                % Set probability of side completely to right
                antibias_toggle.value = false;
                LeftProb.value = 0;
                
                % -- Go cue --
                % Turn on light guide, no auditory go cue. Light go cue turns on
                % and stays on for 8 seconds. To track engagement, lack of response is tracked
                % as a violation.
                go_aud_toggle.value   = false;
                go_light_toggle.value = true;
                go_light_type.value   = 'Guide';
                wait_for_spoke_Tup_forgiveness.value = false;

                guide_prob.value = 0;
                guide_toggle.value = false;

                go_cue_dur.value = 8;
                wait_for_spoke_dur.value = 8;
                
                % -- Temp error --
                temp_error_penalty.value     = true;
                temp_error_water_delay.value = 0;
                retry_type.value             = 'single';
                
                % -- Reward period --
                reward_type.value = 'poke';
                
                % -- ITI --
                % ITIs are ~1 second long, but randomized.
                inter_trial_dur_type.value    = 'sampled';
                inter_trial_dur.value         = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value  = 0.5;
                
                % -- Timeouts --
                % No timeouts.
                violation_dur.value  = 0.1;
                error_dur.value      = 0.1;
                temp_error_dur.value = 0.1;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                % No sounds.
                sasb_on.value = false;
                SoundInterface(obj, 'set', 'ViolationSound', 'Vol', 0);
                SoundInterface(obj, 'set', 'ErrorSound', 'Vol', 0);
                SoundInterface(obj, 'set', 'TempErrorSound', 'Vol', 0);

                % -- Miscellaneous --
                % PWM has rewardcollection_dur (10s) and drink_time (1s)
                drinking_dur.value = 10;
            end
            if n_trials_stage >= 90 && value(frac_correct) > 0.75
                TrainingSection(obj, 'increment_stage');
            end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 2:
        %   Habituation to the sidepokes via a light guide. Here the animal pokes
        % into a lit up sideport to receive water reward. No sounds are played.
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
                stimulus_min.value  = 0.05;
                stimulus_dur.value  = 0.05;
                stimulus_max.value  = 0.05;
                delay_growth.value  = false;
                delay_warm_up.value = false;
                delay_min.value     = 0.001;
                delay_dur.value     = 0.001;
                delay_max.value     = 0.001;
                post_growth.value   = false;
                post_warm_up.value  = false;
                post_min.value      = 0.001;
                post_dur.value      = 0.001;
                post_max.value      = 0.001;
                
                % -- Antibias and sides --
                % Set probability of side completely to left
                antibias_toggle.value = false;
                LeftProb.value = 1;
                
                % -- Go cue --
                % Turn on light guide, no auditory go cue. Light go cue turns on
                % and stays on for 8 seconds. To track engagement, lack of response is tracked
                % as a violation.
                go_aud_toggle.value   = false;
                go_light_toggle.value = true;
                go_light_type.value   = 'Guide';
                wait_for_spoke_Tup_forgiveness.value = false;

                guide_prob.value = 0;
                guide_toggle.value = false;

                go_cue_dur.value = 8;
                wait_for_spoke_dur.value = 8;
                
                % -- Temp error --
                temp_error_penalty.value     = true;
                temp_error_water_delay.value = 0;
                retry_type.value             = 'single';
                
                % -- Reward period --
                reward_type.value = 'poke';
                
                % -- ITI --
                % ITIs are ~1 second long, but randomized.
                inter_trial_dur_type.value    = 'sampled';
                inter_trial_dur.value         = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value  = 0.5;
                
                % -- Timeouts --
                % No timeouts.
                violation_dur.value  = 0.1;
                error_dur.value      = 0.1;
                temp_error_dur.value = 0.1;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                % No sounds.
                sasb_on.value = false;
                SoundInterface(obj, 'set', 'ViolationSound', 'Vol', 0);
                SoundInterface(obj, 'set', 'ErrorSound', 'Vol', 0);
                SoundInterface(obj, 'set', 'TempErrorSound', 'Vol', 0);

                % -- Miscellaneous --
                % PWM has rewardcollection_dur (10s) and drink_time (1s)
                drinking_dur.value = 10;
            end
            if n_trials_stage >= 90 && value(frac_correct) > 0.75
                TrainingSection(obj, 'increment_stage');
            end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 3:
        %   Center->out blocked, 20 trial blocks.
        case 3
            stage_description.value = 'center poking switching blocks (20)';
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
                stimulus_min.value  = 0.05;
                stimulus_dur.value  = 0.05;
                stimulus_max.value  = 0.05;
                delay_growth.value  = false;
                delay_warm_up.value = false;
                delay_min.value     = 0.001;
                delay_dur.value     = 0.001;
                delay_max.value     = 0.001;
                post_growth.value   = false;
                post_warm_up.value  = false;
                post_min.value      = 0.001;
                post_dur.value      = 0.001;
                post_max.value      = 0.001;
                
                % -- Antibias and sides --
                % Set probability of side completely to left. We'll switch in blocks.
                antibias_toggle.value = false;
                LeftProb.value = 1;
                
                % -- Go cue --
                % We move to the cpoke SMA, so now we use the light guide to mark the correct
                % location of the reward and turn off the light-based go cue. 
                % 
                % We set the go cue duration to 50 ms, and the guide pre to 50 ms. So the light
                % guide turns on 100 ms after the rat center pokes. The auditory go cue stays off.
                % 
                % The cpoke stays on until the animal responds, but lack of
                % spoke response within 8 seconds of cpoking is tracked as a violation.
                go_aud_toggle.value   = false;
                go_light_toggle.value = false;
                go_cue_dur.value      = 0.05;
                guide_toggle.value  = true;
                guide_prob.value    = 1.0;
                guide_type.value    = 'Guide';
                guide_pre_dur.value = 0.05;
                guide_cue_dur.value = 8;
                wait_for_spoke_dur.value = 8;
                wait_for_spoke_Tup_forgiveness.value = false;
                
                % -- Temp error --
                % Turn temp-error off, light following should be easy.
                temp_error_penalty.value     = false;
                temp_error_water_delay.value = 0;
                retry_type.value             = 'single';
                
                % -- Reward period --
                reward_type.value = 'poke';
                
                % -- ITI --
                % ITIs are ~1 second long, but randomized.
                inter_trial_dur_type.value    = 'sampled';
                inter_trial_dur.value         = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value  = 0.5;
                
                % -- Timeouts --
                % No timeouts.
                violation_dur.value  = 0.1;
                error_dur.value      = 0.1;
                temp_error_dur.value = 0.1;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                % No sounds.
                sasb_on.value = false;
                SoundInterface(obj, 'set', 'ViolationSound', 'Vol', 0);
                SoundInterface(obj, 'set', 'ErrorSound', 'Vol', 0);
                SoundInterface(obj, 'set', 'TempErrorSound', 'Vol', 0);

                % -- Miscellaneous --
                % PWM has rewardcollection_dur (10s) and drink_time (1s)
                drinking_dur.value = 10;
            end
            % Hardcode block length of 20
            if mod(value(n_trials_stage), 20) == 0
                if LeftProb == 1 LeftProb.value = 0;
                else             LeftProb.value = 1;
                end
            end
            
            if n_trials_stage >= 250 && value(frac_correct) > 0.8
                TrainingSection(obj, 'increment_stage');
            end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 4:
        %   Grow nose poke (0.2 seconds), no sounds yet. Once we grow the animal
        % to 200 ms, we turn on the go sound.
        case 4
            stage_description.value = 'gnp (0.2s), no sounds';
            if n_trials_stage == 0

                % -- SMA --
                init_poke_type.value = 'cpoke_fix';

                % -- Task epochs and growing --
                % Note we only need to grow pre by ~50 ms to 100ms, since stimulus_dur
                % is already set at 50 ms (=100ms).
                pre_growth.value  = true;
                pre_warm_up.value = true;
                pre_min.value     = 0.05;
                pre_dur.value     = 0.05;
                pre_max.value     = 0.1;
                stimulus_growth.value  = false;
                stimulus_warm_up.value = false;
                stimulus_min.value  = 0.05;
                stimulus_dur.value  = 0.05;
                stimulus_max.value  = 0.05;
                delay_growth.value  = false;
                delay_warm_up.value = false;
                delay_min.value     = 0.001;
                delay_dur.value     = 0.001;
                delay_max.value     = 0.001;
                post_growth.value   = false;
                post_warm_up.value  = false;
                post_min.value      = 0.001;
                post_dur.value      = 0.001;
                post_max.value      = 0.001;
                
                % -- Antibias and sides --
                % Set antibias on and LeftProb prior to 0.5.
                antibias_toggle.value = true;
                Beta.value = 3; % set beta for antibias to 3
                LeftProb.value = 0.5;
                
                % -- Go cue
                % Still silent!
                go_aud_toggle.value   = false;
                go_light_toggle.value = false;
                go_cue_dur.value      = 0.05;
                guide_toggle.value  = true;
                guide_prob.value    = 1.0;
                guide_type.value    = 'Guide';
                guide_pre_dur.value = 0.05;
                guide_cue_dur.value = 8;
                wait_for_spoke_dur.value = 8;
                wait_for_spoke_Tup_forgiveness.value = false;
                
                % -- Temp error --
                temp_error_penalty.value     = false;
                temp_error_water_delay.value = 0;
                retry_type.value             = 'single';
                
                % -- Reward period --
                reward_type.value = 'poke';
                
                % -- ITI --
                % ITIs are ~1 second long, but randomized.
                inter_trial_dur_type.value    = 'sampled';
                inter_trial_dur.value         = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value  = 0.5;
                
                % -- Timeouts --
                % Make timeouts a little longer.
                violation_dur.value  = 0.5;
                error_dur.value      = 0.5;
                temp_error_dur.value = 0.1;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                % No sounds.
                sasb_on.value = false;
                SoundInterface(obj, 'set', 'ViolationSound', 'Vol', 0);
                SoundInterface(obj, 'set', 'ErrorSound', 'Vol', 0);
                SoundInterface(obj, 'set', 'TempErrorSound', 'Vol', 0);

                % -- Miscellaneous --
                % PWM has rewardcollection_dur (10s) and drink_time (1s)
                drinking_dur.value = 10;
            end

            if n_trials_stage > 0 && value(cp_fixation_dur) >= 0.2
                TrainingSection(obj, 'increment_stage');
            end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 5:
        %   Grow nose poke (0.62 seconds), with go sound. Once we grow the animal
        % to 0.62 seconds, we turn on Sa and Sb.
        case 5
            stage_description.value = 'gnp (0.62s), go sound';
            if n_trials_stage == 0

                % -- SMA --
                init_poke_type.value = 'cpoke_fix';

                % -- Task epochs and growing --
                % Grow pre 0.2 -> 0.52 seconds (plus 0.1 total stim) = 0.62 total
                pre_growth.value  = true;
                pre_warm_up.value = true;
                pre_min.value     = 0.1;
                pre_dur.value     = 0.1;
                pre_max.value     = 0.52;

                stimulus_growth.value  = false;
                stimulus_warm_up.value = false;
                stimulus_min.value  = 0.05;
                stimulus_dur.value  = 0.05;
                stimulus_max.value  = 0.05;

                delay_growth.value  = false;
                delay_warm_up.value = false;
                delay_min.value     = 0.001;
                delay_dur.value     = 0.001;
                delay_max.value     = 0.001;

                post_growth.value   = false;
                post_warm_up.value  = false;
                post_min.value      = 0.001;
                post_dur.value      = 0.001;
                post_max.value      = 0.001;
                
                % -- Antibias and sides --
                % Set antibias on and LeftProb prior to 0.5.
                antibias_toggle.value = true;
                Beta.value = 3; % set beta for antibias to 3
                LeftProb.value = 0.5;
                
                % -- Go cue
                % Now on! Plus, move the guide cue another 50 ms out.
                go_aud_toggle.value   = true;
                go_light_toggle.value = false;
                go_cue_dur.value      = 0.05;

                guide_toggle.value  = true;
                guide_prob.value    = 1.0;
                guide_type.value    = 'Guide';
                guide_pre_dur.value = 0.1;
                guide_cue_dur.value = 8;
                wait_for_spoke_dur.value = 8;
                wait_for_spoke_Tup_forgiveness.value = false;
                
                % -- Temp error --
                temp_error_penalty.value     = false;
                temp_error_water_delay.value = 0;
                retry_type.value             = 'single';
                
                % -- Reward period --
                reward_type.value = 'poke';
                
                % -- ITI --
                % ITIs are ~1 second long, but randomized.
                inter_trial_dur_type.value    = 'sampled';
                inter_trial_dur.value         = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value  = 0.5;
                
                % -- Timeouts --
                % Make timeouts a little longer.
                violation_dur.value  = 0.5;
                error_dur.value      = 0.5;
                temp_error_dur.value = 0.1;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                % No sounds.
                sasb_on.value = false;
                SoundInterface(obj, 'set', 'ViolationSound', 'Vol', 0);
                SoundInterface(obj, 'set', 'ErrorSound', 'Vol', 0);
                SoundInterface(obj, 'set', 'TempErrorSound', 'Vol', 0);

                % -- Miscellaneous --
                % PWM has rewardcollection_dur (10s) and drink_time (1s)
                drinking_dur.value = 10;
            end

            if n_trials_stage > 0 && value(cp_fixation_dur) >= 0.62
                TrainingSection(obj, 'increment_stage');
            end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 6:
        %   Grow nose poke (1.15 seconds), with Sa/Sb/go sound. This stage turns on
        % Sa and Sb sounds, and grows them to their final length of 0.4 seconds each.
        % 
        % The epochs go from:
        % 
        % pre  | stim | delay | stim | post | GO
        % 0.05 | 0.13 |  0.1  | 0.13 | 0.2  |    => total: 0.61
        % 
        % to
        % 
        % pre  | stim | delay | stim | post | GO
        % 0.05 | 0.4  |  0.1  | 0.4  | 0.2  |    => total: 1.15
        % 
        case 6
            stage_description.value = 'gnp (1.15 sec), with Sa/Sb/go sound';
            if n_trials_stage == 0

                % -- SMA --
                init_poke_type.value = 'cpoke_fix';

                % -- Task epochs and growing --
                % Grow pre 0.2 -> 0.52 seconds (plus 0.1 total stim) = 0.62 total
                pre_growth.value  = false;
                pre_warm_up.value = false;
                pre_min.value     = 0.05;
                pre_dur.value     = 0.05;
                pre_max.value     = 0.1;

                stimulus_growth.value  = true;
                stimulus_warm_up.value = true;
                stimulus_min.value  = 0.13;
                stimulus_max.value  = 0.4;
                % If stimulus_prev_session is greater than double what we start with (0.13), then
                % set the starting stimulus_dur value to be half of prev_session's
                if value(stimulus_prev_session) >= 0.26 && value(stimulus_prev_session) <= value(stimulus_max)
                    stimulus_dur.value = value(stimulus_prev_session)/2;
                elseif value(stimulus_prev_session) == value(stimulus_max)
                    stimulus_dur.value = value(stimulus_max);
                end

                delay_growth.value  = false;
                delay_warm_up.value = false;
                delay_min.value     = 0.1;
                delay_dur.value     = 0.1;
                delay_max.value     = 0.1;

                post_growth.value   = false;
                post_warm_up.value  = false;
                post_min.value      = 0.2;
                post_dur.value      = 0.2;
                post_max.value      = 0.2;
                
                % -- Antibias and sides --
                % Set antibias on and LeftProb prior to 0.5.
                antibias_toggle.value = true;
                Beta.value = 3; % set beta for antibias to 3
                LeftProb.value = 0.5;
                
                % -- Go cue
                % Push the light guide out another 50 ms, to 150 ms post go off.
                go_aud_toggle.value   = true;
                go_light_toggle.value = false;
                go_cue_dur.value      = 0.05;

                guide_toggle.value  = true;
                guide_prob.value    = 1.0;
                guide_type.value    = 'Guide';
                guide_pre_dur.value = 0.15;
                guide_cue_dur.value = 8;

                wait_for_spoke_dur.value = 8;
                wait_for_spoke_Tup_forgiveness.value = false;
                
                % -- Temp error --
                temp_error_penalty.value     = false;
                temp_error_water_delay.value = 0;
                retry_type.value             = 'single';
                
                % -- Reward period --
                reward_type.value = 'poke';
                
                % -- ITI --
                % ITIs are ~1 second long, but randomized.
                inter_trial_dur_type.value    = 'sampled';
                inter_trial_dur.value         = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value  = 0.5;
                
                % -- Timeouts --
                violation_dur.value  = 0.5;
                error_dur.value      = 0.5;
                temp_error_dur.value = 0.1;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                % Turn on Sa and Sb!
                sasb_on.value = true;
                SoundInterface(obj, 'set', 'ViolationSound', 'Vol', 0);
                SoundInterface(obj, 'set', 'ErrorSound', 'Vol', 0);
                SoundInterface(obj, 'set', 'TempErrorSound', 'Vol', 0);

                % -- Miscellaneous --
                % PWM has rewardcollection_dur (10s) and drink_time (1s)
                drinking_dur.value = 10;
            end

            if n_trials_stage > 0 && value(cp_fixation_dur) >= 1.15
                TrainingSection(obj, 'increment_stage');
            end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 7:
        % Grow to a total of 2.85 second fixation, to the following structure:
        % v: growing
        % 
        %                             vvvvvv
        % pre  | stim | delay | stim | post | GO
        % 0.05 | 0.4  | 0.1   | 0.4  | 1    |    => total: 1.95
        % 
        case 7
            stage_description.value = 'gnp (1.95 sec) grow post, with Sa/Sb/go sound';
            if n_trials_stage == 0

                % -- SMA --
                init_poke_type.value = 'cpoke_fix';

                % -- Task epochs and growing --
                pre_growth.value  = false;
                pre_warm_up.value = false;
                pre_min.value     = 0.05;
                pre_max.value     = 0.1;
                pre_dur.value     = 0.05;

                stimulus_growth.value  = false;
                stimulus_warm_up.value = false;
                stimulus_min.value  = 0.05;
                stimulus_max.value  = 0.4;
                stimulus_dur.value  = 0.4;

                delay_growth.value  = false;
                delay_warm_up.value = false;
                delay_min.value     = 0.1;
                delay_dur.value     = 0.1;
                delay_max.value     = 0.1;

                post_growth.value   = true;
                post_warm_up.value  = true;
                post_min.value      = 0.2;
                post_dur.value      = 0.2;
                post_max.value      = 1;
                % If post_prev_session is greater than double what we start with (0.2), then
                % set the starting post_dur value to be half of prev_session's
                if value(post_prev_session) >= value(post_min)*2 && value(post_prev_session) <= value(post_max)
                    post_dur.value = value(post_prev_session)/2;
                elseif value(post_prev_session) == value(post_max)
                    post_dur.value = value(post_max);
                end

                % -- Antibias and sides --
                % Set antibias on and LeftProb prior to 0.5.
                antibias_toggle.value = true;
                Beta.value = 3; % set beta for antibias to 3
                LeftProb.value = 0.5;
                
                % -- Go cue
                % Push the light guide out another 50 ms, to 150 ms post go off.
                go_aud_toggle.value   = true;
                go_light_toggle.value = false;
                go_cue_dur.value      = 0.05;
                guide_prob.value    = 1.0;
                guide_type.value    = 'Guide';
                guide_pre_dur.value = 0.15;
                guide_cue_dur.value = 8;
                wait_for_spoke_dur.value = 8;
                wait_for_spoke_Tup_forgiveness.value = false;
                
                % -- Temp error --
                temp_error_penalty.value     = false;
                temp_error_water_delay.value = 0;
                retry_type.value             = 'single';
                
                % -- Reward period --
                reward_type.value = 'poke';
                
                % -- ITI --
                % ITIs are ~1 second long, but randomized.
                inter_trial_dur_type.value    = 'sampled';
                inter_trial_dur.value         = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value  = 0.5;
                
                % -- Timeouts --
                violation_dur.value  = 0.5;
                error_dur.value      = 0.5;
                temp_error_dur.value = 0.1;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                % Turn on Sa and Sb!
                sasb_on.value = true;
                SoundInterface(obj, 'set', 'ViolationSound', 'Vol', 0);
                SoundInterface(obj, 'set', 'ErrorSound', 'Vol', 0);
                SoundInterface(obj, 'set', 'TempErrorSound', 'Vol', 0);

                % -- Miscellaneous --
                % PWM has rewardcollection_dur (10s) and drink_time (1s)
                drinking_dur.value = 10;
            end

            if n_trials_stage > 0 && value(cp_fixation_dur) >= 2.85
                TrainingSection(obj, 'increment_stage');
            end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 8:
        % Animals have grown to 2.85 second fixation. We wean them off the light
        % guide onto following the sound rule.
        % 
        % pre  | stim | delay | stim | post | GO
        % 0.05 | 0.4  | 1     | 0.4  | 1    |    => total: 2.85
        %
        % 
        case 8
            stage_description.value = 'wean off light guide';
            if n_trials_stage == 0

                % -- SMA --
                init_poke_type.value = 'cpoke_fix';

                % -- Task epochs and growing --
                pre_growth.value  = false;
                pre_warm_up.value = false;
                pre_min.value     = 0.05;
                pre_max.value     = 0.1;
                pre_dur.value     = 0.05;

                stimulus_growth.value  = false;
                stimulus_warm_up.value = false;
                stimulus_min.value  = 0.05;
                stimulus_max.value  = 0.4;
                stimulus_dur.value  = 0.4;

                delay_growth.value  = false;
                delay_warm_up.value = false;
                delay_min.value     = 0.1;
                delay_dur.value     = 0.1;
                delay_max.value     = 0.1;

                post_growth.value   = true;
                post_warm_up.value  = true;
                post_min.value      = 0.2;
                post_dur.value      = 0.2;
                post_max.value      = 1;
                % If post_prev_session is greater than double what we start with (0.2), then
                % set the starting post_dur value to be half of prev_session's
                if value(post_prev_session) >= value(post_min)*2 && value(post_prev_session) <= value(post_max)
                    post_dur.value = value(post_prev_session)/2;
                elseif value(post_prev_session) == value(post_max)
                    post_dur.value = value(post_max);
                end

                % -- Antibias and sides --
                % Set antibias on and LeftProb prior to 0.5.
                antibias_toggle.value = true;
                Beta.value = 3; % set beta for antibias to 3
                LeftProb.value = 0.5;
                
                % -- Go cue
                % Light guide turns on for only 50% of trials.
                go_aud_toggle.value   = true;
                go_light_toggle.value = false;
                go_cue_dur.value      = 0.05;

                guide_toggle.value  = true;
                guide_prob.value    = 0.5;
                guide_type.value    = 'Guide';
                guide_pre_dur.value = 0.15;
                guide_cue_dur.value = 8;
                wait_for_spoke_dur.value = 8;
                wait_for_spoke_Tup_forgiveness.value = false;
                
                % -- Temp error --
                temp_error_penalty.value     = false;
                temp_error_water_delay.value = 0;
                retry_type.value             = 'single';
                
                % -- Reward period --
                reward_type.value = 'poke';
                
                % -- ITI --
                % ITIs are ~1 second long, but randomized.
                inter_trial_dur_type.value    = 'sampled';
                inter_trial_dur.value         = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value  = 0.5;
                
                % -- Timeouts --
                violation_dur.value  = 0.5;
                error_dur.value      = 0.5;
                temp_error_dur.value = 0.1;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                % Turn on Sa and Sb!
                sasb_on.value = true;
                SoundInterface(obj, 'set', 'ViolationSound', 'Vol', 0);
                SoundInterface(obj, 'set', 'ErrorSound', 'Vol', 0);
                SoundInterface(obj, 'set', 'TempErrorSound', 'Vol', 0);

                % -- Miscellaneous --
                % PWM has rewardcollection_dur (10s) and drink_time (1s)
                drinking_dur.value = 10;
            end


        case 9
            stage_description.value = 'custom';


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 10:
        % We want to get animals to good performance on the 4-pair stimulus set.
        % To do that, we'll turn on the light guide for the pairs that they're
        % bad at, but begin shifting the light guide forward in time.
        %
        % This should help them quickly gain performance on the bad pairs.
        % 
        case 10
            stage_description.value = 'pair-dependent light guide';
            guide_perf_toggle.value = true;
            % guide_perf_threshold.value = 0.6; % Allow this to be controlled per-rat.
            guide_pre_dur.value = 0.0;
            guide_pre_rate.value = 0.005; % Push guide forward by 5 milliseconds a trial.


        end %%% -- end switch stage
    end
end



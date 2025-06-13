% TS_LG_GNP_snds v2
% 
% A training curriculum formulated for the July 2023 mouse cohort.
% 
% The curriculum starts by teaching mice light-guided poking. Once a center-out
% motor movement is established, center poke fixation is progressively grown
% until mice are capable of fixating for sufficient time that the sounds can be
% played.
% 
% Stage 1: right poke habituation (with go cue)
% Stage 2: left poke habituation (with go cue)
% Stage 3: cpoke blocked (20 trial blocks, 10 give; with go cue)
% Stage 4: cpoke blocked snds (20 trial blocks, 10 give; with Sa/Sb/Go)
% Stage 5: cpoke random snds (20 give; Sa/Sb/Go)
% Stage 5: gnp
% 
% This curriculum is the second version of LG_GNP_snds, and aims to avoid the
% following:
%   1. Getting stuck in low fixation like last time.
%   2. Crashing with the introduction of Sa/Sb sounds.
%   
% To address 1, we start animals with a minimum of 250 ms fixation on the first
% cpoke stage (stage 3). To address 2, we start playing Sa/Sb on the next stage,
% stage 4. We then quickly move to gnp.
% 
% TODO Add increment criteria to stage 1 - 6
% TODO Make starting cpoke (stage 3, 4, 5) start minimum 250 ms
%   * perhaps also make sidepoking require 250 ms for water dispensing.
% 
% jyanar, July 2023

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
            '3: cpoke blocks (20b/10g)',...
            '4: cpoke blocks snds (20b/10g)',...
            '5: cpoke random',...
            '6: gnp (0.95s) stim 0.05->0.4s',...
            '7: gnp (1.1s) del 0.05->0.2s',...
            '8: wean off light (0.5 prob)',...
            '9: wean off light (no light guide)',...
            '10: intro 4 asymmetric',...
            '11: custom',...
            '12: pair-dependent light guide'
       };

    %---------------------------------------------------------------%
    %          get_curriculum_update                                %
    %---------------------------------------------------------------%
    case 'get_curriculum_update'
        stage_num = value(varargin{1});

        fprintf('TS_LGS_v2/get_curriculum_update called.\n');
        fprintf('Current stage: %i\n', value(stage_num));

        switch stage_num

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 1 (right port):
        %   Habituation and sidepoking. Here we keep ITIs long and temperror off.
        % The animal learns to sidepoke in response to an auditory go cue and a
        % light guide. Water "give" (30% of reward amt) is automatically provided
        % on the appropriate side for 25 trials in order to help establish that
        % the ports provide water.
        % 
        % Lack of response (i.e. wait_for_spoke times out after 8 seconds) is
        % marked as a violation.
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
                stimulus_min.value     = 0.05;
                stimulus_dur.value     = 0.05;
                stimulus_max.value     = 0.05;

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
                % Turn on light guide, play auditory go cue.
                wait_for_spoke_dur.value = 8;
                go_aud_toggle.value   = true;
                go_light_toggle.value = true;
                go_light_type.value   = 'Guide';
                go_cue_dur.value      = 8;
                
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
                violation_dur.value  = 0.1;
                error_dur.value      = 0.1;
                temp_error_dur.value = 0.1;
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

            if n_trials_stage > 70 && frac_violations < 0.9 && frac_correct > 0.9
                TrainingSection(obj, 'increment_stage');
            end

            %%%%%%%%%%%%%%%%%%%%%%%


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 2 (left port):
        %   Habituation and sidepoking. Here we keep ITIs long and temperror off.
        % The animal learns to sidepoke in response to an auditory go cue and a
        % light guide. Water "give" (30% of reward amt) is automatically provided
        % on the appropriate side for 25 trials in order to help establish that
        % the ports provide water.
        % 
        % Lack of response (i.e. wait_for_spoke times out after 8 seconds) is
        % marked as a violation.
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
                stimulus_min.value     = 0.05;
                stimulus_dur.value     = 0.05;
                stimulus_max.value     = 0.05;

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
                % Turn on light guide, auditory go cue
                wait_for_spoke_dur.value = 8;
                go_aud_toggle.value   = true;
                go_light_toggle.value = true;
                go_light_type.value   = 'Guide';
                go_cue_dur.value      = 8;
                
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
                violation_dur.value  = 0.1;
                error_dur.value      = 0.1;
                temp_error_dur.value = 0.1;
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

            if n_trials_stage > 70 && frac_violations < 0.9 && frac_correct > 0.9
                TrainingSection(obj, 'increment_stage');
            end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 3:
        %   Center->side program with 20 trial blocks. For the first 10 trials
        % of the first 2 blocks, turn give on.
        % 
        % NOTE that we start the animal on 250 ms fixation length. This is to
        % prevent the animal from refining the motor program and getting stuck
        % at low fixation lengths during GNP.
        %   
        % Lack of response (i.e. wait_for_spoke times out after 8 seconds) is
        % marked as a violation.
        case 3
            stage_description.value = 'center poking switch blocks (20 block, 10 give)';
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
                stimulus_min.value     = 0.05;
                stimulus_dur.value     = 0.05;
                stimulus_max.value     = 0.05;

                delay_growth.value    = false;
                delay_warm_up.value   = false;
                delay_min.value       = 0.05;
                delay_dur.value       = 0.05;
                delay_max.value       = 0.05;

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.05;
                post_dur.value        = 0.05;
                post_max.value        = 0.05;
                
                % -- Antibias and sides --
                antibias_toggle.value = false;
                LeftProb.value = 1;
                
                % -- Go cue --
                % Turn on light guide, auditory go cue
                wait_for_spoke_dur.value = 8;
                go_aud_toggle.value   = true;
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
                violation_dur.value  = 0.1;
                error_dur.value      = 0.1;
                temp_error_dur.value = 0.1;
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

            if n_trials_stage > 100 && frac_violations < 0.7 && frac_correct > 0.8
                TrainingSection(obj, 'increment_stage');
            end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 4 (introduce Sa/Sb!):
        %   Center->side program with 20 trial blocks. For the first 10 trials
        % of the first 2 blocks, turn give on.
        % 
        % Parameters are all the same as stage 3, except we turn on Sa/Sb.
        case 4
            stage_description.value = 'cpoke blocks snds (20 block, 10 give)';
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
                stimulus_min.value     = 0.05;
                stimulus_dur.value     = 0.05;
                stimulus_max.value     = 0.05;

                delay_growth.value    = false;
                delay_warm_up.value   = false;
                delay_min.value       = 0.05;
                delay_dur.value       = 0.05;
                delay_max.value       = 0.05;

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.05;
                post_dur.value        = 0.05;
                post_max.value        = 0.05;
                
                % -- Antibias and sides --
                antibias_toggle.value = false;
                LeftProb.value = 1;
                
                % -- Go cue --
                % Turn on light guide, auditory go cue
                wait_for_spoke_dur.value = 8;
                go_aud_toggle.value   = true;
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
                % Set ITIs to be a bit shorter (40 s -> 15 s)
                inter_trial_dur_type.value = 'sampled';
                inter_trial_dur.value = 15;
                inter_trial_sample_mean.value = 15;
                inter_trial_sample_std.value = 5;
                inter_trial_max.value = 20;
                
                % -- Timeouts --
                violation_dur.value  = 0.1;
                error_dur.value      = 0.1;
                temp_error_dur.value = 0.1;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                % Turn sounds on!
                sasb_on.value = true;

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

            if n_trials_stage > 100 && frac_violations < 0.7 && frac_correct > 0.8
                TrainingSection(obj, 'increment_stage');
            end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 5 (cpoke randomized):
        %   Center->side, randomized (no blocks). Provide water guide for the
        % first 20 trials.
        %
        % No growing yet. If animals are performing this stage well (can switch
        % quickly), then move them up to GNP.
        case 5
            stage_description.value = 'cpoke random';
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
                stimulus_min.value     = 0.05;
                stimulus_dur.value     = 0.05;
                stimulus_max.value     = 0.05;

                delay_growth.value    = false;
                delay_warm_up.value   = false;
                delay_min.value       = 0.05;
                delay_dur.value       = 0.05;
                delay_max.value       = 0.05;

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.05;
                post_dur.value        = 0.05;
                post_max.value        = 0.05;
                
                % -- Antibias and sides --
                % Turn antibias back on, with beta=3
                antibias_toggle.value = true;
                Beta.value            = 3;
                LeftProb.value        = 0.5;
                
                % -- Go cue --
                % Turn on light guide, auditory go cue
                wait_for_spoke_dur.value = 8;
                go_aud_toggle.value   = true;
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
                violation_dur.value  = 0.1;
                error_dur.value      = 0.1;
                temp_error_dur.value = 0.1;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                % Turn sounds on!
                sasb_on.value = true;

                % -- Miscellaneous --
                drinking_dur.value = 5;
            end

            % Provide water give for the first 20 trials, then turn off.
            if n_trials_stage == 0
                give_prob.value = 1;
                reward_type.value = 'give';
            end

            if n_trials_stage == 20
                give_prob.value = 0;
                reward_type.value = 'poke';
            end
                
            if n_trials_stage > 100 && frac_violations < 0.7 && frac_correct > 0.85
                TrainingSection(obj, 'increment_stage');
            end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 6 (gnp snds):
        %   Center->side, randomized (no blocks). Provide give for the first 20
        % trials. We grow the stimuli lengths to 0.4, resulting in a total fix.
        % length of 0.05 + 0.4 + 0.05 + 0.4 + 0.05 = 0.95
        %
        case 6
            stage_description.value = 'gnp (0.25->0.95s), snds 0.05 -> 0.4 s';
            if n_trials_stage == 0
                % -- SMA --
                init_poke_type.value = 'cpoke_fix';

                % -- Task epochs and growing --
                pre_growth.value  = false;
                pre_warm_up.value = false;
                pre_min.value     = 0.05;
                pre_dur.value     = 0.05;
                pre_max.value     = 0.2;

                stimulus_growth.value  = true;
                stimulus_warm_up.value = true;
                stimulus_min.value     = 0.05;
                stimulus_dur.value     = 0.05;
                stimulus_max.value     = 0.4;
                if value(stimulus_prev_session) >= 0.1 && value(stimulus_prev_session) < value(stimulus_max)
                    stimulus_dur.value = value(stimulus_prev_session) / 2;
                elseif value(stimulus_prev_session) == value(stimulus_max)
                    stimulus_dur.value = value(stimulus_max);
                end

                delay_growth.value    = false;
                delay_warm_up.value   = false;
                delay_min.value       = 0.05;
                delay_dur.value       = 0.05;
                delay_max.value       = 0.05;

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.05;
                post_dur.value        = 0.05;
                post_max.value        = 0.05;
                
                % -- Antibias and sides --
                % Turn antibias back on, with beta=3
                antibias_toggle.value = true;
                Beta.value            = 3;
                LeftProb.value        = 0.5;
                
                % -- Go cue --
                % Turn on light guide, auditory go cue
                wait_for_spoke_dur.value = 8;
                go_aud_toggle.value   = true;
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
                % Cut ITIs down to 1 second.
                inter_trial_dur_type.value = 'sampled';
                inter_trial_dur.value = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value = 1;
                inter_trial_max.value = 3;
                
                % -- Timeouts --
                violation_dur.value  = 0.1;
                error_dur.value      = 0.1;
                temp_error_dur.value = 0.1;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                % Turn sounds on!
                sasb_on.value = true;

                % -- Miscellaneous --
                drinking_dur.value = 5;
            end

            % Provide water give for the first 20 trials, then turn off.
            if n_trials_stage == 0
                give_prob.value = 1;
                reward_type.value = 'give';
            end

            if n_trials_stage == 20
                give_prob.value = 0;
                reward_type.value = 'poke';
            end

            if stimulus_dur >= stimulus_max
                TrainingSection(obj, 'increment_stage');
            end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 7 (gnp del):
        %   Center->side, randomized (no blocks). Grow delay from 0.05 to 0.2.
        %
        %              vvvvvvv
        % pre  | stim | delay | stim | post | GO
        % 0.05 | 0.4  | 0.2   | 0.4  | 0.05 |    => total: 1.1 sec
        % 
        case 7
            stage_description.value = 'gnp (0.95->1.1 s), del 0.05 -> 0.2';
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
                stimulus_min.value     = 0.05;
                stimulus_dur.value     = 0.4;
                stimulus_max.value     = 0.4;

                delay_growth.value    = true;
                delay_warm_up.value   = true;
                delay_min.value       = 0.05;
                delay_dur.value       = 0.05;
                delay_max.value       = 0.2;
                if value(delay_prev_session) >= 0.1 && value(delay_prev_session) < value(delay_max)
                    delay_dur.value = value(delay_prev_session) / 2;
                elseif value(delay_prev_session) == value(delay_max)
                    delay_dur.value = value(delay_max);
                end
                % Make sure delay growth units are seconds, not %
                delay_fixed_growth_rate.value = 0.001;
                delay_fixed_growth_unit.value = 's';

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.05;
                post_dur.value        = 0.05;
                post_max.value        = 0.05;
                
                % -- Antibias and sides --
                % Turn antibias back on, with beta=3
                antibias_toggle.value = true;
                Beta.value            = 3;
                LeftProb.value        = 0.5;
                
                % -- Go cue --
                % Use the light guide (not the go light cue), auditory go cue
                wait_for_spoke_dur.value = 8;
                go_aud_toggle.value   = true;
                go_light_toggle.value = false;
                go_cue_dur.value      = 0.05;
                guide_toggle.value  = true;
                guide_prob.value    = 1.0;
                guide_type.value    = 'Guide';
                guide_pre_dur.value = 0.05;
                guide_cue_dur.value = 8;
                
                % -- Temp error --
                temp_error_penalty.value = false;
                temp_error_water_delay.value = 0;
                retry_type.value = 'single';
                
                % -- Reward period --
                reward_light_toggle.value = false;
                reward_sound_option.value = 'N/A';
                
                % -- ITI --
                % Cut ITIs down to 1 second.
                inter_trial_dur_type.value = 'sampled';
                inter_trial_dur.value = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value = 1;
                inter_trial_max.value = 3;
                
                % -- Timeouts --
                violation_dur.value  = 0.1;
                error_dur.value      = 0.1;
                temp_error_dur.value = 0.1;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                % Turn sounds on!
                sasb_on.value = true;

                % -- Miscellaneous --
                drinking_dur.value = 5;
            end

            if delay_dur >= delay_max
                TrainingSection(obj, 'increment_stage');
            end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 8 (wean off light, 0.5 prob):
        %   With fixation grown to 1.1 seconds, we now begin weaning them off
        % the light guide and onto sound-guided behavior. To do this, we decrease
        % the proportion of light guided trials to 0.5.
        %
        % pre  | stim | delay | stim | post | GO
        % 0.05 | 0.4  | 0.2   | 0.4  | 0.05 |    => total: 1.1 sec
        % 
        case 8
            stage_description.value = 'wean off light (0.5 prob)';
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
                stimulus_min.value     = 0.05;
                stimulus_dur.value     = 0.4;
                stimulus_max.value     = 0.4;

                delay_growth.value    = false;
                delay_warm_up.value   = false;
                delay_min.value       = 0.05;
                delay_dur.value       = 0.2;
                delay_max.value       = 0.2;

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.05;
                post_dur.value        = 0.05;
                post_max.value        = 0.05;
                
                % -- Antibias and sides --
                % Turn antibias back on, with beta=3
                antibias_toggle.value = true;
                Beta.value            = 3;
                LeftProb.value        = 0.5;
                
                % -- Go cue --
                % Use the light guide (not the go light cue), auditory go cue
                wait_for_spoke_dur.value = 8;
                go_aud_toggle.value   = true;
                go_light_toggle.value = false;
                go_cue_dur.value      = 0.05;
                guide_toggle.value  = true;
                guide_prob.value    = 0.5;
                guide_type.value    = 'Guide';
                guide_pre_dur.value = 0.05;
                guide_cue_dur.value = 8;
                
                % -- Temp error --
                temp_error_penalty.value = false;
                temp_error_water_delay.value = 0;
                retry_type.value = 'single';
                
                % -- Reward period --
                reward_light_toggle.value = false;
                reward_sound_option.value = 'N/A';
                
                % -- ITI --
                % Cut ITIs down to 1 second.
                inter_trial_dur_type.value = 'sampled';
                inter_trial_dur.value = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value = 1;
                inter_trial_max.value = 3;
                
                % -- Timeouts --
                % Increase the error timeout to 2 seconds.
                violation_dur.value  = 0.1;
                error_dur.value      = 2.0;
                temp_error_dur.value = 0.1;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                % Turn sounds on!
                sasb_on.value = true;

                % -- Miscellaneous --
                drinking_dur.value = 5;
            end

            if value(frac_correct) > 0.75 && n_trials_stage > 100
                TrainingSection(obj, 'increment_stage');
            end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 9 (wean off light, 0 prob):
        %   Now turn off the light guide entirely.
        %
        % pre  | stim | delay | stim | post | GO
        % 0.05 | 0.4  | 0.2   | 0.4  | 0.05 |    => total: 1.1 sec
        % 
        case 9
            stage_description.value = 'wean off light (no light guide)';
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
                stimulus_min.value     = 0.05;
                stimulus_dur.value     = 0.4;
                stimulus_max.value     = 0.4;

                delay_growth.value    = false;
                delay_warm_up.value   = false;
                delay_min.value       = 0.05;
                delay_dur.value       = 0.2;
                delay_max.value       = 0.2;

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.05;
                post_dur.value        = 0.05;
                post_max.value        = 0.05;
                
                % -- Antibias and sides --
                % Turn antibias back on, with beta=3
                antibias_toggle.value = true;
                Beta.value            = 3;
                LeftProb.value        = 0.5;
                
                % -- Go cue --
                % Turn off the light guide.
                wait_for_spoke_dur.value = 8;
                go_aud_toggle.value   = true;
                go_light_toggle.value = false;
                go_cue_dur.value      = 0.05;
                guide_toggle.value  = false;
                guide_prob.value    = 0;
                guide_type.value    = 'Guide';
                guide_pre_dur.value = 0.05;
                guide_cue_dur.value = 8;
                
                % -- Temp error --
                temp_error_penalty.value = false;
                temp_error_water_delay.value = 0;
                retry_type.value = 'single';
                
                % -- Reward period --
                reward_light_toggle.value = false;
                reward_sound_option.value = 'N/A';
                
                % -- ITI --
                % Cut ITIs down to 1 second.
                inter_trial_dur_type.value = 'sampled';
                inter_trial_dur.value = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value = 1;
                inter_trial_max.value = 3;
                
                % -- Timeouts --
                % Increase the error timeout to 3 seconds.
                violation_dur.value  = 0.1;
                error_dur.value      = 3.0;
                temp_error_dur.value = 0.1;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % -- Sounds --
                % Turn sounds on!
                sasb_on.value = true;

                % -- Miscellaneous --
                drinking_dur.value = 5;
            end

            if value(frac_correct) > 0.8 && n_trials_stage > 100
                TrainingSection(obj, 'increment_stage');
            end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 10 (4 asymmetric):
        %   Introduce the 4 asymmetric pairs.
        %
        % pre  | stim | delay | stim | post | GO
        % 0.05 | 0.4  | 0.2   | 0.4  | 0.05 |    => total: 1.1 sec
        % 
        case 10
            stage_description.value = 'intro 4 asymmetric';
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
                stimulus_min.value     = 0.05;
                stimulus_dur.value     = 0.4;
                stimulus_max.value     = 0.4;

                delay_growth.value    = false;
                delay_warm_up.value   = false;
                delay_min.value       = 0.05;
                delay_dur.value       = 0.2;
                delay_max.value       = 0.2;

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.05;
                post_dur.value        = 0.05;
                post_max.value        = 0.05;
                
                % -- Antibias and sides --
                % Turn antibias back on, with beta=3
                antibias_toggle.value = true;
                Beta.value            = 3;
                LeftProb.value        = 0.5;
                
                % -- Go cue --
                % Turn off the light guide.
                wait_for_spoke_dur.value = 8;
                go_aud_toggle.value   = true;
                go_light_toggle.value = false;
                go_cue_dur.value      = 0.05;
                guide_toggle.value  = false;
                guide_prob.value    = 0;
                guide_type.value    = 'Guide';
                guide_pre_dur.value = 0.05;
                guide_cue_dur.value = 8;
                
                % -- Temp error --
                temp_error_penalty.value = false;
                temp_error_water_delay.value = 0;
                retry_type.value = 'single';
                
                % -- Reward period --
                reward_light_toggle.value = false;
                reward_sound_option.value = 'N/A';
                
                % -- ITI --
                % Cut ITIs down to 1 second.
                inter_trial_dur_type.value = 'sampled';
                inter_trial_dur.value = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value = 1;
                inter_trial_max.value = 3;
                
                % -- Timeouts --
                % Increase the error timeout to 3 seconds.
                violation_dur.value  = 0.1;
                error_dur.value      = 3.0;
                temp_error_dur.value = 0.1;
                violation_sound_match_timeout.value = false;
                temp_error_sound_match_timeout.value = false;
                error_sound_match_timeout.value = false;

                % Stimulus table preset - set to 4 asymmetric
                StimulusSection(obj, 'set_preset', 'Asymmetric 4 pairs');

                % -- Sounds --
                % Turn sounds on!
                sasb_on.value = true;

                % -- Miscellaneous --
                drinking_dur.value = 5;
            end

        case 11
            % --------
            % This stage leaves parameters at whatever they were set on previously.
            stage_description.value = 'custom';

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stage 12:
        % We want to get animals to good performance on the 4-pair stimulus set.
        % To do that, we'll turn on the light guide for the pairs that they're
        % bad at, but begin shifting the light guide forward in time.
        %
        % This should help them quickly gain performance on the bad pairs.
        % 
        case 12
            stage_description.value = 'pair-dependent light guide';
            if n_trials_stage == 0
                guide_perf_toggle.value = true;
                % guide_perf_threshold.value = 0.6; % Allow this to be controlled per-rat.
                guide_pre_dur.value = 0.0;
                guide_pre_rate.value = 0.005; % Push guide forward by 5 milliseconds a trial.
            end

        %%% END stage switch statement
        end
    end
end


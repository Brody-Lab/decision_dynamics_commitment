% A training protocol in which we first grow the center poke to 1 second
% (with the help of the go cue), introduce sounds, and then learn the rule.
% Once the rule is learned, the delay between Sa and Sb is grown.
% 
% The stages go as follows:
%   Stage 1, center poke to play GoSound & deliver reward in the side ports.
%   Stage 2, center poke to play GoSound & require side poke for reward.
%   Stage 3, center poke to play GoSound & require side poke. Begin growing
%       the amount of time required in the center port slowly prior to the
%       go sound playing. Grow to 1 second.
%   Stage 4, center poke to play Sa-Sb-Go sound, require side poke. Always
%       reward animal after poking into correct port, even if preceded by
%       incorrect poking.
%   Stage 5, same as before, but now delay the reward in the correct port
%       slowly.
%   Stage 6, same as before, but do not reward incorrect pokes.
%   Stage 7, rule is learned. Grow the delay period.
% 
% TODO set the wait_for_spoke dur
% TODO set the retry temperror stuff, tup forgiveness stuff
% 
function varargout = TS_JY_rulefirst(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action,

    %---------------------------------------------------------------%
    %          get_stage_list                                       %
    %---------------------------------------------------------------%
    case 'get_stage_list'
        varargout{1} = {...
            '1: cp go snd give',...
            '2: cp go snd poke',...
            '3: gnp 0.5s go snd poke',...
            '4: cp 0.5s all snds',...
            '5: gnp 0.7s (grow pre) all snds',...
            '6: gnp 0.9s (grow delay) all snds',...
            '7: gnp 1s (grow post) all snds',...
            '8: cp 1s learn rule, delayed rwd',...
            '9: cp 1.25s learn rule, disable light guides',...
            '10: custom',...
            % '10: cp 1s learn rule, never rwd',...
        };


    %---------------------------------------------------------------%
    %          get_curriculum_update                                %
    %---------------------------------------------------------------%
    case 'get_curriculum_update'
    	stage_num = value(varargin{1});
        switch stage_num
        case 1
            % stage 1
            % -------
            % Teaching the animal that center poking leads to reward from the sideports.
            % Center poking turns off the center LED (which indicates trial availability),
            % plays the go sound, and delivers reward in the left or right port randomly.
            stage_description.value = 'center poke, play go snd, give rwd';
            if n_trials_stage == 0
                init_poke_type.value = 'cpoke_nofix';   % Use SMA_cpoke.m
                reward_type.value = 'give';             % Automatically deliver reward

                % all durations set to minimum
                pre_growth.value      = false;
                pre_min.value         = 0.05;
                pre_dur.value         = 0.05;

                stimulus_growth.value = false;
                stimulus_min.value    = 0.001;
                stimulus_dur.value    = value(stimulus_min);

                delay_growth.value    = false;
                delay_min.value       = 0.001;
                delay_dur.value       = value(delay_min);

                post_growth.value     = false;
                post_min.value        = 0.001;
                post_dur.value        = value(post_min);

                inter_trial_dur_type.value = 'sampled';
                inter_trial_dur.value = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value = 0.5;

                sasb_on.value = false;
                stimuli_on.value = true;
                SoundInterface(obj, 'set', 'TempErrorSound', 'Vol', 0);
            end
            if n_trials_stage > 30
                TrainingSection(obj, 'increment_stage')
            end

        case 2
            % stage 2
            % -------
            % Everything is the same as the previous stage. However, we now require
            % the animal to poke into the sideport in order to receive reward.
            stage_description.value = 'center poke, play go snd, poke rwd';
            if n_trials_stage == 0
                init_poke_type.value = 'cpoke_nofix';
                reward_type.value = 'poke';

                pre_growth.value      = false;
                pre_min.value         = 0.05;
                pre_dur.value         = 0.05;

                stimulus_growth.value = false;
                stimulus_min.value    = 0.001;
                stimulus_dur.value    = value(stimulus_min);

                delay_growth.value    = false;
                delay_min.value       = 0.001;
                delay_dur.value       = value(delay_min);

                post_growth.value     = false;
                post_min.value        = 0.001;
                post_dur.value        = value(post_min);

                inter_trial_dur_type.value = 'sampled';
                inter_trial_dur.value = 1;
                inter_trial_sample_mean.value = 1;
                inter_trial_sample_std.value = 0.5;

                sasb_on.value = false;
                stimuli_on.value = true;
                SoundInterface(obj, 'set', 'TempErrorSound', 'Vol', 0);
            end
            if n_trials_stage > 50
                TrainingSection(obj, 'increment_stage');
            end

        case 3
            % stage 3
            % -------
            % We grow fixation up to 0.5 seconds, with only the go cue playing.
            % This provides enough space for Sa/Sb dur = 0.2 s in the next stage,
            % with everything else getting stuffed into the remaining 0.1 seconds.
            stage_description.value = 'gnp 0.5s: cpoke, go snd, poke rwd';
            if n_trials_stage == 0
                init_poke_type.value = 'cpoke_fix';
                reward_type.value = 'poke';

                pre_growth.value      = false;
                pre_warm_up.value     = false;
                pre_min.value         = 0.05;
                pre_dur.value         = 0.05;
                pre_max.value         = 0.2;

                stimulus_growth.value = true;
                stimulus_warm_up.value = true;
                stimulus_min.value    = 0.001;
                stimulus_dur.value    = value(stimulus_min);
                stimulus_max.value    = 0.25;
                stimulus_fixed_growth_rate.value = 0.002; % 0.004 s per valid trial
                stimulus_fixed_growth_unit.value = 's';

                delay_growth.value    = false;
                delay_warm_up.value   = false;
                delay_min.value       = 0.001;
                delay_dur.value       = value(delay_min);
                delay_max.value       = 0.2;

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.001;
                post_dur.value        = value(post_min);
                post_max.value        = 0.2;

                inter_trial_dur.value = 1;
                inter_trial_dur_type.value = 'stable';
                violation_dur.value = 1;

                stimuli_on.value = true;
                sasb_on.value = false;
                SoundInterface(obj, 'set', 'TempErrorSound', 'Vol', 0);
                SoundInterface(obj, 'set', 'ViolationSound',... 
                                           'Style', 'ToneFMWiggle',...
                                           'Vol', 0.001,...
                                           'Freq1', 5000,...
                                           'FMFreq', 100,...
                                           'FMAmp', 1000,...
                                           'Dur1', value(violation_dur));
            end
            if stimulus_dur == stimulus_max
                TrainingSection(obj, 'increment_stage');
            end
            
        case 4
            % stage 4
            % -------
            % Turn on Sa/Sb, but no growing. This is a (hopefully) quick intermediate
            % stage which allows the animal to become accustomed to hearing Sa/Sb before
            % continuing with gnp.
            stage_description.value = '0.5s: cpoke, all snds, poke rwd';
            if n_trials_stage == 0
                init_poke_type.value = 'cpoke_fix';
                reward_type.value = 'poke';

                pre_growth.value      = false;
                pre_warm_up.value     = false;
                pre_min.value         = 0.05;
                pre_dur.value         = 0.05;
                pre_max.value         = 0.2;

                stimulus_growth.value = false;
                stimulus_warm_up.value = false;
                stimulus_min.value    = 0.001;
                stimulus_dur.value    = 0.2;
                stimulus_max.value    = 0.2;

                delay_growth.value    = false;
                delay_warm_up.value   = false;
                delay_min.value       = 0.001;
                delay_dur.value       = 0.025;
                delay_max.value       = 0.2;

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.001;
                post_dur.value        = 0.025;
                post_max.value        = 0.2;

                inter_trial_dur.value = 1;
                inter_trial_dur_type.value = 'stable';

                stimuli_on.value = true;
                sasb_on.value = true;
                SoundInterface(obj, 'set', 'TempErrorSound', 'Vol', 0);
                SoundInterface(obj, 'set', 'ViolationSound',... 
                                           'Style', 'ToneFMWiggle',...
                                           'Vol', 0.001,...
                                           'Freq1', 5000,...
                                           'FMFreq', 100,...
                                           'FMAmp', 1000,...
                                           'Dur1', value(violation_dur));
            end
            if n_trials_stage > 50 && frac_violations < 0.5
                TrainingSection(obj, 'increment_stage');
            end

        case 5
            % stage 5
            % -------
            % Grow fixation to 0.7 seconds by growing pre to 0.2 s.
            stage_description.value = 'gnp 0.7s, pre->0.2s: cpoke, all snds, poke rwd';
            if n_trials_stage == 0
                init_poke_type.value = 'cpoke_fix';
                reward_type.value = 'poke';

                pre_growth.value      = true;
                pre_warm_up.value     = true;
                pre_min.value         = 0.05;
                pre_dur.value         = 0.05;
                pre_max.value         = 0.2;

                stimulus_growth.value = false;
                stimulus_warm_up.value = false;
                stimulus_min.value    = 0.001;
                stimulus_dur.value    = 0.2;
                stimulus_max.value    = 0.2;

                delay_growth.value    = false;
                delay_warm_up.value   = false;
                delay_min.value       = 0.001;
                delay_dur.value       = 0.025;
                delay_max.value       = 0.2;

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.001;
                post_dur.value        = 0.025;
                post_max.value        = 0.2;

                inter_trial_dur.value = 1;
                inter_trial_dur_type.value = 'stable';
                
                stimuli_on.value = true;
                sasb_on.value = true;
                SoundInterface(obj, 'set', 'TempErrorSound', 'Vol', 0);
                SoundInterface(obj, 'set', 'ViolationSound',... 
                                           'Style', 'ToneFMWiggle',...
                                           'Vol', 0.001,...
                                           'Freq1', 5000,...
                                           'FMFreq', 100,...
                                           'FMAmp', 1000,...
                                           'Dur1', value(violation_dur));
            end
            if pre_dur == pre_max && frac_violations < 0.5
                TrainingSection(obj, 'increment_stage');
            end

        case 6
            % stage 6
            % -------
            % Grow fixation to 0.9 seconds by growing delay to 0.2 s.
            stage_description.value = 'gnp 0.9s, delay->0.2s: cpoke, all snds, poke rwd';
            if n_trials_stage == 0
                init_poke_type.value = 'cpoke_fix';
                reward_type.value = 'poke';

                pre_growth.value      = false;
                pre_warm_up.value     = false;
                pre_min.value         = 0.05;
                pre_dur.value         = 0.2;
                pre_max.value         = 0.2;

                stimulus_growth.value = false;
                stimulus_warm_up.value = false;
                stimulus_min.value    = 0.001;
                stimulus_dur.value    = 0.2;
                stimulus_max.value    = 0.2;

                delay_growth.value    = true;
                delay_warm_up.value   = true;
                delay_min.value       = 0.001;
                delay_dur.value       = 0.025;
                delay_max.value       = 0.2;
                delay_fixed_growth_unit.value = 's';
                delay_fixed_growth_rate.value = 0.004;

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.001;
                post_dur.value        = 0.025;
                post_max.value        = 0.2;

                inter_trial_dur.value = 1;
                inter_trial_dur_type.value = 'stable';
                
                stimuli_on.value = true;
                sasb_on.value = true;
                SoundInterface(obj, 'set', 'TempErrorSound', 'Vol', 0);
                SoundInterface(obj, 'set', 'ViolationSound',... 
                                           'Style', 'ToneFMWiggle',...
                                           'Vol', 0.001,...
                                           'Freq1', 5000,...
                                           'FMFreq', 100,...
                                           'FMAmp', 1000,...
                                           'Dur1', value(violation_dur));
            end
            if delay_dur == delay_max && frac_violations < 0.5
                TrainingSection(obj, 'increment_stage');
            end

        case 7
            % stage 7
            % -------
            % Grow fixation to 1.1 seconds by growing post to 0.2 s.
            stage_description.value = 'gnp 1.1s, post->0.2s: cpoke, all snds, poke rwd';
            if n_trials_stage == 0
                init_poke_type.value = 'cpoke_fix';
                reward_type.value = 'poke';

                pre_growth.value      = false;
                pre_warm_up.value     = false;
                pre_min.value         = 0.05;
                pre_dur.value         = 0.2;
                pre_max.value         = 0.2;

                stimulus_growth.value = false;
                stimulus_warm_up.value = false;
                stimulus_min.value    = 0.001;
                stimulus_dur.value    = 0.2;
                stimulus_max.value    = 0.2;

                delay_growth.value    = false;
                delay_warm_up.value   = false;
                delay_min.value       = 0.001;
                delay_dur.value       = 0.2;
                delay_max.value       = 0.2;

                post_growth.value     = true;
                post_warm_up.value    = true;
                post_min.value        = 0.001;
                post_dur.value        = 0.025;
                post_max.value        = 0.2;

                inter_trial_dur.value = 1;
                inter_trial_dur_type.value = 'stable';
                
                stimuli_on.value = true;
                sasb_on.value = true;
                SoundInterface(obj, 'set', 'TempErrorSound', 'Vol', 0);
            end
            if post_dur == post_max && frac_violations < 0.5
                TrainingSection(obj, 'increment_stage');
            end

        case 8
            % stage 8
            % -------
            % Learn rule, delayed reward. Durations are all frozen at 0.2s, which
            % together results in 1 second total fixation. Temperror is still on.
            stage_description.value = '1s: learn rule, delayed reward';
            if n_trials_stage == 0
                init_poke_type.value = 'cpoke_fix';
                reward_type.value = 'poke';

                pre_growth.value      = false;
                pre_warm_up.value     = false;
                pre_min.value         = 0.05;
                pre_dur.value         = 0.2;
                pre_max.value         = 0.2;

                stimulus_growth.value = false;
                stimulus_warm_up.value = false;
                stimulus_min.value    = 0.001;
                stimulus_dur.value    = 0.2;
                stimulus_max.value    = 0.2;

                delay_growth.value    = false;
                delay_warm_up.value   = false;
                delay_min.value       = 0.001;
                delay_dur.value       = 0.2;
                delay_max.value       = 0.2;

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.001;
                % post_dur.value        = 0.2;
                post_max.value        = 0.2;

                inter_trial_dur.value = 1;
                inter_trial_dur_type.value = 'stable';
                
                stimuli_on.value = true;
                sasb_on.value = true;
                SoundInterface(obj, 'set', 'TempErrorSound', 'Vol', 0);
            end


        case 9
            % stage 9
            % -------
            % This is a stage for the light guided animals training on Set A akrami.
            % It is the same as stage 8, but the stimulus length is set to 0.4, and
            % light guidance is turned off once the animal is is performing well
            % (>50 trials at >0.75 hits).
            stage_description.value = '1.25: learn rule, turn off light guides';
            if n_trials_stage == 0
                init_poke_type.value = 'cpoke_fix';
                reward_type.value = 'poke';
                light_guide_toggle.value = true;
                wfs_light_toggle.value = true;

                pre_growth.value      = false;
                pre_warm_up.value     = false;
                pre_min.value         = 0.05;
                pre_dur.value         = 0.2;
                pre_max.value         = 0.2;

                stimulus_growth.value = true;
                stimulus_warm_up.value = false;
                stimulus_min.value    = 0.001;
                % stimulus_dur.value    = 0.2;
                stimulus_max.value    = 0.4;

                delay_growth.value    = false;
                delay_warm_up.value   = false;
                delay_min.value       = 0.001;
                delay_dur.value       = 0.2;
                delay_max.value       = 0.2;

                post_growth.value     = false;
                post_warm_up.value    = false;
                post_min.value        = 0.001;
                post_dur.value        = 0.05;
                post_max.value        = 0.05;

                inter_trial_dur.value = 1;
                inter_trial_dur_type.value = 'stable';
                
                stimuli_on.value = true;
                sasb_on.value = true;
                SoundInterface(obj, 'set', 'TempErrorSound', 'Vol', 0);
            end
            % We turn off the light guides if they're performing well.
            if n_trials_stage >= 50 && stimulus_dur == stimulus_max && frac_violations < 0.3 && frac_correct >= 0.75
                light_guide_toggle.value = false;
                wfs_light_toggle.value = false;
            end


        case 10
            % state 10
            % --------
            % This stage leaves parameters at whatever they were set on previously.
            
        end
    end
end

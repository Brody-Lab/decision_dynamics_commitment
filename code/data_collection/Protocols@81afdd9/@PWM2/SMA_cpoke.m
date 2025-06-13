function [varargout] = SMA_cpoke(obj, action)

GetSoloFunctionArgs;


switch action

    %---------------------------------------------------------------%
    %          init                                                 %
    %---------------------------------------------------------------%
	case 'init'

        feval(mfilename, obj, 'prepare_next_trial');


    %---------------------------------------------------------------%
    %          prepare_next_trial                                   %
    %---------------------------------------------------------------%
	case 'prepare_next_trial'

        %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% SETUP THE HARDWARE %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%

        %%% minimum time
        min_time= 2.5E-4;  % This is less than the minumum time allowed for a state transition.

        %%% define LEDs and water lines
        left1led    = bSettings('get', 'DIOLINES', 'left1led');
        center1led  = bSettings('get', 'DIOLINES', 'center1led');
        center2led  = bSettings('get', 'DIOLINES', 'center1water');
        if strcmp(fixation_led_type, 'center1led') 
            center2led = center1led;
        end
        right1led   = bSettings('get', 'DIOLINES', 'right1led');
        left1water  = bSettings('get', 'DIOLINES', 'left1water');
        right1water = bSettings('get', 'DIOLINES', 'right1water');


        %%% define state machine assembler
        sma = StateMachineAssembler('full_trial_structure','use_happenings', 1);

        %%% get water valve opening times (based on calibration)
        [LeftWValveTime, RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
        % TODO water multipliers for individual pairs computed here too
        % TODO water multipliers for give computed in the same way too

        % If scalable reward based on fixation length is enabled, we compute the valve
        % opening times for the long trials.
        LeftWValveTime_Scaled = LeftWValveTime;
        RightWValveTime_Scaled = RightWValveTime;
        if value(extrafix_toggle)
            % Grab the current water volumes
            [leftvol, rightvol] = WaterValvesSection(obj, 'get_water_volumes');
            % Compute the scaled water volumes, and use that to compute the corresponding
            % water valve times
            leftvol_scaled = value(extrafix_reward_multiplier) * leftvol;
            rightvol_scaled = value(extrafix_reward_multiplier) * rightvol;
            WaterValvesSection(obj, 'set_water_amounts', leftvol_scaled, rightvol_scaled);
            [LeftWValveTime_Scaled, RightWValveTime_Scaled] = WaterValvesSection(obj, 'get_water_times');
            % Set back to normal
            WaterValvesSection(obj, 'set_water_amounts', leftvol, rightvol);
        end

        %%% set the water reward
        if strcmp(value(current_side), 'LEFT')
            correct_response   = 'Lhi';
            incorrect_response = 'Rhi';
            retry_incorrect_response = 'Rin';
            reward_water_dio   = left1water;
            reward_light_dio   = left1led;
            incorr_light_dio   = right1led;
            reward_valve_time  = LeftWValveTime;
            hit_valve_time_scaled = LeftWValveTime_Scaled;

        elseif strcmp(value(current_side), 'RIGHT')
            correct_response   = 'Rhi';
            incorrect_response = 'Lhi';
            retry_incorrect_response = 'Lin';
            reward_water_dio   = right1water;
            reward_light_dio   = right1led;
            incorr_light_dio   = left1led;
            reward_valve_time  = RightWValveTime;
            hit_valve_time_scaled = RightWValveTime_Scaled;

        end

        %%% scale water reward based on the water multiplier for this pair
        fprintf('reward valve time: %d ->', reward_valve_time);
        st = value(stim_table);
        reward_valve_time = reward_valve_time * st{value(current_pair), 9};
        fprintf('%d\n', reward_valve_time);


        %%% scale water reward based on reward type
        % TODO Need to track water amounts provided through 'give' as well! for incorr trials.
        
        if value(extrafix_toggle)
            reward_small_time = min_time;
            hit_valve_time = reward_valve_time;
            post_go_state = 'wait_for_cout_state';

        elseif strcmp(value(reward_type), 'give')
            reward_small_time = reward_valve_time * 0.3;
            hit_valve_time = reward_valve_time - reward_small_time;
            post_go_state = 'give_reward';

        elseif strcmp(value(reward_type), 'poke')
            reward_small_time = min_time; % will not be used, but keeping sma happy
            hit_valve_time = reward_valve_time;
            post_go_state = 'wait_for_spoke';

        end

        %%% set up sounds
        sa_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'SaSound');
        sa_sound_dur = SoundManagerSection(obj, 'get_sound_duration', 'SaSound');

        sb_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'SbSound');
        sb_sound_dur = SoundManagerSection(obj, 'get_sound_duration', 'SbSound');

        go_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'GoSound');
        go_sound_dur = SoundManagerSection(obj, 'get_sound_duration', 'GoSound');

        violation_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'ViolationSound');
        error_sound_id      = SoundManagerSection(obj, 'get_sound_id', 'ErrorSound');
        temp_error_sound_id = SoundManagerSection(obj, 'get_sound_id', 'TempErrorSound');

        reward_sound_id     = SoundManagerSection(obj, 'get_sound_id', 'RewardSound');
        reward_sound_dur    = SoundManagerSection(obj, 'get_sound_duration', 'RewardSound');

        extrafix_sound_id   = SoundManagerSection(obj, 'get_sound_id', 'ExtraFixSound');

        %%% wait for spoke conditions
        if value(wait_for_spoke_Tup_forgiveness)
            spoke_Tup_state = 'wait_for_cpoke';
        else
            spoke_Tup_state = 'violation_state';
        end

        %%% error conditions
        if value(temp_error_penalty)
            % if single retry, move to error state if wrong twice
            error_type = 'temp_error_state';
            if strcmp(value(retry_type), 'single')
                retry_incorrect_state = 'error_state';
            % if multi, need to get it right to end trial
            elseif strcmp(value(retry_type), 'multi')
                retry_incorrect_state = 'temp_error_state';
            end
        else
            error_type = 'error_state';
            retry_incorrect_state = 'error_state'; % will not be used, but keeping sma happy
        end

        %%% inter trial duration (itd) conditions
        if value(inter_trial_perf_multiplier)
            hit_final_state = 'hit_final_state';
            error_final_state = 'error_final_state';
            violation_final_state = 'violation_final_state';
        else
            hit_final_state = 'general_final_state';
            error_final_state = 'general_final_state';
            violation_final_state = 'general_final_state';
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%       WAVES        %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%
       
        %---------------------------------------------%
        % Note: We are limited to 20 scheduled waves! %
        %---------------------------------------------%

        % Note, settling_in counts towards total time spent center poking. Thus,
        % we subtract settling_in_dur from pre_dur to get the remaining length of
        % sa_sound_preamble. If settling_in_dur and pre_dur are the same, then we can
        % start SaSound as soon as settling_in_dur is held.
        % NB: ShapingSection ensures that settling_in_dur cannot be greater than pre_dur.
        % 
        % TODO Move this functionality to ShapingSection? Ideally, SMA does not have to perform
        %      calculations to determine how long durations should be. This would simplify the
        %      code further.
        fprintf('Old value of sa_preamble: %f\n', value(pre_dur));
        if value(pre_dur) == value(settling_in_dur)
            sa_sound_preamble = min_time;
        else
            sa_sound_preamble = max(value(pre_dur) - value(settling_in_dur), min_time);
        end
        fprintf('New value of sa_preamble: %f\n', value(sa_sound_preamble));

        % fixation wave
        % 2022-12-06: Subtracting away settling_in_dur from cp_fixation_dur, as we do for the
        % other waves (also ensure it's not negative). This is a short-term fix!
        cp_updated_dur = max(value(cp_fixation_dur) - value(settling_in_dur), min_time);
        sma = add_scheduled_wave(sma, 'name', 'cp_fixation_wave',...
                                      'preamble', cp_updated_dur, ...
                                      'sustain', 2);

        % Sa sound
        sma = add_scheduled_wave(sma, 'name', 'sa_sound_wave',...
                                      'preamble', sa_sound_preamble,...
                                      'sustain', sa_sound_dur,...
                                      'sound_trig', sa_sound_id);
        % Sb sound
        sma = add_scheduled_wave(sma, 'name', 'sb_sound_wave',...
                                      'preamble', sa_sound_preamble + sa_sound_dur + value(delay_dur),...
                                      'sustain', sb_sound_dur,...
                                      'sound_trig', sb_sound_id);

        % Go cue sound wave -- triggered if go_aud_toggle is enabled.
        sma = add_scheduled_wave(sma, 'name', 'go_sound_wave', ...
                                      'preamble', 0, ...
                                      'sustain', go_sound_dur, ...
                                      'sound_trig', go_sound_id);

        % Sa/Sb replay sounds -- triggered if reward_sound_option is "Sa/Sb replay"
        sma = add_scheduled_wave(sma, 'name', 'sa_replay_sound_wave',...
                                      'preamble', 0,...
                                      'sustain', value(sa_replay_dur),...
                                      'sound_trig', sa_sound_id);
        sma = add_scheduled_wave(sma, 'name', 'sb_replay_sound_wave',...
                                      'preamble', value(sa_replay_dur) + value(delay_replay_dur),...
                                      'sustain', value(sb_replay_dur),...
                                      'sound_trig', sb_sound_id);

        % Reward sound -- triggered if reward_sound_option is "Reward sound"
        sma = add_scheduled_wave(sma, 'name', 'reward_sound_wave',...
                                      'preamble', 0,...
                                      'sustain', reward_sound_dur,...
                                      'sound_trig', reward_sound_id);

        % go wave -- does not trigger the go cue, but instead is used to time entry into the
        % go state, which itself will play appropriate go cue (can be light or sound cue).
        % (only used in cp_fix_decoupled)
        sma = add_scheduled_wave(sma, 'name', 'go_cue_wave',...
                                      'preamble', sa_sound_preamble + value(stimulus_dur) + value(delay_dur) + value(stimulus_dur) + value(post_dur),...
                                      'sustain', 2);

        % Add cp_fixation_wave hi/lo happening. Allows us to use it as a state output action.
        cpwn = get_wavenumber(sma, 'cp_fixation_wave');
        sma = add_happening_spec(sma, struct(...
                                 'name', {'cp_fixation_wave_hi', 'cp_fixation_wave_lo'},...
                                 'detectorFunctionName', {'wave_high', 'wave_low'},...
                                 'inputNumber', {cpwn, cpwn}));

        % Add go_cue_wave hi/lo happening. Allows us to use it as a state output action.
        gwn = get_wavenumber(sma, 'go_cue_wave');
        sma = add_happening_spec(sma, struct(...
                                    'name', {'go_cue_wave_hi', 'go_cue_wave_lo'},...
                                    'detectorFunctionName', {'wave_high', 'wave_low'},...
                                    'inputNumber', {gwn, gwn}));

        % Go cue light waves -- triggered if go_light_toggle is enabled.
        sma = add_scheduled_wave(sma, 'name', 'go_corr_light_wave', ...
                                      'preamble', 0, ...
                                      'sustain', value(go_cue_dur), ...
                                      'DOut', reward_light_dio);
        sma = add_scheduled_wave(sma, 'name', 'go_incorr_light_wave', ...
                                      'preamble', 0, ...
                                      'sustain', value(go_cue_dur), ...
                                      'DOut', incorr_light_dio);

        % Guide cue light waves -- triggered if guide_toggle is enabled.
        sma = add_scheduled_wave(sma, 'name', 'guide_corr_light_wave', ...
                                      'preamble', value(go_cue_dur) + value(guide_pre_dur), ...
                                      'sustain', value(guide_cue_dur), ...
                                      'DOut', reward_light_dio);
        sma = add_scheduled_wave(sma, 'name', 'guide_incorr_light_wave', ...
                                      'preamble', value(go_cue_dur) + value(guide_pre_dur), ...
                                      'sustain', value(guide_cue_dur), ...
                                      'DOut', incorr_light_dio);

        %----------------------------------------------------%
        % Determine which waves to trigger from the go_state %
        %----------------------------------------------------%
        go_cue_waves = '';
        if value(go_aud_toggle)
            go_cue_waves = [go_cue_waves ' + go_sound_wave'];
        end
        if value(go_light_toggle)
            switch value(go_light_type)
            case 'Ambiguous'
                go_cue_waves = [go_cue_waves ' + go_corr_light_wave + go_incorr_light_wave'];
            case 'Guide'
                go_cue_waves = [go_cue_waves ' + go_corr_light_wave'];
            case 'Antiguide'
                go_cue_waves = [go_cue_waves ' + go_incorr_light_wave'];
            end
        end
        if value(guide_toggle)
            switch value(guide_type)
            case 'Ambiguous'
                go_cue_waves = [go_cue_waves ' + guide_corr_light_wave + guide_incorr_light_wave'];
            case 'Guide'
                go_cue_waves = [go_cue_waves ' + guide_corr_light_wave'];
            case 'Antiguide'
                go_cue_waves = [go_cue_waves ' + guide_incorr_light_wave'];
            end
        end

        %---------------------------------------------------%
        % Determine which waves to trigger from drink_state %
        %---------------------------------------------------%
        drink_state_waves = '';
        switch value(reward_sound_option)
        case 'Reward sound'
            drink_state_waves = 'reward_sound_wave';
        case 'Sa/Sb replay'
            drink_state_waves = 'sa_replay_sound_wave + sb_replay_sound_wave';
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%       STATES       %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%


        %%%%%%%%%%%%%%%%% CENTER POKE, NO SOUNDS, GIVE REWARD %%%%%%%%%%%%%%%%%
        if strcmp(value(reward_type), 'give') && ~value(stimuli_on)

            %%% Wait for center poke
            sma = add_state(sma, 'name', 'wait_for_cpoke',...
                                 'output_actions', {'DOut', center1led},...
                                 'input_to_statechange', {'Cin',  'cpoke';...
                                                          'Chi',  'cpoke'});

            %%% If animal cpoked, trigger reward
            sma = add_state(sma, 'name', 'cpoke',...
                                 'self_timer', reward_small_time,...
                                 'output_actions', {'DOut', reward_water_dio + center2led * value(fixation_led) },...
                                 'input_to_statechange', {'Tup', 'current_state+1'});


            %%% Nose in center (no settling in state here)
            sma = add_state(sma, 'output_actions', {'DOut', center2led * value(fixation_led)},...
                                 'input_to_statechange', {'Cout', 'current_state+1';...
                                                          'Clo',  'current_state+1'});

            %%% Nose out of center (no violations here)
            sma = add_state(sma, 'self_timer', value(legal_cbreak_dur),...
                                 'output_actions', {'DOut', center2led * value(fixation_led)},...
                                 'input_to_statechange', {'Cin', 'current_state-1';...
                                                          'Chi', 'current_state-1';...
                                                          'Tup', 'wait_for_spoke'});


        %%%%%%%%%%%%%%%%% CENTER POKE, SOUNDS, GIVE REWARD or REQ RULE, W/O FIXATION %%%%%%%%%%%%%%%%%
        elseif value(stimuli_on) && strcmp(value(init_poke_type), 'cpoke_nofix')

            %%% Wait for center poke
            sma = add_state(sma, 'name', 'wait_for_cpoke',...
                                 'output_actions', {'DOut', center1led},...
                                 'input_to_statechange', {'Cin',  'cpoke';...
                                                          'Chi',  'cpoke'});

            %%% Settling in period- if animal breaks fixation here, trial doesn't start
            %%% TODO Why do we have a settling in state in cpoke_nofix?
            sma = add_state(sma, 'name', 'cpoke',...
                                 'self_timer', value(settling_in_dur),...
                                 'output_actions', {'DOut', center2led * value(fixation_led)},...
                                 'input_to_statechange', {'Cout',  'wait_for_cpoke';...
                                                          'Tup',   'current_state+1'});

            %%% Animal made it through settling in, start trial & trigger the waves
            sma = add_state(sma, 'self_timer', 0.001,...
                                 'output_actions', {'SchedWaveTrig', 'sa_sound_wave + sb_sound_wave + go_cue_wave',...
                                                    'DOut', center2led * value(fixation_led)},...
                                 'input_to_statechange', {'Tup', 'current_state+1'});

            %%% Nose in center
            sma = add_state(sma, 'output_actions', {'DOut', center2led * value(fixation_led)},...
                                'input_to_statechange', {'Cout',             'current_state+1';...
                                                         'Clo',              'current_state+1';...
                                                         'go_cue_wave_hi', post_go_state});


            %%% Nose out of center (no fixation violation here)
            sma = add_state(sma, 'self_timer', value(legal_cbreak_dur),...
                                 'output_actions', {'DOut', center2led * value(fixation_led)},...
                                 'input_to_statechange', {'Cin', 'current_state-1';...
                                                          'Chi', 'current_state-1';...
                                                          'Tup', 'wait_for_sounds_to_end'});

            %%% If the animal sidepokes before the sounds have finished playing,
            %%% move to violation state or simply log it and wait for sounds to
            %%% finish, depending on whether violation_penalty is on.
            if value(violation_penalty)
                sma = add_state(sma, 'name', 'wait_for_sounds_to_end',...
                                     'input_to_statechange', {'go_cue_wave_hi', post_go_state;...
                                                              'Rin',              'violation_state';...
                                                              'Rout',             'violation_state';...
                                                              'Lin',              'violation_state';...
                                                              'Lout'              'violation_state'});
            else
                sma = add_state(sma, 'name', 'wait_for_sounds_to_end',...
                                     'input_to_statechange', {'go_cue_wave_hi', post_go_state;...
                                                              'Rin',              'early_spoke_state';...
                                                              'Rout',             'early_spoke_state';...
                                                              'Lin',              'early_spoke_state';...
                                                              'Lout',             'early_spoke_state'});
            end

            sma = add_state(sma, 'name', 'early_spoke_state',...
                                         'input_to_statechange', {'go_cue_wave_hi', post_go_state});

            %%% if reward type is give, post_go_state steps here
            sma = add_state(sma, 'name', 'give_reward',...
                                 'self_timer', reward_small_time,...
                                 'output_actions', {'DOut', reward_water_dio},...
                                 'input_to_statechange', {'Tup', 'wait_for_spoke'});


        %%%%%%%%%%%%%%%%% CENTER POKE, SOUNDS, GIVE REWARD or REQ RULE, FIXATION REQ. %%%%%%%%%%%%%%%%%
        elseif value(stimuli_on) && strcmp(value(init_poke_type), 'cpoke_fix')

            %%% Wait for center poke
            sma = add_state(sma, 'name', 'wait_for_cpoke',...
                                 'output_actions', {'DOut', center1led},...
                                 'input_to_statechange', {'Cin',  'settling_in';...
                                                          'Chi',  'settling_in'});

            %%% Settling in period - animal has center poked. If they COut before settling_in_dur,
            %%% we move them back to the start. Otherwise, initiate trial.
            sma = add_state(sma, 'name', 'settling_in',...
                                 'self_timer', value(settling_in_dur),...
                                 'output_actions', {'DOut', center2led * value(fixation_led)},...
                                 'input_to_statechange', {'Cout', 'wait_for_cpoke';...
                                                          'Tup',  'cpoke'});

            %%% Animal has successfully initiated trial. Begin cpoke, and trigger all necessary waves.
            if value(sasb_on)
                cpoke_waves = 'cp_fixation_wave + sa_sound_wave + sb_sound_wave + go_cue_wave';
            else
                cpoke_waves = 'cp_fixation_wave + go_cue_wave';
            end
            sma = add_state(sma, 'name', 'cpoke',...
                                 'self_timer', 2*min_time,...
                                 'output_actions', {'SchedWaveTrig', cpoke_waves;...
                                                    'DOut', center2led * value(fixation_led)},...
                                 'input_to_statechange', {'Tup', 'current_state+1'});

            %%% cpoke+1
            %%% Valid trial if animal makes it through fixation. Handle legal_cbreak, and sidepokes.
            sma = add_state(sma, 'output_actions', {'DOut', center2led * value(fixation_led)},...
                                 'input_to_statechange', {'cp_fixation_wave_hi', 'go_state';...
                                                          'Cout',                'current_state+1';...
                                                          'Clo',                 'current_state+1';...
                                                          'Rin',                 'violation_state';...
                                                          'Rout',                'violation_state';...
                                                          'Lin',                 'violation_state';...
                                                          'Lout',                'violation_state'});

            %%% cpoke+2 (legal cbreak state)
            %%% Nose out of center during the fixation period.
            %%% - If the animal pokes back in before Tup or before cp_fixation_wave goes hi, we ignore this.
            %%% - If the animal stays out for legal_cbreak_dur or pokes into a sidepoke, we count it as a violation.
            sma = add_state(sma, 'self_timer', value(legal_cbreak_dur),...
                                 'output_actions', {'DOut', center2led * value(fixation_led)},...
                                 'input_to_statechange', {'Cin',  'current_state-1';...
                                                          'Chi',  'current_state-1';...
                                                          'cp_fixation_wave_hi', 'violation_state';...
                                                          'Tup',                 'violation_state';...
                                                          'Rin',                 'violation_state';...
                                                          'Rout',                'violation_state';...
                                                          'Lin',                 'violation_state';...
                                                          'Lout',                'violation_state'});

            %%% Go state
            %%% The go_state functions to trigger the go_cue_waves that were defined above (which can include
            %%% any combination of the go cue lights and the go sound). Note that post_go_state can be
            %%% * give_state (reward_type is give)
            %%% * wait_for_spoke (reward_type is poke)
            %%% * wait_for_cout_state (extrafix_toggle is on)
            sma = add_state(sma, 'name', 'go_state',...
                                 'self_timer', 2 * min_time,...
                                 'output_actions', {'SchedWaveTrig', go_cue_waves},...
                                 'input_to_statechange', {'Tup', post_go_state});

            %%% wait for Cout state
            %%% If the animal maintains fixation in the center port long enough for this state to Tup, then it gets
            %%% a larger reward. We handle it by splitting into a separate branch of the SMA (I know, not ideal).
            sma = add_state(sma, 'name', 'wait_for_cout_state',...
                                 'self_timer', value(extrafix_length_multiplier)*value(cp_fixation_dur) - value(cp_fixation_dur),...
                                 'input_to_statechange', {'Cout', 'wait_for_spoke';...
                                                          'Clo', 'wait_for_spoke';...
                                                          'Tup', 'wait_for_spoke_scaled'});

            %%% if reward type is give, post_go_state steps here
            sma = add_state(sma, 'name', 'give_reward',...
                                 'self_timer', reward_small_time,...
                                 'output_actions', {'DOut', reward_water_dio},...
                                 'input_to_statechange', {'Tup', 'wait_for_spoke'});

        %%%%%%%%%%%%%%%%% CENTER POKE, SOUNDS, GIVE REWARD or REQ RULE, FIXATION REQUIRED %%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%% BUT DECOUPLED FROM THE SOUNDS                                   %%%%%%%%%%%%%%%%%
        elseif value(stimuli_on) && strcmp(value(init_poke_type), 'cpoke_fix_decoupled')

            %%% Wait for center poke
            sma = add_state(sma, 'name', 'wait_for_cpoke',...
                                 'output_actions', {'DOut', center1led},...
                                 'input_to_statechange', {'Cin',  'settling_in';...
                                                          'Chi',  'settling_in'});

            %%% Settling in period- if animal breaks fixation here, trial doesn't start
            sma = add_state(sma, 'name', 'cpoke',...
                                 'self_timer', value(settling_in_dur),...
                                 'output_actions', {'DOut', center2led * value(fixation_led)},...
                                 'input_to_statechange', {'Cout',  'wait_for_cpoke';...
                                                          'Tup',   'current_state+1'});

            %%% Settling in period - animal has center poked. If they COut before settling_in_dur,
            %%% we move them back to the start. Otherwise, initiate trial.
            sma = add_state(sma, 'name', 'settling_in',...
                                 'self_timer', value(settling_in_dur),...
                                 'output_actions', {'DOut', center2led * value(fixation_led)},...
                                 'input_to_statechange', {'Cout', 'wait_for_cpoke';...
                                                          'Tup',  'cpoke'});

            %%% Animal has successfully initiated trial. Begin cpoke, and trigger all necessary waves.
            if value(sasb_on)
                cpoke_waves = 'cp_fixation_wave + sa_sound_wave + sb_sound_wave + go_cue_wave';
            else
                cpoke_waves = 'cp_fixation_wave + go_cue_wave';
            end
            sma = add_state(sma, 'name', 'cpoke',...
                                 'self_timer', 2*min_time,...
                                 'output_actions', {'SchedWaveTrig', cpoke_waves;...
                                                    'DOut', center2led * value(fixation_led)},...
                                 'input_to_statechange', {'Tup', 'current_state+1'});

            %%% cpoke+1
            %%% Valid trial if animal makes it through fixation. Handle legal_cbreak, and sidepokes.
            sma = add_state(sma, 'output_actions', {'DOut', center2led * value(fixation_led)},...
                                 'input_to_statechange', {'cp_fixation_wave_hi', 'wait_for_go';...
                                                          'Cout',                'current_state+1';...
                                                          'Clo',                 'current_state+1';...
                                                          'Rin',                 'violation_state';...
                                                          'Rout',                'violation_state';...
                                                          'Lin',                 'violation_state';...
                                                          'Lout',                'violation_state'});

            %%% cpoke+2 (legal cbreak state)
            %%% Nose out of center during the fixation period.
            %%% - If the animal pokes back in before Tup or before cp_fixation_wave goes hi, we ignore this.
            %%% - If the animal stays out for legal_cbreak_dur or pokes into a sidepoke, we count it as a violation.
            sma = add_state(sma, 'self_timer', value(legal_cbreak_dur),...
                                 'output_actions', {'DOut', center2led * value(fixation_led)},...
                                 'input_to_statechange', {'Cin',  'current_state-1';...
                                                          'Chi',  'current_state-1';...
                                                          'cp_fixation_wave_hi', 'violation_state';...
                                                          'Tup',                 'violation_state';...
                                                          'Rin',                 'violation_state';...
                                                          'Rout',                'violation_state';...
                                                          'Lin',                 'violation_state';...
                                                          'Lout',                'violation_state'});

            %%% cp_fixation_wave is over, so the animal can cpoke out. However, sidepokes not
            %%% counted until the go_cue_wave goes hi -- then we move into wait_for_spoke or give_reward
            sma = add_state(sma, 'name', 'wait_for_go',...
                                 'self_timer', 10, ...
                                 'input_to_statechange', {'go_cue_wave_hi', 'go_state'; ...
                                                          'Tup',            'go_state'});

            %%% Go state
            %%% The go_state functions to trigger the go_cue_waves that were defined above (which can include
            %%% any combination of the go cue lights and the go sound).
            sma = add_state(sma, 'name', 'go_state',...
                                 'self_timer', 2 * min_time,...
                                 'output_actions', {'SchedWaveTrig', go_cue_waves},...
                                 'input_to_statechange', {'Tup', post_go_state})

            %%% if reward type is give, post_go_state steps here
            sma = add_state(sma, 'name', 'give_reward',...
                                 'self_timer', reward_small_time,...
                                 'output_actions', {'DOut', reward_water_dio},...
                                 'input_to_statechange', {'Tup', 'wait_for_spoke'});

        else
            error('State machine not written for given parameters! Check SMA_cpoke.m')

        end

        %%%%%%%%%%%%%%%%% STATES UBIQUITOUS TO ALL TRAINING STAGES %%%%%%%%%%%%%%%%%
        
        %%% Wait for animal to poke for reward
        sma = add_state(sma, 'name', 'wait_for_spoke',...
                             'self_timer', value(wait_for_spoke_dur),...
                             'input_to_statechange', {correct_response,   'hit_state';...
                                                      incorrect_response, error_type;...
                                                      'Tup',              spoke_Tup_state});


        %%% Hit state: animal made correct choice & gets reward
        sma = add_state(sma, 'name', 'hit_state',...
                             'self_timer', hit_valve_time,...
                             'output_actions', {'SchedWaveTrig', '-go_corr_light_wave -go_incorr_light_wave -guide_corr_light_wave -guide_incorr_light_wave',...
                                                'DOut', reward_water_dio + reward_light_dio * value(reward_light_toggle)},...
                             'input_to_statechange', {'Tup', 'drink_state'});

        %%% If extrafix_toggle is on and the animal meets the longer poking requirement, we add
        %%% two states: wait_for_spoke_scaled and hit_state_scaled
        sma = add_state(sma, 'name', 'wait_for_spoke_scaled',...
                             'self_timer', value(wait_for_spoke_dur),...
                             'output_actions', {'SoundOut', extrafix_sound_id},...
                             'input_to_statechange', {correct_response,  'hit_state_scaled';...
                                                      incorrect_response, error_type;...
                                                      'Tup',              spoke_Tup_state});

        sma = add_state(sma, 'name', 'hit_state_scaled',...
                             'self_timer', hit_valve_time_scaled,...
                             'output_actions', {'SchedWaveTrig', '-go_corr_light_wave -go_incorr_light_wave -guide_corr_light_wave -guide_incorr_light_wave',...
                                                'DOut', reward_water_dio + reward_light_dio * value(reward_light_toggle)},...
                             'input_to_statechange', {'Tup', 'drink_state'});

        %%% Drink state: animal drinking reward
        sma = add_state(sma, 'name', 'drink_state',...
                             'self_timer', value(drinking_dur),...
                             'output_actions', {'SchedWaveTrig', drink_state_waves,...
                                                'DOut', reward_light_dio * value(reward_light_toggle)},...
                             'input_to_statechange', {'Tup', hit_final_state});

        %%% Temporary Error State: animal get to retry(ies) after penalty and sound
        sma = add_state(sma, 'name', 'temp_error_state',...
                             'self_timer', value(temp_error_dur),...
                             'output_actions', {'SoundOut', temp_error_sound_id},...
                             'input_to_statechange', {'Tup', 'wait_for_spoke_retry'});

        % waiting for retry answer
        sma = add_state(sma, 'name', 'wait_for_spoke_retry',...
                             'self_timer', value(wait_for_spoke_dur),...
                             'input_to_statechange', {correct_response,   'retry_hit_state';...
                                                      retry_incorrect_response, retry_incorrect_state;...
                                                      'Tup',              spoke_Tup_state});

        % if retry is correct, this state allows for delayed water delivery
        sma = add_state(sma, 'name', 'retry_hit_state',...
                             'self_timer', value(temp_error_water_delay),...
                             'output_actions', {'DOut', reward_light_dio * value(reward_light_toggle)},...
                             'input_to_statechange', {'Tup', 'hit_state'});

        %%% Error state: no retries allowed
        % error state does not allow animal to retry after penalty
        sma = add_state(sma, 'name', 'error_state',...
                             'self_timer', value(error_dur),...
                             'output_actions', {'SchedWaveTrig', '-go_corr_light_wave -go_incorr_light_wave -guide_corr_light_wave -guide_incorr_light_wave',...
                                                'SoundOut', error_sound_id},...
                             'input_to_statechange', {'Tup', error_final_state});

        %%% Violation state: turn off any sounds & enter violation penalty
        sma = add_state(sma, 'name', 'violation_state', 'self_timer', 0.001,...
                             'output_actions', ...
                                {'SchedWaveTrig','-sa_sound_wave -sb_sound_wave -go_cue_wave -cp_fixation_wave -go_corr_light_wave -go_incorr_light_wave -guide_corr_light_wave -guide_incorr_light_wave'},...
                             'input_to_statechange', {'Tup', 'violation_penalty_state'});

        sma = add_multi_sounds_state(sma, [-sa_sound_id -sb_sound_id -go_sound_id violation_sound_id],...
                                          'self_timer', value(violation_dur),...
                                          'state_name', 'violation_penalty_state',...
                                          'return_state', violation_final_state);

        %%% Final states- control the inter trial interval and can vary depending on idt performance mult.
        sma = add_state(sma, 'name','general_final_state',...
                             'self_timer', value(inter_trial_dur),...
                             'input_to_statechange', {'Tup', 'check_next_trial_ready'});

        sma = add_state(sma, 'name','hit_final_state',...
                             'self_timer', value(inter_trial_dur) * value(inter_trial_hit_multiplier),...
                             'input_to_statechange', {'Tup', 'check_next_trial_ready'});

        sma = add_state(sma, 'name','error_final_state',...
                             'self_timer', value(inter_trial_dur) * value(inter_trial_error_multiplier),...
                             'input_to_statechange', {'Tup', 'check_next_trial_ready'});

        sma = add_state(sma, 'name','violation_final_state',...
                             'self_timer', value(inter_trial_dur)* value(inter_trial_violation_multiplier),...
                             'input_to_statechange', {'Tup', 'check_next_trial_ready'});


        % send SMA output back to PWM2.m where dispatcher is called
        varargout{1} = sma;
        varargout{2} = {'hit_state', 'error_state', 'violation_state', 'hit_state_scaled'};

    %---------------------------------------------------------------%
    %          reinit                                               %
    %---------------------------------------------------------------%
    case 'reinit'
        currfig = double(gcf);
        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'],...
            'fullname', ['^' mfilename]);

		% Reinitialise at the original GUI position and figure:
		feval(mfilename, obj, 'init');

		% Restore the current figure:
		figure(currfig)
    %---------------------------------------------------------------%
    %          otherwise                                            %
    %---------------------------------------------------------------%
    otherwise
        error('Called action: %s, which is undefined.', action);
end

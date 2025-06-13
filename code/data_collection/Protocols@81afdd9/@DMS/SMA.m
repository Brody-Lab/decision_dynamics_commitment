% DMS State Machine Assmbler (SMA)
%
% Copied from PWM2 SMA_cpoke written by Jess Breda 2022
%
% This SMA allows for assembly of DMS task with or 
% without fixation requiremnts (cp_fixation_wave)

function [varargout] = SMA(obj, action)

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
        right1led   = bSettings('get', 'DIOLINES', 'right1led');
        left1water  = bSettings('get', 'DIOLINES', 'left1water');
        right1water = bSettings('get', 'DIOLINES', 'right1water');


        %%% define state machine assembler
        sma = StateMachineAssembler('full_trial_structure','use_happenings', 1);

        %%% get water valve opening times (based on calibration)
        [LeftWValveTime, RightWValveTime] = WaterValvesSection(obj, 'get_water_times');

        %%% set the water reward
        if strcmp(value(current_side), 'LEFT') 
            correct_response   = 'Lhi';
            incorrect_response = 'Rhi';
            retry_incorrect_response = 'Rin';
            reward_water_dio   = left1water;
            reward_light_dio   = left1led;
            reward_valve_time  = LeftWValveTime;

        elseif strcmp(value(current_side), 'RIGHT')
            correct_response   = 'Rhi';
            incorrect_response = 'Lhi';
            retry_incorrect_response = 'Lin';
            reward_water_dio   = right1water;
            reward_light_dio   = right1led;
            reward_valve_time  = RightWValveTime;
        end

        
        %%% scale water reward based on the water multiplier for this pair
%         fprintf('!!!!!!!!!!!!!!reward valve time: %d\n', reward_valve_time);
        reward_valve_time = reward_valve_time * stim_table{value(current_pair_idx), 5};
%         fprintf('!!!!!!!!!!!!!reward valve time2: %d\n', reward_valve_time);
        
        %%% scale water reward based on reward type
        if strcmp(value(reward_type), 'give')
            reward_small_time = reward_valve_time * 0.3; % hard coded 30% of reward given
            hit_valve_time = reward_valve_time - reward_small_time;
            post_go_state = 'give_reward';

        elseif strcmp(value(reward_type), 'poke')
            reward_small_time = min_time; % will not be used, but keeping sma happy
            hit_valve_time = reward_valve_time;  
            post_go_state = 'wait_for_spoke';
        end
    
        %%% set up sounds
        sa_sound_id           = SoundManagerSection(obj, 'get_sound_id', 'SaSound');
        sa_sound_dur          = SoundInterface(obj, 'get', 'SaSound', 'Dur1');
        
        sb_sound_id           = SoundManagerSection(obj, 'get_sound_id', 'SbSound');
        sb_sound_dur          = SoundInterface(obj, 'get', 'SbSound', 'Dur1');
   
        go_sound_id           = SoundManagerSection(obj, 'get_sound_id', 'GoSound');
        go_sound_dur          = SoundInterface(obj, 'get', 'GoSound', 'Dur1');

        violation_sound_id    = SoundManagerSection(obj, 'get_sound_id', 'ViolationSound');
        error_sound_id        = SoundManagerSection(obj, 'get_sound_id', 'ErrorSound');
        temp_error_sound_id   = SoundManagerSection(obj, 'get_sound_id', 'TempErrorSound');

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

        %%% sound waves
        % determine time prior to first sound after settling_in_period
        % note: ShapingSection ensures that settling_in_dur cannot be
        % greater than pre_dur
        if value(pre_dur) == value(settling_in_dur)
            sa_sound_preamble = min_time;
        else
            sa_sound_preamble = max(value(pre_dur) - value(settling_in_dur), min_time);
        end

        % first sound
        sma = add_scheduled_wave(sma, 'name', 'sa_sound_wave',...
                                      'preamble', sa_sound_preamble,...
                                      'sustain', sa_sound_dur,...
                                      'sound_trig', sa_sound_id);
        % secound sound - 
        sma = add_scheduled_wave(sma, 'name', 'sb_sound_wave',...
                                      'preamble', sa_sound_preamble + sa_sound_dur + value(delay_dur),...
                                      'sustain', sb_sound_dur,...
                                      'sound_trig', sb_sound_id);
        
        %%% Trial Timing Waves
        %% Pre go wave %%
        % This times the trial (delay-sounda-delay-soundb-delay) to keep 
        % track of when side pokes can count as answers. Once this wave goes
        % hi, you move into `go_state` (can be cued or not). 
        % If `sb_extra` is on, it only includes the time of the sb without the extra. 
        % This way, animals can answer while sb is playing and recieve feedback.
    
        sma = add_scheduled_wave(sma, 'name', 'pre_go_wave',...
                                      'preamble', sa_sound_preamble + sa_sound_dur + value(delay_dur) + value(stimulus_dur) + value(post_dur),...
                                      'sustain', 2);

        % add wave hi/lo happening to allow for use as state output action
        pgwn = get_wavenumber(sma, 'pre_go_wave');

        sma = add_happening_spec(sma, struct(...
                                    'name', {'pre_go_wave_hi', 'pre_go_wave_lo'},...
                                    'detectorFunctionName', {'wave_high', 'wave_low'},...
                                    'inputNumber', {pgwn, pgwn}));

        sma = add_scheduled_wave(sma, 'name', 'cp_fixation_wave',...
                                      'preamble', value(cp_fixation_dur), ...
                                      'sustain', 2);

        cpwn = get_wavenumber(sma, 'cp_fixation_wave');
        
        sma = add_happening_spec(sma, struct(...
                                 'name', {'cp_fixation_wave_hi', 'cp_fixation_wave_lo'},...
                                 'detectorFunctionName', {'wave_high', 'wave_low'},...
                                 'inputNumber', {cpwn, cpwn}));


        %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%       STATES       %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%

        %%% Wait for center poke
        sma = add_state(sma, 'name', 'wait_for_cpoke',...
                             'output_actions', {'DOut', center1led},...
                             'input_to_statechange', {'Cin',  'cpoke';...
                                                      'Chi',  'cpoke'});
    
        %%%%%%%%%%%%%%%%% CENTER POKE, NO SOUNDS, GIVE REWARD %%%%%%%%%%%%%%%%%
        if strcmp(value(reward_type), 'give') && ~value(stimuli_on)

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

            %%% Settling in period- if animal breaks fixation here, trial doesn't start
            sma = add_state(sma, 'name', 'cpoke',...
                                 'self_timer', value(settling_in_dur),...
                                 'output_actions', {'DOut', center2led * value(fixation_led)},...
                                 'input_to_statechange', {'Cout',  'wait_for_cpoke';...
                                                          'Tup',   'current_state+1'});

            %%% Animal made it through settling in, start trial & trigger the waves
            sma = add_state(sma, 'self_timer', 0.001,...
                                 'output_actions', {'SchedWaveTrig', 'sa_sound_wave + sb_sound_wave + pre_go_wave',...
                                                    'DOut', center2led * value(fixation_led)},...
                                 'input_to_statechange', {'Tup', 'current_state+1'});

            %%% Nose in center 
            sma = add_state(sma, 'output_actions', {'DOut', center2led * value(fixation_led)},...
                                'input_to_statechange', {'Cout',             'current_state+1';...
                                                         'Clo',              'current_state+1';...
                                                         'pre_go_wave_hi',   'go_state'}); 
                                                                                           

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
                                     'input_to_statechange', {'pre_go_wave_hi',   'go_state';...
                                                              'Rin',              'violation_state';...
                                                              'Rout',             'violation_state';...
                                                              'Lin',              'violation_state';...
                                                              'Lout'              'violation_state'});
            else
                sma = add_state(sma, 'name', 'wait_for_sounds_to_end',...
                                     'input_to_statechange', {'pre_go_wave_hi',   'go_state';...
                                                              'Rin',              'early_spoke_state';...
                                                              'Rout',             'early_spoke_state';...
                                                              'Lin',              'early_spoke_state';...
                                                              'Lout',             'early_spoke_state'});
            end

            sma = add_state(sma, 'name', 'early_spoke_state',...
                                         'input_to_statechange', {'pre_go_wave_hi', 'go_state'});
            
            %%% Trial is over & this state documents it
            sma = add_state(sma, 'name', 'go_state',...
                        'self_timer', min_time,...
                        'input_to_statechange', {'Tup', post_go_state});                    
                                                         
            %%% If reward type is give, post_go_state steps here else,
            %%% it goes to wait_for_spoke
            sma = add_state(sma, 'name', 'give_reward',...
                                 'self_timer', reward_small_time,...
                                 'output_actions', {'DOut', reward_water_dio},...
                                 'input_to_statechange', {'Tup', 'wait_for_spoke'});


        %%%%%%%%%%%%%%%%% CENTER POKE, SOUNDS, GIVE REWARD or REQ RULE, FIXATION REQ. %%%%%%%%%%%%%%%%%
        elseif value(stimuli_on) && strcmp(value(init_poke_type), 'cpoke_fix')
            
            %%% Settling in period- if animal breaks fixation here, trial doesn't start
            sma = add_state(sma, 'name', 'cpoke',...
                                 'self_timer', value(settling_in_dur),...
                                 'output_actions', {'DOut', center2led * value(fixation_led)},...
                                 'input_to_statechange', {'Cout',  'wait_for_cpoke';...
                                                          'Tup',   'current_state+1'});

            %%% Animal made it through settling in, start trial & trigger the waves
            sma = add_state(sma, 'self_timer', 0.001,...
                                 'output_actions', {'SchedWaveTrig',  'pre_go_wave + sa_sound_wave + sb_sound_wave',...
                                                    'DOut', center2led * value(fixation_led)},...
                                 'input_to_statechange', {'Tup', 'current_state+1'});

            %%% Nose in center, valid trial if makes it through fixation
            sma = add_state(sma, 'output_actions', {'DOut', center2led * value(fixation_led)},...
                                 'input_to_statechange', {'pre_go_wave_hi',      'go_state';...
                                                          'Cout',                'current_state+1';...
                                                          'Clo',                 'current_state+1';...
                                                          'Rin',                 'violation_state';...
                                                          'Rout',                'violation_state';...
                                                          'Lin',                 'violation_state';...
                                                          'Lout',                'violation_state'});                                        

            %%% Nose out of center, violation if Tup
            sma = add_state(sma, 'self_timer', value(legal_cbreak_dur),...
                                 'output_actions', {'DOut', center2led * value(fixation_led)},...
                                 'input_to_statechange', {'Cin', 'current_state-1';...
                                                         'Chi',  'current_state-1';...
                                                         'Tup',  'violation_state';...
                                                         'Rin',  'violation_state';...
                                                         'Rout', 'violation_state';...
                                                         'Lin',  'violation_state';...
                                                         'Lout', 'violation_state'});
            
            %%% Trial is over & this state documents it
            sma = add_state(sma, 'name', 'go_state',...
                                 'self_timer', min_time,...
                                 'input_to_statechange', {'Tup', post_go_state});
                                     
            %%% If reward type is give, post_go_state steps here else,
            %%% it goes to wait_for_spoke
            sma = add_state(sma, 'name', 'give_reward',...
                                 'self_timer', reward_small_time,...
                                 'output_actions', {'DOut', reward_water_dio},...
                                 'input_to_statechange', {'Tup', 'wait_for_spoke'});
            
        else
            error('State machine not written for given parameters! Check SMA_cpoke.m')

        end

        %%%%%%%%%%%%%%%%% STATES UBIUQUITOUS TO ALL TRAINING STAGES %%%%%%%%%%%%%%%%%
        %%% Wait for animal to get reward
        sma = add_state(sma, 'name', 'wait_for_spoke',...
                             'self_timer', value(wait_for_spoke_dur),...
                             'input_to_statechange', {correct_response,   'hit_state';...
                                                      incorrect_response, error_type;...
                                                      'Tup',              spoke_Tup_state});
        
        %%% Hit state: animal made correct choice & gets reward
        sma = add_state(sma, 'name', 'hit_state',...
                             'self_timer', hit_valve_time,...
                             'output_actions', {'DOut', reward_water_dio + reward_light_dio},...
                             'input_to_statechange', {'Tup', 'drink_state'});
        
        sma = add_state(sma, 'name', 'drink_state',...
                             'self_timer', value(drinking_dur),...
                             'output_actions', {'DOut', reward_light_dio},...
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
                             'output_actions', {'DOut', reward_light_dio},...
                             'input_to_statechange', {'Tup', 'hit_state'});

        %%% Error state: no retries allowed                     
        % error state does not allow animal to retry after penalty
        sma = add_state(sma, 'name', 'error_state',...
                             'self_timer', value(error_dur),...
                             'output_actions', {'SoundOut', error_sound_id},...
                             'input_to_statechange', {'Tup', error_final_state});

        %%% Violation state: turn off any sounds & enter violation penalty
        sma = add_state(sma,'name','violation_state','self_timer',0.001,...
            'output_actions',{'SchedWaveTrig', '-sa_sound_wave-sb_sound_wave-pre_go_wave-cp_fixation_wave'},...
            'input_to_statechange',{'Tup','violation_penalty_state'}); 
        
        sma = add_multi_sounds_state(sma, [-sa_sound_id -sb_sound_id violation_sound_id],...
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
        
        
        % send SMA output back to DMS.m where dispatcher is called
        varargout{1} = sma;
        varargout{2} = {'hit_state', 'error_state', 'violation_state'};

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

% FixationGrower State Machine Assmbler (SMA) for cpoke
%
% primary used SMA for FixationGrower where a center poke initiates
% the trial. This SMA is flexible for allowing both penalized and non-
% penalized fixations. Note this SMA was copied and modified from DMS2
% so it still has a delayed comparison backbone
%
% visualization of flow can be found here: 
% https://docs.google.com/drawings/d/1cIENQmHLLWzV-P3V8Uvn7bxAAQi8_ttFyRl2te4Nxb0/edit
% 
% Written by Jess Breda July 2024

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
        right1led   = bSettings('get', 'DIOLINES', 'right1led');
        left1water  = bSettings('get', 'DIOLINES', 'left1water');
        right1water = bSettings('get', 'DIOLINES', 'right1water');


        %%% define state machine assembler
        sma = StateMachineAssembler('full_trial_structure','use_happenings', 1);

        %%% get water valve opening times (based on calibration)
        [LeftWValveTime, RightWValveTime] = WaterValvesSection(obj, 'get_water_times');

        %%% set the values based on correct side
        if strcmp(value(current_side), 'LEFT') 
            correct_response         = 'Lhi';
            incorrect_response       = 'Rhi';
            retry_incorrect_response = 'Rin';
            reward_water_dio         = left1water;
            correct_light_dio        = left1led;
            incorrect_light_dio      = right1led;
            reward_valve_time        = LeftWValveTime;

        elseif strcmp(value(current_side), 'RIGHT')
            correct_response         = 'Rhi';
            incorrect_response       = 'Lhi';
            retry_incorrect_response = 'Lin';
            reward_water_dio         = right1water;
            correct_light_dio        = right1led;
            incorrect_light_dio      = left1led;
            reward_valve_time        = RightWValveTime;
        end

        %%% scale water reward by stim multipier, terrpr and/or give guide
        % TODO: check if need this?
        reward_valve_time    = reward_valve_time * stim_table{value(current_pair_idx), 5};
        terror_valve_time    = reward_valve_time * terror_water_frac;
        
        if contains(value(give_type_implemented), 'water')
            give_valve_time  = reward_valve_time * give_water_frac;
            hit_valve_time   = reward_valve_time - give_valve_time;
        else
              hit_valve_time   = reward_valve_time;
        end
    
        %%% set up sounds
        sa_sound_id           = SoundManagerSection(obj, 'get_sound_id', 'SaSound');
        sa_sound_dur          = SoundInterface(obj, 'get', 'SaSound', 'Dur1');
        
        sb_sound_id           = SoundManagerSection(obj, 'get_sound_id', 'SbSound');
        sb_sound_dur          = SoundInterface(obj, 'get', 'SbSound', 'Dur1');
        
        go_sound_id           = SoundManagerSection(obj, 'get_sound_id', 'GoSound');

        violation_sound_id    = SoundManagerSection(obj, 'get_sound_id', 'ViolationSound');
        error_sound_id        = SoundManagerSection(obj, 'get_sound_id', 'ErrorSound');
        temp_error_sound_id   = SoundManagerSection(obj, 'get_sound_id', 'TempErrorSound');
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%       WAVES        %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%

        %% Timing & Stimulus Waves
        
        %%% Trial Timing Waves
        %% Pre go wave 
        % This times the trial from the end of settling in to the go cue
        % (if any). In other words, this times the duation of the trial
        % where violation can occur if you leave the center port for longer
        % than the legal cbreak period. Settling in determines fixation
        % (unlimited retried until you fixate for the required duration) or
        % stimuli being on or off determines what variables create this
        % duration. See ShapingSection for specific logic

        % Once this wave goes hi, you move into `go_state`. If `sb_extra`
        % is on, it only includes the time of the sb without the extra.
        % This way, animals can answer while sb is playing and recieve
        % feedback.
        
        %TODO cled_mapped_to_fixation_dur determines if -pre_go_cled_wave
        % if in the timing and stim waves off
        
        % See ShapingSection(obj, 'calculate_fixation_and_pre_go_durs')
        pre_go_time = value(pre_go_dur);
        
        
        % this wave times the trial
        sma = add_scheduled_wave(sma, 'name', 'pre_go_wave',...
                                      'preamble', pre_go_time,...
                                      'sustain', 2);
        % this wave times the light
        sma = add_scheduled_wave(sma, 'name', 'pre_go_cled_wave',...
                              'preamble', 0,...
                              'sustain', pre_go_time,...
                              'DOut', center1led);
        

        % add wave hi/lo happening to allow for use as state output action
        pgwn = get_wavenumber(sma, 'pre_go_wave');

        sma = add_happening_spec(sma, struct(...
                                    'name', {'pre_go_wave_hi', 'pre_go_wave_lo'},...
                                    'detectorFunctionName', {'wave_high', 'wave_low'},...
                                    'inputNumber', {pgwn, pgwn}));

        %%% Stimulus (sa, sb) Waves
        if value(stimuli_on)
            %% first sound, sa
            sma = add_scheduled_wave(sma, 'name', 'sa_sound_wave',...
                                        'preamble', value(adjusted_pre_dur),...
                                        'sustain', sa_sound_dur,...
                                        'sound_trig', sa_sound_id);
            %% secound sound, sb 
            sma = add_scheduled_wave(sma, 'name', 'sb_sound_wave',...
                                        'preamble', value(adjusted_pre_dur) + sa_sound_dur + value(delay_dur),...
                                        'sustain', sb_sound_dur,...
                                        'sound_trig', sb_sound_id);
            
            % on waves triggered in cpoke state                          
            timing_and_stim_waves_on = 'sa_sound_wave + sb_sound_wave + pre_go_wave + pre_go_cled_wave';
            
            % off waves triggered in violation state
            if cled_mapped_to_fixation_dur
                timing_and_stim_waves_off = '-sa_sound_wave - sb_sound_wave - pre_go_wave';
            else
                timing_and_stim_waves_off = '-sa_sound_wave - sb_sound_wave - pre_go_wave - pre_go_cled_wave';
            end
        else
            % on waves triggered in cpoke state
            timing_and_stim_waves_on = 'pre_go_wave + pre_go_cled_wave';
            
            % off waves triggered in violation state
            if cled_mapped_to_fixation_dur
                timing_and_stim_waves_off = '- pre_go_wave';
            else
                timing_and_stim_waves_off = '- pre_go_wave - pre_go_cled_wave';
            end
        end


        %% Go cue wave (light or sound)
        go_cue_waves_on = '';
        go_cue_waves_off= '';
        switch value(go_type)
        case 'LED_persist'
            go_cue_waves_on = 'go_corr_light_persist_wave + go_incorr_light_persist_wave';
            go_cue_waves_off = '-go_corr_light_persist_wave - go_incorr_light_persist_wave';

            sma = add_scheduled_wave(sma, 'name', 'go_corr_light_persist_wave', ...
                                          'preamble', 0, ...
                                          'sustain', value(go_dur), ...
                                          'loop', -1,...
                                          'DOut', correct_light_dio);

            sma = add_scheduled_wave(sma, 'name', 'go_incorr_light_persist_wave', ...
                                          'preamble', 0, ...
                                          'sustain', value(go_dur), ...
                                          'loop', -1,...
                                          'DOut', incorrect_light_dio);
        case 'LED_flash'
            go_cue_waves_on = 'go_corr_light_flash_wave + go_incorr_light_flash_wave';
            go_cue_waves_off= '';
            
            sma = add_scheduled_wave(sma, 'name', 'go_corr_light_flash_wave', ...
                                          'preamble', 0, ...
                                          'sustain', value(go_dur), ...
                                          'DOut', correct_light_dio);

            sma = add_scheduled_wave(sma, 'name', 'go_incorr_light_flash_wave', ...
                                          'preamble', 0, ...
                                          'sustain', value(go_dur), ...
                                          'DOut', incorrect_light_dio);
                                      
        case {'sound', 'sound_localized'}
            go_cue_waves_on = 'go_sound_wave';
            go_cue_waves_off= '';
            
            sma = add_scheduled_wave(sma, 'name', 'go_sound_wave', ...
                                      'preamble', 0, ...
                                      'sustain', value(go_dur), ...
                                      'sound_trig', go_sound_id);
        end

        %%  Give light wave
        if contains(value(give_type_implemented), 'light')

            if value(give_light_persist); loop = -1; else; loop = 1; end

            % Note extra_give_light_del_dur adds to pre_give_del_dur, such that
            % pre_give_del_dur + extra_give_light_del_dur = total time pre
            % light give. To use when shifting an animal off light -> water
            sma = add_scheduled_wave(sma, 'name', 'give_light_wave', ...
                                  'preamble', value(extra_give_light_del_dur), ...
                                  'sustain', value(give_light_dur), ...
                                  'loop', loop,...
                                  'DOut', correct_light_dio);

            % only give or go could be persistently turned on during 
            % wait_for_spoke and need to be turned off upon answer (or no 
            % answer), so they will share the same off variable to keep it 
            % cleaner in the SMA
            go_or_give_light_waves_off = ['-give_light_wave' go_cue_waves_off];
        else
            go_or_give_light_waves_off = ['' go_cue_waves_off];
        end

        
        %% States
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%       STATES       %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%% Wait for center poke
        sma = add_state(sma, 'name', 'wait_for_cpoke',...
                             'output_actions', {'DOut', center1led},...
                             'input_to_statechange', {'Cin',  'settling_in';...
                                                      'Chi',  'settling_in'});

        %%% Settling in period- if animal breaks fixation here, trial doesn't start
        sma = add_state(sma, 'name', 'settling_in',...
                             'self_timer', value(settling_in_dur),...
                             'output_actions', {'DOut', center1led},...
                             'input_to_statechange', {'Cout',  'wait_for_cpoke';...
                                                      'Rin',   'concurrent_spoke';...
                                                      'Rhi',   'concurrent_spoke';...
                                                      'Lin',   'concurrent_spoke';...
                                                      'Lhi',   'concurrent_spoke';...
                                                      'Tup',   'cpoke'});
       %%% spoked during settling in- can't move on, will wait until side
       % poke is removed then can start cpoking again
       sma = add_state(sma, 'name', 'concurrent_spoke',...
                            'self_timer', 8,...
                             'output_actions', {'DOut', center1led},...
                             'input_to_statechange', {'Rout',   'wait_for_cpoke';...
                                                      'Lout',   'wait_for_cpoke';...
                                                      'Tup',    'wait_for_cpoke';});
                                                  
        %%% Animal made it through settling in, start trial & trigger the waves
        sma = add_state(sma, 'name', 'cpoke',...
                             'self_timer', min_time,...
                             'output_actions', {'SchedWaveTrig', timing_and_stim_waves_on},...
                             'input_to_statechange', {'Tup', 'current_state+1'});
        
        %%% Nose in center- need to be in this state to trigger go cue once
        %%% fixation time (pre_go_wave) is up
        sma = add_state(sma, 'input_to_statechange', {'Cout',             'current_state+1';...
                                                      'Clo',              'current_state+1';...
                                                      'pre_go_wave_hi',   'go_state';...
                                                      'Rin',              'violation_due_to_concurrent_spoke';...
                                                      'Rout',             'violation_due_to_concurrent_spoke';...
                                                      'Rhi',              'violation_due_to_concurrent_spoke';...
                                                      'Lin',              'violation_due_to_concurrent_spoke';...
                                                      'Lout',             'violation_due_to_concurrent_spoke';...
                                                      'Lhi',              'violation_due_to_concurrent_spoke'});

        
        %%% Nose out of center- if settling_in_determines_fixation, then
        %%% violations aren't really possible due to pre_go_wave only
        %%% lasting 0.001 seconds. However, this post_tup_state makes it
        %%% impossible to accidentaly leave cport during that period and
        %%% trigger a violation. It should be noted that any side poking
        %%% will trigger a violation.
        
        if value(settling_in_determines_fixation)
            post_tup_state = 'current_state-1';
        else
            post_tup_state = 'violation_state';
        end
            
        sma = add_state(sma, 'self_timer', value(legal_cbreak_dur),...
                             'input_to_statechange', {'Cin',  'current_state-1';...
                                                      'Chi',  'current_state-1';...
                                                      'Rin',  'violation_due_to_concurrent_spoke';...
                                                      'Rout', 'violation_due_to_concurrent_spoke';...
                                                      'Rhi',  'violation_due_to_concurrent_spoke';...
                                                      'Lin',  'violation_due_to_concurrent_spoke';...
                                                      'Lout', 'violation_due_to_concurrent_spoke';...
                                                      'Lhi',  'violation_due_to_concurrent_spoke';...
                                                      'Tup',  post_tup_state});
        
        %%% determine next state switch conditioned of if reward guide is on or not
        if strcmp(value(give_type_implemented), 'none')
            post_go_state = 'wait_for_spoke';
        else
            % if give is on, create the appropriate states
            post_go_state = 'pre_give_delay';
            
            if value(give_delay_strict_mode)
                sma = add_state(sma, 'name', 'pre_give_delay',...
                     'self_timer', value(give_del_dur),...
                     'input_to_statechange', {'Tup', 'give_state';...
                                              correct_response, 'hit_state';...
                                              incorrect_response, 'error_state'});
            else
                sma = add_state(sma, 'name', 'pre_give_delay',...
                         'self_timer', value(give_del_dur),...
                         'input_to_statechange', {'Tup', 'give_state';...
                                                  correct_response, 'hit_state'});
            end
            
            switch value(give_type_implemented)
            case 'water'
                sma = add_state(sma, 'name', 'give_state',...
                                     'self_timer', give_valve_time,...
                                     'output_actions', {'DOut', reward_water_dio},...
                                     'input_to_statechange', {'Tup', 'wait_for_spoke'});

            case 'light'
                sma = add_state(sma, 'name', 'give_state',...
                                     'self_timer', min_time,...
                                     'output_actions', {'SchedWaveTrig', 'give_light_wave'},...
                                     'input_to_statechange', {'Tup', 'wait_for_spoke'});

            case 'water_and_light'
                sma = add_state(sma, 'name', 'give_state',...
                                     'self_timer', give_valve_time,...
                                     'output_actions', {'DOut', reward_water_dio},...
                                     'input_to_statechange', {'Tup','current_state+1'});
                sma = add_state(sma,...
                                     'self_timer', min_time,...
                                     'output_actions', {'SchedWaveTrig', 'give_light_wave'},...
                                     'input_to_statechange', {'Tup', 'wait_for_spoke'});
            end
        end
        
        %%% Go cue (if any is triggered here)
        sma = add_state(sma, 'name', 'go_state',...
                             'self_timer', value(go_dur),...
                             'output_actions', {'SchedWaveTrig', go_cue_waves_on},...
                             'input_to_statechange', {'Tup', post_go_state});
       
        
        %%% determine error conditions
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

        %%% go cue passed, now we wait for the animal's answer
        sma = add_state(sma, 'name', 'wait_for_spoke',...
                             'self_timer', value(wait_for_spoke_dur),...
                             'input_to_statechange', {correct_response,   'hit_state';...
                                                      incorrect_response, error_type;...
                                                      'Tup',              'no_answer_state'});
        
        %%% Hit state: animal made correct choice & gets reward
        sma = add_state(sma, 'name', 'hit_state',...
                             'self_timer', hit_valve_time,...
                             'output_actions', {'DOut', reward_water_dio,...
                                                'SchedWaveTrig', go_or_give_light_waves_off},...
                             'input_to_statechange', {'Tup', 'drink_state'});
        
        sma = add_state(sma, 'name', 'drink_state',...
                             'self_timer', value(drinking_dur),...
                             'output_actions', {'DOut', correct_light_dio * value(reward_light)},...
                             'input_to_statechange', {'Tup', 'hit_cleanup_state'});

        sma = add_state(sma, 'name', 'hit_cleanup_state',...
                             'self_timer', min_time,...
                             'input_to_statechange', {'Tup', 'final_state'});
        
        %%% Temporary Error State: animal get to retry(ies) after penalty and sound
        sma = add_state(sma, 'name', 'temp_error_state',...
                             'self_timer', value(temp_error_dur),...
                             'output_actions', {'SoundOut', temp_error_sound_id},...
                             'input_to_statechange', {'Tup', 'wait_for_spoke_retry'});
                            
        % waiting for retry answer
        sma = add_state(sma, 'name', 'wait_for_spoke_retry',...
                             'self_timer', value(wait_for_spoke_dur),...
                             'input_to_statechange', {correct_response,        'terror_lights_clean_up';...
                                                      retry_incorrect_response, retry_incorrect_state;...
                                                      'Tup',                    'no_answer_state'});

        % quick pass through state to turn off go/give lights and/or turn
        % on reward light
        sma = add_state(sma, 'name', 'terror_lights_clean_up',...
                             'self_timer', min_time,...
                             'output_actions', {'SchedWaveTrig', go_or_give_light_waves_off,...
                                                'DOut', correct_light_dio * value(reward_light)},...
                             'input_to_statechange', {'Tup', 'terror_water_delay'});
                         
                         
        % if retry is correct, this state allows for delayed water
        % delivery, not a sound to indicate correct pre delivery could be
        % good, in DMS2 we replay the replay here if on
        sma = add_state(sma, 'name', 'terror_water_delay',...
                             'self_timer', value(temp_error_water_delay),...
                             'input_to_statechange', {'Tup', 'terror_hit_state'});

         sma = add_state(sma, 'name', 'terror_hit_state',...
                             'self_timer', terror_valve_time,...
                             'output_actions', {'DOut', reward_water_dio},... 
                             'input_to_statechange', {'Tup', 'terror_drink_state'});
         
        sma = add_state(sma, 'name', 'terror_drink_state',...
                             'self_timer', value(drinking_dur),...
                             'input_to_statechange', {'Tup', 'hit_cleanup_state'});

        %%% Error state: no retries allowed                     
        % error state does not allow animal to retry after penalty
        % two seperate states to allow for dispatcher clean up to happen
        % after poking causing error state is recored into parsed_events
        sma = add_state(sma, 'name', 'error_state',...
                             'self_timer', 0.001,...
                             'input_to_statechange', {'Tup', 'error_penalty_state'});

        sma = add_state(sma, 'name', 'error_penalty_state',...
                             'self_timer', value(error_dur),...
                             'output_actions', {'SoundOut', error_sound_id,...
                                                'SchedWaveTrig', go_or_give_light_waves_off},...
                             'input_to_statechange', {'Tup', 'final_state'});

        %%% Violation state: turn off any sounds & enter violation penalty
        % and pass through concurrent state if violationw was due to a side
        % poke (rather than pulling nose out of center)
        sma = add_state(sma,'name','violation_due_to_concurrent_spoke',...
                            'self_timer',0.001,...
                            'input_to_statechange',{'Tup','violation_state'}); 

        sma = add_state(sma,'name','violation_state','self_timer',0.001,...
            'output_actions',{'SchedWaveTrig', timing_and_stim_waves_off},...
            'input_to_statechange',{'Tup','violation_penalty_state'}); 
        

        sma = add_multi_sounds_state(sma, [-sa_sound_id -sb_sound_id violation_sound_id],...
                                          'self_timer', value(violation_dur),...
                                          'state_name', 'violation_penalty_state',...
                                          'return_state', 'final_state');
        
        %%% No answer state: if the spoke state Tups and there is no penalty, the trial
        %%% cleans-up and moves on
        sma = add_state(sma, 'name','no_answer_state',...
                             'self_timer', min_time,...
                             'output_actions', {'SchedWaveTrig', go_or_give_light_waves_off},...
                             'input_to_statechange', {'Tup', 'final_state'});                                    

        %%% Final states- control the inter trial interval and can vary depending on idt performance mult.
        sma = add_state(sma, 'name','final_state',...
                             'self_timer', value(inter_trial_dur),...
                             'input_to_statechange', {'Tup', 'check_next_trial_ready'});
    
        
        % send SMA output back to FixationGrower.m where dispatcher is called
        varargout{1} = sma;
        varargout{2} = {'hit_cleanup_state', 'error_penalty_state', 'violation_penalty_state', 'no_answer_state'}; 

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

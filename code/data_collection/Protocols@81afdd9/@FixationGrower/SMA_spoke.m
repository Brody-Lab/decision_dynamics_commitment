% FixationGrower State Machine Assembler (SMA)
%
% To be used for TrainingSection stages where animal
% is not required to cpoke. Instead, they can go
% direct to side poking to get reward. Removed from 
% the main SMA.m file for simplicity/readability.

% Diagramed flow chart here 
% https://docs.google.com/drawings/d/1zTRKgtJqePl_RHpezHUVx3qy5kvZMy7pm1dQeFuq0J0/edit

function [varargout] = SMA_spoke(obj, action)

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

        %%% set the values based on correct side
        % TODO clean these up
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

        %%% scale water reward by stim multiple and/or give guide
        reward_valve_time    = reward_valve_time * stim_table{value(current_pair_idx), 5};

        if contains(value(give_type_implemented), 'water')
            give_valve_time  = reward_valve_time * give_water_frac;
            hit_valve_time   = reward_valve_time - give_valve_time;
        else
              hit_valve_time   = reward_valve_time;
        end

        %%% set up sounds
        go_sound_id           = SoundManagerSection(obj, 'get_sound_id', 'GoSound');
        error_sound_id        = SoundManagerSection(obj, 'get_sound_id', 'ErrorSound');
        temp_error_sound_id   = SoundManagerSection(obj, 'get_sound_id', 'TempErrorSound');


        %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%       WAVES        %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%

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
        
        %%% tracking of trial start- to be used in HistorySection
        %%% since it's unique to this SMA
        sma = add_state(sma, 'name', 'spoke_t_start',...
                             'self_timer', min_time,...
                             'input_to_statechange', {'Tup', 'go_state'});
        
        %%% determine next state switch conditioned of if reward guide is on or not
        if strcmp(value(give_type_implemented), 'none')
            post_go_state = 'wait_for_spoke';
        else
            % if give is on, create the appropriate states
            post_go_state = 'pre_give_delay';

            sma = add_state(sma, 'name', 'pre_give_delay',...
                     'self_timer', value(give_del_dur),...
                     'input_to_statechange', {'Tup', 'give_state';...
                                              correct_response, 'hit_state'});
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
                             'input_to_statechange', {correct_response, 'hit_state';...
                                                      incorrect_response, error_type;...   
                                                      'Tup',            'no_answer_state'});

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
                             'input_to_statechange', {'Tup', 'inter_trial_state'});
                         
        %%% Temporary Error State: animal get to retry(ies) after penalty and sound
        sma = add_state(sma, 'name', 'temp_error_state',...
                             'self_timer', value(temp_error_dur),...
                             'output_actions', {'SoundOut', temp_error_sound_id},...
                             'input_to_statechange', {'Tup', 'wait_for_spoke_retry'});
                            
        % waiting for retry answer
        sma = add_state(sma, 'name', 'wait_for_spoke_retry',...
                             'self_timer', value(wait_for_spoke_dur),...
                             'input_to_statechange', {correct_response,        'retry_hit_state';...
                                                      retry_incorrect_response, retry_incorrect_state;...
                                                      'Tup',                    'no_answer_state'});

        % if retry is correct, this state allows for delayed water delivery
        sma = add_state(sma, 'name', 'retry_hit_state',...
                             'self_timer', value(temp_error_water_delay),...
                             'output_actions', {'SchedWaveTrig', go_or_give_light_waves_off},...
                             'input_to_statechange', {'Tup', 'hit_state'});

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
                             'input_to_statechange', {'Tup', 'inter_trial_state'});
                         
        %%% No answer state: if the spoke state Tups and there is no penalty, the trial
        %%% cleans-up and moves on
        sma = add_state(sma, 'name','no_answer_state',...
                             'self_timer', min_time,...
                             'output_actions', {'SchedWaveTrig', go_or_give_light_waves_off},...
                             'input_to_statechange', {'Tup', 'inter_trial_state'});                                    

        %%% Inter trial state- where the long iti can be implemented. Want
        %%% this separate from final state to be able to check
        %%% parsed_events for poke info in HistorySection.m
        sma = add_state(sma, 'name','inter_trial_state',...
                     'self_timer', value(inter_trial_dur),...
                     'input_to_statechange', {'Tup', 'final_state'});


        %%% Final states- control the inter trial interval and can vary depending on idt performance mult.
        sma = add_state(sma, 'name','final_state',...
                             'self_timer', min_time,...
                             'input_to_statechange', {'Tup', 'check_next_trial_ready'});
    
        % send SMA output back to DMS.m where dispatcher is called
        varargout{1} = sma;
        varargout{2} = {'final_state'}; 


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


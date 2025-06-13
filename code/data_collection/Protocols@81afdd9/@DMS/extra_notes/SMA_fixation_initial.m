function [] = SMA(obj, action)

GetSoloFunctionArgs;


switch action

    %---------------------------------------------------------------%
    %          init                                                 %
    %---------------------------------------------------------------%
	case 'init'


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

        %%% set the water reward
        if strcmp(value(current_side), 'LEFT') 
            correct_response   = 'Lhi';
            incorrect_response = 'Rhi';
            reward_water_dio   = left1water;
            reward_light_dio   = left1led;
            reward_valve_time  = LeftWValveTime;
        
        elseif strcmp(value(current_side), 'RIGHT')
            correct_response   = 'Rhi';
            incorrect_response = 'Lhi';
            reward_water_dio   = right1water;
            reward_light_dio   = right1led;
            reward_valve_time  = RightWValveTime;
        end

        %%% set up sounds
        sa_sound_id           = SoundManagerSection(obj, 'get_sound_id', 'SaSound');
        sa_sound_dur          = SoundManagerSection(obj, 'get_sound_duration', 'SaSound');
        
        sb_sound_id           = SoundManagerSection(obj, 'get_sound_id', 'SbSound');
        sb_sound_dur          = SoundManagerSection(obj, 'get_sound_duration', 'SbSound');
        
        go_sound_id           = SoundManagerSection(obj, 'get_sound_id', 'GoSound');
        violation_sound_id    = SoundManagerSection(obj, 'get_sound_id', 'ViolSound');
        error_sound_id        = SoundManagerSection(obj, 'get_sound_id', 'ErrorSound');
        temp_error_sound_id   = SoundManagerSection(obj, 'get_sound_id', 'TempErrorSound');

        %%% error conditions
        if value(temp_error_penalty)
            error_type = 'temp_error_state';
        else
            error_type = 'error_state';
        end

        %%% light conditions
        if value(light_guided)
            side_led_on = 1;
        else
            side_led_on = 0;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%       WAVES        %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%

        %%% fixation wave
        sma = add_scheduled_wave(sma, 'name', 'cp_fixation_wave',...
                                      'preamble', cp_fixation_dur, ...
                                      'sustain', 2);

        % add wave hi/lo happening to allow for use as state output action
        cpwn = get_wavenumber(sma, 'cp_fixation_wave');
        
        sma = add_happening_spec(sma, struct(...
                                 'name', {'cp_fixation_wave_hi', 'cp_fixation_wave_lo'},...
                                 'detectorFunctionName', {'wave_high', 'wave_low'},...
                                 'inputNumber', {cpwn, cpwn}));

        %%% sound waves
        % determine time prior to first sound after settling_in_period
        if value(pre_sound_dur) <= value(settling_in_dur)
            sa_sound_preamble = min_time;
        else
            sa_sound_preamble = max(value(pre_sound_dur) - value(settling_in_dur), min_time);
        end

        % first sound
        sma = add_scheduled_wave(sma, 'name', 'sa_sound_wave',...
                                      'preamble', sa_sound_preamble,...
                                      'sustain', sa_sound_dur,...
                                      'sound_trig', sa_sound_id);
        % secound sound
        sma = add_scheduled_wave(sma, 'name', 'sb_sound_wave',...
                                      'preamble', sa_sound_preamble + sa_sound_dur + value(delay_dur),...
                                      'sustain', sb_sound_dur,...
                                      'sound_trig', sb_sound_id);


        %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%       STATES       %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%

        %%% Wait for center poke
        sma = add_state(sma, 'name', 'wait_for_cpoke',...
                             'output_actions', {'DOut', center1led},...
                             'input_to_statechange', {'Cin',  'cpoke';...
                                                      'Chi',  'cpoke'});

        %%% Settling in period- if animal breaks fixation here, trial doesn't start
        sma = add_state(sma, 'name', 'cpoke',...
                             'self_timer', value(settling_in_dur),...
                             'input_to_statechange', {'Cout',  'wait_for_cpoke';...
                                                      'Tup',   'current_state+1'});
        
        %%% Animal made it through settling in, start trial & trigger the waves
        sma = add_state(sma, 'self_timer', 0.001,...
                             'output_actions', {'SchedWaveTrig', 'cp_fixation_wave + sa_sound_wave + sb_sound_wave'},...
                             'input_to_statechange', {'Tup', 'current_state+1'});

        %%% Nose in center with stimulus waves playing
        sma = add_state(sma, 'input_to_statechange', {'cp_fixation_wave_hi', 'wait_for_spoke'; ...
                                                      'Cout',                'current_state+1';...
                                                      'Clo',                 'current_state+1';...
                                                      'Rin',                 'violation_state';...
                                                      'Rout',                'violation_state';...
                                                      'Lin',                 'violation_state';...
                                                      'Lout',                'violation_state'});
                                                  
        %%% Nose out of center 
        % goes to violation_state if animal doesn't return within legal_cbreak_dur
        sma = add_state(sma, 'self_timer', value(legal_cbreak_dur),...
                             'input_to_statechange', {'Cin',  'current_state-1';...
                                                      'Chi',  'current_state-1';...
                                                      'Tup',  'violation_state';...
                                                      'Rin',  'violation_state';...
                                                      'Rout', 'violation_state';...
                                                      'Lin',  'violation_state';...
                                                      'Lout', 'violation_state'});
        
        %%% Animal didn't violate, wait for choice
        % allows for light guided choice if light_guided = 1, otherwise need to use sounds
        sma = add_state(sma, 'name', 'wait_for_spoke',...
                             'self_timer', 6,...
                             'output_actions', {'SoundOut', go_sound_id,...
                                                'Dout',     side_led_on * reward_light_dio},...
                             'input_to_statechange', {correct_response,    'hit_state';...
                                                      incorrect_response,  error_type;...
                                                      'Tup',               'violation_state'});

        %%% Hit state: animal made correct choice & gets reward
        sma = add_state(sma, 'name', 'hit_state',...
                             'self_timer', reward_valve_time,...
                             'output_actions', {'Dout', reward_water_dio + reward_light_dio},...
                             'input_to_statechange', {'Tup', 'drink_state'});
        
        sma = add_state(sma, 'name', 'drink_state',...
                             'self_timer', value(drinking_dur),...
                             'input_to_statechange', {'Tup', 'final_state'});
        
        %%% Error states
        % temp error allows for animal to retry after penalty
        sma = add_state(sma, 'name', 'temp_error_state',...
                             'self_timer', value(temp_error_timeout),...
                             'output_actions', {'SoundOut', temp_error_sound_id},...
                             'input_to_statechange', {'Tup', 'wait_for_spoke'});
        
        % error state does not allow animal to retry after penalty
        sma = add_state(sma, 'name', 'error_state',...
                             'self_timer', value(error_timeout),...
                             'output_actions', {'SoundOut', error_sound_id},...
                             'input_to_statechange', {'Tup', 'final_state'});

        %%% Violation state: turn off any sounds & enter violation penalty
        sma = add_multi_sounds_state(sma, [-sa_sound_id -sb_sound_id violation_sound_id],...
                                          'self_timer', value(violation_timeout),...
                                          'state_name', 'violation_state',...
                                          'return_state', 'final_state');


        %%% Final state & prepare next trial
        sma = add_state(sma, 'name','final_state',...
                             'self_timer', value(inter_trial_dur),...
                             'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        
        dispatcher('send_assembler', sma, {'hit_state', 'error_state', 'violation_state'});

    %---------------------------------------------------------------%
    %          reint                                                %
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

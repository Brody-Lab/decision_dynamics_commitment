% For debugging purposes.
function [] = SMA_test(obj, action)

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
        % TODO figure out name for second LED (center1water? or center2led)
        left1led    = bSettings('get', 'DIOLINES', 'left1led');
        center1led  = bSettings('get', 'DIOLINES', 'center1led');
        center2led  = bSettings('get', 'DIOLINES', 'center2led');
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

        %%% scale water reward based on reward type
        if strcmp(value(reward_type), 'give')
            reward_small_time = reward_valve_time * 0.3;
            hit_valve_time = reward_valve_time - reward_small_time;
            post_go_state = 'give_reward';

        elseif strcmp(value(reward_type), 'poke')
            hit_valve_time = reward_valve_time;  
            post_go_state = 'wait_for_spoke';
        end
    
        %%% set up sounds
        sa_sound_id           = SoundManagerSection(obj, 'get_sound_id', 'SaSound');
        sa_sound_dur          = SoundManagerSection(obj, 'get_sound_duration', 'SaSound');
        
        sb_sound_id           = SoundManagerSection(obj, 'get_sound_id', 'SbSound');
        sb_sound_dur          = SoundManagerSection(obj, 'get_sound_duration', 'SbSound');
        
        go_sound_id           = SoundManagerSection(obj, 'get_sound_id', 'GoSound');
        %go_sound_dur          = SoundManagerSection(obj, 'get_sound_duraton', 'GoSound');
        go_sound_dur = 0.05;

        violation_sound_id    = SoundManagerSection(obj, 'get_sound_id', 'ViolSound');
        error_sound_id        = SoundManagerSection(obj, 'get_sound_id', 'ErrorSound');
        temp_error_sound_id   = SoundManagerSection(obj, 'get_sound_id', 'TempErrorSound');

        %%% error conditions
        if value(temp_error_penalty)
            error_type = 'temp_error_state';
        else
            error_type = 'error_state';
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

        %%% fixation wave
        sma = add_scheduled_wave(sma, 'name', 'cp_fixation_wave',...
                                      'preamble', value(cp_fixation_dur), ...
                                      'sustain', 2);

        % add wave hi/lo happening to allow for use as state output action
        cpwn = get_wavenumber(sma, 'cp_fixation_wave');
        
        sma = add_happening_spec(sma, struct(...
                                 'name', {'cp_fixation_wave_hi', 'cp_fixation_wave_lo'},...
                                 'detectorFunctionName', {'wave_high', 'wave_low'},...
                                 'inputNumber', {cpwn, cpwn}));

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
        % secound sound
        sma = add_scheduled_wave(sma, 'name', 'sb_sound_wave',...
                                      'preamble', sa_sound_preamble + sa_sound_dur + value(delay_dur),...
                                      'sustain', sb_sound_dur,...
                                      'sound_trig', sb_sound_id);

        % go sound (used only in early training stages)
        sma = add_scheduled_wave(sma, 'name', 'go_sound_wave',...
                                      'preamble', sa_sound_preamble + sa_sound_dur + value(delay_dur) + sb_sound_dur + value(post_dur),...
                                      'sustain', 2,...
                                      'sound_trig', go_sound_id);

        % add wave hi/lo happening to allow for use as state output action
        gswn = get_wavenumber(sma, 'go_sound_wave');

        sma = add_happening_spec(sma, struct(...
                                    'name', {'go_sound_wave_hi', 'go_sound_wave_lo'},...
                                    'detectorFunctionName', {'wave_high', 'wave_low'},...
                                    'inputNumber', {gswn, gswn}));


        %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%       STATES       %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%

        %%% Wait for center poke
        sma = add_state(sma, 'name', 'wait_for_cpoke',...
                             'output_actions', {'DOut', center1led},...
                             'input_to_statechange', {'Cin',  'wait_for_spoke';...
                                                      'Chi',  'wait_for_spoke'});
    

        %%%%%%%%%%%%%%%%% STATES UBIUQTOUS TO ALL TRAINING STAGES %%%%%%%%%%%%%%%%%
        %%% Wait for animal to get reward, if times up, restart trial
        % TODO see note above on spoke_Tup_state
        sma = add_state(sma, 'name', 'wait_for_spoke',...
                             'self_timer', value(wait_for_spoke_dur),...
                             'input_to_statechange', {correct_response,   'hit_state';...
                                                      incorrect_response, 'error_state'});
        
        %%% Hit state: animal made correct choice & gets reward
        sma = add_state(sma, 'name', 'hit_state',...
                             'self_timer', hit_valve_time,...
                             'output_actions', {'DOut', reward_water_dio + reward_light_dio},...
                             'input_to_statechange', {'Tup', 'drink_state'});
        
        sma = add_state(sma, 'name', 'drink_state',...
                             'self_timer', value(drinking_dur),...
                             'input_to_statechange', {'Tup', hit_final_state});

        % error state does not allow animal to retry after penalty
        sma = add_state(sma, 'name', 'error_state',...
                             'self_timer', 5,...
                             'output_actions', {'SoundOut', error_sound_id},...
                             'input_to_statechange', {'Tup', error_final_state});
                         
        %%% Final states- control the inter trial interval and can vary depending on performance
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
end

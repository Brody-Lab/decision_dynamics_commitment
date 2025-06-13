% SMA_spoke
%
% This SMA is intended for use in PWM2 training protocol stages which do not
% require center poking in order to deliver stimuli. Good examples of this are
% the first few stages of the curriculum `JY_spoke_fix`.
% 
% This is a smaller-featured SMA, primarily for use in the first stages of the
% `JY_spoke_fix` training curriculum. The first stage plays sounds and provides
% reward automatically, without any action on the part of the animal. The second
% again plays sounds automatically, but requires a sidepoke in order to deliver
% reward.
% 
% Written by Jorge Yanar July 2022 drawing heavily from SMA_cpoke.m.
%


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
        % TODO figure out name for second LED (center1water? or center2led)
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
            corr_light_dio   = left1led;
            incorr_light_dio = right1led;

        elseif strcmp(value(current_side), 'RIGHT')
            correct_response   = 'Rhi';
            incorrect_response = 'Lhi';
            retry_incorrect_response = 'Lin';
            reward_water_dio   = right1water;
            reward_light_dio   = right1led;
            reward_valve_time  = RightWValveTime;
            corr_light_dio   = right1led;
            incorr_light_dio = left1led;
        end

        %%% error conditions
        if value(temp_error_penalty)
            error_type = 'error_state';
            if strcmp(retry_type, 'single')
                retry_incorrect_state = 'error_state';
            elseif strcmp(retry_type, 'multi')
                retry_incorrect_state = 'temp_error_state';
            end
        else
            error_type            = 'error_state';
            retry_incorrect_state = 'error_state';
        end

        %%% scale water reward based on reward type
        if strcmp(value(reward_type), 'give')
            reward_small_time = reward_valve_time * 0.3;
            hit_valve_time = reward_valve_time - reward_small_time;
            post_trigger_waves_state = 'give_reward';

        elseif strcmp(value(reward_type), 'poke')
            reward_small_time = min_time; % will not be used, but keeping sma happy
            hit_valve_time = reward_valve_time;  
            post_trigger_waves_state = 'wait_for_spoke';
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


        %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%       WAVES        %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%

        sa_sound_preamble = min_time;

        sma = add_scheduled_wave(sma, 'name', 'sa_sound_wave',...
                                      'preamble', sa_sound_preamble,...
                                      'sustain', sa_sound_dur,...
                                      'sound_trig', sa_sound_id);

        sma = add_scheduled_wave(sma, 'name', 'sb_sound_wave',...
                                      'preamble', sa_sound_preamble + sa_sound_dur + value(delay_dur),...
                                      'sustain', sb_sound_dur,...
                                      'sound_trig', sb_sound_id);

        sma = add_scheduled_wave(sma, 'name', 'go_sound_wave',...
                                      'preamble', sa_sound_preamble + sa_sound_dur + value(delay_dur) + sb_sound_dur + value(post_dur),...
                                      'sustain', 0.05,...
                                      'sound_trig', go_sound_id);

        sma = add_scheduled_wave(sma, 'name', 'wait_for_spoke_dur_wave',...
                                      'preamble', value(wait_for_spoke_dur),...
                                      'sustain', 0.001);

        % Go cue light waves -- triggered if go_light_toggle is enabled.
        sma = add_scheduled_wave(sma, 'name', 'go_corr_light_wave', ...
                                      'preamble', 0, ...
                                      'sustain', value(go_cue_dur), ...
                                      'DOut', reward_light_dio);
        sma = add_scheduled_wave(sma, 'name', 'go_incorr_light_wave', ...
                                      'preamble', 0, ...
                                      'sustain', value(go_cue_dur), ...
                                      'DOut', incorr_light_dio);

        % add wave hi/lo happenings to allow for use as a state output action
        gswn = get_wavenumber(sma, 'go_sound_wave');
        sma = add_happening_spec(sma, struct(...
                                    'name', {'go_sound_wave_hi', 'go_sound_wave_lo'},...
                                    'detectorFunctionName', {'wave_high', 'wave_low'},...
                                    'inputNumber', {gswn, gswn}));

        wfswn = get_wavenumber(sma, 'wait_for_spoke_dur_wave');
        sma = add_happening_spec(sma, struct(...
                                    'name', {'wait_for_spoke_dur_wave_hi', 'wait_for_spoke_dur_wave_lo'},...
                                    'detectorFunctionName', {'wave_high', 'wave_low'},...
                                    'inputNumber', {wfswn, wfswn}));

        %------------------------------------------------------------%
        % Determine which waves to trigger at the start of the trial %
        %------------------------------------------------------------%
        start_waves = '';
        if value(sasb_on)
            start_waves = [start_waves ' + sa_sound_wave + sb_sound_wave'];
        end
        if value(go_aud_toggle)
            start_waves = [start_waves ' + go_sound_wave'];
        end
        if value(go_light_toggle)
            switch value(go_light_type)
            case 'Ambiguous'
                start_waves = [start_waves ' + go_corr_light_wave + go_incorr_light_wave'];
            case 'Guide'
                start_waves = [start_waves ' + go_corr_light_wave'];
            case 'Antiguide'
                start_waves = [start_waves ' + go_incorr_light_wave'];
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%       STATES       %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%

        sma = add_state(sma, 'name', 'iti',...
                             'self_timer', value(inter_trial_dur),...
                             'input_to_statechange', {'Tup', 'trigger_waves'});

        sma = add_state(sma, 'name', 'trigger_waves', ...
                             'self_timer', 0.001, ...
                             'output_actions', {'SchedWaveTrig', start_waves},...
                             'input_to_statechange', {'Tup', post_trigger_waves_state});

        sma = add_state(sma, 'name', 'give_reward',...
                             'self_timer', reward_small_time,...
                             'output_actions', {'DOut', reward_water_dio},...
                             'input_to_statechange', {'Tup', 'wait_for_spoke'});

        sma = add_state(sma, 'name', 'wait_for_spoke',...
                             'output_actions', {'SchedWaveTrig', 'wait_for_spoke_dur_wave'},...
                             'input_to_statechange', {correct_response, 'hit_state',...
                                                      incorrect_response, error_type,...
                                                      'wait_for_spoke_dur_wave_hi', 'violation_state'});

        sma = add_state(sma, 'name', 'temp_error_state',...
                             'self_timer', 0.001,...
                             'input_to_statechange', {'Tup', 'wait_for_spoke_retry',...
                                                      'wait_for_spoke_dur_wave_hi','error_state'});

        % TODO implement wait_for_spoke_Tup_forgiveness logic
        sma = add_state(sma, 'name', 'wait_for_spoke_retry', ...
                             'self_timer', value(wait_for_spoke_dur),...
                             'input_to_statechange', {correct_response, 'hit_state',...
                                                      incorrect_response, retry_incorrect_state,...
                                                      'wait_for_spoke_dur_wave_hi', 'error_state',...
                                                      'Tup', 'error_state'}); % Won't ever hit this -- wfs_dur_wave_hi will go off first

        sma = add_state(sma, 'name', 'hit_state',...
                             'self_timer', hit_valve_time,...
                             'output_actions', {'SchedWaveTrig', '- go_corr_light_wave - go_incorr_light_wave - wait_for_spoke_dur_wave',...
                                                'DOut', reward_water_dio},...
                             'input_to_statechange', {'Tup', 'drink_state'});

        sma = add_state(sma, 'name', 'hit_state_scaled', ...
                             'self_timer', hit_valve_time, ...
                             'output_actions', {'SchedWaveTrig', '- go_corr_light_wave - go_incorr_light_wave - wait_for_spoke_dur_wave',...
                                                'DOut', reward_water_dio},...
                             'input_to_statechange', {'Tup', 'drink_state'});

        sma = add_state(sma, 'name', 'drink_state',...
                             'self_timer', value(drinking_dur),...
                             'input_to_statechange', {'Tup', 'check_next_trial_ready'});

        sma = add_state(sma, 'name', 'error_state',...
                             'self_timer', 0.001,...
                             'output_actions', {'SchedWaveTrig', '- go_corr_light_wave - go_incorr_light_wave - wait_for_spoke_dur_wave'},...
                             'input_to_statechange', {'Tup', 'check_next_trial_ready'});

        sma = add_state(sma, 'name', 'violation_state',...
                             'self_timer', 0.001,...
                             'output_actions', {'SchedWaveTrig', '- go_corr_light_wave - go_incorr_light_wave - wait_for_spoke_dur_wave'},...
                             'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        
        % send SMA output back to PWM2.m where dispatcher is called
        varargout{1} = sma;
        varargout{2} = {'hit_state', 'violation_state', 'error_state'};


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

% @PBups/StateMatrixSection

% [x, y] = StateMatrixSection(obj, action, x, y)
%
% HELP HERE
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'         To initialise the section
%
%            'next_trial'   To set up the state matrix for the next trial
%
%            'reinit'       Delete all of this section's GUIs and data,
%                           and reinit, at the same position on the same
%                           figure as the original section GUI was placed.
%
% x, y     Relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI.
%
%

function  [varargout] =  StateMatrixSection(obj, action)

    GetSoloFunctionArgs;
    
    
    switch action
      case 'init'
    
        feval(mfilename, obj, 'next_trial');
    
    %% next_trial
      case 'next_trial'
    
        sma = StateMachineAssembler('full_trial_structure','use_happenings', 1,'add_trialnum_indicator',n_done_trials+1);
        
        min_time= 2.5E-4;  % This is less than the minumum time allowed for a state transition.
        %% TEMPORARY VARS %%
        during_stim_C_state = 'nose_out_state';
        during_stim_L_state = 'current_state';
        during_stim_R_state = 'current_state';
        % center_poke_state   = 'play_stimulus_sound';
        max_resp_time       = 1000;
        drink_time          = 0.5;   

        left1led           = bSettings('get', 'DIOLINES', 'left1led');
        center1led         = bSettings('get', 'DIOLINES', 'center1led');
        right1led          = bSettings('get', 'DIOLINES', 'right1led');
        left1water         = bSettings('get', 'DIOLINES', 'left1water');
        right1water        = bSettings('get', 'DIOLINES', 'right1water');

        %% set up reward quantity, timing, and sides
        [LeftWValveTime,RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
        [StimulusSpecs] = StimulusSection(obj, 'get_stimulus_specs');

        sound_on_dur = min(value(fixed_stim_dur),value(nose_in_center));

        TrialSide = SidesSection(obj, 'get_current_side');

        %% get ITI based on previous trial outcome
        ITI = PenaltySection(obj, 'get_ITI');

        if value(PunishSideChoice) == 0
            incorrect_outcome = 'current_state';
        else
            if value(SideChoicePunishmentType) == 0
                incorrect_outcome = 'error_state';
            else
                incorrect_outcome = 'temp_error_state';
            end
        end
        if value(PunishViol) == 0
            violation_outcome = 'during_stimulus';
            violation_type = 'current_state';
        else
            violation_outcome = 'violation_state';
            if value(ViolPunishmentType) == 0
                violation_type = 'ViolPun';
            else
                violation_type = 'viol_no_sound_state';
            end
        end

        if strcmp(TrialSide, 'l') 
            correct_response         = 'Lin';
            correct_outcome          = 'reward_state';
            incorrect_response       = 'Rin'; 
            % incorrect_outcome        = 'error_state';
            reward_water_dio         = left1water;
            correct_light_dio        = left1led;
            incorrect_light_dio      = right1led;
            reward_valve_time        = LeftWValveTime;

        elseif strcmp(TrialSide, 'r')
            correct_response         = 'Rin';
            correct_outcome          = 'reward_state';
            incorrect_response       = 'Lin';
            % incorrect_outcome        = 'error_state';
            reward_water_dio         = right1water;
            correct_light_dio        = right1led;
            incorrect_light_dio      = left1led;
            reward_valve_time        = RightWValveTime;
        elseif strcmp(TrialSide, 'p')
            correct_response         = 'Rin';
            correct_outcome          = 'probe_state';
            incorrect_response       = 'Lin';
            incorrect_outcome        = 'probe_state';
            reward_water_dio         = 0;
            correct_light_dio        = 0;
            incorrect_light_dio      = 0;
            reward_valve_time        = 0; %just in case we somehow get here

        end
        % setup when center light is on
        if value(center_light)
            center_dout = center1led;
        else
            center_dout = 0;
        end

        if value(go_sound)
            go_id = SoundManagerSection(obj, 'get_sound_id',  'go_sound'); 
            go_dur = SoundManagerSection(obj, 'get_sound_duration', 'go_sound');
        else
            go_id = 0;
            go_dur = 0;
        end

        if value(continue_stim)
            cont_id = SoundManagerSection(obj, 'get_sound_id',  'continue_sound');
            cont_dur = SoundManagerSection(obj, 'get_sound_duration', 'continue_sound');
        else
            cont_id = 0;
            cont_dur = 0;
        end
        if value(replay_stim)
            replay_id = SoundManagerSection(obj, 'get_sound_id',  'replay_sound');
            replay_dur = SoundManagerSection(obj, 'get_sound_duration', 'replay_sound');
        else
            replay_id = 0;
            replay_dur = 0;
        end
        % setup whether cpoke is necessary
        if value(cpoke_first)
            post_iti_state = 'wait_for_cpoke';
            side_led_time = value(fixed_stim_dur)+value(stim_start_delay); % allows us to use same wave for correct spoke, just changing time of light on
        else
            post_iti_state = 'wait_for_spoke';
            side_led_time = max_resp_time;
        end
        
        % Setup stimuli based on stim_type variable
        if value(stim_type) == "Light Only"
            stim_wave = '';
            stim_wave_cleanup = '-led_on';
            post_stim_wave = 'led_on';
            go_preamble = min_time;
            reward_wave = 'direct_reward'; % If just lights on, replay sound doesn't make sense

        elseif value(stim_type) == "Sound Only"
            stim_wave = 'sound_on';
            stim_wave_cleanup = '-sound_on';           
            if value(continue_stim)
                post_stim_wave = '+continue_sound_on';
                stim_wave_cleanup = '-sound_on -continue_sound_on';
            else
                post_stim_wave = '';

            end
            go_preamble = min_time;
            if value(replay_stim)
                reward_wave = '+direct_reward +replay_sound_on';
            else
                reward_wave = '+direct_reward';
            end

        elseif value(stim_type) == "Light AND Sound"
            stim_wave = '+sound_on';
            stim_wave_cleanup = '-sound_on';
            % post_stim_wave = 'led_on';
            if value(continue_stim)
                post_stim_wave = '+led_on +continue_sound_on';
                stim_wave_cleanup = '-sound_on -continue_sound_on';
            else
                post_stim_wave = 'led_on';

            end
            go_preamble = min_time;
            if value(replay_stim)
                reward_wave = '+direct_reward +replay_sound_on';
            else
                reward_wave = '+direct_reward';
            end
        end

        %%%% WAVES BEGIN %%%%
        sma = add_scheduled_wave(sma, 'name', 'direct_reward', 'preamble', reward_delay(1), ...
                                    'sustain', reward_valve_time, 'DOut', reward_water_dio);

        sma = add_scheduled_wave(sma, 'name', 'sound_on', 'preamble', value(stim_start_delay), ...
                                    'sustain', sound_on_dur, ...
                                    'sound_trig', StimulusSpecs.sound_id);
        
        sma = add_scheduled_wave(sma, 'name', 'replay_sound_on', 'preamble', min_time, ...
                                    'sustain', value(replay_dur), ...
                                    'sound_trig', replay_id);

        sma = add_scheduled_wave(sma, 'name', 'continue_sound_on', 'preamble', min_time, ...
                                    'sustain', value(cont_dur), ...
                                    'sound_trig', cont_id);
        sma = add_scheduled_wave(sma, 'name', 'go_on', 'preamble', go_preamble, ...
                                      'sustain', go_dur, ...
                                      'sound_trig', go_id);

        sma = add_scheduled_wave(sma, 'name', 'led_on', 'preamble', value(light_on_delay)+min_time, ...
                                    'sustain', side_led_time, ...
                                    'DOut', correct_light_dio);

        sma = add_scheduled_wave(sma, 'name', 'cpoke_time_wave',  ...
                                      'preamble', value(nose_in_center), ...
                                      'sustain', value(legal_cbreak));
        
        cwn = get_wavenumber(sma, 'cpoke_time_wave');

        sma = add_happening_spec(sma, struct(...
            'name', {'cpoke_time_wave_hi', 'cpoke_time_wave_lo'}, ...
            'detectorFunctionName', {'wave_high', 'wave_low'}, ...
            'inputNumber', {cwn, cwn}));


        %%%% STATES BEGIN %%%%
        sma = add_state(sma, 'name', 'ITI', 'self_timer', ITI, ...
                        'input_to_statechange', {'Tup',post_iti_state});

        sma = add_state(sma, 'name', 'wait_for_cpoke', ...
                        'output_actions', {'DOut', center_dout}, ...
                        'input_to_statechange', {'Cin', 'settling_in'; ...
                        'Lin', 'current_state'; ...
                        'Rin', 'current_state'; ...
                        });

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
                                'input_to_statechange', {'Tup', 'play_stimulus_sound'});

        sma = add_state(sma, 'name', 'wait_for_spoke', 'self_timer', min_time, ...
                        'output_actions', {'SchedWaveTrig', stim_wave}, ...
                        'input_to_statechange', {'Tup', 'go_cue_state'});

        sma = add_state(sma, 'name', 'play_stimulus_sound', 'self_timer', min_time, ...
            'output_actions', {'SoundOut', -StimulusSpecs.sound_id}, ...
            'input_to_statechange', {'Tup', 'current_state+1'});

        sma = add_state(sma,'self_timer', min_time, 'output_actions', {'SchedWaveTrig', stim_wave}, ...
            'input_to_statechange', {'Tup', 'current_state+1'});
        sma = add_state(sma,'self_timer', min_time, 'output_actions', {'SchedWaveTrig', 'cpoke_time_wave'}, ...
            'input_to_statechange', {'Tup', 'current_state+1'});

        sma = add_state(sma, 'name', 'during_stimulus', ...
            'output_actions', {'DOut', center_dout}, ...
            'input_to_statechange', {'Cout', during_stim_C_state; ...
                                    'Lin', during_stim_L_state; ...
                                    'Rin', during_stim_R_state; ...
                                    'cpoke_time_wave_hi', 'go_cue_state'});

        sma = add_state(sma, 'name', 'go_cue_state', 'self_timer', go_dur, ...
            'output_actions', {'SchedWaveTrig','go_on'}, ...
            'input_to_statechange', {correct_response, correct_outcome; ...
                                    incorrect_response, incorrect_outcome; ...
                                    'Tup', 'post_go_state'});
        
        sma = add_state(sma, 'name', 'post_go_state', 'self_timer', max_resp_time, ...
            'output_actions', {'SchedWaveTrig', post_stim_wave}, ...
            'input_to_statechange', {correct_response, correct_outcome; ...
                                    incorrect_response, incorrect_outcome; ...
                                    'Tup', 'post_tup_state'});

        % reward
        sma = add_state(sma, 'name', 'reward_state', 'self_timer', reward_valve_time+reward_delay+drink_time, ...
            'output_actions', {'SchedWaveTrig', reward_wave}, ... %             % 'self_timer', drink_time, ... %
            'input_to_statechange', {'Tup', 'hit_state'});

        sma = add_state(sma, 'name', 'hit_state', 'self_timer', min_time, ...        % 'self_timer', drink_time, ... %
            'output_actions', {'SchedWaveTrig', stim_wave_cleanup}, ...
            'input_to_statechange', {'Tup', 'post_drink_cleanup_state'});

        % error
        sma = add_state(sma, 'name', 'error_state', 'self_timer', min_time, ...
            'output_actions', {'SchedWaveTrig', stim_wave_cleanup}, ...
            'input_to_statechange', {'Tup', 'current_state+1'});  

        sma = PunishInterface(obj, 'add_sma_states', 'ErrorPun', sma, ...
                        'exitstate', 'post_err_cleanup_state');

        % violation
        sma = add_state(sma, 'name', 'nose_out_state', 'self_timer', value(legal_cbreak), ...
            'input_to_statechange', {'Tup', violation_outcome; ...
                                    'Cin', 'during_stimulus'; ...
                                    'cpoke_time_wave_hi', 'go_cue_state'});

        sma = add_state(sma, 'name', 'violation_state', 'self_timer', min_time, ...
            'output_actions', {'SchedWaveTrig', stim_wave_cleanup}, ...
            'input_to_statechange', {'Tup', violation_type});

        sma = PunishInterface(obj, 'add_sma_states', 'ViolPun', sma, ...
                        'exitstate', 'post_err_cleanup_state');
        
        sma = add_state(sma, 'name', 'viol_no_sound_state', 'self_timer', value(viol_no_sound_dur), ...
            'input_to_statechange', {'Tup', 'post_err_cleanup_state'});

        % probe
        sma = add_state(sma, 'name', 'probe_state', 'self_timer', min_time, ...
                        'output_actions', {'SchedWaveTrig', stim_wave_cleanup}, ...
                        'input_to_statechange',{'Tup','final_state'});

        % temp error
        sma = add_state(sma, 'name', 'temp_error_state', 'self_timer', min_time, ...
            'output_actions', {'SchedWaveTrig', stim_wave_cleanup}, ...
            'input_to_statechange', {'Tup', post_iti_state});            

        % sma = PunishInterface(obj, 'add_sma_states', 'TempErrorPun', sma, ...
        %                 'exitstate', post_iti_state);

        sma = add_state(sma, 'name', 'post_err_cleanup_state', 'self_timer', min_time, ...
            'output_actions', {'SchedWaveTrig', stim_wave_cleanup}, ...
            'input_to_statechange', {'Tup', 'final_state'});

        sma = add_state(sma, 'name', 'post_drink_cleanup_state', 'self_timer', min_time, ...
            'output_actions',  {'SchedWaveTrig', '-sound_on -direct_reward -led_on -replay_sound_on'}, ...
            'input_to_statechange', {'Tup', 'final_state'});
        
        sma = add_state(sma, 'name', 'post_tup_state', 'self_timer', min_time, ...
            'output_actions', {'SchedWaveTrig', '-sound_on -direct_reward -led_on -replay_sound_on'}, ...
            'input_to_statechange', {'Tup', 'final_state'});

        sma = add_state(sma, 'name', 'final_state', 'self_timer', min_time, ...
                'input_to_statechange', {'Tup', 'check_next_trial_ready'});

        varargout{1} = sma;
        varargout{2} = {'hit_state', 'error_state', 'violation_state', 'probe_state','post_tup_state'};

        case 'reinit'

        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
          'fullname', ['^' mfilename]);
    
        % Reinitialise at the original GUI position and figure:
        feval(mfilename, obj, 'init');
    end
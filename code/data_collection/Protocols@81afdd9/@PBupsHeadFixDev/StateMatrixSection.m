% @PBups/StateMatrixSection
% WMS; May 2023

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
        
        % get output lines (probably do not need LED out)
        left1led           = bSettings('get', 'DIOLINES', 'left1led');
        right1led          = bSettings('get', 'DIOLINES', 'right1led');
        left1water         = bSettings('get', 'DIOLINES', 'left1water');
        right1water        = bSettings('get', 'DIOLINES', 'right1water');
    
        %% set up sounds
        %  gets sound stim from stimulus section
        %	sound_id
        %	sound_delay
        %	sound_dur
        %	stim_timing
        [StimulusSpecs , StimulatorSpecs] = StimulusSection(obj, 'get_stimulus_specs'); % these are the pbup sounds
       
        trial_start_dur = SoundManagerSection(obj, 'get_sound_duration', 'trial_start_sound');
        trial_start_id = SoundManagerSection(obj, 'get_sound_id',  'trial_start_sound');
        stim_start_dur = SoundManagerSection(obj, 'get_sound_duration', 'stim_start_sound');
        stim_start_id = SoundManagerSection(obj, 'get_sound_id',  'stim_start_sound');        
        go_dur = SoundManagerSection(obj, 'get_sound_duration', 'go_sound');
        go_id = SoundManagerSection(obj, 'get_sound_id',  'go_sound');   
        % get water times for reward
        [LeftWValveTime,RightWValveTime] = WaterValvesSection(obj, 'get_water_times');

        TrialSide = SidesSection(obj, 'get_current_side');
        ITI = PenaltySection(obj, 'get_ITI');

        % setup side specific variables and input/output lines
        if strcmp(TrialSide, 'l') 
            correct_response         = 'Lin';
            incorrect_response       = 'Rin'; 
            reward_water_dio         = left1water;
            correct_light_dio        = left1led;
            incorrect_light_dio      = right1led;
            reward_valve_time        = LeftWValveTime;
            give_valve_time          = LeftWValveTime*value(give_perc);
        elseif strcmp(TrialSide, 'r')
            correct_response         = 'Rin';
            incorrect_response       = 'Lin';
            reward_water_dio         = right1water;
            correct_light_dio        = right1led;
            incorrect_light_dio      = left1led;
            reward_valve_time        = RightWValveTime;
            give_valve_time          = RightWValveTime*value(give_perc);
        end
        if give_hint == 1 % turn reward valve time to the remainder of the total post give reward time
            reward_valve_time    = reward_valve_time*(1-value(give_perc));
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%       WAVES        %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%

        %reward waves
        sma = add_scheduled_wave(sma, 'name', 'direct_reward', 'preamble', reward_delay(1), ...
        'sustain', reward_valve_time, 'DOut', reward_water_dio);

        %give reward wave
        sma = add_scheduled_wave(sma, 'name', 'give_reward', 'preamble', value(stim_start_delay)+value(fixed_stim_dur)+value(go_dur), ...
        'sustain', give_valve_time, 'DOut', reward_water_dio);

        % plays the sound stimulus
        sma = add_scheduled_wave(sma, 'name', 'sound_on', 'preamble', value(stim_start_delay), ...
                                    'sustain', value(fixed_stim_dur), ...
                                    'sound_trig', StimulusSpecs.sound_id);
        % plays the go sound
        sma = add_scheduled_wave(sma, 'name', 'go_on', 'preamble', min_time, ...
                                    'sustain', value(go_dur), ...
                                    'sound_trig', go_id);        
        % plays the sound stimulus
        sma = add_scheduled_wave(sma, 'name', 'reinforce_sound_on', 'preamble', min_time, ...
                                    'sustain', value(fixed_stim_dur), ...
                                    'sound_trig', StimulusSpecs.sound_id);
        % stim light on
        sma = add_scheduled_wave(sma, 'name', 'stim_light', 'preamble', min_time, ...
                                    'sustain', value(stim_start_delay)+value(fixed_stim_dur)+value(stim_start_dur), 'DOut', left1led);

        % reward timing wave to track max drink time
        sma = add_scheduled_wave(sma, 'name', 'drink_time',...
            'preamble', min_time, ...
            'sustain', value(TotDrinkTime));

        dwn = get_wavenumber(sma, 'drink_time');
        swn = get_wavenumber(sma, 'sound_on');

        sma = add_happening_spec(sma, struct(...
            'name', {'drink_time_hi', 'drink_time_lo'},...
            'detectorFunctionName', {'wave_high', 'wave_low'},...
            'inputNumber', {dwn, dwn}));

        sma = add_happening_spec(sma, struct(...
            'name', {'sound_on_hi', 'sound_on_lo'},...
            'detectorFunctionName', {'wave_high', 'wave_low'},...
            'inputNumber', {swn, swn}));

            
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%       STATES       %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%   SMA State Logic  %%%

        if trial_start_sound == 1 %setup whether sound plays before ITI
            first_state = 'trial_start_sound_state';
        else
            first_state = 'iti';
        end

        if vis_stim_light == 1 %setup whether light plays during stim start sound and stim
            stim_light_wave = 'stim_light';
        else
            stim_light_wave = '';
        end

        if stim_start_sound == 1
            post_iti_state = 'stim_start_sound_state';
        else
            if vis_stim_light == 1
                post_iti_state = 'stim_light_on';
            else
                post_iti_state = 'play_stimulus_sound';
            end
        end

        if go_sound == 1
            wave_trig = 'go_on';
        else
            wave_trig = '';
        end

        if PunishITIPokes == 1 %setup whether or not the animal can lick during ITI
            iti_poke_state = 'iti_pun';
        else
            iti_poke_state = 'current_state';
        end

        if PunishStimLicks == 1 
            poke_state = 'stim_pun';
        else
            poke_state = 'current_state';
        end

        if viol_grace_dur == 0
            viol_grace_t = min_time;
            dur_stim_t = value(fixed_stim_dur)+value(stim_start_delay);
        else
            viol_grace_t = viol_grace_dur;
            dur_stim_t = max(value(fixed_stim_dur)+value(stim_start_delay)-viol_grace_dur,min_time);
        end

        if PunishSideChoice == 1 % setup error state types based on PenaltySection
            error_type = 'error_state';
        else
            error_type = 'current_state';
        end

        if StimRewardWait == 1 % setup whether or not the animal can lick during stimulus
            post_stim_sound_state = 'during_stim';
        else
            post_stim_sound_state = 'wait_for_slick';
        end

        if give_hint == 1
            give_wave = 'give_reward';  
            stim_pun_cleanup = '-sound_on-give_reward';
        else
            give_wave = '';
            stim_pun_cleanup = '-sound_on';
        end 

        if delay_reward == 1
            hit_time_state = 'delay_reward_state';
        else
            hit_time_state = 'hit_state';
        end

        if reinforce_sound == 1
            post_hit_state = 'reinforce_state';
        else
            post_hit_state = 'drink_time_state';
        end
        
        %%%   SMA States   %%%

        %generic first state to control trial start state location
        sma = add_state(sma, 'name', 'trial_start', 'self_timer', min_time, ...
            'input_to_statechange', {'Tup', first_state});

        %Chirp which signals trial/iti start
        sma = add_state(sma, 'name', 'trial_start_sound_state', 'self_timer', trial_start_dur, ...
            'output_actions', {'SoundOut', trial_start_id}, ...
            'input_to_statechange', {'Tup', 'current_state+1'});
        %settle in where no licks are punished to give animal time to stop licking
        sma = add_state(sma, 'self_timer', 0.2, ...
            'input_to_statechange', {'Tup', 'iti'});

        sma = add_state(sma, 'name', 'iti', 'self_timer', ITI, ...
            'input_to_statechange', {'Tup', post_iti_state; ...
                                     'Lin', iti_poke_state; ...
                                     'Rin', iti_poke_state; ...
                                     });
        sma = PunishInterface(obj, 'add_sma_states', 'ITIPun', sma, ...
            'name', 'iti_pun', ...
            'exitstate', 'trial_start');

        % sma = add_state(sma, 'name', 'stim_light', 'self_timer', min_time, ...
        %     'output_actions', {'SchedWaveTrig', 'stim_light'}, ...
        %     'input_to_statechange', {'Tup', post_light_state});

        sma = add_state(sma, 'name', 'stim_start_sound_state', 'self_timer', stim_start_dur, ...
            'output_actions', {'SoundOut', stim_start_id,'SchedWaveTrig',stim_light_wave}, ...
            'input_to_statechange', {'Tup', 'play_stimulus_sound'});
        
        sma = add_state(sma, 'name', 'stim_light_on', 'self_timer', min_time, ...
            'output_actions', {'SchedWaveTrig', stim_light_wave}, ...
            'input_to_statechange', {'Tup', 'play_stimulus_sound'});

        % first cleanup sounds and all waves, then trigger sound wave
        sma = add_state(sma, 'name', 'play_stimulus_sound', 'self_timer', min_time, ...
            'output_actions', {'SchedWaveTrig', '-sound_on'}, ...
            'input_to_statechange', {'Tup', 'current_state+1'});
        sma = add_state(sma, 'self_timer', min_time, ... 
            'output_actions', {'SchedWaveTrig', '+sound_on'}, ...
            'input_to_statechange', {'Tup', post_stim_sound_state});

        % add a state to measure the stimulus timing, and gate whether the animal can lick during stim
        sma = add_state(sma, 'name', 'during_stim', ...
            'self_timer', dur_stim_t, ...
            'output_actions', {'SchedWaveTrig', give_wave}, ...
            'input_to_statechange', {'Tup', 'grace_state'; ...
            'Lin', poke_state; ...
            'Rin', poke_state; ...
            'Cin', 'current_state'});   
        
        % add "grace" state pre go cue to allow animal to lick before go cue if option on
        sma = add_state(sma,'name','grace_state','self_timer',viol_grace_t,...
            'input_to_statechange',{'Tup','wait_for_slick'} );

        % punish state for animal licking during stimulus
        sma = add_state(sma, 'name', 'stim_pun', 'self_timer', min_time, ...
            'output_actions', {'SchedWaveTrig', stim_pun_cleanup}, ...
            'input_to_statechange', {'Tup', 'current_state+1'});
        sma = PunishInterface(obj, 'add_sma_states', 'StimPun', sma, ...
            'exitstate', 'post_drink_cleanup_state');
        
        % wait for side response state. 
        sma = add_state(sma, 'name', 'wait_for_slick', 'self_timer', value(slick_timeout), ...
            'output_actions', {'SchedWaveTrig', wave_trig}, ...
            'input_to_statechange', {'Tup', 'side_tup'; ...
                                    correct_response,   hit_time_state;... %change out to var of wait_hit_state or hit_state
                                    incorrect_response, error_type});
        
        sma = add_state(sma, 'name', 'side_tup', 'self_timer', min_time, ...
            'input_to_statechange', {'Tup', 'post_drink_cleanup_state'});
 
        sma = add_state(sma, 'name', 'delay_reward_state', 'self_timer', min_time, ...
            'input_to_statechange', {'sound_on_lo', 'hit_state'});       
        % hit state that triggers the reward wave
        sma = add_state(sma, 'name', 'hit_state', 'self_timer', min_time, ...
            'output_actions', {'SchedWaveTrig', 'direct_reward'} , ...
            'input_to_statechange', {'Tup', post_hit_state});

        sma = add_state(sma, 'name', 'reinforce_state', 'self_timer', min_time, ...
            'output_actions', {'SchedWaveTrig', 'reinforce_sound_on'} , ...
            'input_to_statechange', {'Tup', 'drink_time_state'});
        
        % this state triggers the drink wave timer so we can keep track of total time drinking (which has a hard cap)
        sma = add_state(sma, 'name', 'drink_time_state', 'self_timer',min_time, ...
            'output_actions', {'SchedWaveTrig', 'drink_time'} , ...
            'input_to_statechange', {'Tup', 'current_state+1'});
        
        % drink state which stays active as long as the animal has licked the correct spout in the last BreakDrinkTime seconds,
        % and the total drink time is less than DrinkTime (measured by the timer wave above going lo)
        sma = add_state(sma, 'name', 'drink_state', 'self_timer',value(BreakDrinkTime), ...
            'input_to_statechange', {'Tup', 'post_drink_cleanup_state'; ...
                                     'drink_time_lo', 'post_drink_cleanup_state'; ...
                                      correct_response, 'current_state+1'});
                                    
        sma = add_state(sma, 'name', 'drink_state_licked', 'self_timer',min_time, ...
        'input_to_statechange', {'Tup', 'current_state-1'});           

        % cleans up drink timer wave and any errant stim sounds
        sma = add_state(sma, 'name', 'post_drink_cleanup_state', 'self_timer', min_time, ...
                        'output_actions',  {'SchedWaveTrig', '-sound_on -direct_reward'}, ...
                        'input_to_statechange', {'Tup', 'final_state'});
 
        sma = add_state(sma, 'name', 'post_viol_cleanup_state', 'self_timer', min_time, ...
                        'output_actions',  {'SchedWaveTrig', '-sound_on'}, ...
                        'input_to_statechange', {'Tup', 'final_state'});

        % state that triggers error sound punishment, will go back to the ITI --TODO: figure out whether added SMA states are necessary?

        sma = add_state(sma, 'name', 'error_state', 'self_timer', min_time, ...
            'output_actions', {'SchedWaveTrig', '-sound_on'}, ...
            'input_to_statechange', {'Tup', 'current_state+1'});
            

        sma = PunishInterface(obj, 'add_sma_states', 'ErrorPun', sma, ...
                        'exitstate', 'post_drink_cleanup_state');
        
        sma = add_state(sma, 'name', 'final_state', 'self_timer', min_time, ...
            'input_to_statechange', {'Tup', 'check_next_trial_ready'});

        varargout{1} = sma;
        varargout{2} = {'hit_state','error_state','stim_pun', 'side_tup'};

    %% reinit
    case 'reinit'

        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
        'fullname', ['^' mfilename]);

        % Reinitialise at the original GUI position and figure:
        feval(mfilename, obj, 'init');



end
        
% @Multipokes3/StateMatrixSection
% Bing Wen, June 2007

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


function  [] =  StateMatrixSection(obj, action)

global left1led;
global center1led;
global right1led;
global left1water;
global right1water;


GetSoloFunctionArgs;


switch action
  case 'init', 
    
    feval(mfilename, obj, 'next_trial');

    
  case 'next_trial',

    sma = StateMachineAssembler('full_trial_structure');
    
    
                             
    % ----------------------- SET UP CORRECT RESPONSES FOR L/R ------------------------------
    if SidesSection(obj, 'get_current_side') == 'l',
        LeftResponseState = 'left_reward';
        if PunishBadSideChoice == 1, 
            if BadSideChoicePunishment == 1,
                % punishment: temporary white noise
                RightResponseState = 'temporary_punishment';
            else
                % punishment: trial terminates
                RightResponseState = 'pre_error_state';
            end;
        else
            RightResponseState = 'current_state';
        end;
        
        % choose the correct sounds to play
        switch value(Pk1ToneLocalization),
            case 'stereo',
                pk1_sound_id = SoundManagerSection(obj, 'get_sound_id', 'Poke1Left_stereo');
                pk1_sound_dur = SoundManagerSection(obj, 'get_sound_duration', 'Poke1Left_stereo');
            case 'localized:pro',
                pk1_sound_id = SoundManagerSection(obj, 'get_sound_id', 'Poke1Left_l');
                pk1_sound_dur = SoundManagerSection(obj, 'get_sound_duration', 'Poke1Left_l');
            case 'localized:anti',
                pk1_sound_id = SoundManagerSection(obj, 'get_sound_id', 'Poke1Left_r');
                pk1_sound_dur = SoundManagerSection(obj, 'get_sound_duration', 'Poke1Left_r');
        end;
        
        switch value(ILToneLocalization),
            case 'stereo',
                il_tone_id = SoundManagerSection(obj, 'get_sound_id', 'ILToneLeft_stereo');
                il_tone_dur = SoundManagerSection(obj, 'get_sound_duration', 'ILToneLeft_stereo');
            case 'localized:pro',
                il_tone_id = SoundManagerSection(obj, 'get_sound_id', 'ILToneLeft_l');
                il_tone_dur = SoundManagerSection(obj, 'get_sound_duration', 'ILToneLeft_l');
            case 'localized:anti',
                il_tone_id = SoundManagerSection(obj, 'get_sound_id', 'ILToneLeft_r');
                il_tone_dur = SoundManagerSection(obj, 'get_sound_duration', 'ILToneLeft_r');
        end;
        
        switch value(Pk2ToneLocalization),
            case 'stereo',
                pk2_sound_id = SoundManagerSection(obj, 'get_sound_id', 'Poke2Left_stereo');
                pk2_sound_dur = SoundManagerSection(obj, 'get_sound_duration', 'Poke2Left_stereo');
            case 'localized:pro',
                pk2_sound_id = SoundManagerSection(obj, 'get_sound_id', 'Poke2Left_l');
                pk2_sound_dur = SoundManagerSection(obj, 'get_sound_duration', 'Poke2Left_l');
            case 'localized:anti',
                pk2_sound_id = SoundManagerSection(obj, 'get_sound_id', 'Poke2Left_r');
                pk2_sound_dur = SoundManagerSection(obj, 'get_sound_duration', 'Poke2Left_r');
        end;
    else
        RightResponseState = 'right_reward';
        if PunishBadSideChoice == 1, 
            if BadSideChoicePunishment == 1,
                % punishment: temporary white noise    
                LeftResponseState = 'temporary_punishment';
            else
                % punishment: trial terminates
                LeftResponseState = 'pre_error_state';
            end;
        else
            LeftResponseState = 'current_state';
        end;
        
        % choose the correct sounds to play
        switch value(Pk1ToneLocalization),
            case 'stereo',
                pk1_sound_id = SoundManagerSection(obj, 'get_sound_id', 'Poke1Right_stereo');
                pk1_sound_dur = SoundManagerSection(obj, 'get_sound_duration', 'Poke1Right_stereo');
            case 'localized:pro',
                pk1_sound_id = SoundManagerSection(obj, 'get_sound_id', 'Poke1Right_r');
                pk1_sound_dur = SoundManagerSection(obj, 'get_sound_duration', 'Poke1Right_r');
            case 'localized:anti',
                pk1_sound_id = SoundManagerSection(obj, 'get_sound_id', 'Poke1Right_l');
                pk1_sound_dur = SoundManagerSection(obj, 'get_sound_duration', 'Poke1Right_l');
        end;
        
        switch value(ILToneLocalization),
            case 'stereo',
                il_tone_id = SoundManagerSection(obj, 'get_sound_id', 'ILToneRight_stereo');
                il_tone_dur = SoundManagerSection(obj, 'get_sound_duration', 'ILToneRight_stereo');
            case 'localized:pro',
                il_tone_id = SoundManagerSection(obj, 'get_sound_id', 'ILToneRight_r');
                il_tone_dur = SoundManagerSection(obj, 'get_sound_duration', 'ILToneRight_r');
            case 'localized:anti',
                il_tone_id = SoundManagerSection(obj, 'get_sound_id', 'ILToneRight_l');
                il_tone_dur = SoundManagerSection(obj, 'get_sound_duration', 'ILToneRight_l');
        end;
        
        switch value(Pk2ToneLocalization),
            case 'stereo',
                pk2_sound_id = SoundManagerSection(obj, 'get_sound_id', 'Poke2Right_stereo');
                pk2_sound_dur = SoundManagerSection(obj, 'get_sound_duration', 'Poke2Right_stereo');
            case 'localized:pro',
                pk2_sound_id = SoundManagerSection(obj, 'get_sound_id', 'Poke2Right_r');
                pk2_sound_dur = SoundManagerSection(obj, 'get_sound_duration', 'Poke2Right_r');
            case 'localized:anti',
                pk2_sound_id = SoundManagerSection(obj, 'get_sound_id', 'Poke2Right_l');
                pk2_sound_dur = SoundManagerSection(obj, 'get_sound_duration', 'Poke2Right_l');
        end;
    end;
    
                       
    warn_id   = SoundManagerSection(obj, 'get_sound_id', 'WarningSound');
    danger_id = SoundManagerSection(obj, 'get_sound_id', 'DangerSound');

    
    % ----------------------- SET UP N_CENTER_POKES ------------------------------
    if n_center_pokes == 0, 
        first_state = 'wait_for_spoke';
    else
        first_state = 'wait_for_cpoke1';
    end;
    
    if PunishITIBadPokes == 1, iti_poke_state = 'bad_poke_during_iti';
    else                       iti_poke_state = 'iti';
    end;
    
    sma = add_state(sma, 'name', 'ITI', 'self_timer', ITI, ...
        'input_to_statechange', {'Tup', first_state; ...
                                 'Cin', iti_poke_state; ...
                                 'Lin', iti_poke_state; ...
                                 'Rin', iti_poke_state; ...
                                 });
    
    sma = add_bad_boy_pokes_section(obj, sma, 'name', 'bad_poke_during_iti', ...
        'return_state', 'iti', ...
        'sound_duration', ITI_bpdur, ...
        'annoy_flag', UseAnnoyingSoundPenalty);
                             
    % ----------------------- CENTER POKE1 ------------------------------
    if PunishLight1BadPokes == 1, poke_state = 'bad_poke_during_light1';
    else                          poke_state = 'wait_for_cpoke1';
    end;
    
    if Pk1Light == 1, pk1_light = center1led;
    else              pk1_light = 0;
    end;
    
    sma = add_state(sma, 'name', 'WAIT_FOR_CPOKE1', ...
        'output_actions', {'DOut', pk1_light}, ...
        'input_to_statechange', {'Cin', 'sound1'; ...
                                 'Lin', poke_state; ...
                                 'Rin', poke_state; ...
                                 });
    
    sma = add_bad_boy_pokes_section(obj, sma, 'name', 'bad_poke_during_light1', ...
        'return_state', 'wait_for_cpoke1', ...
        'sound_duration', Pk1_light_bpdur, ...
        'annoy_flag', UseAnnoyingSoundPenalty);
    
    if n_center_pokes == 0,
        post_sound1_state = 'current_state';  
        % there is no post_sound1_state for n_center_pokes = 1
    elseif n_center_pokes == 1,
        post_sound1_state = 'center_to_side_gap';
    elseif n_center_pokes == 2,
        post_sound1_state = 'inter_light_gap_setup';
    end;

    
    if n_center_pokes == 1,
      sma = add_state(sma, 'name', 'SOUND1', 'self_timer', pk1_sound_dur, ...
        'output_actions', {'SoundOut', pk1_sound_id}, ...
        'input_to_statechange', {'Tup', post_sound1_state, 'Lin', LeftResponseState, 'Rin', RightResponseState});
    else
      sma = add_state(sma, 'name', 'SOUND1', 'self_timer', pk1_sound_dur, ...
        'output_actions', {'SoundOut', pk1_sound_id}, ...
        'input_to_statechange', {'Tup', post_sound1_state});
    end;

    
    % ----------------------- INTER LIGHT GAP ------------------------------
    
    
    sma = add_scheduled_wave(sma, 'name', 'inter_light_gap_dur', 'preamble', InterLightGap);
    sma = add_scheduled_wave(sma, 'name', 'inter_light_tone_start', 'preamble', InterLightToneStart);
    
    % inter_light_gap_setup: first make sure all scheduled waves are
    % stopped
    sma = add_state(sma, 'name', 'INTER_LIGHT_GAP_SETUP', ...
        'self_timer', 0.001, ...
        'output_actions', {'SchedWaveTrig', '-inter_light_gap_dur-inter_light_tone_start'}, ...
        'input_to_statechange', {'Tup', 'current_state+1'});
    
    % then start them
    sma = add_state(sma, ...
        'self_timer', 0.001, ...
        'output_actions', {'SchedWaveTrig', 'inter_light_gap_dur+inter_light_tone_start'}, ...
        'input_to_statechange', {'Tup', 'inter_light_gap'});
    
    if PunishInterLightBadPokes == 1, il_spoke_state = 'bad_poke_during_il_gap';
    else                              il_spoke_state = 'current_state';
    end;
    
    if PunishInterLightBadCenterPokes ==1, il_cpoke_state = 'bad_poke_during_il_gap';
    else                                   il_cpoke_state = 'current_state';
    end;
    
    
    if strcmpi(value(IL_ToneSoundType), 'off'),
        il_tone_state = 'current_state';
    else  % elseif il_tone exists
        il_tone_state = 'inter_light_tone_setup';
    end;
    
    sma = add_state(sma, 'name', 'INTER_LIGHT_GAP', ...
        'input_to_statechange', {'inter_light_gap_dur_In', 'wait_for_cpoke2'; ...
                                 'inter_light_tone_start_In', il_tone_state; ...
                                 'Lin', il_spoke_state; ...
                                 'Rin', il_spoke_state; ...
                                 'Cin', il_cpoke_state; ...
                                 });

    sma = add_state(sma, 'name', 'INTER_LIGHT_TONE_SETUP', ...
        'self_timer', 0.001, ...
        'output_actions', {'SoundOut', il_tone_id}, ...
        'input_to_statechange', {'Tup', 'inter_light_sound'});


    % if the il_tone_dur lasts longer than 0.5 sec, then draw 
    % 0.5s for the inter_light_sound state
    % This is a hack until sounds can be drawn on top of other states
    if il_tone_dur > 0.5, il_tone_draw_dur = 0.495;
    else                  il_tone_draw_dur = il_tone_dur;
    end;
    
    sma = add_state(sma, 'name', 'INTER_LIGHT_SOUND', ...
        'self_timer', il_tone_draw_dur, ...
        'input_to_statechange', {'Tup', 'inter_light_gap'; ...
                                 'Rin', il_spoke_state; ...
                                 'Lin', il_spoke_state; ...
                                 'Cin', il_cpoke_state; ...
                                });
    
                             
    sma = add_bad_boy_pokes_section(obj, sma, 'name', 'bad_poke_during_il_gap', ...
        'return_state', 'inter_light_gap_setup', ...
        'sound_duration', IL_bpdur, ...
        'turn_off_sound', il_tone_id, ...
        'annoy_flag', UseAnnoyingSoundPenalty);
                             
    % ----------------------- CENTER POKE2 ------------------------------
    if PunishLight2BadPokes == 1, poke_state = 'bad_poke_during_light2';
    else                          poke_state = 'wait_for_cpoke2';
    end;
    
    if Pk2Light == 1, pk2_light = center1led;
    else              pk2_light = 0;
    end
    
    sma = add_state(sma, 'name', 'WAIT_FOR_CPOKE2', ...
        'output_actions', {'DOut', pk2_light}, ...
        'input_to_statechange', {'Cin', 'sound2'; ...
                                 'Lin', poke_state; ...
                                 'Rin', poke_state; ...
                                 });
    
    sma = add_bad_boy_pokes_section(obj, sma, 'name', 'bad_poke_during_light2', ...
        'return_state', 'wait_for_cpoke2', ...
        'sound_duration', Pk2_light_bpdur, ...
        'turn_off_sound', il_tone_id, ...
        'annoy_flag', UseAnnoyingSoundPenalty);
    
    sma = add_state(sma, 'name', 'SOUND2', 'self_timer', pk2_sound_dur, ...
        'output_actions', {'SoundOut', pk2_sound_id}, ...
        'input_to_statechange', {'Tup', 'center_to_side_gap'});

                             
    % ----------------------- SIDE POKES ------------------------------
    if PunishCenter2SideBadPokes == 1, poke_state = 'bad_poke_during_c2side_gap';
    else                               poke_state = 'center_to_side_gap';
    end;
    
    sma = add_state(sma, 'name', 'CENTER_TO_SIDE_GAP', 'self_timer', Center2SideGap, ...
        'input_to_statechange', {'Tup', 'wait_for_spoke'; ...
                                 'Cin', poke_state; ...
                                 'Lin', poke_state; ...
                                 'Rin', poke_state; ...
                                 });
    
    sma = add_bad_boy_pokes_section(obj, sma, 'name', 'bad_poke_during_c2side_gap', ...
        'return_state', 'center_to_side_gap', ...
        'sound_duration', C2Side_bpdur, ...
        'turn_off_sound', il_tone_id, ...
        'annoy_flag', UseAnnoyingSoundPenalty);
    
    switch value(SideLights),
        case 'correct side only', 
            if SidesSection(obj, 'get_current_side') == 'l', side_lights = left1led;
            else                                             side_lights = right1led;
            end;
        case 'both sides on',
            side_lights = left1led+right1led;
        case 'off'
            side_lights = 0;
    end;
    
    if PunishSideLightBadPokes == 1, poke_state = 'bad_poke_during_spoke';
    else                             poke_state = 'wait_for_spoke';
    end;
    
    sma = add_state(sma, 'name', 'WAIT_FOR_SPOKE', ...
        'output_actions', {'DOut', side_lights}, ...
        'input_to_statechange', {'Lin', LeftResponseState; ...
                                 'Rin', RightResponseState; ...
                                 'Cin', poke_state; ...
                                 });
    sma = add_bad_boy_pokes_section(obj, sma, 'name', 'bad_poke_during_spoke', ...
        'return_state', 'wait_for_spoke', ...
        'sound_duration', Side_light_bpdur, ...
        'turn_off_sound', il_tone_id, ...
        'annoy_flag', UseAnnoyingSoundPenalty);
    
    sma = add_bad_pokes_section(obj, sma, 'name', 'temporary_punishment', ...
        'return_state', 'wait_for_spoke', ...
        'sound_duration', TempError);
                             
    % ----------------------- REWARD STATES ------------------------------
    [LeftWValveTime RightWValveTime] = WaterValvesSection(obj, 'get_water_times');  
    
    sma = add_state(sma, 'name', 'LEFT_REWARD', ...
        'self_timer', water_wait, ...
        'input_to_statechange', {'Tup', 'current_state+1'});
    sma = add_state(sma, ...
        'self_timer', LeftWValveTime, ...
        'output_actions', {'DOut', left1water; ...
                          }, ...
        'input_to_statechange', {'Tup', 'hit_state'});
   
    sma = add_state(sma, 'name', 'RIGHT_REWARD', ...
        'self_timer', water_wait, ...
        'input_to_statechange', {'Tup', 'current_state+1'});
    sma = add_state(sma, ...
        'self_timer', RightWValveTime, ...
        'output_actions', {'DOut', right1water; ...
                          }, ...
        'input_to_statechange', {'Tup', 'hit_state'});

    
    if WarnDur > 0,                     post_hit_state = 'warning';
    elseif WarnDur==0 && DangerDur > 0, post_hit_state = 'danger';
    elseif WarnDur==0 && DangerDur==0,  post_hit_state = 'turn_il_tone_off';
    end;
   
    if DangerDur > 0,                   post_warning_state = 'danger';
    else                                post_warning_state = 'turn_il_tone_off';
    end;

    if soft_dt > 0, post_drinkt_min_state     = 'SOFT_DT'; 
                    post_drinkt_min_state_out = 'SOFT_DT_OUT'; 
    else            post_drinkt_min_state     = post_hit_state;
                    post_drinkt_min_state_out = post_hit_state;
    end;

    sma = add_scheduled_wave(sma, 'name', 'drink_min', 'preamble', drinkt_min);
    sma = add_scheduled_wave(sma, 'name', 'drink_max', 'preamble', drinkt_max);    
    sma = add_state(sma, 'name', 'HIT_STATE', ...
        'output_actions', {'SoundOut', -pk1_sound_id, 'SchedWaveTrig', 'drink_min + drink_max'}, ...
        'input_to_statechange', {'drink_min_In', post_drinkt_min_state, 'Lout', 'hit_state_out', 'Cout', 'hit_state_out', 'Rout', 'hit_state_out'});
    sma = add_state(sma, ...
        'input_to_statechange', {'drink_min_In', post_drinkt_min_state, 'Lout', 'hit_state_out', 'Cout', 'hit_state_out', 'Rout', 'hit_state_out'});
    sma = add_state(sma, 'name', 'HIT_STATE_OUT', ...
        'input_to_statechange', {'drink_min_In', post_drinkt_min_state_out, 'Lin', 'hit_state+1', 'Cin', 'hit_state+1', 'Rin', 'hit_state+1'});
    sma = add_state(sma, 'name', 'SOFT_DT', ...
        'input_to_statechange', {'drink_max_In', post_hit_state, 'Lout', 'soft_dt_out', 'Cout', 'soft_dt_out', 'Rout', 'soft_dt_out'});
    sma = add_state(sma, 'name', 'SOFT_DT_OUT', 'self_timer', soft_dt, ...
        'input_to_statechange', {'Tup', post_hit_state, 'drink_max_In', post_hit_state, 'Lin', 'soft_dt', 'Cin', 'soft_dt', 'Rin', 'soft_dt'});
      
    sma = add_state(sma, 'name', 'WARNING', 'self_timer', WarnDur, ...
        'input_to_statechange', {'Tup', post_warning_state}, 'output_actions', {'SoundOut', warn_id});
    sma = add_state(sma, 'name', 'DANGER',  'self_timer', DangerDur, ...
        'output_actions', {'SoundOut', danger_id}, ...
        'input_to_statechange', {'Tup', 'turn_il_tone_off', 'Lin', 'to_pun', 'Cin', 'to_pun', 'Rin', 'to_pun'});
    sma = add_state(sma, 'name', 'to_pun', 'self_timer', 1e-4, ...
        'output_actions', {'SoundOut', -danger_id}, ...    
        'input_to_statechange', {'Tup', 'mypun'});
    sma = PunishInterface(obj, 'add_sma_states', 'PostDrinkPun', sma, 'name', 'mypun', ...
        'exitstate', 'danger');
    sma = add_state(sma, 'name', 'TURN_IL_TONE_OFF', 'self_timer', 1e-4, ...
        'output_actions', {'SoundOut', -il_tone_id}, ...
        'input_to_statechange', {'Tup', 'current_state+1'});
    sma = add_state(sma, 'self_timer', 1e-4, ...
        'output_actions', {'SoundOut', -danger_id}, ...    
        'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        
    
    sma = add_state(sma, 'name', 'pre_error_state', 'self_timer', 1e-4, ...
        'output_actions', {'SoundOut', -pk1_sound_id}, ...
        'input_to_statechange', {'Tup', 'current_state+1'});
    sma = add_bad_pokes_section(obj, sma, 'name', 'error_state', ...
        'return_state', 'check_next_trial_ready', ...
        'sound_duration', ExtraITIOnError, ...
        'turn_off_sound', il_tone_id);
      

    % add states to the 'prepare_next_trial' states:
    dispatcher('send_assembler', sma, {'hit_state', 'error_state'});
    
  case 'reinit',

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);

    % Reinitialise at the original GUI position and figure:
    feval(mfilename, obj, 'init');
    
end;

% ========================================================================
%
%                    add_bad_boy_pokes_section
%
% ========================================================================   
function [sma] = add_bad_boy_pokes_section(obj, sma, varargin)
% plays bad_boy_pokes_sound with pauses and reinits

    pairs = { ...
        'name'              'this'  ; ...
        'return_state'      'iti'   ; ...
        'annoy_flag'        0       ; ...
        'sound_duration'    3       ; ...
        'turn_off_sound'    0       ; ...
        }; parseargs(varargin, pairs);
    
    bbpdur = SoundManagerSection(obj, 'get_sound_duration', 'bad_boy_poke_sound');
    
    bbp_sound_id = SoundManagerSection(obj, 'get_sound_id', 'bad_boy_poke_sound');
    
   
   if annoy_flag, first_sound = 'current_state+1';
   else           first_sound = 'current_state+3';
   end;
    
   sma = add_state(sma, 'name', name, 'output_actions', ...
     {'SoundOut', -bbp_sound_id; ...
     }, ...
     'self_timer', 0.0002, ...
     'input_to_statechange', {'Tup', 'current_state+1'});
 
   sma = add_state(sma, 'output_actions', ...
         {'SoundOut', -turn_off_sound; ...
         }, ...
         'self_timer', 0.0002, ...
         'input_to_statechange', {'Tup', first_sound});
   
   % optional annoying sound precursor to bad boy sound
   annoying_sound_dur = SoundManagerSection(obj, 'get_sound_duration', 'annoying_sound');
   annoying_sound_id = SoundManagerSection(obj, 'get_sound_id', 'annoying_sound');
   
   sma = add_state(sma, 'self_timer', annoying_sound_dur, ...
                   'output_actions', {'SoundOut', annoying_sound_id}, ...
                   'input_to_statechange', {'Tup', 'current_state+2'; ...
                                            'Cin', 'current_state+1'; ...
                                            'Lin', 'current_state+1'; ...
                                            'Rin', 'current_state+1'; ...
                                           });
     
   sma = add_state(sma, 'output_actions', {'SoundOut', -annoying_sound_id}, ...
                        'self_timer', 0.035, ...
                        'input_to_statechange', {'Tup', name});
 
   % Play bad poke sound; if end without in-pokes, go to the return state
   n_bbp_sounds = floor(sound_duration / bbpdur);
   extra_bbp_time = sound_duration - n_bbp_sounds*bbpdur;

   for i=1:n_bbp_sounds,
     sma = add_state(sma, 'output_actions', ...
       {'SoundOut', bbp_sound_id}, ...
       'self_timer', bbpdur+0.04, ...  % 40 ms extra between annoying sounds
       'input_to_statechange', {'Tup', 'current_state+2' ; ...
       'Cin', 'current_state+1' ; ...
       'Rin', 'current_state+1' ; ...
       'Lin', 'current_state+1'});
   
     % There was a poke during the sound! Turn sound off, wait 35 ms, and
     % play again from scratch.
     sma = add_state(sma, 'output_actions', ...
       {'SoundOut', -bbp_sound_id}, ...
       'self_timer', 0.035, ...
       'input_to_statechange', {'Tup', name});
   end;
   if extra_bbp_time > 0.0002,
     sma = add_state(sma, 'output_actions', ...
       {'SoundOut', bbp_sound_id}, ...
       'self_timer', extra_bbp_time+0.04, ...  % 40 ms pause
       'input_to_statechange', {'Tup', 'current_state+2' ; ...
       'Cin', 'current_state+1' ; ...
       'Rin', 'current_state+1' ; ...
       'Lin', 'current_state+1'});
   
     % There was a poke during the sound! Turn sound off, wait 35 ms, and
     % play again from scratch.
     sma = add_state(sma, 'output_actions', ...
       {'SoundOut', -bbp_sound_id}, ...
       'self_timer', 0.035, ...
       'input_to_statechange', {'Tup', name});
   end;
   
   % We've been successful, no pokes -- turn sound off, go home
   sma = add_state(sma, 'output_actions', ...
     {'SoundOut', -bbp_sound_id}, ...
     'self_timer', 0.0002, ...
     'input_to_statechange', {'Tup', return_state});
   
return;
   
% ========================================================================
%
%                      add_bad_pokes_section
%
% ========================================================================
function [sma] = add_bad_pokes_section(obj, sma, varargin)
    pairs = { ...
        'name'              'this'  ; ...
        'return_state'      'iti'   ; ...
        'sound_duration'    3       ; ...
        'turn_off_sound'    0       ; ...
        }; parseargs(varargin, pairs);
    
    bpdur = SoundManagerSection(obj, 'get_sound_duration', 'bad_poke_sound');
    
    bp_sound_id = SoundManagerSection(obj, 'get_sound_id', 'bad_poke_sound');
   
   sma = add_state(sma, 'name', name, 'output_actions', ...
     {'SoundOut', -bp_sound_id; ...
     }, ...
     'self_timer', 0.0002, ...
     'input_to_statechange', {'Tup', 'current_state+1'});
 

   sma = add_state(sma, 'output_actions', ...
         {'SoundOut', -turn_off_sound; ...
         }, ...
         'self_timer', 0.0002, ...
         'input_to_statechange', {'Tup', 'current_state+1'});
   
 
   % Play bad poke sound; if end without in-pokes, go to the return state
   n_bp_sounds = floor(sound_duration / bpdur);
   extra_bp_time = sound_duration - n_bp_sounds*bpdur;

   for i=1:n_bp_sounds,
     sma = add_state(sma, 'output_actions', ...
       {'SoundOut', bp_sound_id}, ...
       'self_timer', bpdur+0.0002, ...  % 0.2 ms extra to make sure sound ended
       'input_to_statechange', {'Tup', 'current_state+2' ; ...
       'Cin', 'current_state+1' ; ...
       'Rin', 'current_state+1' ; ...
       'Lin', 'current_state+1'});
   
     % There was a poke during the sound! Turn sound off, wait 35 ms, and
     % play again from scratch.
     sma = add_state(sma, 'output_actions', ...
       {'SoundOut', -bp_sound_id}, ...
       'self_timer', 0.035, ...
       'input_to_statechange', {'Tup', name});
   end;
   if extra_bp_time > 0.0002,
     sma = add_state(sma, 'output_actions', ...
       {'SoundOut', bp_sound_id}, ...
       'self_timer', extra_bp_time+0.0002, ...  % 0.2 ms extra to make sure sound ended
       'input_to_statechange', {'Tup', 'current_state+2' ; ...
       'Cin', 'current_state+1' ; ...
       'Rin', 'current_state+1' ; ...
       'Lin', 'current_state+1'});
   
     % There was a poke during the sound! Turn sound off, wait 35 ms, and
     % play again from scratch.
     sma = add_state(sma, 'output_actions', ...
       {'SoundOut', -bp_sound_id}, ...
       'self_timer', 0.035, ...
       'input_to_statechange', {'Tup', name});
   end;
   
   % We've been successful, no pokes -- turn sound off, go home
   sma = add_state(sma, 'output_actions', ...
     {'SoundOut', -bp_sound_id}, ...
     'self_timer', 0.0002, ...
     'input_to_statechange', {'Tup', return_state});
   
   return;
   
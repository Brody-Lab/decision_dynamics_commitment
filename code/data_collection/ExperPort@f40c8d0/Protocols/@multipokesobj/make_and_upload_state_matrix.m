function [] = make_and_upload_state_matrix(obj, action)

global left1water; global right1water; global left1led; global center1led; global right1led;

GetSoloFunctionArgs;


switch action,
 case 'init'

   SoloParamHandle(obj, 'RealTimeStates', 'value', struct(...
     'dead_time',          -1, ...
     'wait_for_cpoke1',    -1, ...  
     'wait_for_cpoke2',    -1, ...
     'wait_for_spoke',     -1, ...
     'sound1',             -1, ...
     'sound2',             -1, ...
     'inter_light_gap',    -1, ...
     'center_to_side_gap', -1, ...
     'hit_state',          -1, ...
     'left_reward',        -1, ...
     'right_reward',       -1, ...
     'iti',                -1, ...
     'error_state',        -1));
   SoloFunctionAddVars('RewardsSection',   'ro_args', 'RealTimeStates');
   SoloFunctionAddVars('PokesPlotSection', 'ro_args', 'RealTimeStates');
  
   SoloParamHandle(obj, 'state_matrix');
   SoloParamHandle(obj, 'assembler');

   make_and_upload_state_matrix(obj, 'next_matrix');
   return;
   
 case 'next_matrix',
   
   sma = StateMachineAssembler('no_dead_time_technology');
   
   % -----------------------------------------------------------
   %
   % Case where we've reached trial limit
   %
   % -----------------------------------------------------------
   
   if n_done_trials >= MaxTrials  ||  ...
       (~isempty(protocol_start_time) && etime(clock, protocol_start_time) >= MaxMins*60),
     
     % <~> Experiment is over.
     
     % <~> Load a quiet white noise sound for the post-experiment period to
     %       (perhaps) cue to the rat that it needs to wait.
     srate = SoundManager(obj, 'get_sample_rate');
     SoundManager(obj, 'declare_new_sound', 'max_trials_noise');
     SoundManager(obj, 'set_sound', 'max_trials_noise', 0.006*randn(1,floor(2*srate))); % two secs here
     SoundManager(obj, 'send_not_yet_uploaded_sounds');
     
     sma = add_state(sma, 'name', 'ITI', 'default_statechange', 'current_state+1', ...
       'self_timer', 0.0001);
     sma = add_state(sma, 'output_actions', {'SoundOut', SoundManager(obj, 'get_sound_id', 'max_trials_noise')}, ...
       'self_timer', SoundManager(obj, 'get_sound_duration', 'max_trials_noise'), ...
       'input_to_statechange', {'Tup', 'iti'});
     
     [stm, assembled_state_names] = send(sma, rpbox('getstatemachine'));
     
     state_matrix.value = stm;
     RealTimeStates.value = assembled_state_names;
     push_history(RealTimeStates);
     rpbox('send_statenames', RealTimeStates);
     
     assembler.value = only_labels_and_outcols(sma);
     push_history(assembler);
     
     SavingSection(obj, 'savesets', 'interactive', 0, 'commit', 1);
     SavingSection(obj, 'savedata', 'interactive', 0, 'commit', 1);
     warndlg('Saved data already-- no need to save again');
     return;
   end;
   
   
   % -----------------------------------------------------------
   %
   % Now to work
   %
   % -----------------------------------------------------------
   
   
   % <~> Vars to shorten and speed up. Ugly, but better?
   % <~> The DrinkTimeLight parameter controls whether or not the light is
   %       on when the rat is drinking (distinct from light "guide" to
   %       correct port, which turns off when rat pokes there).
   DTL_OFF = 0;
   DTL_CORRECT_ONLY = 1;
   %   DTL_SAMEASGUIDES = 2;
   DTL_BOTH_SIDES = 3;
   DrinkTimeLight_temp = DTL_OFF; % <~> default to old
                                             % behavior if value strange
   if     strcmp(value(DrinkTimeLight),'off'),
       DrinkTimeLight_temp = DTL_OFF;
       %   elseif strcmp(value(DrinkTimeLight),'same_as_light_guides'),
       %       DrinkTimeLight_temp = DTL_SAMEASGUIDES;
   elseif strcmp(value(DrinkTimeLight),'correct_only'),
       DrinkTimeLight_temp = DTL_CORRECT_ONLY;
   elseif strcmp(value(DrinkTimeLight),'both'),
       DrinkTimeLight_temp = DTL_BOTH_SIDES;
   else
       error(['ERROR- unexpected value for DrinkTimeLight: ' ...
           value(DrinkTimeLight) '. Must be off, correct_only, or both']);
   end;
   
   
   if SidesSection(obj, 'get_next_side')=='l', % This is ell for LEFT
     poke1_sound_id  = SoundManager(obj, 'get_sound_id',       'Poke1Left');
     poke1_sound_dur = SoundManager(obj, 'get_sound_duration', 'Poke1Left');
     poke2_sound_id  = SoundManager(obj, 'get_sound_id',       'Poke2Left');
     poke2_sound_dur = SoundManager(obj, 'get_sound_duration', 'Poke2Left');
     if LightIndicatesCorrect, sideled = left1led;
     else                      sideled = left1led + right1led;
     end;
     % <~> construct output bitfield for drinktime
     DrinkTimeLEDs = bitor(...
         (DrinkTimeLight_temp==DTL_BOTH_SIDES)* (right1led+left1led), ...
         (DrinkTimeLight_temp==DTL_CORRECT_ONLY)*left1led);
     % <~> end
     LeftResponseState   = 'left_reward';
     if PunishBadSideChoice, 
       if ShortBadSidePunishment, RightResponseState = 'temporary_punishment'; 
       else                       RightResponseState = 'error_state';
       end;
     else
       RightResponseState = 'current_state';
     end;
     
   else         % --------- Correct response is RIGHT ---------
     poke1_sound_id  = SoundManager(obj, 'get_sound_id',       'Poke1Right');
     poke1_sound_dur = SoundManager(obj, 'get_sound_duration', 'Poke1Right');
     poke2_sound_id  = SoundManager(obj, 'get_sound_id',       'Poke2Right');
     poke2_sound_dur = SoundManager(obj, 'get_sound_duration', 'Poke2Right');
     if LightIndicatesCorrect, sideled = right1led;
     else                      sideled = left1led + right1led;
     end;
     % <~> construct output bitfield for drinktime
     DrinkTimeLEDs = bitor(...
         (DrinkTimeLight_temp==DTL_BOTH_SIDES)* (right1led+left1led), ...
         (DrinkTimeLight_temp==DTL_CORRECT_ONLY)*right1led);
     % <~> end
     if PunishBadSideChoice, 
       if ShortBadSidePunishment, LeftResponseState = 'temporary_punishment'; 
       else                       LeftResponseState = 'error_state';
       end;
     else
       LeftResponseState = 'current_state';
     end;
     RightResponseState  = 'right_reward';
   end;
  
   % sma = add_scheduled_wave(sma, 'name', 'sound1', 'preamble', poke1_sound_dur);
   % sma = add_scheduled_wave(sma, 'name', 'sound2', 'preamble', poke2_sound_dur);
   
   if PunishITIBadPokes == 1, iti_poke_state = 'bad_poke_before_light1';
   else                       iti_poke_state = 'iti';
   end;
   
   sma = add_state(sma, 'name', 'ITI', ...
     'self_timer', ITI, 'input_to_statechange', {'Tup', 'wait_for_cpoke1'; ...
     'Cin', iti_poke_state ; ...
     'Rin', iti_poke_state ; ...
     'Lin', iti_poke_state ; ...
     });
   sma = add_bad_pokes_section(obj, sma, 'name', 'bad_poke_before_light1', 'return_state', 'iti', ...
     'sound_duration', iti_bpdur);

   if PunishLight1BadPokes == 1, poke_state = 'bad_poke_during_light1';
   else                          poke_state = 'wait_for_cpoke1';
   end;
   sma = add_state(sma, 'name', 'WAIT_FOR_CPOKE1', ...
     'output_actions', {'DOut', center1led}, ...
     'input_to_statechange', { ...
     'Cin', 'sound1'   ;  ...
     'Lin', poke_state ;  ...
     'Rin', poke_state ;  ...
     });
   sma = add_bad_pokes_section(obj, sma, 'name', 'bad_poke_during_light1', 'return_state', 'wait_for_cpoke1', ...
     'sound_duration', Pk1_light_bpdur);
   
   if     n_center_pokes == 1,  post_sound1_state = 'center_to_side_gap';
   elseif n_center_pokes == 2,  post_sound1_state = 'pre_inter_light_gap';
   else   error('n_center_pokes is what???');
   end;
   
   sma = add_state(sma, 'name', 'SOUND1', ...
     'self_timer', poke1_sound_dur, ...
     'output_actions', {'SoundOut', poke1_sound_id; 'DOut', center1led}, ...
     'input_to_statechange', {'Tup',  post_sound1_state});
   
   if PunishInterLightBadPokes == 1, inter_light_poke_state = 'bad_poke_before_light2';
   else                              inter_light_poke_state = 'inter_light_gap';
   end;
   
   sma = add_state(sma, 'name', 'PRE_INTER_LIGHT_GAP', ...
     'self_timer', 0.5, ...
     'input_to_statechange', {'Tup', 'inter_light_gap'});
   
   sma = add_state(sma, 'name', 'INTER_LIGHT_GAP', ...
     'self_timer', InterLightGap, ...
     'input_to_statechange', {'Tup', 'wait_for_cpoke2'; ...
     'Cin', inter_light_poke_state ; ...
     'Rin', inter_light_poke_state ; ...
     'Lin', inter_light_poke_state ; ...
     });
   sma = add_bad_pokes_section(obj, sma, 'name', 'bad_poke_before_light2', 'return_state', 'inter_light_gap', ...
     'sound_duration', IL_bpdur);
   
   if PunishLight2BadPokes == 1, poke_state = 'bad_poke_during_light2';
   else                          poke_state = 'wait_for_cpoke2';
   end;
   sma = add_state(sma, 'name', 'WAIT_FOR_CPOKE2', ...
     'output_actions', {'DOut', center1led}, ...
     'input_to_statechange', { ...
     'Cin', 'sound2'   ;  ...
     'Lin', poke_state ;  ...
     'Rin', poke_state ;  ...
     });
   sma = add_bad_pokes_section(obj, sma, 'name', 'bad_poke_during_light2', 'return_state', 'wait_for_cpoke2', ...
     'sound_duration', Pk2_light_bpdur);

   sma = add_state(sma, 'name', 'SOUND2', ...
     'self_timer', poke2_sound_dur, ...
     'output_actions', {'SoundOut', poke2_sound_id; 'DOut', center1led}, ...
     'input_to_statechange', {'Tup',  'center_to_side_gap'});
   
   if PunishCenter2SideBadPokes == 1, center2side_poke_state = 'bad_poke_before_side';
   else                               center2side_poke_state = 'center_to_side_gap';
   end;

   sma = add_state(sma, 'name', 'CENTER_TO_SIDE_GAP', ...
     'self_timer', Center2SideGap, ...
     'input_to_statechange', {'Tup', 'wait_for_spoke'; ...
     'Cin', center2side_poke_state ; ...
     'Rin', center2side_poke_state ; ...
     'Lin', center2side_poke_state ; ...
     });
   sma = add_bad_pokes_section(obj, sma, 'name', 'bad_poke_before_side', 'return_state', 'center_to_side_gap', ...
     'sound_duration', C2Side_bpdur);

   if PunishSideLightBadPokes == 1, poke_state = 'bad_poke_during_sidelight';
   else                             poke_state = 'wait_for_spoke';
   end;
   sma = add_state(sma, 'name', 'WAIT_FOR_SPOKE', ...
     'output_actions', {'DOut', sideled}, ...
     'input_to_statechange', {'Lin', LeftResponseState; 'Rin', RightResponseState; 'Cin', poke_state});
   sma = add_bad_pokes_section(obj, sma, 'name', 'bad_poke_during_sidelight', 'return_state', 'wait_for_spoke', ...
     'sound_duration', Side_light_bpdur);
   sma = add_bad_pokes_section(obj, sma, 'name', 'temporary_punishment', 'return_state', 'wait_for_spoke', ...
     'sound_duration', TempError);
   
   
   sma = add_state(sma, 'name', 'LEFT_REWARD', ...
     'self_timer', water_wait, ...
     'input_to_statechange', {'Tup', 'current_state+1'});
   sma = add_state(sma, ...
     'self_timer', LeftWValveTime, ...
     'output_actions', {'DOut', left1water + DrinkTimeLEDs}, ... % <~> DTLEDs
     'input_to_statechange', {'Tup', 'hit_state'});
   sma = add_state(sma, 'name', 'RIGHT_REWARD', ...
     'self_timer', water_wait, ...
     'input_to_statechange', {'Tup', 'current_state+1'});
   sma = add_state(sma, ...
     'self_timer', RightWValveTime, ...
     'output_actions', {'DOut', right1water + DrinkTimeLEDs}, ... % <~> DTLEDs
     'input_to_statechange', {'Tup', 'hit_state'});
%   if SoftHitState==0,


% <~> modified following line to add output action for drink time lights
% sma = add_state(sma, 'name', 'HIT_STATE', ...
%     'self_timer', hit_state_duration, 'input_to_statechange', {'Tup', 'state35'});
     sma = add_state(sma, 'name', 'HIT_STATE', ...
       'self_timer', hit_state_duration, ...
       'output_actions', {'DOut', DrinkTimeLEDs}, ... % <~> this line
       'input_to_statechange', {'Tup', 'state35'});
% <~> end
  
%   else
%     sma = add_scheduled_wave(sma, 'name', 'soft_hit_state_timer', 'preamble', value(SoftHitStateTime));
%     sma = add_state(sma, 'name', 'HIT_STATE', ...
%       'self_timer', hit_state_duration, 'input_to_statechange', {'Tup', 'state35'});
%   end;

sma = add_bad_pokes_section(obj, sma, 'name', 'ERROR_STATE', 'return_state', 'state35', ...
     'sound_duration', ExtraITIOnError);
   
   sma = add_state(sma, 'name', 'DEAD_TIME', 'iti_state', 1, ...
     'self_timer', 0.5, 'input_to_statechange', {'Tup', 'state35'});
   
   if n_done_trials==0,
     [state_matrix.value, assembler_state_names] = send(sma, rpbox('getstatemachine'), 'run_trial_asap', 0);
   else
     [state_matrix.value, assembler_state_names] = send(sma, rpbox('getstatemachine'));
   end;

   RealTimeStates.value = assembler_state_names;
   rpbox('send_statenames', RealTimeStates);        push_history(RealTimeStates);
   assembler.value = only_labels_and_outcols(sma);  push_history(assembler);
   
   return;

   
 case 'reinit',
      % Delete all SoloParamHandles who belong to this object and whose
      % fullname starts with the name of this mfile:
      delete_sphandle('owner', ['^@' class(obj) '$'], ...
                      'fullname', ['^' mfilename]);

      % Reinitialise 
      feval(mfilename, obj, 'init');
   
   
 otherwise
   error('Invalid action!!');
   
end;




function  [sma] = add_bad_pokes_section(obj, sma, varargin)
   pairs = { ...
     'name'          'this'  ; ...
     'return_state'   'iti'  ; ...
     'sound_duration'  3     ; ...
   }; parseargs(varargin, pairs);

   bpdur = SoundManager(obj, 'get_sound_duration', 'bad_poke_sound');
   
   % Make sure bad pke sound was off:
   sma = add_state(sma, 'name', name, 'output_actions', ...
     {'SoundOut', -SoundManager(obj, 'get_sound_id', 'bad_poke_sound')}, ...
     'self_timer', 0.0002, ...
     'input_to_statechange', {'Tup', 'current_state+1'});
   
   % Play bad poke sound; if end without in-pokes, go to the return state
   n_bp_sounds = floor(sound_duration / bpdur);
   extra_bp_time = sound_duration - n_bp_sounds*bpdur;

   for i=1:n_bp_sounds,
     sma = add_state(sma, 'output_actions', ...
       {'SoundOut', SoundManager(obj, 'get_sound_id', 'bad_poke_sound')}, ...
       'self_timer', bpdur+0.0002, ...  % 0.2 ms extra to make sure sound ended
       'input_to_statechange', {'Tup', 'current_state+2' ; ...
       'Cin', 'current_state+1' ; ...
       'Rin', 'current_state+1' ; ...
       'Lin', 'current_state+1'});
   
     % There was a poke during the sound! Turn sound off, wait 35 ms, and
     % play again from scratch.
     sma = add_state(sma, 'output_actions', ...
       {'SoundOut', -SoundManager(obj, 'get_sound_id', 'bad_poke_sound')}, ...
       'self_timer', 0.035, ...
       'input_to_statechange', {'Tup', name});
   end;
   if extra_bp_time > 0.0002,
     sma = add_state(sma, 'output_actions', ...
       {'SoundOut', SoundManager(obj, 'get_sound_id', 'bad_poke_sound')}, ...
       'self_timer', extra_bp_time+0.0002, ...  % 0.2 ms extra to make sure sound ended
       'input_to_statechange', {'Tup', 'current_state+2' ; ...
       'Cin', 'current_state+1' ; ...
       'Rin', 'current_state+1' ; ...
       'Lin', 'current_state+1'});
   
     % There was a poke during the sound! Turn sound off, wait 35 ms, and
     % play again from scratch.
     sma = add_state(sma, 'output_actions', ...
       {'SoundOut', -SoundManager(obj, 'get_sound_id', 'bad_poke_sound')}, ...
       'self_timer', 0.035, ...
       'input_to_statechange', {'Tup', name});
   end;
   
   % We've been successful, no pokes -- turn sound off, go home
   sma = add_state(sma, 'output_actions', ...
     {'SoundOut', -SoundManager(obj, 'get_sound_id', 'bad_poke_sound')}, ...
     'self_timer', 0.0002, ...
     'input_to_statechange', {'Tup', return_state});
   
   return;
   

 


   
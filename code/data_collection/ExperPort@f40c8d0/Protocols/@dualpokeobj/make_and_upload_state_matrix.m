function [] = make_and_upload_state_matrix(obj, action)

GetSoloFunctionArgs;


switch action,
 case 'init'
   SoloParamHandle(obj, 'state_matrix'); 
   SoloParamHandle(obj, 'assembler');
   
   SoloParamHandle(obj, 'RealTimeStates', 'value', struct(...
     'wait_for_cpoke', 0, ...  % Waiting for initial center poke
     'sound_playing',  0, ...
     'wait_for_apoke', 0, ...  % Waiting for an answer poke
     'left_reward',    0, ...
     'right_reward',   0, ...
     'iti',            0, ...
     'extra_iti',      0));
   SoloFunctionAddVars('RewardsSection',   'ro_args', 'RealTimeStates');
   SoloFunctionAddVars('PokesPlotSection', 'ro_args', 'RealTimeStates');
   
   make_and_upload_state_matrix(obj, 'next_matrix');
   return;
   
 case 'next_matrix',
   
   global left1water; global right1water; global left1led; global center1led; global right1led;

   if SidesSection(obj, 'get_next_side')=='l', % This is ell for LEFT
     this_trial_sound_id = SoundManager(obj, 'get_sound_id', 'left');
     LeftResponseState   = 'left_reward';
     RightResponseState  = 'error_state';
   else                                        % Correct response is RIGHT
     this_trial_sound_id = SoundManager(obj, 'get_sound_id', 'right');
     LeftResponseState   = 'error_state';
     RightResponseState  = 'right_reward';
   end;
  
   
   sma = StateMachineAssembler('no_dead_time_technology', 'default_DOut', left1led+center1led+right1led);
   sma = add_state(sma, 'name', 'STATE_ZERO', 'default_statechange', ...  % State names are not case-sensitive
     'wait_for_cpoke', 'self_timer', 0.0002);
   sma = add_state(sma, 'name', 'WAIT_FOR_CPOKE', ...
     'input_to_statechange', {'Cin', 'play_sound'});
   
   sma = add_state(sma, 'name', 'PLAY_SOUND', ...
     'self_timer', SoundSection(obj, 'get_tone_duration')/1000, ...
     'output_actions', {'SoundOut', this_trial_sound_id, 'DOut', 0}, ...
     'input_to_statechange', { ...
       'Tup',  'wait_for_answer' ; ...
       'Lin',  LeftResponseState ; ...
       'Rin',  RightResponseState});
   sma = add_state(sma, 'name', 'WAIT_FOR_ANSWER', ...
     'input_to_statechange', { ...
       'Lin',  LeftResponseState ; ...
       'Rin',  RightResponseState});
     
   sma = add_state(sma, 'name', 'LEFT_REWARD', ...
     'self_timer', LeftWValveTime, ...
     'output_actions', {'DOut', left1water}, ...
     'input_to_statechange', {'Tup', 'inter_trial_interval'});
   sma = add_state(sma, 'name', 'RIGHT_REWARD', ...
     'self_timer', RightWValveTime, ...
     'output_actions', {'DOut', right1water}, ...
     'input_to_statechange', {'Tup', 'inter_trial_interval'});
   sma = add_state(sma, 'name', 'ERROR_STATE', ...
     'self_timer', ExtraITIOnError, ...
     'input_to_statechange', {'Tup', 'inter_trial_interval'});
   
   sma = add_state(sma, 'name', 'INTER_TRIAL_INTERVAL', 'iti_state', 1, ...
     'self_timer', ITI, 'input_to_statechange', ...
     {'Tup', 'state35'; ...
     'Cin', 'punish_state' ; ...
     'Lin', 'punish_state' ; ...
     'Rin', 'punish_state'});

   sma = add_state(sma, 'name', 'PUNISH_STATE', 'iti_state', 1, ...
     'self_timer', 0.0002, 'default_statechange', 'current_state+1');
   sma = add_state(sma, 'iti_state', 1, ...
     'self_timer', ITI_reinit, 'input_to_statechange', ...
     {'Tup', 'inter_trial_interval' ; 
     'Cin', 'punish_state' ; ...
     'Lin', 'punish_state' ; ...
     'Rin', 'punish_state'});
  
     
   [state_matrix.value, assembler_state_names] = send(sma, rpbox('getstatemachine'));

   RealTimeStates.value = assembler_state_names;
   RealTimeStates.extra_iti = [RealTimeStates.error_state RealTimeStates.punish_state];
   % RealTimeStates is a SoloParamHandle, and rmfield is defined for these by reference, 
   % so we can do rmfield without a return value:
   rmfield(rmfield(RealTimeStates, 'error_state'), 'punish_state');
   
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

   
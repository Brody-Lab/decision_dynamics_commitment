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
     'extra_iti',      0));
   SoloFunctionAddVars('RewardsSection', 'ro_args', 'RealTimeStates');
   
   make_and_upload_state_matrix(obj, 'next_matrix');
   return;
   
 case 'next_matrix',
   
   global left1water; global right1water;
   
   sound_ids = SoundSection(obj, 'get_sound_ids');

   if SidesSection(obj, 'get_next_side')=='l',
     this_trial_sound_id = sound_ids.left;
     LeftResponseState   = 'left_reward';
     RightResponseState  = 'error_state';
   else
     this_trial_sound_id = sound_ids.right;
     LeftResponseState   = 'error_state';
     RightResponseState  = 'right_reward';
   end;
  
   
   sma = StateMachineAssembler('no_dead_time_technology');
   sma = add_state(sma, 'name', 'STATE_ZERO', 'default_statechange', ...
     'wait_for_cpoke', 'self_timer', 0.0002);
   sma = add_state(sma, 'name', 'WAIT_FOR_CPOKE', ...
     'input_to_statechange', {'Cin', 'play_sound'});
   
   sma = add_state(sma, 'name', 'PLAY_SOUND', ...
     'self_timer', SoundSection(obj, 'get_tone_duration')/1000, ...
     'output_actions', {'SoundOut', this_trial_sound_id}, ...
     'input_to_statechange', { ...
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
     'self_timer', 0.1, 'input_to_statechange', {'Tup', 'state35'});
   
   RealTimeStates.wait_for_cpoke = label2statenum(sma, 'wait_for_cpoke');
   RealTimeStates.sound_playing  = label2statenum(sma, 'play_sound');
   RealTimeStates.wait_for_apoke = label2statenum(sma, 'wait_for_answer');
   RealTimeStates.left_reward    = label2statenum(sma, 'left_reward');
   RealTimeStates.right_reward   = label2statenum(sma, 'right_reward');
   RealTimeStates.extra_iti      = label2statenum(sma, 'error_state');
   
   state_matrix.value = send(sma, rpbox('getstatemachine'));
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

   
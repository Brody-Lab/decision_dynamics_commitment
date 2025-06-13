function RealTimeStates = make_and_upload_state_matrix(obj, action)
 
GetSoloFunctionArgs;
amp = 0.05;

switch action
 case 'init'
   SoloParamHandle(obj, 'RealTimeStates', 'value', struct(...
     'wait_for_cpoke', -1, ...  % Waiting for initial center poke
     'pre_chord',      -1, ...  % Silent period preceeding GO signal
     'chord',          -1, ...  % GO signal
     'wait_for_apoke', -1, ...  % Waiting for an answer poke (after GO signal)
     'left_dirdel',    -1, ...  % Direct delivery on LHS
     'right_dirdel',   -1, ...  % Direct delivery on RHS
     'left_reward',    -1, ...  % Reward obtained on LHS
     'right_reward',   -1, ...  % Reward obtained on RHS
     'drink_time',     -1, ...  % Silent time to permit drinking
     'timeout',        -1, ...  % Penalty state
     'iti',            -1, ...  % Intertrial interval
     'dead_time',      -1, ...  % 'Filler' state needed because of
                          ...  % Matlab lag in sending next state
                          ...  % machine 
     'state35',        -1, ...  % End-of-trial state (the state number
                          ...  % is an ancient convention) 
     'extra_iti',      -1, ...  % State of penalty within ITI (occurs if
                          ...  % rat pokes during ITI - usually longer
                          ...  % than ITI) 
     'hit_state',      -1) ...
                   );

     SoloParamHandle(obj, 'state_matrix');
     SoloParamHandle(obj, 'deliver_water', 'value', 1);
     SoloParamHandle(obj, 'assembler');
     
 case 'next_matrix'
 otherwise
   error('Unknown action');
end;

stne = 1;
sound_len = value(chord_sound_len);
itilist = value(iti_list);

lwpt = value(LeftWValve);
rwpt = value(RightWValve);

avail = value(RewardAvail);
iti_length = itilist(value(n_done_trials+1));
if ~strcmpi(value(WaterDelivery),'direct')
    iti_length = max(iti_length - avail, 0.01);
else
    avail = 0.01;
end;

side = side_list(n_done_trials+1);
left = get_generic('side_list_left');

global left1led; global right1led; global center1led;
default_leds = (1-Light_Polarity)*(left1led+center1led+right1led);

sma = StateMachineAssembler('no_dead_time_technology', 'default_DOut', default_leds);


% -----------------------------------------------------------
%
% Case where we've reached trial limit
%
% -----------------------------------------------------------

if n_done_trials >= Max_Trials,

   srate = SoundManager(obj, 'get_sample_rate');
   SoundManager(obj, 'declare_new_sound', 'max_trials_noise'); 
   SoundManager(obj, 'set_sound', 'max_trials_noise', amp*0.001*randn(1,floor(2*srate))); % two secs here
   SoundManager(obj, 'send_not_yet_uploaded_sounds');
   
   sma = add_state(sma, 'name', 'TIMEOUT', 'default_statechange', 'current_state+1', ...
     'self_timer', 0.0001);
   sma = add_state(sma, 'output_actions', {'SoundOut', SoundManager(obj, 'get_sound_id', 'max_trials_noise')}, ...
     'self_timer', SoundManager(obj, 'get_sound_duration', 'max_trials_noise'), ...
     'input_to_statechange', {'Tup', 'timeout'});
   
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

switch WaterDelivery,
  case 'only if nxt pke corr',
    if     side==left,
      LeftResponseState  = 'left_reward_state';
      RightResponseState = 'error_state';
    elseif side==1-left,
      LeftResponseState  = 'error_state';
      RightResponseState = 'right_reward_state';
    end;
    
  case 'next corr poke',
    if     side==left, 
      LeftResponseState  = 'left_reward_state';
      RightResponseState = 'wait_for_poke';
    elseif side==1-left, 
      LeftResponseState  = 'wait_for_poke';
      RightResponseState = 'right_reward_state';
    end;
    
  case 'direct',  % post-tone act is either the Left or Right direct water delivery
    if     side==left,
      LeftResponseState  = 'left_direct_delivery';
      RightResponseState = 'left_direct_delivery';
    elseif side==1-left, 
      LeftResponseState  = 'right_direct_delivery';
      RightResponseState = 'right_direct_delivery';
    end;

    otherwise,
        error(['Don''t know how to do this WaterDelivery: ' WaterDelivery]);
end;

global left1water;  
global right1water; 

if ~strcmpi(value(WaterDelivery), 'direct'),  PostSoundState = 'wait_for_poke';
else                                          PostSoundState = LeftResponseState;
end;

if side==left,
  LightSignal = default_leds + (2*Light_Polarity-1)*left1led;
else
  LightSignal = default_leds + (2*Light_Polarity-1)*right1led;
end;


if PokeElicitsSound == 0,
   sma = add_state(sma, 'name', 'LED_STIMULUS', ...
                   'output_actions', {'DOut', LightSignal}, ...
                   'input_to_statechange', {'Tup', 'no_stimulus_gap'}, ...
                   'self_timer', max(min(Light_Duration, Light_F1_SOA), 0.0002));

   sma = add_state(sma, 'name', 'NO_STIMULUS_GAP', ...
                   'self_timer', max(Light_F1_SOA - Light_Duration, 0.0002), ...
                   'input_to_statechange', {'Tup', 'sound_and_light'});

   sma = add_state(sma, 'name', 'SOUND_AND_LIGHT', ...
                   'output_actions', { ...
                     'SoundOut', ...
                     SoundManager(obj,'get_sound_id','relevant_plus_chord') ; ...
                     'DOut', LightSignal}, ...
                   'self_timer', max(Light_Duration - Light_F1_SOA, 0.0002), ...
                   'input_to_statechange', {'Tup', 'play_sound'; ...
                     'Lin', LeftResponseState ; ...
                     'Rin', RightResponseState});
   
   sma = add_state(sma, 'name', 'PLAY_SOUND', ...
                   'self_timer', ...
                   max(SoundManager(obj,'get_sound_duration', ...
                                    'relevant_plus_chord') - ...
                       max(Light_Duration-Light_F1_SOA,0), 0.0002),...
                   'input_to_statechange', {'Tup', PostSoundState; ...
                     'Lin', LeftResponseState ; ...
                     'Rin', RightResponseState});  
   % PostSoundState defined two lines above

   sma = add_state(sma, 'name', 'WAIT_FOR_POKE', ...
                   'self_timer', avail, 'input_to_statechange', {...
                     'Tup', 'error_state' ; ...
                     'Lin', LeftResponseState ; ...
                     'Rin', RightResponseState});
else


   sma = add_scheduled_wave(sma, 'name','light_is_on','preamble',Light_Duration);
   sma = add_scheduled_wave(sma, 'name','sound_dur','preamble', ...
                            SoundManager(obj, 'get_sound_duration', ...
                                         'relevant_plus_chord'));

   switch WaterDelivery,
    case 'only if nxt pke corr',
      if     side==left,
         LeftResponseState  = 'left_reward_sound_light_on';
         RightResponseState = 'error_state';
      elseif side==1-left,
         LeftResponseState  = 'error_state';
         RightResponseState = 'right_reward_sound_light_on';
    end;
    
    case 'next corr poke',
      if     side==left, 
         LeftResponseState  = 'left_reward_sound_light_on';
         RightResponseState = 'wait_for_poke';
      elseif side==1-left, 
         LeftResponseState  = 'wait_for_poke';
         RightResponseState = 'right_reward_sound_light_on';
      end;
    
    case 'direct',  
      % post-tone act is either the Left or Right direct water delivery
      if     side==left,
       LeftResponseState  = 'left_direct_delivery';
       RightResponseState = 'left_direct_delivery';
      elseif side==1-left, 
         LeftResponseState  = 'right_direct_delivery';
         RightResponseState = 'right_direct_delivery';
      end;
   end;
   
   if strcmp(WaterDelivery, 'direct') 
      if side==left, nopokeState = 'left_direct_delivery';
      else           nopokeState = 'right_direct_delivery';
      end;
   else
      nopokeState = 'error_state';
   end;
   
   
   sma = add_state(sma, 'name', 'LED_STIMULUS', ...
                   'output_actions', {'DOut', LightSignal, ...
                   'SchedWaveTrig', 'light_is_on'}, ...
                   'input_to_statechange', { ...
                     'light_is_on_In', nopokeState ; ...
                     'Lin',            LeftResponseState ; ...
                     'Rin',            RightResponseState});
                   
   sma = add_state(sma, 'name', 'WAIT_FOR_POKE', ...
                   'output_actions', {'DOut', LightSignal}, ...
                   'input_to_statechange', { ...
                     'light_is_on_In', nopokeState ; ...
                     'Lin',            LeftResponseState ; ...
                     'Rin',            RightResponseState});
                      
   sma = add_state(sma, 'name', 'LEFT_REWARD_SOUND_LIGHT_ON', ...
                   'output_actions', { ...
                     'SoundOut', ...
                     SoundManager(obj,'get_sound_id','relevant_plus_chord') ; ...
                     'DOut', LightSignal ; 'SchedWaveTrig', 'sound_dur'}, ...
                   'input_to_statechange', {...
                     'light_is_on_In', 'left_reward_sound_on', ...
                     'sound_dur_In',   'left_reward_state'});

   sma = add_state(sma, 'name', 'LEFT_REWARD_SOUND_ON', ...
                   'input_to_statechange', { ...
                     'sound_dur_In',   'left_reward_state'});
   
   sma = add_state(sma, 'name', 'RIGHT_REWARD_SOUND_LIGHT_ON', ...
                   'output_actions', { ...
                     'SoundOut', ...
                     SoundManager(obj,'get_sound_id','relevant_plus_chord') ; ...
                     'DOut', LightSignal ; 'SchedWaveTrig', 'sound_dur'}, ...
                   'input_to_statechange', {...
                     'light_is_on_In', 'right_reward_sound_on', ...
                     'sound_dur_In',   'right_reward_state'});

   sma = add_state(sma, 'name', 'RIGHT_REWARD_SOUND_ON', ...
                   'input_to_statechange', { ...
                     'sound_dur_In',   'right_reward_state'});
   
                   
   
end;

sma = add_state(sma, 'name', 'LEFT_REWARD_STATE', ...
  'self_timer', value(LeftWValve),  'output_actions', {'DOut', left1water*(deliver_water==1) + default_leds}, ...
  'input_to_statechange', {'Tup', 'hit_state'});

sma = add_state(sma, 'name', 'RIGHT_REWARD_STATE', ...
  'self_timer', value(RightWValve), 'output_actions', {'DOut', right1water*(deliver_water==1) + default_leds}, ...
  'input_to_statechange', {'Tup', 'hit_state'});

sma = add_state(sma, 'name', 'LEFT_DIRECT_DELIVERY', ...
  'self_timer', value(LeftWValve),  'output_actions', {'DOut', left1water*(deliver_water==1) + default_leds}, ...
  'input_to_statechange', {'Tup', 'hit_state'});

sma = add_state(sma, 'name', 'RIGHT_DIRECT_DELIVERY', ...
  'self_timer', value(RightWValve), 'output_actions', {'DOut', right1water*(deliver_water==1) + default_leds}, ...
  'input_to_statechange', {'Tup', 'hit_state'});

sma = add_state(sma, 'name', 'hit_state', ...
  'self_timer', iti_length, 'input_to_statechange', {'Tup', 'state35'});

sma = add_state(sma, 'name', 'error_state', ...
  'self_timer', iti_length, 'input_to_statechange', {'Tup', 'state35'});

sma = add_state(sma, 'iti_state', 1, 'name', 'iti_state', 'default_statechange', 'state35', 'self_timer', 0.1);


[stm, assembled_state_names] = send(sma, rpbox('getstatemachine'));
% fprintf(1, 'Just sent; time is %s\n', datestr(now));

state_matrix.value = stm;

if PokeElicitsSound == 0,
   RealTimeStates.pre_chord       = assembled_state_names.no_stimulus_gap;
   RealTimeStates.chord           = [assembled_state_names.sound_and_light assembled_state_names.play_sound];
else
   RealTimeStates.chord           = ...
       [assembled_state_names.left_reward_sound_light_on  ...
        assembled_state_names.right_reward_sound_light_on ...
        assembled_state_names.left_reward_sound_on  ...
        assembled_state_names.right_reward_sound_on];   
end


RealTimeStates.wait_for_cpoke  = assembled_state_names.led_stimulus;
RealTimeStates.wait_for_apoke  = assembled_state_names.wait_for_poke;
RealTimeStates.left_reward     = assembled_state_names.left_reward_state;
RealTimeStates.right_reward    = assembled_state_names.right_reward_state;
RealTimeStates.left_dirdel     = assembled_state_names.left_direct_delivery;
RealTimeStates.right_dirdel    = assembled_state_names.right_direct_delivery;
RealTimeStates.hit_state       = assembled_state_names.hit_state;
RealTimeStates.extra_iti       = assembled_state_names.error_state;
RealTimeStates.iti             = assembled_state_names.iti_state;
RealTimeStates.state35         = assembled_state_names.state35;
RealTimeStates.dead_time       = assembled_state_names.state_0;
   
push_history(RealTimeStates);
rpbox('send_statenames', assembled_state_names);

assembler.value = only_labels_and_outcols(sma);
push_history(assembler);

return;




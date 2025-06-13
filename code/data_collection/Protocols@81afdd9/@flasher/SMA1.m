
function  [] =  SMA1(obj, action)

GetSoloFunctionArgs;


switch action
   case 'init',
      
      feval(mfilename, obj, 'next_trial');
      
      %% next_trial
   case 'next_trial',
      
      %% Setup water
      min_time= 2.5E-4;  % This is less than the minumum time allowed for a state transition.
      
      left1led           = bSettings('get', 'DIOLINES', 'left1led');
      center1led         = bSettings('get', 'DIOLINES', 'center1led');
      right1led          = bSettings('get', 'DIOLINES', 'right1led');
      left1water         = bSettings('get', 'DIOLINES', 'left1water');
      right1water        = bSettings('get', 'DIOLINES', 'right1water');
%     center1water       = bSettings('get', 'DIOLINES', 'center1water');
%     Center1water is not used in this version       
      
      sma = StateMachineAssembler('full_trial_structure','use_happenings', 1);
      [LeftWValveTime, RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
%     [CenterWValveTime] = WaterValvesSection(obj, 'get_center_time');
            
      %% Setup sounds
      cue_stereo_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'CueStereoSound');
      cue_left_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'CueLeftSound');
      cue_right_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'CueRightSound');
      cue_high_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'CueHighSound');
    
      right_hit_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'RightHitSound');
      left_hit_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'RightHitSound');

      miss_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'MissSound');
      fa_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'FalseAlarmSound');
      cr_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'CorrectRejectSound');
      viol_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'ViolationSound');
      to_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'TimeoutSound');
      iti_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'ITISound');
      
      %% Declare variables
      % These will get moved to other functions as SoloParamHandles.
      
      wfnic_led=center1led;
      precue_dur=0.3;
      cue_dur=0.4;
      postcue_dur=0.5;
      if rand<0.5
      gap_type='none'; % [both left right none]  On Go-trials the cue can appear on the right or left or both.  
      else
          if rand<0.2
              gap_type='both';
          elseif rand<0.5
              gap_type='right';
          else
              gap_type='left';
          end
      end
  
%      [cue_type, gap_type]=SidesSection(obj,'get_trial_type');
      
      gap_dur=0.1+rand/2;
      flash1_dur=rand+0.5;
      waitforgo_dur=1-gap_dur;
      waitfornogo_dur=2;
      wait_for_cpoke_timeout=150;
      
      allow_nic_breaks=1; % [0 1]
      side_rewards=1;
      side_reward_loc=1;
      reward_delay=0.1;
      high_rew_mult=5;
      
      
      miss_iti_state='iti_state_long';
      hit_iti_state='iti_state_short';
      
      
      
      %% 
      
      if allow_nic_breaks==1
         cpoke_out_state='current_state';
      else
         cpoke_out_state='violation_state';
      end
      
      if side_rewards
          if side_reward_loc==-1
              reward_state='left_reward_state';
              reward_led=0;
              hit_dio=left1water;
              hit_valve_time=LeftWValveTime;
              hit_sound_id=left_hit_sound_id;
              reward_poke='Lhi';
          else
              reward_state='right_reward_state';
              reward_led=0;
              hit_dio=right1water;
              hit_valve_time=RightWValveTime;
              hit_sound_id=left_hit_sound_id;
              reward_poke='Rhi';
          end
      else
              reward_state='center_reward_state'; %#ok<*UNRCH>
              hit_dio=center1water;
              reward_led=center1led;
              hit_valve_time=CenterWValveTime;    
              reward_poke='Chi';
      end
     
    
      
      %% Cue setup
      % Each trial begins with an auditory cue.
      % The cue can be :
      % Stereo  : provides no attentional cue
      % Left    : indicates to attend to the left LED
      % Right   : indicates to attend to the right LED
      % High    : indicates that a large reward will be given
      
      
      precue_state=['nic_precue_' cue_type];
      cue_state=['nic_cue_' cue_type];
      postcue_state=['nic_postcue_' cue_type];
      
      switch cue_type
          case 'stereo'
              cue_sound_id=cue_stereo_sound_id;
          case 'left'
              cue_sound_id=cue_left_sound_id;
          case 'right'
              cue_sound_id=cue_right_sound_id;
          case 'high'
              cue_sound_id=cue_high_sound_id;
              hit_valve_time=hit_valve_time*high_rew_mult;
          otherwise
              error('something wrong')
      end
      
      
        sma = add_scheduled_wave(sma, 'name', 'direct_reward', 'preamble', reward_delay, ...
         'sustain', hit_valve_time, 'DOut', hit_dio);
     
      
      %% Flash setup
      % After the auditory attentional cue there is a delay 'postcue' state
      % followed by a visual stimulus.
      % If the trial is a "go" trial then the stimulus is a light
      % onset-offset-onset pattern.  The rat must withdraw from the center
      % poke within some time-limit of the offset time.  The offset can
      % happen on one side or on both sides of the rat.
      %
      % If the trial is a "no-go" trial then the stimulus is just an
      % onset-offset pattern.  The rat is rewarded for staying in the center port 
      % until the end of the light.  
      
      flash1_state=['flash1_' gap_type];
      gap_state=['gap_' gap_type];
      flash2_state=['flash2_' gap_type];
      flash_led=right1led+left1led;
      gotogap_state=gap_state;
              
      switch gap_type
          case 'none'
              gap_led=0; % will never get here
              gotogap_state='nogo_state';             
              
          case 'left'
              gap_led=right1led;   % if the gap is on the left, leave the right LED on.         
          case 'right'
              gap_led=left1led;            
          case 'both'
              gap_led=0;
          otherwise
              error('something wrong')
      end
              
      
      %% States setup
      % The first state is just waiting for the rat to poke in the center
      % port.  We make sure the nic sound is off in this state.
      
      sma = add_state(sma,'name','wait_for_nopoke',...
          'self_timer',min_time,...
          'output_actions',{'SoundOut',iti_sound_id},...
          'input_to_statechange',{'Tup','current_state+1'});
      
      sma = add_state(sma,...
         'self_timer',1,...
         'input_to_statechange',{'Chi','current_state+1'; ...
                                 'Rhi','current_state+1';...
                                 'Lhi','current_state+1';
                                 'Tup','wait_for_cpoke'});    
                             
      sma = add_state(sma,'self_timer',min_time,...
          'input_to_statechange',{'Tup','current_state-1'});                       
                             
      
      sma = add_state(sma,'name','wait_for_cpoke',...
         'self_timer',wait_for_cpoke_timeout,...
         'output_actions',{'DOut',wfnic_led;'SoundOut',-iti_sound_id},...
         'input_to_statechange',{'Tup','timeout_state'; ...
         'Chi',precue_state});
      
      
      % Then the first NIC state: the "precue" state.  We turn on the side_lights 
      % to signal that they should stay in the center port until the
      % side_lights go out.
      
      sma = add_state(sma,'name',precue_state,'self_timer',precue_dur,...
         'output_actions',{'DOut',flash_led},...
         'input_to_statechange',{'Clo','wait_for_cpoke';...
         'Tup','current_state+1'});
     
     % ^ If they leave the cpoke, they should maybe get a white noise sound.
     
      
      % Now we play the cue which tells them the trial type:
      % stereo = no info
      % right  = 80% cue on right
      % left   = 80% cue on left
      % high   = 5x reward
      
      sma = add_state(sma,'name',cue_state,'self_timer',cue_dur,...
                   'output_actions',{'SoundOut',cue_sound_id; 'DOut',flash_led},...
         'input_to_statechange',{'Clo',cpoke_out_state;...
         'Tup',postcue_state});

       sma = add_state(sma,'name',postcue_state,'self_timer',postcue_dur,...
                   'output_actions',{'SoundOut',-cue_sound_id; 'DOut',flash_led},...
         'input_to_statechange',{'Clo',cpoke_out_state;...
         'Tup',flash1_state});
     
     
     
     
     %% Then the lights

       sma = add_state(sma,'name',flash1_state,'self_timer',flash1_dur,...
                   'output_actions',{'DOut',flash_led},...
         'input_to_statechange',{'Clo','false_alarm_state';...
         'Tup',gotogap_state});

       sma = add_state(sma,'name',gap_state,'self_timer',gap_dur,...
                   'output_actions',{'DOut',gap_led},...
         'input_to_statechange',{'Clo','hit_state';...
         'Tup',flash2_state});

       sma = add_state(sma,'name',flash2_state,'self_timer',waitforgo_dur,...
                   'output_actions',{'DOut',flash_led},...
         'input_to_statechange',{'Clo','hit_state';...
         'Tup','miss_state'});
     
       sma = add_state(sma,'name','nogo_state','self_timer',waitfornogo_dur,...
                   'output_actions',{'DOut',flash_led},...
         'input_to_statechange',{'Clo','false_alarm_state';...
         'Tup','correct_rejection_state'});
     
     
      sma = add_state(sma,'name','hit_state','self_timer',0.25,...
         'output_actions',{'SoundOut',hit_sound_id},...
         'input_to_statechange',{'Tup','current_state+1'});
     
     
      sma = add_state(sma,'self_timer',0.1,...
         'output_actions',{'DOut',reward_led},...
         'input_to_statechange',{'Tup','current_state+1'});
     
     sma=add_state(sma,...
         'input_to_statechange',{reward_poke,reward_state});
     
      sma = add_state(sma,'name','correct_rejection_state',...
         'input_to_statechange',{'Clo','current_state+1'});
     
     sma=add_state(sma,...
              'output_actions',{'SoundOut',cr_sound_id},...
            'input_to_statechange',{'Clo','current_state+1'});
     
     sma=add_state(sma,'output_actions',{'DOut',reward_led},...
         'input_to_statechange',{reward_poke,reward_state});
     
     
      sma = add_state(sma,'name',reward_state,'self_timer',1,...
         'output_actions',{'SchedWaveTrig','direct_reward'},...
         'input_to_statechange',{'Tup',hit_iti_state});

     
     sma = add_state(sma,'name','miss_state','self_timer',min_time,...
         'output_actions',{'SoundOut',miss_sound_id},...
         'input_to_statechange',{'Tup',miss_iti_state});
     
      
      sma = add_state(sma,'name','false_alarm_state','self_timer',min_time,...
         'output_actions',{'SoundOut',fa_sound_id},...
         'input_to_statechange',{'Tup',miss_iti_state});
      
      
     
      sma = add_state(sma,'name','timeout_state','self_timer',min_time,...
         'output_actions',{'SoundOut',iti_sound_id},...
         'input_to_statechange',{'Tup',miss_iti_state});
     
           
      sma = add_state(sma,'name','violation_state','self_timer',min_time,...
      'output_actions',{'SoundOut',iti_sound_id},...
         'input_to_statechange',{'Tup',miss_iti_state});

     
     
      sma = add_state(sma,'name','iti_state_short','self_timer',short_iti_dur,...
         'output_actions',{'SoundOut',iti_sound_id},...
         'input_to_statechange',{'Tup','pre_clean_up_state'});
     
     
     
      sma = add_state(sma,'name','iti_state_long','self_timer',long_iti_dur,...
         'output_actions',{'SoundOut',iti_sound_id},...
         'input_to_statechange',{'Tup','pre_clean_up_state'});
      
     
     
     
     sma=add_state(sma,'name','pre_clean_up_state',...
        'input_to_statechange',{'Clo','clean_up_state'});
      
      sma = add_multi_sounds_state(sma,[-to_sound_id -viol_sound_id -hit_sound_id -miss_sound_id -fa_sound_id -cr_sound_id],...
         'state_name','clean_up_state','return_state','check_next_trial_ready');
      
      
      dispatcher('send_assembler', sma, {'hit_state', 'miss_state', 'false_alarm_state', 'correct_rejection_state' 'violation_state','timeout_state'});
      fprintf('sending\n');
      
      
   otherwise
      warning('do not know how to do %s',action);
end
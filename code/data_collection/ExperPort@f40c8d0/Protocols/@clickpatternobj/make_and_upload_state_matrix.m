function [] = make_and_upload_state_matrix(obj, action)

GetSoloFunctionArgs;


switch action,
 case 'init'
   SoloParamHandle(obj, 'state_matrix');
   
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

   % program starts in state 40:
   stm = [0 0   0 0   0 0   40 0.01  0 0];
   stm = [stm ; zeros(40-rows(stm), 10)];
   stm(36,:) = [35 35   35 35   35 35   35 1   0 0];

   b = rows(stm); 
   %td = SoundSection(obj, 'get_tone_duration')/1000;
   eiti = ExtraITIOnError;
   
   global left1water; global right1water;
   lwvt = LeftWValveTime;   lvid = left1water;
   rwvt = RightWValveTime;  rvid = right1water;
   
   
   RealTimeStates.wait_for_cpoke = b;
   RealTimeStates.sound_playing  = b+1;
   RealTimeStates.wait_for_apoke = b+2;
   RealTimeStates.left_reward    = b+3;
   RealTimeStates.right_reward   = b+4;
   RealTimeStates.extra_iti      = b+5;
   
   

   sound_ids = SoundSection(obj, 'get_sound_ids');
   if SidesSection(obj, 'get_next_side')=='l', 
      sid  = sound_ids.left; 
      onlt = RealTimeStates.left_reward(1);
      onrt = RealTimeStates.extra_iti(1);
   else                         
      sid  = sound_ids.right; 
      onrt = RealTimeStates.right_reward(1);
      onlt = RealTimeStates.extra_iti(1);
   end;
   td = 0
   if onlt == b+3
       td = (value(total_length2))/200000;
   end
   if onrt == b+4
       td = (value(total_length))/200000;
   end
          %Cin Cout Rin Rou  Lin Lou  Tup  Tim   Dou Aou
   stm = [stm ; 
          b+1 b     b   b     b   b     b   100   0   0  ; ... % wait for c poke
          b+1 b+5  b+1 b+1   b+1 b+1   b+2  td    0  sid ; ... % play sound
          b+2 b+2  onlt b+2  onrt b+2  b+2  999   0   0  ; ... % wt fr a poke
          b+3 b+3  b+3 b+3   b+3 b+3   35  lwvt lvid  0  ; ... % l rewrd
          b+4 b+4  b+4 b+4   b+4 b+4   35  rwvt rvid  0  ; ... % r rewrd
          b+5 b+5  b+5 b+5   b+5 b+5   35  eiti   0  -sid ; ... % extra iti
          ];
   
   stm = [stm ; zeros(512-rows(stm),10)];
   
   rpbox('send_matrix', stm);
   state_matrix.value = stm;
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

   
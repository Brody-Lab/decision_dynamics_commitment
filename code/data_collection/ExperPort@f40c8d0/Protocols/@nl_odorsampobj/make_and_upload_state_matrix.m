function RealTimeStates = make_and_upload_state_matrix(obj, action)

GetSoloFunctionArgs;


switch action,
 case 'init'
   SoloParamHandle(obj, 'state_matrix');
   
   SoloParamHandle(obj, 'RealTimeStates', 'value', struct(...
     'wait_for_cpoke', 0, ...  % Waiting for initial center poke
     'odor_valve_on',  0, ...
     'hold_in_center', 0,...
     'wait_for_apoke', 0, ...  % Waiting for an answer poke
     'left_reward',    0, ...
     'right_reward',   0, ...
     'drink_time',     0, ...
     'extra_iti',      0));
   SoloFunctionAddVars('RewardsSection', 'ro_args', 'RealTimeStates');
   
   make_and_upload_state_matrix(obj, 'next_matrix');
   return;
   
 case 'next_matrix',

   % program starts in state 40:
   stm = [0 0   0 0   0 0   40 0.01  0 0  0 0];
   stm = [stm ; zeros(40-rows(stm), 12)];
   stm(36,:) = [35 35   35 35   35 35   35 1   0 0  0 0];

   b = rows(stm);
   %   od = odor_duration; %odor valve open duration, specified in OdorSection.
   eiti = ExtraITIOnError;
   
   global left1water; global right1water;
   lwvt = LeftWValveTime;   lvid = left1water;
   rwvt = RightWValveTime;  rvid = right1water;
   
   
   RealTimeStates.wait_for_cpoke = b;
   RealTimeStates.odor_valve_on  = b+1;
   RealTimeStates.hold_in_center = b+2;
   RealTimeStates.wait_for_apoke = b+3;
   RealTimeStates.left_reward    = b+4;
   RealTimeStates.right_reward   = b+5;
   RealTimeStates.drink_time     = b+6;
   RealTimeStates.extra_iti      = b+7;
   
   

%   if SidesSection(obj, 'get_next_side')=='l', 
%      oid  = odor_ids.left; 
%      onlt = RealTimeStates.left_reward(1);
%      onrt = RealTimeStates.extra_iti(1);
%   else                         
%      oid  = odor_ids.right; 
%      onrt = RealTimeStates.right_reward(1);
%      onlt = RealTimeStates.extra_iti(1);
%   end;

% valid odor sampling time (vot) is set in TimeSection, determined by hit
% history of each progress step.
vot = value(ValidPokeTime);

% water available time (wat) is set in TimeSection, denote the duration
% within which the rat has to go to side poke to get water.
wat = value(WatAvilTime);

drkt = value(DrinkTime);

bk = zeros(1,4); bk(1,value(active_bank)) = 1;
vid = value(valve_id);
ob3 = bk(3)*vid;
ob4 = bk(4)*vid;
clog = 0;
          %Cin Cout Lin Lou  Rin Rou  Tup  Tim   Dou    bk3 bk4  Aou
   stm = [stm ; 
          b+1 b     b   b     b   b    b+7   10    0     0   0    0  ; ... % wait for c poke, if timeup, goes to error state
          b+1 b    b+1 b+1   b+1 b+1   b+2   vot   clog  ob3 ob4  0 ; ... % odor valve open
          b+2 b+3  b+2 b+2   b+2 b+2   b+1   2     0     ob3 ob4  0  ; ... % hold in center
          b+3 b+3  b+4 b+3   b+5 b+3   b+7   wat   0     0   0    0  ; ... % wt for side poke
          b+4 b+4  b+4 b+4   b+4 b+4   b+6  lwvt lvid    0   0    0  ; ... % left rewrd
          b+5 b+5  b+5 b+5   b+5 b+5   b+6  rwvt rvid    0   0    0  ; ... % right rewrd
          b+6 b+6  b+6 35    b+6 35   35    drkt   0     0   0    0  ; ... % drinking time
          b+7 b+7  b+7 b+7   b+7 b+7   35   eiti   0     0   0    0  ; ... % extra iti
          ];
   
   stm = [stm ; zeros(512-rows(stm),12)];
   fsm = rpbox('getstatemachine');
   fsm = SetOutputRouting(fsm, {struct('type', 'dout', 'data', '0-15');...
       struct('type', 'tcp', 'data', [value(OLF_IP) ':3336:SET BANK ODOR Bank3 %v']);...
       struct('type', 'tcp', 'data', [value(OLF_IP) ':3336:SET BANK ODOR Bank4 %v']);...
       struct('type','noop','data','')});
   rpbox('setstatemachine', fsm);
   rpbox('send_matrix', stm, 1);
   state_matrix.value = stm;
   
   % Store the latest RealTimeStates
   push_history(RealTimeStates);
   
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

   
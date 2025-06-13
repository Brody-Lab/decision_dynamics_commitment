function RealTimeStates = make_and_upload_state_matrix(obj, action)

GetSoloFunctionArgs;

switch action,
 case 'init'
   SoloParamHandle(obj, 'state_matrix');
   
   SoloParamHandle(obj, 'RealTimeStates', 'value', struct(...
     'dummy_state', 0, ...  % Waiting for initial center poke
     'odor_valve_on',  0, ...
     'odor_valve_hold', 0,...
     'odor_valve_off', 0));
     
   SoloFunctionAddVars('RewardsSection', 'ro_args', 'RealTimeStates');
   make_and_upload_state_matrix(obj, 'next_matrix');
   return;
   
 case 'next_matrix',

   % program starts in state 40:
   stm = [0 0   0 0   0 0   40 0.01  0 0 0 0];
   stm = [stm ; zeros(40-rows(stm), 12)];
   stm(36,:) = [35 35   35 35   35 35   35 1   0 0 0 0 ];

   b = rows(stm);
   %   od = odor_duration; %odor valve open duration, specified in OdorSection.
   
   
   RealTimeStates.dummy_state = b;
   RealTimeStates.odor_valve_on  = b+1;
   RealTimeStates.odor_valve_hold = b+2;
   RealTimeStates.odor_valve_off = b+3;
   
   

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
% vot = value(ValidPokeTime);

% water available time (wat) is set in TimeSection, denote the duration
% within which the rat has to go to side poke to get water.
% wat = value(WatAvilTime);

% drkt = value(DrinkTime);

% -----------------------------------------------------------
%
% Case where we've reached trial limit
%
% -----------------------------------------------------------

if n_done_trials >= Max_Trials,

  % RealTimeStates.dead_time = 1:pstart-1;
  % RealTimeStates.timeout   = pstart:pstart+2;
   b = rows(stm);
   stm = [stm ; 
           b   b     b   b     b   b   b+1  0.03   0 0 0 0  ; ...
           b+1 b+1   b+1 b+1   b+1 b+1   b  0.5    0 0 0 0 ];      % valves go to # zero (do nothing)
   
   stm = [stm ; zeros(512-size(stm,1),12)];
   state_matrix.value = stm;
   rpbox('send_matrix', stm, 1);
   rpbox('send_statenames', RealTimeStates);
   push_history(RealTimeStates);

   SavingSection(obj, 'savesets', 0);
   SavingSection(obj, 'savedata');
   % extract data and plot and save them.
   if strcmpi(value(pid_plot),'on')
       pid_plot_save;
   end;
   return;
end;

global center1water; 

ov1 = value(ValveID1); ov2 = value(ValveID2);
td = final_valve_delay;     % set and modified in OdorSection
vdur = value(odor_duration); 
fv1 = center1water; 
iti = inter_t_interval;                 % set in odor_testobj.m
auxai = value(log_aux); % trigger auxai high for measurement of vavle latency
 
          %Cin Cout Lin Lou  Rin Rou  Tup  Tim   Dou  ov1  ov2    Aou
   stm = [stm ; 
          b   b     b   b     b   b    b+1  0.01  0    0    0      0  ; ... % 
          b+1 b+1  b+1 b+1   b+1 b+1   b+2  td    0    ov1  ov2    0 ; ... %  
          b+2 b+2  b+2 b+2   b+2 b+2   b+3  vdur fv1   ov1  ov2    0  ; ... % 
          b+3 b+3  b+3 b+3   b+3 b+3   b+4  0.5   0    ov1  ov2    0  ; ... %
          b+4 b+4  b+4 b+4   b+4 b+4   35   iti   0    0    0      0  ; ... 
          ];
   
   stm = [stm ; zeros(512-rows(stm),12)];
   fsm = rpbox('getstatemachine');
   fsm = SetOutputRouting(fsm, {struct('type', 'dout', 'data', '0-15');...
       struct('type', 'tcp', 'data', [value(OLF_IP) ':3336:SET BANK ODOR Bank' num2str(value(ActiveBank1ID)) ' %v']);...
       struct('type', 'tcp', 'data', [value(OLF_IP) ':3336:SET BANK ODOR Bank' num2str(value(ActiveBank2ID)) ' %v']);...
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

   
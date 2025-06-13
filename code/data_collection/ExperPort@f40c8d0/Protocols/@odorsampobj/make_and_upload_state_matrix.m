function RealTimeStates = make_and_upload_state_matrix(obj, action)

GetSoloFunctionArgs;

switch action,
 case 'init'
   SoloParamHandle(obj, 'state_matrix');
   
   SoloParamHandle(obj, 'RealTimeStates', 'value', struct(...
     'wait_for_cpoke', 0, ...  % Waiting for initial center poke
     'hold_in_center', 0,...
     'direct_deliv',   0, ...
     'odor_valve_on',  0, ...
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
   stm = [0 0   0 0   0 0   40 0.01  0 0 0];
   stm = [stm ; zeros(40-rows(stm), length(stm))];
   stm(36,:) = [35 35   35 35   35 35   35 1   0 0 0];

   b = rows(stm);
   %   od = odor_duration; %odor valve open duration, specified in OdorSection.
   eiti = ExtraITIOnError;
   
   global left1water; global right1water; global center1water;
   lwvt = LeftWValveTime;   lvid = left1water;
   rwvt = RightWValveTime;  rvid = right1water;
   
   fvid = center1water; % Final valve (for odor, despite the name)
   
   RealTimeStates.wait_for_cpoke = b;
   RealTimeStates.hold_in_center = b+1;
   RealTimeStates.direct_deliv   = b+2;
   RealTimeStates.odor_valve_on  = b+3;
   RealTimeStates.wait_for_apoke = b+4;
   RealTimeStates.left_reward    = b+5;
   RealTimeStates.right_reward   = b+6;
   RealTimeStates.drink_time     = b+7;
   RealTimeStates.extra_iti      = b+8;
   
   

%   if SidesSection(obj, 'get_next_side')=='l', 
%      oid  = odor_ids.left; 
%      onlt = RealTimeStates.left_reward(1);
%      onrt = RealTimeStates.extra_iti(1);
%   else                         
%      oid  = odor_ids.right; 
%      onrt = RealTimeStates.right_reward(1);
%      onlt = RealTimeStates.extra_iti(1);
%   end;

    % -----------------------------------------------------------
    %
    % Case where we've reached trial limit
    %
    % -----------------------------------------------------------

    if value(session_end),

       srate = get_generic('sampling_rate');
       b = rows(stm);
       stm = [stm ; 
               b   b     b   b     b   b   b+1  0.03   0 0 0 ; ...
              b+1 b+1   b+1 b+1   b+1 b+1   b   2   0 0 0];      % valves go to # zero (do nothing)

       stm = [stm ; zeros(512-size(stm,1), size(stm, 2))];
       state_matrix.value = stm;
       rpbox('send_matrix', stm, 1);
       rpbox('send_statenames', RealTimeStates);
       push_history(RealTimeStates);

       SavingSection(obj, 'savesets', 0);
       SavingSection(obj, 'savedata');
       return;
    end;


    % valid odor poke time (vpt) is set in TimeSection, determined by hit
    % history of each progress step.

    vpt = value(ValidPokeTime); % min time required for rat to poke before odor comes on
    mot = value(MaxOdorTime); % max time that odor valve will stay open
    
    % water available time (wat) is set in TimeSection, denote the duration
    % within which the rat has to go to side poke to get water.
    wat = value(WatAvailTime);

    drkt = value(DrinkTime);

    ov = value(ValveID); % odor valve, from OdorSection

    %% for the first Preodor_Trials, do not turn on odor or final valve
    if sum(value(hit_history)) <= value(Preodor_Trials)
        ov = 0;
        fvid = 0;
    end
    
    %% for the first DirectDelivery_Trials, give water for odor poke
    if sum(value(hit_history)) <= value(DirectDelivery_Trials)
        ddid = fvid + lvid + rvid;
    else
        ddid = fvid;
    end
        
           %Cin Cout Lin Lou  Rin Rou   Tup  Tim   Dou  Bank  Aou
    stm = [stm ; 
           b+1 b     b   b     b   b    b+8   18    0     0    0  ; ... % State b:   wait for c poke, if timeup, goes to error state
           b+1 b    b+1 b+1   b+1 b+1   b+2   vpt fvid   ov    0  ; ... % State b+1: poke in center, odor valve and final valve on
           b+2 b+4  b+2 b+2   b+2 b+2   b+3  lwvt ddid   ov    0  ; ... % State b+2: valid hold in center, if direct delivery, water valves on
           b+3 b+4  b+3 b+3   b+3 b+3   b+4   mot fvid   ov    0  ; ... % State b+3: odor valve and final valve stay on
           b+4 b+4  b+5 b+4   b+6 b+4   b+8   wat   0     0    0  ; ... % State b+4: wait for side poke
           b+5 b+5  b+5 b+5   b+5 b+5   b+7  lwvt lvid    0    0  ; ... % State b+5: left reward
           b+6 b+6  b+6 b+6   b+6 b+6   b+7  rwvt rvid    0    0  ; ... % State b+6: right reward
           b+7 b+7  b+7 35    b+7 35    35   drkt   0     0    0  ; ... % State b+7: drinking time
           b+8 b+8  b+8 b+8   b+8 b+8   35   eiti   0     0    0  ; ... % State b+8: extra iti
           ];

% 
%        
%            %Cin Cout Lin Lou  Rin Rou   Tup  Tim   Dou  Bank  Aou
%     stm = [stm ; 
%            b+1 b     b   b     b   b    b+8   18    0     0    0  ; ... % State b:   wait for c poke, if timeup, goes to error state
%            b+1 b    b+1 b+1   b+1 b+1   b+2   vpt   0          0  ; ... % State b+1: hold in center (perhaps odor valve should be on?)
%            b+2 b+4  b+2 b+2   b+2 b+2   b+3  lwvt ddid         0  ; ... % State b+2: odor valve on and, if direct delivery, water valves on
%            b+3 b+4  b+3 b+3   b+3 b+3   b+4   mot fvid         0  ; ... % State b+3: odor valve on
%            b+4 b+4  b+5 b+4   b+6 b+4   b+8   wat   0          0  ; ... % State b+4: wait for side poke
%            b+5 b+5  b+5 b+5   b+5 b+5   b+7  lwvt lvid         0  ; ... % State b+5: left reward
%            b+6 b+6  b+6 b+6   b+6 b+6   b+7  rwvt rvid         0  ; ... % State b+6: right reward
%            b+7 b+7  b+7 35    b+7 35    35   drkt   0          0  ; ... % State b+7: drinking time
%            b+8 b+8  b+8 b+8   b+8 b+8   35   eiti   0          0  ; ... % State b+8: extra iti
%            ];
% 

    % now pad and send off!
       
    stm = [stm ; zeros(512-rows(stm), size(stm, 2))];

    % this code is necessary to control the odor valves via the state matrix
    fsm = rpbox('getstatemachine');
    fsm = SetOutputRouting(fsm, {struct('type', 'dout', 'data', '0-15');...
           struct('type', 'tcp', 'data', [value(OLF_IP) ':3336:SET BANK ODOR Bank' num2str(value(ActiveBankID)) ' %v']);...
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

   
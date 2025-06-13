function RealTimeStates = make_and_upload_state_matrix(obj, action)

GetSoloFunctionArgs;

switch action
 case 'init'
   SoloParamHandle(obj, 'RealTimeStates', 'value', struct(...
     'wait_for_cpoke', 0, ...  % Waiting for initial center poke
     'odor_poke_in', 0, ... % Odor poke in 
     'odor_valve_on', 0, ... % Odor valve on (after odor delay) 
     'hold_cpoke', 0, ...  % The rat holds in the center port longer than the valid odor sampling time
     'wait_for_apoke', 0, ...  % Waiting for an answer poke 
     'pre_left_reward',0, ...  % Delay before reward obtained at L
     'left_reward',    0, ...  % Reward obtained at L
     'pre_right_reward',0, ... % Delay before reward obtained at R
     'right_reward',   0, ...  % Reward obtained at R
     'no_reward',      0, ...  % No reward, but not necessarily incorrect (occurs when neither L nor R is rewarded)
     'drink_time',     0, ...  % Silent time to permit drinking
     'iti',            0, ...  % Intertrial interval
     'extra_iti',      0, ...  % Penalty ITI 
     'dead_time',      0, ...  % 'Filler' state needed because of
                          ...  % Matlab lag in sending next state
                          ...  % machine 
     'state35',        0) ...  % End-of-trial state (the state number
                          ...  % is an ancient convention) 
                   );
 
     SoloParamHandle(obj, 'state_matrix');
     SoloParamHandle(obj, 'deliver_water', 'value', 1);
     
     % TrialEvents is lifted from Masa to extract event times using NSpike clock
     SoloFunctionAddVars('TrialEvents', 'rw_args', 'RealTimeStates');                

 case 'next_matrix'
 otherwise
   error('Unknown action');
end;

itilist = value(iti_list);

lwpt = value(LeftWValve);
rwpt = value(RightWValve);

avail = value(RewardAvail);
iti_length = itilist(value(n_done_trials+1));

side = side_list(n_done_trials+1);
odor = odor_list(n_done_trials+1);

left = get_generic('side_list_left');
right = get_generic('side_list_right');
neither = get_generic('side_list_neither');
both = get_generic('side_list_both');


% This next section assigns NUMBERS for each state
% -----------------------------------------------------------
pstart = 39;


ITIS = pstart; % ITI - note that this is now at the BEGINNING of the trial, to allow flow controllers to equilibrate - GF 4/20/07
WcpS = pstart + 1; % wait for center poke
OpkS = pstart + 2; % odor poke in
OvoS = pstart + 3; % odor valve on
CpkS = pstart + 4; % hold in center poke longer than valid sampling time
WpkS = pstart + 5; % wait for water poke
LrwpS = pstart + 6; % reward delay preceding water at L
LrwS = pstart + 7; % water at L
RrwpS = pstart + 8; % reward delay preceding water at R
RrwS = pstart + 9; % water at R
NrwS = pstart + 10; % No water at either L or R
DrkS = pstart + 11; % drinking
ITIS2 = pstart + 12; % Penalty ITI

RealTimeStates.iti = ITIS;         % 39
RealTimeStates.extra_iti = ITIS2; % 51 - where bad responses go
RealTimeStates.wait_for_cpoke = WcpS;   % 40
RealTimeStates.odor_poke_in = OpkS;   % 41
RealTimeStates.odor_valve_on = OvoS;   % 42
RealTimeStates.hold_cpoke = CpkS;     % 43
RealTimeStates.wait_for_apoke = WpkS;     % 44
RealTimeStates.pre_left_reward = LrwpS;      % 45
RealTimeStates.left_reward = LrwS;      % 46
RealTimeStates.pre_right_reward = RrwpS;     % 47
RealTimeStates.right_reward = RrwS;     % 48
RealTimeStates.no_reward = NrwS;     % 49
RealTimeStates.drink_time = DrkS;     % 50
RealTimeStates.dead_time = [1 35];

% Begin stm definition
% -----------------------------------------------------------

%        Cin    Cout    Lin    Lout     Rin     Rout    Tup    Timer    Dout  BankA   BankB  Aout
stm = [ pstart pstart  pstart pstart   pstart  pstart  pstart   0.01     0     0        0     0; ... % go to start of program
    ];
stm = [stm ; zeros(pstart-size(stm,1), size(stm, 2))]; % pad till start state (pstart)
stm(36,:) = [35 35   35 35   35 35    35  100 0 0 0 0];
RealTimeStates.state35 = 36;



% -----------------------------------------------------------
%
% Case where we've reached trial limit
%
% -----------------------------------------------------------

if n_done_trials >= Max_Trials,

   srate = get_generic('sampling_rate');
%  white_noise_len   = 2;
 %  white_noise_sound = 0.2*0.095*randn(1,floor(white_noise_len*srate));
   % whln = white_noise_len;
   
   % rpbox('loadrp3stereosound2', {[]; 0.3*value(white_noise_sound)});

   RealTimeStates.dead_time = 1:pstart-1;
   RealTimeStates.timeout   = pstart:pstart+2;
   b = rows(stm);
   stm = [stm ; 
           b   b     b   b     b   b   b+1  0.03   0 0 0 0; ...
          b+1 b+1   b+1 b+1   b+1 b+1   b   2   0 0 0 0];      % valves go to # zero (do nothing)

   stm = [stm ; zeros(512-size(stm,1), size(stm, 2))];
   state_matrix.value = stm;
   rpbox('send_matrix', stm, 1);
   rpbox('send_statenames', RealTimeStates);
   push_history(RealTimeStates);

   SavingSection(obj, 'savesets', 0);
   SavingSection(obj, 'savedata');
   return;
end;


% -----------------------------------------------------------
%
% Now to work
%
% -----------------------------------------------------------

switch WaterDelivery,
    case 'only if nxt pke corr',
        if side == left % lpkA and rpkA are acts (states to go to) on L and R pokes, respectively
            lpkA = LrwpS;
            rpkA = ITIS2;  
        elseif side == right
            lpkA = ITIS2;
            rpkA = RrwpS;
        elseif side == neither
            lpkA = NrwS;
            rpkA = NrwS;
        elseif side == both
            lpkA = LrwpS;
            rpkA = RrwpS;
        end;
        
    otherwise,
        error(['Don''t know how to do this WaterDelivery: ' WaterDelivery]);
end;

global left1water;  
global right1water; 
global center1water; 

if deliver_water==1,
   lvid = left1water; rvid = right1water;
else
   lvid = 0;          rvid = 0;
end;


% % In RT rigs, stop sound 1; upstairs, play 10 ms v soft sound to halt
% % main sound:
% global fake_rp_box; 
% if fake_rp_box == 2, quiet = -1; else quiet = 2; end;

b = pstart + 1;

%% get timing values to be used in state matrix

tl = value(TrialLength);

vst = value(valid_samp_time); % the time rats have to stay in the center port
mot = value(max_odor_time); % max time that odor valve will stay open

% find odor delay
od = value(odor_delay_list(value(n_done_trials) + 1));

% find water valve delay
wvd = value(reward_delay_list(value(n_done_trials) + 1));

% note that the state matrix doesn't seem to deal well w/ times of 0
if wvd <= 0; wvd = 0.001; end
if od <= 0; odd = 0.001; end

drink_length = 0.2; % pause between correct answer and state 35; useful for visualizing trials in colored bar form

% set appropriate odor valves for left odor/s and right odor/s
% note1: both valves (one in each bank) are opened simultaneously in each
% trial; what determines which mixture is presented is the flow rate of the
% flow controllers
% note2: for pure odor trials, one of the 'divert valves' is opened, b/c it
% is not good to set the flow controller's flow rate to 0

% get current stim (to find out if it's a pure odor trial)
current_stim = value(current_odor); % note that current_stim will be 0 before odor_list and stim_list are created

odor_pair = ceil(odor / max_mixture_fractions); % which odor pair this stimulus belongs to
odor_valve1_ind = ((odor_pair - 1) * 2) + 1; % find the odor valve index corresponding to odor A for this pair
odor_valve2_ind = ((odor_pair - 1) * 2) + 2; % find the odor valve index corresponding to odor B for this pair

if (current_stim ~= 0) & (eval(strcat('odor_A_percent', num2str(current_stim))) == 0) %not zeroth trial, and pure odor B trial
    eval(strcat('ov1 = ', num2str(value(DivertValve)), ';')); %set BankA valve to divert valve
else
    eval(strcat('ov1 = value(odor_valve', num2str(odor_valve1_ind), ');')); %set BankA valve to proper odor valve
end

if (current_stim ~= 0) & (eval(strcat('odor_A_percent', num2str(current_stim))) == 100) %not zeroth trial, and pure odor A trial
    eval(strcat('ov2 = ', num2str(value(DivertValve)), ';')); %set BankB valve to divert valve
else
    eval(strcat('ov2 = value(odor_valve', num2str(odor_valve2_ind), ');')); %set BankB valve to proper odor valve
end


%% Odor Valve States

% Cin     Cout   Lin    Lout    Rin    Rout    Tup         Timer   Dout  BankA   BankB   Aout
stm = [stm ; ...
   ITIS    ITIS   ITIS   ITIS    ITIS   ITIS   b       iti_length    0      0       0       0 ; ... %state b - 1 (39): ITI state
   b+1     b      b      b       b      b      35           tl       0      0       0       0 ; ... %state b (40): wait for c_poke
   b+1     b      b+1    b+1     b+1    b+1    b+2          od       0      0       0       0 ; ... %b+1: odor poke in
   b+2     35     b+2    b+2     b+2    b+2    b+3          vst      0     ov1     ov2      0 ; ... %b+2: odor valve on
   b+3     b+4    b+3    b+3     b+3    b+3    b+4          mot      0     ov1     ov2      0 ; ... %b+3: odor valve stays on until odorpokeout or max odor time
   ]; 

%% Water Valve States

stm = [stm; ...
   b+4     b+4    lpkA   b+4    rpkA    b+4    35          avail     0      0       0       0 ; ... %b+4: WpkS (Water poke state)
   LrwpS   LrwpS  LrwpS  LrwpS  LrwpS   LrwpS  LrwS          wvd     0      0       0       0 ; ... %b+5: LrwpS (L reward prestate)
   LrwS    LrwS   LrwS   LrwS   LrwS    LrwS   DrkS         lwpt    lvid    0       0       0 ; ... %b+6: LrwS (L reward state) 
   RrwpS   RrwpS  RrwpS  RrwpS  RrwpS   RrwpS  RrwS          wvd     0      0       0       0 ; ... %b+7: RrwpS (R reward prestate)
   RrwS    RrwS   RrwS   RrwS   RrwS    RrwS   DrkS         rwpt    rvid    0       0       0 ; ... %b+8: RrwS (R reward state)
   NrwS    NrwS   NrwS   NrwS   NrwS    NrwS    35          0.01     0      0       0       0 ; ... %b+9: NrwS (No reward state)   
   ];

%% Drinking States

stm = [stm ; ...
    DrkS  DrkS  DrkS    DrkS    DrkS    DrkS    35     drink_length   0     0       0       0; ...  %b+10: Drinking state
    ];

%% Extra ITI State
iti = ITIS2;

stm = [stm ; ...
    iti   iti   iti     iti     iti     iti     35       Penalty_ITI   0     0      0        0; ...  %b+11: Penalty ITI
    ];


%% now pad and send off!
stm = [stm ; zeros(512-size(stm,1), size(stm, 2))];

% this code is necessary to control the odor valves via the state matrix
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

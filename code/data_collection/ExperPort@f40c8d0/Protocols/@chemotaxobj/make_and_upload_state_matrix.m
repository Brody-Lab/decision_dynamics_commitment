function RealTimeStates = make_and_upload_state_matrix(obj, action)

GetSoloFunctionArgs;

switch action
 case 'init'
   SoloParamHandle(obj, 'RealTimeStates', 'value', struct(...
     'wait_for_cpoke', 0, ...  % Waiting for initial center poke
     'odor_poke_in', 0, ... % Odor poke in, odor valve on 
     'final_valve_delay', 0, ... % an exponential random delay between nose poke and final valve open
     'valid_samp_time', 0, ...  % Valid odor sampling time
     'hold_cpoke',     0, ...  % During which, the rat still holds in the c_port
     'wait_for_apoke', 0, ...  % Waiting for an answer poke 
     'pre_left_reward',0, ...  % Delay before reward obtained at L
     'left_reward',    0, ...  % Reward obtained at L
     'pre_right_reward',0, ... % Reward obtained at R
     'right_reward',   0, ...  % Delay before reward obtained at R
     'drink_time',     0, ...  % Silent time to permit drinking
     'timeout',        0, ...  % Penalty state
     'iti',            0, ...  % Intertrial interval
     'dead_time',      0, ...  % 'Filler' state needed because of
                          ...  % Matlab lag in sending next state
                          ...  % machine 
     'state35',        0, ...  % End-of-trial state (the state number
                          ...  % is an ancient convention) 
     'extra_iti',      0, ...  % State of penalty within ITI (occurs if
                          ...  % rat pokes during ITI - usually longer
                          ...  % than ITI) 
     'hit_state',      0) ...
                   );
 
     SoloParamHandle(obj, 'state_matrix');
     SoloParamHandle(obj, 'deliver_water', 'value', 1);
     
 case 'next_matrix'
 otherwise
   error('Unknown action');
end;

itilist = value(iti_list);

lwpt = value(LeftWValve);
rwpt = value(RightWValve);

avail = value(RewardAvail);
iti_length = itilist(value(n_done_trials+1));
% if ~strcmpi(value(WaterDelivery),'direct')
%     iti_length = max(iti_length - avail, 0.01)
% else
%     avail = 0.01;
% end;

side = side_list(n_done_trials+1);
odor = odor_list(n_done_trials+1);
left = get_generic('side_list_left');





% This next section assigns NUMBERS for each state
% -----------------------------------------------------------
pstart = 40;



WcpS = pstart;
OvoS = pstart + 1; % odor valve on (when odor poke in)
FdlS = pstart + 2; % final valve delay
FvoS = pstart + 3; % final valve on
CpkS = pstart + 4; % hold in center poke
WpkS = pstart + 5; % wait for water poke
LrwpS = pstart + 6; % reward delay preceding water at L
LrwS = pstart + 7; % water at L
RrwpS = pstart + 8; % reward delay preceding water at R
RrwS = pstart + 9; % water at R
DrkS = pstart + 10; % drinking
ITIS = pstart + 11; % ITI

RealTimeStates.wait_for_cpoke = WcpS;   % 40
RealTimeStates.odor_poke_in = OvoS;   % 41
RealTimeStates.final_valve_delay = FdlS;   % 42
RealTimeStates.valid_samp_time = FvoS;  % 43
RealTimeStates.hold_cpoke = CpkS;     % 44
RealTimeStates.wait_for_apoke = WpkS;     % 45
RealTimeStates.pre_left_reward = LrwpS;      % 46
RealTimeStates.left_reward = LrwS;      % 47
RealTimeStates.pre_right_reward = RrwpS;     % 48
RealTimeStates.right_reward = RrwS;     % 49
RealTimeStates.drink_time = DrkS;     % 50
RealTimeStates.hit_state = ITIS;         % 51
RealTimeStates.extra_iti = ITIS+1; % 52 - where bad responses go
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
        if     side==left, lpkA = LrwpS;   rpkA = ITIS+1;  % lpkA and rpkA are acts (states to go to) on L and R pokes, respectively
        elseif side==1-left, lpkA = ITIS+1; rpkA = RrwpS;
        end;
    case 'next corr poke', % GF 11/12/06: I think this means that incorrect choice doesn't preclude a later, correct choice being rewarded
        if     side==left, lpkA = LrwpS; rpkA = WpkS;
        elseif side==1-left, lpkA = WpkS; rpkA = RrwpS;
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

ovid = center1water; % Final valve (for odor, despite the name)


% In RT rigs, stop sound 1; upstairs, play 10 ms v soft sound to halt
% main sound:
global fake_rp_box; 
if fake_rp_box == 2, quiet = -1; else quiet = 2; end;

b = pstart;

%% get timing values to be used in state matrix

tl = value(TrialLength);
rtm=floor(tl+(rand*tl));
vst = value(valid_samp_time); % the time rats have to stay in the center port
mot = value(max_odor_time); % max time that odor valve will stay open

% odor travel time is the empirically determined delay necessary between odor valve on and final valve on, so that odor intensity is no longer "rising"
ott = value(odor_travel_time);

% find delay before final valve opens
odor_delay_current = value(odor_delay_list(value(n_done_trials) + 1));
fvd = odor_delay_current - ott;

% it's possible that odor travel time will be greater than min odor delay inputted, so make sure fvd > 0
% also note that the state matrix doesn't seem to deal well w/ times of 0
if fvd <= 0; fvd = 0.001; end

% find water valve delay
wvd = value(reward_delay_list(value(n_done_trials) + 1));
% note that the state matrix doesn't seem to deal well w/ times of 0
if wvd <= 0; wvd = 0.001; end

drink_length = 0.2; % pause between correct answer and iti; useful for visualizing trials in colored bar form

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

%%MCS MODIFICATIONS OF STATE MATRIX: final valve not activated, odor left
%%on while waiting for reward_poke, goes into wait for 


%% Odor Valve States

% Cin     Cout   Lin    Lout    Rin    Rout     Tup         Timer   Dout  BankA   BankB   Aout
stm = [stm ; ...
   b+3     b      b      b       b      b      b+5          rtm      0      0       0       0 ; ... %MCS doesn't just wait for poke! state b (40): wait for c_poke
   b+1     b      b+1    b+1     b+1    b+1    b+3          ott      0     ov1     ov2      0 ; ... %b+1: MCS: this state is unuseodor poke in, odor valve on
   b+2     b      b+2    b+2     b+2    b+2    b+3          fvd      0     ov1     ov2      0 ; ... %b+2: MCS: this state is unused final valve delay; odor valve stays on (ovso)
   b+3     b      b+3    b+3     b+3    b+3    b+5          vst      0     ov1     ov2      0 ; ... %b+3: final valve on; valid sampling time; ovso
   b+4     b+5    b+4    b+4     b+4    b+4    b+5          mot      0     ov1     ov2      0 ; ... %b+4: MCS: this state is unused hold in center poke; final valve stays on; ovso
   ]; 
%% Water Valve States

stm = [stm; ...
   b+5     b+5    lpkA   b+5    rpkA    b+5     b           avail    0    ov1     ov2       1 ; ... %b+5: WpkS (Water poke state)
   LrwpS   LrwpS  LrwpS  LrwpS  LrwpS   LrwpS  LrwS          wvd     0      0       0       1 ; ... %b+6: LrwpS (L reward prestate)
   LrwS    LrwS   LrwS   LrwS   LrwS    LrwS   DrkS         lwpt    lvid    0       0      -1 ; ... %b+7: LrwS (L reward state) 
   RrwpS   RrwpS  RrwpS  RrwpS  RrwpS   RrwpS  RrwS          wvd     0      0       0       1 ; ... %b+8: RrwpS (R reward prestate)
   RrwS    RrwS   RrwS   RrwS   RrwS    RrwS   DrkS         rwpt    rvid    0       0      -1 ; ... %b+9: RrwS (R reward state)
   ];
%% ITI States
iti = ITIS;

stm = [stm ; ...
    DrkS  DrkS  DrkS    DrkS    DrkS    DrkS    35     drink_length   0     0       0      -1; ...  %b+10: Drinking state
    iti   iti   iti     iti     iti     iti     35       iti_length   0     0       0      -1; ...  %b+11: benign ITI state
    iti+1 iti+1 iti+1   iti+1   iti+1   iti+1   35       iti_length   0     0       0      -1; ...  %b+12: ITI where miss trials end up
    ];


%% now pad and send off!
stm = [stm ; zeros(512-size(stm,1), size(stm, 2))];

% this code is necessary to control the odor valves via the state matrix
fsm = rpbox('getstatemachine');
fsm = SetOutputRouting(fsm, {struct('type', 'dout', 'data', '0-15');...
       struct('type', 'tcp', 'data', [value(OLF_IP) ':3336:SET BANK ODOR Bank' num2str(value(ActiveBank1ID)) ' %v']);...
       struct('type', 'tcp', 'data', [value(OLF_IP) ':3336:SET BANK ODOR Bank' num2str(value(ActiveBank2ID)) ' %v']);...
       struct('type', 'sound', 'data', '0')});
rpbox('setstatemachine', fsm);


rpbox('send_matrix', stm, 1);
state_matrix.value = stm;

% Store the latest RealTimeStates
push_history(RealTimeStates);

return;

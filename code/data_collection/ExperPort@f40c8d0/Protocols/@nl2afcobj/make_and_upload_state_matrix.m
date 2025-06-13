function RealTimeStates = make_and_upload_state_matrix(obj, action)

GetSoloFunctionArgs;

switch action
 case 'init'
   SoloParamHandle(obj, 'RealTimeStates', 'value', struct(...
     'wait_for_cpoke', 0, ...  % Waiting for initial center poke
     'rand_valve_delay', 0, ... % an exponential random delay between nose poke and vavle open
     'valid_samp_time', 0, ...  % Valid odor sampling time
     'hold_cpoke',     0, ...  % During which, the rat still holds in the c_port
     'wait_for_apoke', 0, ...  % Waiting for an answer poke 
     'left_dirdel',    0, ...  % Direct delivery on LHS
     'right_dirdel',   0, ...  % Direct delivery on RHS
     'left_reward',    0, ...  % Reward obtained on LHS
     'right_reward',   0, ...  % Reward obtained on RHS
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

% stne = 1;
% sound_len = value(chord_sound_len);
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



% This next section assigns NUMBERS for each state
% -----------------------------------------------------------
pstart = 40;



WcpS = pstart;
VdlS = pstart + 1;
VstS = pstart + 2; % valid odor poke time
CpkS = pstart + 3; % hold in center till C_out
WpkS = pstart + 4;
LrwS = pstart + 5;
RrwS = pstart + 6;
LddS = pstart + 7;
RddS = pstart + 8;
ITI_state = pstart+9;

RealTimeStates.wait_for_cpoke=WcpS;   % 40
RealTimeStates.rand_valve_delay=VdlS;   % 41
RealTimeStates.valid_samp_time=VstS;  % 42
RealTimeStates.hold_cpoke=CpkS;     % 43
RealTimeStates.wait_for_apoke=WpkS;     % 44
RealTimeStates.left_reward = LrwS;      % 45
RealTimeStates.right_reward = RrwS;     % 46
RealTimeStates.left_dirdel = LddS;      % 47
RealTimeStates.right_dirdel = RddS;     % 48
RealTimeStates.hit_state = ITI_state;         % 49
RealTimeStates.extra_iti = ITI_state+1; % 50 - where bad responses go
RealTimeStates.dead_time = [1 35];

% Begin stm definition
% -----------------------------------------------------------

%        Cin    Cout    Lin    Lout     Rin     Rout    Tup    Timer    Dout  bk3  bk4 Aout
stm = [ pstart pstart  pstart pstart   pstart  pstart  pstart   0.01     0     0    0   0 ; ... % go to start of program
    ];
stm = [stm ; zeros(pstart-size(stm,1),12)]; % PAD till start state (pstart)
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
           b   b     b   b     b   b   b+1  0.03   0 0 0 0 ; ...
          b+1 b+1   b+1 b+1   b+1 b+1   b   2   0 0 0 0];      % valves go to # zero (do nothing)

   stm = [stm ; zeros(512-size(stm,1),12)];
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
        if     side==left, lpkA = LrwS;   rpkA = ITI_state+1;  % lpkA and rpkA are acts (states to go to) on L and R pokes, respectively
        elseif side==1-left, lpkA = ITI_state+1; rpkA = RrwS;
        end;
    case 'next corr poke',
        if     side==left, lpkA = LrwS; rpkA = WpkS;
        elseif side==1-left, lpkA = WpkS; rpkA = RrwS;
        end;
    case 'direct',
        if     side==left, lpkA = LddS; rpkA = LddS; % post-tone act is either the Left or Right direct water delivery
        elseif side==1-left, rpkA = RddS; lpkA = RddS;
        end;

    otherwise,
        error(['Don''t know how to do this WaterDelivery: ' WaterDelivery]);
end;

global left1water;  
global right1water; 

if deliver_water==1,
   lvid = left1water; rvid = right1water;
else
   lvid = 0;          rvid = 0;
end;


% In RT rigs, stop sound 1; upstairs, play 10 ms v soft sound to halt
% main sound:
global fake_rp_box; 
if fake_rp_box == 2, quiet = -1; else quiet = 2; end;

% min_sound = 0.3; rest_sound = max(sound_len - min_sound, 0.01);

b = pstart;
vdl= value(rand_valve_delay);
vst = value(valid_samp_time); % the time rats have to stay in the center port, set in TimesSection
ob3 = value(L_valve); % odor valve ID in Bank3
ob4 = value(R_valve); % odor valve ID in Bank4
auxai = 1; % trigger auxai high for measurement of vavle latency

% Cin    Cout   Lin    Lout    Rin    Rout   Tup    Timer   Dout  bk3  bk4  Aout
stm = [stm ; ...
   b+1     b      b      b       b      b   ITI_state+1  15   0    0    0    0 ; ...    %b: wait for c_poke
   b+1     b      b+1    b+1     b+1    b+1  b+2    vdl       0    0    0    0 ; ...    %b+1: valide odor poke
   b+2     b      b+2    b+2     b+2    b+2  b+3    vst    auxai   ob3  ob4   0 ; ...    %b+1: valide odor poke
   b+3     b+4    b+3    b+3     b+3    b+3  b+4    1         0    ob3  ob4   0 ; ...    %b+2: hold in center poke
    ];
if ~strcmpi(value(WaterDelivery), 'direct')
    stm = [stm; ...
        b+4   b+4    lpkA   b+4    rpkA    b+4   ITI_state+1   avail  0   0   0   0 ; ...    %b+3: WpkS
        ];
else % go directly to water delivery
    stm = [stm; ...
        lpkA    lpkA    lpkA    lpkA    lpkA    lpkA    lpkA    0.02  0  0  0  0       ;...
        ];
end;

stm = [stm; ...
    LrwS  LrwS  LrwS    LrwS   LrwS    LrwS  ITI_state  lwpt    lvid   0   0   0     ; ...
    RrwS  RrwS  RrwS    RrwS   RrwS    RrwS  ITI_state  rwpt    rvid   0   0   0     ; ...
    LddS  LddS  LddS    LddS   LddS    LddS  ITI_state  lwpt    lvid   0   0   0     ; ...
    RddS  RddS  RddS    RddS   RddS    RddS  ITI_state  rwpt    rvid   0   0   0 ];

% and finally add the ITI state
iti = ITI_state; iti_wrong = ITI_state + 1;
stm = [stm ; ...
    iti   iti   iti     iti     iti     iti     35 iti_length   0   0   0   0; ...  % benign ITI state
    iti+1 iti+1 iti+1   iti+1   iti+1   iti+1   35 iti_length   0   0   0   0; ...  % ITI where miss trials end up
    ];

% now pad and send off!
stm = [stm ; zeros(512-size(stm,1),12)];

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




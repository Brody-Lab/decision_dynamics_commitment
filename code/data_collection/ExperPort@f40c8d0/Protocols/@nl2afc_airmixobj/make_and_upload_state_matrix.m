function RealTimeStates = make_and_upload_state_matrix(obj, action)

GetSoloFunctionArgs;

switch action
 case 'init'
   SoloParamHandle(obj, 'RealTimeStates', 'value', struct(...
     'wait_for_cpoke', 0, ...  % Waiting for initial center poke   'odor_travel_time', 0, ... % time between bank valve open to final valve open
     'rand_valve_delay', 0, ... % an exponential random delay between nose poke and bank valve open
     'valid_samp_time', 0, ...  % Valid odor sampling time
     'hold_cpoke',     0, ...  % During which, the rat still holds in the c_port
     'wait_for_apoke', 0, ...  % Waiting for an answer poke 
     'left_dirdel',    0, ...  % Direct delivery on LHS
     'right_dirdel',   0, ...  % Direct delivery on RHS
     'left_reward',    0, ...  % Reward obtained on LHS
     'right_reward',   0, ...  % Reward obtained on RHS
     'drink_time',     0, ...  % Silent time to permit drinking
     'left_rand',      0, ...  % Random deliery at the left
     'right_rand',     0, ...  % Random deliery at the right
     'timeout',        0, ...  % Penalty state
     'ITI',            0, ...  % 'Filler' state needed because of
                          ...  % Matlab lag in sending next state
                          ...  % machine 
     'state35',        0)); ...  % End-of-trial state (the state number
                               % is an ancient convention)
    
                           %     'iti',            0, ...  % Intertrial interval
%     'extra_iti',      0, ...  % State of penalty within ITI (occurs if
                          ...  % rat pokes during ITI - usually longer
                          ...  % than ITI) 
%     'hit_state',      0) );
               
 
     SoloParamHandle(obj, 'state_matrix');
     SoloParamHandle(obj, 'deliver_water', 'value', 1);
     SoloParamHandle(obj, 'probe_reward', 'value', 0);
     
 case 'next_matrix'
 otherwise
   error('Unknown action');
end;

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
% OttS = pstart + 1;
RvdS = pstart + 1;
VstS = pstart + 2; % valid odor sampling time
CpkS = pstart + 3; % hold in center till C_out
WpkS = pstart + 4;
LrwS = pstart + 5;
RrwS = pstart + 6;
LddS = pstart + 7;
RddS = pstart + 8;
%ITI_state = pstart+10;
LrdS = pstart + 50; % left random water delivery for probe trials
RrdS = pstart + 51; % right random water delivery ...

RealTimeStates.wait_for_cpoke=WcpS;   % 40
% RealTimeStates.odor_travel_time=OttS;  % 41
RealTimeStates.rand_valve_delay=RvdS;   % 42
RealTimeStates.valid_samp_time=VstS;  % 43
RealTimeStates.hold_cpoke=CpkS;     % 44
RealTimeStates.wait_for_apoke=WpkS;     % 45
RealTimeStates.left_reward = LrwS;      % 46
RealTimeStates.right_reward = RrwS;     % 47
RealTimeStates.left_dirdel = LddS;      % 48
RealTimeStates.right_dirdel = RddS;     % 49
%RealTimeStates.hit_state = ITI_state;         % 50
%RealTimeStates.extra_iti = ITI_state+1; % 51 - where bad responses go
RealTimeStates.left_rand = LrdS;        %90
RealTimeStates.right_rand = RrdS;        %91


% Begin stm definition
% -----------------------------------------------------------

%        Cin    Cout    Lin    Lout     Rin     Rout    Tup    Timer    Dout  bk_L  bk_R  Aout
stm = [ pstart pstart  pstart pstart   pstart  pstart  pstart   0.01     0     0      0    0   ; ... % go to start of program
    ];
stm = [stm ; zeros(pstart-size(stm,1), size(stm,2))]; % PAD till start state (pstart)
stm(36,:) = [35 35   35 35   35 35    36  0.00001      0 0 0 0];
stm(37,:) = [36 36   36 36   36 36    35  iti_length 0 0 0 0];
RealTimeStates.state35 = 36;
RealTimeStates.ITI = [1:37];

% -----------------------------------------------------------
%
% Case where we've reached trial limit
%
% -----------------------------------------------------------

if n_done_trials >= Max_Trials

   srate = get_generic('sampling_rate');
%  white_noise_len   = 2;
 %  white_noise_sound = 0.2*0.095*randn(1,floor(white_noise_len*srate));
   % whln = white_noise_len;
   
   % rpbox('loadrp3stereosound2', {[]; 0.3*value(white_noise_sound)});

   RealTimeStates.ITI = 1:pstart-1;
   RealTimeStates.timeout   = pstart:pstart+2;
   b = rows(stm);
   stm = [stm ; 
           b   b     b   b     b   b   b+1  0.03  0  0  0 0 ; ...
          b+1 b+1   b+1 b+1   b+1 b+1   b    2    0  0  0 0];      % valves go to # zero (do nothing)

   stm = [stm ; zeros(512-size(stm,1),size(stm,2))];
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
        deliver_water.value = 1;
        if     side==left, lpkA = LrwS;   rpkA = 35;  % lpkA and rpkA are acts (states to go to) on L and R pokes, respectively
        elseif side==1-left, lpkA = 35; rpkA = RrwS;
        end;
    case 'next corr poke',
        deliver_water.value = 1;
        if     side==left, lpkA = LrwS; rpkA = WpkS;
        elseif side==1-left, lpkA = WpkS; rpkA = RrwS;
        end;
    case 'direct',
        deliver_water.value = 1;
        if     side==left, lpkA = LddS; rpkA = LddS; % post-tone act is either the Left or Right direct water delivery
        elseif side==1-left, rpkA = RddS; lpkA = RddS;
        end;
    case 'probe'
        lpkA = LrdS; rpkA = RrdS;
        if rand > .5
            deliver_water.value = 1;
        else
            deliver_water.value = 0;
        end
        probe_reward.value = probe_reward + deliver_water;
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

global fake_rp_box; 
if fake_rp_box == 2, quiet = -1; else quiet = 2; end;


b = pstart;

% stne = 1;
% sound_len = value(chord_sound_len);
switch value(Tone_cue)
    case 'OFF'
        cue = 0;
    case 'ON'
        cue = value(mix_ID); % if sound cue is on, the tone id is the same as odor mix ID.
end;

% ott = value(odor_travel_time); % final valve delay
rvd = value(rand_valve_delay); % randm final valve delay after odor travel time
vst = value(valid_samp_time); % the time rats have to stay in the center port, set in TimesSection
fv = 2^0; 

vl = value(L_valve); % left odor valve ID
vr = value(R_valve); % left odor valve ID


% Cin    Cout   Lin    Lout    Rin    Rout   Tup    Timer   Dout  Bank_L  Bank_R  Aout
stm = [stm ; ...
   b+1     b      b      b       b      b    35      300       0    0       0      0 ; ...    %b: wait for c_poke
 %  b+1     b      b+1    b+1     b+1    b+1  b+2    ott       0    vl     vr      cue ;  ...    %b+1: odor travel time
   b+1     b      b+1    b+1     b+1    b+1  b+2    rvd       0    0       0      0 ; ...    %b+2 randam valve delay
   b+2     b      b+2    b+2     b+2    b+2  b+3    vst       0    vl     vr      0 ; ...    %b+3: valide odor poke
   b+3     b+4    b+3    b+3     b+3    b+3  b+4    1         0    vl     vr      0 ; ...    %b+4: time before poke out
    ];
if ~strcmpi(value(WaterDelivery), 'direct')
    stm = [stm; ...
        b+4   b+4    lpkA   b+4    rpkA    b+4      35   avail  0   0  0  0 ; ...    %b+4: WpkS wait for ans poke
        ];
else % go directly to water delivery
    stm = [stm; ...
        lpkA    lpkA    lpkA    lpkA    lpkA    lpkA    lpkA    0.02  0  0  0  0       ;...
        ];
end;

stm = [stm; ...
    LrwS  LrwS  LrwS    LrwS   LrwS    LrwS  35  lwpt    lvid   0    0   0     ; ...
    RrwS  RrwS  RrwS    RrwS   RrwS    RrwS  35  rwpt    rvid   0    0   0     ; ...
    LddS  LddS  LddS    LddS   LddS    LddS  35  lwpt    lvid   0    0   0     ; ...
    RddS  RddS  RddS    RddS   RddS    RddS  35  rwpt    rvid   0    0   0     ];


% and finally add the ITI state
%{
iti = ITI_state; iti_wrong = ITI_state + 1;
stm = [stm ; ...
    iti   iti   iti     iti     iti     iti     35 iti_length   0   0   0   0; ...  % benign ITI state
    iti+1 iti+1 iti+1   iti+1   iti+1   iti+1   35 iti_length   0   0   0   0; ...  % ITI where miss trials end up
    ];
%}
% add two extra states for random reward in probe trials.

stm = [stm; zeros(LrdS-size(stm,1),size(stm,2))];
stm = [stm;...
    LrdS  LrdS  LrdS    LrdS   LrdS    LrdS  35  lwpt      lvid   0   0   0     ; ...
    RrdS  RrdS  RrdS    RrdS   RrdS    RrdS  35  rwpt      rvid   0   0   0 ;];

% now pad and send off!
stm = [stm ; zeros(512-size(stm,1),size(stm,2))];

fsm = rpbox('getstatemachine');
fsm = SetOutputRouting(fsm, {struct('type', 'dout', 'data', '0-15');...
       struct('type', 'tcp', 'data', [value(OLF_IP) ':3336:SET BANK ODOR Bank' num2str(value(bk_L)) ' %v']);...
       struct('type', 'tcp', 'data', [value(OLF_IP) ':3336:SET BANK ODOR Bank' num2str(value(bk_R)) ' %v']);...
       struct('type','noop','data','')});
rpbox('setstatemachine', fsm);

rpbox('send_matrix', stm, 1);
state_matrix.value = stm;

% Store the latest RealTimeStates
push_history(RealTimeStates);

return;




function RealTimeStates = make_and_upload_state_matrix(obj, action)
 
GetSoloFunctionArgs;
amp = 0.05;

switch action
 case 'init'
   SoloParamHandle(obj, 'RealTimeStates', 'value', struct(...
     'wait_for_cpoke', 0, ...  % Waiting for initial center poke
     'pre_chord',      0, ...  % Silent period preceeding GO signal
     'chord',          0, ...  % GO signal
     'wait_for_apoke', 0, ...  % Waiting for an answer poke (after GO signal)
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



% This next section assigns NUMBERS for each state
% -----------------------------------------------------------
pstart = 40;

RealTimeStates.chord=pstart;   % 40

WpkS = pstart + 1;
LrwS = pstart + 2;
RrwS = pstart + 3;
LddS = pstart + 4;
RddS = pstart + 5;
ITI_state = pstart+6;

RealTimeStates.wait_for_apoke=WpkS;     % 41
RealTimeStates.left_reward = LrwS;      % 42
RealTimeStates.right_reward = RrwS;     % 43
RealTimeStates.left_dirdel = LddS;      % 44
RealTimeStates.right_dirdel = RddS;     % 45
RealTimeStates.hit_state = ITI_state;         % 46
RealTimeStates.extra_iti = ITI_state+1; % 47 - where bad responses go
RealTimeStates.dead_time = [1 35];

% Begin stm definition
% -----------------------------------------------------------

%        Cin    Cout    Lin    Lout     Rin     Rout    Tup    Timer    Dout   Aout
stm = [ pstart pstart  pstart pstart   pstart  pstart  pstart   0.01     0       0 ; ... % go to start of program
    ];
stm = [stm ; zeros(pstart-size(stm,1),10)]; % PAD till start state (pstart)
stm(36,:) = [35 35   35 35   35 35    35  100 0 0];
RealTimeStates.state35 = 36;



% -----------------------------------------------------------
%
% Case where we've reached trial limit
%
% -----------------------------------------------------------

if n_done_trials == 1,
   % [ratname experimenter]= SavingSection(obj,'get_info');
   % SessionDefinition(obj, 'set_info', ratname, experimenter);
end;
if n_done_trials >= Max_Trials,

   srate = get_generic('sampling_rate');
   white_noise_len   = 2;
   white_noise_sound = amp*0.2*0.095*randn(1,floor(white_noise_len*srate));
   whln = white_noise_len;
   
   rpbox('loadrp3stereosound2', {[]; 0.001*value(white_noise_sound)});

   RealTimeStates.dead_time = 1:pstart-1;
   RealTimeStates.timeout   = pstart:pstart+2;
   b = rows(stm);
   stm = [stm ; 
           b   b     b   b     b   b   b+1  0.03   0 0 ; ...
          b+1 b+1   b+1 b+1   b+1 b+1   b   whln   0 2];

   stm = [stm ; zeros(512-size(stm,1),10)];
   state_matrix.value = stm;
   rpbox('send_matrix', stm, 1);
   rpbox('send_statenames', RealTimeStates);
   push_history(RealTimeStates);

%   SavingSection(obj, 'savesets', 0);
%   SavingSection(obj, 'savedata');
 SessionDefinition(obj, 'eod_save');
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

min_sound = 0.3; rest_sound = max(sound_len - min_sound, 0.01);

b = pstart;
% Cin    Cout   Lin    Lout    Rin    Rout   Tup    Timer   Dout    Aout
stm = [stm ; ...
    b     b      b      b       b      b     b+1     sound_len  0     1 ; ...    %b: play sound
    ];
if ~strcmpi(value(WaterDelivery), 'direct')
    stm = [stm; ...
        b+1   b+1    lpkA   b+1    rpkA    b+1   ITI_state+1   avail  0     0 ; ...    %b+1: WpkS
        ];
else % go directly to water delivery
    stm = [stm; ...
        lpkA    lpkA    lpkA    lpkA    lpkA    lpkA    lpkA    0.02 0 0       ;...
        ];
end;

stm = [stm; ...
    LrwS  LrwS  LrwS    LrwS   LrwS    LrwS  ITI_state  lwpt    lvid    0     ; ...
    RrwS  RrwS  RrwS    RrwS   RrwS    RrwS  ITI_state  rwpt    rvid    0     ; ...
    LddS  LddS  LddS    LddS   LddS    LddS  ITI_state  lwpt    lvid    0     ; ...
    RddS  RddS  RddS    RddS   RddS    RddS  ITI_state  rwpt    rvid    0 ];

% and finally add the ITI state
iti = ITI_state; iti_wrong = ITI_state + 1;
stm = [stm ; ...
    iti   iti   iti     iti     iti     iti     35 iti_length   0   0; ...  % benign ITI state
    iti+1 iti+1 iti+1   iti+1   iti+1   iti+1   35 iti_length   0   0; ...  % ITI where miss trials end up
    ];

% now pad and send off!
stm = [stm ; zeros(512-size(stm,1),10)];
state_matrix.value = stm;

rpbox('send_matrix', stm, 1);

% Store the latest RealTimeStates
push_history(RealTimeStates);

return;




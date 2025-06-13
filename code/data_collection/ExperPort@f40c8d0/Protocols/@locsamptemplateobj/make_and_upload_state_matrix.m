function RealTimeStates = make_and_upload_state_matrix(obj, action)

GetSoloFunctionArgs;

switch action
 case 'init'
   SoloParamHandle(obj, 'RealTimeStates', 'value', struct(...
     'wait_for_cpoke', 0, ...  % Waiting for initial center poke
     'pre_chord',         0, ...  % Silent period preceeding GO signal
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

sound_len = value(chord_sound_len);

lwpt = value(LeftWValve);
rwpt = value(RightWValve);

avail = value(RewardAvail);

itilist = value(iti_list);                         %%% Irrelevant now %%%
iti_length = itilist(value(n_done_trials+1));      %%% Irrelevant now %%%
%if ~strcmpi(value(WaterDelivery),'direct')
%    iti_length = max(iti_length - avail, 0.01);
%else
%    avail = 0.01;                       %%% Why again?
%end;

side = side_list(n_done_trials+1);
left = get_generic('side_list_left');


%%%%%%%%% My version of the State Matrix %%%%%%%%%%%

pstart = 40;

WcS  = pstart + 0;
pgS  = pstart + 1;
sndS = pstart + 2;
WpkS = pstart + 3;
LrwS = pstart + 4;
RrwS = pstart + 5;
LddS = pstart + 6;
RddS = pstart + 7;
ITIst = pstart+ 8;
ExtraITIst = pstart+ 9;


RealTimeStates.wait_for_cpoke=WcS;      % 40
RealTimeStates.pre_chord = pgS;         % 41
RealTimeStates.chord=sndS;              % 42
RealTimeStates.wait_for_apoke=WpkS;     % 43
RealTimeStates.left_reward = LrwS;      % 44
RealTimeStates.right_reward = RrwS;     % 45
RealTimeStates.left_dirdel = LddS;      % 46
RealTimeStates.right_dirdel = RddS;     % 47
RealTimeStates.hit_state = ITIst;       % 48
RealTimeStates.extra_iti = ExtraITIst;  % 49
RealTimeStates.dead_time = [1 35];
RealTimeStates.state35 = 36;          %  FSM indexes from 0, matlab from 1


% --- Initialize state matrix (RT indexes start at 0) ---
stm = zeros(128,10);                    % HARDCODED? (sjara)

% --  First row of state matrix, go to start state --
%             Cin    Cout    Lin   Lout    Rin   Rout   Tup   Timer    Dout   Aout
stm(1,:) = [ pstart pstart pstart pstart pstart pstart pstart  0.01     0       0 ];

% -- State 35 (counting from 0) --
stm(35+1,:) = [35 35   35 35   35 35    35  100 0 0];


% -- Test for end of trials --
if n_done_trials >= Max_Trials,
  %%%%% TO BE DONE %%%%%%
  %%%%% Check Classical2AFC %%%%
end


switch WaterDelivery,
    % -- lpkA and rpkA are acts (states to go to) on L and R pokes, respectively --
    case 'only if nxt pke corr',
        if     side==left, lpkA = LrwS;   rpkA = 35;
        elseif side==1-left, lpkA = 35; rpkA = RrwS;
        end;
    case 'next corr poke',
        if     side==left, lpkA = LrwS; rpkA = WpkS;
        elseif side==1-left, lpkA = WpkS; rpkA = RrwS;
        end;
    case 'direct',
        % -- Post-tone act is either the Left or Right direct water delivery --
        if     side==left, lpkA = LddS; rpkA = LddS;
        elseif side==1-left, rpkA = RddS; lpkA = RddS;
        end;

    otherwise,
        error(['Don''t know how to do this WaterDelivery: ' WaterDelivery]);
end;


% THERE MUST BE A WAY BETTER THAN GLOBAL VARIABLES!!! (I don't like Solo) --Santiago
% At least one structure that contains all those globals.
global left1water;  
global right1water; 

% -- Define Valve IDs ??? --
if deliver_water==1,
   lvid = left1water; rvid = right1water;
else
   lvid = 0;          rvid = 0;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In RT rigs, stop sound 1; upstairs, play 10 ms v soft sound to halt
% main sound:
%global fake_rp_box; 
%if fake_rp_box == 2, quiet = -1; else quiet = 2; end;
%min_sound = 0.3; rest_sound = max(sound_len - min_sound, 0.01);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


     % Cin    Cout    Lin   Lout   Rin   Rout    Tup    Timer   Dout    Aout
stm(WcS+1,:) = [...
        pgS   WcS    WcS    WcS   WcS    WcS    WcS     100      0      0  ; ...   % Wait for center poke
             ];

%PreChordTime = value(
     % Cin    Cout    Lin   Lout   Rin   Rout    Tup    Timer   Dout    Aout
%stm(pgS+1,:) = [...
%        35     35     35    35      35    35     sndS  value(PreChordTime)      0      0  ; ...   % Mandatory time in Cpoke
%             ];
stm(pgS+1,:) = [...
        WcS     WcS     WcS    WcS      WcS    WcS     sndS  value(PreChordTime)      0      0  ; ...   % Mandatory time in Cpoke
             ];

      %  Cin   Cout   Lin    Lout    Rin   Rout   Tup    Timer   Dout    Aout
stm(sndS+1,:) = [...
        sndS   sndS   sndS   sndS   sndS   sndS   WpkS   sound_len  0     1 ; ...   % Play sound
      ];

% -- If it is not direct delivery, wait for poke --
if ~strcmpi(value(WaterDelivery), 'direct')  % -- If it is not direct delivery, wait for poke --
    stm(WpkS+1,:) = [...
        %WpkS   WpkS    lpkA    WpkS   rpkA   WpkS   ExtraITIst  avail  0     0 ; ...    % Wait for poke
        WpkS   WpkS    lpkA    WpkS   rpkA   WpkS   35  avail  0     0 ; ...    % Wait for poke
        ];
else % -- Go directly to water delivery --
    stm(WpkS+1,:) = [...
        lpkA   lpkA    lpkA    lpkA   lpkA   lpkA     lpkA    0.02     0     0 ;...    % or direct
        ];
end

% --- Reward states ---
stm([LrwS,RrwS,LddS,RddS]+1,:) = [...
    LrwS  LrwS  LrwS    LrwS   LrwS    LrwS  35  lwpt    lvid    0     ; ... % Lreward
    RrwS  RrwS  RrwS    RrwS   RrwS    RrwS  35  rwpt    rvid    0     ; ... % Rreward
    LddS  LddS  LddS    LddS   LddS    LddS  35  lwpt    lvid    0     ; ... % Ldirect
    RddS  RddS  RddS    RddS   RddS    RddS  35  rwpt    rvid    0 ];        % Rdirect


% --- ITI state ---
stm([ITIst,ExtraITIst]+1,:) = [...
      ITIst      ITIst      ITIst      ITIst      ITIst     ITIst     35 iti_length   0   0; ...  % Benign ITI state
    ExtraITIst ExtraITIst ExtraITIst ExtraITIst ExtraITIst ExtraITIst 35 iti_length   0   0; ...  % ITI after miss trials
    ];



% --- Send state matrix ---
state_matrix.value = stm;

% --- Using the RPBox call takes too long --
%rpbox('send_matrix', stm, 1);
% --- Send the state matrix directly to state machine instead ---
FSMengine = rpbox('getstatemachine');
FSMengine = SetStateMatrix(FSMengine, stm);

% --- Store the latest RealTimeStates ---
push_history(RealTimeStates);

return;
















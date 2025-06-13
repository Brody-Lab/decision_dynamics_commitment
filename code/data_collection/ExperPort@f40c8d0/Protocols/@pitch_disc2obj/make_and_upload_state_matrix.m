function make_and_upload_state_matrix(obj, action)


DeadTimeReinitPenalty = 6;  % not set by user

GetSoloFunctionArgs;

% Read-write:'RealTimeStates', 'super'
%
% Read-only:
%   'n_done_trials'
%   'side_list', 'vpd_list'
%   'chord_sound_len', 'go_dur',
%   'WaterDelivery', 'RewardPorts', 'DrinkTime', 'LeftWValve', 'RightWValve'
%   'ITISound', 'ITILength', 'ITIReinitPenalty', 'ExtraITIonError'
%   'TimeOutSound', 'TimeOutLength', 'TimeOutReinitPenalty', 'BadBoySound', 'BadBoySPL'

% RealTimeStates:
%   'wait_for_cpoke', 0, ...  % Waiting for initial center poke
%   'pre_chord',      % Silent period preceeding GO signal
%   'chord',          % GO signal
%   'wait_for_apoke', % Waiting for an answer poke (after GO signal)
%   'left_dirdel',    % Direct delivery on LHS
%   'right_dirdel',   % Direct delivery on RHS
%   'left_reward',    % Reward obtained on LHS
%   'right_reward',   % Reward obtained on RHS
%   'drink_time',     % Silent time to permit drinking
%   'timeout',        % Penalty state
%   'iti',            % Intertrial interval
%   'dead_time',      % 'Filler' state needed because of Matlab lag in sending next state machine
%   'state35',        % End-of-trial state (the state number is an ancient convention)
%   'extra_iti',      % State of penalty within ITI (occurs if rat pokes during ITI - usually longer than ITI)

switch action,
    case 'next_matrix',  % serves only to skip the 'init' section
    case 'init'
        % FIRST: Set up sounds ---------------------------------
        amp = get_generic(value(super), 'amp');
        srate = get_generic(value(super), 'sampling_rate');

        % 1. White noise
        white_noise_factor = value(WN_SPL);
        white_noise_len = get_generic(value(super), 'white_noise_len');
        SoloParamHandle(obj, 'white_noise_sound', 'value', ...
            white_noise_factor*amp*rand(1,floor(white_noise_len*srate)));

        % 2. Badboy Sound
        [bb_sound, bb_len] = Make_badboy_sound('generic', 0, 0, 'volume', BadBoySPL);
        SoloParamhandle('badboy_sound', 'value', bb_sound);
        SoloParamHandle(obj, 'badboy_len', 'value', bb_len);

        % 3. Harsher version of badboy sound:
        h_bb_unit = MakeChord( srate, 70-67, 20*1000, 4, 850, 0.005*1000 );
        SoloParamHandle(obj, 'harsher_badboy_sound');
        partial_bb = [amp*rand(1, floor(0.8*srate)) zeros(1, floor(0.050*srate))];
        harsher_badboy_sound.value = [ h_bb_unit+partial_bb h_bb_unit+partial_bb ];
        SoloParamHandle(obj, 'harsher_badboy_len', 'value', ...
            length(value(harsher_badboy_sound))/floor(srate));

        % Now load the sounds
        rpbox('loadrp3stereosound2', {[]; value(white_noise_sound)});
        if strcmp(BadBoySound, 'harsher')
            rpbox('loadrp3stereosound3', {[]; []; value(harsher_badboy_sound)});
        else
            rpbox('loadrp3stereosound3', {[]; []; value(badboy_sound)});
        end;

    case 'update_bb_sound',
        [bb_sound, bb_len] = Make_badboy_sound('generic', 0,0, 'volume', BadBoySPL);
        badboy_sound.value = bb_sound;
        badboy_len.value = bb_len;
        rpbox('loadrp3stereosound2', {[]; value(white_noise_sound)});
    case 'update_wn_sound',
        amp = get_generic(value(super), 'amp');
        srate = get_generic(value(super), 'sampling_rate');
        white_noise_factor = value(WN_SPL);
        white_noise_len = get_generic(value(super), 'white_noise_len');
        white_noise_sound.value = white_noise_factor*amp*rand(1,floor(white_noise_len*srate));
        rpbox('loadrp3stereosound2', {[]; value(white_noise_sound)});

    otherwise,
        error(['Don''t know how to handle action ' action]);
end;

% -------------------------------------------------- End of switch-case statement

if strcmp(BadBoySound, 'harsher')
    rpbox('loadrp3stereosound3', {[]; []; value(harsher_badboy_sound)});
else
    rpbox('loadrp3stereosound3', {[]; []; value(badboy_sound)});
end;

stne  = 1; % sample tone - here, the prolonged tone + silence before GO + and GO signal
whsd  = 2; % white noise sound
bbsd  = 4; % bad boy sound

wnln = get_generic(value(super), 'white_noise_len');
if strcmp(BadBoySound, 'harsher')
    bbln     = value(harsher_badboy_len);
else
    bbln     = value(badboy_len);
end;

% Assign shorter names for states to use in matrix
iti      = ITILength;
tout     = TimeOutLength;
lwpt     = LeftWValve;
rwpt     = RightWValve;
drkt     = DrinkTime;
ntrials  = n_done_trials;

if ~is_multiple(ITILength, wnln) | ~is_multiple(ExtraITIonError, wnln) | ~is_multiple(ITIReinitPenalty, wnln) | ...
        ~is_multiple(TimeOutLength, wnln) | ~is_multiple(TimeOutReinitPenalty, wnln)
    error(sprintf('ITI, ExtraITI, Timeout, Reinit penalties must be multiples of %g',wnln));
end;
if ~is_multiple(DeadTimeReinitPenalty, wnln)
    error(sprintf(['DeadTimeReinit penalties must be multiples of %g\n ' ...
        'Correct this within @%s/%s'], wnln, class(obj), mfilename));
end;

ExtraITIReinitPenalty = ITIReinitPenalty;

side = side_list(n_done_trials+1);
vpd  = vpd_list(n_done_trials+1);

% Calculations for time before GO signal
tdur = chord_sound_len;                         % Actual length of tones (here, prolonged tone + silence + GO)
vlst = ChordSection(obj, 'get_ValidSoundTime'); % Time after GO onset that Cout may occur sans penalty
snd_stay_time = (chord_sound_len - go_dur) + vlst; % Time during main sound during which a Cout is penalised
snd_leave_time = chord_sound_len - snd_stay_time; % After vlst seconds of GO signal, Cout will not be penalised
if snd_leave_time < 0.02
    snd_leave_time = 0.02;
end; % Silence when triggered sound is being played

% prst = vpd - vlst;                              % Time before sample tone
if vpd < 0.02,
    vpd = 0.02;
end; % Hack for when tdur changes in the middle of a trial

% This next section assigns NUMBERS for each state
% -----------------------------------------------------------

% Major hard-coded states in the state machine
pstart      = 40;   % start of main program
rewardstart = 47;   % start of reward states program
itistart    = 100;  % start of iti and timeout parts of program

% Reward states
WpkS = pstart+5;  % state in which we're waiting for a R or L poke
RealTimeStates.wait_for_cpoke = pstart;
RealTimeStates.wait_for_apoke = WpkS;

LrwS = rewardstart+0;  % state that gives water on left  port
RrwS = rewardstart+2;  % state that gives water on right port
LddS = rewardstart+4;  % state for left  direct water delivery
RddS = rewardstart+6;  % state for right direct water delivery
RealTimeStates.left_reward    = LrwS;
RealTimeStates.right_reward   = RrwS;
RealTimeStates.drink_time     = [LrwS+1 RrwS+1];
RealTimeStates.left_dirdel    = LddS;
RealTimeStates.right_dirdel   = RddS;

bbfg = ~strcmp(BadBoySound, 'off');

% Penalty and ITI states
%
% Note: The lengths used for state i's offset
% actually correspond to the number of substates in state (i-1).
ITI_state = 55;
ITIReinit_state      = ITI_state            + max(2*ITILength/wnln, 1); % no bb in ITI
ExtraITI_state       = ITIReinit_state      + max(2*ITIReinitPenalty/wnln + 2*bbfg, 1);
ExtraITIReinit_state = ExtraITI_state       + max(2*ExtraITIonError/wnln  + 2*bbfg, 1);
TimeOut_state        = ExtraITIReinit_state + max(2*ITIReinitPenalty/wnln + 2*bbfg, 1);
TimeOutReinit_state  = TimeOut_state        + max(2*TimeOutLength/wnln    + 2*bbfg, 1);
TimeOutReinit_endstate = TimeOutReinit_state + max(2*TimeOutReinitPenalty/wnln + 2*bbfg, 1);

if TimeOutReinit_endstate > 128,    % check for overflow
    fprintf(2, ['The reinits and timeouts and ITIs are too long! Reducing\n' ...
        'them and trying them again. This will *not* be reflected\n' ...
        'in the GUI.\n']);
    [trash, u] = max([TimeOutReinitPenalty ITIReinitPenalty ITILength ...
        TimeoutLength]);
    switch u(1),
        case 1, TimeOutReinitPenalty = TimeOutReinitPenalty - wnln;
        case 2, ITIReinitPenalty     = ITIReinitPenalty - wnln;
        case 3, ITILength            = ITILength - wnln;
        case 4, TimeOutLength        = TimeOutLength - wnln;
    end;

    make_and_upload_state_matrix(obj, 'next_matrix');
end;

% --- End of state number assignments

ItiS = ITI_state;
TouS = TimeOut_state;
if tout < 0.001, TouS = pstart; end;  % timeouts of zero mean just skip that state

%        Cin    Cout    Lin    Lout     Rin     Rout    Tup    Timer    Dout   Aout
stm = [ pstart pstart  pstart pstart   pstart  pstart  pstart   0.01     0       0 ; ... % go to start of program
    ];

% Set up no-dead-time technology -------------------------########
DeadTimeReinit_state = 3;
% what to do when starting deadtime
stm = noise_section(stm, 1, DeadTimeReinit_state, 35, 'off', wnln, ...
    bbln, bbsd, wnln, whsd);
% what to do when reinitializing deadtime ( on poke )
[stm, DeadTime_endstate] = ...
    noise_section(stm, DeadTimeReinit_state, DeadTimeReinit_state, 35, ...
    BadBoySound, DeadTimeReinitPenalty, bbln, bbsd, wnln, whsd);
RealTimeStates.dead_time = [1:DeadTime_endstate 35];

stm = [stm ; zeros(pstart-size(stm,1),10)]; % PAD till start state (pstart)

% State 35 for no-dead-time technology -------------------########
stm(36,:) = [35 35   35 35   35 35    1  0.01 0 0];
RealTimeStates.state35 = 36;

% ptnA - post-tone action
% lpkA - left-poke action

% Post GO signal responses to pokes
% Defines state transitions depending on schedule
switch WaterDelivery,
    case 'only if nxt pke corr',
        punish = ExtraITI_state;
        ptnA = WpkS; % post-tone act here is to go to waiting for a R or L poke
        if     side==1, lpkA = LrwS;   rpkA = punish;  % lpkA and rpkA are acts (states to go to) on L and R pokes, respectively
        elseif side==0, lpkA = punish; rpkA = RrwS;
        end;

    case 'next corr poke',
        ptnA = WpkS; % post-tone act here is to go to waiting for a R or L poke
        if     side==1, lpkA = LrwS; rpkA = WpkS;
        elseif side==0, lpkA = WpkS; rpkA = RrwS;
        end;

    case 'direct',
        if     side==1, ptnA = LddS; % post-tone act is either the Left or Right direct water delivery
        elseif side==0, ptnA = RddS;
        end;
        lpkA = LrwS; rpkA = RrwS; % doesn't really matter, we won't reach them

    otherwise,
        error(['Don''t know how to do this WaterDelivery: ' WaterDelivery]);
end;

if strcmp(RewardPorts, 'both ports'),  % Override punishments, reward on both sides
    ptnA = WpkS;
    lpkA = LrwS;
    rpkA = RrwS;
end;

global fake_rp_box;

% WpkS_Cin_action = WpkS;
% if strcmp(APokePenalty, 'on')
%     WpkS_Cin_action = TouS;
% end;

% Behaviour from Cin (start of trial) to GO sound --------- ###############
%
b  = pstart;        % base state for main program
RealTimeStates.pre_chord = pstart + 2;
RealTimeStates.chord     = pstart + (3:4);

% if isempty(fake_rp_box) | fake_rp_box ~= 1,
%      Cin    Cout    Lin    Lout    Rin    Rout   Tup    Timer   Dout    Aout
stm = [stm ; ...
    1+b     b      b      b       b      b       b      100      0       0 ; ...   %0 : b     Pre-state: wait for C poke
    1+b     b      b      b       b      b      2+b     0.01     0       0 ; ...   %1 : 1+b   if pk<10 ms, doesn't count
    TouS   TouS   TouS   TouS    TouS   TouS    3+b     vpd      0       0 ; ...   %2 : 2+b   prechord (here, silence before cue+silence+GO)
    TouS   TouS   TouS   TouS    TouS   TouS    4+b snd_stay_time  0    stne ; ... %3 : 3+b   cue+silence+GO
    WpkS   WpkS   WpkS   WpkS    WpkS   WpkS   ptnA snd_leave_time 0     0 ; ...   %4 : 4+b   Part of GO signal with penalty-less Cout
    WpkS   WpkS   lpkA   WpkS    rpkA   WpkS    WpkS    100      0       0 ; ...   %5 : 5+b   wait for r/l poke act
    ];
% else
%     WtoS = pstart+6; % wait for sound over before going to the timeout state
%     %    lost = tdur - vlst; if lost < 0.02, lost = 0.02; end;
%     %      Cin    Cout    Lin    Lout    Rin    Rout   Tup    Timer   Dout    Aout
%     stm = [stm ; ...
%         1+b     b      b      b       b      b       b      100      0       0 ; ... %0 : (b) Pre-state: wait for C poke
%         1+b     b      b      b       b      b      2+b     0.01     0       0 ; ... %1 : (1+b) if pk<10 ms, doesn't count
%         TouS   TouS   TouS   TouS    TouS   TouS    3+b     prst     0       0 ; ... %2 : (2+b) pre sound time
%         3+b    3+b    3+b    3+b     3+b    3+b     4+b     vlst     0    stne ; ... %3 : (3+b) trigger sample sound
%         TouS   TouS   TouS   TouS    TouS   TouS    ptnA    lost     0       0 ; ... %4 : (4+b) After snd trig, before sound end: To be filled with whatever ptnA holds
%         WpkS_Cin_action   WpkS   lpkA   WpkS    rpkA   WpkS    WpkS    100      0       0 ; ... %5 : WpkS: wait for r/l poke act
%         WtoS   WtoS   WtoS   WtoS    WtoS   WtoS    TouS    tdur     0       0 ; ... %6 : wait for sound over bf timeout
%         ];
% end;

stm = [stm ; zeros(rewardstart-size(stm,1),10)];       % PAD till next hard-coded point (rewardstart)

% Note: Although states for all trial types and schedules are defined, lpkA
% and rpkA (above) control which of these states left and right pokes
% transition to.
%      Cin    Cout    Lin    Lout    Rin    Rout   Tup    Timer   Dout    Aout
stm = [stm ; ...
    LrwS   LrwS   LrwS   LrwS    LrwS   LrwS   1+LrwS   lwpt     1       0 ; ... %0 : Left reward: give water
    1+LrwS 1+LrwS 1+LrwS 1+LrwS  1+LrwS 1+LrwS   ItiS    drkt     0       0 ; ... %1 : free time to enjoy water
    RrwS   RrwS   RrwS   RrwS    RrwS   RrwS   1+RrwS   rwpt     2       0 ; ... %2 : Right reward: give water
    1+RrwS 1+RrwS 1+RrwS 1+RrwS  1+RrwS 1+RrwS   ItiS    drkt     0       0 ; ... %3 : free time to enjoy water
    LddS   LddS   LddS   LddS    LddS   LddS   1+LddS   lwpt     1       0 ; ... %4 : Left direct w delivery
    1+LddS 1+LddS  ItiS  1+LddS  1+LddS 1+LddS  1+LddS   100      0       0 ; ... %5 : Wait for L water collection
    RddS   RddS   RddS   RddS    RddS   RddS   1+RddS   rwpt     2       0 ; ... %6 : Left direct w delivery
    1+RddS 1+RddS 1+RddS 1+RddS    35   1+RddS  1+RddS   100      0       0 ; ... %7 : Wait for R water collection
    ];

% Set after sound trig, before sound end state to hold contingencies
% that the post tone Act (ptnA) state holds:
stm(4+b+1, 1:6) = stm(ptnA+1,1:6);

% Behaviour during ITI states ----------------------------- ###############
% (regular, reinit-ed and penalty)
bbfg = ~strcmp(BadBoySound, 'off');

[stm, ITI_endstate] = ...
    noise_section(stm, ITI_state, ITIReinit_state, 35, ...
    'off', ITILength, bbln, bbsd, wnln, whsd);
[stm, ITIReinit_endstate] = ...
    noise_section(stm, ITIReinit_state, ITIReinit_state, ITI_state, ...
    BadBoySound, ITIReinitPenalty, bbln, bbsd, wnln, whsd);
[stm, ExtraITI_endstate] = ...
    noise_section(stm, ExtraITI_state, ExtraITIReinit_state, ITI_state, ...
    BadBoySound, ExtraITIonError, bbln, bbsd, wnln, whsd);

if ExtraITIonError == 0, donestate = ITI_state;
else                     donestate = ExtraITI_state+2*bbfg;
end;
[stm, ExtraITIReinit_endstate] = ...
    noise_section(stm, ExtraITIReinit_state, ExtraITIReinit_state, ...
    donestate, BadBoySound, ExtraITIReinitPenalty, ...
    bbln, bbsd, wnln, whsd);

RealTimeStates.iti       = ...
    [ITI_state     :ITI_endstate           ITIReinit_state:ITIReinit_endstate];
RealTimeStates.extra_iti = ...
    [ExtraITI_state:ExtraITI_endstate ExtraITIReinit_state:ExtraITIReinit_endstate];

% Behaviour during TimeOut states ----------------------------- ############
[stm, TimeOut_endstate] = ...
    noise_section(stm, TimeOut_state, TimeOutReinit_state, pstart, ...
    BadBoySound, TimeOutLength, bbln, bbsd, wnln, whsd);

if TimeOutLength == 0, donestate = pstart;
else                   donestate = TimeOut_state+2*bbfg;
end;
[stm, TimeOutReinit_endstate] = ...
    noise_section(stm, TimeOutReinit_state, TimeOutReinit_state, ...
    donestate, BadBoySound, TimeOutReinitPenalty, ...
    bbln, bbsd, wnln, whsd);

RealTimeStates.timeout   = ...
    [TimeOut_state :TimeOut_endstate   TimeOutReinit_state:TimeOutReinit_endstate];

% PAD with zeros up to a 128 size (fixed size of stm matrix):
stm = [stm ; zeros(128-size(stm,1),10)];

% store for posterity
if ~exist('state_matrix', 'var'),
    SoloParamHandle(obj, 'state_matrix');
end;
state_matrix.value = stm;

rpbox('send_matrix', stm, 1);

% Store the latest RealTimeStates
push_history(RealTimeStates);

return;

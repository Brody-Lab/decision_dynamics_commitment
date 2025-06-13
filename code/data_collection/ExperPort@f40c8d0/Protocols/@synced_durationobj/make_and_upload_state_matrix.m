function make_and_upload_state_matrix(obj, action)


DeadTimeReinitPenalty = 6;  % not set by user

GetSoloFunctionArgs;

% Read-write:'RealTimeStates', 'super'
%
% Read-only:
%   'n_done_trials'
%   'side_list', 'vpd_list'
%   'chord_sound_len', 'error_sound_len', 'go_dur',
%   'WaterDelivery', 'RewardPorts', 'DrinkTime', 'LeftWValve', 'RightWValve'
%   'ITISound', 'ITILength', 'ITIReinitPenalty', 'ExtraITIonError'
%   'TimeOutSound', 'TimeOutLength', 'TimeOutReinitPenalty', 'BadBoySound', 'BadBoySPL'

% RealTimeStates:
%   'wait_for_cpoke', 0, ...  % Waiting for initial center pokef
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

% stm_ctr.value = value(stm_ctr) + 1;
% sprintf('Called: %s', num2str(value(stm_ctr)))

global fake_rp_box;

switch action,
    case 'next_matrix',  % serves only to skip the 'init' section
    case 'init'
        % FIRST: Set up sounds ---------------------------------
        amp = get_generic('amp');
        srate = get_generic('sampling_rate');

        % 1. White noise
        white_noise_factor = value(WN_SPL);
        white_noise_len = get_generic('white_noise_len');
        SoloParamHandle(obj, 'white_noise_sound', 'value', ...
            volume_factor*white_noise_factor*amp*rand(1,floor(white_noise_len*srate)));

        % 2. Badboy Sound
        [bb_sound, bb_len] = Make_badboy_sound('generic', 0, 0, 'volume', BadBoySPL,'volume_factor',volume_factor);
        SoloParamHandle(obj, 'badboy_sound', 'value', bb_sound);
        SoloParamHandle(obj, 'badboy_len', 'value', bb_len);

        % 3. Harsher version of badboy sound:
        h_bb_unit = MakeChord2( srate, 70-67, 20*1000, 4, 850, ...
            'RiseFall',0.005*1000,'volume_factor',volume_factor );
        SoloParamHandle(obj, 'harsher_badboy_sound');
        partial_bb = [volume_factor*amp*rand(1, floor(0.8*srate)) zeros(1, floor(0.050*srate))];
        harsher_badboy_sound.value = [ h_bb_unit+partial_bb h_bb_unit+partial_bb ];
        SoloParamHandle(obj, 'harsher_badboy_len', 'value', ...
            length(value(harsher_badboy_sound))/floor(srate));

        % Now load the sounds
        if fake_rp_box == 2
            LoadSound(rpbox('getsoundmachine'),2, value(white_noise_sound),'both',3,0);
        else
            rpbox('loadrp3stereosound2', {[]; value(white_noise_sound)});
        end;

        if strcmp(BadBoySound, 'harsher')
            if fake_rp_box == 2
                LoadSound(rpbox('getsoundmachine'),3, value(harsher_badboy_sound),'both',3,0);
            else
                rpbox('loadrp3stereosound3', {[]; []; value(harsher_badboy_sound)});
            end;
        else
            if fake_rp_box == 2
                LoadSound(rpbox('getsoundmachine'),3, value(badboy_sound),'both',3,0);
            else
                rpbox('loadrp3stereosound3', {[]; []; value(badboy_sound)});
            end;
        end;

    case 'update_bb_sound',
        [bb_sound, bb_len] = Make_badboy_sound('generic', 0,0, 'volume', BadBoySPL,'volume_factor',volume_factor);
        badboy_sound.value = bb_sound;
        badboy_len.value = bb_len;
        if fake_rp_box == 2
            LoadSound(rpbox('getsoundmachine'),2, value(white_noise_sound),'both',3,0);
        else
            rpbox('loadrp3stereosound2', {[]; value(white_noise_sound)});
        end;

        return;

    case 'update_wn_sound',
        amp = get_generic('amp');
        srate = get_generic('sampling_rate');
        white_noise_factor = value(WN_SPL);
        white_noise_len = get_generic('white_noise_len');
        white_noise_sound.value = white_noise_factor*amp*rand(1,floor(white_noise_len*srate))*volume_factor;
        if fake_rp_box == 2
            LoadSound(rpbox('getsoundmachine'),2, value(white_noise_sound),'both',3,0);
        else
            rpbox('loadrp3stereosound2', {[]; value(white_noise_sound)});
        end;
        return;

    otherwise,
        error(['Don''t know how to handle action ' action]);
end;

% -------------------------------------------------- End of switch-case statement

if strcmp(BadBoySound, 'harsher')
    if fake_rp_box == 2
        LoadSound(rpbox('getsoundmachine'),3, value(harsher_badboy_sound),'both',3,0);
    else
        rpbox('loadrp3stereosound3', {[]; []; value(harsher_badboy_sound)});
    end;
else
    if fake_rp_box == 2
        LoadSound(rpbox('getsoundmachine'),3, value(badboy_sound),'both',3,0);
    else
        rpbox('loadrp3stereosound3', {[]; []; value(badboy_sound)});
    end;
end;

stne  = 1; % sample tone - here, the prolonged tone + silence before GO + and GO signal
whsd  = 2; % white noise sound
if fake_rp_box == 2
    bbsd  = 3; % bad boy sound
    errsd = 4; % error sound
else
    bbsd  = 4; % bad boy sound
    errsd = bbsd;
end;

wnln = get_generic('white_noise_len');
if strcmp(BadBoySound, 'harsher')
    bbln     = value(harsher_badboy_len);
else
    bbln     = value(badboy_len);
end;

if fake_rp_box ~= 2
    error_sound_len = value(badboy_len);
end;

% Assign shorter names for states to use in matrix
iti     = value(ITILength);
tout    = value(TimeOutLength);
lwpt    = value(LeftWValve);
rwpt    = value(RightWValve);
drkt    = value(DrinkTime);
ntrials = n_done_trials;

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
dummy = protocolobj('empty');
left = get_generic('side_list_left');


% Calculations for time before GO signal
%tdur = chord_sound_len;                         % Actual length of tones (here, prolonged tone + silence + GO)
vlst = ChordSection(obj, 'get_ValidSoundTime'); % Time after GO onset that Cout may occur sans penalty
% Assemble all the times
prst  = vpd_list(n_done_trials+1);               % pre-sound
% relevant cue
if side == left, cue = tone1_list(n_done_trials+1); else cue = tone2_list(n_done_trials+1); end;
pre_chord = prechord_list(n_done_trials+1);
go_stay = vlst;
go_leave = go_dur - vlst;
%snd_stay_time =  go_dur) + vlst; % Time during main sound during which a Cout is penalised
%snd_leave_time = chord_sound_len - snd_stay_time; % After vlst seconds of GO signal, Cout will not be penalised
if go_stay < 0.02, go_stay = 0.02; end;
if go_leave < 0.02, go_leave = 0.02; end;
if prst < 0.02, prst = 0.02; end; % Hack for when tdur changes in the middle of a trial

% This next section assigns NUMBERS for each state
% -----------------------------------------------------------
% Major hard-coded states in the state machine
sync_rows = 16;

sync_start_state = 40; % The 16 rows of sync signal start at state 40.
% The last of the sync_start_state transitions to the 'pstart' state ...
% where we wait for the rat to poke its nose in.
pstart      = sync_start_state + sync_rows;   % start of main program
%rewardstart = 47;   % start of reward states program
RealTimeStates.sending_trialnum=(sync_start_state:sync_start_state + sync_rows-1);
% Get all the granular sections done here
temp1 = granular_section(0, 0, prst, Granularity/1000, LegalSkipOut/1000);
temp2 = granular_section(0, 0, cue, Granularity/1000, LegalSkipOut/1000);
temp3 = granular_section(0, 0, pre_chord, Granularity/1000, LegalSkipOut/1000);
temp4 = granular_section(0, 0, vlst, Granularity/1000, LegalSkipOut/1000);

rewardstart = pstart + 2 + ...
    rows(temp1) + rows(temp2) + rows(temp3) + rows(temp4) ...
    + 2;
%itistart    = 100;  % start of iti and timeout parts of program
itistart = rewardstart + sync_start_state;

% Reward states
%WpkS = pstart+5;  % state in which we're waiting for a R or L poke
WpkS = rewardstart - 1;
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
%ITI_state = 55;
% if fake_rp_box == -12
%     ITI_state = RddS + 7;
% else
ITI_state = RddS + 4;
ITIReinit_state      = ITI_state            + max(2*ITILength/wnln, 1); % no bb in ITI
ExtraITI_state       = ITIReinit_state      + max(2*ITIReinitPenalty/wnln + 2*bbfg, 1);
ExtraITIReinit_state = ExtraITI_state       + max(2*ExtraITIonError/wnln  + 2*bbfg, 1);
TimeOut_state        = ExtraITIReinit_state + max(2*ITIReinitPenalty/wnln + 2*bbfg, 1);
TimeOutReinit_state  = TimeOut_state + max(2*TimeOutLength/wnln    + 2*bbfg, 1);
if fake_rp_box == 2,
    TimeOutReinit_state = TimeOutReinit_state + 1;
end;
TimeOutReinit_endstate = TimeOutReinit_state + max(2*TimeOutReinitPenalty/wnln + 2*bbfg, 1);

if TimeOutReinit_endstate > 512,    % check for overflow
    fprintf(2, ['The reinits and timeouts and ITIs are too long! Reducing\n' ...
        'them and trying them again. This will *not* be reflected\n' ...
        'in the GUI.\n']);
    [trash, u] = max([TimeOutReinitPenalty ITIReinitPenalty ITILength ...
        TimeOutLength]);
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

syncss = sync_start_state;
stm = [ syncss syncss  syncss syncss   syncss  syncss  syncss   0.01     0       0 ; ... % go to start of program
    ];

% Set up no-dead-time technology -------------------------########
DeadTimeReinit_state = 3;
% what to do when starting deadtime
stm = noise_section(stm, 1, DeadTimeReinit_state, 35, 'off', wnln, ...
    error_sound_len, errsd, wnln, whsd);
% what to do when reinitializing deadtime ( on poke )
[stm, DeadTime_endstate] = ...
    noise_section(stm, DeadTimeReinit_state, DeadTimeReinit_state, 35, ...
    BadBoySound, DeadTimeReinitPenalty, error_sound_len, errsd, wnln, whsd);
RealTimeStates.dead_time = [1:DeadTime_endstate 35];

stm = [stm ; zeros(sync_start_state-size(stm,1),10)]; % PAD till start state (pstart)

% State 35 for no-dead-time technology -------------------########
stm(36,:) = [35 35   35 35   35 35    1  0.01 0 0];
RealTimeStates.state35 = 36;



% -----------------------------------------------------------
%
% Case where we've reached trial limit
%
% -----------------------------------------------------------


if n_done_trials == 1
    protocol_start_time.value = clock;
end;

if n_done_trials >= Max_Trials || etime(clock, value(protocol_start_time))/60 > MaxMins,

   srate = get_generic('sampling_rate');
   white_noise_len   = 2;
   white_noise_sound = 0.1*0.095*randn(1,floor(white_noise_len*srate));
   whln = white_noise_len;
   
   rpbox('loadrp3stereosound2', {[]; 0.3*value(white_noise_sound)});

   RealTimeStates.dead_time = 1:pstart-1;
   RealTimeStates.timeout   = pstart:pstart+2;
   b = rows(stm);
   stm = [stm ; 
           b   b     b   b     b   b   b+1  0.03   0 0 ; ...
          b+1 b+1   b+1 b+1   b+1 b+1   b   whln   0 2];

   stm = [stm ; zeros(512-size(stm,1),10)];
   state_matrix.value = stm;
   rpbox('send_matrix', stm, 1, 1);   % <~> added another arg (value 1) to the call to employ Carlos's fix for long deadtimes (See comment at beginning of .../Modules/RPbox.m.).
   rpbox('send_statenames', RealTimeStates);
   push_history(RealTimeStates);

   %SavingSection(value(super), 'savesets', 0);
   SessionDefinition(obj, 'eod_save');
   return;
end;



% ptnA - post-tone action
% lpkA - left-poke action

% Post GO signal responses to pokes
% Defines state transitions depending on schedule
switch WaterDelivery,
    case 'only if nxt pke corr',
        punish = ExtraITI_state;
        ptnA = WpkS; % post-tone act here is to go to waiting for a R or L poke
        if     side==left, lpkA = LrwS;   rpkA = punish;  % lpkA and rpkA are acts (states to go to) on L and R pokes, respectively
        elseif side==1-left, lpkA = punish; rpkA = RrwS;
        end;

    case 'next corr poke',
        ptnA = WpkS; % post-tone act here is to go to waiting for a R or L poke
        if     side==left, lpkA = LrwS; rpkA = WpkS;
        elseif side==1-left, lpkA = WpkS; rpkA = RrwS;
        end;

    case 'direct',
        if     side==left, ptnA = LddS; % post-tone act is either the Left or Right direct water delivery
        elseif side==1-left, ptnA = RddS;
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

% Behaviour from Cin (start of trial) to GO sound --------- ###############
%
b  = pstart;        % base state for main program

%      Cin    Cout    Lin    Lout    Rin    Rout   Tup    Timer   Dout    Aout

syncm = make_sync_matrix(sync_start_state, n_done_trials+1,pstart,whsd,sync_dur);
stm = [stm ; syncm];
stm = [stm ; ...
    1+b     b      b      b       b      b       b      100      0       0 ; ...   %0 : b     Pre-state: wait for C poke
    1+b     b      b      b       b      b      2+b     0.01     0       0 ];    %1 : 1+b   if pk<10 ms, doesn't count

% Granularity needs to be created for a single state which has the pre-sound
% state, relevant tones, gaps, and the final GO chord

% Old version: Everything from the starting cluck sound, pre-sound time
% right up to 'GO' signal used to be in 2+b:left_over_state. The new
% version will create separate chunks of states for each of these extents
% to cleanly separate their analysis.
% [stm_sstay, left_over_state] = granular_section(2+b, TouS, snd_stay_time, Granularity/1000, LegalSkipOut/1000, stne);

% NOTE: However, that the *sound* itself is still one and is only triggered
% during the pre-sound state (so that we may begin with a "Cluck")
[stm_presound, cue_start_state] = granular_section(2+pstart, TouS, prst, Granularity/1000, LegalSkipOut/1000, stne);
[stm_cue, prego_start_state] = granular_section(cue_start_state, TouS, cue, Granularity/1000, LegalSkipOut/1000);
[stm_prego, go_start_state] = granular_section(prego_start_state, TouS, pre_chord, Granularity/1000, LegalSkipOut/1000);
[stm_sstay, go_leave_state] = granular_section(go_start_state, TouS, go_stay, Granularity/1000, LegalSkipOut/1000);

stm = [stm; stm_presound];
RealTimeStates.pre_chord = pstart + 2 : cue_start_state-1;
stm = [stm; stm_cue];
RealTimeStates.cue = cue_start_state:prego_start_state-1;
stm = [stm; stm_prego];
RealTimeStates.pre_go = prego_start_state:go_start_state-1;
stm = [stm; stm_sstay];
RealTimeStates.chord = go_start_state:go_leave_state;

b = size(stm,1);
if ptnA == WpkS
    stm = [stm ; ...
        WpkS   WpkS    WpkS    WpkS    WpkS    WpkS  WpkS  go_leave  0   0];
elseif ptnA == LddS
    stm = [stm ; ...
        b   b   LddS    LddS    LddS    LddS	LddS  go_leave  0   0];
elseif ptnA == RddS
    stm = [stm ; ...
        b   b   RddS    RddS    RddS    RddS	RddS go_leave  0   0];
else
    error('Invalid value for ptnA; (must be WpkS, LddS or RddS)');
end;

stm = [stm ; ...
    WpkS   WpkS   lpkA   WpkS    rpkA   WpkS    WpkS    100     0   0 ; ...  %5 : 5+b   wait for r/l poke act
    ];

% RealTimeStates.pre_chord = pstart + 2:left_over_state;
% RealTimeStates.chord     = pstart + 2:left_over_state;

stm = [stm ; zeros(rewardstart-size(stm,1),10)];       % PAD till next hard-coded point (rewardstart)

global left1water;  lvid = left1water;
global right1water; rvid = right1water;

% Note: Although states for all trial types and schedules are defined, lpkA
% and rpkA (above) control which of these states left and right pokes
% transition to.
% deliver water in the older valve-style
%      Cin    Cout    Lin    Lout    Rin    Rout   Tup    Timer   Dout    Aout
stm = [stm ; ...
    LrwS   LrwS   LrwS   LrwS    LrwS   LrwS   1+LrwS   lwpt     lvid       0 ; ... %0 : Left reward: give water
    1+LrwS 1+LrwS 1+LrwS 1+LrwS  1+LrwS 1+LrwS   ItiS    drkt     0       0 ; ... %1 : free time to enjoy water
    RrwS   RrwS   RrwS   RrwS    RrwS   RrwS   1+RrwS   rwpt     rvid       0 ; ... %2 : Right reward: give water
    1+RrwS 1+RrwS 1+RrwS 1+RrwS  1+RrwS 1+RrwS   ItiS    drkt     0       0 ; ... %3 : free time to enjoy water
    LddS   LddS   LddS   LddS    LddS   LddS   1+LddS   lwpt     lvid       0 ; ... %4 : Left direct w delivery
    1+LddS 1+LddS  2+LddS  1+LddS  1+LddS 1+LddS  1+LddS   100      0       0 ; ... %5 : Wait for L water collection
    2+LddS 2+LddS  2+LddS  2+LddS  2+LddS 2+LddS  ItiS   drkt+2      0       0 ; ... %5 : Wait for L water collection
    RddS   RddS   RddS   RddS    RddS   RddS   1+RddS   rwpt     rvid       0 ; ... %6 : Left direct w delivery
    1+RddS 1+RddS 1+RddS 1+RddS  2+RddS    1+RddS  1+RddS   100      0       0 ; ... %7 : Wait for R water collection
    2+RddS 2+RddS 2+RddS 2+RddS  2+RddS    2+RddS  ItiS   drkt+2      0       0 ; ... %7 : Wait for R water collection
    ];
% end;

RealTimeStates.left_dirdel = LddS:LddS+2;
RealTimeStates.right_dirdel = RddS:RddS+2;

% % Set after sound trig, before sound end state to hold contingencies
% % that the post tone Act (ptnA) state holds:
% stm(4+b+1, 1:6) = stm(ptnA+1,1:6);

% Behaviour during ITI states ----------------------------- ###############
% (regular, reinit-ed and penalty)
bbfg = ~strcmp(BadBoySound, 'off');

stm = [stm ; zeros(ITI_state-size(stm,1),10)];

[stm, ITI_endstate] = ...
    noise_section(stm, ITI_state, ITIReinit_state, 35, ...
    'off', ITILength, error_sound_len, errsd, wnln, whsd);
[stm, ITIReinit_endstate] = ...
    noise_section(stm, ITIReinit_state, ITIReinit_state, ITI_state, ...
    BadBoySound, ITIReinitPenalty, error_sound_len, errsd, wnln, whsd);
[stm, ExtraITI_endstate] = ...
    noise_section(stm, ExtraITI_state, ExtraITIReinit_state, ITI_state, ...
    BadBoySound, ExtraITIonError, error_sound_len, errsd, wnln, whsd);

if ExtraITIonError == 0, donestate = ITI_state;
else                     donestate = ExtraITI_state+2*bbfg;
end;
[stm, ExtraITIReinit_endstate] = ...
    noise_section(stm, ExtraITIReinit_state, ExtraITIReinit_state, ...
    donestate, BadBoySound, ExtraITIReinitPenalty, ...
    error_sound_len, errsd, wnln, whsd);

RealTimeStates.iti       = ...
    [ITI_state     :ITI_endstate           ITIReinit_state:ITIReinit_endstate];
RealTimeStates.extra_iti = ...
    [ExtraITI_state:ExtraITI_endstate ExtraITIReinit_state:ExtraITIReinit_endstate];

% Behaviour during TimeOut states ----------------------------- ############
% if fake_rp_box == -12
% % untrigger cue sound
% stm = [stm;  ...
%     TouS    TouS    TouS    TouS    TouS    TouS    TouS+1  0.001   0   -1];
% end;

if fake_rp_box == 2
    stm = [stm; ...
        TouS    TouS    TouS    TouS    TouS    TouS    TouS+1  0.001 0 -1];
    [stm, TimeOut_endstate] = ...
        noise_section(stm, TimeOut_state+1, TimeOutReinit_state, pstart, ...
        BadBoySound, TimeOutLength, bbln, bbsd, wnln, whsd);
else
    [stm, TimeOut_endstate] = ...
        noise_section(stm, TimeOut_state, TimeOutReinit_state, pstart, ...
        BadBoySound, TimeOutLength, bbln, bbsd, wnln, whsd);
end;

if TimeOutLength == 0, donestate = pstart;
else                   donestate = TimeOut_state+2*bbfg;
end;
[stm, TimeOutReinit_endstate] = ...
    noise_section(stm, TimeOutReinit_state, TimeOutReinit_state, ...
    donestate, BadBoySound, TimeOutReinitPenalty, ...
    error_sound_len, errsd, wnln, whsd);

RealTimeStates.timeout   = ...
    [TimeOut_state :TimeOut_endstate   TimeOutReinit_state:TimeOutReinit_endstate];

% Wrap-up ... and add a pretty bow! -------------------------- ############

% PAD with zeros up to a 512 size (fixed size of stm matrix):
stm = [stm ; zeros(512-size(stm,1),10)];

% store for posterity
if ~exist('state_matrix', 'var'),
    SoloParamHandle(obj, 'state_matrix');
end;
state_matrix.value = stm;

rpbox('send_matrix', stm, 1, 1);   % <~> added another arg (value 1) to the call to employ Carlos's fix for long deadtimes (See comment at beginning of .../Modules/RPbox.m.).
% rpbox('ForceState0');

% Store the latest RealTimeStates
push_history(RealTimeStates);

SavingSection(value(super),'autosave_data');

return;

function [sync_matrix] = make_sync_matrix(start_state, trial_num, goto_state,wnoise_id,state_dur)

Dout_sync_line = bSettings('get', 'DIOLINES', 'trialnum_indicator');

%        Cin    Cout    Lin    Lout     Rin     Rout    Tup    Timer    Dout   Aout
% Aout_col=10;
Dout_col = 9;
timer_col = 8;
Tup_col = 7;
sync_rows = 16;

%The field is actually 16 bits long with the 1st bit always on and the  
% next 15 bits indicating the trialnum.
sync_matrix = zeros(sync_rows,10);

base_act = (start_state:1:start_state+(sync_rows-1))';
first_six = repmat(base_act,1, 6);
sync_matrix(1:sync_rows, 1:6) = first_six;

sync_matrix(1,Dout_col) = Dout_sync_line; % leading "High" signal
sync_matrix(1:sync_rows,Tup_col) = (start_state+1:1:start_state+sync_rows)';
sync_matrix(1:sync_rows, timer_col) = ones(sync_rows,1) * (state_dur/1000); % convert to seconds, 
                                                                            % because that's the unit for the state machine

% encode the upcoming trial number in binary
bin_state = dec2bin(trial_num);
start_pos = (sync_rows - length(bin_state)) + 1;
ctr = 1;
for k = start_pos:sync_rows
    sync_matrix(k, Dout_col) = Dout_sync_line*str2double(bin_state(ctr)); 
    ctr = ctr+1;
end;
% (looks like this line is an error) sync_matrix(Dout_col,start_pos:end) = str2double(bin_state);

% play white noise in sync matrix to prevent cin
% sync_matrix(1:sync_rows, Aout_col) = ones(sync_rows,1) * wnoise_id;

% finally transition to pstart state
sync_matrix(sync_rows, Tup_col) = goto_state;
function make_and_upload_state_matrix(obj, action)

% Known bug: miss on right direct delivery doesn't produce ITI sound

DeadTimeReinitPenalty = 6;

GetSoloFunctionArgs;
% SoloFunction('make_and_upload_state_matrix', ...
%    'rw_args', 'RealTimeStates', ...
%    'ro_args', {'n_done_trials', 'side_list', 'vpd_list', ...
%    'chord_sound_len', 'WaterDelivery', 'RewardPorts', 'DrinkTime', ...
%    'BadBoySound', 'ITISound', 'ITILength', 'ITIReinitPenalty', ...
%    'TimeOutSound', 'TimeOutLength', 'TimeOutReinitPenalty', ...
%    'ExtraITIonError', 'LeftWValveTime', 'RightWValveTime'});

switch action,
    case 'next_matrix',
        % Everything fine, skip init and proceed to next section of function

    case 'init'
        amp = 0.095;
        SoloParamHandle(obj, 'white_noise_len',   'value', 2);
        SoloParamHandle(obj, 'white_noise_sound', 'value', ...
            amp*rand(1,floor(white_noise_len*50e6/1024)));

        % 150 ms of white noise, followed by 50 ms of silence:
        bb_unit = [amp*rand(1, floor(0.150*50e6/1024)) ...
            zeros(1, floor(0.050*50e6/1024))];
        SoloParamHandle(obj, 'badboy_sound');
        badboy_sound.value = [bb_unit bb_unit bb_unit bb_unit];

        SoloParamHandle(obj, 'badboy_len', 'value', ...
            length(value(badboy_sound))/floor(50e6/1024));

        % Harsher version of badboy sound:
        h_bb_unit = MakeChord( 50e6/1024, 70-67, 20*1000, 4, 850, 0.005*1000 );
        SoloParamHandle(obj, 'harsher_badboy_sound');
        partial_bb = [amp*rand(1, floor(0.8*50e6/1024)) zeros(1, floor(0.050*50e6/1024))];
        harsher_badboy_sound.value = [ h_bb_unit+partial_bb h_bb_unit+partial_bb ];

        SoloParamHandle(obj, 'harsher_badboy_len', 'value', ...
            length(value(harsher_badboy_sound))/floor(50e6/1024));


        rpbox('loadrp3stereosound2', {[]; value(white_noise_sound)});
        if strcmp(BadBoySound, 'harsher')
            rpbox('loadrp3stereosound3', {[]; []; value(harsher_badboy_sound)});
        else
            rpbox('loadrp3stereosound3', {[]; []; value(badboy_sound)});
        end;

    otherwise,
        error(['Don''t know how to handle action ' action]);
end;

if strcmp(BadBoySound, 'harsher')
    rpbox('loadrp3stereosound3', {[]; []; value(harsher_badboy_sound)});
else
    rpbox('loadrp3stereosound3', {[]; []; value(badboy_sound)});
end;

stne  = 1; % sample tone
whsd  = 2; % white noise sound
bbsd  = 4; % bad boy sound

whln     = value(white_noise_len);

if strcmp(BadBoySound, 'harsher')
    bbln     = value(harsher_badboy_len);
else
    bbln     = value(badboy_len);
end;
iti      = ITILength;
tout     = TimeOutLength;
lwpt     = LeftWValve;
rwpt     = RightWValve;
drkt     = DrinkTime;
ntrials  = n_done_trials;

if ITILength/whln ~= floor(ITILength/whln)  |  ...
        TimeOutLength/whln         ~= floor(TimeOutLength/whln)  |  ...
        ExtraITIonError/whln       ~= floor(ExtraITIonError/whln)  |  ...
        ITIReinitPenalty/whln      ~= floor(ITIReinitPenalty/whln)  |  ...
        TimeOutReinitPenalty/whln  ~= floor(TimeOutReinitPenalty/whln),
    error(sprintf('ITI, ExtraITI, Timeout, Reinit pnalties must be multiples of %g',whln));
end;
if DeadTimeReinitPenalty/whln ~= floor(DeadTimeReinitPenalty/whln),
    error(sprintf(['DeadTimeReinit pnalties must be multiples of %g\n ' ...
        'Correct this within @%s/%s'], whln, class(obj), mfilename));
end;

ExtraITIReinitPenalty = ITIReinitPenalty;

side = side_list(n_done_trials+1);
vpd  = vpd_list(n_done_trials+1);

tdur = chord_sound_len;

pstart      = 40;   % start of main program
rewardstart = 47;  % start of reward states program
itistart    = 100;  % start of iti and timeout parts of program

b  = pstart;      % base state for main program

%        Cin    Cout    Lin    Lout     Rin     Rout    Tup    Timer    Dout   Aout
stm = [ pstart pstart  pstart pstart   pstart  pstart  pstart   0.01     0       0 ; ... % go to start of program
    ];


% function [stm, endstate] = ...
%  noise_section(stm,startstate,pokestate,donestate,BadBoySound,Len, ...
%                bbln, bbsd, whln, whds)

DeadTimeReinit_state = 3;
stm = noise_section(stm, 1, DeadTimeReinit_state, 35, 'off', whln, ...
    bbln, bbsd, whln, whsd);

[stm, DeadTime_endstate] = ...
    noise_section(stm, DeadTimeReinit_state, DeadTimeReinit_state, 35, ...
    BadBoySound, DeadTimeReinitPenalty, bbln, bbsd, whln, whsd);



RealTimeStates.dead_time = [1:DeadTime_endstate 35];



stm = [stm ; zeros(pstart-size(stm,1),10)];

% State 35 for no-dead-time technology
stm(36,:) = [35 35   35 35   35 35    1  0.01 0 0];
RealTimeStates.state35 = 36;

% Now to work
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


%bbfg = strcmp(BadBoySound, 'on');
bbfg = ~strcmp(BadBoySound, 'off');

ITI_state = 55;
ITIReinit_state      = ITI_state            + ...
    max(2*ITILength/whln, 1); % no bb in ITI
ExtraITI_state       = ITIReinit_state      + ...
    max(2*ITIReinitPenalty/whln + 2*bbfg, 1);
ExtraITIReinit_state = ExtraITI_state       + ...
    max(2*ExtraITIonError/whln  + 2*bbfg, 1);
TimeOut_state        = ExtraITIReinit_state + ...
    max(2*ITIReinitPenalty/whln + 2*bbfg, 1);
TimeOutReinit_state  = TimeOut_state        + ...
    max(2*TimeOutLength/whln    + 2*bbfg, 1);
TimeOutReinit_endstate = TimeOutReinit_state + ...
    max(2*TimeOutReinitPenalty/whln + 2*bbfg, 1);

if TimeOutReinit_endstate > 128,
    fprintf(2, ['The reinits and timeouts and ITIs are too long! Reducing\n' ...
        'them and trying them again. This will *not* be reflected\n' ...
        'in the GUI.\n']);
    [trash, u] = max([TimeOutReinitPenalty ITIReinitPenalty ITILength ...
        TimeoutLength]);
    switch u(1),
        case 1, TimeOutReinitPenalty = TimeOutReinitPenalty - whln;
        case 2, ITIReinitPenalty     = ITIReinitPenalty - whln;
        case 3, ITILength            = ITILength - whln;
        case 4, TimeOutLength        = TimeOutLength - whln;
    end;

    make_and_upload_state_matrix(obj, 'next_matrix');
end;

% ----


ItiS = ITI_state;
TouS = TimeOut_state;
if tout < 0.001, TouS = pstart; end;  % timeouts of zero mean just skip that state

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

vlst = ChordSection(value(super), 'get_ValidSoundTime');

prst = vpd - vlst; % presound time
if prst < 0.02, prst = 0.02; end; % Hack for when tdur changes in the middle of a trial
if vlst < 0.02, vlst = 0.02; end; % Equal hack

lost = tdur - vlst; if lost < 0.02, lost = 0.02; end; % leftover sound time


global fake_rp_box;

if isempty(fake_rp_box) | fake_rp_box ~= 1,
    %      Cin    Cout    Lin    Lout    Rin    Rout   Tup    Timer   Dout    Aout
    stm = [stm ; ...
        1+b     b      b      b       b      b       b      100      0       0 ; ... %0 : Pre-state: wait for C poke
        1+b     b      b      b       b      b      2+b     0.01     0       0 ; ... %1 : if pk<10 ms, doesn't count
        TouS   TouS   TouS   TouS    TouS   TouS    3+b     prst     0       0 ; ... %2 : pre sound time
        TouS   TouS   TouS   TouS    TouS   TouS    4+b     vlst     0    stne ; ... %3 : trigger sample sound
        0      0      0      0       0      0      ptnA    lost     0       0 ; ... %4 : After snd trig, before sound end: To be filled with whatever ptnA holds
        WpkS   WpkS   lpkA   WpkS    rpkA   WpkS    WpkS    100      0       0 ; ... %5 : wait for r/l poke act
        ];
else
    WtoS = pstart+6; % wait for sound over before going to the timeout state
    lost = tdur - vlst; if lost < 0.02, lost = 0.02; end;

    %      Cin    Cout    Lin    Lout    Rin    Rout   Tup    Timer   Dout    Aout
    stm = [stm ; ...
        1+b     b      b      b       b      b       b      100      0       0 ; ... %0 : Pre-state: wait for C poke
        1+b     b      b      b       b      b      2+b     0.01     0       0 ; ... %1 : if pk<10 ms, doesn't count
        TouS   TouS   TouS   TouS    TouS   TouS    3+b     prst     0       0 ; ... %2 : pre sound time
        3+b    3+b    3+b    3+b     3+b    3+b     4+b     vlst     0    stne ; ... %3 : trigger sample sound
        0      0      0      0       0      0      ptnA    lost     0       0 ; ... %4 : After snd trig, before sound end: To be filled with whatever ptnA holds
        WpkS   WpkS   lpkA   WpkS    rpkA   WpkS    WpkS    100      0       0 ; ... %5 : wait for r/l poke act
        WtoS   WtoS   WtoS   WtoS    WtoS   WtoS    TouS    tdur     0       0 ; ... %6 : wait for sound over bf timeout
        ];
end;


RealTimeStates.pre_chord = pstart + 2;
RealTimeStates.chord     = pstart + (3:4);

stm = [stm ; zeros(rewardstart-size(stm,1),10)];

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


% function [stm, endstate] = ...
%     noise_section(stm,startstate,pokestate,donestate,BadBoySound,Len, ...
%                bbln, bbsd, whln, whsd)

%bbfg = strcmp(BadBoySound, 'on');
bbfg = ~strcmp(BadBoySound, 'off');

[stm, ITI_endstate] = ...
    noise_section(stm, ITI_state, ITIReinit_state, 35, ...
    'off', ITILength, bbln, bbsd, whln, whsd);
[stm, ITIReinit_endstate] = ...
    noise_section(stm, ITIReinit_state, ITIReinit_state, ITI_state, ...
    BadBoySound, ITIReinitPenalty, bbln, bbsd, whln, whsd);
[stm, ExtraITI_endstate] = ...
    noise_section(stm, ExtraITI_state, ExtraITIReinit_state, ITI_state, ...
    BadBoySound, ExtraITIonError, bbln, bbsd, whln, whsd);

if ExtraITIonError == 0, donestate = ITI_state;
else                     donestate = ExtraITI_state+2*bbfg;
end;
[stm, ExtraITIReinit_endstate] = ...
    noise_section(stm, ExtraITIReinit_state, ExtraITIReinit_state, ...
    donestate, BadBoySound, ExtraITIReinitPenalty, ...
    bbln, bbsd, whln, whsd);


[stm, TimeOut_endstate] = ...
    noise_section(stm, TimeOut_state, TimeOutReinit_state, pstart, ...
    BadBoySound, TimeOutLength, bbln, bbsd, whln, whsd);

if TimeOutLength == 0, donestate = pstart;
else                   donestate = TimeOut_state+2*bbfg;
end;
[stm, TimeOutReinit_endstate] = ...
    noise_section(stm, TimeOutReinit_state, TimeOutReinit_state, ...
    donestate, BadBoySound, TimeOutReinitPenalty, ...
    bbln, bbsd, whln, whsd);



RealTimeStates.timeout   = ...
    [TimeOut_state :TimeOut_endstate   TimeOutReinit_state:TimeOutReinit_endstate];
RealTimeStates.iti       = ...
    [ITI_state     :ITI_endstate           ITIReinit_state:ITIReinit_endstate];
RealTimeStates.extra_iti = ...
    [ExtraITI_state:ExtraITI_endstate ExtraITIReinit_state:ExtraITIReinit_endstate];



% Pad with zeros up to a 128 size:
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




% --------- NOISE_SECTION -------------

function [stm, endstate] = ...
    noise_section(stm,startstate,pokestate,donestate,BadBoySound,Len, ...
    bbln, bbsd, whln, whsd)
%
% Pads with zeros up to startstate; then puts in a BadBoySound (if
% 'on'), followed by Len secs of white noise (Len must be a multiple of
% whln). On poke, goes to pokestate; at end, goes to donestate. whln is
% the length, in secs, of the white noise signal
%
% bbln : bad boy length, in sec
% bbsd : trigger for bad boy sound (i.e., column 10 of stm
% whln : white noise length in sec
% whsd : trigger for white nois

% NOTE !!! Len must be a multiple of whln !!!!

if strcmp(BadBoySound, 'off') && Len==0
    % There is nothing to do here-- go to your done state asap
    c = size(stm,1);
    stm = [stm ; ...
        c      c       c       c        c     c    donestate 0.001 0 0];
    endstate = c;
    return
end;

stm = [stm ; zeros(startstate-size(stm,1),10)];
b0 = pokestate; c = size(stm,1);
%if strcmp(BadBoySound, 'on')
if ~strcmp(BadBoySound, 'off')
    % Start with bad boy sound, then go to white noises..
    stm = [stm ; ...
        b0     b0      b0      b0       b0    b0      c+1      0.03     0       0 ; ...
        b0     b0      b0      b0       b0    b0      c+2      bbln     0    bbsd];
end

% If done with the white noises, go to the done state
if Len==0, stm(end,7) = donestate; end

for i=1:Len/whln
    c = size(stm, 1);
    stm = [stm ; ...
        b0    b0       b0      b0       b0    b0      c+1      0.03     0       0 ; ...
        b0    b0       b0      b0       b0    b0      c+2      whln     0    whsd];
    % If done with the white noises, go to the done state
    if i==Len/whln, stm(end,7) = donestate; end
end;

endstate = c+1;
return







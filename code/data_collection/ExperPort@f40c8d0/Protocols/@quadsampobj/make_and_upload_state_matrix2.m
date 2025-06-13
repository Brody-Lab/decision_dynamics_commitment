function RealTimeStates = make_and_upload_state_matrix(obj, action)

DeadTimeReinitPenalty = 0;

GetSoloFunctionArgs;
% SoloFunction('make_and_upload_state_matrix', ...
%    'ro_args', {'n_done_trials', 'side_list', 'vpd_list', ...
%    'chord_sound_len', 'go_dur', 'Granularity', 'LegalSkipOut', ...
%    'WaterDelivery', 'RewardPorts', 'DrinkTime', ...
%    'BadBoySound', 'ITISound', 'ITILength', 'ITIReinitPenalty', ...
%    'TimeOutSound', 'TimeOutLength', 'TimeOutReinitPenalty', ...
%    'APokePenalty', ...
%    'ExtraITIonError', 'LeftWValve', 'RightWValve'});


switch action,
    case 'next_matrix',
      % Everything fine, skip init and proceed to next section of function

    case 'init'
        global fake_rp_box;
        if fake_rp_box==2, srate = GetSampleRate(rpbox('getsoundmachine'));
        else               srate = 50e6/1024;
        end;

        SoloParamHandle(obj, 'Stateguys', 'value', struct('ITI', [], 'ITIReinit', [], ...
            'ExtraITI', [], 'ExtraITIReinit', [], 'TimeOutFirm', [], 'TimeOut', [], ...
            'TimeOutReinit', []));
        
        amp = 0.095;
        SoloParamHandle(obj, 'white_noise_len',   'value', 2);
        SoloParamHandle(obj, 'white_noise_sound', 'value', ...
            amp*rand(1,floor(white_noise_len*srate)));

        % 150 ms of white noise, followed by 50 ms of silence:
        bb_unit = [amp*rand(1, floor(0.150*srate)) ...
            zeros(1, floor(0.050*srate))];
        SoloParamHandle(obj, 'badboy_sound');
        badboy_sound.value = [bb_unit bb_unit bb_unit bb_unit];

        SoloParamHandle(obj, 'badboy_len', 'value', ...
            length(value(badboy_sound))/floor(srate));

        % Harsher version of badboy sound:
        h_bb_unit = MakeChord( srate, 70-67, 6*1000, 8, 850, 0.005*1000 );
        SoloParamHandle(obj, 'harsher_badboy_sound');
        partial_bb = [amp*rand(1, floor(0.150*srate)) ...
                      zeros(1, floor(0.050*srate)) ...
                      amp*rand(1, floor(0.150*srate)) ...
                      zeros(1, floor(0.050*srate)) ...
                      amp*rand(1, floor(0.150*srate)) ...
                      zeros(1, floor(0.050*srate)) ...
                      amp*rand(1, floor(0.150*srate)) ...
                      zeros(1, floor(0.100*srate)) ...
                      ];
        
        % Make sure the two components are same length:
        if length(partial_bb) < length(h_bb_unit)
            partial_bb = [partial_bb zeros(1, length(h_bb_unit)-length(partial_bb))];          
        elseif length(partial_bb) > length(h_bb_unit)
            partial_bb = partial_bb(1:length(h_bb_unit));
        end;
        
        harsher_badboy_sound.value = ...
            [ h_bb_unit+partial_bb h_bb_unit+partial_bb ];

        SoloParamHandle(obj, 'harsher_badboy_len', 'value', ...
            length(value(harsher_badboy_sound))/floor(srate));


        rpbox('loadrp3stereosound2', {[]; value(white_noise_sound)});
        if strcmp(BadBoySound, 'harsher')
            rpbox('loadrp3stereosound3', {[]; []; value(harsher_badboy_sound)});
        else
            rpbox('loadrp3stereosound3', {[]; []; value(badboy_sound)});
        end;

        SoloParamHandle(obj, 'RealTimeStates', 'value', struct(...
          'wait_for_cpoke', 0, ...  % Waiting for initial center poke
          'wait_for_apoke', 0, ...  % Waiting for an answer poke
          'left_reward',    0, ...
          'right_reward',   0, ...
          'drink_time',     0, ...
          'left_dirdel',    0, ...  
          'right_dirdel',   0, ...
          'pre_chord',      0, ...
          'chord',          0, ...
          'timeout',        0, ...
          'iti',            0, ...
          'dead_time',      0, ...
          'state35',        0, ...
          'extra_iti',      0));
        
    otherwise,
        error(['Don''t know how to handle action ' action]);
end;

if strcmp(BadBoySound, 'harsher')
    rpbox('loadrp3stereosound3', {[]; []; value(harsher_badboy_sound)});
else
    rpbox('loadrp3stereosound3', {[]; []; value(badboy_sound)});
end;


sm = rpbox('getstatemachine');

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
tout     = TimeOutLength-TimeOutFirm;
touf     = TimeOutFirm;
lwpt     = LeftWValve;
rwpt     = RightWValve;
drkt     = DrinkTime;
ntrials  = n_done_trials;

if ITILength/whln ~= floor(ITILength/whln)  |  ...
        TimeOutFirm/whln           ~= floor(TimeOutFirm/whln)  |  ...
        TimeOutLength/whln         ~= floor(TimeOutLength/whln)  |  ...
        ExtraITIonError/whln       ~= floor(ExtraITIonError/whln)  |  ...
        ITIReinitPenalty/whln      ~= floor(ITIReinitPenalty/whln)  |  ...
        TimeOutReinitPenalty/whln  ~= floor(TimeOutReinitPenalty/whln),
    error(sprintf('ITI, ExtraITI, Timeout, Reinit penalties must be multiples of %g',whln));
end;
if DeadTimeReinitPenalty/whln ~= floor(DeadTimeReinitPenalty/whln),
    error(sprintf(['DeadTimeReinit penalties must be multiples of %g\n ' ...
        'Correct this within @%s/%s'], whln, class(obj), mfilename));
end;

ExtraITIReinitPenalty = ITIReinitPenalty;

side = side_list(n_done_trials+1);
vpd  = vpd_list(n_done_trials+1);

tdur = chord_sound_len;

vlst = ChordSection(obj, 'get_ValidSoundTime');


sound_stay_time = (chord_sound_len - go_dur) + vlst;
if sound_stay_time < 0.01, sound_stay_time = 0.01; end;
lost = tdur - sound_stay_time; 
if lost < 0.02, lost = 0.02; end; % leftover sound time - rat can poke out at this point without penalty

pstart      = 40;   % start of main program
% function [stm, donestate] = ...
%       granular_section(start, penalty_state, timelength, granularity, legalskipout, initial_trigger)

rewardstart = 40 + 2 + rows(granular_section(0, 0, sound_stay_time, Granularity/1000, LegalSkipOut/1000)) + 2;


itistart    = rewardstart+40;  % start of iti and timeout parts of program

b  = pstart;      % base state for main program

%        Cin    Cout    Lin    Lout     Rin     Rout  SchedWaves  Tup    Timer    Dout   Aout
stm = [ pstart pstart  pstart pstart   pstart  pstart  0 0 0 0   pstart   0.01     0       0 0; ... % go to start of program
    ];


global fake_rp_box;
nix_dead_time_reinit = 0;

cls = GetDioScheduledWaveInputColumns(sm); nx = length(cls);

if nix_dead_time_reinit,
   if fake_rp_box==2 | fake_rp_box==3,
      stm = [stm ; ...
             1 1   1 1   1 1  zeros(1,nx)  2  0.01  0  -1   0 ; ...
             2 2   2 2   2 2  zeros(1,nx)  3  0.01  0  -2   0 ; ...
             3 3   3 3   3 3  zeros(1.nx)  4  0.01  0  -4   0 ; ...
             4 4   4 4   4 4  zeros(1,nx) 35  whln  0 whsd] 0 ;
   else
      stm = [stm ; ...
             1 1   1 1   1 1  zeros(1,nx)   2  0.03  0  0   0 ; ...
             2 2   2 2   2 2  zeros(1,nx)  35  whln  0 whsd 0];
   end;
   RealTimeStates.dead_time = [1:39];     
else
   DeadTimeReinit_state = 6;
   [sm, stm] = noise_section(sm, stm, 1, DeadTimeReinit_state, 35, 'off', whln, ...
                       bbln, bbsd*deadtime_noise, whln, whsd*deadtime_noise);

   [sm, stm, DeadTime_endstate] = ...
       noise_section(sm, stm, DeadTimeReinit_state, DeadTimeReinit_state, 1, ...
                     BadBoySound, DeadTimeReinitPenalty, ...
                     bbln, bbsd*deadtime_noise, whln, whsd*deadtime_noise);

   RealTimeStates.dead_time = [1:DeadTime_endstate 35];
end;




stm = [stm ; zeros(pstart-size(stm,1),cols(stm))];

% State 35 for no-dead-time technology
stm(36,:) = [35 35   35 35   35 35  zeros(1.nx)   1  0.01 0 0 0];
RealTimeStates.state35 = 36;

% Now to work
if n_done_trials >= TrialLimit | ...
       etime(clock, value(protocol_start_time))/60 > MaxMins,
   
   rpbox('loadrp3stereosound2', {[]; 0.3*value(white_noise_sound)});
   sm = ClearScheduledWaves(sm); 
   sm = SetInputEvents(sm, 6);
   rpbox('setstatemachine', sm);

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

   SavingSection(obj, 'savesets', 'interactive', 0, 'commit', 1);
   SavingSection(obj, 'savedata', 'interactive', 0, 'commit', 1);
   warndlg('Saved data already-- no need to save again');
   return;
end;



WpkS = rewardstart-1;  % state in which we're waiting for a R or L poke
RealTimeStates.wait_for_cpoke = pstart;
RealTimeStates.wait_for_apoke = WpkS;

LrwS = rewardstart+0;  % state that gives water on left  port
RrwS = rewardstart+2;  % state that gives water on right port
LddS = rewardstart+4;  % state for left  direct water delivery
RddS = rewardstart+7;  % state for right direct water delivery
RealTimeStates.left_reward    = LrwS;
RealTimeStates.right_reward   = RrwS;
RealTimeStates.drink_time     = [LrwS+1 RrwS+1 LddS+2 RddS+2];
RealTimeStates.left_dirdel    = LddS;
RealTimeStates.right_dirdel   = RddS;


%bbfg = strcmp(BadBoySound, 'on');
bbfg = ~strcmp(BadBoySound, 'off');

ITI_state = rewardstart + 12;
ITIReinit_state      = ITI_state            + ...
    max(3 + 2*ITILength/whln, 1); % no bb in ITI
ExtraITI_state       = ITIReinit_state      + ...
    max(3 + 2*ITIReinitPenalty/whln + 2*bbfg, 1);
ExtraITIReinit_state = ExtraITI_state       + ...
    max(3 + 2*ExtraITIonError/whln  + 2*bbfg, 1);
TimeOutFirm_state        = ExtraITIReinit_state + ...
    max(3 + 2*ITIReinitPenalty/whln + 2*bbfg, 1);
TimeOut_state        = TimeOutFirm_state + 3*(touf/whln);
TimeOutReinit_state  = TimeOut_state        + ...
    max(3 + 2*TimeOutLength/whln    + 2*bbfg, 1);
TimeOutReinit_endstate = TimeOutReinit_state + ...
    max(3 + 2*TimeOutReinitPenalty/whln + 2*bbfg, 1);
MinorPenalty_state      = TimeOutReinit_endstate + 1;
MinorPenalty_endstate   = MinorPenalty_state + 3*round(MinorPenalty/whln);
minor_penalty = MinorPenalty_state;

Stateguys.ITI            = ITI_state;
Stateguys.ITIReinit      = ITIReinit_state;
Stateguys.ExtraITI       = ExtraITI_state;
Stateguys.ExtraITIReinit = ExtraITIReinit_state;
Stateguys.TimeOutFirm    = TimeOutFirm_state;
Stateguys.TimeOut        = TimeOut_state;
Stateguys.TimeOutReinit  = TimeOutReinit_state;

if MinorPenalty_state > rpbox('get_state_matrix_nrows'),
    fprintf(2, ['The reinits and timeouts and ITIs are too long! Reducing\n' ...
        'them and trying them again. This will *not* be reflected\n' ...
        'in the GUI.\n']);
    [trash, u] = max([TimeOutReinitPenalty ITIReinitPenalty ITILength ...
        TimeOutLength]);
    switch u(1),
        case 1, TimeOutReinitPenalty = TimeOutReinitPenalty - whln;
        case 2, ITIReinitPenalty     = ITIReinitPenalty - whln;
        case 3, ITILength            = ITILength - whln;
        case 4, TimeOutLength        = TimeOutLength - whln;
    end;

    make_and_upload_state_matrix(obj, 'next_matrix');
end;

% ----

if TimeOutFirm < 0.001, TimeOutFirm_state = TimeOut_state; end;

ItiS = ITI_state;
TouS = TimeOutFirm_state;
% Total timeouts of zero mean just skip timeout
if tout+touf < 0.001, TouS = pstart; end;  

switch WaterDelivery,
    case 'only if nxt pke corr',
        punish = ExtraITI_state;
        ptnA = WpkS; % post-tone act here is to go to waiting for a R or L poke
        if     side>0.5, lpkA = LrwS;   rpkA = punish;  % lpkA and rpkA are acts (states to go to) on L and R pokes, respectively
        elseif side<0.5, lpkA = punish; rpkA = RrwS;
        end;

    case 'next corr poke',
        ptnA = WpkS; % post-tone act here is to go to waiting for a R or L poke
        if     side>0.5, lpkA = LrwS; rpkA = minor_penalty;
        elseif side<0.5, rpkA = RrwS; lpkA = minor_penalty;
        end;
        
    case 'direct',
        if     side>0.5, ptnA = LddS; % post-tone act is either the Left or Right direct water delivery
        elseif side<0.5, ptnA = RddS;
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
% function [stm, donestate] = ...
%       granular_section(start, penalty_state, timelength, granularity, legalskipout, initial_trigger)

WpkS_Cin_action = WpkS;
if strcmp(APokePenalty, 'on') WpkS_Cin_action = TouS; end;

global fake_rp_box;
if fake_rp_box == 0, off1=0; else off1 = -1; end;

if fake_rp_box == 0, offrl = 0;  offbb = 0;     offwh = 0; 
else                 offrl = -1; offbb = -bbsd; offwh = -whsd; 
end;

cls = GetDioScheduledWaveInputColumns(sm); nx = length(cls);

%      Cin    Cout    Lin    Lout    Rin    Rout                Tup    Timer   Dout    Aout
stm = [stm ; ...
       1+b     b      b      b       b      b       zeros(1,nx)  b      100      0    off1  0 ; ... %0 : Pre-state: wait for C poke (turn sound off if came thru timeout)
       1+b     b      b      b       b      b       zeros(1,nx) 2+b     0.01     0       0  0 ; ... %1 : if pk<10 ms, doesn't count
       ];

% Granularity needs to be created for a single state which has the
% pre-sound state, relevant tones, gaps and the final GO chord
[stm_sstay,  left_over_state] = ...
    granular_section(2+b, TouS, sound_stay_time, Granularity/1000, ...
                     LegalSkipOut/1000, stne);  % stne instead of zero for
                                             % relevant sound
stm = [stm ; stm_sstay];

cls = GetDioScheduledWaveInputColumns(sm); nx = length(cls);


b = size(stm,1);
if ptnA == WpkS,
   stm = [stm ; ...
       WpkS_Cin_action   WpkS   lpkA   WpkS    rpkA   WpkS  zeros(1,nx)  WpkS    lost      0       0   0];
elseif ptnA == LddS,
   stm = [stm ; ...
          b  b      LddS  LddS     LddS  LddS    zeros(1,nx) LddS    lost     0  0 0];
elseif ptnA == RddS,
   stm = [stm ; ...
          b  b      RddS  RddS     RddS  RddS    zeros(1,nx) RddS    lost     0  0 0];
else
   error('ptnA is none of WpkS, LddS, Rdds-- what do I do??');
end;

stm =[stm ;
      WpkS_Cin_action   WpkS   lpkA   WpkS    rpkA   WpkS    zeros(1,nx) WpkS    100      0     0       0 ; ... %5 : wait for r/l poke act
     ];


RealTimeStates.pre_chord = pstart + 2:left_over_state;
RealTimeStates.chord     = pstart + 2:left_over_state;

stm = [stm ; zeros(rewardstart-size(stm,1),15)];


global left1water;  lvid = left1water; 
global right1water; rvid = right1water;

% What to do with sounds on entering reward state (not dir del):
if ReplayRelevant==1,
   sact = stne;
else
   sact = offrl;
end;


%      Cin    Cout    Lin    Lout    Rin    Rout   SchdWvs   Tup    Timer   Dout    Aout
stm = [stm ; ...
    LrwS   LrwS   LrwS   LrwS    LrwS   LrwS   zeros(1,nx) 1+LrwS   lwpt     lvid   sact  0; ... %0 : Left reward: give water
    1+LrwS 1+LrwS 1+LrwS 1+LrwS  1+LrwS 1+LrwS zeros(1,nx)  ItiS    drkt     0       0   0; ... %1 : free time to enjoy water
    RrwS   RrwS   RrwS   RrwS    RrwS   RrwS   zeros(1,nx) 1+RrwS   rwpt     rvid   sact; ... %2 : Right reward: give water
    1+RrwS 1+RrwS 1+RrwS 1+RrwS  1+RrwS 1+RrwS zeros(1,nx)  ItiS    drkt     0       0   0; ... %3 : free time to enjoy water
    LddS   LddS   LddS   LddS    LddS   LddS   zeros(1,nx) 1+LddS   lwpt     lvid     0   0; ... %4 : Left direct w delivery
    1+LddS 1+LddS 2+LddS 1+LddS  1+LddS 1+LddS zeros(1,nx) 1+LddS   100      0       0   0; ... %5 : Wait for L water collection
    2+LddS 2+LddS 2+LddS 2+LddS  2+LddS 2+LddS zeros(1,nx)   ItiS   drkt      0       0   0; ... %6 : Drink time
    RddS   RddS   RddS   RddS    RddS   RddS   zeros(1,nx) 1+RddS   rwpt     rvid     0   0; ... %7 : Left direct w delivery
    1+RddS 1+RddS 1+RddS 1+RddS 2+RddS  1+RddS zeros(1,nx) 1+RddS   100      0       0   0; ... %8 : Wait for R water collection
    2+RddS 2+RddS 2+RddS 2+RddS 2+RddS  2+RddS zeros(1,nx)   ItiS   drkt      0       0   0; ... %9 : drink time
    ];



% function [sm, stm, endstate] = ...
%     noise_section(sm, stm,startstate,pokestate,donestate,BadBoySound,Len, ...
%                bbln, bbsd, whln, whsd)

%bbfg = strcmp(BadBoySound, 'on');
bbfg = ~strcmp(BadBoySound, 'off');

stm = [stm ; zeros(ITI_state-size(stm,1),cols(stm))];


[sm, stm, ITI_endstate] = ...
    noise_section(sm, stm, ITI_state, ITIReinit_state, 35, ...
    'off', ITILength, bbln, bbsd, whln, whsd);
[sm, stm, ITIReinit_endstate] = ...
    noise_section(sm, stm, ITIReinit_state, ITIReinit_state, ITI_state, ...
    BadBoySound, ITIReinitPenalty, bbln, bbsd, whln, whsd);
[sm, stm, ExtraITI_endstate] = ...
    noise_section(sm, stm, ExtraITI_state, ExtraITIReinit_state, ITI_state, ...
    BadBoySound, ExtraITIonError, bbln, bbsd, whln, whsd);

if ExtraITIonError == 0, donestate = ITI_state;
else                     donestate = 3+ExtraITI_state+2*bbfg;
end;
[sm, stm, ExtraITIReinit_endstate] = ...
    noise_section(sm, stm, ExtraITIReinit_state, ExtraITIReinit_state, ...
    donestate, BadBoySound, ExtraITIReinitPenalty, ...
    bbln, bbsd, whln, whsd);

% Now add TimeOutFirm state:
for i=1:round(touf/whln),
    b = rows(stm);
    stm = [stm ;  ...
        b   b     b   b     b   b    zeros(1,nx)  b+1   0.001  0 offrl 0; ... 
       b+1 b+1   b+1 b+1   b+1 b+1   zeros(1,nx)  b+2   whln   0  whsd 0; ...
       b+2 b+2   b+2 b+2   b+2 b+2   zeros(1,nx)  b+3   0.03   0 offwh 0];
end;
% Add such a section for minor_penalty at end of
% TimeOutReinit_endstate; be careful about MinorPenalty being zero.
% Check if it works. Check for doing it with just next corr poke.
% If there is no regular timeout state, go back to pstart:
if tout<0.001 & round(touf/whln)>0, stm(end,7) = pstart; end;


[sm, stm, TimeOut_endstate] = ...
    noise_section(sm, stm, TimeOut_state, TimeOutReinit_state, pstart, ...
    'off', TimeOutLength, bbln, bbsd, whln, whsd);

if TimeOutLength == 0, donestate = pstart;
else                   donestate = 3+TimeOut_state+2*bbfg;
end;
[sm, stm, TimeOutReinit_endstate] = ...
    noise_section(sm, stm, TimeOutReinit_state, TimeOutReinit_state, ...
    donestate, BadBoySound, TimeOutReinitPenalty, ...
    bbln, bbsd, whln, whsd);


% Add such a section for minor_penalty at end of
% TimeOutReinit_endstate; be careful about MinorPenalty being zero.
% Check if it works. Check for doing it with just next corr poke.
% Now the minor_penalty section:
stm = [stm ; zeros(MinorPenalty_state-size(stm,1),10)];
n_mp = round(MinorPenalty/whln);
for i=1:n_mp,
    b = rows(stm);
    stm = [stm ;  ...
        b   b     b   b     b   b    zeros(1,nx)  b+1   0.001  0  0    0; ... 
       b+1 b+1   b+1 b+1   b+1 b+1   zeros(1,nx)  b+2   whln   0  whsd 0; ...
       b+2 b+2   b+2 b+2   b+2 b+2   zeros(1,nx)  b+3   0.03   0 offwh 0];
end;
b = rows(stm);
stm = [stm ;  ...
       b   b     b   b     b   b    zeros(1,nx)  WpkS   0.001  0 0 0];



RealTimeStates.timeout   = ...
    [TimeOutFirm_state:TimeOut_state-1  TimeOut_state:TimeOut_endstate   TimeOutReinit_state:TimeOutReinit_endstate];
RealTimeStates.iti       = ...
    [ITI_state     :ITI_endstate           ITIReinit_state:ITIReinit_endstate];
RealTimeStates.extra_iti = ...
    [ExtraITI_state : ExtraITI_endstate ...
     ExtraITIReinit_state : ExtraITIReinit_endstate ...
     MinorPenalty_state : MinorPenalty_endstate];



% Pad with zeros up to an nrows size:
stm = [stm ; zeros(rpbox('get_state_matrix_nrows')-size(stm,1),cols(stm))];

% store for posterity
if ~exist('state_matrix', 'var'),
    SoloParamHandle(obj, 'state_matrix');
end;
state_matrix.value = stm;

if isempty(GetDIOScheduledWaves(sm)), stm = stm(:,1:end-1); end;

rpbox('setstatemachine', sm);
rpbox('send_matrix', stm, 1);
rpbox('send_statenames', RealTimeStates);

% Store the latest RealTimeStates
push_history(RealTimeStates);

return;




% --------- NOISE_SECTION -------------

function [sm, stm, endstate] = ...
    noise_section(sm,stm,startstate,pokestate,donestate,BadBoySound,Len, ...
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

global fake_rp_box;
if fake_rp_box == 0, offrl = 0;  offbb = 0;     offwh = 0; 
else                 offrl = -1; offbb = -bbsd; offwh = -whsd; 
end;

if fake_rp_box == 0, offt = 0.01; else offt = 0.001; end;

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
% First turn all sounds off:
stm = [stm ; ...
        c   c    c   c    c   c   c+1   offt   0 offrl ; ...
       c+1 c+1  c+1 c+1  c+1 c+1  c+2   offt   0 offbb ; ...
       c+2 c+2  c+2 c+2  c+2 c+2  c+3   offt   0 offwh ; ...
       ];
c = size(stm,1);

if ~strcmp(BadBoySound, 'off')
    % Start with bad boy sound, then go to white noises..
    stm = [stm ; ...
        b0     b0      b0      b0       b0    b0      c+1      0.002     0       0 ; ...
        b0     b0      b0      b0       b0    b0      c+2      bbln     0    bbsd];
end

% If done with the white noises, go to the done state
if Len==0, stm(end,7) = donestate; end

for i=1:Len/whln
    c = size(stm, 1);
    stm = [stm ; ...
        b0    b0       b0      b0       b0    b0      c+1      0.03     0    offwh ; ...
        b0    b0       b0      b0       b0    b0      c+2      whln     0    whsd];
    % If done with the white noises, go to the done state
    if i==Len/whln, stm(end,7) = donestate; end
end;

endstate = c+1;
return


   
   
function [stm, donestate] = ...
       granular_section(start, penalty_state, timelength, granularity, legalskipout, initial_trigger)
   
   if nargin < 6, initial_trigger = 0; end;

   if legalskipout == 0,
      ps = penalty_state;
      stm = [start ps   ps ps   ps ps   start+1 timelength    0 initial_trigger];
      donestate = start+1;
      return;
   end;
   
   % e.g. of how this works
   % if timelength is 150ms, granularity 25ms, legalskipout 75ms
   % full_reg_units = 6 = nreg_states
   % full_legal_units = 3 = nlegal_states
   % stm will have the following states:
   % r1  [ (this_state) r1+1 ps ps ps ps r2 25 ]
   %    l1_1 [ r1 (this_state) ps ps ps ps l1_2 25 ]
   %    l1_2 [ r1 (this_state) ps ps ps ps l1_3 25 ] 
   %    l1_3 [ r1 ps ps ps ps ps l1_4 25 ]
   % r2  [ (this state) r2+1 ps ps ps ps r3 25]
   % l2_1 - l2_3 like l1_1 - l1_3
   % r3  [ (this_state) r3+1 ps ps ps ps ds 25 ] 
   % l3_1 - l3_3 like l1_3 - l1_3
   % 
   
      
   full_reg_units   = floor(timelength/granularity);
   last_reg_unit    = timelength - granularity*full_reg_units;
   last_reg_unit    = floor(last_reg_unit*10000)/10000;  % do away with rounding errors
   if last_reg_unit > 0, nreg_states = full_reg_units+1;
   else                  nreg_states = full_reg_units;
   end;
   
   full_legal_units = floor(legalskipout/granularity);  
   last_legal_unit  = legalskipout - granularity*full_legal_units;
   if last_legal_unit<0, last_legal_unit = 0; end;
   last_legal_unit  = floor(last_legal_unit*10000)/10000;  % do away with rounding errors
   if last_legal_unit > 0, nlegal_states = full_legal_units+1;
   else                    nlegal_states = full_legal_units;
   end;

   ps = penalty_state;
   ds = start + (nreg_states-1)*(nlegal_states+1) + 1;

   donestate = ds;

   stm = [];
   
   for i=1:nreg_states-1,
      b = start + size(stm,1);
      stm = [stm ;
             b  b+1    ps  ps   ps  ps    b+nlegal_states+1    granularity  0  0];  % add nreg unit's STM
         % Note: This is a mini state of unit granularity. 
         
          for j=1:nlegal_states-1 % The regular-sized legal poke-out states
             pokeback = start + (j-1)*(nlegal_states+1) + (i-1)*(nlegal_states+1);
             if pokeback <= start + (nreg_states-1)*(nlegal_states-1) % take care of timelength constraint
                stm = [stm ;
                       pokeback  b+j   ps  ps    ps  ps    b+j+1    granularity  0  0];
             else % We're done here-- but must end with poke back in!
                stm = [stm ; ds b+j   b+j b+j   b+j b+j   b+j+1 granularity  0 0];
             end;
          end;
          
      if last_legal_unit == 0, last_legal_time = granularity; % The final, leftovers legal poke-out state
      else                     last_legal_time = last_legal_unit;
      end;
      
      pokeback = start + (nlegal_states-1)*(nlegal_states+1);
      if pokeback <= start + (nreg_states-1)*(nlegal_states-1)
         stm = [stm ;
                pokeback  ps   ps  ps    ps  ps    ps  last_legal_unit  0  0];
      else % We're done here-- but must end with poke back in!
         b = start + size(stm,1);
         stm = [stm ; ds b   b b   b b   ps last_legal_unit  0 0];         
      end;
   end;
   if last_reg_unit == 0, last_reg_unit = granularity; end;
   b = start + size(stm,1);
   stm = [stm ;
          b ps   b b   b b   ds last_reg_unit  0  0];

   
   stm(1,10) = initial_trigger;
   return;
   
   

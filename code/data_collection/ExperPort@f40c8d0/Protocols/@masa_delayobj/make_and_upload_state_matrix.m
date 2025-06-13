function make_and_upload_state_matrix(obj, action)

GetSoloFunctionArgs;
% SoloFunction('make_and_upload_state_matrix', ...
%     'rw_args', 'RealTimeStates', ...
%     'ro_args', {'n_done_trials', 'ValveLeftSmall', 'ValveLeftLarge', ...
%     'ValveRightSmall', 'ValveRightLarge', ...
%     'DelayToReward', 'VpdList'...
%     'TrialLength', 'RewardAvailPeriod', 'RewardSide', 'CinTimeOut', 'CinToTout', ...
%     'Beginner1', 'BeginnerTup', 'C_ReEnter'});

%assign state number to state name
Wcpk = 0;
CpkS = 50;
SpkS = 55;
FpkS = 59; %fake cpoke state for beginner (who doesn't have to do Cpoke)
CpSm = 60;
SmAv = 65;
CpLa = 70;
LaAv = 75;
SmRw = 80;
LaRw = 85;
TO1  = 90;
TO2O = 100;
TO2I = 105;
TO2T = 110;
TO3I = 120;
TO3T = 125;

%Save state number
RealTimeStates.wait_for_cpoke  = [Wcpk];
RealTimeStates.cpoke           = [CpkS:CpkS+2 FpkS];
RealTimeStates.short_poke      = [SpkS:SpkS+3];
RealTimeStates.cpoke_small     = [CpSm:CpSm+3];
RealTimeStates.small_available = [SmAv:SmAv+3];
RealTimeStates.cpoke_large     = [CpLa:CpLa+3];
RealTimeStates.large_available = [LaAv:LaAv+3];
RealTimeStates.small_reward    = [SmRw:SmRw+1];
RealTimeStates.large_reward    = [LaRw:LaRw+1];
RealTimeStates.time_out1       = [TO1 TO1+1]; %time_out before state35
RealTimeStates.time_out2       = [36:38 TO2O:TO3T+2]; %time_out after state35
RealTimeStates.state35         = 35;

switch action,
    case 'init',
        
    case 'next_matrix',
%         % Everything fine, skip init and proceed to next section of function
    otherwise,
        error(['Don''t know how to handle action ' action]);
end;

%get digital output ID number
global left1water;
global right1water;

%pass value of SoloParamHandle to local value
l_sm     = ValveLeftSmall;
l_la     = ValveLeftLarge;
r_sm     = ValveRightSmall;
r_la     = ValveRightLarge;
rwdl     = DelayToReward;
vpds     = VpdList(1,n_done_trials+1);
avpd     = VpdList(2,n_done_trials+1)-vpds;
sm_tn    = 1; % tone index (see ChordSection)
la_tn    = 2; % tone index (see ChordSection)
sm_la    = 3; % tone index (see ChordSection)
% chord= 100; %chord index
noise_b = 111; %noise burst (short noise) index
noise =112;    %noise index
trial_length = TrialLength;
reward_avail = RewardAvailPeriod;
cin_timeout  = CinTimeOut;
cin_to_tout  = CinToTout;
jitter       = Jitter;

sylt = 512; %light to synchronize with video

switch value(RewardSide),
    case 'Left',
        wvid=left1water;
        side_port_idx=2;
        rwsm=l_sm;
        rwla=l_la;
    case 'Right',
        wvid=right1water;
        side_port_idx=3;
        rwsm=r_sm;
        rwla=r_la;
end;

%now make state matrix
stm = zeros(140,16);

%        Cin   Cout  Sin  Sout Al1in  Al2in Al3in Al4in  Tup  Timer  Dout Aout Altrig    
      
% State 35-37
stm(36,:) = [37 35   35   35   35   35  35    35   35  35  35  36  0.001 2^15 0  8]; %state35
stm(37,:) = [37 36   36   36   36   36  36    TO2O 36  36  36  36  10    0 0  0]; %state36 (outside)
stm(38,:) = [37 38   37   37   37   37  37    TO2I 37  37  37  37  10    0 0 -4]; %state37 (inside)
stm(39,:) = [37 38   38   38   38   38  36    TO2T 38  38  38  38  10    0 0  4]; %state38 (timeout for 2s)

        
%main matrix
stm(1,:) = ... %state0
   [CpkS   0      0      0      0      0      0      0      0      0      0      0     10     0    -noise  0]; %state0: Wcpk wait for C poke

if strcmp(value(Beginner1),'Yes'), %beginner1 doesn't have to do cpoke
    stm(1,12:13) = [FpkS value(BeginnerTup)];
end;

stm(CpkS+1:CpkS+3,:) = ... %state50 
   [CpkS   CpkS+2 CpkS   CpkS   CpkS   CpkS   CpkS   CpkS   CpSm   CpkS   CpkS   CpkS+1 0.001  0     0       16; ... %CpkS
    CpkS+1 CpkS+2 CpkS+1 CpkS+1 CpkS+1 CpkS+1 CpkS+1 CpkS+1 CpSm   CpkS+1 CpkS+1 CpkS+1 10     0     0      -64; ...
    CpkS+1 CpkS+2 CpkS+2 CpkS+2 CpkS+2 CpkS+2 CpkS+2 CpkS+2 CpSm+2 CpkS+2 SpkS   CpkS+2 10     0     0       64];

if jitter == 0,
    stm(CpkS+1, [2 12 13 16]) = [SpkS CpSm vpds 0];
end;

stm(SpkS+1:SpkS+4,:) = ... %state55
   [SpkS+2 SpkS   SpkS   SpkS   SpkS   TO1    SpkS   SpkS   SpkS   SpkS   SpkS   SpkS+1 0.001  0     0        2; ... %short poke
    SpkS+2 SpkS+1 SpkS+1 SpkS+1 SpkS+1 TO1    SpkS+1 SpkS+1 SpkS+1 SpkS+1 SpkS+1 SpkS+1 10     0     0       -16; ... 
    SpkS+2 SpkS+2 SpkS+2 SpkS+2 SpkS+2 TO1    SpkS+2 SpkS+2 SpkS+2 SpkS+2 SpkS+2 SpkS+3 0.001  0    -noise_b -16; ... %just for tone_off c_reenter
    SpkS+2 SpkS+3 SpkS+3 SpkS+3 SpkS+3 TO1    SpkS+3 SpkS+3 SpkS+3 SpkS+3 SpkS+3 SpkS+1 0.001  0     noise_b  0];  %c_reenter

stm(FpkS+1, :) = ... %state59
   [FpkS  FpkS   FpkS   FpkS   FpkS   FpkS   FpkS   FpkS   FpkS   FpkS   FpkS   LaAv   0.001  0     sm_la    0];  %fake cpoke state for beginner (who doesn't have to do cpoke)

stm(CpSm+1:CpSm+4,:) = ... %state60 
   [CpSm   CpSm+3 CpSm   CpSm   CpSm   CpSm   CpSm   CpSm   CpSm   CpLa   CpSm   CpSm+1 0.001  0     sm_tn   32; ... %cpoke_small
    CpSm+1 CpSm+3 CpSm+1 CpSm+1 CpSm+1 CpSm+1 CpSm+1 CpSm+1 CpSm+1 CpLa   CpSm+1 CpSm+1 10     0     0      -64; ...
    CpSm+1 CpSm+2 CpSm+2 CpSm+2 CpSm+2 CpSm+2 CpSm+2 CpSm+2 CpSm+2 CpLa+2 SmAv   CpSm+2 10     0     sm_tn   32; ...
    CpSm+1 CpSm+3 CpSm+3 CpSm+3 CpSm+3 CpSm+3 CpSm+3 CpSm+3 CpSm+3 CpLa+2 SmAv   CpSm+3 10     0     0       64];

if jitter == 0,
    stm(CpSm+1, [2 12 13 16]) = [SmAv CpLa avpd 0];
end;

stm(SmAv+1:SmAv+4,:) = ... %state65 
   [SmAv+2 SmAv   SmRw   SmAv   SmAv   TO1    SmAv   SmAv   SmAv   SmAv   SmAv   SmAv+1 0.001  0     0        2; ... %small_available
    SmAv+2 SmAv+1 SmRw   SmAv+1 SmAv+1 TO1    SmAv+1 SmAv+1 SmAv+1 SmAv+1 SmAv+1 SmAv+1 10     0     0       -32;
    SmAv+2 SmAv+2 SmAv+2 SmAv+2 SmAv+2 TO1    SmAv+2 SmAv+2 SmAv+2 SmAv+2 SmAv+2 SmAv+3 0.001  0    -noise_b -32; ... %just for tone_off c_reenter
    SmAv+2 SmAv+3 SmAv+3 SmAv+3 SmAv+3 TO1    SmAv+3 SmAv+3 SmAv+3 SmAv+3 SmAv+3 SmAv+1 0.001  0     noise_b  0];  %c_reenter

stm(CpLa+1:CpLa+4,:) = ... %state70
   [CpLa   CpLa+3 CpLa   CpLa   CpLa   CpLa   CpLa   CpLa   CpLa   CpLa   CpLa   CpLa+1 0.001  0     la_tn    0; ... %cpoke_large
    CpLa+1 CpLa+3 CpLa+1 CpLa+1 CpLa+1 CpLa+1 CpLa+1 CpLa+1 CpLa+1 CpLa+1 CpLa+1 CpLa+1 10     0     0      -64; ...
    CpLa+1 CpLa+2 CpLa+2 CpLa+2 CpLa+2 CpLa+2 CpLa+2 CpLa+2 CpLa+2 CpLa+2 LaAv   CpLa+2 10     0     la_tn    0; ...
    CpLa+1 CpLa+3 CpLa+3 CpLa+3 CpLa+3 CpLa+3 CpLa+3 CpLa+3 CpLa+3 CpLa+3 LaAv   CpLa+3 10     0     0       64];

if jitter == 0,
    stm(CpLa+1, [2 12 13]) = [LaAv CpLa 10];
end;

stm(LaAv+1:LaAv+4,:) = ... %state75 
   [LaAv+2 LaAv   LaRw   LaAv   LaAv   TO1    LaAv   LaAv   LaAv   LaAv   LaAv   LaAv+1 0.001  0     0        2; ... %large_available (just to make it the same as SmAv)
    LaAv+2 LaAv+1 LaRw   LaAv+1 LaAv+1 TO1    LaAv+1 LaAv+1 LaAv+1 LaAv+1 LaAv+1 LaAv+1 10     0     0        0; ... %large_available
    LaAv+2 LaAv+2 LaAv+2 LaAv+2 LaAv+2 TO1    LaAv+2 LaAv+2 LaAv+2 LaAv+2 LaAv+2 LaAv+3 0.001  0    -noise_b  0; ... %just for tone_off c_reenter
    LaAv+2 LaAv+3 LaAv+3 LaAv+3 LaAv+3 TO1    LaAv+3 LaAv+3 LaAv+3 LaAv+3 LaAv+3 LaAv+1 0.001  0     noise_b  0];  %c_reenter

if strcmp(value(C_ReEnter), 'Go2Cpks'), %for beginner; ##if Go2CpkS, you can't use {jitter>0}
    stm([SpkS+1 SmAv+1 LaAv+1], 1)=CpkS;
    stm([SpkS+1 SmAv+1 LaAv+1], 12)=[SpkS+1 SmAv+1 LaAv+1];
    stm([SpkS+1 SmAv+1 LaAv+1], 13)=10;
    stm(CpkS+2, 16)=-2; %delete sched wave for RewardAvailablePeriod
elseif strcmp(value(C_ReEnter), 'NoReward'), %for bad rats (add Nov/13/06, mod Apr/30/07)
    stm([SpkS+4 SmAv+4 LaAv+4], 13)= ...
        [0;
         0;
         0];
end;
    
% state_matrix for reward
stm(SmRw+1:SmRw+2,:) = ... %state80
   [SmRw   SmRw   SmRw   SmRw   SmRw   SmRw   SmRw   SmRw   SmRw   SmRw   SmRw   SmRw+1 rwdl    sylt -noise_b 0; %InsideWaterPort
    SmRw+1 SmRw+1 SmRw+1 SmRw+1 SmRw+1 SmRw+1 SmRw+1 SmRw+1 SmRw+1 SmRw+1 SmRw+1 TO1    rwsm    wvid 0       0];
if rwsm<=0, stm(SmRw+1,12)=TO1;end;

stm(LaRw+1:LaRw+2,:) = ... %state85
   [LaRw   LaRw   LaRw   LaRw   LaRw   LaRw   LaRw   LaRw   LaRw   LaRw   LaRw   LaRw+1 rwdl    sylt -noise_b 0; %InsideWaterPort
    LaRw+1 LaRw+1 LaRw+1 LaRw+1 LaRw+1 LaRw+1 LaRw+1 LaRw+1 LaRw+1 LaRw+1 LaRw+1 TO1    rwla    wvid 0       0];
    
if rwla<=0, stm(LaRw+1,12)=TO1;end;

%state_matrix for time out state
%play sched wave (3s) for state 35 computation, turn off noise_b and play noise
stm(TO1+1:TO1+2,:) = ... %state90
   [TO1    TO1    TO1    TO1    TO1    TO1    TO1    TO1    TO1    TO1    TO1    TO1+1  0.001   0   -noise_b 0; 
    TO1+1  TO1+1  TO1+1  TO1+1  TO1+1  TO1+1  TO1+1  TO1+1  TO1+1  TO1+1  TO1+1  35     0.001   0     noise  0]; 

%time out after first 3s time out elapsed (Cout)
%play sched wave for fixed trial length (Trial length - CinToTout),
%continue playing noise(3s) and sched wave (3s)
stm(TO2O+1:TO2O+3,:) = ... %state100-102:
   [TO2I+2 TO2O   TO2O   TO2O   35     TO2O   TO2O   TO2O   TO2O   TO2O   TO2O   TO2O+1 0.001  0     0      1; %send sched time for fixed trial length (Cout)
    TO2I+3 TO2O+1 TO2O+1 TO2O+1 35     TO2O+1 TO2O+1 TO2O+1 TO2O+1 TO2O+1 TO2O+1 TO2O+2 0.001  0     noise  8; %send sched wave (3s) and play noise(3s)  (Cout)
    TO2I+3 TO2O+2 TO2O+2 TO2O+2 35     TO2O+2 TO2O+2 TO2O+1 TO2O+2 TO2O+2 TO2O+2 TO2O+2 10     0     0      0]; %wait for 3s sched wave (Cout)

%time out after first 3s time out elapsed (Cin)
%play sched wave for fixed trial length (Trial length - CinToTout),
%continue playing noise(3s) and sched wave (3s)
stm(TO2I+1:TO2I+4,:) = ... %state105-108:
   [TO2I   TO2T+1 TO2I   TO2I   TO3I+1 TO2I   TO2I   TO2I   TO2I   TO2I   TO2I   TO2I+2 0.001  0     0      1; %send sched time for fixed trial length (Cin) 
    TO2I+1 TO2T+1 TO2I+1 TO2I+1 TO3I+1 TO2I+1 TO2I+1 TO2I+1 TO2I+1 TO2I+1 TO2I+1 TO2I+2 0.001  0     0     -4; % 
    TO2I+2 TO2T+3 TO2I+2 TO2I+2 TO3I   TO2I+2 TO2I+2 TO2I+2 TO2I+2 TO2I+2 TO2I+2 TO2I+3 0.001  0     noise  8; %send sched wave (3s) and play noise(3s)  (Cin)
    TO2I+3 TO2T+3 TO2I+3 TO2I+3 TO3I   TO2I+3 TO2I+3 TO2I+2 TO2I+3 TO2I+3 TO2I+3 TO2I+3 10     0     0     -4];%wait for 3s sched wave (Cin)

%time out after first 3s time out elapsed (Tout2s)
%play sched wave for fixed trial length (Trial length - CinToTout),
%continue playing noise(3s) and sched wave (3s)
stm(TO2T+1:TO2T+4,:) = ... %state110-113:
   [TO2I+1 TO2T   TO2T   TO2T   TO3T+1 TO2T   TO2O+1 TO2T   TO2T   TO2T   TO2T   TO2T+2 0.001  0     0      1; %send sched time for fixed trial length (Cin) 
    TO2I+1 TO2T+1 TO2T+1 TO2T+1 TO3T+1 TO2T+1 TO2O+1 TO2T+1 TO2T+1 TO2T+1 TO2T+1 TO2T+2 0.001  0     0      4; % 
    TO2I+3 TO2T+2 TO2T+2 TO2T+2 TO3T   TO2T+2 TO2O+2 TO2T+2 TO2T+2 TO2T+2 TO2T+2 TO2T+2 10     0     noise  8; %send sched wave (3s) and play noise(3s)  (Cin)
    TO2I+3 TO2T+3 TO2T+3 TO2T+3 TO3T   TO2T+3 TO2O+2 TO2T+2 TO2T+3 TO2T+3 TO2T+3 TO2T+3 10     0     0      4];%wait for 3s sched wave (Cin)

%time out after sched wave for fixed trial length is played and a rat is
%still inside the Cpoke (waiting for cout)
stm(TO3I+1:TO3I+2,:) = ... %state120-121:
   [TO3I   TO3T+2 TO3I   TO3I   TO3I   TO3I   TO3I   TO3I+1 TO3I   TO3I   TO3I   TO3I   10     0     0     -4; ...
    TO3I+1 TO3T+2 TO3I+1 TO3I+1 TO3I+1 TO3I+1 TO3I+1 TO3I+1 TO3I+1 TO3I+1 TO3I+1 TO3I   0.001  0     noise  8];

%time out after sched wave for fixed trial length is played and a rat is
%still TimeOut2s state (waiting for timeout being elapsed)
stm(TO3T+1:TO3T+3,:) = ... %state125-127:
   [TO3I   TO3T   TO3T   TO3T   TO3T   TO3T   35     TO3T+1 TO3T   TO3T   TO3T   TO3T   10     0     0      0; ...
    TO3I   TO3T+1 TO3T+1 TO3T+1 TO3T+1 TO3T+1 35     TO3T+1 TO3T+1 TO3T+1 TO3T+1 TO3T+1 10     0     noise  8; ...
    TO3I   TO3T+2 TO3T+2 TO3T+2 TO3T+2 TO3T+2 35     TO3T+1 TO3T+2 TO3T+2 TO3T+2 TO3T+2 10     0     0      4];

if n_done_trials<=0 %after TO_2 immediately go to Wcpk 
    sched_wave_pre=0.001;
elseif cin_to_tout(n_done_trials)>=trial_length-3-0.001, 
    %-0.001 for sure %after TO_2 immediately go to Wcpk 
    stm(TO2O+1,12)=35;
    stm(TO2I+1,2)=TO3T+2;
    stm(TO2I+1,12)=TO3I+1;
    stm(TO2T+1,1)=TO3I;
    stm(TO2T+1,7)=35;
    stm(TO2T+1,12)=TO3T+1;
    sched_wave_pre=0.001; %no effect
else, %spend remaining time out in (TO2O ~) state
    sched_wave_pre=trial_length-3-cin_to_tout(n_done_trials);
end;

% store for posterity
if ~exist('state_matrix', 'var'),
    SoloParamHandle(obj, 'state_matrix');
end;

state_matrix.value = stm;

fsm = rpbox('getstatemachine');
%SetScheduledWaves(machine, [trig_id(2^id for use) alin_col alout_col(-1:none) dioline(-1:none) pre on refrac])
fsm = SetScheduledWaves(fsm, ...
    [0 4  -1 -1 sched_wave_pre 0.00 0.00; ... %sched_wave for fixed trial length
     1 5  -1 -1 reward_avail   0.00 0.00; ... %and RewardAvailability Time Out
     2 6  -1 -1 cin_timeout    0.00 0.00; ... %sched wave for 2s count
     3 7  -1 -1 3              0.00 0.00; ... %sched wave for 3s count
     4 8  -1 -1 vpds           0.00 0.00; ... %sched wave for 1st tone
     5 9  -1 -1 avpd           0.00 0.00; ... %sched wave for 2nd tone
     6 10 -1 -1 jitter         0.00 0.00; ... %sched wave for jitter
     ]);   
     
fsm = SetInputEvents(fsm, [1 -1 side_port_idx -side_port_idx 0 0 0 0 0 0 0], 'ai'); %'0' for virtual inputs (sched wave inputs)
fsm = SetOutputRouting(fsm, { struct('type', 'dout', 'data', '0-15') ; ...
    struct('type', 'sound', 'data', '0') ; ...
    struct('type', 'sched_wave', 'data', '')});
fsm = SetStateMatrix(fsm, stm);
fsm = rpbox('setstatemachine', fsm);

% Store the latest RealTimeStates
push_history(RealTimeStates);

return;

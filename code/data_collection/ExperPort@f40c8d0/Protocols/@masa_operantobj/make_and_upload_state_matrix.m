function make_and_upload_state_matrix(obj, action)

GetSoloFunctionArgs;
% SoloFunction('make_and_upload_state_matrix', ...
%     'rw_args', 'RealTimeStates', ...
%     'ro_args', {'n_done_trials', 'ValveLeftSmall', 'ValveLeftLarge', ...
%     'ValveRightSmall', 'ValveRightLarge', ...
%     'DelayToReward', 'VpdList'...
%     'TrialLength', 'RewardAvailPeriod', 'CinTimeOut', 'CinToTout', ...
%     'Beginner1', 'BeginnerTup', 'C_ReEnter'});

%assign state number to state name
Wcpk = 0;
CpkS = 50;
SpkS = 51;
FpkS = 55; %fake cpoke state for beginner (who doesn't have to do Cpoke)
CpSm = 60;
SmAv = 61;
CpLa = 70;
LaAv = 71;
SLRw = 80;
SRRw = 82;
LLRw = 85;
LRRw = 87;
TO1  = 90;
TO2O = 100;
TO2I = 105;
TO2T = 110;
TO3I = 120;
TO3T = 125;

%Save state number
RealTimeStates.wait_for_cpoke  = [Wcpk];
RealTimeStates.cpoke           = [CpkS FpkS];
RealTimeStates.short_poke      = [SpkS:SpkS+2];
RealTimeStates.cpoke_small     = [CpSm];
RealTimeStates.small_available = [SmAv:SmAv+2];
RealTimeStates.cpoke_large     = [CpLa];
RealTimeStates.large_available = [LaAv:LaAv+2];
RealTimeStates.small_reward    = [SLRw SLRw+1 SRRw SRRw+1];
RealTimeStates.large_reward    = [LLRw:LLRw+1 LRRw LRRw+1];
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

lvid = left1water;
rvid = right1water;

% switch value(RewardSide),
%     case 'Left',
%         wvid=left1water;
%         side_port_idx=2;
%         rwsm=l_sm;
%         rwla=l_la;
%     case 'Right',
%         wvid=right1water;
%         side_port_idx=3;
%         rwsm=r_sm;
%         rwla=r_la;
% end;

%now make state matrix
stm = zeros(140,15);

%        Cin   Cout  Lin  Lout Al1in  Al2in Al3in Al4in  Tup  Timer  Dout Aout Altrig    
      
% State 35-37
stm(36,:) = [37 35   35   35   35   35   35   35  35    35   36  0.001 0 0  8]; %state35
stm(37,:) = [37 36   36   36   36   36   36   36  36    TO2O 36  10    0 0  0]; %state36 (outside)
stm(38,:) = [37 38   37   37   37   37   37   37  37    TO2I 37  10    0 0 -4]; %state37 (inside)
stm(39,:) = [37 38   38   38   38   38   38   38  36    TO2T 38  10    0 0  4]; %state38 (timeout for 2s)

        
%main matrix
stm(1,:) = ... %state0
   [CpkS   0      0      0      0      0      0      0      0      0      0      10     0    -noise  0]; %state0: Wcpk wait for C poke

if strcmp(value(Beginner1),'Yes'), %beginner1 doesn't have to do cpoke
    stm(1,11:12) = [FpkS value(BeginnerTup)];
end;

stm(CpkS+1:CpkS+4,:) = ... %state50 
   [CpkS   SpkS   CpkS   CpkS   CpkS   CpkS   CpkS   CpkS   CpkS   CpkS   CpSm   vpds   0     0       -2; ... %CpkS
    SpkS+1 SpkS   SpkS   SpkS   SpkS   SpkS   SpkS   TO1    SpkS   SpkS   SpkS   10     0     0        2; ... %short poke
    SpkS+1 SpkS+1 SpkS+1 SpkS+1 SpkS+1 SpkS+1 SpkS+1 TO1    SpkS+1 SpkS+1 SpkS+2 0.001  0     -noise_b 0; ... %just for tone_off c_reenter
    SpkS+2 SpkS   SpkS+2 SpkS+2 SpkS+2 SpkS+2 SpkS+2 TO1    SpkS+2 SpkS+2 SpkS+2 10     0     noise_b  0];  %c_reenter

stm(FpkS+1, :) = ... %state55
    [FpkS  FpkS   FpkS   FpkS   FpkS   FpkS   FpkS   FpkS   FpkS   FpkS   LaAv   0.001  0     sm_la    0];  %fake cpoke state for beginner (who doesn't have to do cpoke)

stm(CpSm+1:CpSm+4,:) = ... %state60 
   [CpSm   SmAv   CpSm   CpSm   CpSm   CpSm   CpSm   CpSm   CpSm   CpSm   CpLa   avpd   0     sm_tn    0; ... %cpoke_small
    SmAv+1 SmAv   SLRw   SmAv   SRRw   SmAv   SmAv   TO1    SmAv   SmAv   SmAv   10     0     0        2; ... %small_available
    SmAv+1 SmAv+1 SmAv+1 SmAv+1 SmAv+1 SmAv+1 SmAv+1 TO1    SmAv+1 SmAv+1 SmAv+2 0.001  0     -noise_b 0; ... %just for tone_off c_reenter
    SmAv+2 SmAv   SmAv+2 SmAv+2 SmAv+2 SmAv+2 SmAv+2 TO1    SmAv+2 SmAv+2 SmAv+2 10     0     noise_b  0];  %c_reenter

stm(CpLa+1:CpLa+4,:) = ... %state70
   [CpLa   LaAv   CpLa   CpLa   CpLa   CpLa   CpLa   CpLa   CpLa   CpLa   CpLa   10     0     la_tn    0; ... %cpoke_large
    LaAv+1 LaAv   LLRw   LaAv   LRRw   LaAv   LaAv   TO1    LaAv   LaAv   LaAv   10     0     0        2; ... %large_available
    LaAv+1 LaAv+1 LaAv+1 LaAv+1 LaAv+1 LaAv+1 LaAv+1 TO1    LaAv+1 LaAv+1 LaAv+2 0.001  0     -noise_b 0; ... %just for tone_off c_reenter
    LaAv+2 LaAv   LaAv+2 LaAv+2 LaAv+2 LaAv+2 LaAv+2 TO1    LaAv+2 LaAv+2 LaAv+2 10     0     noise_b  0];  %c_reenter

if strcmp(value(C_ReEnter), 'Go2Cpks'), %for beginner
    stm([SpkS+1 SmAv+1 LaAv+1], 1)=CpkS;
    stm(CpkS+1, 14)=-2; %delete sched wave for RewardAvailablePeriod
elseif strcmp(value(C_ReEnter), 'NoReward'), %for bad rats (add Nov 13)
    stm([SpkS+3 SmAv+3 LaAv+3], [1:2])= ...
        [SpkS+1 SpkS+2;
         SmAv+1 SmAv+2;
         LaAv+1 LaAv+2];
end;
    
% state_matrix for reward
%small at left (SL)
stm(SLRw+1:SLRw+2,:) = ... %state80
   [SLRw   SLRw   SLRw   SLRw   SLRw   SLRw   SLRw   SLRw   SLRw   SLRw   SLRw+1 rwdl    0   -noise_b 0; %InsideWaterPort
    SLRw+1 SLRw+1 SLRw+1 SLRw+1 SLRw+1 SLRw+1 SLRw+1 SLRw+1 SLRw+1 SLRw+1 TO1    l_sm    lvid 0       0];
if l_sm<=0, stm(SLRw+1,11)=TO1;end;

%small at right (SR)
stm(SRRw+1:SRRw+2,:) = ... %state82
   [SRRw   SRRw   SRRw   SRRw   SRRw   SRRw   SRRw   SRRw   SRRw   SRRw   SRRw+1 rwdl    0   -noise_b 0; %InsideWaterPort
    SRRw+1 SRRw+1 SRRw+1 SRRw+1 SRRw+1 SRRw+1 SRRw+1 SRRw+1 SRRw+1 SRRw+1 TO1    r_sm    rvid 0       0];
if r_sm<=0, stm(SRRw+1,11)=TO1;end;

%large at left (LL)
stm(LLRw+1:LLRw+2,:) = ... %state85
   [LLRw   LLRw   LLRw   LLRw   LLRw   LLRw   LLRw   LLRw   LLRw   LLRw   LLRw+1 rwdl    0   -noise_b 0; %InsideWaterPort
    LLRw+1 LLRw+1 LLRw+1 LLRw+1 LLRw+1 LLRw+1 LLRw+1 LLRw+1 LLRw+1 LLRw+1 TO1    l_la    lvid 0       0];    
if l_la<=0, stm(LLRw+1,11)=TO1;end;

%large at right (LR)
stm(LRRw+1:LRRw+2,:) = ... %state85
   [LRRw   LRRw   LRRw   LRRw   LRRw   LRRw   LRRw   LRRw   LRRw   LRRw   LRRw+1 rwdl    0   -noise_b 0; %InsideWaterPort
    LRRw+1 LRRw+1 LRRw+1 LRRw+1 LRRw+1 LRRw+1 LRRw+1 LRRw+1 LRRw+1 LRRw+1 TO1    r_la    rvid 0       0];
if r_la<=0, stm(LRRw+1,11)=TO1;end;

%state_matrix for time out state
%play sched wave (3s) for state 35 computation, turn off noise_b and play noise
stm(TO1+1:TO1+2,:) = ... %state90
   [TO1    TO1    TO1    TO1    TO1    TO1    TO1    TO1    TO1    TO1    TO1+1  0.001  0   -noise_b 8; 
    TO1+1  TO1+1  TO1+1  TO1+1  TO1+1  TO1+1  TO1+1  TO1+1  TO1+1  TO1+1  35     0.001  0     noise  0]; 

%time out after first 3s time out elapsed (Cout)
%play sched wave for fixed trial length (Trial length - CinToTout),
%continue playing noise(3s) and sched wave (3s)
stm(TO2O+1:TO2O+3,:) = ... %state100-102:
   [TO2I+2 TO2O   TO2O   TO2O   TO2O   TO2O   35     TO2O   TO2O   TO2O   TO2O+1 0.001  0     0      1; %send sched time for fixed trial length (Cout)
    TO2I+3 TO2O+1 TO2O+1 TO2O+1 TO2O+1 TO2O+1 35     TO2O+1 TO2O+1 TO2O+1 TO2O+2 0.001  0     noise  8; %send sched wave (3s) and play noise(3s)  (Cout)
    TO2I+3 TO2O+2 TO2O+2 TO2O+2 TO2O+2 TO2O+2 35     TO2O+2 TO2O+2 TO2O+1 TO2O+2 10     0     0      0]; %wait for 3s sched wave (Cout)

%time out after first 3s time out elapsed (Cin)
%play sched wave for fixed trial length (Trial length - CinToTout),
%continue playing noise(3s) and sched wave (3s)
stm(TO2I+1:TO2I+4,:) = ... %state105-108:
   [TO2I   TO2T+1 TO2I   TO2I   TO2I   TO2I   TO3I+1 TO2I   TO2I   TO2I   TO2I+2 0.001  0     0      1; %send sched time for fixed trial length (Cin) 
    TO2I+1 TO2T+1 TO2I+1 TO2I+1 TO2I+1 TO2I+1 TO3I+1 TO2I+1 TO2I+1 TO2I+1 TO2I+2 0.001  0     0     -4; % 
    TO2I+2 TO2T+3 TO2I+2 TO2I+2 TO2I+2 TO2I+2 TO3I   TO2I+2 TO2I+2 TO2I+2 TO2I+3 0.001  0     noise  8; %send sched wave (3s) and play noise(3s)  (Cin)
    TO2I+3 TO2T+3 TO2I+3 TO2I+3 TO2I+3 TO2I+3 TO3I   TO2I+3 TO2I+3 TO2I+2 TO2I+3 10     0     0     -4];%wait for 3s sched wave (Cin)

%time out after first 3s time out elapsed (Tout2s)
%play sched wave for fixed trial length (Trial length - CinToTout),
%continue playing noise(3s) and sched wave (3s)
stm(TO2T+1:TO2T+4,:) = ... %state110-113:
   [TO2I+1 TO2T   TO2T   TO2T   TO2T   TO2T   TO3T+1 TO2T   TO2O+1 TO2T   TO2T+2 0.001  0     0      1; %send sched time for fixed trial length (Cin) 
    TO2I+1 TO2T+1 TO2T+1 TO2T+1 TO2T+1 TO2T+1 TO3T+1 TO2T+1 TO2O+1 TO2T+1 TO2T+2 0.001  0     0      4; % 
    TO2I+3 TO2T+2 TO2T+2 TO2T+2 TO2T+2 TO2T+2 TO3T   TO2T+2 TO2O+2 TO2T+2 TO2T+2 10     0     noise  8; %send sched wave (3s) and play noise(3s)  (Cin)
    TO2I+3 TO2T+3 TO2T+3 TO2T+3 TO2T+3 TO2T+3 TO3T   TO2T+3 TO2O+2 TO2T+2 TO2T+3 10     0     0      4];%wait for 3s sched wave (Cin)

%time out after sched wave for fixed trial length is played and a rat is
%still inside the Cpoke (waiting for cout)
stm(TO3I+1:TO3I+2,:) = ... %state120-121:
   [TO3I   TO3T+2 TO3I   TO3I   TO3I   TO3I   TO3I   TO3I   TO3I   TO3I+1 TO3I   10     0     0     -4; ...
    TO3I+1 TO3T+2 TO3I+1 TO3I+1 TO3I+1 TO3I+1 TO3I+1 TO3I+1 TO3I+1 TO3I+1 TO3I   0.001  0     noise  8];

%time out after sched wave for fixed trial length is played and a rat is
%still TimeOut2s state (waiting for timeout being elapsed)
stm(TO3T+1:TO3T+3,:) = ... %state125-127:
   [TO3I   TO3T   TO3T   TO3T   TO3T   TO3T   TO3T   TO3T   35     TO3T+1 TO3T   10     0     0      0; ...
    TO3I   TO3T+1 TO3T+1 TO3T+1 TO3T+1 TO3T+1 TO3T+1 TO3T+1 35     TO3T+1 TO3T+1 0.001  0     noise  8; ...
    TO3I   TO3T+2 TO3T+2 TO3T+2 TO3T+2 TO3T+2 TO3T+2 TO3T+2 35     TO3T+1 TO3T+2 10     0     0      4];

if n_done_trials<=0 %after TO_2 immediately go to Wcpk 
    sched_wave_pre=0.001;
elseif cin_to_tout(n_done_trials)>=trial_length-3-0.001, 
    %-0.001 for sure %after TO_2 immediately go to Wcpk 
    stm(TO2O+1,11)=35;
    stm(TO2I+1,2)=TO3T+2;
    stm(TO2I+1,11)=TO3I+1;
    stm(TO2T+1,1)=TO3I;
    stm(TO2T+1,9)=35;
    stm(TO2T+1,11)=TO3T+1;
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
    [0 6 -1 -1 sched_wave_pre 0.00 0.00; ... %sched_wave for fixed trial length
     1 7 -1 -1 reward_avail   0.00 0.00; ... %and RewardAvailability Time Out
     2 8 -1 -1 cin_timeout    0.00 0.00; ... %sched wave for 2s count
     3 9 -1 -1 3              0.00 0.00]);   %sched wave for 3s count
     
fsm = SetInputEvents(fsm, [1 -1 2 -2 3 -3 0 0 0 0], 'ai'); %'0' for virtual inputs (sched wave inputs)
fsm = SetOutputRouting(fsm, { struct('type', 'dout', 'data', '0-15') ; ...
    struct('type', 'sound', 'data', '0') ; ...
    struct('type', 'sched_wave', 'data', '')});
fsm = SetStateMatrix(fsm, stm);
fsm = rpbox('setstatemachine', fsm);

% Store the latest RealTimeStates
push_history(RealTimeStates);

return;

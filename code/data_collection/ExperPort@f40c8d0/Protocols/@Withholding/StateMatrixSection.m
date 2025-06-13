
function  [] =  StateMatrixSection(obj, action)

global center1water left1water right1water ephys_sync video_sync left1led right1led 

GetSoloFunctionArgs;

%Pass other sections' SPHs to local variables

DELAY_TO_REWARD = value(DelayToReward);
CENTER_SMALL_REWARD = value(CenterSmall);
CENTER_LARGE_REWARD = value(CenterLarge);
LEFT_SMALL_REWARD = value(LeftSmall);
LEFT_LARGE_REWARD = value(LeftLarge);
RIGHT_SMALL_REWARD = value(RightSmall);
RIGHT_LARGE_REWARD = value(RightLarge);
ID_TONE_SMALL = value(IdToneSmall);
ID_TONE_LARGE = value(IdToneLarge);
ID_TONE_SMALL_LARGE = value(IdToneSmallLarge);
ID_NOISE = value(IdNoise);
ID_NOISE_BURST = value(IdNoiseBurst);

VALID_POKE_DURATION_1_N = value(VpdSmall_Current_N);
VALID_POKE_DURATION_2_N =value(VpdCue_N);
VALID_POKE_DURATION_3_N = value(VpdRest_N);

VALID_POKE_DURATION_1_L = value(VpdSmall_Current_L);
VALID_POKE_DURATION_2_L = value(VpdLarge_Current_L) - value(VpdSmall_Current_L);
VALID_POKE_DURATION_3_L = value(VpdLarge_Current_L) - value(VpdSmall_Current_L);
BLOCK_NAME = value(BlockName); %1:'NosePoke' or 0:'LeverPress'

WAIT_POKE_NECESSARY = value(WaitPokeNecessary); %'Yes' or 'No'
TIME_TO_FAKE_POKE = value(TimeToFakePoke);
MULTI_POKE = value(MultiPoke); %valid_waiting, just_noiseB', 'no_reward'
REWARD_AVAIL_PERIOD = value(RewardAvailPeriod);
ITI_POKE_TIMEOUT = value(ITIPokeTimeOut);
MULTI_POKE_TOLERANCE = value(MultiPokeTolerance);
TRIAL_LENGTH_CONSTANT = value(TrialLengthConstant);
TRIAL_LENGTH = value(TrialLength);

switch value(PortAssign),
case 'NP-C;Rew-Both'
    NOSE_POKE_IN = 'Cin';
    NOSE_POKE_OUT = 'Cout';
    LEVER_PRESS_IN = ''; %not used
    LEVER_PRESS_OUT = ''; %not used
    REWARD_PORT = 'Both';
case 'NP-C;Rew-L'
    NOSE_POKE_IN = 'Cin';
    NOSE_POKE_OUT = 'Cout';
    LEVER_PRESS_IN = ''; %not used
    LEVER_PRESS_OUT = ''; %not used
    REWARD_PORT = 'Left';
case 'NP-C;Rew-R'
    NOSE_POKE_IN = 'Cin';
    NOSE_POKE_OUT = 'Cout';
    LEVER_PRESS_IN = ''; %not used
    LEVER_PRESS_OUT = ''; %not used
    REWARD_PORT = 'Right';
case 'LP-C;Rew-Both'
    NOSE_POKE_IN = ''; %not used
    NOSE_POKE_OUT = ''; %not used
    LEVER_PRESS_IN = 'Cin'; 
    LEVER_PRESS_OUT = 'Cout'; 
    REWARD_PORT = 'Both';
case 'LP-C;Rew-L'
    NOSE_POKE_IN = ''; %not used
    NOSE_POKE_OUT = ''; %not used
    LEVER_PRESS_IN = 'Cin'; 
    LEVER_PRESS_OUT = 'Cout'; 
    REWARD_PORT = 'Left';
case 'LP-C;Rew-R'
    NOSE_POKE_IN = ''; %not used
    NOSE_POKE_OUT = ''; %not used
    LEVER_PRESS_IN = 'Cin'; 
    LEVER_PRESS_OUT = 'Cout'; 
    REWARD_PORT = 'Right';
case 'NP-L;Rew-C'
    NOSE_POKE_IN = 'Lin';
    NOSE_POKE_OUT = 'Lout';
    LEVER_PRESS_IN = ''; 
    LEVER_PRESS_OUT = '';
    REWARD_PORT = 'Center';
case 'NP-R;Rew-C'
    NOSE_POKE_IN = 'Rin';
    NOSE_POKE_OUT = 'Rout';
    LEVER_PRESS_IN = ''; 
    LEVER_PRESS_OUT = '';
    REWARD_PORT = 'Center';
case 'LP-L;Rew-C'
    NOSE_POKE_IN = '';
    NOSE_POKE_OUT = '';
    LEVER_PRESS_IN = 'Lin'; 
    LEVER_PRESS_OUT = 'Lout';
    REWARD_PORT = 'Center';
case 'LP-R;Rew-C'
    NOSE_POKE_IN = '';
    NOSE_POKE_OUT = '';
    LEVER_PRESS_IN = 'Rin'; 
    LEVER_PRESS_OUT = 'Rout';
    REWARD_PORT = 'Center';
case 'NP-L;LP-R;Rew-C'
    NOSE_POKE_IN = 'Lin';
    NOSE_POKE_OUT = 'Lout';
    LEVER_PRESS_IN = 'Rin'; 
    LEVER_PRESS_OUT = 'Rout';
    REWARD_PORT = 'Center';
case 'NP-R;LP-L;Rew-C'
    NOSE_POKE_IN = 'Rin';
    NOSE_POKE_OUT = 'Rout';
    LEVER_PRESS_IN = 'Lin'; 
    LEVER_PRESS_OUT = 'Lout';
    REWARD_PORT = 'Center';
otherwise
    error('don''t know this parameter %s', value(PortAssign));
end;

if ~isempty(NOSE_POKE_IN)&&~isempty(LEVER_PRESS_IN),
    WAIT_IN_STATE_CHANGE = {NOSE_POKE_IN,'waiting1_np', ...
                            LEVER_PRESS_IN,'waiting1_lp'};
elseif ~isempty(NOSE_POKE_IN)&&isempty(LEVER_PRESS_IN),
    WAIT_IN_STATE_CHANGE = {NOSE_POKE_IN,'waiting1_np'};
elseif isempty(NOSE_POKE_IN)&&~isempty(LEVER_PRESS_IN),
    WAIT_IN_STATE_CHANGE = {LEVER_PRESS_IN,'waiting1_lp'};
elseif isempty(NOSE_POKE_IN)&&isempty(LEVER_PRESS_IN),
    error('either NOSE_POKE or LEVER_PRESS should be active!')
end;
%%%

switch action
  case 'init',
    StateMatrixSection(obj, 'prepare_next_trial');    
    
  case 'prepare_next_trial',
      
    sma = StateMachineAssembler('no_dead_time_technology');
    
    sma = add_scheduled_wave(sma, 'name', 'vpd1_np', ...
        'preamble', VALID_POKE_DURATION_1_N);
    sma = add_scheduled_wave(sma, 'name', 'vpd2_np', ...
        'preamble', VALID_POKE_DURATION_2_N);
    
    sma = add_scheduled_wave(sma, 'name', 'vpd3_np', ...
        'preamble', VALID_POKE_DURATION_3_N);
    
    sma = add_scheduled_wave(sma, 'name', 'vpd1_lp', ...
        'preamble', VALID_POKE_DURATION_1_L);
    sma = add_scheduled_wave(sma, 'name', 'vpd2_lp', ...
        'preamble', VALID_POKE_DURATION_2_L);
    
    sma = add_scheduled_wave(sma, 'name', 'vpd3_lp', ...
        'preamble', VALID_POKE_DURATION_3_L);
    
    sma = add_scheduled_wave(sma, 'name', 'multi_poke_tolerance', ...
        'preamble', MULTI_POKE_TOLERANCE);
    sma = add_scheduled_wave(sma, 'name', 'reward_avail', ...
        'preamble', REWARD_AVAIL_PERIOD);
    sma = add_scheduled_wave(sma, 'name', 'delay_to_reward', ...
        'preamble', DELAY_TO_REWARD);
    sma = add_scheduled_wave(sma, 'name', 'center_small_reward', ...
        'preamble', CENTER_SMALL_REWARD);
    sma = add_scheduled_wave(sma, 'name', 'center_large_reward', ...
        'preamble', CENTER_LARGE_REWARD);
    sma = add_scheduled_wave(sma, 'name', 'left_small_reward', ...
        'preamble', LEFT_SMALL_REWARD);
    sma = add_scheduled_wave(sma, 'name', 'left_large_reward', ...
        'preamble', LEFT_LARGE_REWARD);
    sma = add_scheduled_wave(sma, 'name', 'right_small_reward', ...
        'preamble', RIGHT_SMALL_REWARD);
    sma = add_scheduled_wave(sma, 'name', 'right_large_reward', ...
        'preamble', RIGHT_LARGE_REWARD);
    sma = add_scheduled_wave(sma, 'name', 'three_sec', ...
        'preamble', 3);
    sma = add_scheduled_wave(sma, 'name', 'iti_poke_timeout', ...
        'preamble', ITI_POKE_TIMEOUT);
    sma = add_scheduled_wave(sma, 'name', 'trial_length', ...
        'preamble', TRIAL_LENGTH-3, 'sustain',3);

%%%%%%%%%%%Waiting for rat's entering waiting port%%%%%%%%%%%%%%%%%    
%         'ready_to_start_waiting'
    if strcmp(WAIT_POKE_NECESSARY, 'No'),
        sma = add_state(sma, 'name', 'ready_to_start_waiting', ...
            'output_actions', {'SoundOut',-ID_NOISE}, ...
            'self_timer', TIME_TO_FAKE_POKE, ...
            'input_to_statechange', [WAIT_IN_STATE_CHANGE, ...
                                     {'Tup','fake_poke'}]);
    else
        sma = add_state(sma, 'name', 'ready_to_start_waiting', ...
            'output_actions', {'SoundOut',-ID_NOISE}, ...
            'input_to_statechange', WAIT_IN_STATE_CHANGE);
    end;
%%%%%%%%%%%Waiting for rat's entering waiting port%%%%%%%%%%%%%%%%%

%%%%%%%%%%%fake_poke state for beginner Level1%%%%%%%%%%%%%%%%%%%%%
%         'fake_poke'
    sma = add_state(sma, 'name', 'fake_poke', ...
        'self_timer', 0.0001, ...
        'output_actions', {'SoundOut', ID_TONE_SMALL_LARGE}, ...
        'input_to_statechange', {'Tup','large_available1'});
%%%%%%%%%%%fake_poke state for beginner Level1%%%%%%%%%%%%%%%%%%%%%

for i = 1:2, %repeat for MIRROR WORLD STATE MATRIX!!!
    %%% some conditianal parameter for determinig real side state matrix or 
    %%% mirror side state matrix
    
    if i == 1,
        MIRROR_STR = '';    
    elseif i == 2,
        MIRROR_STR = 'mirror_';     
    end;
    
%%%%%%%%%%%Waiting inside waiting port%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if strcmp(TRIAL_LENGTH_CONSTANT, 'Yes'),
        SCHED_WAVE_TL_STR = '+trial_length';
    else
        SCHED_WAVE_TL_STR = '';
    end;
    
    for h = 1:2, %repeat for nose poke waiting,1 and lever press waiting,2

        if h == 1,
            BLOCK_STR = '_np';
            VPD1 = VALID_POKE_DURATION_1_N;
            WAIT_IN = NOSE_POKE_IN;
            WAIT_OUT = NOSE_POKE_OUT;
            
            if strcmp(BLOCK_NAME,'NosePoke'),
                WAIT_OUT_STATE = 'short_poke1';
                WAIT_OUT_STATE_SMALL = 'small_available1';
                WAIT_OUT_STATE_LARGE = 'large_available1';
            elseif strcmp(BLOCK_NAME,'LeverPress'),
                WAIT_OUT_STATE = 'zero_available1';
                WAIT_OUT_STATE_SMALL = 'zero_available1';
                WAIT_OUT_STATE_LARGE = 'zero_available1';
            elseif strcmp(BLOCK_NAME,'Both'),
                WAIT_OUT_STATE = 'short_poke1';
                WAIT_OUT_STATE_SMALL = 'small_available1';
                WAIT_OUT_STATE_LARGE = 'large_available1';
            end;

            if ~isempty(NOSE_POKE_IN)&&~isempty(LEVER_PRESS_IN),
                WAIT_OUT_WAITING = {NOSE_POKE_OUT,[MIRROR_STR WAIT_OUT_STATE]};
                WAIT_OUT_WAITING_SMALL = {NOSE_POKE_OUT,[MIRROR_STR WAIT_OUT_STATE_SMALL]};
                WAIT_OUT_WAITING_LARGE = {NOSE_POKE_OUT,[MIRROR_STR WAIT_OUT_STATE_LARGE]};
                WAIT_IN_WAITING_MULTI_POKE = {NOSE_POKE_IN,[MIRROR_STR 'waiting2_np']};
                WAIT_IN_WAITING_SMALL_MULTI_POKE = {NOSE_POKE_IN,[MIRROR_STR 'waiting_small2_np']};
                WAIT_IN_WAITING_LARGE_MULTI_POKE = {NOSE_POKE_IN,[MIRROR_STR 'waiting_large2_np']};
                WAIT_OUT_WAITING_MULTI_POKE = {NOSE_POKE_OUT,[MIRROR_STR 'waiting3_np']};
                WAIT_OUT_WAITING_SMALL_MULTI_POKE = {NOSE_POKE_OUT,[MIRROR_STR 'waiting_small3_np']};
                WAIT_OUT_WAITING_LARGE_MULTI_POKE = {NOSE_POKE_OUT,[MIRROR_STR 'waiting_large3_np']};
            elseif ~isempty(NOSE_POKE_IN)&&isempty(LEVER_PRESS_IN),
                WAIT_OUT_WAITING = {NOSE_POKE_OUT,[MIRROR_STR WAIT_OUT_STATE]};
                WAIT_OUT_WAITING_SMALL = {NOSE_POKE_OUT,[MIRROR_STR WAIT_OUT_STATE_SMALL]};
                WAIT_OUT_WAITING_LARGE = {NOSE_POKE_OUT,[MIRROR_STR WAIT_OUT_STATE_LARGE]};
                WAIT_IN_WAITING_MULTI_POKE = {NOSE_POKE_IN,[MIRROR_STR 'waiting2_np']};
                WAIT_IN_WAITING_SMALL_MULTI_POKE = {NOSE_POKE_IN,[MIRROR_STR 'waiting_small2_np']};
                WAIT_IN_WAITING_LARGE_MULTI_POKE = {NOSE_POKE_IN,[MIRROR_STR 'waiting_large2_np']};
                WAIT_OUT_WAITING_MULTI_POKE = {NOSE_POKE_OUT,[MIRROR_STR 'waiting3_np']};
                WAIT_OUT_WAITING_SMALL_MULTI_POKE = {NOSE_POKE_OUT,[MIRROR_STR 'waiting_small3_np']};
                WAIT_OUT_WAITING_LARGE_MULTI_POKE = {NOSE_POKE_OUT,[MIRROR_STR 'waiting_large3_np']};                
            elseif isempty(NOSE_POKE_IN)&&~isempty(LEVER_PRESS_IN),
                WAIT_OUT_WAITING = {};
                WAIT_OUT_WAITING_SMALL = {};
                WAIT_OUT_WAITING_LARGE = {};
                WAIT_IN_WAITING_MULTI_POKE = {};
                WAIT_IN_WAITING_SMALL_MULTI_POKE = {};
                WAIT_IN_WAITING_LARGE_MULTI_POKE = {};
                WAIT_OUT_WAITING_MULTI_POKE = {};
                WAIT_OUT_WAITING_SMALL_MULTI_POKE = {};
                WAIT_OUT_WAITING_LARGE_MULTI_POKE = {};   
            elseif isempty(NOSE_POKE_IN)&&isempty(LEVER_PRESS_IN),
                error('either NOSE_POKE or LEVER_PRESS should be active!')
            end;

        elseif h == 2,
            BLOCK_STR = '_lp';
%             WAIT_IN = LEVER_PRESS_IN;
%             WAIT_OUT = LEVER_PRESS_OUT;
            VPD1 = VALID_POKE_DURATION_1_L;
            WAIT_IN = LEVER_PRESS_IN;
            WAIT_OUT = LEVER_PRESS_OUT;
            
            if strcmp(BLOCK_NAME,'NosePoke'),
                WAIT_OUT_STATE = 'zero_available1';
                WAIT_OUT_STATE_SMALL = 'zero_available1';
                WAIT_OUT_STATE_LARGE = 'zero_available1';
            elseif strcmp(BLOCK_NAME,'LeverPress'),
                WAIT_OUT_STATE = 'short_poke1';
                WAIT_OUT_STATE_SMALL = 'small_available1';
                WAIT_OUT_STATE_LARGE = 'large_available1';
            elseif strcmp(BLOCK_NAME,'Both'),
                WAIT_OUT_STATE = 'short_poke1';
                WAIT_OUT_STATE_SMALL = 'small_available1';
                WAIT_OUT_STATE_LARGE = 'large_available1';
            end;
            
            if ~isempty(NOSE_POKE_IN)&&~isempty(LEVER_PRESS_IN),
                WAIT_OUT_WAITING = {LEVER_PRESS_OUT,[MIRROR_STR WAIT_OUT_STATE]};
                WAIT_OUT_WAITING_SMALL = {LEVER_PRESS_OUT,[MIRROR_STR WAIT_OUT_STATE_SMALL]};
                WAIT_OUT_WAITING_LARGE = {LEVER_PRESS_OUT,[MIRROR_STR WAIT_OUT_STATE_LARGE]};
                WAIT_IN_WAITING_MULTI_POKE = {LEVER_PRESS_IN,[MIRROR_STR 'waiting2_lp']};
                WAIT_IN_WAITING_SMALL_MULTI_POKE = {LEVER_PRESS_IN,[MIRROR_STR 'waiting_small2_lp']};
                WAIT_IN_WAITING_LARGE_MULTI_POKE = {LEVER_PRESS_IN,[MIRROR_STR 'waiting_large2_lp']};
                WAIT_OUT_WAITING_MULTI_POKE = {LEVER_PRESS_OUT,[MIRROR_STR 'waiting3_lp']};
                WAIT_OUT_WAITING_SMALL_MULTI_POKE = {LEVER_PRESS_OUT,[MIRROR_STR 'waiting_small3_lp']};
                WAIT_OUT_WAITING_LARGE_MULTI_POKE = {LEVER_PRESS_OUT,[MIRROR_STR 'waiting_large3_lp']};
            elseif ~isempty(NOSE_POKE_IN)&&isempty(LEVER_PRESS_IN),
                WAIT_OUT_WAITING = {};
                WAIT_OUT_WAITING_SMALL = {};
                WAIT_OUT_WAITING_LARGE = {};
                WAIT_IN_WAITING_MULTI_POKE = {};
                WAIT_IN_WAITING_SMALL_MULTI_POKE = {};
                WAIT_IN_WAITING_LARGE_MULTI_POKE = {};
                WAIT_OUT_WAITING_MULTI_POKE = {};
                WAIT_OUT_WAITING_SMALL_MULTI_POKE = {};
                WAIT_OUT_WAITING_LARGE_MULTI_POKE = {};
            elseif isempty(NOSE_POKE_IN)&&~isempty(LEVER_PRESS_IN),
                WAIT_OUT_WAITING = {LEVER_PRESS_OUT,[MIRROR_STR WAIT_OUT_STATE]};
                WAIT_OUT_WAITING_SMALL = {LEVER_PRESS_OUT,[MIRROR_STR WAIT_OUT_STATE_SMALL]};
                WAIT_OUT_WAITING_LARGE = {LEVER_PRESS_OUT,[MIRROR_STR WAIT_OUT_STATE_LARGE]};
                WAIT_IN_WAITING_MULTI_POKE = {LEVER_PRESS_IN,[MIRROR_STR 'waiting2_lp']};
                WAIT_IN_WAITING_SMALL_MULTI_POKE = {LEVER_PRESS_IN,[MIRROR_STR 'waiting_small2_lp']};
                WAIT_IN_WAITING_LARGE_MULTI_POKE = {LEVER_PRESS_IN,[MIRROR_STR 'waiting_large2_lp']};
                WAIT_OUT_WAITING_MULTI_POKE = {LEVER_PRESS_OUT,[MIRROR_STR 'waiting3_lp']};
                WAIT_OUT_WAITING_SMALL_MULTI_POKE = {LEVER_PRESS_OUT,[MIRROR_STR 'waiting_small3_lp']};
                WAIT_OUT_WAITING_LARGE_MULTI_POKE = {LEVER_PRESS_OUT,[MIRROR_STR 'waiting_large3_lp']};  
            elseif isempty(NOSE_POKE_IN)&&isempty(LEVER_PRESS_IN),
                error('either NOSE_POKE or LEVER_PRESS should be active!')
            end;
        end;
        

        if MULTI_POKE_TOLERANCE == 0,
            if strcmp(MULTI_POKE, 'valid_waiting'),
                %if so, TrialLengthConstant is No, and you don't have to send
                %scheduled waves for trial_length_constant

                %'waiting1'
                sma = add_state(sma, 'name', [MIRROR_STR 'waiting1' BLOCK_STR], ...
                    'self_timer', VPD1, ...
                    'output_actions', {'SchedWaveTrig','-reward_avail'}, ...
                    'input_to_statechange', [WAIT_OUT_WAITING, ...
                    {'Tup',[MIRROR_STR 'waiting_small1' BLOCK_STR]}]);
            else
                %MULTI_POKE not 'valid_waiting', then you don't have to cancel sched
                %wave for RewardAvailablePeriod here, but you should send
                %trial_length scheduled wave
                sma = add_state(sma, 'name', [MIRROR_STR 'waiting1' BLOCK_STR], ...
                                                         'output_actions', {'SchedWaveTrig',['vpd1' BLOCK_STR SCHED_WAVE_TL_STR]}, ...
                                                         'input_to_statechange', [WAIT_OUT_WAITING, ...
                                                                                                    {['vpd1' BLOCK_STR '_In'],[MIRROR_STR 'waiting_small1' BLOCK_STR], ...
                                                                                                    'trial_length_In',['mirror_waiting1' BLOCK_STR]}]);
            end;

            
            
    %%was not here before..just because cue assignment
    %'short_poke', 'small_available, 'large_available', 'zero_available'
    switch REWARD_PORT %input_to_statechange for reward port in
    case 'Center',
        REWARD_PORT_IN_SHORT = {'Cin',[MIRROR_STR 'pre_center_short_reward']};
        REWARD_PORT_IN_SMALL = {'Cin',[MIRROR_STR 'pre_center_small_reward']};                            
        REWARD_PORT_IN_LARGE = {'Cin',[MIRROR_STR 'pre_center_large_reward']};
        REWARD_PORT_IN_ZERO = {'Cin',[MIRROR_STR 'pre_center_zero_reward']};
        DOUT_CUE={'DOut',center1led};
    case 'Left',
        REWARD_PORT_IN_SHORT = {'Lin',[MIRROR_STR 'pre_left_short_reward']};
        REWARD_PORT_IN_SMALL = {'Lin',[MIRROR_STR 'pre_left_small_reward']};                            
        REWARD_PORT_IN_LARGE = {'Lin',[MIRROR_STR 'pre_left_large_reward']};
        REWARD_PORT_IN_ZERO = {'Lin',[MIRROR_STR 'pre_left_zero_reward']};
        DOUT_CUE={'DOut',left1led};
    case 'Right',
        REWARD_PORT_IN_SHORT = {'Rin',[MIRROR_STR 'pre_right_short_reward']};
        REWARD_PORT_IN_SMALL = {'Rin',[MIRROR_STR 'pre_right_small_reward']};                            
        REWARD_PORT_IN_LARGE = {'Rin',[MIRROR_STR 'pre_right_large_reward']};
        REWARD_PORT_IN_ZERO = {'Rin',[MIRROR_STR 'pre_right_zero_reward']};
        DOUT_CUE={'DOut',right1led};
    case 'Both',
        REWARD_PORT_IN_SHORT = {'Lin',[MIRROR_STR 'pre_left_short_reward'], ...
                                'Rin',[MIRROR_STR 'pre_right_short_reward']};
        REWARD_PORT_IN_SMALL = {'Lin',[MIRROR_STR 'pre_left_small_reward'], ...
                                'Rin',[MIRROR_STR 'pre_right_small_reward']};                            
        REWARD_PORT_IN_LARGE = {'Lin',[MIRROR_STR 'pre_left_large_reward'], ...
                                'Rin',[MIRROR_STR 'pre_right_large_reward']};
        REWARD_PORT_IN_ZERO = {'Lin',[MIRROR_STR 'pre_left_zero_reward'], ...
                               'Rin',[MIRROR_STR 'pre_right_zero_reward']};
        DOUT_CUE=[{'DOut',left1led},{'DOut',right1led}];
    otherwise,
        error('don''t know this REWARD_PORT parameter %s!', REWARD_PORT)
    end;
    %%%%%%%%%%%%%%%%%%%%%%%%%
%%%

            

            %these states will never be used. Just to make the number of
            %states always the same, so that sending state matrix inside the
            %trial doesn't do weird thing.
            sma = add_state(sma, 'name', [MIRROR_STR 'waiting2' BLOCK_STR]);
            sma = add_state(sma, 'name', [MIRROR_STR 'waiting3' BLOCK_STR]);
            %never used states

            %'waiting_small1'
            sma = add_state(sma, 'name', [MIRROR_STR 'waiting_small1' BLOCK_STR], ...
                                                     'output_actions',[ {'SoundOut', ID_TONE_SMALL},{'SchedWaveTrig',['vpd2' BLOCK_STR]}], ...
                                                     'input_to_statechange',[ WAIT_OUT_WAITING_SMALL,...%%%%%%%%%%%%%%%%%%%
                                                                                                  ['vpd2' BLOCK_STR '_In'],[MIRROR_STR 'cue_state' BLOCK_STR],...
                                                                                                  {'trial_length_In',['mirror_waiting_small2' BLOCK_STR]}]); %not mirror_waiting_small1 because sound is already played
  
          %%%%
                        %'cue_state' for Tup1
            sma = add_state(sma, 'name', [MIRROR_STR 'cue_state' BLOCK_STR], ...
                                                     'output_actions',[,{'SchedWaveTrig',['vpd3' BLOCK_STR]}], ...%%cue
                                                     'input_to_statechange',[WAIT_OUT_WAITING_SMALL,...%%%%%%%%%%%%%%%%%%%%%%%
                                                                                                 ['vpd3' BLOCK_STR '_In'],[MIRROR_STR 'waiting_large1' BLOCK_STR],... 
                                                                                                 {'trial_length_In',['mirror_waiting_small2' BLOCK_STR]}]);% 'mirror_cue_state2 does not exist...check
           %%%%%%%%%%%%%%%

            %'waiting_small2' %in real world, never used...
            sma = add_state(sma, 'name', [MIRROR_STR 'waiting_small2' BLOCK_STR], ...
                                                     'input_to_statechange', [WAIT_OUT_WAITING_SMALL, ...
                                                                                                {['vpd2' BLOCK_STR '_In'],[MIRROR_STR 'waiting_large1' BLOCK_STR], ...
                                                     'trial_length_In',['mirror_waiting_small2' BLOCK_STR]}]);
            %again never used states
            sma = add_state(sma, 'name', [MIRROR_STR 'waiting_small3' BLOCK_STR]);
            sma = add_state(sma, 'name', [MIRROR_STR 'waiting_small4' BLOCK_STR]);
            %never used states

            %'waiting_large1'
            sma = add_state(sma, 'name', [MIRROR_STR 'waiting_large1' BLOCK_STR], ...
                'output_actions', {'SoundOut', ID_TONE_LARGE}, ...
                'input_to_statechange', [WAIT_OUT_WAITING_LARGE, ...
                {'trial_length_In',['mirror_waiting_large2' BLOCK_STR]}]); %not mirror_waiting_large1 because sound is alreday played

            %'waiting_large2' %in real world, never used...
            sma = add_state(sma, 'name', [MIRROR_STR 'waiting_large2' BLOCK_STR], ...
                'input_to_statechange', [WAIT_OUT_WAITING_LARGE, ...
                {'trial_length_In',['mirror_waiting_large2' BLOCK_STR]}]);

            %again never used states
            sma = add_state(sma, 'name', [MIRROR_STR 'waiting_large3' BLOCK_STR]);
            sma = add_state(sma, 'name', [MIRROR_STR 'waiting_large4' BLOCK_STR]);
            %never used states


        elseif MULTI_POKE_TOLERANCE > 0,
            %then MULTI_POKE cant be 'valid_waiting', so it's not necessary to
            %remove reward_avail sched_wave in waiting1 state

            %'waiting1'
            sma = add_state(sma, 'name', [MIRROR_STR 'waiting1' BLOCK_STR], ...
                'output_actions', {'SchedWaveTrig',['vpd1'  BLOCK_STR  SCHED_WAVE_TL_STR]}, ...
                'input_to_statechange', {WAIT_OUT,[MIRROR_STR 'waiting3' BLOCK_STR], ...
                ['vpd1' BLOCK_STR '_In'],[MIRROR_STR 'waiting_small1'  BLOCK_STR], ...
                'trial_length_In',['mirror_waiting1'  BLOCK_STR]});

            sma = add_state(sma, 'name', [MIRROR_STR 'waiting2'  BLOCK_STR], ...
                'output_actions', {'SchedWaveTrig','-multi_poke_tolerance'}, ...
                'input_to_statechange', [WAIT_OUT_WAITING_MULTI_POKE, ...
                {['vpd1' BLOCK_STR '_In'],[MIRROR_STR 'waiting_small1' BLOCK_STR], ...
                'trial_length_In',['mirror_waiting2' BLOCK_STR]}]);

            sma = add_state(sma, 'name', [MIRROR_STR 'waiting3' BLOCK_STR], ...
                'output_actions', {'SchedWaveTrig','multi_poke_tolerance'}, ...
                'input_to_statechange', [WAIT_IN_WAITING_MULTI_POKE, ...
                {['vpd1' BLOCK_STR '_In'],[MIRROR_STR 'waiting_small4' BLOCK_STR], ...
                'multi_poke_tolerance_In',[MIRROR_STR WAIT_OUT_STATE], ...
                'trial_length_In',['mirror_waiting3' BLOCK_STR]}]);

            %'waiting_small1'
            sma = add_state(sma, 'name', [MIRROR_STR 'waiting_small1' BLOCK_STR], ...
                'output_actions', {'SchedWaveTrig',['vpd2' BLOCK_STR], ...
                'SoundOut',ID_TONE_SMALL}, ...
                'input_to_statechange', [WAIT_OUT_WAITING_SMALL_MULTI_POKE, ...
                {['vpd2' BLOCK_STR '_In'],[MIRROR_STR 'waiting_large1' BLOCK_STR], ...
                'trial_length_In',['mirror_waiting_small2' BLOCK_STR]}]); %not mirror_waiting_small1 because sound is alreday played

            sma = add_state(sma, 'name', [MIRROR_STR 'waiting_small2' BLOCK_STR], ...
                'output_actions', {'SchedWaveTrig','-multi_poke_tolerance'}, ...
                'input_to_statechange', [WAIT_OUT_WAITING_SMALL_MULTI_POKE, ...
                {['vpd2'  BLOCK_STR '_In'],[MIRROR_STR 'waiting_large1' BLOCK_STR], ...
                'trial_length_In',['mirror_waiting_small2' BLOCK_STR]}]);

            sma = add_state(sma, 'name', [MIRROR_STR 'waiting_small3' BLOCK_STR], ...
                'output_actions', {'SchedWaveTrig','multi_poke_tolerance'}, ...
                'input_to_statechange', [WAIT_IN_WAITING_SMALL_MULTI_POKE, ...
                {['vpd2' BLOCK_STR '_In'],[MIRROR_STR 'waiting_large4' BLOCK_STR], ...
                'multi_poke_tolerance_In',[MIRROR_STR WAIT_OUT_STATE_SMALL], ...
                'trial_length_In',['mirror_waiting_small3' BLOCK_STR]}]);

            sma = add_state(sma, 'name', [MIRROR_STR 'waiting_small4' BLOCK_STR], ...
                'output_actions', {'SchedWaveTrig',['vpd2' BLOCK_STR], ...
                'SoundOut',ID_TONE_SMALL}, ...
                'input_to_statechange', [WAIT_IN_WAITING_SMALL_MULTI_POKE, ...
                {['vpd2' BLOCK_STR '_In'],[MIRROR_STR 'waiting_large4' BLOCK_STR], ...
                'multi_poke_tolerance_In',[MIRROR_STR WAIT_OUT_STATE_SMALL], ...
                'trial_length_In',['mirror_waiting_small3' BLOCK_STR]}]); %not mirror_waiting_small4 because sound is alreday played

            %'waiting_large1'
            sma = add_state(sma, 'name', [MIRROR_STR 'waiting_large1' BLOCK_STR], ...
                'output_actions', {'SoundOut',ID_TONE_LARGE}, ...
                'input_to_statechange', [WAIT_OUT_WAITING_LARGE_MULTI_POKE, ...
                {'trial_length_In',['mirror_waiting_large2' BLOCK_STR]}]); %not mirror_waiting_large1 because sound is alreday played

            sma = add_state(sma, 'name', [MIRROR_STR 'waiting_large2' BLOCK_STR], ...
                'output_actions', {'SchedWaveTrig','-multi_poke_tolerance'}, ...
                'input_to_statechange', [WAIT_OUT_WAITING_LARGE_MULTI_POKE, ...
                {'trial_length_In',['mirror_waiting_large2' BLOCK_STR]}]);

            sma = add_state(sma, 'name', [MIRROR_STR 'waiting_large3' BLOCK_STR], ...
                'output_actions', {'SchedWaveTrig','multi_poke_tolerance'}, ...
                'input_to_statechange', [WAIT_IN_WAITING_LARGE_MULTI_POKE, ...
                {['vpd2' BLOCK_STR '_In'],[MIRROR_STR 'waiting_large4' BLOCK_STR], ...
                'multi_poke_tolerance_In',[MIRROR_STR WAIT_OUT_STATE_LARGE], ...
                'trial_length_In',['mirror_waiting_large3' BLOCK_STR]}]);

            sma = add_state(sma, 'name', [MIRROR_STR 'waiting_large4' BLOCK_STR], ...
                'output_actions', {'SoundOut',ID_TONE_LARGE}, ...
                'input_to_statechange', [WAIT_IN_WAITING_LARGE_MULTI_POKE, ...
                {'multi_poke_tolerance_In',[MIRROR_STR WAIT_OUT_STATE_LARGE], ...
                'trial_length_In',['mirror_waiting_large3' BLOCK_STR]}]); %not mirror_waiting_large4 because sound is alreday played

        end;
    end; %end of 'for-loop' (for h = 1:2); states for nose_poke_waiting and lever_press_waiting
%%%%%%%%%%%Waiting inside waiting port%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

%%%%%%%%%%%after_exiting_waiting_port%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     %'short_poke', 'small_available, 'large_available', 'zero_available'
%     switch REWARD_PORT %input_to_statechange for reward port in
%     case 'Center',
%         REWARD_PORT_IN_SHORT = {'Cin',[MIRROR_STR 'pre_center_short_reward']};
%         REWARD_PORT_IN_SMALL = {'Cin',[MIRROR_STR 'pre_center_small_reward']};                            
%         REWARD_PORT_IN_LARGE = {'Cin',[MIRROR_STR 'pre_center_large_reward']};
%         REWARD_PORT_IN_ZERO = {'Cin',[MIRROR_STR 'pre_center_zero_reward']};
%     case 'Left',
%         REWARD_PORT_IN_SHORT = {'Lin',[MIRROR_STR 'pre_left_short_reward']};
%         REWARD_PORT_IN_SMALL = {'Lin',[MIRROR_STR 'pre_left_small_reward']};                            
%         REWARD_PORT_IN_LARGE = {'Lin',[MIRROR_STR 'pre_left_large_reward']};
%         REWARD_PORT_IN_ZERO = {'Lin',[MIRROR_STR 'pre_left_zero_reward']};
%     case 'Right',
%         REWARD_PORT_IN_SHORT = {'Rin',[MIRROR_STR 'pre_right_short_reward']};
%         REWARD_PORT_IN_SMALL = {'Rin',[MIRROR_STR 'pre_right_small_reward']};                            
%         REWARD_PORT_IN_LARGE = {'Rin',[MIRROR_STR 'pre_right_large_reward']};
%         REWARD_PORT_IN_ZERO = {'Rin',[MIRROR_STR 'pre_right_zero_reward']};
%     case 'Both',
%         REWARD_PORT_IN_SHORT = {'Lin',[MIRROR_STR 'pre_left_short_reward'], ...
%                                 'Rin',[MIRROR_STR 'pre_right_short_reward']};
%         REWARD_PORT_IN_SMALL = {'Lin',[MIRROR_STR 'pre_left_small_reward'], ...
%                                 'Rin',[MIRROR_STR 'pre_right_small_reward']};                            
%         REWARD_PORT_IN_LARGE = {'Lin',[MIRROR_STR 'pre_left_large_reward'], ...
%                                 'Rin',[MIRROR_STR 'pre_right_large_reward']};
%         REWARD_PORT_IN_ZERO = {'Lin',[MIRROR_STR 'pre_left_zero_reward'], ...
%                                'Rin',[MIRROR_STR 'pre_right_zero_reward']};
%     otherwise,
%         error('don''t know this REWARD_PORT parameter %s!', REWARD_PORT)
%     end;
 
    switch MULTI_POKE %state after center port re-enter
                     %reward state after multiple c pokes
    case 'valid_waiting',
        MULTI_POKE_STATE_SP_N = 'waiting1_np'; 
        MULTI_POKE_STATE_SM_N = 'waiting1_np'; 
        MULTI_POKE_STATE_LA_N = 'waiting1_np';
        MULTI_POKE_STATE_ZR_N = 'waiting1_np';
        MULTI_POKE_STATE_SP_L = 'waiting1_lp';
        MULTI_POKE_STATE_SM_L = 'waiting1_lp';
        MULTI_POKE_STATE_LA_L = 'waiting1_lp';
        MULTI_POKE_STATE_ZR_L = 'waiting1_lp';
    case 'just_noiseB',
        MULTI_POKE_STATE_SP_N = [MIRROR_STR 'short_poke2'];
        MULTI_POKE_STATE_SM_N = [MIRROR_STR 'small_available2'];
        MULTI_POKE_STATE_LA_N = [MIRROR_STR 'large_available2'];
        MULTI_POKE_STATE_ZR_N = [MIRROR_STR 'zero_available2'];
        MULTI_POKE_STATE_SP_L = [MIRROR_STR 'short_poke2'];
        MULTI_POKE_STATE_SM_L = [MIRROR_STR 'small_available2'];
        MULTI_POKE_STATE_LA_L = [MIRROR_STR 'large_available2'];
        MULTI_POKE_STATE_ZR_L = [MIRROR_STR 'zero_available2'];
        WAIT_IN_AFT_MULTI_POKE_SHORT = [MIRROR_STR 'short_poke2'];
        WAIT_IN_AFT_MULTI_POKE_SMALL = [MIRROR_STR 'small_available2'];
        WAIT_IN_AFT_MULTI_POKE_LARGE = [MIRROR_STR 'large_available3'];
        WAIT_IN_AFT_MULTI_POKE_ZERO = [MIRROR_STR 'zero_available3'];
        REWARD_IN_AFT_MULTI_POKE_SHORT = REWARD_PORT_IN_SHORT;
        REWARD_IN_AFT_MULTI_POKE_SMALL = REWARD_PORT_IN_SMALL;
        REWARD_IN_AFT_MULTI_POKE_LARGE = REWARD_PORT_IN_LARGE;
        REWARD_IN_AFT_MULTI_POKE_ZERO = REWARD_PORT_IN_ZERO;
    case 'no_reward',
        MULTI_POKE_STATE_SP_N = [MIRROR_STR 'short_poke2'];
        MULTI_POKE_STATE_SM_N = [MIRROR_STR 'small_available2'];
        MULTI_POKE_STATE_LA_N = [MIRROR_STR 'large_available2'];
        MULTI_POKE_STATE_ZR_N = [MIRROR_STR 'zero_available2'];
        MULTI_POKE_STATE_SP_L = [MIRROR_STR 'short_poke2'];
        MULTI_POKE_STATE_SM_L = [MIRROR_STR 'small_available2'];
        MULTI_POKE_STATE_LA_L = [MIRROR_STR 'large_available2'];
        MULTI_POKE_STATE_ZR_L = [MIRROR_STR 'zero_available2'];
        WAIT_IN_AFT_MULTI_POKE_SHORT = [MIRROR_STR 'short_poke2'];
        WAIT_IN_AFT_MULTI_POKE_SMALL = [MIRROR_STR 'small_available2'];
        WAIT_IN_AFT_MULTI_POKE_LARGE = [MIRROR_STR 'large_available3'];
        WAIT_IN_AFT_MULTI_POKE_ZERO = [MIRROR_STR 'zero_available3'];
        REWARD_IN_AFT_MULTI_POKE_SHORT = {};
        REWARD_IN_AFT_MULTI_POKE_SMALL = {};
        REWARD_IN_AFT_MULTI_POKE_LARGE = {};
        REWARD_IN_AFT_MULTI_POKE_ZERO = {};
    otherwise,
        error('don''t know this MULTI_POKE parameter %s!', MULTI_POKE);
    end;

    if ~isempty(NOSE_POKE_IN)&&~isempty(LEVER_PRESS_IN),
        WAIT_IN_FIRST_MULTI_POKE_SHORT = {NOSE_POKE_IN,MULTI_POKE_STATE_SP_N, ...
                                          LEVER_PRESS_IN,MULTI_POKE_STATE_SP_L};
        WAIT_IN_FIRST_MULTI_POKE_SMALL = {NOSE_POKE_IN,MULTI_POKE_STATE_SM_N, ...
                                          LEVER_PRESS_IN,MULTI_POKE_STATE_SM_L};
        WAIT_IN_FIRST_MULTI_POKE_LARGE = {NOSE_POKE_IN,MULTI_POKE_STATE_LA_N, ...
                                          LEVER_PRESS_IN,MULTI_POKE_STATE_LA_L};
        WAIT_IN_FIRST_MULTI_POKE_ZERO = {NOSE_POKE_IN,MULTI_POKE_STATE_ZR_N, ...
                                         LEVER_PRESS_IN,MULTI_POKE_STATE_ZR_L};
        WAIT_IN_AFT_MULTI_POKE_SHORT = {NOSE_POKE_IN,[MIRROR_STR 'short_poke2'], ...
                                        LEVER_PRESS_IN,[MIRROR_STR 'short_poke2']};
        WAIT_IN_AFT_MULTI_POKE_SMALL = {NOSE_POKE_IN,[MIRROR_STR 'small_available2'], ...
                                        LEVER_PRESS_IN,[MIRROR_STR 'small_available2']};
        WAIT_IN_AFT_MULTI_POKE_LARGE = {NOSE_POKE_IN,[MIRROR_STR 'large_available2'], ...
                                        LEVER_PRESS_IN,[MIRROR_STR 'large_available2']};
        WAIT_IN_AFT_MULTI_POKE_ZERO = {NOSE_POKE_IN,[MIRROR_STR 'zero_available2'], ...
                                       LEVER_PRESS_IN,[MIRROR_STR 'zero_available2']}; 
    elseif ~isempty(NOSE_POKE_IN)&&isempty(LEVER_PRESS_IN),
        WAIT_IN_FIRST_MULTI_POKE_SHORT = {NOSE_POKE_IN,MULTI_POKE_STATE_SP_N};
        WAIT_IN_FIRST_MULTI_POKE_SMALL = {NOSE_POKE_IN,MULTI_POKE_STATE_SM_N};
        WAIT_IN_FIRST_MULTI_POKE_LARGE = {NOSE_POKE_IN,MULTI_POKE_STATE_LA_N};
        WAIT_IN_FIRST_MULTI_POKE_ZERO = {NOSE_POKE_IN,MULTI_POKE_STATE_ZR_N};
        WAIT_IN_AFT_MULTI_POKE_SHORT = {NOSE_POKE_IN,[MIRROR_STR 'short_poke2']};
        WAIT_IN_AFT_MULTI_POKE_SMALL = {NOSE_POKE_IN,[MIRROR_STR 'small_available2']};
        WAIT_IN_AFT_MULTI_POKE_LARGE = {NOSE_POKE_IN,[MIRROR_STR 'large_available2']};
        WAIT_IN_AFT_MULTI_POKE_ZERO = {NOSE_POKE_IN,[MIRROR_STR 'zero_available2']};
    elseif isempty(NOSE_POKE_IN)&&~isempty(LEVER_PRESS_IN),
        WAIT_IN_FIRST_MULTI_POKE_SHORT = {LEVER_PRESS_IN,MULTI_POKE_STATE_SP_L};
        WAIT_IN_FIRST_MULTI_POKE_SMALL = {LEVER_PRESS_IN,MULTI_POKE_STATE_SM_L};
        WAIT_IN_FIRST_MULTI_POKE_LARGE = {LEVER_PRESS_IN,MULTI_POKE_STATE_LA_L};
        WAIT_IN_FIRST_MULTI_POKE_ZERO = {LEVER_PRESS_IN,MULTI_POKE_STATE_ZR_L};
        WAIT_IN_AFT_MULTI_POKE_SHORT = {LEVER_PRESS_IN,[MIRROR_STR 'short_poke2']};
        WAIT_IN_AFT_MULTI_POKE_SMALL = {LEVER_PRESS_IN,[MIRROR_STR 'small_available2']};
        WAIT_IN_AFT_MULTI_POKE_LARGE = {LEVER_PRESS_IN,[MIRROR_STR 'large_available2']};
        WAIT_IN_AFT_MULTI_POKE_ZERO = {LEVER_PRESS_IN,[MIRROR_STR 'zero_available2']}; 
    elseif isempty(NOSE_POKE_IN)&&isempty(LEVER_PRESS_IN),
        error('either NOSE_POKE or LEVER_PRESS should be active!')
    end;
                            
    %'short_poke'
    sma = add_state(sma, 'name', [MIRROR_STR 'short_poke1'], ...
        'output_actions', {'SchedWaveTrig','reward_avail'}, ...
        'input_to_statechange', [WAIT_IN_FIRST_MULTI_POKE_SHORT, ...
                                 REWARD_PORT_IN_SHORT, ...
                                 {'reward_avail_In',[MIRROR_STR 'time_out1_out_1'], ...
                                 'trial_length_In','mirror_short_poke1'}]);

    %small_available
    sma = add_state(sma, 'name', [MIRROR_STR 'small_available1'], ...
        'output_actions', {'SchedWaveTrig','reward_avail'}, ...
        'input_to_statechange', [WAIT_IN_FIRST_MULTI_POKE_SMALL, ...
                                 REWARD_PORT_IN_SMALL, ...
                                 {'reward_avail_In',[MIRROR_STR 'time_out1_out_1'], ...
                                  'trial_length_In','mirror_small_available1'}]);

    %large_available
    sma = add_state(sma, 'name', [MIRROR_STR 'large_available1'], ...
        'output_actions', {'SchedWaveTrig','reward_avail'}, ...
        'input_to_statechange', [WAIT_IN_FIRST_MULTI_POKE_LARGE, ...
                                 REWARD_PORT_IN_LARGE, ...
                                 {'reward_avail_In',[MIRROR_STR 'time_out1_out_1'], ...
                                  'trial_length_In','mirror_large_available1'}]);
                              
    %zero_available
    sma = add_state(sma, 'name', [MIRROR_STR 'zero_available1'], ...
        'output_actions', {'SchedWaveTrig','reward_avail'}, ...
        'input_to_statechange', [WAIT_IN_FIRST_MULTI_POKE_ZERO, ...
                                 REWARD_PORT_IN_ZERO, ...
                                 {'reward_avail_In',[MIRROR_STR 'time_out1_out_1'], ...
                                  'trial_length_In','mirror_zero_available1'}]);

    if ismember(MULTI_POKE, {'just_noiseB', 'no_reward'}),        
        %short_poke2' after MULTI_POKE noise burst
        sma = add_state(sma, 'name', [MIRROR_STR 'short_poke2'], ...
            'self_timer', 0.0001, ...
            'output_actions', {'SoundOut',ID_NOISE_BURST}, ...
            'input_to_statechange', {'Tup',[MIRROR_STR 'short_poke3'], ...
                                     'reward_avail_In',[MIRROR_STR 'time_out1_out_1'], ...
                                     'trial_length_In','mirror_short_poke2'});
                                 
        %short_poke3' after MULTI_POKE resting state                        
        sma = add_state(sma, 'name', [MIRROR_STR 'short_poke3'], ...
            'input_to_statechange', [WAIT_IN_AFT_MULTI_POKE_SHORT, ...
                                     REWARD_IN_AFT_MULTI_POKE_SHORT, ...
                                     {'reward_avail_In',[MIRROR_STR 'time_out1_out_1'], ...
                                     'trial_length_In','mirror_short_poke3'}]);
                                 
        %'small_available2' after MULTI_POKE noise burst
        sma = add_state(sma, 'name', [MIRROR_STR 'small_available2'], ...
            'self_timer', 0.0001, ...
            'output_actions', {'SoundOut',ID_NOISE_BURST}, ...
            'input_to_statechange', {'Tup', [MIRROR_STR 'small_available3'], ...
                                     'reward_avail_In',[MIRROR_STR 'time_out1_out_1'], ...
                                     'trial_length_In','mirror_small_available2'});
                                 
        %'small_available3' after MULTI_POKE resting state
        sma = add_state(sma, 'name', [MIRROR_STR 'small_available3'], ...
            'input_to_statechange', [WAIT_IN_AFT_MULTI_POKE_SMALL, ...
                                     REWARD_IN_AFT_MULTI_POKE_SMALL, ...
                                     {'reward_avail_In',[MIRROR_STR 'time_out1_out_1'], ...
                                      'trial_length_In','mirror_small_available3'}]);
        
        %'large_available2'
        sma = add_state(sma, 'name', [MIRROR_STR 'large_available2'], ...
            'self_timer', 0.0001, ...
            'output_actions', {'SoundOut',ID_NOISE_BURST}, ...
            'input_to_statechange', {'Tup',[MIRROR_STR 'large_available3'], ...
                                     'reward_avail_In',[MIRROR_STR 'time_out1_out_1'], ...
                                     'trial_length_In','mirror_large_available2'});
        
        %'large_available3'                         
        sma = add_state(sma, 'name', [MIRROR_STR 'large_available3'], ...
            'input_to_statechange', [WAIT_IN_AFT_MULTI_POKE_LARGE, ...
                                     REWARD_IN_AFT_MULTI_POKE_LARGE, ...
                                     {'reward_avail_In',[MIRROR_STR 'time_out1_out_1'], ...
                                      'trial_length_In','mirror_large_available3'}]);
                                  
        %zero_available2'
        sma = add_state(sma, 'name', [MIRROR_STR 'zero_available2'], ...
            'self_timer', 0.0001, ...
            'output_actions', {'SoundOut',ID_NOISE_BURST}, ...
            'input_to_statechange', {'Tup',[MIRROR_STR 'zero_available3'], ...
                                     'reward_avail_In',[MIRROR_STR 'time_out1_out_1'], ...
                                     'trial_length_In','mirror_zero_available2'});
                                 
        %zero_available3'                        
        sma = add_state(sma, 'name', [MIRROR_STR 'zero_available3'], ...
            'input_to_statechange', [WAIT_IN_AFT_MULTI_POKE_ZERO, ...
                                     REWARD_IN_AFT_MULTI_POKE_ZERO, ...
                                     {'reward_avail_In',[MIRROR_STR 'time_out1_out_1'], ...
                                     'trial_length_In','mirror_zero_available3'}]);
    else
        %again these states will never be used.
        %just to make the number of states always the same
        sma = add_state(sma, 'name', [MIRROR_STR 'short_poke2']);
        sma = add_state(sma, 'name', [MIRROR_STR 'short_poke3']);
        sma = add_state(sma, 'name', [MIRROR_STR 'small_available2']);
        sma = add_state(sma, 'name', [MIRROR_STR 'small_available3']);
        sma = add_state(sma, 'name', [MIRROR_STR 'large_available2']);
        sma = add_state(sma, 'name', [MIRROR_STR 'large_available3']);
        sma = add_state(sma, 'name', [MIRROR_STR 'zero_available2']);
        sma = add_state(sma, 'name', [MIRROR_STR 'zero_available3']); 
        %never used states...                         
    end;
%%%%%%%%%%%after_exiting_waiting_port%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%%%%%%%%%%%%%Pre-reward state and reward delivery state%%%%%%%%%%%%

for j = 1:3, %repeat for center,left, and right
for k = 1:4, %repeat for short,small,large, and zero
    
    %set conditional parameters
    if j == 1, REW_PORT_STR = 'center_'; DOUT_WATER = center1water;
    elseif j == 2, REW_PORT_STR = 'left_'; DOUT_WATER = left1water;
    elseif j == 3, REW_PORT_STR = 'right_'; DOUT_WATER = right1water;
    end;
    
    if k == 1,
        REW_SIZE_STR = 'short_';
        DELAY_TO_REWARD_SCHED_IN_STATE = [MIRROR_STR 'time_out1_out_1'];
        REWARD_SCHED_WAVE = {};
        REWARD_SCHED_WAVE_IN = {};
    elseif k == 2,
        REW_SIZE_STR = 'small_';
        DELAY_TO_REWARD_SCHED_IN_STATE = [MIRROR_STR REW_PORT_STR REW_SIZE_STR 'reward'];
        REWARD_SCHED_WAVE = {'SchedWaveTrig',[REW_PORT_STR REW_SIZE_STR 'reward']};
        REWARD_SCHED_WAVE_IN = {[REW_PORT_STR REW_SIZE_STR 'reward_In'],[MIRROR_STR 'time_out1_out_1']};
    elseif k == 3,
        REW_SIZE_STR = 'large_';
        DELAY_TO_REWARD_SCHED_IN_STATE = [MIRROR_STR REW_PORT_STR REW_SIZE_STR 'reward'];
        REWARD_SCHED_WAVE = {'SchedWaveTrig',[REW_PORT_STR REW_SIZE_STR 'reward']};
        REWARD_SCHED_WAVE_IN = {[REW_PORT_STR REW_SIZE_STR 'reward_In'],[MIRROR_STR 'time_out1_out_1']};
    elseif k == 4,
        REW_SIZE_STR = 'zero_';
        DELAY_TO_REWARD_SCHED_IN_STATE = [MIRROR_STR 'time_out1_out_1'];
        REWARD_SCHED_WAVE = {};
        REWARD_SCHED_WAVE_IN = {};
    end;
    
%         pre reward state
    sma = add_state(sma, 'name', [MIRROR_STR 'pre_' REW_PORT_STR REW_SIZE_STR 'reward'], ...
      'output_actions', {'SchedWaveTrig','delay_to_reward', ...
                         'DOut', video_sync}, ...
      'input_to_statechange', {'delay_to_reward_In',DELAY_TO_REWARD_SCHED_IN_STATE, ...
                               'trial_length_In',['mirror_pre_' REW_PORT_STR REW_SIZE_STR 'reward']});
  
%         reward state
    sma = add_state(sma, 'name', [MIRROR_STR REW_PORT_STR REW_SIZE_STR 'reward'], ...
      'output_actions', [{'DOut',DOUT_WATER}, ...
                         REWARD_SCHED_WAVE], ...
      'input_to_statechange', [REWARD_SCHED_WAVE_IN, ...
                               {'trial_length_In',['mirror_' REW_PORT_STR REW_SIZE_STR 'reward']}]);

end;
end;
%%%%%%%%%%%%%Pre-reward state and reward delivery state%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%% ITI (inter-trial interval) %%%%%%%%%%%%%%%%%%%%

    if strcmp(TRIAL_LENGTH_CONSTANT, 'Yes') && isempty(MIRROR_STR),
    % if TRIAL_LENGTH_CONSTANT Yes and REAL (not MIRROR) STATE MATRIX
        INPUT_FOR_END_ITI = 'trial_length_Out';
    else %TRIAL_LENGTH_CONSTANT, No or MIRROR STATE MATRIX        
        INPUT_FOR_END_ITI = 'three_sec_In';
    end;
           
    if ~isempty(NOSE_POKE_IN)&&~isempty(LEVER_PRESS_IN),
        WAIT_IN_TIME_OUT_1 = {NOSE_POKE_IN,[MIRROR_STR 'time_out1_in'], ...
                              LEVER_PRESS_IN,[MIRROR_STR 'time_out1_in']};
        WAIT_OUT_TIME_OUT_1 = {NOSE_POKE_OUT,[MIRROR_STR 'time_out1_ref'], ...
                               LEVER_PRESS_OUT,[MIRROR_STR 'time_out1_ref']};
    elseif ~isempty(NOSE_POKE_IN)&&isempty(LEVER_PRESS_IN),
        WAIT_IN_TIME_OUT_1 = {NOSE_POKE_IN,[MIRROR_STR 'time_out1_in']};
        WAIT_OUT_TIME_OUT_1 = {NOSE_POKE_OUT,[MIRROR_STR 'time_out1_ref']};
    elseif isempty(NOSE_POKE_IN)&&~isempty(LEVER_PRESS_IN),
        WAIT_IN_TIME_OUT_1 = {LEVER_PRESS_IN,[MIRROR_STR 'time_out1_in']};
        WAIT_OUT_TIME_OUT_1 = {LEVER_PRESS_OUT,[MIRROR_STR 'time_out1_ref']};
    elseif isempty(NOSE_POKE_IN)&&isempty(LEVER_PRESS_IN),
        error('either NOSE_POKE or LEVER_PRESS should be active!')
    end;

    %'time_out1' %iti before trial length has passed
    sma = add_state(sma, 'name', [MIRROR_STR 'time_out1_out_1'], ...
      'output_actions', {'SchedWaveTrig','three_sec', ...
                         'DOut', ephys_sync, ...
                         'SoundOut',ID_NOISE}, ...   
      'input_to_statechange', [WAIT_IN_TIME_OUT_1, ...
                               {INPUT_FOR_END_ITI,'state35'}]);
                           
    sma = add_state(sma, 'name', [MIRROR_STR 'time_out1_out_2'], ... 
      'input_to_statechange', [WAIT_IN_TIME_OUT_1, ...
                               {INPUT_FOR_END_ITI,'state35'}]);

    sma = add_state(sma, 'name', [MIRROR_STR 'time_out1_in'], ...
      'output_actions', {'SchedWaveTrig','-iti_poke_timeout'}, ...
      'input_to_statechange', [WAIT_OUT_TIME_OUT_1, ...
                               {INPUT_FOR_END_ITI,'time_out2_in'}]);
  
    sma = add_state(sma, 'name', [MIRROR_STR 'time_out1_ref'], ...
      'output_actions', {'SchedWaveTrig','iti_poke_timeout'}, ...
      'input_to_statechange', [WAIT_IN_TIME_OUT_1, ...
                               {'iti_poke_timeout_In',[MIRROR_STR 'time_out1_out_2'], ...
                               INPUT_FOR_END_ITI,'time_out2_ref'}]);
end; %end of for i=1:2, end making REAL AND MIRROR STATE MATRIX
  
    %'time_out2': after trial length period has passed    
    if ~isempty(NOSE_POKE_IN)&&~isempty(LEVER_PRESS_IN),
        WAIT_IN_TIME_OUT_2 = {NOSE_POKE_IN,'time_out2_in', ...
                              LEVER_PRESS_IN,'time_out2_in'};
        WAIT_OUT_TIME_OUT_2 = {NOSE_POKE_OUT,'time_out2_ref', ...
                               LEVER_PRESS_OUT,'time_out2_ref'};
    elseif ~isempty(NOSE_POKE_IN)&&isempty(LEVER_PRESS_IN),
        WAIT_IN_TIME_OUT_2 = {NOSE_POKE_IN,'time_out2_in'};
        WAIT_OUT_TIME_OUT_2 = {NOSE_POKE_OUT,'time_out2_ref'};
    elseif isempty(NOSE_POKE_IN)&&~isempty(LEVER_PRESS_IN),
        WAIT_IN_TIME_OUT_2 = {LEVER_PRESS_IN,'time_out2_in'};
        WAIT_OUT_TIME_OUT_2 = {LEVER_PRESS_OUT,'time_out2_ref'};
    elseif isempty(NOSE_POKE_IN)&&isempty(LEVER_PRESS_IN),
        error('either NOSE_POKE or LEVER_PRESS should be active!')
    end;
    
    sma = add_state(sma, 'name', 'time_out2_in', ...
      'output_actions', {'SchedWaveTrig','-iti_poke_timeout'}, ...
      'input_to_statechange', WAIT_OUT_TIME_OUT_2);
                           
    sma = add_state(sma, 'name', 'time_out2_ref', ...
      'output_actions', {'SchedWaveTrig','iti_poke_timeout'}, ...
      'input_to_statechange', [WAIT_IN_TIME_OUT_2, ...
                               {'iti_poke_timeout_In','state35'}]);

    
%   dispatcher('send_assembler', sma, ...
%   optional cell_array of strings specifying the prepare_next_trial states);   
    dispatcher('send_assembler', sma, {'time_out1_out_1','mirror_time_out1_out_1'});
    
  otherwise,
    warning('%s : %s  don''t know action %s\n', class(obj), mfilename, action);
end;

   
      
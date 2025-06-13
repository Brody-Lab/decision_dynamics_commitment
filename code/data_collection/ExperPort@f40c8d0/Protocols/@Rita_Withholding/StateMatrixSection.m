
function  [] =  StateMatrixSection(obj, action)

global center1water left1water right1water ephys_sync video_sync

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
%ID_TONE_LARGE = value(IdToneLarge);
ID_TONE_SMALL_LARGE = value(IdToneSmallLarge);
ID_NOISE = value(IdNoise);
VALID_POKE_DURATION_1 = value(VpdSmall_Current);
VALID_POKE_DURATION_2 = value(VpdLarge_Current) - value(VpdSmall_Current);

BLOCK_NAME = value(BlockName); %1:'NosePoke' or 0:'LeverPress'

WAIT_POKE_NECESSARY = value(WaitPokeNecessary); %'Yes' or 'No'
TIME_TO_FAKE_POKE = value(TimeToFakePoke);
ITI_POKE_TIMEOUT = value(ITIPokeTimeOut);
TRIAL_LENGTH_CONSTANT = value(TrialLengthConstant);
TRIAL_LENGTH = value(TrialLength);%I want this value to be the time where noise is on

%%
RANDOMVAR=rand(1,1);

if RANDOMVAR>0.5
    RANDOMVAR=1;%left
    ID_TONE_LARGE = value(IdToneLargeL);
else
    RANDOMVAR=0;%right
    ID_TONE_LARGE = value(IdToneLargeR);
end

%%
switch value(PortAssign),
    case 'NP-C;Rew-Both'
        NOSE_POKE_IN = 'Cin'; NOSE_POKE_OUT = 'Cout';
        LEVER_PRESS_IN = ''; LEVER_PRESS_OUT = '';
        REWARD_PORT = 'Both';
        %%%%%%%%%%%%%%%%
    case 'NP-C;Rew-BothProb'
        NOSE_POKE_IN = 'Cin'; NOSE_POKE_OUT = 'Cout';
        LEVER_PRESS_IN = ''; LEVER_PRESS_OUT = '';
        REWARD_PORT = 'Both';
        %%%%%%%%%%%%%%%%%%%%%
    case 'NP-C;Rew-L'
        NOSE_POKE_IN = 'Cin'; NOSE_POKE_OUT = 'Cout';
        LEVER_PRESS_IN = ''; LEVER_PRESS_OUT = '';
        REWARD_PORT = 'Left';
    case 'NP-C;Rew-R'
        NOSE_POKE_IN = 'Cin'; NOSE_POKE_OUT = 'Cout';
        LEVER_PRESS_IN = ''; LEVER_PRESS_OUT = '';
        REWARD_PORT = 'Right';
    case 'LP-C;Rew-Both'
        NOSE_POKE_IN = ''; NOSE_POKE_OUT = '';
        LEVER_PRESS_IN = 'Cin'; LEVER_PRESS_OUT = 'Cout';
        REWARD_PORT = 'Both';
    case 'LP-C;Rew-L'
        NOSE_POKE_IN = ''; NOSE_POKE_OUT = '';
        LEVER_PRESS_IN = 'Cin'; LEVER_PRESS_OUT = 'Cout';
        REWARD_PORT = 'Left';
    case 'LP-C;Rew-R'
        NOSE_POKE_IN = ''; NOSE_POKE_OUT = '';
        LEVER_PRESS_IN = 'Cin'; LEVER_PRESS_OUT = 'Cout';
        REWARD_PORT = 'Right';
    case 'NP-L;Rew-C'
        NOSE_POKE_IN = 'Lin'; NOSE_POKE_OUT = 'Lout';
        LEVER_PRESS_IN = ''; LEVER_PRESS_OUT = '';
        REWARD_PORT = 'Center';
    case 'NP-R;Rew-C'
        NOSE_POKE_IN = 'Rin'; NOSE_POKE_OUT = 'Rout';
        LEVER_PRESS_IN = ''; LEVER_PRESS_OUT = '';
        REWARD_PORT = 'Center';
    case 'LP-L;Rew-C'
        NOSE_POKE_IN = ''; NOSE_POKE_OUT = '';
        LEVER_PRESS_IN = 'Lin'; LEVER_PRESS_OUT = 'Lout';
        REWARD_PORT = 'Center';
    case 'LP-R;Rew-C'
        NOSE_POKE_IN = ''; NOSE_POKE_OUT = '';
        LEVER_PRESS_IN = 'Rin'; LEVER_PRESS_OUT = 'Rout';
        REWARD_PORT = 'Center';
    case 'NP-L;LP-R;Rew-C'
        NOSE_POKE_IN = 'Lin'; NOSE_POKE_OUT = 'Lout';
        LEVER_PRESS_IN = 'Rin'; LEVER_PRESS_OUT = 'Rout';
        REWARD_PORT = 'Center';
    case 'NP-R;LP-L;Rew-C'
        NOSE_POKE_IN = 'Rin'; NOSE_POKE_OUT = 'Rout';
        LEVER_PRESS_IN = 'Lin'; LEVER_PRESS_OUT = 'Lout';
        REWARD_PORT = 'Center';
    otherwise
        error('don''t know this parameter %s', value(PortAssign));
end;

%%%
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
        change=20;
        sma = StateMachineAssembler('no_dead_time_technology');
        
        sma = add_scheduled_wave(sma, 'name', 'vpd1', ...
            'preamble', VALID_POKE_DURATION_1);
        sma = add_scheduled_wave(sma, 'name', 'vpd2', ...
            'preamble', VALID_POKE_DURATION_2);
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
            'preamble', change);
        sma = add_scheduled_wave(sma, 'name', 'iti_poke_timeout', ...
            'preamble', ITI_POKE_TIMEOUT);
        sma = add_scheduled_wave(sma, 'name', 'trial_length', ...
            'preamble', TRIAL_LENGTH-change, 'sustain',change);
        
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
            'input_to_statechange', {'Tup','waiting_large_fake'});
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
                                        
                    if ~isempty(NOSE_POKE_IN)
                        WAIT_OUT_WAITING = {NOSE_POKE_OUT,[MIRROR_STR 'short_poke1']};
                    elseif isempty(NOSE_POKE_IN)
                        WAIT_OUT_WAITING = {};
                    elseif isempty(NOSE_POKE_IN)&&isempty(LEVER_PRESS_IN),
                        error('either NOSE_POKE or LEVER_PRESS should be active!')
                    end;
                    
                elseif h == 2,
                    BLOCK_STR = '_lp';
                    
                    if ~isempty(LEVER_PRESS_IN),
                        WAIT_OUT_WAITING = {LEVER_PRESS_OUT,[MIRROR_STR 'short_poke1']};
                    elseif isempty(LEVER_PRESS_IN),
                        WAIT_OUT_WAITING = {};
                    elseif isempty(NOSE_POKE_IN)&&isempty(LEVER_PRESS_IN),
                        error('either NOSE_POKE or LEVER_PRESS should be active!')
                    end;
                end;
                
                switch REWARD_PORT %input_to_statechange for reward port in
                    case 'Center',
                        REWARD_PORT_IN_SMALL = {'Cin',[MIRROR_STR 'pre_center_small_reward']};
                        REWARD_PORT_IN_LARGE = {'Cin',[MIRROR_STR 'pre_center_large_reward']};
                        REWARD_PORT_IN_ZERO = {'Cin',[MIRROR_STR 'pre_center_zero_reward']};
                    case 'Left',
                        REWARD_PORT_IN_SMALL = {'Lin',[MIRROR_STR 'pre_left_small_reward']};
                        REWARD_PORT_IN_LARGE = {'Lin',[MIRROR_STR 'pre_left_large_reward']};
                        REWARD_PORT_IN_ZERO = {'Lin',[MIRROR_STR 'pre_left_zero_reward']};
                    case 'Right',
                        REWARD_PORT_IN_SMALL = {'Rin',[MIRROR_STR 'pre_right_small_reward']};
                        REWARD_PORT_IN_LARGE = {'Rin',[MIRROR_STR 'pre_right_large_reward']};
                        REWARD_PORT_IN_ZERO = {'Rin',[MIRROR_STR 'pre_right_zero_reward']};
                    case 'Both',
                        REWARD_PORT_IN_SMALL = {'Lin',[MIRROR_STR 'pre_left_small_reward'], ...
                            'Rin',[MIRROR_STR 'pre_right_small_reward']};
                        REWARD_PORT_IN_LARGE = {'Lin',[MIRROR_STR 'pre_left_large_reward'], ...
                            'Rin',[MIRROR_STR 'pre_right_large_reward']};
                        REWARD_PORT_IN_ZERO = {'Lin',[MIRROR_STR 'pre_left_zero_reward'], ...
                            'Rin',[MIRROR_STR 'pre_right_zero_reward']};
                        %%%%%%%5
                    case 'BothProb',
                        
                        REWARD_PORT_IN_SMALL = {'Lin',[MIRROR_STR 'pre_left_small_reward'], ...
                            'Rin',[MIRROR_STR 'pre_right_small_reward']};
                        if RANDOMVAR==1
                           REWARD_PORT_IN_LARGE = {'Lin',[MIRROR_STR 'pre_left_large_reward']};
                        else
                           REWARD_PORT_IN_LARGE = {'Rin',[MIRROR_STR 'pre_right_large_reward']}; 
                        end
                        REWARD_PORT_IN_ZERO = {'Lin',[MIRROR_STR 'pre_left_zero_reward'], ...
                            'Rin',[MIRROR_STR 'pre_right_zero_reward']};
                        %%%%%%%
                    otherwise,
                        error('don''t know this REWARD_PORT parameter %s!', REWARD_PORT)
                end;
                
                
                %MULTI_POKE not 'valid_waiting', then you don't have to cancel sched
                %wave for RewardAvailablePeriod here, but you should send
                %trial_length scheduled wave
                sma = add_state(sma, 'name', [MIRROR_STR 'waiting1' BLOCK_STR], ...
                    'output_actions', {'SchedWaveTrig',['vpd1' SCHED_WAVE_TL_STR]}, ...
                    'input_to_statechange', [WAIT_OUT_WAITING, ...
                                            {'vpd1_In',[MIRROR_STR 'waiting_small1'], ...
                                             'trial_length_In',['mirror_waiting1' BLOCK_STR]}]);
                           
            end; %end of 'for-loop' (for h = 1:2); states for nose_poke_waiting and lever_press_waiting
            %%%%%%%%%%%Waiting inside waiting port%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %'short_poke'
            sma = add_state(sma, 'name', [MIRROR_STR 'short_poke1'], ...
                'input_to_statechange', [WAIT_IN_STATE_CHANGE, ...
                                         {'trial_length_In','mirror_short_poke1'}]);    
            
             %'waiting_small1'
                sma = add_state(sma, 'name', [MIRROR_STR 'waiting_small1'], ...
                    'output_actions', {'SoundOut', ID_TONE_SMALL, ...
                                       'SchedWaveTrig','vpd2'}, ...
                    'input_to_statechange', [REWARD_PORT_IN_SMALL, ...
                                             {'vpd2_In',[MIRROR_STR 'waiting_large1'], ...
                                             'trial_length_In','mirror_waiting_small2'}]); %not mirror_waiting_small1 because sound is alreday played
                
                %'waiting_small2' only for mirror state
                sma = add_state(sma, 'name', [MIRROR_STR 'waiting_small2'], ...
                    'output_actions', {'SchedWaveTrig','vpd2'}, ...
                    'input_to_statechange', [REWARD_PORT_IN_SMALL, ...
                                             {'vpd2_In',[MIRROR_STR 'waiting_large1']}]);
                
                
                %'waiting_large1'
                sma = add_state(sma, 'name', [MIRROR_STR 'waiting_large1'], ...
                    'output_actions', {'SoundOut', ID_TONE_LARGE}, ...
                    'input_to_statechange', [REWARD_PORT_IN_LARGE, ...
                                            {'trial_length_In','mirror_waiting_large2'}]); %not mirror_waiting_large1 because sound is alreday played
                
                %'waiting_large2' only for mirror state
                sma = add_state(sma, 'name', [MIRROR_STR 'waiting_large2'], ...
                    'input_to_statechange', REWARD_PORT_IN_LARGE); 
                                                
                 %'waiting_small1_invalid'
                sma = add_state(sma, 'name', [MIRROR_STR 'waiting_small1_invalid'], ...
                    'output_actions', {'SoundOut', ID_TONE_SMALL, ...
                                       'SchedWaveTrig','vpd2'}, ...
                    'input_to_statechange', [REWARD_PORT_IN_ZERO, ...
                                             {'vpd2_In',[MIRROR_STR 'waiting_large1'], ...
                                             'trial_length_In','mirror_waiting_small2_invalid'}]); %not mirror_waiting_small1 because sound is alreday played
                
                %'waiting_small2_invalid' only for mirror state
                sma = add_state(sma, 'name', [MIRROR_STR 'waiting_small2_invalid'], ...
                    'output_actions', {'SchedWaveTrig','vpd2'}, ...
                    'input_to_statechange', [REWARD_PORT_IN_ZERO, ...
                                             {'vpd2_In',[MIRROR_STR 'waiting_large1_invalid']}]);
                
                
                %'waiting_large1_invalid'
                sma = add_state(sma, 'name', [MIRROR_STR 'waiting_large1_invalid'], ...
                    'output_actions', {'SoundOut', ID_TONE_LARGE}, ...
                    'input_to_statechange', [REWARD_PORT_IN_ZERO, ...
                                            {'trial_length_In','mirror_waiting_large2_invalid'}]); %not mirror_waiting_large1 because sound is alreday played
                
                %'waiting_large2_invalid' only for mirror state
                sma = add_state(sma, 'name', [MIRROR_STR 'waiting_large2_invalid'], ...
                    'input_to_statechange', REWARD_PORT_IN_ZERO); 
                
                
                %'waiting_large_fake' %special state for fake poke
                sma = add_state(sma, 'name', [MIRROR_STR 'waiting_large_fake'], ...
                    'output_actions', {'SoundOut', ID_TONE_LARGE}, ...
                    'input_to_statechange', REWARD_PORT_IN_LARGE);
            
            
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
                %INPUT_FOR_END_ITI = 10;
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
            
%             sma = add_state(sma, 'name', [MIRROR_STR 'time_out1_out_1'], ...
%                 'output_actions', {'DOut', ephys_sync, ...
%                 'SoundOut',ID_NOISE}, ...
%                 'input_to_statechange', [WAIT_IN_TIME_OUT_1, ...
%                 {INPUT_FOR_END_ITI,'state35'}]);
            
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



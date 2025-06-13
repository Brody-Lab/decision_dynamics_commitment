
function  [] =  SMA_train(obj, action)

GetSoloFunctionArgs;


min_time= 2.5E-4;
left1led           = bSettings('get', 'DIOLINES', 'left1led');
center1led         = bSettings('get', 'DIOLINES', 'center1led');
right1led          = bSettings('get', 'DIOLINES', 'right1led');
left1water         = bSettings('get', 'DIOLINES', 'left1water');
right1water        = bSettings('get', 'DIOLINES', 'right1water');
%     center1water       = bSettings('get', 'DIOLINES', 'center1water');
%     Center1water is not used in this version

sma = StateMachineAssembler('full_trial_structure','use_happenings', 1);
[LeftWValveTime, RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
%     [CenterWValveTime] = WaterValvesSection(obj, 'get_center_time');

%% Setup sounds

% These are used in all stages
right_hit_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'RightHitSound');
left_hit_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'LeftHitSound');

iti_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'ITISound');

% These are used starting with stage 3
viol_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'ViolationSound');
to_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'TimeoutSound');

 if rewards_from_spokes==1
            if side_reward_loc==-1
                fprintf('This is a left-reward\n');
                reward_state='left_reward_state';
                reward_poke='Lhi';
                hit_dio=left1water;
                hit_valve_time=LeftWValveTime;
                hit_sound_id=left_hit_sound_id;
            elseif side_reward_loc==1
                fprintf('This is a right-reward\n');
                reward_state='right_reward_state';
                reward_poke='Rhi';
                hit_dio=right1water;
                hit_valve_time=RightWValveTime;
                hit_sound_id=right_hit_sound_id;
            else
                error('Reward location should be 1 or -1')
            end
        else
            error('Center rewards are not implemented')
            % reward_state='center_reward_state'; %#ok<*UNRCH>
            % hit_dio=center1water;
            % reward_led=0;
            % hit_valve_time=CenterWValveTime;
            % reward_poke='Chi';
        end
        
        sma = add_scheduled_wave(sma, 'name', 'direct_reward', 'preamble', reward_delay, ...
            'sustain', hit_valve_time, 'DOut', hit_dio);
        

switch action
    case 'init',
        feval(mfilename, obj, 'next_trial');
        %% next_trial
    case 'stage1',
        
        
       
        
        %% States setup
        % The first state is just waiting for the rat to poke in the center
        % port.  We make sure the nic sound is off in this state.
        
        sma = add_state(sma,'name','wait_for_nopoke',...
            'self_timer',min_time,...
            'output_actions',{'SoundOut',iti_sound_id},...
            'input_to_statechange',{'Tup','current_state+1'});
        
        sma = add_state(sma,...
            'self_timer',2,...
            'input_to_statechange',{'Chi','current_state+1'; ...
            'Rhi','current_state+1';...
            'Lhi','current_state+1';
            'Tup','current_state+2'});
        
        sma = add_state(sma,'self_timer',min_time,...
            'input_to_statechange',{'Tup','current_state-1'});
        
        sma = add_state(sma,'self_timer',2,...
            'output_actions',{'SoundOut',-iti_sound_id},...
            'input_to_statechange',{'Tup','current_state+1'});
        
        sma = add_state(sma,'name','hit_state','self_timer',0.2,...
            'output_actions',{'SoundOut',hit_sound_id},...
            'input_to_statechange',{'Tup','current_state+1'});
        
        sma = add_state(sma,'name',reward_state,'self_timer',3,...
            'output_actions',{'SchedWaveTrig','direct_reward'},...
            'input_to_statechange',{'Tup','iti_state_short'});
        
        sma = add_state(sma,'name','iti_state_short','self_timer',short_iti_dur,...
            'output_actions',{'SoundOut',iti_sound_id},...
            'input_to_statechange',{'Tup','check_next_trial_ready'});
        
        dispatcher('send_assembler', sma, {'hit_state'});
        
        
    case 'stage2',
        
        %% Grow nose in center
        %% Associate hit sound  with reward.
        
        %% Declare variables
        % These will get moved to other functions as SoloParamHandles.
        
        
        
        %% States setup
        % The first state is just waiting for the rat to poke in the center
        % port.  We make sure the nic sound is off in this state.
        
        sma = add_state(sma,'name','iti_state_short','self_timer',short_iti_dur,...
            'output_actions',{'SoundOut',iti_sound_id},...
            'input_to_statechange',{'Tup','wait_for_nopoke'});
        
        
        sma = add_state(sma,'name','wait_for_nopoke',...
            'self_timer',min_time,...
            'output_actions',{'SoundOut',iti_sound_id},...
            'input_to_statechange',{'Tup','current_state+1'});
        
        sma = add_state(sma,...
            'self_timer',2,...
            'input_to_statechange',{'Chi','current_state+1'; ...
            'Rhi','current_state+1';...
            'Lhi','current_state+1';
            'Tup','current_state+2'});
        
        sma = add_state(sma,'self_timer',min_time,...
            'input_to_statechange',{'Tup','current_state-1'});
        
        sma = add_state(sma,'name','wait_for_cpoke',...
            'self_timer',wait_for_cpoke_timeout,...
            'output_actions',{'DOut',center1led;'SoundOut',-iti_sound_id},...
            'input_to_statechange',{'Tup','wait_for_nopoke'; ...
            'Chi','cpoke1'});
        
        sma = add_state(sma,'name','cpoke1','self_timer',flash1_dur,...
            'output_actions',{'DOut',right1led+left1led},...
            'input_to_statechange',{'Tup','current_state+1'; ...
            'Clo','wait_for_nopoke';...
            });
        
        sma = add_state(sma,'name','wait_for_cout',...
            'self_timer',waitforgo_dur,...
            'input_to_statechange',{'Tup','wait_for_nopoke'; ...
            'Clo','hit_state'});
        
        sma = add_state(sma,'name','hit_state',...
            'output_actions',{'SoundOut',hit_sound_id},...
            'input_to_statechange',{reward_poke,'current_state+1'});
        
        sma = add_state(sma,'name',reward_state,'self_timer',3,...
            'output_actions',{'SchedWaveTrig','direct_reward'},...
            'input_to_statechange',{'Tup','check_next_trial_ready'});
        
        
        dispatcher('send_assembler', sma, {'hit_state'});
        
        
    otherwise
        warning('do not know how to do %s',action);
end
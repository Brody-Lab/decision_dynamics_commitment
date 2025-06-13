
function  [] =  SMA1(obj, action)

GetSoloFunctionArgs;


switch action
    case 'init',
        
        feval(mfilename, obj, 'next_trial');
        
        %% next_trial
    case 'next_trial',
        
        %% Setup water
        min_time= 2.5E-4;  % This is less than the minumum time allowed for a state transition.
        
        left1led           = bSettings('get', 'DIOLINES', 'left1led');
        center1led         = bSettings('get', 'DIOLINES', 'center1led');
        right1led          = bSettings('get', 'DIOLINES', 'right1led');
        left1water         = bSettings('get', 'DIOLINES', 'left1water');
        right1water        = bSettings('get', 'DIOLINES', 'right1water');
        
        sma = StateMachineAssembler('full_trial_structure','use_happenings', 1);
        [LeftWValveTime, RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
        [LeftWMult, RightWMult] = SidesSection(obj, 'get_water_mult');
        
        %% Setup sounds
        
        nic_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'NICSound');
        
        hit_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'HitSound');
        err_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'ErrorSound');
        viol_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'ViolationSound');
        to_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'TimeoutSound');
        
        
        
        %% Declare variables
        % These will get moved to other functions as SoloParamHandles.
        
        if allow_nic_breaks==1
            cpoke_out_state='current_state';
        else
            cpoke_out_state='violation_state';
        end
        
        
        
        
        is_done=false;
        
        % Note if nic_time is zero no flashes will be played.
        
        delta_zero_ok=1;
        
        while ~is_done
            
            left_stim =rand(1,ceil(nic_time/bin_size))<left_prob;
            right_stim=rand(1,ceil(nic_time/bin_size))<right_prob;
            
            
            
            %unlike pbups we do not force a stero flash at the beginning of
            %each trial
            SidesSection(obj,'forced_stereo',0)
            
            if sum(left_stim)>sum(right_stim)
                correct_response='Lhi';
                error_response='Rhi';
                is_done=true;
                hit_dio=left1water;
                hit_valve_time=LeftWValveTime*LeftWMult;
                this_trial='l';
                
                
            elseif sum(left_stim)<sum(right_stim)
                correct_response='Rhi';
                error_response='Lhi';
                hit_dio=right1water;
                hit_valve_time=RightWValveTime*RightWMult;
                is_done=true;
                this_trial='r';
            elseif delta_zero_ok || nic_time==0   % if delta flash = 0 choose rewarded side at random
                if rand<0.5
                    correct_response='Rhi';
                    error_response='Lhi';
                    hit_dio=right1water;
                    hit_valve_time=RightWValveTime*RightWMult;
                    is_done=true;
                    this_trial='s';
                else
                    correct_response='Lhi';
                    error_response='Rhi';
                    is_done=true;
                    hit_dio=left1water;
                    hit_valve_time=LeftWValveTime*LeftWMult;
                    this_trial='m';
                end
            end
        end
        
        SidesSection(obj,'update_trial_history',this_trial);
        
        bonus=max(1,(nic_time+settling_time+delay_time)).^reward_exponent;
        
        hit_valve_time=hit_valve_time*bonus/2;
        
        sma = add_scheduled_wave(sma, 'name', 'direct_reward', 'preamble', reward_delay, ...
            'sustain', hit_valve_time, 'DOut', hit_dio);
        
        if value(imaging)==1 && ~isnan(bSettings('get', 'DIOLINES', 'scope'));
            trigscope = bSettings('get', 'DIOLINES', 'scope');
        else
            trigscope = nan;
        end
        
        if value(imaging)==1
            sma = add_scheduled_wave(sma, 'name', 'TrigScope', 'preamble', 0, 'sustain', ...
                0.5, 'DOut', trigscope, 'loop', 0);
        else
            sma = add_scheduled_wave(sma, 'name', 'TrigScope', 'preamble', 0, 'sustain', 0); %dummy wave.
        end
        
        
        
        % wait for center nose in
        
        % On Cin play a NIC sound, the stimulus, stop with violation if rat leaves during
        % NIC.  Stimulus is lights flashing on the right and left. If the rat
        % leaves early the trial ends.
        
        sma = add_state(sma,'name','wait_for_cpoke',...
            'self_timer',wait_for_cpoke_timeout,...
            'output_actions',{'SoundOut',-nic_sound_id},...
            'input_to_statechange',{'Tup','timeout_state'; ...
            'Chi','nic_prestim'});
        
        
        
        sma = add_state(sma,'name','nic_prestim','self_timer',settling_time,...
            'output_actions',{'SoundOut',nic_sound_id;},...
            'input_to_statechange',{'Clo','wait_for_cpoke';...
            'Tup','current_state+1'});
        
        jitter=false; %if set to true, th eprotocol will jitter the LED durations
        
        for tx=1:numel(left_stim)
            % Set flash time CV here
            if jitter
                this_led_time=led_time+0.15*randn*led_time;
            else
                this_led_time=led_time;
            end
            
            % In each time bin add a state that is a left_light
            if left_stim(tx)==1 && right_stim(tx)==1
                sma=add_state(sma,'name',sprintf('led%03g_B',tx),'self_timer',this_led_time,...
                    'output_actions',{'DOut',right1led+left1led},...
                    'input_to_statechange',{'Tup','current_state+1'; ...
                    'Clo',cpoke_out_state});
            elseif left_stim(tx)==1 && right_stim(tx)==0
                sma=add_state(sma,'name',sprintf('led%03g_L',tx),'self_timer',this_led_time,...
                    'output_actions',{'DOut',left1led},...
                    'input_to_statechange',{'Tup','current_state+1'; ...
                    'Clo',cpoke_out_state});
                
            elseif left_stim(tx)==0 && right_stim(tx)==1
                sma=add_state(sma,'name',sprintf('led%03g_R',tx),'self_timer',this_led_time,...
                    'output_actions',{'DOut',right1led},...
                    'input_to_statechange',{'Tup','current_state+1'; ...
                    'Clo',cpoke_out_state});
            elseif left_stim(tx)==0 && right_stim(tx)==0
                sma=add_state(sma,'name',sprintf('led%03g_N',tx),'self_timer',this_led_time,...
                    'input_to_statechange',{'Tup','current_state+1'; ...
                    'Clo',cpoke_out_state});
            else
                error('You are in trouble');
            end
            
            % Set IFI CV here
            if jitter
                this_off_time=(1+randn*.1)*bin_size-this_led_time;
            else
                this_off_time=bin_size-this_led_time;
            end
            
            
            sma=add_state(sma,'name',sprintf('led%03g_off',tx),'self_timer',this_off_time,...
                'input_to_statechange',{'Tup','current_state+1'; ...
                'Clo',cpoke_out_state});
        end
        
        sma = add_state(sma,'name','nic_poststim','self_timer',delay_time,...
            'input_to_statechange',{'Clo',cpoke_out_state;...
            'Tup','wait_for_cout'});
        
        sma = add_state(sma,'name','wait_for_cout',...
            'output_actions',{'SoundOut',-nic_sound_id},...
            'input_to_statechange',{'Clo','wait_for_spoke'});
        
        switch side_lights
            case 'none', % no lights
                led_dio=0;
            case 'both', % both lights
                led_dio=left1led+right1led;
            case 'correct side', % pro lights
                if this_trial=='l' || this_trial=='m'
                    led_dio=left1led;
                elseif this_trial=='r' || this_trial=='s'
                    led_dio=right1led;
                else
                    error('this_trial variable should take the value l, r, m, or s.');
                end
                
            case 'anti side'; % Anti lights
                if this_trial=='l' || this_trial=='m'
                    led_dio=left1led;
                elseif this_trial=='r' || this_trial=='s'
                    led_dio=right1led;
                else
                    error('this_trial variable should take the value l, r, m, or s.');
                end
            otherwise
                error('side lights takes the wrong value')
        end
        
        
        if ignore_errors==1
            error_state='current_state';
        else
            error_state='error_state';
        end
        
        sma = add_state(sma,'name','wait_for_spoke','self_timer',wait_for_spoke_timeout,...
            'output_actions',{'DOut',led_dio},...
            'input_to_statechange',{correct_response, 'hit_state';...
            error_response,error_state;...
            'Tup','timeout_state'});
        
        sma = add_state(sma,'name','hit_state','self_timer',reward_delay+hit_valve_time+0.1,...
            'output_actions',{'SoundOut',hit_sound_id;...
            'SchedWaveTrig','direct_reward'},...
            'input_to_statechange',{'Tup','preclean_up_state'});
        
        sma = add_state(sma,'name','error_state','self_timer',error_iti,...
            'output_actions',{'SoundOut',err_sound_id},...
            'input_to_statechange',{'Tup','preclean_up_state'});
        
        
        sma = add_state(sma,'name','timeout_state','self_timer',1,...
            'output_actions',{'SoundOut',to_sound_id},...
            'input_to_statechange',{'Tup','preclean_up_state'});
        
           sma = add_state(sma,'name','preclean_up_state','self_timer',0.5,...
            'output_actions',{ 'SchedWaveTrig','+TrigScope'},...
            'input_to_statechange',{'Tup','clean_up_state'});
    
        
        sma = add_multi_sounds_state(sma,[-nic_sound_id viol_sound_id],...
            'self_timer',violation_iti,...
            'state_name','violation_state','return_state','clean_up_state');
        
        sma = add_multi_sounds_state(sma,[-to_sound_id -viol_sound_id -hit_sound_id -err_sound_id],...
            'state_name','clean_up_state','return_state','check_next_trial_ready');
        
        
        dispatcher('send_assembler', sma, {'hit_state', 'error_state', 'violation_state','timeout_state'});
        
        
        
    otherwise
        warning('do not know how to do %s',action);
end
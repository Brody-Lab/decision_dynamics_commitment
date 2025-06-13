function  [] =  SMA1(obj, action)

GetSoloFunctionArgs;


switch action
    case 'init',
        
        feval(mfilename, obj, 'next_trial');
        
        
        %% next_trial
    case 'next_trial',
        
        
        %Output Lines
        left1led           = bSettings('get', 'DIOLINES', 'left1led');
        center1led         = bSettings('get', 'DIOLINES', 'center1led');
        right1led          = bSettings('get', 'DIOLINES', 'right1led');
        left1water         = bSettings('get', 'DIOLINES', 'left1water');
        right1water        = bSettings('get', 'DIOLINES', 'right1water');
      
        % INPUT LINES
        if ~isnan(bSettings('get', 'DIOLINES', 'A5'));
            CW = bSettings('get', 'DIOLINES', 'A5');
            sma = StateMachineAssembler('full_trial_structure', 'use_happenings', 1, 'n_input_lines', 4);
        else
            sma = StateMachineAssembler('full_trial_structure', 'use_happenings', 1);
        end
         
        % Sounds
        nic_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'NICSound');
        hit_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'HitSound');
        err_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'ErrorSound');
        viol_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'ViolationSound');
        to_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'TimeoutSound');
        
        
        % Declare variables
        % These will get moved to other functions as SoloParamHandles.
        
        if allow_nic_breaks==1
            cpoke_out_state='current_state';
        else
            cpoke_out_state='violation_state';
        end
        
        if value(training_stage)==1
            [LeftWValveTime RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
            if rand<0.5
                this_trial = 'l';
                correct_response = 'Lhi';
                led_dio=left1led;
                water=left1water;
                hit_valve_time = LeftWValveTime;
                error_response = 'Rhi';
            else
                this_trial = 'r';
                correct_response = 'Rhi';
                led_dio=right1led;
                water=right1water;
                hit_valve_time = RightWValveTime;
                error_response = 'Lhi';
            end
        elseif value(training_stage)==2
            this_trial = 'f'; %f is for forage.  there is no correct side
            switch safe_side
                case 'l', % if left is the safe side
                    lsound = hit_sound_id;
                    l_ul = value(safe_amount);
                    safe_hit.value = 1;
                    if value(test_gambles_now)==1;
                       if rand >= value(safe_prob);
                           safe_hit.value = 0;
                           lsound = err_sound_id;
                           l_ul = 0;
                       else
                           lsound = hit_sound_id;
                           l_ul = value(safe_amount);
                           safe_hit.value = 1;
                       end
                    end
                    if rand >= value(risky_prob) %if there's no reward on risky (right) side
                        risk_hit.value = 0;
                        rsound = err_sound_id;
                        r_ul = 0;
                    else
                        risk_hit.value =1;
                        rsound = hit_sound_id;
                        r_ul = value(risky_amount);
                    end
                case 'r', % if the right side is safe
                    rsound = hit_sound_id;
                    r_ul = value(safe_amount);
                    safe_hit.value = 1;
                    if value(test_gambles_now)==1;
                       if rand >= value(safe_prob);
                           safe_hit.value = 0;
                           rsound = err_sound_id;
                           r_ul = 0;
                       else
                           safe_hit.value = 1;
                           rsound = hit_sound_id;
                           r_ul = value(safe_amount);
                       end
                    end
                    if rand >= value(risky_prob)
                        l_ul = 0;
                        risk_hit.value = 0;
                        lsound  = err_sound_id;
                    else
                        risk_hit.value = 1;
                        lsound = hit_sound_id;
                        l_ul = value(risky_amount);
                    end
            end
            
         [x, y] = WaterValvesSection(obj, 'set_water_amounts', l_ul, r_ul);
         
        end
        
        
        [LeftWValveTime RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
        
        if value(training_stage)==2
            if l_ul==0;
                LeftWValveTime = 0; %unfortunately, because of weird stuff in WaterValvesSection, we had to do this manually.
            end
            if r_ul ==0
                RightWValveTime = 0;
            end
        end
            

        
        SidesSection(obj,'update_trial_history',this_trial);
        
        if value(training_stage)==1
            sma = add_scheduled_wave(sma, 'name', 'direct_reward', 'preamble', reward_delay, ...
                'sustain',  hit_valve_time, 'DOut', led_dio, 'DOut', water);
        end
        
        sma = add_scheduled_wave(sma, 'name', 'left_reward', 'preamble', reward_delay, ...
            'sustain',  LeftWValveTime, 'DOut', left1water);
        
        sma = add_scheduled_wave(sma, 'name', 'right_reward', 'preamble', reward_delay, ...
            'sustain',  RightWValveTime, 'DOut', right1water);
        
%         sma = add_scheduled_wave(sma, 'name', 'left_reward', 'preamble', reward_delay, ...
%             'sustain',  LeftWValveTime, 'DOut', left1led, 'DOut', left1water);
%         
%         sma = add_scheduled_wave(sma, 'name', 'right_reward', 'preamble', reward_delay, ...
%             'sustain',  RightWValveTime, 'DOut', right1led, 'DOut', right1water);
        
        if n_done_trials==0
            try
                if ~isnan(bSettings('get', 'DIOLINES', 'A5'));
                    CW = bSettings('get', 'DIOLINES', 'A5');
                    %  sma = StateMachineAssembler('full_trial_structure', 'use_happenings', 1, 'n_input_lines', 6);
                    sma = add_scheduled_wave(sma, 'name', 'forward', 'preamble', 0, 'sustain', .001,'DOut', CW, 'loop', -1 );
                    
                    sma = add_state(sma, 'name', 'MoveForward', ...
                        'output_actions', {'SchedWaveTrig', '+forward'}, ...
                        'input_to_statechange', {'Ahi', 'Stop'});
                    
                    sma = add_state(sma, 'name', 'Stop', 'self_timer', 0.001, ...
                        'output_actions', {'SchedWaveTrig', '-forward'}, ...
                        'input_to_statechange', {'Tup', 'wait_for_cpoke'});
                end
            catch
            end
        end
        
        %% STATES for Training stage 1, grow delay time, light chasing
        
        if value(training_stage) == 1
            sma = add_state(sma,'name','wait_for_cpoke',...
                'self_timer',wait_for_cpoke_timeout,...
                'output_actions',{'SoundOut',-nic_sound_id},...
                'input_to_statechange',{'Tup','timeout_state'; ...
                'Chi','nic_prestim'});
            
            sma = add_state(sma,'name','nic_prestim','self_timer',0.001,...
                'output_actions',{'SoundOut',nic_sound_id},...
                'input_to_statechange',{'Clo','wait_for_cpoke';...
                'Tup','current_state+1'});
            
            sma = add_state(sma,'name','nic','self_timer',nic_time,...
                'input_to_statechange',{'Clo',cpoke_out_state;...
                'Tup','wait_for_cout'});
            
            sma = add_state(sma,'name','wait_for_cout',...
                'output_actions',{'SoundOut',-nic_sound_id},...
                'input_to_statechange',{'Clo','wait_for_spoke'});
            
            %% States for training stages 2: foraging
            
        elseif value(training_stage)==2
            sma = add_state(sma,'name','wait_for_cpoke',...
                'self_timer',wait_for_cpoke_timeout,...
                'output_actions',{'SoundOut',-nic_sound_id},...
                'input_to_statechange',{'Tup','timeout_state'; 'Chi', 'current_state+1'});
            
            sma = add_state(sma,'name','nic_prestim','self_timer',0.001,...
                'output_actions',{'SoundOut',nic_sound_id},...
                'input_to_statechange',{'Clo','violation_state';...
                'Tup','current_state+1'});
            
            
            sma = add_state(sma,'name','nic','self_timer', nic_time,...
                'input_to_statechange',{'Clo', 'violation_state';...
                'Tup','wait_for_cout'});
            
            sma = add_state(sma,'name','wait_for_cout',...
                'output_actions',{'SoundOut',-nic_sound_id}, ...
                'input_to_statechange',{'Clo','wait_for_spoke'});
        else
            error('Training Stage Invalid or Unspecified')
        end
        
        
        if ignore_errors==1
            error_state='current_state';
        else
            error_state='error_state';
        end
        
        % if the slot was not entered:
        if value(training_stage)==1
            sma = add_state(sma,'name','wait_for_spoke','self_timer',wait_for_spoke_timeout,...
                'output_actions',{'DOut',led_dio},...
                'input_to_statechange',{correct_response, 'hit_state';...
                error_response,error_state;...
                'Tup','timeout_state'});
            
            sma = add_state(sma,'name','hit_state','self_timer',reward_delay+hit_valve_time+0.1,...
                'output_actions',{'SoundOut',hit_sound_id;...
                'SchedWaveTrig','direct_reward'},...
                'input_to_statechange',{'Tup','clean_up_state'});
            
        elseif value(training_stage)==2
            sma = add_state(sma,'name','wait_for_spoke','self_timer',wait_for_spoke_timeout,...
                'input_to_statechange',{'Lhi', 'left_choice';...
                'Rhi', 'right_choice';...
                'Tup','timeout_state'});
            
            sma = add_state(sma, 'name', 'left_choice', 'self_timer', .001, ...
                'output_actions', {'SchedWaveTrig', 'left_reward'; 'SoundOut', lsound}, ...
                'input_to_statechange', {'Tup', 'clean_up_state'});
            
            sma = add_state(sma, 'name', 'right_choice', 'self_timer', .001, ...
                'output_actions', {'SchedWaveTrig', 'right_reward'; 'SoundOut', rsound}, ...
                'input_to_statechange', {'Tup', 'clean_up_state'});
        end
        
        sma = add_state(sma,'name','error_state','self_timer',error_iti,...
            'output_actions',{'SoundOut',err_sound_id},...
            'input_to_statechange',{'Tup','clean_up_state'});
        
        sma = add_state(sma,'name','timeout_state','self_timer',1,...
            'output_actions',{'SoundOut',to_sound_id},...
            'input_to_statechange',{'Tup','clean_up_state'});
        
        sma = add_multi_sounds_state(sma,[-nic_sound_id viol_sound_id],...
            'self_timer',violation_iti,...
            'state_name','violation_state','return_state','clean_up_state');
        
        sma = add_multi_sounds_state(sma,[-to_sound_id -viol_sound_id -hit_sound_id -err_sound_id],...
            'state_name','clean_up_state','return_state','check_next_trial_ready');
        
        if value(training_stage)<=1
            dispatcher('send_assembler', sma, {'hit_state', 'error_state', 'violation_state','timeout_state'});
        elseif value(training_stage)>1
            dispatcher('send_assembler', sma, {'left_choice', 'right_choice', 'violation_state','timeout_state'});
        end
        
        
    otherwise
        warning('do not know how to do %s',action);
end
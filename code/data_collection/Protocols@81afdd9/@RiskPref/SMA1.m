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
        %nic_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'NICSound');
        hit_high_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'HitHighSound');
        hit_low_sound_id = SoundManagerSection(obj, 'get_sound_id', 'HitLowSound');
        err_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'ErrorSound');
        viol_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'ViolationSound');
        to_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'TimeoutSound');
        leftlow_id = SoundManagerSection(obj, 'get_sound_id', 'LeftLow');
        lefthigh_id = SoundManagerSection(obj, 'get_sound_id', 'LeftHigh');
        rightlow_id = SoundManagerSection(obj, 'get_sound_id', 'RightLow');
        righthigh_id = SoundManagerSection(obj, 'get_sound_id', 'RightHigh');
        go_sound_id = SoundManagerSection(obj, 'get_sound_id', 'GoSound');
        
        % Declare variables
        % These will get moved to other functions as SoloParamHandles.
        
        if allow_nic_breaks==1
            cpoke_out_state='current_state';
        else
            cpoke_out_state='violation_state';
        end
        
        if value(training_stage)==1
            [LeftWValveTime, RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
            [l_ul, r_ul] = WaterValvesSection(obj, 'get_water_volumes');
            this_left_volume.value = l_ul;
            this_right_volume.value = r_ul;
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
        elseif value(training_stage)==2 || value(training_stage)==3 && value(forced_choice==1) %forced choice trials only. only one side will be rewarded.
            if rand<value(bias_coin);
                this_trial = 'l';
                correct_response = 'Lhi';
                led_dio=left1led;
                water=left1water;
                % hit_valve_time = LeftWValveTime;
                error_response = 'Rhi';
                if strcmp(value(this_left_var), 'low');
                    thissound = leftlow_id;
                    %    rightsound = [];
                    if rand>0.5
                        l_ul = max(value(LowVarVol));
                        left_hit.value = 1;
                        r_ul = 0;
                        lsound = hit_high_sound_id;
                        rsound = err_sound_id;
                    else
                        l_ul = min(value(LowVarVol));
                        left_hit.value = 1;
                        r_ul = 0;
                        lsound = hit_low_sound_id;
                        rsound = err_sound_id;
                    end
                elseif strcmp(value(this_left_var), 'high');
                    thissound = lefthigh_id;
                    if rand>0.5
                        l_ul = max(value(HighVarVol));
                        left_hit.value = 1;
                        r_ul = 0;
                        lsound = hit_high_sound_id;
                        rsound = err_sound_id;
                    else
                        l_ul = min(value(HighVarVol));
                        left_hit.value = 0;
                        r_ul = 0;
                        lsound = hit_low_sound_id;
                        rsound = err_sound_id;
                    end
                end
            else
                this_trial = 'r';
                correct_response = 'Rhi';
                led_dio=right1led;
                water=right1water;
                error_response = 'Lhi';
                if strcmp(value(this_right_var), 'low');
                    thissound = rightlow_id;
                    if rand>0.5
                        r_ul = max(value(LowVarVol));
                        right_hit.value = 1;
                        l_ul = 0;
                        rsound = hit_high_sound_id;
                        lsound = err_sound_id;
                    else
                        r_ul = min(value(LowVarVol));
                        right_hit.value = 1;
                        l_ul = 0;
                        rsound = hit_low_sound_id;
                        lsound = err_sound_id;
                    end
                elseif strcmp(value(this_right_var), 'high');
                    thissound = righthigh_id;
                    if rand>0.5
                        r_ul = max(value(HighVarVol));
                        right_hit.value = 1;
                        l_ul = 0;
                        rsound = hit_high_sound_id;
                        lsound = err_sound_id;
                    else
                        r_ul = min(value(HighVarVol));
                        right_hit.value = 0;
                        l_ul = 0;
                        rsound = hit_low_sound_id;
                        lsound = err_sound_id;
                    end
                end
            end
            
            [x, y] = WaterValvesSection(obj, 'set_water_amounts', l_ul, r_ul);
            this_left_volume.value = l_ul;
            this_right_volume.value = r_ul;
            
        elseif value(training_stage==3) && value(forced_choice==0); %now introduce both options on most trials.
            this_trial = 'f'; %there is no correct answer.
            
            if rand < .5 %left comes first.
                if strcmp(value(this_left_var), 'low');
                    first_sound.value = 'leftlow';
                    firstsound = leftlow_id;
                    if rand>0.5
                        l_ul = max(value(LowVarVol));
                        left_hit.value = 1;
                        lsound = hit_high_sound_id;
                    else
                        l_ul = min(value(LowVarVol));
                        left_hit.value = 1;
                        lsound = hit_low_sound_id;
                    end
                elseif strcmp(value(this_left_var), 'high');
                    first_sound.value = 'lefthigh';
                    firstsound = lefthigh_id;
                    if rand>0.5
                        l_ul = max(value(HighVarVol));
                        left_hit.value = 1;
                        lsound = hit_high_sound_id;
                    else
                        l_ul = min(value(HighVarVol));
                        left_hit.value = 0;
                        lsound = hit_low_sound_id;
                    end
                end
                if strcmp(value(this_right_var), 'low');
                    second_sound.value = 'rightlow';
                    secondsound = rightlow_id;
                    if rand>0.5
                        r_ul = max(value(LowVarVol));
                        right_hit.value = 1;
                        rsound = hit_high_sound_id;
                    else
                        r_ul = min(value(LowVarVol));
                        right_hit.value = 1;
                        rsound = hit_low_sound_id;
                    end
                elseif strcmp(value(this_right_var), 'high');
                    second_sound.value = 'righthigh';
                    secondsound = righthigh_id;
                    if rand>0.5
                        r_ul = max(value(HighVarVol));
                        right_hit.value = 1;
                        rsound = hit_high_sound_id;
                    else
                        r_ul = min(value(HighVarVol));
                        right_hit.value = 0;
                        rsound = hit_low_sound_id;
                    end
                end
            else %right comes first.
                if strcmp(value(this_left_var), 'low');
                    second_sound.value = 'leftlow';
                    secondsound = leftlow_id;
                    if rand>0.5
                        l_ul = max(value(LowVarVol));
                        left_hit.value = 1;
                        lsound = hit_high_sound_id;
                    else
                        l_ul = min(value(LowVarVol));
                        left_hit.value = 1;
                        lsound = hit_low_sound_id;
                    end
                elseif strcmp(value(this_left_var), 'high');
                    second_sound.value = 'lefthigh';
                    secondsound = lefthigh_id;
                    if rand>0.5
                        l_ul = max(value(HighVarVol));
                        left_hit.value = 1;
                        lsound = hit_high_sound_id;
                    else
                        l_ul = min(value(HighVarVol));
                        left_hit.value = 0;
                        lsound = hit_low_sound_id;
                    end
                end
                if strcmp(value(this_right_var), 'low');
                    first_sound.value = 'rightlow';
                    firstsound = rightlow_id;
                    if rand>0.5
                        r_ul = max(value(LowVarVol));
                        right_hit.value = 1;
                        rsound = hit_high_sound_id;
                    else
                        r_ul = min(value(LowVarVol));
                        right_hit.value = 1;
                        rsound = hit_low_sound_id;
                    end
                elseif strcmp(value(this_right_var), 'high');
                    first_sound.value = 'righthigh';
                    firstsound = righthigh_id;
                    if rand>0.5
                        r_ul = max(value(HighVarVol));
                        right_hit.value = 1;
                        rsound = hit_high_sound_id;
                    else
                        r_ul = min(value(HighVarVol));
                        right_hit.value = 0;
                        rsound = hit_low_sound_id;
                    end
                end
                
            end
            
            [x, y] = WaterValvesSection(obj, 'set_water_amounts', l_ul, r_ul);
            this_left_volume.value = l_ul;
            this_right_volume.value = r_ul;
            
        end
        
        
        [LeftWValveTime, RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
        
        if value(training_stage)>=2
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
        
        
        % if value(training_stage>=2)
        
        if value(forced_choice)==1 && value(training_stage>=2);
            sma = add_scheduled_wave(sma, 'name', 'forced_choice_wave', 'preamble', .2, 'sustain', .3, ...
                'sound_trig', thissound, 'loop', 0);
        else
            sma = add_scheduled_wave(sma, 'name', 'forced_choice_wave', 'preamble', .001, 'sustain', .001, 'loop', 0);
        end
        
        if value(forced_choice)==0 && value(training_stage==3);
            if strcmp(value(first_sound), 'rightlow') | strcmp(value(first_sound), 'righthigh');
                sma = add_scheduled_wave(sma, 'name', 'sound1', 'preamble', .2, 'sustain', .3, ...
                    'sound_trig', firstsound, 'DOut', right1led, 'loop', 0);
                sma = add_scheduled_wave(sma, 'name', 'sound2', 'preamble', .8, 'sustain', .3, ...
                    'sound_trig', secondsound,'DOut', left1led, 'loop', 0);
            elseif strcmp(value(first_sound), 'leftlow') | strcmp(value(first_sound), 'lefthigh');
                sma = add_scheduled_wave(sma, 'name', 'sound1', 'preamble', .2, 'sustain', .3, ...
                    'sound_trig', firstsound, 'DOut', left1led, 'loop', 0);
                sma = add_scheduled_wave(sma, 'name', 'sound2', 'preamble', .8, 'sustain', .3, ...
                    'sound_trig', secondsound,'DOut', right1led, 'loop', 0);
            end
        else
            sma = add_scheduled_wave(sma, 'name', 'sound1', 'preamble', .001, 'sustain', .001, 'loop', 0);
            sma = add_scheduled_wave(sma, 'name', 'sound2', 'preamble', .001, 'sustain', .001, 'loop', 0);
        end
        
        
        
        
        if n_done_trials==0
            try
                if ~isnan(bSettings('get', 'DIOLINES', 'A5'));
                    CW = bSettings('get', 'DIOLINES', 'A5');
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
                'output_actions',{'DOut',center1led},...
                'input_to_statechange',{'Tup','timeout_state'; ...
                'Chi','nic_prestim'});
            
            sma = add_state(sma,'name','nic_prestim','self_timer',0.001,...
                'input_to_statechange',{'Clo','wait_for_cpoke';...
                'Tup','current_state+1'});
            
            sma = add_state(sma,'name','nic','self_timer',nic_time,...
                'output_actions', {'SchedWaveTrig', 'forced_choice_wave'},...
                'input_to_statechange',{'Clo',cpoke_out_state;...
                'Tup','wait_for_cout'});
            
            sma = add_state(sma,'name','wait_for_cout',...
                'output_actions',{'DOut',center1led; 'SoundOut', go_sound_id},...
                'input_to_statechange',{'Clo','wait_for_spoke'});
            
            %% States for training stages 2: introduce sounds/gambles in forced choice trials only.
            
        elseif value(training_stage)>=2
            sma = add_state(sma,'name','wait_for_cpoke',...
                'self_timer',wait_for_cpoke_timeout,...
                'output_actions',{'DOut',center1led},...
                'input_to_statechange',{'Tup','timeout_state'; 'Chi', 'current_state+1'});
            
            sma = add_state(sma,'name','nic_prestim','self_timer',0.001,...
                'output_actions',{'SchedWaveTrig', 'forced_choice_wave+sound1+sound2'},...
                'input_to_statechange',{'Clo','violation_state';...
                'Tup','current_state+1'});
            
            
            sma = add_state(sma,'name','nic','self_timer', nic_time,...
                'input_to_statechange',{'Clo', 'violation_state';...
                'Tup','wait_for_cout'});
            
            sma = add_state(sma,'name','wait_for_cout',...
                'output_actions',{'DOut',center1led; 'SoundOut', go_sound_id}, ...
                'input_to_statechange',{'Clo','wait_for_spoke'});
        else
            error('Training Stage Invalid or Unspecified')
        end
        
        
        %         if ignore_errors==1
        %             error_state='current_state';
        %         else
        error_state='error_state';
        %   end
        
        % if the slot was not entered:
        if value(training_stage)==1
            sma = add_state(sma,'name','wait_for_spoke','self_timer',wait_for_spoke_timeout,...
                'output_actions',{'DOut',led_dio},...
                'input_to_statechange',{correct_response, 'hit_state';...
                error_response,error_state;...
                'Tup','timeout_state'});
            
            sma = add_state(sma,'name','hit_state','self_timer',reward_delay+hit_valve_time+0.1,...
                'output_actions',{'SoundOut',hit_high_sound_id;...
                'SchedWaveTrig','direct_reward'},...
                'input_to_statechange',{'Tup','clean_up_state'});
            
        elseif value(training_stage)>=2
            
            if value(forced_choice)==1
                
                sma = add_state(sma,'name','wait_for_spoke','self_timer',wait_for_spoke_timeout,...
                    'output_actions',{'DOut',led_dio},...
                    'input_to_statechange',{'Lhi', 'left_choice';...
                    'Rhi', 'right_choice';...
                    'Tup','timeout_state'});
            else 
                sma = add_state(sma,'name','wait_for_spoke','self_timer',wait_for_spoke_timeout,...
                    'input_to_statechange',{'Lhi', 'left_choice';...
                    'Rhi', 'right_choice';...
                    'Tup','timeout_state'});
            end
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
        
        sma = add_multi_sounds_state(sma,[-leftlow_id -lefthigh_id -rightlow_id -righthigh_id viol_sound_id],...
            'self_timer',violation_iti,...
            'state_name','violation_state','return_state','clean_up_state');
        
        sma = add_multi_sounds_state(sma,[-leftlow_id -lefthigh_id -rightlow_id -righthigh_id -to_sound_id -viol_sound_id...
            -hit_high_sound_id -hit_low_sound_id -err_sound_id],...
            'state_name','clean_up_state','return_state','check_next_trial_ready');
        
        if value(training_stage)<=1
            dispatcher('send_assembler', sma, {'hit_state', 'error_state', 'violation_state','timeout_state'});
        elseif value(training_stage)>1
            dispatcher('send_assembler', sma, {'left_choice', 'right_choice', 'violation_state','timeout_state'});
        end
        
        
    otherwise
        warning('do not know how to do %s',action);
end
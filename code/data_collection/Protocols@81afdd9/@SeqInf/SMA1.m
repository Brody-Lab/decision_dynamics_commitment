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
        
        
        A  = SoundManagerSection(obj, 'get_sound_id', 'NICSound');
        B  = SoundManagerSection(obj, 'get_sound_id', 'ToneSound');
        C  = SoundManagerSection(obj, 'get_sound_id', 'ErrorSound');
        X  = SoundManagerSection(obj, 'get_sound_id', 'GoSound');
        Y  = SoundManagerSection(obj, 'get_sound_id', 'TimeoutSound');
        Z  = SoundManagerSection(obj, 'get_sound_id', 'HitSound');
        
        
        Rsoundout=eval(Rsound);
        Lsoundout=eval(Lsound);
        
        [LeftWValveTime, RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
        
        sma = add_scheduled_wave(sma, 'name', 'poketime', 'preamble', value(nic_time),'sustain', .001 );
        sma = add_scheduled_wave(sma, 'name', 'firstsound', 'preamble', .4,'sustain', .001 );
        sma = add_scheduled_wave(sma, 'name', 'intersound', 'preamble', .7,'sustain', .001 );
        
        if n_done_trials==0
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
        end
        
        
        sma = add_state(sma,'name','wait_for_cpoke',...
            'output_actions',{'DOut', center1led},...
            'input_to_statechange',{'Chi','in_cpoke'});
        
        sma = add_state(sma,'name','in_cpoke','self_timer',.001,...
            'output_actions',{'SchedWaveTrig','poketime'},...
            'input_to_statechange',{'Tup','first_sound'});
        
        sma = add_state(sma,'name','first_sound','self_timer',.001,...
            'output_actions',{'SoundOut',Lsoundout ; 'SchedWaveTrig','firstsound'},...
            'input_to_statechange',{'Clo','legal_c_break';...
            'poketime_Out','wait_for_spoke';...
            'Tup','backinpoke'});
        
        sma = add_state(sma,'name','backinpoke',...
            'input_to_statechange',{'Clo','legal_c_break';...
            'firstsound_Out','inter_sound';...
            'intersound_Out','second_sound';...
            'poketime_Out','wait_for_spoke'});
        
        sma = add_state(sma,'name','inter_sound','self_timer',.001,...
            'output_actions',{'SchedWaveTrig','intersound';...
            'SoundOut',-Lsoundout},...
            'input_to_statechange',{'Clo','violation';...
            'Tup','backinpoke';...
            'poketime_Out','wait_for_spoke'});
        
        sma = add_state(sma,'name','second_sound','self_timer',.001,...
            'output_actions',{'SoundOut',Rsoundout},...
            'input_to_statechange',{'Clo','legal_c_break';...
            'Tup','backinpoke';...
            'poketime_Out','wait_for_spoke'});
        
        sma = add_state(sma,'name','legal_c_break','self_timer',.025,...
            'input_to_statechange',{'Chi','backinpoke';...
            'poketime_Out','wait_for_spoke';...
            'intersound_Out','second_sound';...
            'firstsound_Out','inter_sound';...
            'Tup','violation'});

        %% STATES for Training stage 1, grow delay time, light chasing
        
        if value(training_stage) == 1
            
            if strcmp('l',value(Corr))
                goodpoke = 'Lhi';
                led_dio=left1led;
                water=left1water;
                hit_valve_time = LeftWValveTime;
                badpoke = 'Rhi';
                
            elseif strcmp('r',value(Corr))
                goodpoke = 'Rhi';
                led_dio=right1led;
                water=right1water;
                hit_valve_time = RightWValveTime;
                badpoke = 'Lhi';
            end
            
            
            
            sma = add_state(sma,'name','wait_for_spoke',...
                'output_actions',{'DOut', led_dio;},...
                'input_to_statechange',{goodpoke,'reward'; badpoke,'error'});
            
            
            sma = add_state(sma,'name','reward','self_timer',hit_valve_time,...
                'output_actions',{'DOut',water;},...
                'input_to_statechange',{'Tup','clean_up_state'});
            
            
        elseif value(training_stage)>1
            
            if strcmp('l',value(Corr))
                goodpoke = 'Lhi';
                led_dio=left1led;
                water=left1water;
                hit_valve_time = LeftWValveTime;
                badpoke = 'Rhi';
                
            elseif strcmp('r',value(Corr))
                goodpoke = 'Rhi';
                led_dio=right1led;
                water=right1water;
                hit_valve_time = RightWValveTime;
                badpoke = 'Lhi';
            end
            
            
            sma = add_state(sma,'name','wait_for_spoke',...
                'output_actions',{'DOut', right1led+left1led},...
                'input_to_statechange',{goodpoke,'reward'; badpoke,'error'});
            
            sma = add_state(sma,'name','reward','self_timer',hit_valve_time,...
                'output_actions',{'DOut',water; },...
                'input_to_statechange',{'Tup','clean_up_state'});
            
        %else
           % error('Training Stage Invalid or Unspecified.  Check back later!')
            
        end
        
        sma = add_multi_sounds_state(sma,[-Lsoundout -Rsoundout ],...
            'state_name','error','return_state','error_timeout');
        
                    sma = add_state(sma,'name','error_timeout','self_timer',5,...
                'input_to_statechange',{'Tup','clean_up_state'});
        
        
        sma = add_multi_sounds_state(sma,[-Lsoundout -Rsoundout ],...
            'state_name','violation','return_state','clean_up_state');
        
        
        sma = add_multi_sounds_state(sma,[-Lsoundout -Rsoundout ],...
            'state_name','clean_up_state','return_state','check_next_trial_ready');
        
        
        dispatcher('send_assembler', sma, {'reward','error','violation'});
        
        
    otherwise
        warning('do not know how to do %s',action);
end
function  [] =  SMA1(obj, action)
% May 2014 BBS

GetSoloFunctionArgs;


switch action
    case 'init',
        
        feval(mfilename, obj, 'next_trial');
        
        %% next_trial
    case 'next_trial',
        
        % Setup water
        min_time= 2.5E-4;  % This is less than the minumum time allowed for a state transition.
        
        %Output Lines
        left1led           = bSettings('get', 'DIOLINES', 'left1led');
        center1led         = bSettings('get', 'DIOLINES', 'center1led');
        right1led          = bSettings('get', 'DIOLINES', 'right1led');
        left1water         = bSettings('get', 'DIOLINES', 'left1water');
        right1water        = bSettings('get', 'DIOLINES', 'right1water');
        CW                 = bSettings('get', 'DIOLINES', 'A5');              %Ch4  5V
        CCW                = bSettings('get', 'DIOLINES', 'B5');              %Ch5  5V
        
        % INPUT LINES
        sma = StateMachineAssembler('full_trial_structure', 'use_happenings', 1,'n_input_lines', 6); %
        [LeftWValveTime RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
        %[LeftWMult RightWMult] = SidesSection(obj, 'get_water_mult');
        
        % Sounds
        nic_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'NICSound');
        hit_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'HitSound');
        
        
        
        % Declare variables
        % These will get moved to other functions as SoloParamHandles.
        
        if rand<0.5
            correct_response='Rhi';
            led_dio=right1led;
            hit_dio=right1water;
            hit_valve_time=RightWValveTime*value(wtr_mult);
            %this_trial='r';
        else
            correct_response='Lhi';
            led_dio=left1led;
            hit_dio=left1water;
            hit_valve_time=LeftWValveTime*value(wtr_mult);
            %this_trial='l';
        end
        
        
        
       % SidesSection(obj,'update_trial_history',this_trial);
        
        %----------------Stage Commands--------------------------------------
        sma = add_scheduled_wave(sma, 'name', 'forward',            'preamble', 0, 'sustain', .001,'DOut', CW, 'loop', -1 );
        sma = add_scheduled_wave(sma, 'name', 'backward',           'preamble', 0, 'sustain', .001,'DOut', CCW, 'loop', NosPos);
        sma = add_scheduled_wave(sma, 'name', 'step',               'preamble', 0, 'sustain', .001,'DOut', CCW, 'loop', value(StepSize));
        
        
        %Initialization states for moving the center poke stage
        if n_done_trials==0
            sma = add_state(sma, 'name', 'MoveForward', ...
                'output_actions', {'SchedWaveTrig', '+forward'}, ...
                'input_to_statechange', {'Ahi', 'Stop'});
            
            sma = add_state(sma, 'name', 'Stop', 'self_timer', 0.001, ...
                'output_actions', {'SchedWaveTrig', '-forward'}, ...
                'input_to_statechange', {'Tup', 'MoveBack'});
            
            sma = add_state(sma, 'name', 'MoveBack', 'self_timer', Value(NosPos)*0.002, ... %increased the duration of this state BBS 9.25.13
                'output_actions', {'SchedWaveTrig','+backward'}, ...
                'input_to_statechange', {'Tup', 'wait_for_cpoke'});
        end  %End of move stage, begining of behavioral trial
        
        %% STATES for Training stage 1
        if value(training_stage) == 1
            if n_done_trials>0 && value(StepNextTrial)==1
                sma = add_state(sma,'name','step_stage',...
                    'self_timer',value(StepSize)*0.001,...
                    'output_actions',{'SchedWaveTrig','+step'},...
                    'input_to_statechange',{'Tup','wait_for_cpoke'});
            end
            sma = add_state(sma,'name','wait_for_cpoke',...
                'input_to_statechange',{'Dhi','nic_sound';...
                'Chi','nic_sound'});
            
            sma = add_state(sma,'name','nic_sound','self_timer',.05,...
                'output_actions',{'SoundOut',hit_sound_id},...
                'input_to_statechange',{'Tup','cpoke_out'});
            
            sma = add_state(sma,'name','cpoke_out','self_timer',.05,...
                'output_actions',{'SoundOut',-hit_sound_id},...
                'input_to_statechange',{'Tup','wait_for_spoke'});
            
            sma = add_state(sma,'name','wait_for_spoke',...
                'output_actions',{'DOut',led_dio},...
                'input_to_statechange',{correct_response, 'hit_state'});
            
            sma = add_state(sma,'name','hit_state','self_timer',hit_valve_time,...
                'output_actions',{'DOut',hit_dio},...
                'input_to_statechange',{'Tup','check_next_trial_ready'});

        elseif value(training_stage)==2
            sma = add_state(sma,'name','wait_for_spoke',...
                'output_actions',{'DOut',led_dio},...
                'input_to_statechange',{correct_response, 'hit_state'});
            
            sma = add_state(sma,'name','hit_state','self_timer',hit_valve_time,...
                'output_actions',{'DOut',hit_dio},...
                'input_to_statechange',{'Tup','wait_for_cpoke'});
            
            sma = add_state(sma,'name','wait_for_cpoke',...
                'input_to_statechange',{'Dhi','nic_sound'});
            
            sma = add_state(sma,'name','nic_sound','self_timer',10,...
                'output_actions',{'SoundOut',nic_sound_id},...
                'input_to_statechange',{'Dlo','cpoke_out',...
                'Tup','cpoke_out'});
            
            sma = add_state(sma,'name','cpoke_out','self_timer',0.05,...
                'output_actions',{'SoundOut',-nic_sound_id},...
                'input_to_statechange',{'Tup','wait_for_side_light'});
            
            sma = add_state(sma,'name','wait_for_side_light','self_timer',reward_delay,...
                'input_to_statechange',{'Tup','check_next_trial_ready'});
            
        end
        dispatcher('send_assembler', sma, {'cpoke_out'});
end


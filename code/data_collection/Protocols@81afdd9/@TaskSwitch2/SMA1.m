function  [] =  SMA1(obj, action)

GetSoloFunctionArgs;


switch action

    case 'init',

        feval(mfilename, obj, 'next_trial');


    case 'next_trial',

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%% SETUP THE HARDWARE %%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%% minimum time
        min_time= 2.5E-4;  % This is less than the minumum time allowed for a state transition.

        %%% define LEDs and water lines
        left1led           = bSettings('get', 'DIOLINES', 'left1led');
        center1led         = bSettings('get', 'DIOLINES', 'center1led');
        right1led          = bSettings('get', 'DIOLINES', 'right1led');
        left1water         = bSettings('get', 'DIOLINES', 'left1water');
        right1water        = bSettings('get', 'DIOLINES', 'right1water');

        %%% define state machine assembler
        sma = StateMachineAssembler('full_trial_structure','use_happenings', 1);

        %%% get water valve opening times (based on calibration)
        %%% water reward gets larger as a "hit streak" gets longer (see @water)
        [LeftWValveTime RightWValveTime] = WaterValvesSection(obj, 'get_water_times', value(hit_streak));

        %%% Antibias: change the amount of water reward for each side
        [LeftWMult, RightWMult] = StimulusSection(obj, 'get_water_mult');

        %%% Increase water reward for incoherent trials
        IncoherentRewardMult = StimulusSection(obj, 'get_water_incoh');

        %%% Increase water reward for incoherent trials
        OverallWaterMult = StimulusSection(obj, 'get_overall_water_mult');

        %%% Increase error delay for incoherent trials
        IncoherentDelay = StimulusSection(obj, 'get_delay_incoh');
        
        
        
        %%% set the water reward
        if strcmp(value(ThisSide),'LEFT')
            correct_response='Lhi';
            error_response='Rhi';
            hit_dio=left1water;
            hit_led=left1led;
            hit_valve_time=LeftWValveTime*LeftWMult*IncoherentRewardMult*OverallWaterMult;
        elseif strcmp(value(ThisSide),'RIGHT')
            correct_response='Rhi';
            error_response='Lhi';
            hit_dio=right1water;
            hit_led=right1led;
            hit_valve_time=RightWValveTime*RightWMult*IncoherentRewardMult*OverallWaterMult;
        else
            error('!!!')
        end
        
        

        
        %%% Setup sounds
        hit_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'HitSound');
        err_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'ErrorSound');

        viol_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'ViolationSound');
        timeout_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'TimeoutSound');

        task1_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'Task1Sound');
        task2_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'Task2Sound');

        
        %%% setup variables according to current task
        if(strcmp(value(ThisTask),'Direction'))
            task_sound_id=task1_sound_id;
            helper_lights=value(helper_lights_dir);
            error_forgiveness=value(error_forgiveness_dir);
            wait_delay=value(wait_delay_dir);
            
            centerlight=center1led+left1led+right1led;
            centerlight2=center1led;
            
            wait_for_cpoke2='wait_for_cpoke_dir';
        elseif(strcmp(value(ThisTask),'Frequency'))
            task_sound_id=task2_sound_id;
            helper_lights=value(helper_lights_freq);
            error_forgiveness=value(error_forgiveness_freq);
            wait_delay=value(wait_delay_freq);
            
            centerlight=center1led;
            centerlight2=center1led;
            
            wait_for_cpoke2='wait_for_cpoke_freq';
        else
            error('what task?')
        end

        
        
        %%% setup the stimulus
        stimulus_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'StimulusSound');
        

        %%% setup the reward
        sma = add_scheduled_wave(sma, 'name', 'direct_reward', 'preamble', value(reward_delay), ...
            'sustain', hit_valve_time, 'DOut', hit_dio);

        
        
        if(helper_lights)
            sidelights=hit_led;       
        else
            sidelights=left1led+right1led;
        end
            
        
        
        
        
        %%%%%%%%%%%%%%%%%%%% WAIT FOR CPOKE %%%%%%%%%%%%%%%%%%%%
        
%         sma = add_state(sma,'name','wait_for_cpoke',...
%             'self_timer',value(wait_for_cpoke_timeout),...
%             'output_actions',{'SoundOut',task_sound_id;'DOut', centerlight },...
%             'input_to_statechange',{'Tup','timeout_state'; ...
%             'Chi','nic_prestim'});


        sma = add_state(sma,'name','wait_for_cpoke',...
            'self_timer',min_time,...
            'input_to_statechange',{'Tup',wait_for_cpoke2});
       
        
        sma = add_state(sma,'name','wait_for_cpoke_dir',...
            'self_timer',value(wait_for_cpoke_timeout),...
            'output_actions',{'SoundOut',task_sound_id;'DOut', centerlight },...
            'input_to_statechange',{'Tup','timeout_state'; ...
            'Chi','nic_prestim'});


        sma = add_state(sma,'name','wait_for_cpoke_freq',...
            'self_timer',value(wait_for_cpoke_timeout),...
            'output_actions',{'SoundOut',task_sound_id;'DOut', centerlight },...
            'input_to_statechange',{'Tup','timeout_state'; ...
            'Chi','nic_prestim'});

            
            

        %%%%%%%%%%%%%%%%%%%% NIC PRESTIM %%%%%%%%%%%%%%%%%%%%
        
        sma = add_state(sma,'name','nic_prestim','self_timer',value(settling_time),...
            'output_actions',{'DOut', centerlight2 },...
            'input_to_statechange',{'Clo','wait_for_cpoke';...
            'Tup','cpoke'});

        

        %%%%%%%%%%%%%%%%%%%% CPOKE with legal breaks up to 0.1 %%%%%%%%%%%%%%
        
        legal_cbreak=0.1;
        
        sma = add_scheduled_wave(sma,'name','cpoke_timer','preamble', value(nose_in_center)+legal_cbreak);
        
        % trigger the start of the timer:
        sma = add_state(sma, 'name', 'cpoke', 'self_timer', min_time, ...
            'output_actions', {'SoundOut',stimulus_sound_id; ...
            'SchedWaveTrig', 'cpoke_timer'; 'DOut', centerlight2}, ...
            'input_to_statechange', {'Cout', 'cpoke_out'; ...
                                     'Tup', 'cpoke_in'});


        sma = add_state(sma, 'name', 'cpoke_in', 'self_timer', 1000, ...
            'output_actions', {'DOut', centerlight2}, ...
            'input_to_statechange', {'Cout', 'cpoke_out'; ...
                                     'cpoke_timer_In', 'wait_for_cout'});

        sma = add_state(sma, 'name', 'cpoke_out', 'self_timer', legal_cbreak, ...
            'output_actions', {'DOut', centerlight2}, ...
            'input_to_statechange', {'Cin', 'cpoke_in'; ...
                                     'cpoke_timer_In', 'wait_for_cout';...
                                     'Tup', 'nic_error_state'});
        
        
        
        %%%%%%%%%%%%%%%%%%%% WAIT FOR COUT %%%%%%%%%%%%%%%%%%%%
        
        sma = add_state(sma,'name','wait_for_cout',...
            'input_to_statechange',{'Clo','wait_for_spoke'});

  

        if error_forgiveness==1
            error_state='wait_state';
        else
            error_state='error_state';
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%% WAIT FOR SPOKE %%%%%%%%%%%%%%%%%%%%
        
        if error_forgiveness==1
            % stimulus sound keeps going after rat steps out of cpoke
            sma = add_state(sma,'name','wait_for_spoke','self_timer',value(wait_for_spoke_timeout),...
                'output_actions',{'DOut',sidelights},...
                'input_to_statechange',{correct_response,'hit_state';...
                                        error_response,error_state;...
                                        'Tup','timeout_state'});
        else
            % as soon as rat steps out of cpoke, we stop stimulus sound
            sma = add_state(sma,'name','wait_for_spoke','self_timer',value(wait_for_spoke_timeout),...
                'output_actions',{'SoundOut',-stimulus_sound_id;'DOut',sidelights},...
                'input_to_statechange',{correct_response,'hit_state';...
                                        error_response,error_state;...
                                        'Tup','timeout_state'});
        end

        

        %%%%%%%%%%%%%%%%%%%% HIT STATE %%%%%%%%%%%%%%%%%%%%
        
        % first we turn off stimulus sound, in case it didn't happen before
        % (i.e. if error_forgiveness == 1)
        sma = add_state(sma,'name','hit_state','self_timer',min_time,...
            'output_actions',{'SoundOut',-stimulus_sound_id},...
            'input_to_statechange',{'Tup','hit_state2'});
        
        
        % we do the operations for the hit state
        sma = add_state(sma,'name','hit_state2','self_timer',value(reward_delay)+hit_valve_time+0.1,...
            'output_actions',{'SoundOut',hit_sound_id;'DOut',hit_led;...
            'SchedWaveTrig','direct_reward'},...
            'input_to_statechange',{'Tup','clean_up_state'});
        

        

        %%%%%%%%%%%%%%%%%%%% ERROR STATE %%%%%%%%%%%%%%%%%%%%

        sma = add_state(sma,'name','error_state','self_timer',value(error_delay)+IncoherentDelay,...
            'output_actions',{'SoundOut',err_sound_id},...
            'input_to_statechange',{'Tup','clean_up_state'});

        
        sma = add_state(sma,'name','wait_state','self_timer',wait_delay+IncoherentDelay,...            
            'input_to_statechange',{'Tup','wait_for_spoke'});

        

        %%%%%%%%%%%%%%%%%%%% NIC ERROR STATE %%%%%%%%%%%%%%%%%%%%
        
        sma = add_multi_sounds_state(sma,[-stimulus_sound_id viol_sound_id],...
            'self_timer',value(nic_delay),...
            'state_name','nic_error_state','return_state','clean_up_state');


        %%%%%%%%%%%%%%%%%%%% TIMEOUT STATE %%%%%%%%%%%%%%%%%%%%

        sma = add_state(sma,'name','timeout_state','self_timer',value(timeout_delay),...
            'output_actions',{'SoundOut',timeout_sound_id},...
            'input_to_statechange',{'Tup','clean_up_state'});

        
        %%%%%%%%%%%%%%%%%%%% CLEAN UP STATE %%%%%%%%%%%%%%%%%%%% 

        sma = add_multi_sounds_state(sma,[-stimulus_sound_id -timeout_sound_id -viol_sound_id -hit_sound_id -err_sound_id -task1_sound_id -task2_sound_id],...
            'state_name','clean_up_state','return_state','check_next_trial_ready');


        dispatcher('send_assembler', sma, {'hit_state2', 'error_state',...
            'nic_error_state','timeout_state'});

       
    case 'get'
        
        val=varargin{1};
        
        eval(['x=value(' val ');']);
        
       
    otherwise
        warning('do not know how to do %s',action);
end




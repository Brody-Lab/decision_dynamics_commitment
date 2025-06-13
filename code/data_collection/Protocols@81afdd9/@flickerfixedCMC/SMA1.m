function  [] =  SMA1(obj, action)
% Edited to allow centerport translation June 2013 BBS

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
        [LeftWMult RightWMult] = SidesSection(obj, 'get_water_mult');
        
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
        
        
        % There is something wrong with this code.
        % It is giving unequal # of trials so i will flip a coin and then
        % generate a trial with that side.
        
        
        is_done=false;
        
        % Note if nic_time is zero no flashes will be played.
        
        while ~is_done
            left_stim =(rand(1,ceil(nic_time/bin_size))<left_prob);
            right_stim=(rand(1,ceil(nic_time/bin_size))<right_prob);
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
            elseif rand<0.05 || nic_time==0   % if nic_time=0 OR on 5% of equal trials let it through
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
        
        hit_valve_time=hit_valve_time*bonus;
        
        sma = add_scheduled_wave(sma, 'name', 'direct_reward', 'preamble', reward_delay, ...
            'sustain', hit_valve_time, 'DOut', hit_dio);
        
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
            
            sma = add_state(sma, 'name', 'MoveBack', 'self_timer', value(NosPos)*0.001, ...
                'output_actions', {'SchedWaveTrig','+backward'}, ...
                'input_to_statechange', {'Tup', 'wait_for_cpoke'});
        end  %End of move stage, begining of behavioral trial
        
        %BEGIN FLICKR STATES
        if n_done_trials>0 && value(StepNextTrial)==1
            sma = add_state(sma,'name','step_stage',...
                'self_timer',value(StepSize)*0.001,...
                'output_actions',{'SchedWaveTrig','+step'},...
                'input_to_statechange',{'Tup','wait_for_cpoke'});
        end

%% STATES for Training stage 1 (called Training Stage 3 in Flickr)
        if value(training_stage) == 3
            sma = add_state(sma,'name','wait_for_cpoke',...
                'self_timer',wait_for_cpoke_timeout,...
                'output_actions',{'SoundOut',-nic_sound_id},...
                'input_to_statechange',{'Tup','timeout_state'; ...
                'Dhi','wait_for_spoke';...
                'Chi','nic_prestim'});
              
            sma = add_state(sma,'name','nic_prestim','self_timer',settling_time,...
                'output_actions',{'SoundOut',nic_sound_id},...
                'input_to_statechange',{'Clo','wait_for_cpoke';...
                'Tup','current_state+1'});
            
            
            for tx=1:numel(left_stim)
                % In each time bin add a state that is a left_light
                if left_stim(tx)==1 && right_stim(tx)==1
                    sma=add_state(sma,'name',sprintf('led%03g_B',tx),'self_timer',led_time,...
                        'output_actions',{'DOut',right1led+left1led},...
                        'input_to_statechange',{'Tup','current_state+1'; ...
                        'Clo',cpoke_out_state});
                elseif left_stim(tx)==1 && right_stim(tx)==0
                    sma=add_state(sma,'name',sprintf('led%03g_L',tx),'self_timer',led_time,...
                        'output_actions',{'DOut',left1led},...
                        'input_to_statechange',{'Tup','current_state+1'; ...
                        'Clo',cpoke_out_state});
                    
                elseif left_stim(tx)==0 && right_stim(tx)==1
                    sma=add_state(sma,'name',sprintf('led%03g_R',tx),'self_timer',led_time,...
                        'output_actions',{'DOut',right1led},...
                        'input_to_statechange',{'Tup','current_state+1'; ...
                        'Clo',cpoke_out_state});
                elseif left_stim(tx)==0 && right_stim(tx)==0
                    sma=add_state(sma,'name',sprintf('led%03g_N',tx),'self_timer',led_time,...
                        'input_to_statechange',{'Tup','current_state+1'; ...
                        'Clo',cpoke_out_state});
                else
                    error('You are in trouble');
                end
                
                
                sma=add_state(sma,'name',sprintf('led%03g_off',tx),'self_timer',bin_size-led_time,...
                    'input_to_statechange',{'Tup','current_state+1'; ...
                    'Clo',cpoke_out_state});
            end
            
            sma = add_state(sma,'name','nic_poststim','self_timer',delay_time,...
                'input_to_statechange',{'Clo',cpoke_out_state;...
                'Tup','wait_for_cout'});
            
            sma = add_state(sma,'name','wait_for_cout',...
                'output_actions',{'SoundOut',-nic_sound_id},...
                'input_to_statechange',{'Clo','wait_for_spoke'});
            
%% States for training stages 2 & 3 (in flicker these are called states 1&2)

        elseif value(training_stage)<3
            sma = add_state(sma,'name','wait_for_cpoke',...
                'self_timer',wait_for_cpoke_timeout,...
                'output_actions',{'SoundOut',-nic_sound_id},...
                'input_to_statechange',{'Tup','timeout_state'; ...
                'Dhi','nic_prestim'});
            
            sma = add_state(sma,'name','nic_prestim','self_timer',settling_time,...
                'output_actions',{'SoundOut',nic_sound_id},...
                'input_to_statechange',{'Dlo','wait_for_cpoke';...
                'Tup','current_state+1'});
            
            for tx=1:numel(left_stim)
                % In each time bin add a state that is a left_light
                if left_stim(tx)==1 && right_stim(tx)==1
                    sma=add_state(sma,'name',sprintf('led%03g_B',tx),'self_timer',led_time,...
                        'output_actions',{'DOut',right1led+left1led},...
                        'input_to_statechange',{'Tup','current_state+1'; ...
                        'Dlo',cpoke_out_state});
                elseif left_stim(tx)==1 && right_stim(tx)==0
                    sma=add_state(sma,'name',sprintf('led%03g_L',tx),'self_timer',led_time,...
                        'output_actions',{'DOut',left1led},...
                        'input_to_statechange',{'Tup','current_state+1'; ...
                        'Dlo',cpoke_out_state});
                    
                elseif left_stim(tx)==0 && right_stim(tx)==1
                    sma=add_state(sma,'name',sprintf('led%03g_R',tx),'self_timer',led_time,...
                        'output_actions',{'DOut',right1led},...
                        'input_to_statechange',{'Tup','current_state+1'; ...
                        'Dlo',cpoke_out_state});
                elseif left_stim(tx)==0 && right_stim(tx)==0
                    sma=add_state(sma,'name',sprintf('led%03g_N',tx),'self_timer',led_time,...
                        'input_to_statechange',{'Tup','current_state+1'; ...
                        'Dlo',cpoke_out_state});
                else
                    error('Stimulus Arguments Invalid or Unspecified');
                end
                
                
                sma=add_state(sma,'name',sprintf('led%03g_off',tx),'self_timer',bin_size-led_time,...
                    'input_to_statechange',{'Tup','current_state+1'; ...
                    'Dlo',cpoke_out_state});
            end
            
            sma = add_state(sma,'name','nic_poststim','self_timer',delay_time,...
                'input_to_statechange',{'Dlo',cpoke_out_state;...
                'Tup','wait_for_cout'});
            
            sma = add_state(sma,'name','wait_for_cout',...
                'output_actions',{'SoundOut',-nic_sound_id},...
                'input_to_statechange',{'Dlo','wait_for_spoke'});
        else
            error('Training Stage Invalid or Unspecified')
        end
                
        
%% STIMULUS INFO
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
                    error('Trial Side Invalid or Unspecified');
                end
                
            case 'anti side'; % Anti lights
                if this_trial=='l' || this_trial=='m'
                    led_dio=left1led;
                elseif this_trial=='r' || this_trial=='s'
                    led_dio=right1led;
                else
                    error('Anti-Side Trial Invalid or Unspecified');
                end
            otherwise
                error('Side Lights Invalid or Unspecified')
        end
             
        if ignore_errors==1
            error_state='current_state';
        else
            error_state='error_state';
        end
        
        % if the slot was not entered:
        sma = add_state(sma,'name','wait_for_spoke','self_timer',wait_for_spoke_timeout,...
            'output_actions',{'DOut',led_dio},...
            'input_to_statechange',{correct_response, 'hit_state';...
            error_response,error_state;...
            'Tup','timeout_state'});
        
        sma = add_state(sma,'name','hit_state','self_timer',reward_delay+hit_valve_time+0.1,...
            'output_actions',{'SoundOut',hit_sound_id;...
            'SchedWaveTrig','direct_reward'},...
            'input_to_statechange',{'Tup','clean_up_state'});
        
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
        
        
        dispatcher('send_assembler', sma, {'hit_state', 'error_state', 'violation_state','timeout_state'});
        
        
    otherwise
        warning('do not know how to do %s',action);
end
function  [] =  SMA1(obj, action)
% Edited to allow centerport translation June 2013 BBS
% Edited to allow Pistons October 2013 BBS

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
        obj_water          = bSettings('get', 'DIOLINES', 'right1water');
        CW                 = bSettings('get', 'DIOLINES', 'A5');              %Ch4  5V
        CCW                = bSettings('get', 'DIOLINES', 'B5');              %Ch5  5V
        vacuum             = bSettings('get', 'DIOLINES', 'vacuum');
        D5                 = bSettings('get', 'DIOLINES', 'D5');
        shutter            = bSettings('get', 'DIOLINES', 'shutter'); %opens and closes shutter
        readme             = bSettings('get', 'DIOLINES', 'readme'); %signals that trial number is being sent
        trigger            = bSettings('get', 'DIOLINES', 'trigger'); %triggers scan image acquisition
        bit1               = bSettings('get', 'DIOLINES', 'bit1'); %first bit of three bit digital word (aux lines in scanimage 5)
        bit2               = bSettings('get', 'DIOLINES', 'bit2'); %second bit
        bit3               = bSettings('get', 'DIOLINES', 'bit3'); %third bit
        

        
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
        
        
        %is_done=false;
        
        % Note if nic_time is zero no flashes will be played.
        
        %while ~is_done
            left_stim =(rand(1,ceil(nic_time/bin_size))<left_prob);
            right_stim=(rand(1,ceil(nic_time/bin_size))<right_prob);
            
            if sum(left_stim)>sum(right_stim) %LEFT TRIALS
                correct_response='Lhi';
                error_response='Rhi';
                %is_done=true;
                hit_dio=left1water;
                report_choice = bit1; %this goes to scan image.
                choice_dio=D5;
                other_dio=center1led;
                hit_valve_time=LeftWValveTime*LeftWMult;
                this_trial='l';
                     
            elseif sum(left_stim)<sum(right_stim) %RIGHT TRIALS
                correct_response='Rhi';
                error_response='Lhi';
               % hit_dio=right1water;
                hit_dio = left1water;
                report_choice = bit2; %this goes to scan image.
                choice_dio=center1led;
                other_dio=D5;
                hit_valve_time=LeftWValveTime*RightWMult;
                %is_done=true;
                this_trial='r';
                
            elseif sum(left_stim)==sum(right_stim)  %EQUAL FLASHES
                if rand<0.5
                    correct_response='Rhi';
                    error_response='Lhi';
                   % hit_dio=right1water;
                    hit_dio = left1water;
                    choice_dio=center1led;
                    other_dio=D5;
                    hit_valve_time=LeftWValveTime*RightWMult;
                    %is_done=true;
                    this_trial='s';
                else
                    correct_response='Lhi';
                    error_response='Rhi';
                    %is_done=true;
                    hit_dio=left1water;
                    choice_dio=D5;
                    other_dio=center1led;
                    hit_valve_time=LeftWValveTime*LeftWMult;
                    this_trial='m';
                end
            end
        %end
        
        SidesSection(obj,'update_trial_history',this_trial);
        
        %%THIS IS WHERE WE ENCODE THE TRIAL NUMBER IN BINARY TO SEND IT TO
        %%SCAN IMAGE AT THE BEGINNING OF EACH TRIAL.
        digitalword = dec2bin(value(n_done_trials+1), 12);
        %Parse into 4 words, each 3 bits
        word1 = digitalword(1:3);
        word2 = digitalword(4:6);
        word3 = digitalword(7:9);
        word4 = digitalword(10:12);
        
        mylines = {'bit1'; 'bit2'; 'bit3'};
        
        mybits1 = zeros(1,3); %place holder for the three DIOLINES corresponding to each bit.
        mybits2 = zeros(1,3);
        mybits3 = zeros(1,3);
        mybits4 = zeros(1,3);
        
        if ~isempty(regexp(word1, '1'));
            these = regexp(word1, '1');
            for j = 1:length(these);
                mybits1(these(j)) = bSettings('get', 'DIOLINES', cell2mat(mylines(these(j))));
            end
        end
        if ~isempty(regexp(word2, '1'));
            these = regexp(word2, '1');
            for j = 1:length(these);
                mybits2(these(j)) = bSettings('get', 'DIOLINES', cell2mat(mylines(these(j))));
            end
        end
        if ~isempty(regexp(word3, '1'));
            these = regexp(word3, '1');
            for j = 1:length(these);
                mybits3(these(j)) = bSettings('get', 'DIOLINES', cell2mat(mylines(these(j))));
            end
        end
        if ~isempty(regexp(word4, '1'));
            these = regexp(word4, '1');
            for j = 1:length(these);
                mybits4(these(j)) = bSettings('get', 'DIOLINES', cell2mat(mylines(these(j))));
            end
        end
 
        
        postwatertime=0.25;
        preshuttertime=0.3;
        waveform = ones(1,value(nic_time+postwatertime)*2000)*value(PistonPressure);
        
        bonus=max(1,(nic_time+settling_time+delay_time)).^reward_exponent;
        
        hit_valve_time=hit_valve_time*bonus;
        
        sma = add_scheduled_wave(sma, 'name', 'direct_reward', 'preamble', reward_delay, ...
            'sustain', hit_valve_time, 'DOut', hit_dio);
        
          sma = add_scheduled_wave(sma, 'name', 'report_correct_choice', 'preamble',0, ...
            'sustain', 0.2, 'DOut', choice_dio);
        
        sma = add_scheduled_wave(sma, 'name', 'report_other_choice', 'preamble',0, ...
            'sustain', 0.2, 'DOut', other_dio);

        
        %----------------Imaging Commands--------------------------------------   %    
        sma = add_scheduled_wave(sma, 'name', 'pistons','ao_line', 1, 'analog_waveform', waveform, 'loop', 0);
        sma = add_scheduled_wave(sma, 'name', 'shutter', 'preamble', preshuttertime, 'sustain', nic_time-preshuttertime,'DOut', shutter, 'loop', 0 );
        if value(Imaging)==1;
            
            sma = add_scheduled_wave(sma, 'name', 'scan_image','preamble', 0, 'sustain', nic_time+postwatertime, 'DOut', trigger, 'loop', 0);
        else
            sma = add_scheduled_wave(sma, 'name', 'scan_image', 'preamble', 0, 'sustain', 0, 'loop', 0);
        end
        
        if value(WaterImmersion)==1
            sma = add_scheduled_wave(sma, 'name', 'waterimmersion', 'preamble', 0, 'sustain', ObjWater_dur, 'DOut', obj_water, 'loop', 0);
            sma = add_scheduled_wave(sma, 'name', 'obj_clearwater', 'preamble', nic_time-Vacuum_dur+postwatertime, 'sustain', Vacuum_dur, 'DOut', vacuum, 'loop', 0);
        else
            sma = add_scheduled_wave(sma, 'name', 'waterimmersion', 'preamble', 0, 'sustain', 0, 'loop', 0);
            sma = add_scheduled_wave(sma, 'name', 'obj_clearwater', 'preamble', 0, 'sustain', 0, 'loop', 0);
        end
        
 
        
        %----------------Stage Commands--------------------------------------
        sma = add_scheduled_wave(sma, 'name', 'forward',            'preamble', 0, 'sustain', .001,'DOut', CW, 'loop', -1 );
        sma = add_scheduled_wave(sma, 'name', 'backward',           'preamble', 0, 'sustain', .001,'DOut', CCW, 'loop', NosPos);
        sma = add_scheduled_wave(sma, 'name', 'step',               'preamble', 0, 'sustain', .001,'DOut', CCW, 'loop', value(StepSize));
        
        
        %% -----------Synchronizing Bcontrol and ScanImage
        %%Unfortunately, because scheduled waves can only trigger one
        %%DIOline at a time, this code has to be a little clunky, with a
        %%different scheduled wave for each of the 15 bits we want to
        %%send. I need to talk to Carlos to see if there is a better
        %%solution.
        sma = add_scheduled_wave(sma, 'name', 'word1_1', 'preamble', 0, 'sustain', .1, 'DOut', mybits1(1), 'loop', 0);
        sma = add_scheduled_wave(sma, 'name', 'word1_2', 'preamble', 0, 'sustain', .1, 'DOut', mybits1(2), 'loop', 0);
        sma = add_scheduled_wave(sma, 'name', 'word1_3', 'preamble', 0, 'sustain', .1, 'DOut', mybits1(3), 'loop', 0);
        
        sma = add_scheduled_wave(sma, 'name', 'word2_1', 'preamble', 0, 'sustain', .1, 'DOut', mybits2(1), 'loop', 0);
        sma = add_scheduled_wave(sma, 'name', 'word2_2', 'preamble', 0, 'sustain', .1, 'DOut', mybits2(2), 'loop', 0);
        sma = add_scheduled_wave(sma, 'name', 'word2_3', 'preamble', 0, 'sustain', .1, 'DOut', mybits2(3), 'loop', 0);
        
        sma = add_scheduled_wave(sma, 'name', 'word3_1', 'preamble', 0, 'sustain', .1, 'DOut', mybits3(1), 'loop', 0);
        sma = add_scheduled_wave(sma, 'name', 'word3_2', 'preamble', 0, 'sustain', .1, 'DOut', mybits3(2), 'loop', 0);
        sma = add_scheduled_wave(sma, 'name', 'word3_3', 'preamble', 0, 'sustain', .1, 'DOut', mybits3(3), 'loop', 0);
        
        sma = add_scheduled_wave(sma, 'name', 'word4_1', 'preamble', 0, 'sustain', .1, 'DOut', mybits4(1), 'loop', 0);
        sma = add_scheduled_wave(sma, 'name', 'word4_2', 'preamble', 0, 'sustain', .1, 'DOut', mybits4(2), 'loop', 0);
        sma = add_scheduled_wave(sma, 'name', 'word4_3', 'preamble', 0, 'sustain', .1, 'DOut', mybits4(3), 'loop', 0);
        
        sma = add_scheduled_wave(sma, 'name', 'sendbit1', 'preamble', 0, 'sustain', .1, 'DOut', readme, 'trigger_on_up', 'word1_1+word1_2+word1_3', 'loop', 0);
        sma = add_scheduled_wave(sma, 'name', 'sendbit2', 'preamble', .15, 'sustain', .1, 'DOut', readme, 'trigger_on_up', 'word2_1+word2_2+word2_3', 'loop', 0);
        sma = add_scheduled_wave(sma, 'name', 'sendbit3', 'preamble', .3, 'sustain', .1, 'DOut', readme, 'trigger_on_up', 'word3_1+word3_2+word3_3', 'loop', 0);
        sma = add_scheduled_wave(sma, 'name', 'sendbit4', 'preamble', .45, 'sustain', .1, 'DOut', readme, 'trigger_on_up', 'word4_1+word4_2+word4_3', 'loop', 0);
        
        

      FixationDuration=value(settling_time)+value(delay_time)+value(nic_time);
         

 %       Initialization states for moving the center poke stage
        if n_done_trials==0
            sma = add_state(sma, 'name', 'MoveForward', ...
                'output_actions', {'SchedWaveTrig', '+forward'}, ...
                'input_to_statechange', {'Ahi', 'Stop'});
            
            sma = add_state(sma, 'name', 'Stop', 'self_timer', 0.001, ...
                'output_actions', {'SchedWaveTrig', '-forward'}, ...
                'input_to_statechange', {'Tup', 'MoveBack'});
            
            sma = add_state(sma, 'name', 'MoveBack', 'self_timer', value(NosPos)*0.002, ... %increased the duration of this state BBS 9.25.13
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
                'Bhi','wait_for_spoke';...
                'Chi','nic_prestim'});
              
            sma = add_state(sma,'name','nic_prestim','self_timer',settling_time,...
                'output_actions',{'SoundOut',nic_sound_id},...
                'input_to_statechange',{'Clo','wait_for_cpoke';...
                'Tup','current_state+1'});
            
            for tx=1:numel(left_stim)
                % In each time bin add a state that is a left_light
                if left_stim(tx)==1 && right_stim(tx)==1
                    sma=add_state(sma,'name',sprintf('led%03g_B',tx),'self_timer',led_time,...
                        'output_actions',{'DOut',right1led+bit2+left1led+bit1},...
                        'input_to_statechange',{'Tup','current_state+1'; ...
                        'Clo',cpoke_out_state});
                elseif left_stim(tx)==1 && right_stim(tx)==0
                    sma=add_state(sma,'name',sprintf('led%03g_L',tx),'self_timer',led_time,...
                        'output_actions',{'DOut',left1led+bit1},...
                        'input_to_statechange',{'Tup','current_state+1'; ...
                        'Clo',cpoke_out_state});
                    
                elseif left_stim(tx)==0 && right_stim(tx)==1
                    sma=add_state(sma,'name',sprintf('led%03g_R',tx),'self_timer',led_time,...
                        'output_actions',{'DOut',right1led+bit2},...
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
                'Bhi','nic_pre_prestim'});

%              sma = add_state(sma,'name','nic_pre_prestim','self_timer',.01,...
%                 'output_actions',{'SchedWaveTrig','+pistons+shutter'},...
%                 'input_to_statechange',{'Tup','current_state+1'});
           sma = add_state(sma,'name','nic_pre_prestim','self_timer',0.001,...
                'output_actions',{'SoundOut',nic_sound_id;'SchedWaveTrig', '+pistons +scan_image +shutter +waterimmersion +obj_clearwater +sendbit1 +sendbit2 +sendbit3 +sendbit4'},...
                'input_to_statechange',{'Blo','violation_state';...
                'Dlo', 'release'; 'Tup','current_state+1'});
            
            sma = add_state(sma,'name','nic_prestim','self_timer',settling_time,...
                'output_actions',{'SoundOut',nic_sound_id},...
                'input_to_statechange',{'Blo','release';...
                'Dlo','release';...
                'Tup','current_state+1'});
            
            for tx=1:numel(left_stim)
                % In each time bin add a state that is a left_light
                if left_stim(tx)==1 && right_stim(tx)==1
                    sma=add_state(sma,'name',sprintf('led%03g_B',tx),'self_timer',led_time,...
                        'output_actions',{'DOut',center1led+bit2+D5+bit1},...
                        'input_to_statechange',{'Tup','current_state+1'; ...
                        'Dlo','release';...
                         'Blo','release'});
                     
                elseif left_stim(tx)==1 && right_stim(tx)==0
                    sma=add_state(sma,'name',sprintf('led%03g_L',tx),'self_timer',led_time,...
                        'output_actions',{'DOut',D5+bit1},...
                        'input_to_statechange',{'Tup','current_state+1'; ...
                        'Dlo','release';...
                        'Blo','release'});
                    
                elseif left_stim(tx)==0 && right_stim(tx)==1
                    sma=add_state(sma,'name',sprintf('led%03g_R',tx),'self_timer',led_time,...
                        'output_actions',{'DOut',center1led+bit2},...
                        'input_to_statechange',{'Tup','current_state+1'; ...
                        'Dlo','release';...
                         'Blo','release'});
                     
                elseif left_stim(tx)==0 && right_stim(tx)==0
                    sma=add_state(sma,'name',sprintf('led%03g_N',tx),'self_timer',led_time,...
                        'input_to_statechange',{'Tup','current_state+1'; ...
                        'Dlo','release';...
                         'Blo','release'});
                else
                    error('Stimulus Arguments Invalid or Unspecified');
                end
                
                
                sma=add_state(sma,'name',sprintf('led%03g_off',tx),'self_timer',bin_size-led_time,...
                    'input_to_statechange',{'Tup','current_state+1'; ...
                    'Dlo','release';...
                     'Blo','release'});
            end
            
            sma = add_state(sma,'name','nic_poststim','self_timer',delay_time,...
                'input_to_statechange',{'Dlo','release';...
                'Blo','release';...
                'Tup','wait_for_cout'}, 'output_actions', {'SchedWaveTrig', ...
                '-pistons -scan_image -shutter -waterimmersion -obj_clearwater -sendbit1 -sendbit2 -sendbit3 -sendbit4'});
            
             sma = add_state(sma,'name','release','self_timer',0.05,...
                'output_actions',{'SchedWaveTrig','-pistons -scan_image -shutter -waterimmersion -obj_clearwater -sendbit1 -sendbit2 -sendbit3 -sendbit4'},...
                'input_to_statechange',{'Tup','violation_state'});
            
            sma = add_state(sma,'name','wait_for_cout',...
                'output_actions',{'SoundOut',-nic_sound_id},...
                'input_to_statechange',{'Blo','wait_for_spoke'});
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
%         sma = add_state(sma,'name','wait_for_spoke','self_timer',wait_for_spoke_timeout,...
%             'output_actions',{'DOut',led_dio},...
%             'input_to_statechange',{correct_response, 'hit_state';...
%             error_response,error_state;...
%             'Tup','timeout_state'});
        sma = add_state(sma,'name','wait_for_spoke','self_timer',wait_for_spoke_timeout,...
            'output_actions',{'DOut',led_dio},...
            'input_to_statechange',{'Rhi', 'pre_hitR';...
            'Lhi', 'pre_hitL';...
            'Tup','timeout_state'});
        
        if strcmp(value(correct_response),'Rhi')
        
                sma = add_state(sma, 'name','pre_hitL', 'self_timer', .05, 'output_actions', ...
            {'DOut', trigger; 'DOut', bit1; 'SoundOut', err_sound_id}, 'input_to_statechange', ...
            {'Tup', 'wait_for_center_error'});
        
                sma = add_state(sma, 'name','pre_hitR', 'self_timer', .05, 'output_actions', ...
            {'DOut', trigger; 'DOut', bit2; 'SoundOut',hit_sound_id}, 'input_to_statechange', ...
            {'Tup', 'wait_for_center_reward'});
        
        elseif strcmp(value(correct_response),'Lhi')
        
                sma = add_state(sma, 'name','pre_hitL', 'self_timer', .05, 'output_actions', ...
            {'DOut', trigger; 'DOut', bit1; 'SoundOut',hit_sound_id}, 'input_to_statechange', ...
            {'Tup', 'wait_for_center_reward'});
        
                sma = add_state(sma, 'name','pre_hitR', 'self_timer', .05, 'output_actions', ...
            {'DOut', trigger; 'DOut', bit2; 'SoundOut', err_sound_id}, 'input_to_statechange', ...
            {'Tup', 'wait_for_center_error'});
        end
        
        
        sma = add_state(sma, 'name', 'wait_for_center_reward', 'self_timer', wait_for_spoke_timeout, ...
            'input_to_statechange', {'Bhi', 'hit_state'; 'Chi', 'hit_state'; ...
            'Tup', 'timeout_state'});
        
        sma = add_state(sma, 'name', 'wait_for_center_error', 'self_timer', wait_for_spoke_timeout, ...
            'input_to_statechange', {'Bhi', 'error_state'; 'Chi', 'error_state'; ...
            'Tup', 'timeout_state'});
        
        sma = add_state(sma,'name','hit_state','self_timer',reward_delay+hit_valve_time+0.1,...
            'output_actions',{'SoundOut',hit_sound_id;...
            'SchedWaveTrig','direct_reward+report_correct_choice'},...
            'input_to_statechange',{'Tup','wait_for_cout_final'});
        
        
        
%         sma = add_state(sma,'name','hit_state','self_timer',reward_delay+hit_valve_time+0.1,...
%             'output_actions',{'SoundOut',hit_sound_id;...
%             'SchedWaveTrig','direct_reward+pistonspractice+report_correct_choice'},...
%             'input_to_statechange',{'Tup','clean_up_state'});
        
        sma = add_state(sma,'name','error_state','self_timer',error_iti,...
            'output_actions',{'SoundOut',err_sound_id,...
            'SchedWaveTrig','report_other_choice'},...
            'input_to_statechange',{'Tup','wait_for_cout_final'});
        
        sma = add_state(sma, 'name', 'wait_for_cout_final', 'self_timer', wait_for_spoke_timeout, ...
            'input_to_statechange', {'Blo', 'clean_up_state'; 'Tup', 'wait_for_cout_final'});
        
        sma = add_state(sma,'name','timeout_state','self_timer',1,...
            'output_actions',{'SoundOut',to_sound_id},...
            'input_to_statechange',{'Tup','clean_up_state'});
        
        sma = add_multi_sounds_state(sma,[-nic_sound_id -viol_sound_id -err_sound_id -to_sound_id],...
            'self_timer',violation_iti,...
            'state_name','violation_state','return_state','clean_up_state');
        
%         sma = add_multi_sounds_state(sma,[-to_sound_id -viol_sound_id -hit_sound_id -err_sound_id],...
%             'state_name','clean_up_state','return_state','check_next_trial_ready');
        
        sma = add_state(sma, 'name', 'clean_up_state', 'self_timer', .1, 'input_to_statechange', ...
            {'Tup', 'check_next_trial_ready'});
           
        
        dispatcher('send_assembler', sma, {'hit_state', 'error_state', 'violation_state','timeout_state'});
        
        
    otherwise
        warning('do not know how to do %s',action);
end
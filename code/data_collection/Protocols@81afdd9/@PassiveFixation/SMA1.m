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
        obj_water          = bSettings('get', 'DIOLINES', 'right1water');
        CW                 = bSettings('get', 'DIOLINES', 'A5');              %Ch4  5V
        CCW                = bSettings('get', 'DIOLINES', 'B5');              %Ch5  5V
        vacuum             = bSettings('get', 'DIOLINES', 'vacuum');
        D5                 = bSettings('get', 'DIOLINES', 'D5');
        shutter            = bSettings('get', 'DIOLINES', 'shutter'); %opens and closes shutter
        % obj_water          = bSettings('get', 'DIOLINES', 'B12'); %solenoid for objective
        %obj_water          = bSettings('get', 'DIOLINES', 'obj_water'); %solenoid for objective
        readme             = bSettings('get', 'DIOLINES', 'readme'); %signals that trial number is being sent
        trigger            = bSettings('get', 'DIOLINES', 'trigger'); %triggers scan image acquisition
        %  vacuum             = bSettings('get', 'DIOLINES', 'vacuum'); %vacuum line for objective
        %  bit2               = bSettings('get', 'DIOLINES', 'bit2');
        %  bit3               = bSettings('get', 'DIOLINES', 'bit3');
        
        % INPUT LINES
        sma = StateMachineAssembler('full_trial_structure', 'use_happenings', 1, 'n_input_lines', 6);
        
        % Sounds
        nic_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'NICSound');
        hit_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'HitSound');
        err_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'ErrorSound');
        viol_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'ViolationSound');
        to_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'TimeoutSound');
        
        if n_done_trials >= value(warmuptrials);
            SoundInterface(obj, 'set','NICSound','Dur1', value(nic_time));
        elseif value(thisnic)<value(nic_time);
            if value(nic_time)<.1
                SoundInterface(obj, 'set','NICSound','Dur1', .1);
            else
                SoundInterface(obj, 'set','NICSound','Dur1', value(nic_time));
            end
        end
        
        % [x, y] = WaterValvesSection(obj, 'set_water_amounts', l_ul, r_ul);
        [LeftWValveTime RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
        
        if rand > 0.5;
            this_trial = 'l';
            %water=left1water;
            thisled = left1led;
            hitpoke = 'Lhi';
            errorpoke = 'Rhi';
        else
            this_trial = 'r';
            %  water=left1water;
            thisled = right1led;
            hitpoke = 'Rhi';
            errorpoke = 'Lhi';
        end
        hit_valve_time = LeftWValveTime;
        water=left1water;
        
        SidesSection(obj,'update_trial_history',this_trial);
        
        
        %%THIS IS WHERE WE ENCODE THE TRIAL NUMBER IN BINARY TO SEND IT TO
        %%SCAN IMAGE AT THE BEGINNING OF EACH TRIAL.
        digitalword = dec2bin(value(n_done_trials+1), 15);
        %Parse into 5 words, each 3 bits
        word1 = digitalword(1:3);
        word2 = digitalword(4:6);
        word3 = digitalword(7:9);
        word4 = digitalword(10:12);
        word5 = digitalword(13:15);
        
        mylines = {'bit1'; 'bit2'; 'bit3'};
        
        mybits1 = zeros(1,3); %place holder for the three DIOLINES corresponding to each bit.
        mybits2 = zeros(1,3);
        mybits3 = zeros(1,3);
        mybits4 = zeros(1,3);
        mybits5 = zeros(1,3);
        
        
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
        if ~isempty(regexp(word5, '1'));
            these = regexp(word5, '1');
            for j = 1:length(these);
                mybits5(these(j)) = bSettings('get', 'DIOLINES', cell2mat(mylines(these(j))));
            end
        end
        
        
        postwatertime=0.25;
        preshuttertime=0.3;
        waveform = ones(1,value(nic_time+postwatertime)*2000)*value(PistonPressure);
        % end
        
        
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
        
        sma = add_scheduled_wave(sma, 'name', 'forward', 'preamble', 0, 'sustain', .001,'DOut', CW, 'loop', -1 );
        sma = add_scheduled_wave(sma, 'name', 'backward', 'preamble', 0, 'sustain', .001,'DOut', CCW, 'loop', value(NosPos));
        sma = add_scheduled_wave(sma, 'name', 'stepstage', 'preamble', 0, 'sustain', .01,'DOut', CCW, 'loop', value(StepSize));
        
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
        
        sma = add_scheduled_wave(sma, 'name', 'word5_1', 'preamble', 0, 'sustain', .1, 'DOut', mybits5(1), 'loop', 0);
        sma = add_scheduled_wave(sma, 'name', 'word5_2', 'preamble', 0, 'sustain', .1, 'DOut', mybits5(2), 'loop', 0);
        sma = add_scheduled_wave(sma, 'name', 'word5_3', 'preamble', 0, 'sustain', .1, 'DOut', mybits5(3), 'loop', 0);
        
        sma = add_scheduled_wave(sma, 'name', 'sendbit1', 'preamble', 0, 'sustain', .1, 'DOut', readme, 'trigger_on_up', 'word1_1+word1_2+word1_3', 'loop', 0);
        sma = add_scheduled_wave(sma, 'name', 'sendbit2', 'preamble', .15, 'sustain', .1, 'DOut', readme, 'trigger_on_up', 'word2_1+word2_2+word2_3', 'loop', 0);
        sma = add_scheduled_wave(sma, 'name', 'sendbit3', 'preamble', .3, 'sustain', .1, 'DOut', readme, 'trigger_on_up', 'word3_1+word3_2+word3_3', 'loop', 0);
        sma = add_scheduled_wave(sma, 'name', 'sendbit4', 'preamble', .45, 'sustain', .1, 'DOut', readme, 'trigger_on_up', 'word4_1+word4_2+word4_3', 'loop', 0);
        sma = add_scheduled_wave(sma, 'name', 'sendbit5', 'preamble', .6, 'sustain', .1, 'DOut', readme, 'trigger_on_up', 'word5_1+word5_2+word5_3', 'loop', 0);
        
        %       if value(reward_delay) > value(nic_time)
        %           sma = add_scheduled_wave(sma, 'name', 'direct_reward', 'preamble', nic_time, ...
        %               'sustain',  hit_valve_time, 'DOut', water);
        %       else
        %           sma = add_scheduled_wave(sma, 'name', 'direct_reward', 'preamble', reward_delay, ...
        %               'sustain',  hit_valve_time, 'DOut', water);
        %       end
        
        %         sma = add_scheduled_wave(sma, 'name', 'direct_reward', 'preamble', 4, ...
        %                'sustain',  hit_valve_time, 'DOut', water);
        %
        %SidesSection(obj,'update_trial_history',this_trial);
        
        
        if n_done_trials==0
            
            %NOTE 700ms is equivalent to roughtly 200ul of water from the automatic
            %immersion system
            
            sma = add_state(sma, 'name', 'MoveForward', ...
                'output_actions', {'SchedWaveTrig', '+forward'}, ...
                'input_to_statechange', {'Ahi', 'Stop'});
            
            sma = add_state(sma, 'name', 'Stop', 'self_timer', 0.001, ...
                'output_actions', {'SchedWaveTrig', '-forward'}, ...
                'input_to_statechange', {'Tup', 'MoveBack'});
            
            sma = add_state(sma, 'name', 'MoveBack', 'self_timer', value(NosPos)*0.002, ...
                'output_actions', {'SchedWaveTrig','+backward'}, ...
                'input_to_statechange', {'Tup', 'wait_for_cpoke'});
        end  %End of move stage, beginning of behavioral session
        
        
        %% STATES for Training stage 0, grow nos pos
        if value(training_stage) == 0
            sma = add_state(sma,'name','wait_for_cpoke','self_timer', wait_for_cpoke_timeout, ...
                'output_actions',{'SoundOut',-nic_sound_id; 'SoundOut', hit_sound_id}, ...
                'input_to_statechange', {'Chi', 'cp','Bhi','cpslotonly','Tup','wait_for_cpoke'});
            
            sma = add_state(sma,'name','cp','self_timer', hit_valve_time, ...
                'output_actions', {'SoundOut', nic_sound_id; 'DOut', water}, ...
                'input_to_statechange', {'Tup', 'wait_for_spoke'});
            
            sma = add_state(sma,'name','cpslotonly','self_timer', hit_valve_time, ...
                'output_actions', {'SoundOut', nic_sound_id; 'DOut', water}, ...
                'input_to_statechange', {'Tup', 'wait_for_spoke_slot'});
            
            sma = add_state(sma, 'name', 'wait_for_spoke', 'self_timer', .001,...
                'output_actions', {'SoundOut', -nic_sound_id; 'SchedWaveTrig', 'stepstage'; ...
                'DOut', thisled}, 'input_to_statechange',...
                {hitpoke, 'hit_state'});
            
            sma = add_state(sma, 'name', 'wait_for_spoke_slot', 'self_timer', .001,...
                'output_actions', {'SoundOut', -nic_sound_id; 'SchedWaveTrig', 'stepstage'; ...
                'DOut', thisled}, 'input_to_statechange',...
                {hitpoke, 'hit_state'});
            
            
            %% STATES for Training stage 0, grow NIC TIME
        elseif value(training_stage) == 1
            
            
            sma = add_state(sma,'name','wait_for_cpoke',...
                'self_timer',wait_for_cpoke_timeout,...
                'output_actions',{'SoundOut',-nic_sound_id},...
                'input_to_statechange',{'Bhi','nic'});
            
            if n_done_trials < value(warmuptrials)
                sma = add_state(sma,'name','nic','self_timer',value(thisnic),...
                    'output_actions', {'SoundOut', nic_sound_id}, ...
                    'input_to_statechange',{'Blo', 'violation_state';...
                    'Tup', 'givewater'});
            else
                
                sma = add_state(sma,'name','nic','self_timer',nic_time,...
                    'output_actions', {'SoundOut', nic_sound_id}, ...
                    'input_to_statechange',{'Blo', 'violation_state';...
                    'Tup', 'givewater'});
            end
            
            sma = add_state(sma, 'name', 'givewater', 'self_timer', hit_valve_time, ...
                'output_actions', {'SoundOut', -nic_sound_id; 'SoundOut', hit_sound_id; 'DOut', water}, ...
                'input_to_statechange', {'Tup', 'wait_for_spoke'});
            
            sma = add_state(sma, 'name', 'wait_for_spoke', 'self_timer', .001,...
                'output_actions', {'DOut', thisled}, 'input_to_statechange',...
                {hitpoke, 'hit_state'});
            
            
            %% States for training stages 2: imaging
        elseif value(training_stage)==2
            
            sma = add_state(sma,'name','wait_for_cpoke',...
                'self_timer',wait_for_cpoke_timeout,...
                'output_actions',{'SoundOut',-nic_sound_id},...
                'input_to_statechange',{'Bhi','nic_prestim'});
            
            sma = add_state(sma,'name','nic_prestim','self_timer',0.001,...
                'output_actions',{'SoundOut',nic_sound_id;'SchedWaveTrig', '+pistons +scan_image +shutter +waterimmersion +obj_clearwater +sendbit1 +sendbit2 +sendbit3 +sendbit4 +sendbit5'},...
                'input_to_statechange',{'Blo','violation_state';...
                'Dlo', 'release'; ...
                'Tup','nic'});
            
            if n_done_trials < value(warmuptrials)
                sma = add_state(sma,'name','nic','self_timer',value(thisnic),...
                    'input_to_statechange',{'Dlo', 'release';...
                    'Tup','givewater'; 'Blo', 'violation_state'});
            else
                if rand <= rewardprob
                    sma = add_state(sma,'name','nic','self_timer',nic_time,...
                        'input_to_statechange',{'Dlo', 'release';...
                        'Tup','givewater'; 'Blo', 'violation_state'});
                else
                    sma = add_state(sma,'name','nic','self_timer',nic_time,...
                        'input_to_statechange',{'Dlo', 'release';...
                        'Tup','givebeep'; 'Blo', 'violation_state'});
                end
            end
            
            sma = add_state(sma, 'name', 'givewater', 'self_timer', hit_valve_time, ...
                'output_actions', {'SoundOut', hit_sound_id; 'DOut', water}, ...
                'input_to_statechange', {'Tup', 'postwater'; 'Dlo', 'release'});
            
                        sma = add_state(sma, 'name', 'givebeep', 'self_timer', hit_valve_time, ...
                'output_actions', {'SoundOut', hit_sound_id}, ...
                'input_to_statechange', {'Tup', 'postwater'; 'Dlo', 'release'});
            
            sma = add_state(sma, 'name', 'postwater', 'self_timer', postwatertime,...
                'output_actions', {'SchedWaveTrig', '-shutter -scan_image -waterimmersion -obj_clearwater'; ...
                'DOut', thisled},'input_to_statechange', {'Tup', 'wait_for_spoke';...
                'Dlo', 'release'});
            
            
            sma = add_state(sma, 'name', 'wait_for_spoke', 'self_timer', .001,...
                'output_actions', {'SoundOut', -nic_sound_id; 'SchedWaveTrig', '-pistons -scan_image'; ...
                'DOut', thisled},'input_to_statechange', {hitpoke, 'hit_state_slot_only';...
                'Dlo', 'release'});
            
        else
            error('Training Stage Invalid or Unspecified')
        end
        
        if ignore_errors==1
            error_state='current_state';
        else
            error_state='error_state';
        end
        
        sma = add_state(sma,'name','pre_hit_state','self_timer', .001,...
            'output_actions', {'SoundOut', hit_sound_id}, ...
            'input_to_statechange',{'Chi','hit_state'});
        
        sma = add_state(sma,'name','pre_hit_state_slot','self_timer', .001,...
            'output_actions', {'SoundOut', hit_sound_id}, ...
            'input_to_statechange',{'Bhi','hit_state_slot_only'});
        
        sma = add_state(sma,'name','hit_state_slot_only','self_timer', .001,...
            'output_actions',{'SoundOut',  hit_sound_id},...
            'input_to_statechange',{'Tup','clean_up_state'});
        
        sma = add_state(sma,'name','hit_state','self_timer', .001,...
            'output_actions',{'SoundOut',  hit_sound_id},...
            'input_to_statechange',{'Tup','clean_up_state'});
        
        sma = add_state(sma, 'name', 'wait_for_s_out', 'self_timer', .001, ...
            'input_to_statechange', {'Blo', 'clean_up_state'; 'Tup', 'wait_for_s_out'});
        
        sma = add_state(sma, 'name', 'wait_for_c_out', 'self_timer', .001, ...
            'input_to_statechange', {'Clo', 'clean_up_state'; 'Tup', 'wait_for_c_out'});
        
        sma = add_state(sma, 'name', 'release', 'self_timer', 0.1, 'output_actions',...
            {'SchedWaveTrig', '-pistons-shutter-scan_image-waterimmersion-obj_clearwater'},'input_to_statechange',...
            {'Tup', 'violation_state'});
        
        sma = add_state(sma, 'name', 'violation_state', 'self_timer', violation_iti, 'output_actions', ...
            {'SchedWaveTrig', '-pistons-shutter-scan_image-waterimmersion-obj_clearwater'; ...
            'SoundOut', viol_sound_id; 'SoundOut', -nic_sound_id},'input_to_statechange', {'Tup', 'clean_up_state'});
        
        sma = add_state(sma,'name','timeout_state','self_timer',1,...
            'output_actions',{'SoundOut',to_sound_id},...
            'input_to_statechange',{'Tup','clean_up_state'});
        
        sma = add_state(sma,'name','error_state','self_timer',1,...
            'output_actions',{'SoundOut',err_sound_id},...
            'input_to_statechange',{'Tup','clean_up_state'});
        
        sma = add_multi_sounds_state(sma,[-to_sound_id -viol_sound_id -hit_sound_id -err_sound_id],...
            'state_name','clean_up_state','return_state','check_next_trial_ready');
        
        dispatcher('send_assembler', sma, {'hit_state', 'hit_state_slot_only', 'error_state', 'violation_state','timeout_state'});
        
        
        
    otherwise
        warning('do not know how to do %s',action);
end
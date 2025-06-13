
function  [varargout] =  SMA1(obj, action)

GetSoloFunctionArgs;


switch action
    case 'init',
        
       % SoundManagerSection(obj, 'declare_new_sound', 'GoSound');
       % SoundInterface(obj, 'set','GoSound','Style','Tone', 'Vol', 0.01,'Freq1', 2000, 'Dur1', 0.2);

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
        
        %trigger miniscope in the phys room.
        if value(imaging)==1 && ~isnan(bSettings('get', 'DIOLINES', 'scope'));
            trigscope = bSettings('get', 'DIOLINES', 'scope');
        else
            trigscope = nan;
        end
        
        % This code makes the protocol compatible with the head-fixed rigs,
        % in addition to the regular ones.
        if ~isnan(bSettings('get', 'DIOLINES', 'A5'));
            CW = bSettings('get', 'DIOLINES', 'A5');
            sma = StateMachineAssembler('full_trial_structure', 'use_happenings', 1, 'n_input_lines', 4);
        else
            sma = StateMachineAssembler('full_trial_structure', 'use_happenings', 1);
        end
        
        
        [sma] = StimulatorSection(obj, 'update_values', sma);
        
        [LeftWValveTime, RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
        [LeftWMult, RightWMult] = SidesSection(obj, 'get_water_mult');
        
        %% Setup sounds
        
       % hit_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'HitSound');
        SoundInterface(obj, 'set', 'HitSound', 'Style', 'ToneSweep', 'Vol', .02, 'Freq1', 5000, 'Freq2', 1500, 'Dur1', 0.1, 'Dur2', 0.1);
        hit_sound_id = SoundManagerSection(obj, 'get_sound_id', 'HitSound');
        err_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'ErrorSound');
        viol_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'ViolationSound');
        to_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'TimeoutSound');
        go_sound_id = SoundManagerSection(obj, 'get_sound_id', 'GoSound');
        
        

        totaldur = value(nic_time)+value(delay_time)+value(settling_time);
         

        
        %% Declare variables
        % These will get moved to other functions as SoloParamHandles.
        
        if allow_nic_breaks==1
            cpoke_out_state='wait_for_cpoke';
        else
            cpoke_out_state='violation_state';
        end
        
        
        is_done=false;
        
        % Note if nic_time is zero no flashes will be played.
        
            srate = SoundManagerSection(obj, 'get_sample_rate');
            volume_indx = find(value(possible_volumes)==24);

            if value(training_stage)<2 | (value(training_stage==2) & n_done_trials<=value(warmuptrials))
                if value(training_stage==2) & n_done_trials<=value(warmuptrials)
                    nic_time.value = value(nic_time)/(value(warmuptrials)/n_done_trials);
                    totaldur = value(nic_time)+value(delay_time)+value(settling_time);
                end
                
             %   nic_sound_id = SoundManagerSection(obj, 'get_sound_id', 'neutral_nic');
                [LeftWValveTime, RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
                left_stim =zeros(1, length(ceil(nic_time/bin_size))); 
                right_stim = left_stim;
                if rand<0.5
                    this_trial = 'l';
                    correct_response = 'Lhi';
                    led_dio=left1led;
                    water=left1water;
                    hit_valve_time = LeftWValveTime;
                    error_response = 'Rhi';
                    lrate = value(pbup_freqs(volume_indx));
                    % lrate = 40;
                    rrate = 0;
                    [snd, lrate, rrate, data] = make_pbup_CMC(srate, totaldur, rrate, lrate);
                    SoundManagerSection(obj, 'set_sound', 'NICSound', snd);
                    nic_sound_id = SoundManagerSection(obj, 'get_sound_id', 'NICSound');
                else
                    this_trial = 'r';
                    correct_response = 'Rhi';
                    led_dio=right1led;
                    water=right1water;
                    hit_valve_time = RightWValveTime;
                    error_response = 'Lhi';
                    lrate = 0;
                    rrate = value(pbup_freqs(volume_indx));
                    [snd, lrate, rrate, data] = make_pbup_CMC(srate, totaldur, rrate, lrate);
                    SoundManagerSection(obj, 'set_sound', 'NICSound', snd);
                    nic_sound_id = SoundManagerSection(obj, 'get_sound_id', 'NICSound');
                end
                
            elseif value(training_stage)==2 & n_done_trials>value(warmuptrials)
                  [LeftWValveTime, RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
                  
                lflashes = 10;
                rflashes = 10;
                nflashes = 10;

                
                bin_stim = rand(1, ceil(value(nic_time)/value(bin_size)));
                
                if length(bin_stim)<nflashes;
                   bin_stim = [bin_stim, zeros(1, nflashes-length(bin_stim))];   
                end
                
                right_stim = zeros(1, length(bin_stim));
                left_stim = zeros(1, length(bin_stim));
                [dm, i] = sort(bin_stim);
               
                totaldur = length(bin_stim)*value(bin_size)+value(delay_time)+value(settling_time);
                nic_time.value = totaldur;
                
                if rand<0.5
                    this_trial = 'l';
                    correct_response = 'Lhi';
                    led_dio=left1led;
                    water=left1water;
                    hit_valve_time = LeftWValveTime;
                    error_response = 'Rhi';
                    lrate = value(pbup_freqs(volume_indx));
                    left_stim(i(1:rflashes)) = 1;
                    if value(val_grows_high_to_low) ==1
                        left_stim(i(1:rflashes)) = 0;
                        right_stim(i(1:rflashes)) = 1;
                    end
                    
                    % lrate = 40;
                    rrate = 0;
                    [snd, lrate, rrate, data] = make_pbup_CMC(srate, totaldur, rrate, lrate);
                    SoundManagerSection(obj, 'set_sound', 'NICSound', snd);
                    nic_sound_id = SoundManagerSection(obj, 'get_sound_id', 'NICSound');
                else
                    this_trial = 'r';
                    correct_response = 'Rhi';
                    led_dio=right1led;
                    water=right1water;
                    hit_valve_time = RightWValveTime;
                    error_response = 'Lhi';
                    right_stim(i(1:rflashes)) = 1;
                    if value(val_grows_high_to_low) ==1
                        right_stim(i(1:rflashes)) = 0;
                        left_stim(i(1:rflashes)) = 1;
                    end
                    lrate = 0;
                    rrate = value(pbup_freqs(volume_indx));
                    [snd, lrate, rrate, data] = make_pbup_CMC(srate, totaldur, rrate, lrate);
                    SoundManagerSection(obj, 'set_sound', 'NICSound', snd);
                    nic_sound_id = SoundManagerSection(obj, 'get_sound_id', 'NICSound');
                end
                
            elseif value(training_stage)==3
                
                if rand < value(right_prob)
                    right_hit.value = 1;
                    rsound = hit_sound_id;
                    r_ul = value(this_right_volume);
                else
                    right_hit.value = 0;
                    rsound = err_sound_id;
                    r_ul = 0;
                end
                if rand < value(left_prob)
                    left_hit.value = 1;
                    lsound = hit_sound_id;
                    l_ul = value(this_left_volume);
                else
                    left_hit.value = 0;
                    lsound = err_sound_id;
                    l_ul = 0;
                end
                
                this_trial = 'p'; %p is for preference.  there is no correct side
                %nflashes = value(risky_prob) * 10; %find(value(risky_prob_options)==value(risky_prob));
                lflashes = value(left_prob)*10;
                rflashes = value(right_prob)*10;
                
                if value(val_grows_high_to_low) ==1
                      lflashes = 10-lflashes;
                      rflashes = 10-rflashes;
                end
                nflashes = max([lflashes rflashes]);
                bin_stim = rand(1, ceil(value(nic_time)/value(bin_size)));
                
                if length(bin_stim)<nflashes;
                   bin_stim = [bin_stim, zeros(1, nflashes-length(bin_stim))];   
                end
                
                right_stim = zeros(1, length(bin_stim));
                left_stim = zeros(1, length(bin_stim));
                
                [dm, i] = sort(bin_stim);
                right_stim(i(1:rflashes)) = 1;
                
                bin_stim = rand(1, length(bin_stim));
                [dm, i] = sort(bin_stim);
                left_stim(i(1:lflashes)) = 1;
                
                totaldur = length(bin_stim)*value(bin_size)+value(delay_time)+value(settling_time);
                nic_time.value = totaldur;

                totalvolumes = [6 12 24 48];
                rrate = value(this_right_volume);
                lrate = value(this_left_volume);
                
                if value(val_grows_high_to_low)==1 
                    volindx = find(totalvolumes==value(this_right_volume));
                    rrate = value(pbup_freqs(volindx));
                    volindx = find(totalvolumes==value(this_left_volume));
                    lrate = value(pbup_freqs(volindx));
                   %pbup_freqs.value = [48, 24, 12, 6];
                end
                
                if value(invert_volumes)==1
                    volindx = find(totalvolumes==value(this_right_volume));
                    rrate = value(pbup_freqs(volindx));
                    volindx = find(totalvolumes==value(this_left_volume));
                    lrate = value(pbup_freqs(volindx));
                    %pbup_freqs.value = [48, 24, 12, 6];
                end
                    
               % volindx = find(totalvolumes==value(this_right_volume));
               % rrate = value(pbup_freqs(volindx));
                
               % volindx = find(totalvolumes==value(this_left_volume));
               % lrate = value(pbup_freqs(volindx));
                
                
                %make pbups stimulus
                [snd, lrate, rrate, data] = make_pbup_CMC(srate, totaldur, rrate, lrate);
                SoundManagerSection(obj, 'set_sound', 'NICSound', snd);
                nic_sound_id = SoundManagerSection(obj, 'get_sound_id', 'NICSound');
                
                if value(double_volume)==1
                    l_ul = l_ul*2;
                    r_ul = r_ul*2;
                end
                 [x, y] = WaterValvesSection(obj, 'set_water_amounts', l_ul, r_ul);
               
                
            end
            
            %keep track of bup times.
            bpt.left = data.left;
            bpt.right = data.right;
            ThisBupTimes.value = bpt;
            push_history(ThisBupTimes);
            
            [LeftWValveTime, RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
            
            if value(training_stage)==3
                if l_ul==0;
                    LeftWValveTime = 0; %unfortunately, because of weird stuff in WaterValvesSection, we had to do this manually.
                end
                if r_ul ==0
                    RightWValveTime = 0;
                end
            end
            

        
        SidesSection(obj,'update_trial_history',this_trial);
        
        if value(training_stage)<3
            sma = add_scheduled_wave(sma, 'name', 'direct_reward', 'preamble', reward_delay, ...
                'sustain', hit_valve_time, 'DOut', water);
        end
        
        sma = add_scheduled_wave(sma, 'name', 'left_reward', 'preamble', reward_delay, ...
            'sustain',  LeftWValveTime, 'DOut', left1water);
        
        sma = add_scheduled_wave(sma, 'name', 'right_reward', 'preamble', reward_delay, ...
            'sustain',  RightWValveTime, 'DOut', right1water);
        
        sma = add_scheduled_wave(sma, 'name', 'NICSoundOut', 'preamble', 0, 'sustain', ...
            totaldur, 'sound_trig', nic_sound_id, 'loop',0);
        
        if value(imaging)==1
            sma = add_scheduled_wave(sma, 'name', 'TrigScope', 'preamble', 0, 'sustain', ...
                totaldur, 'DOut', trigscope, 'loop', 1);
        else
            sma = add_scheduled_wave(sma, 'name', 'TrigScope', 'preamble', 0, 'sustain', 0); %dummy wave.
        end
        
        sma = add_scheduled_wave(sma, 'name', 'GoSoundOut', 'preamble', 0, 'sustain', .2, ...
            'sound_trig', go_sound_id, 'loop', 0);
        
%             'trigger_on_up', 'stimulator_wave');
        %we will make a placeholder scheduled wave.  if it's an opto
        %rat/trial, this will get written over in StimulatorSection. 
        
        % wait for center nose in
        % On Cin play a NIC sound, the stimulus, stop with violation if rat leaves during
        % NIC.  Stimulus is lights flashing on the right or left. If the rat
        % leaves early the trial ends.
        
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
        
        
        if value(training_stage) == -1
            sma = add_state(sma,'name','pre_spoke',...
                'self_timer',.001,...
                'input_to_statechange',{'Tup','wait_for_spoke'});
        end
        
        
        sma = add_state(sma,'name','wait_for_cpoke',...
            'self_timer',wait_for_cpoke_timeout,...
            'output_actions',{'DOut', center1led},...
            'input_to_statechange',{'Tup','timeout_state'; ...
            'Chi','nic_prestim'});
        
%         t = value(stimulator_history);
%         if strcmp(value(StimState), 'nic_prestim') && t(end)==1
            %trigger laserON wave.
        sma = add_state(sma,'name','nic_prestim','self_timer',settling_time,...
            'output_actions', {'SchedWaveTrig', 'NICSoundOut+stimulatorwave1+TrigScope'},...
            'input_to_statechange',{'Clo','legalbreak';...
            'Tup','preflash'});
        
%             sma = add_state(sma,'name','nic_prestim','self_timer',settling_time,...
%                 'output_actions', {'SchedWaveTrig', 'NICSoundOut'},...
%                 'input_to_statechange',{'Clo','legalbreak';...
%                 'Tup','preflash'});
%         else
%             sma = add_state(sma,'name','nic_prestim','self_timer',settling_time,...
%                 'output_actions', {'SchedWaveTrig', 'NICSoundOut'},...
%                 'input_to_statechange',{'Clo','legalbreak';...
%                 'Tup','preflash'});
%         end
%         
        
%         sma = add_state(sma,'name','nic_prestim','self_timer',settling_time,...
%             'output_actions', {'SchedWaveTrig', 'NICSoundOut'},...
%             'input_to_statechange',{'Clo','legalbreak';...
%             'Tup','preflash'});
%                    %'output_actions',{'SoundOut',nic_sound_id},...
                   
       sma = add_state(sma, 'name', 'legalbreak', 'self_timer', value(legalbreaktime), ...
           'input_to_statechange', {'Chi', 'preflash', 'Clo', cpoke_out_state});
                   
        sma = add_state(sma, 'name', 'preflash', 'self_timer', .001, ...
            'input_to_statechange', {'Tup', 'current_state+1'});
                   
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
                'Clo', 'current_state+1'});
            
%             sma=add_state(sma,'self_timer',value(legalbreaktime),...
%                 'input_to_statechange',{'Chi','current_state+1'; ...
%                 'Tup',cpoke_out_state});
        end
        
        sma = add_state(sma,'name','nic_poststim','self_timer',delay_time,...
            'input_to_statechange',{'Clo','legalcbreak';...
            'Tup','wait_for_cout1'});
        
         sma = add_state(sma,'name','legalcbreak','self_timer',value(legalbreaktime),...
            'input_to_statechange',{'Chi','current_state+1';...
            'Tup',cpoke_out_state});
        
        sma = add_state(sma,'name','wait_for_cout1', 'self_timer', .001, ...
            'output_actions', {'SchedWaveTrig', 'GoSoundOut'; 'DOut', center1led},...
            'input_to_statechange',{'Clo','wait_for_spoke'; 'Tup', 'wait_for_cout2'});
        
        sma = add_state(sma, 'name', 'wait_for_cout2', ...
            'output_actions', {'SchedWaveTrig', '-NICSoundOut-stimulatorwave1'; 'DOut', center1led},...
            'input_to_statechange',{'Clo','wait_for_spoke'});
        %'output_actions',{'SoundOut',-nic_sound_id},...
        
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
                elseif this_trial == 'p'
                    led_dio = 0;
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
        
        if value(training_stage)<3
            sma = add_state(sma,'name','wait_for_spoke','self_timer',wait_for_spoke_timeout,...
                'output_actions',{'DOut',led_dio; 'SchedWaveTrig', '-NICSoundOut-stimulatorwave1'},...
                'input_to_statechange',{correct_response, 'hit_state';...
                error_response,error_state;...
                'Tup','timeout_state'});
            
            sma = add_state(sma,'name','hit_state','self_timer',reward_delay+hit_valve_time+0.1,...
                'output_actions',{'SoundOut',hit_sound_id;...
                'SchedWaveTrig','direct_reward'},...
                'input_to_statechange',{'Tup','pre_clean_up_state'});
            
            sma = add_state(sma,'name','error_state','self_timer',error_iti,...
                'output_actions',{'SoundOut',err_sound_id},...
                'input_to_statechange',{'Tup','pre_clean_up_state'});
            
        elseif value(training_stage)==3
            sma = add_state(sma,'name','wait_for_spoke','self_timer',wait_for_spoke_timeout,...
                'output_actions',{'SchedWaveTrig', '-NICSoundOut-stimulatorwave1'},...
                'input_to_statechange',{'Lhi', 'left_choice';...
                'Rhi', 'right_choice';...
                'Tup','timeout_state'});
            
            sma = add_state(sma, 'name', 'left_choice', 'self_timer', .001, ...
                'output_actions', {'SchedWaveTrig', 'left_reward'; 'SoundOut', lsound}, ...
                'input_to_statechange', {'Tup', 'hit_state'});
            
            sma = add_state(sma, 'name', 'right_choice', 'self_timer', .001, ...
                'output_actions', {'SchedWaveTrig', 'right_reward'; 'SoundOut', rsound}, ...
                'input_to_statechange', {'Tup', 'hit_state'});
            
            t = value(stimulator_history);
            if strcmp(value(StimState), 'hit_state') && t(end)==1
                %make hit state longer, for laserON wave.
               % p = value(PulseWidth);
                p = [0 4000];
                sma = add_state(sma, 'name', 'hit_state', 'self_timer', p(2)/1000, ...
                    'output_actions', {'SchedWaveTrig', 'stimulatorwave2'}, ...
                    'input_to_statechange', {'Tup', 'pre_clean_up_state'});
%                 sma = add_state(sma, 'name', 'hit_state', 'self_timer', .001, ...
%                     'input_to_statechange', {'Tup', 'clean_up_state'});
            else
                sma = add_state(sma, 'name', 'hit_state', 'self_timer', .001, ...
                    'output_actions', {'SchedWaveTrig', 'stimulatorwave2'}, ...
                    'input_to_statechange', {'Tup', 'pre_clean_up_state'});
            end
        end
        
        
        sma = add_state(sma,'name','timeout_state','self_timer',1,...
            'output_actions',{'SoundOut',to_sound_id},...
            'input_to_statechange',{'Tup','pre_clean_up_state'});
        
        if value(scale_vios)==1 && value(training_stage)==3
            
            t = min([value(this_right_volume) value(this_left_volume)]);
            %tmult = length(value(possible_volumes))+1-find(value(possible_volumes)==t);
            tind = find(value(possible_volumes)==t);
            tmult = value(scaling_factors(tind));
            
            sma = add_multi_sounds_state(sma,[-nic_sound_id viol_sound_id -go_sound_id],...
                'self_timer',violation_iti*tmult,...
                'state_name','violation_state','return_state','pre_clean_up_state');
        else
            sma = add_multi_sounds_state(sma,[-nic_sound_id viol_sound_id -go_sound_id],...
                'self_timer',violation_iti,...
                'state_name','violation_state','return_state','pre_clean_up_state');
        end
        
        sma = add_state(sma, 'name', 'pre_clean_up_state', 'self_timer', .001, ...
            'output_actions', {'SchedWaveTrig','-stimulatorwave1-stimulatorwave2-TrigScope'}, ...
            'input_to_statechange', {'Tup', 'clean_up_state'});
        
        sma = add_multi_sounds_state(sma,[-to_sound_id -viol_sound_id -hit_sound_id -err_sound_id -nic_sound_id -go_sound_id],...
            'state_name','clean_up_state','return_state','check_next_trial_ready');
        
        
        if value(training_stage)<=2
            dispatcher('send_assembler', sma, {'hit_state', 'error_state', 'pre_clean_up_state', 'violation_state','timeout_state'});
        elseif value(training_stage)>2
            dispatcher('send_assembler', sma, {'left_choice', 'right_choice', 'hit_state',...
                'pre_clean_up_state', 'violation_state','timeout_state'});
        end

        varargout{1} = sma;
        
    otherwise
        warning('do not know how to do %s',action);
end
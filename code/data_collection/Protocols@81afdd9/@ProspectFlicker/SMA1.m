
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
        
        % This code makes the protocol compatible with the head-fixed rigs,
        % in addition to the regular ones.
        if ~isnan(bSettings('get', 'DIOLINES', 'A5'));
            CW = bSettings('get', 'DIOLINES', 'A5');
            sma = StateMachineAssembler('full_trial_structure', 'use_happenings', 1, 'n_input_lines', 4);
        else
            sma = StateMachineAssembler('full_trial_structure', 'use_happenings', 1);
        end
        
        
        [LeftWValveTime, RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
        [LeftWMult, RightWMult] = SidesSection(obj, 'get_water_mult');
        
        %% Setup sounds
        
       % hit_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'HitSound');
        SoundInterface(obj, 'set', 'HitSound', 'Style', 'ToneSweep', 'Vol', .02, 'Freq1', 5000, 'Freq2', 1500, 'Dur1', 0.1, 'Dur2', 0.1);
        hit_sound_id = SoundManagerSection(obj, 'get_sound_id', 'HitSound');
        err_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'ErrorSound');
        viol_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'ViolationSound');
        to_sound_id  = SoundManagerSection(obj, 'get_sound_id', 'TimeoutSound');
        

         totaldur = value(nic_time)+value(delay_time)+value(settling_time);

     %  nic_sound_id = SoundManagerSection(obj, 'get_sound_id', 'NICSound');
        
        %% Declare variables
        % These will get moved to other functions as SoloParamHandles.
        
        if allow_nic_breaks==1
            cpoke_out_state='current_state';
        else
            cpoke_out_state='violation_state';
        end
        
        
        is_done=false;
        
        % Note if nic_time is zero no flashes will be played.
        
        
        
     %   while ~is_done
%                if value(training_stage)<2
%             nic_sound_id = SoundManagerSection(obj, 'get_sound_id', 'neutral_nic');
%         elseif value(training_stage)==2;
%            sv = [3:7:45];
%            indx = find(sv==value(this_safe_volume));
%            nicnames = {'three_nic';'ten_nic';'seventeen_nic';'twentyfour_nic';'thirtyone_nic';'thirtyeight_nic';'fortyfive_nic'}
%            nic_sound_id = SoundManagerSection(obj, 'get_sound_id', nicnames(indx));
%         end
        

            if value(training_stage)<2
             %   nic_sound_id = SoundManagerSection(obj, 'get_sound_id', 'neutral_nic');
                [LeftWValveTime RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
                left_stim =zeros(1, length(ceil(nic_time/bin_size))); 
                right_stim = left_stim;
                if rand<0.5
                    this_trial = 'l';
                    correct_response = 'Lhi';
                    led_dio=left1led;
                    water=left1water;
                    hit_valve_time = LeftWValveTime;
                    error_response = 'Rhi';
                    nic_sound_id = SoundManagerSection(obj, 'get_sound_id', 'left_neutral_nic');
                else
                    this_trial = 'r';
                    correct_response = 'Rhi';
                    led_dio=right1led;
                    water=right1water;
                    hit_valve_time = RightWValveTime;
                    error_response = 'Lhi';
                    nic_sound_id = SoundManagerSection(obj, 'get_sound_id', 'right_neutral_nic');
                end
            elseif value(training_stage)==2
                this_trial = 'p'; %p is for preference.  there is no correct side
                nflashes = value(risky_prob) * 10; %find(value(risky_prob_options)==value(risky_prob));
                bin_stim = rand(1, ceil(value(nic_time)/value(bin_size)));
                if length(bin_stim)<nflashes;
                   bin_stim = [bin_stim, zeros(1, nflashes-length(bin_stim))];   
                end
               % nic_freqs = [625 938 1250 1875 2500 3750 5000];
               
                %SoundInterface(obj, 'set','NICSound','Style','Tone', 'Vol', 0.002, 'Freq1', nic_freqs(indx), 'Dur1', ...
              %         length(bin_stim)*value(bin_size)+value(delay_time)+value(settling_time));
                 %  nic_sound_id = SoundManagerSection(obj, 'get_sound_id', 'NICSound');
                 totaldur = length(bin_stim)*value(bin_size)+value(delay_time)+value(settling_time);
                 nic_time.value = totaldur;
                 [dm, i] = sort(bin_stim);
                switch safe_side
                    case 'l', % if left is the safe side
                        lsound = hit_sound_id;
                        l_ul = value(this_safe_volume);
                        safe_hit.value = 1;
                        right_stim = zeros(1, length(bin_stim));
                        right_stim(i(1:nflashes)) = 1;
                        left_stim =zeros(1, length(right_stim));
                        if rand >= value(risky_prob) %if there's no reward on risky (right) side
                            risk_hit.value = 0;
                            rsound = err_sound_id;
                            r_ul = 0;
                        else
                            risk_hit.value =1;
                            rsound = hit_sound_id;
                            r_ul = value(risky_volume);
                        end
                        sv = [3:7:45];
                        indx = find(sv==value(this_safe_volume));
                         nic_freqs = [625 938 1250 1875 2500 3750 5000];

               
                    %    SoundInterface(obj, 'set','NICSound','Style','Tone', 'Vol', 0.002, 'Freq1', nic_freqs(indx), 'Dur1', ...
                     %  length(bin_stim)*value(bin_size)+value(delay_time)+value(settling_time), 'Bal', -1);
                     SoundInterface(obj, 'set','NICSound','Style','ToneSweep', 'Vol', 0.002, 'Freq1', nic_freqs(indx),'Freq2', nic_freqs(indx),...
                         'Dur1', .05, 'Dur2', .05, 'Bal', -1, 'Tau', 0, 'Gap', .02, 'Loop', 1); 
                     nic_sound_id = SoundManagerSection(obj, 'get_sound_id','NICSound');
                        
%                       %  nicnames = {'three_nic_left';'ten_nic_left';'seventeen_nic_left';...
%                             'twentyfour_nic_left';'thirtyone_nic_left';'thirtyeight_nic_left';'fortyfive_nic_left'};
%                         nic_sound_id = SoundManagerSection(obj, 'get_sound_id', nicnames{indx});
                        
                    case 'r', % if the right side is safe
                        rsound = hit_sound_id;
                        r_ul = value(this_safe_volume);
                        safe_hit.value = 1;
                        left_stim = zeros(1, length(bin_stim));
                        left_stim(i(1:nflashes)) = 1;
                        right_stim =zeros(1, length(left_stim));
                        if rand >= value(risky_prob)
                            l_ul = 0;
                            risk_hit.value = 0;
                            lsound  = err_sound_id;
                        else
                            risk_hit.value = 1;
                            lsound = hit_sound_id;
                            l_ul = value(risky_volume);
                        end
                        sv = [3:7:45];
                        indx = find(sv==value(this_safe_volume));
                        nic_freqs = [625 938 1250 1875 2500 3750 5000];
                        
%                         SoundInterface(obj, 'set','NICSound','Style','Tone', 'Vol', 0.002, 'Freq1', nic_freqs(indx), 'Dur1', ...
%                        length(bin_stim)*value(bin_size)+value(delay_time)+value(settling_time), 'Bal', 1);
                        SoundInterface(obj, 'set','NICSound','Style','ToneSweep', 'Vol', 0.002, 'Freq1', nic_freqs(indx),'Freq2', nic_freqs(indx),...
                         'Dur1', .05, 'Dur2', .05, 'Bal', 1, 'Tau', 0, 'Gap', .02, 'Loop', 1); 
                        nic_sound_id = SoundManagerSection(obj, 'get_sound_id','NICSound');
%                         nicnames = {'three_nic_right';'ten_nic_right';'seventeen_nic_right';...
%                             'twentyfour_nic_right';'thirtyone_nic_right';'thirtyeight_nic_right';'fortyfive_nic_right'};
%                         nic_sound_id = SoundManagerSection(obj, 'get_sound_id', nicnames{indx});
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
            
     %   end
        
        SidesSection(obj,'update_trial_history',this_trial);
        
        if value(training_stage)<2
            sma = add_scheduled_wave(sma, 'name', 'direct_reward', 'preamble', reward_delay, ...
                'sustain', hit_valve_time, 'DOut', water);
        end
        
        sma = add_scheduled_wave(sma, 'name', 'left_reward', 'preamble', reward_delay, ...
            'sustain',  LeftWValveTime, 'DOut', left1water);
        
        sma = add_scheduled_wave(sma, 'name', 'right_reward', 'preamble', reward_delay, ...
            'sustain',  RightWValveTime, 'DOut', right1water);
        
        sma = add_scheduled_wave(sma, 'name', 'NICSoundOut', 'preamble', 0, 'sustain', ...
            totaldur, 'sound_trig', nic_sound_id, 'loop',0);
        
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
        
        
        sma = add_state(sma,'name','wait_for_cpoke',...
            'self_timer',wait_for_cpoke_timeout,...
            'output_actions',{'SoundOut',-nic_sound_id},...
            'input_to_statechange',{'Tup','timeout_state'; ...
            'Chi','nic_prestim'});
        
        
        
        sma = add_state(sma,'name','nic_prestim','self_timer',settling_time,...
            'output_actions', {'SchedWaveTrig', 'NICSoundOut'},...
            'input_to_statechange',{'Clo','wait_for_cpoke';...
            'Tup','current_state+1'});
                   %'output_actions',{'SoundOut',nic_sound_id},...
        
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
            
            sma=add_state(sma,'self_timer',value(legalbreaktime),...
                'input_to_statechange',{'Chi','current_state+1'; ...
                'Tup',cpoke_out_state});
        end
        
        sma = add_state(sma,'name','nic_poststim','self_timer',delay_time,...
            'input_to_statechange',{'Clo','legalcbreak';...
            'Tup','wait_for_cout'});
        
         sma = add_state(sma,'name','legalcbreak','self_timer',value(legalbreaktime),...
            'input_to_statechange',{'Chi','current_state+1';...
            'Tup',cpoke_out_state});
        
        sma = add_state(sma,'name','wait_for_cout',...
            'output_actions', {'SchedWaveTrig', '-NICSoundOut'},...
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
        
        if value(training_stage)<2
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
            
        elseif value(training_stage)==2
            sma = add_state(sma,'name','wait_for_spoke','self_timer',wait_for_spoke_timeout,...
                'input_to_statechange',{'Lhi', 'left_choice';...
                'Rhi', 'right_choice';...
                'Tup','timeout_state'});
            
            sma = add_state(sma, 'name', 'left_choice', 'self_timer', .001, ...
                'output_actions', {'SchedWaveTrig', 'left_reward'; 'SoundOut', lsound}, ...
                'input_to_statechange', {'Tup', 'hit_state'});
            
            sma = add_state(sma, 'name', 'right_choice', 'self_timer', .001, ...
                'output_actions', {'SchedWaveTrig', 'right_reward'; 'SoundOut', rsound}, ...
                'input_to_statechange', {'Tup', 'hit_state'});
            
            sma = add_state(sma, 'name', 'hit_state', 'self_timer', .001, ...
                'input_to_statechange', {'Tup', 'clean_up_state'});
        end
        
        
        sma = add_state(sma,'name','timeout_state','self_timer',1,...
            'output_actions',{'SoundOut',to_sound_id},...
            'input_to_statechange',{'Tup','clean_up_state'});
        
        sma = add_multi_sounds_state(sma,[-nic_sound_id viol_sound_id],...
            'self_timer',violation_iti,...
            'state_name','violation_state','return_state','clean_up_state');
        
        sma = add_multi_sounds_state(sma,[-to_sound_id -viol_sound_id -hit_sound_id -err_sound_id -nic_sound_id],...
            'state_name','clean_up_state','return_state','check_next_trial_ready');
        
        
        if value(training_stage)<=1
            dispatcher('send_assembler', sma, {'hit_state', 'error_state', 'violation_state','timeout_state'});
        elseif value(training_stage)>1
            dispatcher('send_assembler', sma, {'left_choice', 'right_choice', 'violation_state','timeout_state'});
        end

        
    otherwise
        warning('do not know how to do %s',action);
end
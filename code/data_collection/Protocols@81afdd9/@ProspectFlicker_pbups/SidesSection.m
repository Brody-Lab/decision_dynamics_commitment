

function [x, y] = SidesSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action,
    
    % ------------------------------------------------------------------
    %              INIT
    % ------------------------------------------------------------------
    
    case 'init'
        x=varargin{1};
        y=varargin{2};
        
        NumeditParam(obj, 'led_time', 0.02, x,y,'label','LED On Time','TooltipString','Duration of each flash');
        next_row(y);
        NumeditParam(obj, 'bin_size', 0.2, x,y,'label','ILI Time','TooltipString','Min. seperation between flashes');
        next_row(y);
        NumeditParam(obj, 'legalbreaktime', .075, x, y, 'label', 'legalcbreak');
        next_row(y);
        NumeditParam(obj, 'nic_time', 2, x,y,'label','NIC Time','TooltipString','Length of NIC');
        next_row(y);
        NumeditParam(obj, 'wait_for_cpoke_timeout', 6000, x,y,'label','Wait for Cpoke Timeout','TooltipString','After this time go to the timeout state');
        next_row(y);
        ToggleParam(obj, 'allow_nic_breaks', 0, x,y,'OffString','Punish NIC Viol','OnString','Ignore NIC Viol','TooltipString','After this time go to the timeout state');
        next_row(y);
        NumeditParam(obj, 'settling_time', 0.25, x,y,'label','Pre-Stim NIC time','TooltipString','Time in NIC before starting flickers');
        next_row(y);
        NumeditParam(obj, 'delay_time', 0.1, x,y,'label','Post-Stim NIC time','TooltipString','Time in NIC after ending flickers');
        next_row(y);
        MenuParam(obj, 'side_lights' ,{'none','both','correct side'},1, x,y,'label','Side Lights','TooltipString','Controls the side LEDs during wait_for_spoke');
        next_row(y);
        NumeditParam(obj, 'wait_for_spoke_timeout', 4, x,y,'label','Response Timeout','TooltipString','Time after NIC to wait for a side poke');
        next_row(y);
        NumeditParam(obj, 'reward_delay', 0.1, x,y,'label','Reward Delay','TooltipString','Delay between side poke and reward delivery');
        next_row(y);
        ToggleParam(obj, 'ignore_errors', 0, x,y,'OffString','Errors Punished','OnString','Errors Ignored','TooltipString','If ignore errors, then subject will eventually get the reward at the correct poke');
        next_row(y);
        NumeditParam(obj, 'error_iti', 1, x,y,'label','Error Timeout','TooltipString','ITI on error trials');
        next_row(y);
        NumeditParam(obj, 'violation_iti', 1.5, x,y,'label','Violation Timeout','TooltipString','ITI on error trials');
        next_row(y);
        NumeditParam(obj, 'prob_test_trials', 0, x, y, 'label', 'prob_test_trials');
        
        next_column(x);
        y=5;
        NumeditParam(obj,'trials_in_stage',0,x,y,'label','Trial Counter');
        next_row(y);
        NumeditParam(obj,'training_stage',1,x,y,'label','Training Stage');
        next_row(y);
        ToggleParam(obj,'use_training',1,x,y,'OnString','Using Autotrain','OffString','Manual Settings');
        next_row(y);
        NumeditParam(obj, 'left_prob', 0, x, y, 'TooltipString', 'Probability of a left reward');
        next_row(y);
        NumeditParam(obj, 'right_prob', 0, x, y, 'TooltipString', 'Probability of a right reward');
        next_row(y);
        NumeditParam(obj, 'risky_prob_options', [0.1:.1:1], x, y, 'label', 'risky_prob_options');
        next_row(y);
        NumeditParam(obj, 'left_hit', 1, x, y, 'TooltipString', 'Will choosing left pay off?');
        next_row(y);
        NumeditParam(obj, 'right_hit', 1, x, y, 'TooltipString', 'Will choosing right pay off?');
        next_row(y);
        NumeditParam(obj, 'possible_volumes', [6, 9, 14, 21, 32, 48, 72], x, y, 'TooltipString', 'Volume on side with flashes');
        next_row(y);
        NumeditParam(obj, 'pbup_freqs', [6, 9, 14, 21, 32, 48, 72], x, y, 'label', 'pbup_freqs');
        next_row(y);
        NumeditParam(obj, 'this_left_volume', 21, x, y, 'label', 'this_left_volume');
        next_row(y);
        NumeditParam(obj, 'this_right_volume', 21, x, y, 'label', 'this_right_volume');
        next_row(y);
%         MenuParam(obj, 'safe_side' ,{'l','r', 'n'},1, x,y,'label','Safe Side','TooltipString','This side gives certain reward');
%         next_row(y);
        NumeditParam(obj, 'randomize_sides', 1, x, y, 'label', 'randomize_sides');
        next_row(y);
        NumeditParam(obj, 'block_length', 30, x, y, 'label', 'block_length', 'TooltipString', 'if ~randomize_sides, this is the block length');
        next_row(y);
        NumeditParam(obj, 'blockcounter', 0, x, y, 'label', 'blockcounter');
        % next_row(y);
        
        next_column(x);
        y=5;
        NumeditParam(obj, 'left_bias', 1, x, y, ...
            'TooltipString', 'This multiplier adjusts the probability of the left side being safe to counteract bias');
        next_row(y);
        NumeditParam(obj, 'right_bias', 1, x, y, ...
            'TooltipString', 'This multiplier adjusts the probability of the right side being safe to counteract bias');
        next_row(y);
        NumeditParam(obj, 'probmult', 1, x, y, 'TooltipString', 'changing the probability of the safe side to combat bias');
        next_row(y);
        ToggleParam(obj, 'antibias_wtr_mult', 1, x,y,...
            'OnString', 'AB ON',...
            'OffString', 'AB OFF',...
            'TooltipString', sprintf(['If on (black) then it disables the wtr_mult entries\n'...
            'and uses hitfrac to adjust the water times']));
        next_row(y);
        NumeditParam(obj, 'dep_today', 0, x, y, 'label', 'dep_today');
        next_row(y);
        NumeditParam(obj, 'since_h2o_deprive_ctr', 0, x, y, 'label', 'since_h2o_deprive_ctr');
        next_row(y);
        NumeditParam(obj, 'h2o_day_thresh', 4, x, y, 'label', 'h2o_day_thresh');
        next_row(y);
        NumeditParam(obj, 'deprive_h2o', 0, x, y, 'label', 'deprive_h2o');
        next_row(y);
        SoloFunctionAddVars('SMA1', 'ro_args', ...
            {'led_time'; 'legalbreaktime'; 'bin_size';'side_lights' ; 'ignore_errors';...
            'right_prob'; 'left_prob';'risky_prob_options';'this_right_volume'; ...%'safe_side';...
            'this_left_volume'; 'possible_volumes'; 'pbup_freqs'; 'nic_time'; 'wait_for_cpoke_timeout';...
            'settling_time'; 'delay_time';'allow_nic_breaks';'training_stage';'legalbreaktime';...
            'wait_for_spoke_timeout' ; 'reward_delay';'error_iti';'violation_iti';'antibias_wtr_mult'});
        
        SoloFunctionAddVars('SMA1', 'rw_args', ...
            {'right_hit'; 'left_hit'; 'nic_time'});
        
        
        %   History of hit/miss:
        SoloParamHandle(obj, 'hit_history',      'value', []);
        SoloParamHandle(obj, 'deltaf_history',      'value', []);
        SoloParamHandle(obj, 'right_click_history',      'value', []);
        SoloParamHandle(obj, 'left_click_history',      'value', []);
        SoloParamHandle(obj, 'went_right', 'value', []);
        SoloParamHandle(obj, 'went_left', 'value', []);
        SoloParamHandle(obj, 'ThisBupTimes', 'value', []);
        
        %   History of nose_in_center violations:
        SoloParamHandle(obj, 'violation_history', 'value', []);
        SoloParamHandle(obj, 'previous_sides', 'value', []);
        
        
    case 'update_trial_history',
        ps=value(previous_sides);
        
        this_side=varargin{1};
        
        ps(n_done_trials+1)=varargin{1};
        
        previous_sides.value=ps;
        
    case 'forced_stereo',
        
        
    case 'next_trial',
        
        %% update hit_history, previous_sides, etc
        was_viol=false;
        was_hit=false;
        if n_done_trials>0
            if ~isempty(parsed_events)
                if isfield(parsed_events,'states')
                    if isfield(parsed_events.states,'violation_state')
                        was_viol=rows(parsed_events.states.violation_state)>0 || rows(parsed_events.states.timeout_state)>0;
                    end
                end
                
            end
            
            violation_history.value=[violation_history(:); was_viol];
            
            if ~was_viol
                was_hit=rows(parsed_events.states.hit_state)>0;
                hit_history.value=[hit_history(:); was_hit];
                
            else
                % There was a violation or timeout
                hit_history.value=[hit_history(:); nan];
            end
            % Now calculate the deltaF and sides - this maybe interesting
            % even in a violation or timeout case.
            
            fn=fieldnames(parsed_events.states);
            led_states=find(strncmp('led',fn,3));
            deltaF=0;
            n_l=0;
            n_r=0;
            for lx=1:numel(led_states)
                lind=led_states(lx);
                if rows(parsed_events.states.(fn{lind}))>0
                    if fn{lind}(end)=='l'
                        deltaF=deltaF-1;
                        n_l=n_l+1;
                    elseif fn{lind}(end)=='r'
                        deltaF=deltaF+1;
                        n_r=n_r+1;
                    elseif fn{lind}(end)=='b'
                        n_l=n_l+1;
                        n_r=n_r+1;
                        
                    end
                end
            end
            
            deltaf_history.value=[deltaf_history(:); deltaF];
            right_click_history.value=[right_click_history(:); n_r];
            left_click_history.value=[left_click_history(:); n_l];
            
            
            %keep track of which side the animal went to
            if ~was_viol
                if value(training_stage)<2
                    if ~isempty(parsed_events.states.hit_state) && value(previous_sides(end))=='r';
                        wr = 1;
                        wl = 0;
                    elseif isempty(parsed_events.states.hit_state) && value(previous_sides(end))=='l';
                        wr = 1;
                        wl = 0;
                    elseif ~isempty(parsed_events.states.hit_state) && value(previous_sides(end)) == 'l';
                        wr = 0;
                        wl = 1;
                    elseif isempty(parsed_events.states.hit_state) && value(previous_sides(end)) == 'r';
                        wr = 0;
                        wl = 1;
                    end
                    went_right.value = [went_right(:); wr];
                    went_left.value = [went_left(:); wl];
                else
                    
                    wr = ~isempty(parsed_events.states.right_choice);
                    went_right.value = [went_right(:); wr];
                    wl = ~isempty(parsed_events.states.left_choice);
                    went_left.value = [went_left(:); wl];
                end
                
            else
                % There was a violation or timeout
                % hit_history.value=[hit_history(:); nan];
                went_right.value = [went_right(:); nan];
                went_left.value = [went_left(:); nan];
            end
            
        end
        
        
        
        %% Now set up next_trial
        %         nic_freqs = [625 937.5 1250 1875 2500 3750 5000];
        %         sv = [3:7:45];
        %         indx = find(sv==value(this_safe_volume));
        %         totaldur = value(nic_time)+value(delay_time)+value(settling_time);
        %         if value(training_stage) ~= 2
        %            % SoundInterface(obj, 'set','NICSound','Style','ToneFMWiggle', 'Vol', 0.02, 'Freq1', 1000, 'Dur1', 10);
        %         else
        %           %  SoundInterface(obj, 'set','NICSound','Style','Tone', 'Vol', 0.02, 'Freq1', nic_freqs(indx), 'Dur1', 10);
        %         end
        
        if use_training==1
            if ~was_viol && was_hit
                trials_in_stage.value=trials_in_stage+1;
            end
            
            switch value(training_stage) %#ok<*NODEF>
                case 0, %resests the settings
                    settling_time.value=0.001;
                    delay_time.value=0.001;
                    allow_nic_breaks.value=1;
                    ignore_errors.value=1;
                    side_lights.value=3;
                    training_stage.value=1;
                    trials_in_stage.value=0;
                    bin_size.value=0.050;
                    wait_for_cpoke_timeout.value=6000;
                    wait_for_spoke_timeout.value=6000;
                    reward_delay.value=0.01;
                    error_iti.value=10;
                    left_prob.value=0.5;
                    right_prob.value=0.5;
                    nic_time.value=0;
                    led_time.value=0.04;
                    risky_prob.value=0;
                    
                    
                case 1,  % Earliest stage of training.  Light chase and grow nose in center
                    
                    if ~was_viol  % if last trial was violation don't increment.
                        
                        
                        if settling_time<0.25
                            settling_time.value=settling_time+0.005;
                        else
                            delay_time.value=delay_time+0.002;
                        end
                        
                        if delay_time>0.05
                            allow_nic_breaks.value=0; %#ok<*STRNU>
                        else
                            allow_nic_breaks.value=1;
                        end
                        
                        
                        if delay_time>0.2
                            ignore_errors.value=0;
                        else
                            ignore_errors.value=1;
                        end
                        
                        if delay_time>3.2 %transition to next training stage
                            training_stage.value=2;
                            blockcounter.value = 0;
                            randomize_sides.value = 0;
                            trials_in_stage.value=0;
                            side_lights.value=3;
                        else
                            side_lights.value=3;
                        end
                    end
                    
                case 2, % start counting flashes
                    bin_size.value=0.25;
                    nic_time.value=3*bin_size+floor(rand*10)*bin_size;
                    settling_time.value=0.15+rand/5;
                    delay_time.value=0.05+rand/3;
                    led_time.value=0.02;
                    randomize_sides.value = 1;
                    side_lights.value=1;
                   % last_trial=previous_sides(end)=='r' || previous_sides(end)=='s';
                    blockcounter.value = value(blockcounter) + 1;
                    antibias_wtr_mult.value = 1;
                    trials_in_stage.value= value(trials_in_stage) + 1;
                    
                    if value(trials_in_stage) < 2500
                        risky_prob_options.value =  [1];%0.1:.1:1
                        possible_volumes.value = [6 21];%
                        
                    elseif value(trials_in_stage) >= 3000 && value(trials_in_stage) < 4500
                        risky_prob_options.value =  [0 1];%0.1:.1:1
                        possible_volumes.value = [6 21];%[3:7:45]
                        
                    elseif value(trials_in_stage) >= 4500 && value(trials_in_stage) < 8000
                        risky_prob_options.value =  [0 1];%0.1:.1:1
                        possible_volumes.value = [6 21 72];
                        
                    elseif value(trials_in_stage) >=8000 && value(trials_in_stage) < 11000
                        risky_prob_options.value = [0 0.5 1];
                        possible_volumes.value = [6 21 72];
                        
                    elseif value(trials_in_stage) >= 11000 && value(trials_in_stage) < 13500
                        risky_prob_options.value =  [0 0.5 1];%0.1:.1:1
                        possible_volumes.value = [6 21 32 72];%[3:7:45]
                        
                    elseif value(trials_in_stage) >= 13500 && value(trials_in_stage) < 16000
                        risky_prob_options.value = [0 0.1 0.5 0.9 1];
                        possible_volumes.value = [6 9 21 32 72];
                        
                    elseif value(trials_in_stage) >= 16000 && value(trials_in_stage) < 18500
                        risky_prob_options.value = [0 0.1 0.2 0.5 0.8 0.9 1];
                        possible_volumes.value = [6 9 14 21 32 72];
                        
                    elseif value(trials_in_stage) >= 18500
                        risky_prob_options.value = [0:.1:1];
                        possible_volumes.value = [6 9 14 21 32 48 72];
                        
                    end
                    
                    %% Do the anti-bias
                    %% if the rat favors one side, make that side have a higher
                    %% chance of yielding the lower expected value
                    doantibias = 0;
                    if n_done_trials>25 && antibias_wtr_mult==1 && value(training_stage)==2
                        hh=hit_history(n_done_trials-24:n_done_trials);
                        lc = value(went_left(n_done_trials-24:n_done_trials));
                        rc = value(went_right(n_done_trials-24:n_done_trials));
                        % ps=previous_sides(n_done_trials-24:n_done_trials);
                        right_hits=nanmean(rc);
                        left_hits=nanmean(lc);
                        doantibias = 1;
                        if abs(right_hits-left_hits)<0.2 || isnan(right_hits) || isnan(left_hits)
                            left_bias.value=0.5;
                            right_bias.value=0.5;
                        else
                            left_bias.value = left_hits;
                            right_bias.value = right_hits;
                        end
                    end
                    
                    
                    
                    if rand<0.5
                        left_prob.value = 1;
                        %get probability of reward on right side
                        rdice = rand(1, length(value(risky_prob_options)));
                        probindx = find(rdice==max(rdice));
                        right_prob.value = value(risky_prob_options(probindx));
                        
                    else
                        right_prob.value = 1;
                        %p(r) on left side
                        ldice = rand(1, length(value(risky_prob_options)));
                        probindx = find(ldice==max(ldice));
                        left_prob.value = value(risky_prob_options(probindx));
                    end
                    
                 
                    
                    %reward volume on right
                    rdice = rand(1, length(value(possible_volumes)));
                    volindx = find(rdice==max(rdice));
                    rrate = value(pbup_freqs(volindx));
                    this_right_volume.value = value(possible_volumes(volindx));
                    
                    %reward volume on left
                    ldice = rand(1, length(value(possible_volumes)));
                    volindx = find(ldice==max(ldice));
                    lrate = value(pbup_freqs(volindx));
                    this_left_volume.value = value(possible_volumes(volindx));
                    

                        
                        if doantibias ==1
                            if value(left_bias) >= .8; %bias is really bad.
                                left_prob.value = min(value(possible_volumes));
                                this_right_volume.value = max(value(possible_volumes));
                                right_prob.value = max(value(risky_prob_options));
%                                 if value(left_bias) > value(right_bias)
%                                     safe_side.value = 'r';
%                                 elseif value(left_bias) < value(right_bias);
%                                     safe_side.value = 'l';
%                                 end
                            elseif value(right_bias) >= .8;
                                right_prob.value = min(value(possible_volumes));
                                this_left_volume.value = max(value(possible_volumes));
                                left_prob.value = max(value(risky_prob_options));
                                
                        
                            end
                          
                        end
                    
                    
                    
            end
        end
        
        
    case 'get_water_mult'
        x = 1;
        y = 1;
    
        
    case 'get_hit_tally'
       
        if value(right_hit)==1 && value(went_right(end))==1;
            x = 'r';
            y = 1;
        elseif value(left_hit)==1 && value(went_left(end))==1;
            x = 'l';
            y = 1;
        else
            y = 0;
            x = 'n';
        end
               
%         if strcmp(value(safe_side), 'l');
%             wl = value(went_left);
%             if wl(end)==1
%                 x = 'l';
%                 y = 1;
%             else
%                 rh = get_history(risk_hit);
%                 if rh{end-1}==1;
%                     x = 'r';
%                     y = 1;
%                 else
%                     x = 'r';
%                     y = 0;
%                 end
%             end
%         elseif strcmp(value(safe_side), 'r');
%             wr = value(went_right);
%             if (wr(end)==1)
%                 x = 'r';
%                 y = 1;
%             else
%                 rh = get_history(risk_hit);
%                 if rh{end-1}==1;
%                     x = 'l';
%                     y = 1;
%                 else
%                     x = 'l';
%                     y = 0;
%                 end
%             end
%         end
        
        
    case 'end_sess'
        %if we're going to deprive ad lib water, do it here.
        if value(training_stage) ==2 && value(trials_in_stage) > 5000
            if value(deprive_h2o)==1;
                AdLibGUISection(obj, 'WaptorOnOff', 1);
                since_h2o_deprive_ctr.value = value(since_h2o_deprive_ctr)+1;
                if value(since_h2o_deprive_ctr)>=value(h2o_day_thresh);
                    since_h2o_deprive_ctr.value = 0;
                    %  AdLibGUISection(obj, 'manual_override', 1);
                    dep_today.value = 1;
                    AdLibGUISection(obj, 'water_needs_figure', 0);
                else
                    % AdLibGUISection(obj, 'manual_override', 0);
                    dep_today.value = 0;
                    AdLibGUISection(obj, 'water_needs_figure', 1);
                end
            end
        end
        
    case 'make_and_send_summary'
        % reset anti-bias
        left_bias.value=0.5;
        right_bias.value=0.5;
        probmult.value = 0.5;
        
        
        peh=cell2mat(parsed_events_history);
        hits=nan(size(peh));
        cpv=zeros(size(peh));
        ps=value(previous_sides(:));
        sides=nan(size(ps));
        sides(ps=='r')=1;
        sides(ps=='l')=-1;
        
        df=nan(size(peh));  % delta flashes
        nic=df;
        cout=extract_event(peh,'wait_for_cout(1,2)');
        cin=extract_event(peh,'wait_for_cpoke(end,2)');
        viol=extract_event(peh,'violation_state(1,1)');
        
        flashtimes=cell(size(peh));
        flashdurs=cell(size(peh));
        left_flash_dur=nan(size(peh));
        right_flash_dur=nan(size(peh));
        for px=1:numel(peh)
            this_stim_word=[];
            %calculate flash times
            fn=fieldnames(peh(px).states);
            led_states=find(strncmp('led',fn,3));
            flashtimes{px}.left = [];
            flashtimes{px}.right = [];
            flashdurs{px}.left = [];
            flashdurs{px}.right = [];
            good_trial=false;
            for lx=1:numel(led_states)
                lind=led_states(lx);
                this_state=peh(px).states.(fn{lind});
                if rows(this_state)>0
                    % if we actually went into this stat
                    good_trial=true;
                    flash_time=this_state(1);
                    flash_dur=this_state(2)-this_state(1);
                    if lx==1
                        first_led_time=flash_time;
                    end
                    if fn{lind}(end)=='l'
                        flashtimes{px}.left = [flashtimes{px}.left flash_time];
                        flashdurs{px}.left = [flashdurs{px}.left flash_dur];
                        
                        this_stim_word(lx)='l';
                    elseif fn{lind}(end)=='r'
                        flashtimes{px}.right = [flashtimes{px}.right  flash_time];
                        flashdurs{px}.right = [flashdurs{px}.right flash_dur];
                        
                        this_stim_word(lx)='r';
                        
                    elseif fn{lind}(end)=='b'
                        flashtimes{px}.left = [flashtimes{px}.left  flash_time];
                        flashtimes{px}.right = [flashtimes{px}.right  flash_time];
                        flashdurs{px}.left = [flashdurs{px}.left flash_dur];
                        flashdurs{px}.right = [flashdurs{px}.right flash_dur];
                        
                        
                        this_stim_word(lx)='b';
                        
                    elseif fn{lind}(end)=='n'
                        this_stim_word(lx)='n'; %#ok<*AGROW>
                    end
                end
                
            end
            this_stim_word(this_stim_word==0)=[];
            left_flash_dur(px)=sum(flashdurs{px}.left);
            right_flash_dur(px)=sum(flashdurs{px}.right);
            
            stim_word{px}=char(this_stim_word);
            
            
            if good_trial
                flashtimes{px}.right = flashtimes{px}.right - first_led_time;
                flashtimes{px}.left = flashtimes{px}.left - first_led_time;
            end
            
            % calculate pokes
            if isnan(cout(px)) || ~isnan(viol(px))
                cpv(px)=1;
                hits(px)=nan;
            else
                r_pokes=peh(px).pokes.R(:,1);
                l_pokes=peh(px).pokes.L(:,1);
                
                firstrightpoke=r_pokes(find(r_pokes>cout(px),1,'first'));
                firstleftpoke=l_pokes(find(l_pokes>cout(px),1,'first'));
                if isempty(firstrightpoke), firstrightpoke=+inf; end
                if isempty(firstleftpoke), firstleftpoke=+inf; end
                P=[firstleftpoke firstrightpoke];
                
                if all(isinf(P))
                    hits(px)=nan;
                    cpv(px)=1;
                else
                    
                    [pt,pind]=min(P);  % Which poke was first?
                    pind=2*(pind-1)-1;
                    if sides(px)==pind
                        hits(px)=1;
                    else
                        hits(px)=0;
                    end
                end
            end
            
        end
        nt=min([numel(hits) numel(ps) numel(value(deltaf_history)) numel(cpv)]); %nt = number of trials
        
        pd.flashdurs=flashdurs(1:nt);
        pd.flashtimes=flashtimes(1:nt);
        pd.left_flash_dur=left_flash_dur(1:nt);
        pd.right_flash_dur=right_flash_dur(1:nt);
        
        cpv=cpv(1:nt); % cpv = center poke violation
        hits=hit_history(1:nt);
        csides=ps(1:nt); % correct side on each trial
        deltaf_history=deltaf_history(1:nt);
        n_left=left_click_history(1:nt);
        n_right=right_click_history(1:nt);
        
        pd.deltaF=deltaf_history(:); %#R-#L
        pd.n_left=n_left(:);
        pd.n_right=n_right(:);
        nic=cell2mat(get_history(nic_time));
        pre_nic=cell2mat(get_history(settling_time));
        post_nic=cell2mat(get_history(delay_time));
        pd.nic=nic(1:nt);
        pd.stim_word=stim_word(1:nt)';
        pd.pre_nic=pre_nic(1:nt);
        pd.post_nic=post_nic(1:nt);
        pd.csides=csides;
        slh=get_history(side_lights);
        slh=slh(1:nt);
        csides(csides=='s' & strncmp('cor',slh,3))='r';
        csides(csides=='m' & strncmp('cor',slh,3))='l';
        
        pd.sides=csides(:);
        
        
        pd.bin_size=cell2mat(get_history(bin_size));
        pd.led_time=cell2mat(get_history(led_time));
        pd.left_prob=cell2mat(get_history(left_prob));
        pd.right_prob=cell2mat(get_history(right_prob));
        pd.training_stage=cell2mat(get_history(training_stage));
        pd.side_lights=get_history(side_lights);
       % pd.safe_side = cell2mat(get_history(safe_side));
        pd.this_left_volume = cell2mat(get_history(this_left_volume));
        pd.this_right_volume = cell2mat(get_history(this_right_volume));
       % pd.risky_prob = cell2mat(get_history(risky_prob));
        % pd.risky_prob_options = cell2mat(get_history(risky_prob_options));
        % pd.safe_volumes = cell2mat(get_history(safe_volumes));
    %    pd.risky_volume = cell2mat(get_history(risky_volume));
     %   pd.risk_hit = cell2mat(get_history(risk_hit));
        pd.went_right = value(went_right);
        pd.went_left = value(went_left);
        pd.probmult = cell2mat(get_history(probmult));
        pd.right_bias = cell2mat(get_history(right_bias));
        pd.left_bias = cell2mat(get_history(left_bias));
        pd.left_hit = cell2mat(get_history(left_hit));
        pd.right_hit = cell2mat(get_history(right_hit));
        %often when the protocol prepairs the next trial it saves an
        %additional paramter for a trial that the animal does not complete
        %here we get rid of the unused paramter (nt= number of trials
        %performed by the animal)
        pd.side_lights = pd.side_lights(1:nt);
        pd.bin_size  =  pd.bin_size(1:nt);
        pd.led_time  =  pd.led_time(1:nt);
        pd.left_prob = pd.left_prob(1:nt);
        pd.right_prob=pd.right_prob(1:nt);
        
        pd.left_hit = pd.left_hit(1:nt);
        pd.right_hit = pd.right_hit(1:nt);
        
        pd.training_stage=pd.training_stage(1:nt);
        pd.this_left_volume = pd.this_left_volume(1:nt);
        pd.this_right_volume = pd.this_right_volume(1:nt);
        
      %  pd.this_safe_volume = pd.this_safe_volume(1:nt);
      %  pd.risky_prob = pd.risky_prob(1:nt);
   
    %    pd.risky_volume = pd.risky_volume(1:nt);
     %   pd.risk_hit = pd.risk_hit(1:nt);
        pd.went_right = pd.went_right(1:nt);
        pd.went_left = pd.went_left(1:nt);
        pd.probmult = pd.probmult(1:nt);
        pd.right_bias = pd.right_bias(1:nt);
        pd.left_bias = pd.left_bias(1:nt);
        deprive_h2o = cell2mat(get_history(deprive_h2o));
        pd.deprive_h2o = deprive_h2o(end);
        deptoday = cell2mat(get_history(dep_today));
        pd.deprive_h2o_today = deptoday(end);
        
        
         pd.bupsdata   = get_history(ThisBupTimes);
         pd.bupsdata = ThisBupTimes(1:nt);
    %pd.stimdata   = PBupsSection(obj, 'get_all_stimulator_specs');

        
        
        pd.hits=hits;
        pd.cpv=cpv;
        % pd.led_time_R=led_time_R;
        % pd.led_time_L=led_time_L;
        sendsummary(obj,'hits',hits,'sides',csides,'protocol_data',pd);
        
        
        
        
        
end



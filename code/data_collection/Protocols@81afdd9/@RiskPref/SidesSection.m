function [x, y] = SidesSection(obj, action, varargin)
%for the foraging task to determine probability distortion
%(ProspectForaging) cmc Nov 2015

GetSoloFunctionArgs(obj);

switch action,
    
    % ------------------------------------------------------------------
    %              INIT
    % ------------------------------------------------------------------
    
    case 'init'
        x=varargin{1};
        y=varargin{2};
        
        
        
        % next_row(y);
        NumeditParam(obj, 'wait_for_cpoke_timeout', 60, x,y,'label','Wait for Cpoke Timeout','TooltipString','After this time go to the timeout state');
        next_row(y);
        ToggleParam(obj,  'allow_nic_breaks', 0, x,y,'OffString','Punish NIC Viol','OnString','Ignore NIC Viol','TooltipString','After this time go to the timeout state');
        next_row(y);
        NumeditParam(obj, 'wait_for_spoke_timeout', 4, x,y,'label','Response Timeout','TooltipString','Time after NIC to wait for a side poke');
        next_row(y);
        NumeditParam(obj, 'reward_delay', 0.1, x,y,'label','Reward Delay','TooltipString','Delay between side poke and reward delivery');
        next_row(y);
        NumeditParam(obj, 'error_iti', 1.5, x,y,'label','Error Timeout','TooltipString','ITI on error trials');
        next_row(y);
        NumeditParam(obj, 'nic_time', .001, x,y,'label','NIC Time','TooltipString','Length of NIC');
        next_row(y);
        NumeditParam(obj, 'growNIC_incr', .002, x,y,'label','growNIC_incr','TooltipString','Grow NIC time by this much');
        next_row(y);
        NumeditParam(obj, 'Max_NIC', 1.2, x,y,'label','Maximum NIC','TooltipString','Max NIC time');
        next_row(y);
        NumeditParam(obj, 'violation_iti', 1, x,y,'label','Violation Timeout','TooltipString','ITI on error trials');
        
        next_column(x);
        y=5;
        NumeditParam(obj, 'HighVarVol', [0 60], x,y,'label','HighVarVol','TooltipString','High Variance Volume');
        next_row(y);
        NumeditParam(obj, 'LowVarVol', [15 45], x,y,'label','LowVarVol','TooltipString','Low Variance Volume');
        next_row(y);
        MenuParam(obj, 'this_right_var', {'high', 'low'}, 2, x, y, 'label', 'this_right_var', 'TooltipString', 'right water');
        next_row(y);
        MenuParam(obj, 'this_left_var', {'high', 'low'}, 2, x, y, 'label', 'this_left_var', 'TooltipString', 'left_water');
        next_row(y);
        NumeditParam(obj, 'right_hit', 1, x, y, 'label', 'right_hit', 'TooltipString', 'Will right choice give water');
        next_row(y);
        NumeditParam(obj, 'left_hit', 1, x, y, 'label', 'left_hit', 'TooltipString', 'Will left choice give water')
        next_row(y);
        NumeditParam(obj, 'forced_choice', 1, x,  y, 'label', 'forced_choice');
        next_row(y);
        MenuParam(obj, 'second_sound', {'lefthigh', 'leftlow', 'righthigh', 'rightlow'}, 1, x, y, 'label', 'second_sound');
        next_row(y);
        MenuParam(obj, 'first_sound', {'lefthigh', 'leftlow', 'righthigh', 'rightlow'}, 1, x, y, 'label', 'first_sound');
        next_row(y);
        NumeditParam(obj, 'this_left_volume', 24, x, y, 'label', 'this_left_volume');
        next_row(y);
        NumeditParam(obj, 'this_right_volume', 24, x, y, 'label', 'this_right_volume');
        next_row(y);
        
        next_column(x);
        y=5;
        NumeditParam(obj,'trials_in_stage',1,x,y,'label','Trial Counter');
        next_row(y);
        NumeditParam(obj,'training_stage',1,x,y,'label','Training Stage');
        next_row(y);
        ToggleParam(obj,'use_training',1,x,y,'OnString','Using Autotrain','OffString','Manual Settings');
        next_row(y);
        NumeditParam(obj, 'left_wtr_mult', 1, x, y, ...
            'TooltipString', 'all left reward times are multiplied by this number');
        next_row(y);
        NumeditParam(obj, 'right_wtr_mult', 1, x, y, ...
            'TooltipString', 'all right reward times are multiplied by this number');
        next_row(y);
        ToggleParam(obj, 'antibias_wtr_mult', 1, x,y,...
            'OnString', 'AB ON',...
            'OffString', 'AB OFF',...
            'TooltipString', sprintf(['If on (black) then it disables the wtr_mult entries\n'...
            'and uses hitfrac to adjust the water times']));
        next_row(y);
        NumeditParam(obj, 'bias_coin', .5, x, y, 'label', 'bias_coin');
        next_row(y);
        
        SoloFunctionAddVars('SMA1', 'ro_args', ...
            {'training_stage';'nic_time'; 'growNIC_incr';'wait_for_cpoke_timeout'; ...
            'allow_nic_breaks';'wait_for_spoke_timeout' ; 'reward_delay';'left_wtr_mult';...
            'error_iti';'violation_iti';'right_wtr_mult'; 'HighVarVol'; 'LowVarVol';...
            'this_right_var'; 'this_left_var'; 'forced_choice'; 'bias_coin'});
        SoloFunctionAddVars('SMA1', 'rw_args', {'first_sound'; 'second_sound';'left_hit'; ...
            'right_hit'; 'this_left_volume'; 'this_right_volume'});
%         SoloFunctionAddVars('StimulusSection', 'ro_args', ...
%             {'risky_prob_options'; 'reward_options'; 'test_this_vol'});
          
        %   History of nose_in_center violations:
        SoloParamHandle(obj, 'violation_history', 'value', []);
        SoloParamHandle(obj, 'hit_history', 'value', []);
        SoloParamHandle(obj, 'went_right', 'value', []);
        SoloParamHandle(obj, 'went_left', 'value', []);
        SoloParamHandle(obj, 'previous_sides', 'value', []);
        DeclareGlobals(obj, 'ro_args', {'went_right'; 'went_left'});
        
        
    case 'update_trial_history',
        ps=value(previous_sides);
        ps(n_done_trials+1)=varargin{1};
        
        previous_sides.value=ps;
        
%     case 'trial_completed'
%         trials_in_stage.value = value(trials_in_stage) + 1;
        
    case 'next_trial',
        
        if value(n_done_trials) == 0 & value(training_stage)>=2;
            nic_time.value = 1.2;
        end
        
        
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
            
            %keep track of which side the animal went to
            if ~was_viol
                hit_history.value=[hit_history(:); 1];
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
                hit_history.value=[hit_history(:); nan];
                went_right.value = [went_right(:); nan];
                went_left.value = [went_left(:); nan];
            end
            
            
            
        end
        
        
        %% Now set up next_trial
        
        
        if use_training==1
            %  if ~was_viol && was_hit
            if ~was_viol
                trials_in_stage.value=value(trials_in_stage)+1;
            end
            
            switch value(training_stage) %#ok<*NODEF>
                case 0,
                    settling_time.value=0.001;
                    allow_nic_breaks.value=1;
                    ignore_errors.value=1;
                    training_stage.value=1;
                    trials_in_stage.value=0;
                    wait_for_cpoke_timeout.value=600;
                    wait_for_spoke_timeout.value=600;
                    reward_delay.value=0.01;
                    error_iti.value=1.5;
                    nic_time.value=0.001;
                    this_left_var.value = nan;
                    this_right_var.value = nan;
                    
                    
                case 1,  % Light chase and grow nose in center time
                    
                    if ~was_viol  % if last trial was violation don't increment.
                        
                        nic_time.value=value(nic_time)+value(growNIC_incr);
                        allow_nic_breaks.value=0; %#ok<*STRNU>
                        
                        
                        if value(nic_time)>=value(Max_NIC) % increased this time to make the transition easier
                            training_stage.value=2;
                            trials_in_stage.value=0;
                        end
                    end
                    
                case 2, % start to present stimuli.
                    forced_choice.value = 1;
                    if value(trials_in_stage) < 2500
                        this_left_var.value = 'low';
                        this_right_var.value = 'low';
                    elseif value(trials_in_stage) >= 2500 && value(trials_in_stage) < 5000
                        this_left_var.value = 'high';
                        this_right_var.value = 'high';
                    elseif value(trials_in_stage) >= 5000
                        if rand>.5
                            this_left_var.value = 'low';
                            this_right_var.value = 'high';
                        else
                            this_left_var.value = 'high';
                            this_right_var.value = 'low';
                        end
                    end
                    if value(trials_in_stage) > 8000;
                        training_stage.value = 3;
                        trials_in_stage.value = 0;
                    end
                    
                case 3, %interleave forced choice and free choice trials.
                    if rand<0.05 %5 percent of trials will be forced choice trials.
                        forced_choice.value = 1;
                    else
                        forced_choice.value = 0; 
                    end
                    if rand>.5
                        this_left_var.value = 'low';
                        this_right_var.value = 'high';
                    else
                        this_left_var.value = 'high';
                        this_right_var.value = 'low';
                    end
                    
                    if n_done_trials>25 && value(antibias_wtr_mult)==1
                  
                        right_hits=nanmean(went_right(n_done_trials-24:n_done_trials));
                        left_hits=nanmean(went_left(n_done_trials-24:n_done_trials));
                        
                        if abs(right_hits-left_hits)<0.3 || isnan(right_hits) || isnan(left_hits)
                            bias_coin.value=0.5;
                        else
                            forced_choice.value = 1;
                            if right_hits>left_hits
                                bias_coin.value = 1;
                            elseif right_hits<left_hits;
                                bias_coin.value = 0;
                            end
                        end
                        
                        
                    end
                    
            end
        end
        
        
    case 'get_water_mult',
        x=left_wtr_mult+0;
        y=right_wtr_mult+0;
        
    case 'get_hit_tally'
        
        wr = value(went_right);
        wl = value(went_left);
        if wr(end)==1;
            x = 'r';
            rh = get_history(right_hit);
            if rh{end-1}==1;
                y = 1;
            else
                y = 0;
            end
        else
            x = 'l';
            lh = get_history(left_hit);
            if lh{end-1} ==1;
                y = 1;
            else
                y = 0;
            end
        end
        
        
    case 'end_sess'
        %if we're going to deprive ad lib water, do it here.
       % if value(deprive_h2o)==1;
%             AdLibGUISection(obj, 'WaptorOnOff', 1);
%             if value(since_h2o_deprive_ctr)>=value(h2o_day_thresh);
%                 since_h2o_deprive_ctr.value = 0;
%                 %  AdLibGUISection(obj, 'manual_override', 1);
%                 AdLibGUISection(obj, 'water_needs_figure', 0);
%             else
%                 % AdLibGUISection(obj, 'manual_override', 0);
%                 AdLibGUISection(obj, 'water_needs_figure', 1);
%             end
%        % end
        
        
    case 'make_and_send_summary',
        
        % reset anti-bias
     %   left_wtr_mult.value=1;
     %   right_wtr_mult.value=1;
        bias_coin.value = 0.5;
        
       % nt = n_done_trials
        
        peh=cell2mat(parsed_events_history);
        nt = length(peh);
        ps=value(previous_sides(:));
        pd.sides = ps(1:nt);
        sides = ps(1:nt);
        cout=extract_event(peh,'wait_for_cout(1,2)');
        cin=extract_event(peh,'wait_for_cpoke(end,2)');
        viol=extract_event(peh,'violation_state(1,1)');
        
        pd.nic=cell2mat(get_history(nic_time));
        pd.training_stage=cell2mat(get_history(training_stage));
        pd.trials_in_stage = cell2mat(get_history(trials_in_stage));
        
        pd.went_right = value(went_right);
        pd.went_left = value(went_left);
        hits = ones(length(value(went_left)), 1);
        hits = hits(1:nt);
        pd.hits = hits;
        pd.first_sound = get_history(first_sound);
        pd.second_sound = get_history(second_sound);
        pd.forced_choice = cell2mat(get_history(forced_choice));
        pd.this_left_volume = cell2mat(get_history(this_left_volume));
        pd.this_right_volume = cell2mat(get_history(this_right_volume));
        pd.bias_coin = cell2mat(get_history(bias_coin));
        
        pd.nic = pd.nic(1:nt);
        pd.training_stage = pd.training_stage(1:nt);
        pd.trials_in_stage = pd.trials_in_stage(1:nt);
        pd.went_right = pd.went_right(1:nt);
        pd.went_left = pd.went_left(1:nt);
        pd.hits = pd.hits(1:nt);
        pd.first_sound = pd.first_sound(1:nt);
        pd.second_sound = pd.second_sound(1:nt);
        pd.forced_choice = pd.forced_choice(1:nt);
        pd.this_left_volume = pd.this_left_volume(1:nt);
        pd.this_right_volume = pd.this_right_volume(1:nt);
        pd.bias_coin = pd.bias_coin(1:nt);
        
        sendsummary(obj,'hits',hits,'sides',sides,'protocol_data',pd);
        
end



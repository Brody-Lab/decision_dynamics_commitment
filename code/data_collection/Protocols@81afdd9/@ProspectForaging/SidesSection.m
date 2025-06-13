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
        MenuParam(obj, 'side_lights' ,{'none','both','correct side','anti side'},1, x,y,'label','Side Lights','TooltipString','Controls the side LEDs during wait_for_spoke');
        next_row(y);
        NumeditParam(obj, 'wait_for_spoke_timeout', 4, x,y,'label','Response Timeout','TooltipString','Time after NIC to wait for a side poke');
        next_row(y);
        NumeditParam(obj, 'reward_delay', 0.1, x,y,'label','Reward Delay','TooltipString','Delay between side poke and reward delivery');
        next_row(y);
        ToggleParam(obj, 'ignore_errors', 0, x,y,'OffString','Errors Punished','OnString','Errors Ignored','TooltipString','If ignore errors, then subject will eventually get the reward at the correct poke');
        next_row(y);
        NumeditParam(obj, 'error_iti', 1.5, x,y,'label','Error Timeout','TooltipString','ITI on error trials');
        next_row(y);
        NumeditParam(obj, 'nic_time', .001, x,y,'label','NIC Time','TooltipString','Length of NIC');
        next_row(y);
        NumeditParam(obj, 'growNIC_incr', .002, x,y,'label','growNIC_incr','TooltipString','Grow NIC time by this much');
        next_row(y);
        NumeditParam(obj, 'Max_NIC', .500, x,y,'label','Maximum NIC','TooltipString','Max NIC time');
        next_row(y);
        NumeditParam(obj, 'violation_iti', 1, x,y,'label','Violation Timeout','TooltipString','ITI on error trials');
        
        next_column(x);
        y=5;
        NumeditParam(obj, 'max_trials_in_con', 300, x, y, 'label', 'Max trials per con');
        next_row(y);
        NumeditParam(obj, 'risky_pref', NaN, x, y, 'label', 'Percent Risky Choices');
        next_row(y);
        NumeditParam(obj, 'window_for_avg', 20, x, y, 'label', 'Window for Avg');
        next_row(y);
        NumeditParam(obj, 'trials_in_this_con', 1, x, y, 'label', 'Trials in this con');
        next_row(y);
        NumeditParam(obj, 'risky_amount', 10, x, y, 'label', 'Risky reward', 'TooltipString', 'Reward amount at risky option');
        next_row(y);
        NumeditParam(obj, 'risky_prob', 0.5, x,y,'label','Risky Prob','TooltipString','Prob. of right LED flash in each interval.');
        next_row(y);
        NumeditParam(obj, 'epsilon', 1, x, y, 'label', 'epsilon', 'TooltipString', 'Search increment multiplier');
        next_row(y);
        NumeditParam(obj, 'exit_rule', .5, x, y, 'label', 'exit_rule');
        next_row(y);
        NumeditParam(obj, 'min_trials_for_PEST', 15, x, y, 'label', 'min_trials_for_PEST');
        next_row(y);
        NumeditParam(obj, 'use_PEST', 0, x, y, 'label', 'use_PEST');
        next_row(y);
        NumeditParam(obj, 'min_safe_amount', 0.5, x, y, 'label', 'Min safe reward', 'TooltipString', 'Minimum allowable safe amount');
        next_row(y);
        NumeditParam(obj, 'safe_prob', 1, x, y, 'label', 'Safe prob', 'TooltipString', 'This should be 1 unless we are testing the rats strategy');
        next_row(y);
        NumeditParam(obj, 'safe_amount', 10, x, y, 'label', 'Safe reward', 'TooltipString', 'Searching for certainty equivalent of safe option');
        next_row(y);
        NumeditParam(obj, 'numtrials_two_gambles', 30, x, y, 'label', 'numtrials_two_gambles');
        next_row(y);
        NumeditParam(obj, 'test_gambles_now', 0, x, y, 'label', 'test_gambles_now');
        next_row(y);
        NumeditParam(obj, 'test_two_gambles', 0, x, y, 'label', 'test_two_gambles');
        next_row(y);
        NumeditParam(obj, 'reward_options', [15 25 35 50 60], x, y, 'label', 'reward_oiptions');
        next_row(y);
        NumeditParam(obj, 'risky_prob_options', [0.1:.1:1], x, y, 'label', 'risky_prob_options');
        next_row(y);
        NumeditParam(obj, 'choose_wisely', 1, x, y, 'label', 'choose_wisely', 'TooltipString', 'if set to 1, will choose unexplored prob/amount combos');
        next_row(y);
        % NumeditParam(obj, 'safe_prob', 1.0, x,y,'label','Safe Prob','TooltipString','Prob. of left LED flash in each interval.');
        % next_row(y);
        NumeditParam(obj, 'randomize_sides', 1, x, y, 'label', 'randomize_sides');
        next_row(y);
        MenuParam(obj, 'safe_side' ,{'l','r'},1, x,y,'label','Safe Side','TooltipString','This side gives certain reward');
        next_row(y);
        NumeditParam(obj, 'safe_hit', 1, x, y, 'label', 'Will safe side payoff?');
        next_row(y);
        NumeditParam(obj, 'risk_hit', 1, x, y, 'label', 'Will risk payoff?', 'TooltipString', 'Tells whether the risky side will yield reward on this trial');
        next_row(y);
        NumeditParam(obj, 'test_this_vol', 25, x, y, 'label', 'test_this_vol');
        next_row(y);
        NumeditParam(obj, 'CEtest_ntrials', 50, x, y, 'label', 'CEtest_ntrials');
        next_row(y);
        NumeditParam(obj, 'testing_CEs_now', 0, x, y, 'label', 'testing_CEs_now');
        next_row(y);
        NumeditParam(obj, 'CE_test', 0, x, y, 'label', 'CE_test', 'TooltipString', 'The volume being tested as the CE');
        next_row(y);
        NumeditParam(obj, 'test_CEs', 0, x, y, 'label', 'test_CEs');
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
        NumeditParam(obj, 'since_h2o_deprive_ctr', 0, x, y, 'label', 'since_h2o_deprive_ctr');
        next_row(y);
        NumeditParam(obj, 'h2o_day_thresh', 4, x, y, 'label', 'h2o_day_thresh');
        next_row(y);
        NumeditParam(obj, 'deprive_h2o', 0, x, y, 'label', 'deprive_h2o');
        next_row(y);
        
        SoloFunctionAddVars('SMA1', 'ro_args', ...
            {'training_stage';'side_lights' ; 'ignore_errors';...
            'risky_prob'; 'safe_prob'; 'safe_side';...
            'nic_time'; 'growNIC_incr';'wait_for_cpoke_timeout'; 'allow_nic_breaks' ; ...
            'wait_for_spoke_timeout' ; 'reward_delay';'left_wtr_mult';...
            'error_iti';'violation_iti';'right_wtr_mult'; 'test_gambles_now'});
        SoloFunctionAddVars('SMA1', 'rw_args', {'risk_hit'; 'safe_hit'; 'risky_prob'; 'risky_amount';...
            'safe_amount'; 'trials_in_this_con'});
        SoloFunctionAddVars('StimulusSection', 'ro_args', ...
            {'risky_prob_options'; 'reward_options'; 'test_this_vol'});
        
        
        
        %   History of nose_in_center violations:
        SoloParamHandle(obj, 'violation_history', 'value', []);
        SoloParamHandle(obj, 'went_right', 'value', []);
        SoloParamHandle(obj, 'went_left', 'value', []);
        SoloParamHandle(obj, 'previous_sides', 'value', []);
        DeclareGlobals(obj, 'ro_args', {'went_right'; 'went_left'; 'risk_hit'; 'safe_hit'});
        
        
    case 'update_trial_history',
        ps=value(previous_sides);
        ps(n_done_trials+1)=varargin{1};
        
        previous_sides.value=ps;
        
    case 'trial_completed'
        trials_in_stage.value = value(trials_in_stage) + 1;
        trials_in_this_con.value = value(trials_in_this_con)+1;
        
    case 'next_trial',
        
        if value(n_done_trials) == 0
            rewards = value(reward_options);
            p = rand(1,length(value(risky_prob_options)));
            r = rand(1,length(rewards));
            
            trials_in_stage.value = 0;
            trials_in_this_con.value = 0;
            risky_pref_history.value = NaN;
            epsilon.value = 1;
            max_trials_in_con.value = 300;
            
            if value(randomize_sides)==1
                if rand>.5
                    safe_side.value = 'l';
                    %  risky_side.value = 'r';
                else
                    safe_side.value = 'r';
                    %  risky_side.value = 'l';
                end
            end
            
            tvar = rand;
            %tvar2 = rand;
            if tvar<.3 && value(test_two_gambles)==1;
                risky_prob.value = value(risky_prob_options(find(p==max(p))));
                risky_amount.value = rewards(find(r==max(r)));
                safe_amount.value = value(risky_amount);
                p2 = rand(1,length(value(risky_prob_options)));
                safe_prob.value = value(risky_prob_options(find(p2==max(p2))));
                test_gambles_now.value = 1;
                trials_in_this_con.value = 0;
                if strcmp(value(safe_side), 'l'); %length(safe_side)==4; %case left
                    left_prob.value=value(safe_prob);
                    right_prob.value=value(risky_prob);
                elseif strcmp(value(safe_side), 'r'); %length(safe_side)==5; %case right
                    right_prob.value=value(safe_prob);
                    left_prob.value = value(risky_prob);
                end
            elseif tvar > .7 && value(test_CEs)==1;
               % if value(choose_wisely)==1
               try
                [x] = StimulusSection(obj, 'init');
               catch
                   x = nan(length(risky_prob_options), length(.1:.1:1));
               end
             
                np = (.1:.1:.9);
                dice = rand(1,length(np));
                risky_prob.value = np(dice==max(dice));
                pind = find(value(risky_prob_options)==value(risky_prob));
                
                if length(value(test_this_vol))>1
                    dice = rand(1, length(value(test_this_vol)));
                    risky_amount.value = value(test_this_vol(dice==max(dice)));
                else
                    risky_amount.value = value(test_this_vol);
                end
                rind = find(value(reward_options)==value(risky_amount));
                
                if ~isnan(x(rind, pind))
                safe_amount.value = x(rind, pind);
                CE_test.value = value(safe_amount);
                else
                    safe_amount.value = rind*pind;
                    CE_test.value = value(safe_amount);
                end
                safe_prob.value = 1;
                
                testing_CEs_now.value = 1;
                trials_in_this_con.value = 0;
                if strcmp(value(safe_side), 'l'); %length(safe_side)==4; %case left
                    left_prob.value=value(safe_prob);
                    right_prob.value=value(risky_prob);
                elseif strcmp(value(safe_side), 'r'); %length(safe_side)==5; %case right
                    right_prob.value=value(safe_prob);
                    left_prob.value = value(risky_prob);
                end
            else
                if value(choose_wisely)==1; %if we want to choose reward amount/prob combinations that the animal has not seen before.
                    [expmtr, ratname]=SavingSection(obj, 'get_info');
                    if ~strcmp(ratname, 'ratname');
                        [x] = StimulusSection(obj, 'init');
                        %  [w, ce] = ce_overdays(S);
                        
                        [nr,nc] = find(isnan(x));
                        
                        if ~isempty(nc)
                            dice = rand(1,length(nr));
                            risky_prob.value = value(risky_prob_options(nc(find(dice==max(dice)))));
                            risky_amount.value = rewards(nr(find(dice==max(dice))));
                            %   safe_amount.value = value(risky_amount)*value(risky_prob);
                            safe_amount.value = value(risky_amount)/2; %%Christine is trying this out to see if it changes how quickly animals converge on CE
                        else
                            risky_prob.value = value(risky_prob_options(find(p==max(p))));
                            risky_amount.value = rewards(find(r==max(r)));
                            %  safe_amount.value = value(risky_amount)*value(risky_prob);
                            safe_amount.value= value(risky_amount)/2; %%Christine is trying this out to see if it changes how quickly animals converge on CE
                        end
                        
                    else
                        risky_prob.value = value(risky_prob_options(find(p==max(p))));
                        risky_amount.value = rewards(find(r==max(r)));
                        %  safe_amount.value = value(risky_amount)*value(risky_prob);
                        safe_amount.value= value(risky_amount)/2; %%Christine is trying this out to see if it changes how quickly animals converge on CE
                        
                    end
                else
                    
                    risky_prob.value = value(risky_prob_options(find(p==max(p))));
                    risky_amount.value = rewards(find(r==max(r)));
                    %  safe_amount.value = value(risky_amount)*value(risky_prob);
                    safe_amount.value= value(risky_amount)/2; %%Christine is trying this out to see if it changes how quickly animals converge on CE
                    
                end
            end
            if value(use_PEST)==1
                safe_amount.value = value(risky_amount)/2;
                epsilon.value = value(safe_amount)/3;
            else
                epsilon.value = 1;
            end
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
        
        
        if use_training==1
            if ~was_viol && was_hit
                trials_in_stage.value=trials_in_stage+1;
            end
            
            switch value(training_stage) %#ok<*NODEF>
                case 0,
                    settling_time.value=0.001;
                    % delay_time.value=0.001;
                    allow_nic_breaks.value=1;
                    ignore_errors.value=1;
                    side_lights.value=3;
                    training_stage.value=1;
                    %training_stage.value=3;
                    trials_in_stage.value=0;
                    % bin_size.value=0.050;
                    wait_for_cpoke_timeout.value=600;
                    wait_for_spoke_timeout.value=600;
                    reward_delay.value=0.01;
                    error_iti.value=1.5;
                    safe_prob.value=1.0;
                    % risky_prob.value=1.0;
                    nic_time.value=0.001;
                    
                    
                case 1,  % Light chase and grow nose in center time
                    
                    if ~was_viol  % if last trial was violation don't increment.
                        
                        
                        
                        nic_time.value=value(nic_time)+value(growNIC_incr);
                        
                        
                        allow_nic_breaks.value=0; %#ok<*STRNU>
                        
                        
                        if value(nic_time)>=value(Max_NIC) % increased this time to make the transition easier
                            training_stage.value=2;
                            trials_in_stage.value=0;
                            trials_in_this_con.value = 0;
                            rewards = value(reward_options);
                            p = rand(1,length(value(risky_prob_options)));
                            r = rand(1,length(rewards));
                            
                            risky_prob.value = value(risky_prob_options(find(p==max(p))));
                            risky_amount.value = rewards(find(r==max(r)));
                            %  safe_amount.value = value(risky_amount)*value(risky_prob);
                            safe_amount.value= value(risky_amount)/2;
                            if value(use_PEST)==1
                                epsilon.value = value(safe_amount)/3;
                            else
                                epsilon.value = 1;
                            end
                            
                        end
                    end
                case 2, % start foraging
                    
                    if value(test_gambles_now)==1;
                        %  elseif value(test_gambles_now)==1;
                        if value(trials_in_this_con)>= value(numtrials_two_gambles)
                            test_gambles_now.value = 0;
                            trials_in_this_con.value = value(max_trials_in_con)+1;
                            safe_prob.value = 1;
                        end
                        % end
                        
                    elseif value(test_gambles_now)~=1 && value(testing_CEs_now)==1;
                        if value(trials_in_this_con)>=value(CEtest_ntrials);
                            testing_CEs_now.value = 0;
                            trials_in_this_con.value = value(max_trials_in_con)+1;
                            CE_test.value = 0;
                        end
                        
                        %let's compute the percentage of choosing the risky
                        %choice for this particular condition.  This is the
                        %staircase algorithm described by Kevin.  11/19/15
                    else
                        if value(use_PEST)==0
                            if value(trials_in_stage)>value(window_for_avg) && value(trials_in_stage) < value(max_trials_in_con);
                                if strcmp(value(safe_side), 'l'); %length(safe_side)==4; %case left=safe
                                    
                                    
                                    %   risky_pref.value = nanmean(value(went_right(end-value(trials_in_this_con)+1:end)));
                                    risky_pref.value = nanmean(value(went_right(end-value(window_for_avg)+1:end)));
                                    
                                    if value(went_left(end))==1; %made safe choice
                                        if value(safe_amount) - value(epsilon) > value(min_safe_amount);
                                            safe_amount.value = value(safe_amount) - value(epsilon);
                                        else
                                            safe_amount.value = value(min_safe_amount);
                                        end
                                    elseif value(went_right(end))==1; %made risky choice
                                        safe_amount.value = value(safe_amount) + value(epsilon);
                                    end
                                    
                                elseif strcmp(value(safe_side), 'r'); %length(safe_side)==5; %case right=safe
                                    
                                    %  risky_pref.value = nanmean(value(went_left(end-value(trials_in_this_con)+1:end)));
                                    risky_pref.value = nanmean(value(went_left(end-value(window_for_avg)+1:end)));
                                    
                                    
                                    if value(went_right(end))==1; %made safe choice
                                        if value(safe_amount) - value(epsilon) > value(min_safe_amount);
                                            safe_amount.value = value(safe_amount) - value(epsilon);
                                        else
                                            safe_amount.value = value(min_safe_amount);
                                        end
                                    elseif value(went_left(end))==1; %made risky choice
                                        safe_amount.value = value(safe_amount) + value(epsilon);
                                    end
                                    
                                end
                            end
                        elseif value(use_PEST)==1 && value(trials_in_this_con) >=value(min_trials_for_PEST) && value(epsilon) > value(exit_rule);
                            %peform halving/doubling rule
                            if ~isnan(value(went_left(end))+value(went_left(end-1))+value(went_left(end-2)));
                                if value(went_left(end)) == value(went_left(end-1)) && value(went_left(end-2))==value(went_left(end-3)); %went to same side three times
                                    epsilon.value = value(epsilon)*2;
                                elseif value(went_left(end)) ~= value(went_left(end-1)); %switched sides
                                    epsilon.value = value(epsilon)/2;
                                end
                            end
                            if strcmp(value(safe_side), 'l'); %length(safe_side)==4; %case left=safe
                                if value(went_left(end))==1; %made safe choice
                                    
                                    if value(safe_amount) - value(epsilon) >= value(exit_rule);
                                        safe_amount.value = value(safe_amount) - value(epsilon);
                                    else
                                        safe_amount.value = value(exit_rule);
                                    end
                                elseif value(went_right(end))==1; %made risky choice
                                    safe_amount.value = value(safe_amount) + value(epsilon);
                                end
                                
                            elseif strcmp(value(safe_side), 'r'); %length(safe_side)==5; %case right=safe
                                
                                if value(went_right(end))==1; %made safe choice
                                    if value(safe_amount) - value(epsilon) >= value(exit_rule);
                                        safe_amount.value = value(safe_amount) - value(epsilon);
                                    else
                                        safe_amount.value = value(exit_rule);
                                    end
                                elseif value(went_left(end))==1; %made risky choice
                                    safe_amount.value = value(safe_amount) + value(epsilon);
                                end
                                
                            end
                        end
                        
                        
                        if value(use_PEST)==0 && value(trials_in_stage) >= value(max_trials_in_con) || value(use_PEST)==1 && value(epsilon)<=value(exit_rule);
                            
                            rewards = value(reward_options);
                            p = rand(1,length(value(risky_prob_options)));
                            r = rand(1,length(rewards));
                            tvar = rand;
                            if tvar<.3 && value(test_two_gambles)==1;
                                risky_prob.value = value(risky_prob_options(find(p==max(p))));
                                risky_amount.value = rewards(find(r==max(r)));
                                safe_amount.value = value(risky_amount);
                                p2 = rand(1,length(value(risky_prob_options)));
                                safe_prob.value = value(risky_prob_options(find(p2==max(p2))));
                                test_gambles_now.value = 1;
                                trials_in_this_con.value = 0;
                                if strcmp(value(safe_side), 'l'); %length(safe_side)==4; %case left
                                    left_prob.value=value(safe_prob);
                                    right_prob.value=value(risky_prob);
                                elseif strcmp(value(safe_side), 'r'); %length(safe_side)==5; %case right
                                    right_prob.value=value(safe_prob);
                                    left_prob.value = value(risky_prob);
                                end
                            elseif tvar > .7 && value(test_CEs)==1;
                                [x] = StimulusSection(obj, 'init');
                                np = (.1:.1:.9);
                                dice = rand(1,length(np));
                                risky_prob.value = np(dice==max(dice));
                                pind = find(value(risky_prob_options)==value(risky_prob));
                                
                                if length(value(test_this_vol))>1
                                    dice = rand(1, length(value(test_this_vol)));
                                    risky_amount.value = value(test_this_vol(dice==max(dice)));
                                else
                                    risky_amount.value = value(test_this_vol);
                                end
                                rind = find(value(reward_options)==value(risky_amount));
                                
                                if ~isnan(x(rind, pind))
                                    safe_amount.value = x(rind, pind);
                                    CE_test.value = value(safe_amount);
                                else
                                    safe_amount.value = rind*pind;
                                    CE_test.value = value(safe_amount);
                                end

                                safe_prob.value = 1;
                                
                                testing_CEs_now.value = 1;
                                trials_in_this_con.value = 0;
                                if strcmp(value(safe_side), 'l'); %length(safe_side)==4; %case left
                                    left_prob.value=value(safe_prob);
                                    right_prob.value=value(risky_prob);
                                elseif strcmp(value(safe_side), 'r'); %length(safe_side)==5; %case right
                                    right_prob.value=value(safe_prob);
                                    left_prob.value = value(risky_prob);
                                end
                            else 
                                if value(choose_wisely)==1; %if we want to choose reward amount/prob combinations that the animal has not seen before.
                                    [expmtr, ratname]=SavingSection(obj, 'get_info');
                                    if ~strcmp(ratname, 'ratname');
                                        [x] = StimulusSection(obj, 'init');
                                        %  [w, ce] = ce_overdays(S);
                                        
                                        [nr,nc] = find(isnan(x));
                                        
                                        if ~isempty(nc)
                                            dice = rand(1,length(nr));
                                            risky_prob.value = value(risky_prob_options(nc(find(dice==max(dice)))));
                                            risky_amount.value = rewards(nr(find(dice==max(dice))));
                                            %    safe_amount.value = value(risky_amount)*value(risky_prob);
                                            safe_amount.value = value(risky_amount)/2; %%Christine is trying this out to see if it changes how quickly animals converge on CE
                                        else
                                            risky_prob.value = value(risky_prob_options(find(p==max(p))));
                                            risky_amount.value = rewards(find(r==max(r)));
                                            % safe_amount.value = value(risky_amount)*value(risky_prob);
                                            safe_amount.value= value(risky_amount)/2; %%Christine is trying this out to see if it changes how quickly animals converge on CE
                                        end
                                        
                                    else
                                        risky_prob.value = value(risky_prob_options(find(p==max(p))));
                                        risky_amount.value = rewards(find(r==max(r)));
                                        % safe_amount.value = value(risky_amount)*value(risky_prob);
                                        safe_amount.value= value(risky_amount)/2; %%Christine is trying this out to see if it changes how quickly animals converge on CE
                                        
                                    end
                                else
                                    risky_prob.value = value(risky_prob_options(find(p==max(p))));
                                    risky_amount.value = rewards(find(r==max(r)));
                                    % safe_amount.value = value(risky_amount)*value(risky_prob);
                                    safe_amount.value= value(risky_amount)/2;
                                end
                                if value(use_PEST)==1
                                    safe_amount.value = value(risky_amount)/2;
                                    epsilon.value = value(safe_amount)/3;
                                else
                                    epsilon.value = 1;
                                end
                                trials_in_stage.value = 0;
                                trials_in_this_con.value = 0;
                                risky_pref_history.value = NaN;
                                
                                if value(randomize_sides) ==1
                                    if rand<0.5
                                        safe_side.value = 'l';
                                        %  risky_side.value = 'r';
                                    else
                                        safe_side.value = 'r';
                                        %  risky_side.value = 'l';
                                    end
                                end
                                % end
                                
                                
                                %end
                                
                                
                                if strcmp(value(safe_side), 'l'); %length(safe_side)==4; %case left
                                    left_prob.value=1;
                                    right_prob.value=value(risky_prob);
                                elseif strcmp(value(safe_side), 'r'); %length(safe_side)==5; %case right
                                    right_prob.value=1;
                                    left_prob.value = value(risky_prob);
                                end
                            end
                        end
                        
                    end
            end
        end
        
        
    case 'get_water_mult',
        x=left_wtr_mult+0;
        y=right_wtr_mult+0;
        
    case 'get_hit_tally'
        if strcmp(value(safe_side), 'l');
            wl = value(went_left);
            if wl(end)==1
                x = 'l';
                y = 1;
            else
                rh = get_history(risk_hit);
                if rh{end-1}==1;
                    x = 'r';
                    y = 1;
                else
                    x = 'r';
                    y = 0;
                end
            end
        elseif strcmp(value(safe_side), 'r');
            wr = value(went_right);
            if (wr(end)==1)
                x = 'r';
                y = 1;
            else
                rh = get_history(risk_hit);
                if rh{end-1}==1;
                    x = 'l';
                    y = 1;
                else
                    x = 'l';
                    y = 0;
                end
            end
        end
        
        
    case 'end_sess'
        %if we're going to deprive ad lib water, do it here.
        if value(deprive_h2o)==1;
            AdLibGUISection(obj, 'WaptorOnOff', 1);
            since_h2o_deprive_ctr.value = value(since_h2o_deprive_ctr)+1;
            if value(since_h2o_deprive_ctr)>=value(h2o_day_thresh);
                since_h2o_deprive_ctr.value = 0;
                %  AdLibGUISection(obj, 'manual_override', 1);
                AdLibGUISection(obj, 'water_needs_figure', 0);
            else
                % AdLibGUISection(obj, 'manual_override', 0);
                AdLibGUISection(obj, 'water_needs_figure', 1);
            end
        end
        
        
    case 'make_and_send_summary',
        
        % reset anti-bias
        left_wtr_mult.value=1;
        right_wtr_mult.value=1;
        
        
        
        % Replaced make_and_send_summary code with the code from flickr.
        % This adds several elements to the protocol_data structure: flashtimes, flashdurs, stimword
        
        peh=cell2mat(parsed_events_history);
        ps=value(previous_sides(:));
        pd.sides = ps;
        cout=extract_event(peh,'wait_for_cout(1,2)');
        cin=extract_event(peh,'wait_for_cpoke(end,2)');
        viol=extract_event(peh,'violation_state(1,1)');
        
        
        
        pd.nic=cell2mat(get_history(nic_time));
        pd.PEST=cell2mat(get_history(use_PEST));
        pd.safe_prob=cell2mat(get_history(safe_prob));
        pd.risky_prob=cell2mat(get_history(risky_prob));
        pd.risky_prob_options = cell2mat(get_history(risky_prob_options));
        pd.reward_options = cell2mat(get_history(reward_options));
        pd.safe_hit = cell2mat(get_history(safe_hit));
        pd.risk_hit = cell2mat(get_history(risk_hit));
        pd.training_stage=cell2mat(get_history(training_stage));
        pd.risky_pref_history = cell2mat(get_history(risky_pref));
        pd.risky_amount = cell2mat(get_history(risky_amount));
        pd.safe_amount = cell2mat(get_history(safe_amount));
        pd.test_gambles_now = cell2mat(get_history(test_gambles_now));
        pd.epsilon = cell2mat(get_history(epsilon));
        pd.exit_rule = cell2mat(get_history(exit_rule));
        pd.trials_in_this_con = cell2mat(get_history(trials_in_this_con));
        pd.testing_CEs_now = cell2mat(get_history(testing_CEs_now));
        pd.CE_test = cell2mat(get_history(CE_test));
        
        
        if value(training_stage) ==2
            if value(randomize_sides)==0
                if  strcmp(value(safe_side), 'l'); %length(safe_side)==4;
                    pd.safe_side = 'l';
                    %  pd.risky_side = 'r';
                else
                    pd.safe_side = 'r';
                    %  pd.risky_side = 'l';
                end
            else
                pd.safe_side = cell2mat(get_history(safe_side));
                %     pd.risky_side = cell2mat(get_history(risky_side));
            end
        else
            pd.safe_side = nan;
            %  pd.risky_side = nan;
        end
        
        pd.went_right = value(went_right);
        pd.went_left = value(went_left);
        hits = ones(length(value(went_left)), 1);
        sides = nan(length(value(went_right)),1);
        sides(find(value(went_right)==1))='r';
        sides(find(value(went_left)==1))='l';
        pd.sides = sides;
        pd.hits = hits;
        
        
        sendsummary(obj,'hits',hits,'sides',sides,'protocol_data',pd);
        
end



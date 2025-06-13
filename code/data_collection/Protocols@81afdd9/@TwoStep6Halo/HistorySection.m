
function [x, y] = HistorySection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
    %% init
    case 'init',
        
        SoloParamHandle(obj,'reward_history','value',[]);
        SoloParamHandle(obj,'better_choices_history','value',[]);
        SoloParamHandle(obj,'sides_history_1','value',[]);
        SoloParamHandle(obj,'sides_history_2','value',[]);
        SoloParamHandle(obj,'pcong_history','value',[]);
        SoloParamHandle(obj,'trial_type_history','value',[]);
        SoloParamHandle(obj,'cpoke_viol1_history','value',[]);
        SoloParamHandle(obj,'cpoke_viol2_history','value',[]);
        SoloParamHandle(obj,'viol1_history','value',[]);
        SoloParamHandle(obj,'viol_history','value',[]);
        SoloParamHandle(obj,'left_reward_prob_history','value',[]);
        SoloParamHandle(obj,'right_reward_prob_history','value',[]);
        SoloParamHandle(obj,'stim_history','value',[]);
        
        lf = 0.65;
        
        
        DispParam(obj,'right_choices_2',0,x,y,'labelfraction',lf);
        next_row(y);
        DispParam(obj,'left_choices_2',0,x,y,'labelfraction',lf);
        next_row(y);
        DispParam(obj,'right_choices_1',0,x,y,'labelfraction',lf);
        next_row(y);
        DispParam(obj,'left_choices_1',0,x,y,'labelfraction',lf);
        next_row(y);
        
        DispParam(obj,'cpoke_violation_frac_2',0,x,y,'labelfraction',lf);
        next_row(y);
        DispParam(obj,'cpoke_violation_frac_1',0,x,y,'labelfraction',lf);
        next_row(y);
        DispParam(obj,'cpoke_violations',0,x,y,'labelfraction',lf);
        next_row(y);
        DispParam(obj,'violation_frac',0,x,y,'labelfraction',lf);
        next_row(y);
        DispParam(obj,'violation_trials',0,x,y,'labelfraction',lf);
        next_row(y);
        DispParam(obj,'violation_frac1',0,x,y,'labelfraction',lf);
        next_row(y);
        DispParam(obj,'violation_trials1',0,x,y,'labelfraction',lf);
        next_row(y);
        DispParam(obj,'better_choices_last50',0,x,y,'labelfraction',lf);
        next_row(y);
        DispParam(obj,'better_choices_frac',0,x,y,'labelfraction',lf);
        next_row(y);
        DispParam(obj,'better_choices',0,x,y,'labelfraction',lf);
        next_row(y);
        DispParam(obj,'reward_frac_last50',0,x,y,'labelfraction',lf);
        next_row(y);
        DispParam(obj,'reward_frac',0,x,y,'labelfraction',lf);
        next_row(y);
        DispParam(obj,'rewarded_trials',0,x,y,'labelfraction',lf);
        next_row(y);
        DispParam(obj,'nTrials',0,x,y,'labelfraction',lf);
        next_row(y);
        
        
        SubheaderParam(obj, 'title', 'History Section', x, y);
        next_row(y, 1.5);
        
        % Big plot at the top to display data
        pos = get(gcf, 'Position');
        SoloParamHandle(obj, 'axes1', 'saveable', 0, 'value', axes);
        set(value(axes1), 'Units', 'pixels');
        set(value(axes1), 'Position', [100 pos(4)-100 pos(3)-150 80]);
        set(value(axes1), 'YLim', [0 1]);
        ylabel('Trial Type');
        
        % Little plot to show history of reward probabilities
        SoloParamHandle(obj, 'axes2', 'saveable', 0, 'value', axes);
        set(value(axes2), 'Units', 'pixels');
        set(value(axes2), 'Position', [100 pos(4)-210 pos(3)-150 80]);
        set(value(axes2), 'YLim', [0 1]);
        ylabel('Reward Probability');
        
        % Little plot to show history of transition probabilities
        SoloParamHandle(obj, 'axes3', 'saveable', 0, 'value', axes);
        set(value(axes3), 'Units', 'pixels');
        set(value(axes3), 'Position', [100 pos(4)-320 pos(3)-150 80]);
        set(value(axes3), 'YLim', [0 1]);
        xlabel('Trial Number');
        ylabel('P Congruent');
        
        SoloParamHandle(obj, 'previous_axes', 'saveable', 0);
        
        drawnow;
        HistorySection(obj,'update_plot');
        
        
        SoloParamHandle(obj, 'after_load_callbacks', 'value', []);
        set_callback(after_load_callbacks, {mfilename, 'update_plot'});
        set_callback_on_load(after_load_callbacks, 1);
        
        %% Next trial
    case 'next_trial'
        
        nTrials.value = value(nTrials) + 1;
        
        if value(nTrials) > 0 % If the trial that we're preparing is NOT the first trial, record all the history stuff
            
            right_reward_visited = isfield(parsed_events.states, 'right_reward_state') && rows(parsed_events.states.right_reward_state) > 0;
            left_reward_visited = isfield(parsed_events.states, 'left_reward_state') && rows(parsed_events.states.left_reward_state) > 0;
            right_unreward_visited = isfield(parsed_events.states, 'right_unreward_state') && rows(parsed_events.states.right_unreward_state) > 0;
            left_unreward_visited = isfield(parsed_events.states, 'left_unreward_state') && rows(parsed_events.states.left_unreward_state) > 0;
            %     right_small_reward_visited = isfield(parsed_events.states, 'right_small_reward_state') && rows(parsed_events.states.right_unreward_state) > 0;
            %     left_small_reward_visited = isfield(parsed_events.states, 'left_small_reward_state') && rows(parsed_events.states.left_unreward_state) > 0;
            
            
            free_choice = isfield(parsed_events.states, 'free_choice') && rows(parsed_events.states.free_choice) > 0;
            force_left = isfield(parsed_events.states, 'force_left') && rows(parsed_events.states.force_left) > 0;
            force_right = isfield(parsed_events.states, 'force_right') && rows(parsed_events.states.force_right) > 0;
            
            left_choice_1 = isfield(parsed_events.states, 'left_choice_1') && rows(parsed_events.states.left_choice_1) > 0;
            right_choice_1 = isfield(parsed_events.states, 'right_choice_1') && rows(parsed_events.states.right_choice_1) > 0;
            left_choice_2 = isfield(parsed_events.states, 'nose_in_center_2l') && rows(parsed_events.states.nose_in_center_2l) > 0;
            right_choice_2 = isfield(parsed_events.states, 'nose_in_center_2r') && rows(parsed_events.states.nose_in_center_2r) > 0;
            
            % Update sides counters, sides history
            if right_choice_2
                right_choices_2.value = value(right_choices_2) + 1;
                sideChosen_2 = 'r';
            elseif left_choice_2
                left_choices_2.value = value(left_choices_2) + 1;
                sideChosen_2 = 'l';
            else
                sideChosen_2 = 'v';
            end
            
            if left_choice_1
                left_choices_1.value = value(left_choices_1) + 1;
                sideChosen_1 = 'l';
            elseif right_choice_1
                right_choices_1.value = value(right_choices_1) + 1;
                sideChosen_1 = 'r';
            else
                sideChosen_1 = 'v'; % violation on choice 1
                sideChosen_2 = 'x'; % Means that there never was a choice 2
            end
            
            % Update trial-type
            if free_choice
                trial_type = 'f';
            elseif force_left
                trial_type = 'l';
            elseif force_right
                trial_type = 'r';
            else
                warning('Invalid trial_type'); % This should never happen
                trial_type = 'X';
            end
            
            
            better_choice = ParamsSection(obj,'get_better_choice');
            if free_choice % only count better_choices that were free choices
                if sideChosen_1 == better_choice
                    choseBetter = 1;
                    better_choices.value = value(better_choices) + 1;
                else
                    choseBetter = 0;
                end
            else
                choseBetter = NaN;
            end
            
            % update reward counters, reward history
            if right_reward_visited || left_reward_visited
                rewarded_trials.value = value(rewarded_trials) + 1;
                reward = 1;
            else
                reward = 0;
            end
            
            % Update centerpoke violation counters
            cpoke_violation1 = (isfield(parsed_events.states, 'cpoke_violation_1') && rows(parsed_events.states.cpoke_violation_1) > 0);
            cpoke_violation2 = isfield(parsed_events.states, 'cpoke_violation_2r') && rows(parsed_events.states.cpoke_violation_2r) > 0 ...
                || (isfield(parsed_events.states, 'cpoke_violation_2l') && rows(parsed_events.states.cpoke_violation_2l) > 0);
            
            % Cpoke violations get counted regardless of whether they were
            % on first or second choice.  cpoke_viol gets coded with
            cpoke_viol_1 = 0;
            cpoke_viol_2 = 0;
            if cpoke_violation1 || cpoke_violation2
                cpoke_violations.value = cpoke_violations + 1;
                if cpoke_violation1
                    cpoke_viol_1 = 1;
                end
                if cpoke_violation2
                    cpoke_viol_2 = 1;
                end
            end
            
            % Update violation counters
            if isfield(parsed_events.states, 'violation_penalty2') && rows(parsed_events.states.violation_penalty2) > 0
                violation_trials.value = violation_trials + 1;
                viol2 = 1;
            else
                viol2 = 0;
            end
            % Update violation counters
            if isfield(parsed_events.states, 'violation_penalty1') && rows(parsed_events.states.violation_penalty1) > 0
                violation_trials1.value = violation_trials1 + 1;
                viol1 = 1;
            else
                viol1 = 0;
            end
            
            % Update laser indicator
            stim_type = 'n'; % This is a first trial. There is no laser.
            
            % Update all the history vectors
            params = ParamsSection(obj,'get_params');
            left_reward_prob_history.value = [left_reward_prob_history(:);params.left_reward_prob];
            right_reward_prob_history.value = [right_reward_prob_history(:);params.right_reward_prob];
            pcong_history.value = [pcong_history(:);params.p_congruent];
            sides_history_1.value = [sides_history_1(:);sideChosen_1];
            sides_history_2.value = [sides_history_2(:);sideChosen_2];
            reward_history.value = [reward_history(:);reward];
            better_choices_history.value = [better_choices_history(:); choseBetter];
            cpoke_viol1_history.value = [cpoke_viol1_history(:);cpoke_viol_1];
            cpoke_viol2_history.value = [cpoke_viol2_history(:);cpoke_viol_2];
            viol1_history.value = [viol1_history(:);viol1];
            viol_history.value = [viol_history(:);viol2];
            trial_type_history.value = [trial_type_history(:);trial_type];
            stim_history.value = [stim_history(:);stim_type];
            
            % Update fracs and partial fracs
            reward_frac.value = mean(reward_history(:));
            better_choices_frac.value = nanmean(better_choices_history(:));
            if length(reward_history(:)) >= 50
                reward_frac_last50.value = mean(reward_history(end-49:end));
                better_choices_last50.value = nanmean(better_choices_history(end-49:end));
            end
            violation_frac.value = mean(viol_history(:));
            violation_frac1.value = mean(viol1_history(:));
            cpoke_violation_frac_1.value = mean(cpoke_viol1_history(:));
            cpoke_violation_frac_2.value = mean(cpoke_viol2_history(:));
            
        end
        
        training_stage = TrainingSection(obj,'get_training_stage');
        
        if strcmp(training_stage,'stimulation') % This is a double-trial, and needs special handling
            HistorySection(obj,'next_trial_double')
        end
        
        HistorySection(obj,'update_plot');
        
        %% Double trial update
    case 'next_trial_double'
        % If we're running double trials, do a second update of the history
        % vectors
        nTrials.value = value(nTrials) + 1;
        
        right_reward_visited = isfield(parsed_events.states, 'right_reward_state_2nd') && rows(parsed_events.states.right_reward_state_2nd) > 0;
        left_reward_visited = isfield(parsed_events.states, 'left_reward_state_2nd') && rows(parsed_events.states.left_reward_state_2nd) > 0;
        right_unreward_visited = isfield(parsed_events.states, 'right_unreward_state_2nd') && rows(parsed_events.states.right_unreward_state_2nd) > 0;
        left_unreward_visited = isfield(parsed_events.states, 'left_unreward_state_2nd') && rows(parsed_events.states.left_unreward_state_2nd) > 0;
        %     right_small_reward_visited = isfield(parsed_events.states, 'right_small_reward_state') && rows(parsed_events.states.right_unreward_state) > 0;
        %     left_small_reward_visited = isfield(parsed_events.states, 'left_small_reward_state') && rows(parsed_events.states.left_unreward_state) > 0;
        
        
        free_choice = isfield(parsed_events.states, 'free_choice_2nd') && rows(parsed_events.states.free_choice_2nd) > 0;
        force_left = isfield(parsed_events.states, 'force_left_2nd') && rows(parsed_events.states.force_left_2nd) > 0;
        force_right = isfield(parsed_events.states, 'force_right_2nd') && rows(parsed_events.states.force_right_2nd) > 0;
        
        left_choice_1 = isfield(parsed_events.states, 'left_choice_1_2nd') && rows(parsed_events.states.left_choice_1_2nd) > 0;
        right_choice_1 = isfield(parsed_events.states, 'right_choice_1_2nd') && rows(parsed_events.states.right_choice_1_2nd) > 0;
        left_choice_2 = isfield(parsed_events.states, 'nose_in_center_2l_2nd') && rows(parsed_events.states.nose_in_center_2l_2nd) > 0;
        right_choice_2 = isfield(parsed_events.states, 'nose_in_center_2r_2nd') && rows(parsed_events.states.nose_in_center_2r_2nd) > 0;
        
        % Update sides counters, sides history
        if right_choice_2
            right_choices_2.value = value(right_choices_2) + 1;
            sideChosen_2 = 'r';
        elseif left_choice_2
            left_choices_2.value = value(left_choices_2) + 1;
            sideChosen_2 = 'l';
        else
            sideChosen_2 = 'v';
        end
        
        if left_choice_1
            left_choices_1.value = value(left_choices_1) + 1;
            sideChosen_1 = 'l';
        elseif right_choice_1
            right_choices_1.value = value(right_choices_1) + 1;
            sideChosen_1 = 'r';
        else
            sideChosen_1 = 'v'; % violation on choice 1
            sideChosen_2 = 'x'; % Means that there never was a choice 2
        end
        
        % Update trial-type
        if free_choice
            trial_type = 'f';
        elseif force_left
            trial_type = 'l';
        elseif force_right
            trial_type = 'r';
        else
            warning('Invalid trial_type'); % This should never happen
            trial_type = 'X';
        end
        
        
        better_choice = ParamsSection(obj,'get_better_choice');
        if free_choice % only count better_choices that were free choices
            if sideChosen_1 == better_choice
                choseBetter = 1;
                better_choices.value = value(better_choices) + 1;
            else
                choseBetter = 0;
            end
        else
            choseBetter = NaN;
        end
        
        % update reward counters, reward history
        if right_reward_visited || left_reward_visited
            rewarded_trials.value = value(rewarded_trials) + 1;
            reward = 1;
        else
            reward = 0;
        end
        
        % Update centerpoke violation counters
        cpoke_violation1 = (isfield(parsed_events.states, 'cpoke_violation_1_2nd') && rows(parsed_events.states.cpoke_violation_1_2nd) > 0);
        cpoke_violation2 = isfield(parsed_events.states, 'cpoke_violation_2r_2nd') && rows(parsed_events.states.cpoke_violation_2r_2nd) > 0 ...
            || (isfield(parsed_events.states, 'cpoke_violation_2l_2nd') && rows(parsed_events.states.cpoke_violation_2l_2nd) > 0);
        
        % Cpoke violations get counted regardless of whether they were
        % on first or second choice.  cpoke_viol gets coded with
        cpoke_viol_1 = 0;
        cpoke_viol_2 = 0;
        if cpoke_violation1 || cpoke_violation2
            cpoke_violations.value = cpoke_violations + 1;
            if cpoke_violation1
                cpoke_viol_1 = 1;
            end
            if cpoke_violation2
                cpoke_viol_2 = 1;
            end
        end
        
        % Update violation counters
        if isfield(parsed_events.states, 'violation_penalty2_2nd') && rows(parsed_events.states.violation_penalty2_2nd) > 0
            violation_trials.value = violation_trials + 1;
            viol2 = 1;
        else
            viol2 = 0;
        end
        % Update violation counters
        if isfield(parsed_events.states, 'violation_penalty1_2nd') && rows(parsed_events.states.violation_penalty1_2nd) > 0
            violation_trials1.value = violation_trials1 + 1;
            viol1 = 1;
        else
            viol1 = 0;
        end
        
        % Update laser indicator
        reward_stim = isfield(parsed_events.states, 'reward_stim_indicator') && rows(parsed_events.states.reward_stim_indicator) > 0;
        choice_stim = isfield(parsed_events.states, 'choice_stim_indicator') && rows(parsed_events.states.choice_stim_indicator) > 0;
        both_stim = isfield(parsed_events.states, 'both_stim_indicator') && rows(parsed_events.states.both_stim_indicator) > 0;
        no_stim = isfield(parsed_events.states, 'no_stim_indicator') && rows(parsed_events.states.no_stim_indicator) > 0;
        
        if reward_stim
            stim_type = 'r';
        elseif choice_stim
            stim_type = 'c';
        elseif both_stim
            stim_type = 'b';
        elseif no_stim
            stim_type = 'n';
        else
            error('error: problem parsing stim');
        end
                
        % Update all the history vectors
        params = ParamsSection(obj,'get_params');
        left_reward_prob_history.value = [left_reward_prob_history(:);params.left_reward_prob];
        right_reward_prob_history.value = [right_reward_prob_history(:);params.right_reward_prob];
        pcong_history.value = [pcong_history(:);params.p_congruent];
        sides_history_1.value = [sides_history_1(:);sideChosen_1];
        sides_history_2.value = [sides_history_2(:);sideChosen_2];
        reward_history.value = [reward_history(:);reward];
        better_choices_history.value = [better_choices_history(:); choseBetter];
        cpoke_viol1_history.value = [cpoke_viol1_history(:);cpoke_viol_1];
        cpoke_viol2_history.value = [cpoke_viol2_history(:);cpoke_viol_2];
        viol1_history.value = [viol1_history(:);viol1];
        viol_history.value = [viol_history(:);viol2];
        trial_type_history.value = [trial_type_history(:);trial_type];
        stim_history.value = [stim_history(:);stim_type];
        
        
        % Update fracs and partial fracs
        reward_frac.value = mean(reward_history(:));
        better_choices_frac.value = nanmean(better_choices_history(:));
        if length(reward_history(:)) >= 50
            reward_frac_last50.value = mean(reward_history(end-49:end));
            better_choices_last50.value = nanmean(better_choices_history(end-49:end));
        end
        violation_frac.value = mean(viol_history(:));
        violation_frac1.value = mean(viol1_history(:));
        cpoke_violation_frac_1.value = mean(cpoke_viol1_history(:));
        cpoke_violation_frac_2.value = mean(cpoke_viol2_history(:));
        
        
        
        %% Update plot
    case 'update_plot'
        try
            % Update big plot
            ax = value(axes1);
            delete(get(ax, 'Children'));
            
            
            
            % get trials by outcome and trial type
            rewards_free = find(reward_history==1 & trial_type_history == 'f');
            unrewards_free = find(reward_history==0 & viol_history==0 & viol1_history==0 & trial_type_history == 'f');
            rewards_forced = find(reward_history==1 & trial_type_history ~= 'f');
            unrewards_forced = find(reward_history==0 & viol_history==0 & viol1_history==0 & trial_type_history ~= 'f');
            violations = find(viol_history==1 | viol1_history==1);
            
            stims = find(stim_history~='n');

            
            % Get trials by 1st and 2nd choice
            leftlefts = find(sides_history_1 == 'l' & sides_history_2 == 'l');
            leftrights = find(sides_history_1 == 'l' & sides_history_2 == 'r');
            rightlefts = find(sides_history_1 == 'r' & sides_history_2 == 'l');
            rightrights = find(sides_history_1 == 'r' & sides_history_2 == 'r');
            leftviols = find(sides_history_1 == 'l' & viol1_history == 1);
            rightviols = find(sides_history_1 == 'r' & viol1_history == 1);
            
            % Assign y-values to each trial based on choices
            yvals = zeros(1,value(nTrials));
            yvals(leftlefts) = 4;
            yvals(leftviols) = 3.5;
            yvals(leftrights) = 3;
            yvals(rightlefts) = 2;
            yvals(rightviols) = 1.5;
            yvals(rightrights) = 1;
            ylabels = {'Right-Right','Right-Left','Left-Right','Left-Left'};
            
            % Start plotting
            hold(ax, 'on');
            % Put horizontal dashed lines
            for t = 1:4
                plot(ax, [0 value(nTrials) + 1], [t t], ':', 'Color',[0.5 0.5 0.5]);
            end
            
            % Put laser dots
            plot(ax, stims, yvals(stims),'*',...
                'MarkerEdgeColor', [0.2, 1, 0.2],...
                'linewidth', 1.5, ...
                'MarkerSize', 12);
            
            % put reward/unreward dots
            plot(ax, rewards_free, yvals(rewards_free),'.',...
                'MarkerEdgeColor', [0, 0.5, 1],...
                'MarkerSize',15);
            plot(ax, unrewards_free, yvals(unrewards_free),'.',...
                'MarkerEdgeColor',[1, 0.66, 0],...
                'MarkerSize',15);
            plot(ax, rewards_forced, yvals(rewards_forced),'o',...
                'MarkerEdgeColor', [0, 0.5, 1],...        
                'MarkerSize',5,'LineWidth',1.5);
            plot(ax, unrewards_forced, yvals(unrewards_forced),'o',...
                'MarkerEdgeColor',[1, 0.66, 0],...
                'MarkerSize',5,'LineWidth',1.5);
            plot(ax, violations, yvals(violations),'r.',...
                'MarkerSize',15);
            set(ax, 'Ylim', [0.5 4.5], 'XLim', [0 value(nTrials)+1],'YTick', 1:4, 'YTickLabel', ylabels);
            hold(ax, 'off');
            
            % update small plot
            ax2 = value(axes2);
            delete(get(ax2, 'Children'));
            hold(ax2,'on');
            plot(ax2,value(left_reward_prob_history),'r');
            plot(ax2,value(right_reward_prob_history),'b');
            set(ax2, 'Ylim', [0 1], 'XLim', [0 value(nTrials)+1]);
            
            hold(ax2,'off');
            
            % update small plot
            ax3 = value(axes3);
            delete(get(ax3, 'Children'));
            hold(ax3,'on');
            plot(ax3,value(pcong_history),'b');
            set(ax3, 'Ylim', [0 1], 'XLim', [0 value(nTrials)+1]);
            hold(ax3,'off');
            
            
        catch err
            warning(['Problem with plot:',err]);
        end
        
        %% Get info
    case 'get_all'
        x.nTrials = value(nTrials);
        x.reward_history = value(reward_history);
        x.better_choices_history = value(better_choices_history);
        x.sides_history_1 = value(sides_history_1);
        x.sides_history_2 = value(sides_history_2);
        x.cpoke_viol1_history = value(cpoke_viol1_history);
        x.cpoke_viol2_history = value(cpoke_viol2_history);
        x.viol_history = value(viol_history);
        x.left_reward_prob_history = value(left_reward_prob_history);
        x.right_reward_prob_history = value(right_reward_prob_history);
        x.stim_history = value(stim_history);
        x.pcong_history = value(pcong_history);
    otherwise
        warning('Invalid case in History Section');
end

end

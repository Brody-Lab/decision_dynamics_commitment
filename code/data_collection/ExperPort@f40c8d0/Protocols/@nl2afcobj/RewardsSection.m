function [x, y] = RewardsSection(obj, action, x, y);
%
% [x, y] = InitRewards_Display(x, y, obj);
%
% args:    x, y                 current UI pos, in pixels
%          obj                  A locsamp3obj object
%
% returns: x, y                 updated UI pos
%
% Updates (and stores) history of various measures of hit (or reward
% rates); e.g. Hit rate for Last 20 trials, # Right rewards, etc.,
% Also updates the on-screen hit-rate display
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

GetSoloFunctionArgs;
% SoloFunction('RewardsSection', 'rw_args', {'LastTrialEvents', 'hit_history'}, ...
%    'ro_args', {'RealTimeStates', 'side_list', 'n_done_trials', 'n_started_trials'});

switch action,
    case 'init',

        SoloParamHandle(obj, 'LeftRewards', 'value', zeros(1, maxtrials)); %next_row(y);
        SoloParamHandle(obj, 'RightRewards', 'value',zeros(1, maxtrials)); %next_row(y);
        SoloFunctionAddVars('BlockControl','ro_args',{'LeftRewards','RightRewards'});
        
        DispParam(obj, 'Rewards',     0, x, y); next_row(y);
        SoloParamHandle(obj,'RewardTracker', 'value', 0);
        DispParam(obj, 'Trials',      0, x, y); next_row(y);
        SoloParamHandle(obj,'TrialTracker', 'value', 0);
        next_row(y);
        MenuParam(obj, 'performance_plot',{'Score';'Hits';'Miss';'False'},1,x,y,'label','To plot');
        next_row(y);    
        set_callback(performance_plot, {'RewardsSection', 'plot_options'});
        
        % store the value of rat performance, with columns: Score, Hits, Miss, False
        SoloParamHandle(obj, 'perform_left', 'value', ones(maxtrials,4)*(-1)); 
        SoloParamHandle(obj, 'perform_right', 'value', ones(maxtrials,4)*(-1)); 
        SoloParamHandle(obj, 'perform_overall', 'value', ones(maxtrials,4)*(-1)); 
        
        LastTrialevents.value = [];

        SubheaderParam(obj, 'hitrt_sbh', 'Hit History', x, y); next_row(y);
        
   %-------- Initilize a plot monitoring rats perfomance-------------
        oldunits = get(gcf, 'Units'); set(gcf, 'Units', 'normalized');
        SoloParamHandle(obj, 'h1',  'value', axes('Position', [0.08, 0.52, 0.4, 0.25])); hold on; % axes
        % Plot performance against trial number (over sliding window)
        SoloParamHandle(obj, 'sliding_left',  'value', plot(-1, 1, 'b*')); hold on; %
        SoloParamHandle(obj, 'sliding_right',  'value', plot(-1, 1, 'mo')); hold on; %
        SoloParamHandle(obj, 'Legend','value',legend('Left','Right','Location',[0.09 0.74 0.12 0.06]));
        %SoloParamHandle(obj, 'perform_bars',  'value', bar(value(perform)); % bar plot of performance till now
        %set(gca,'XTickLabel',{'Score';'Hits';'Miss';'False'}, ...
        %    get(gca, 'YLabel'),'String', 'Percentage'); 
        SoloParamHandle(obj, 'h2',  'value', axes('Position', [0.56, 0.52, 0.4, 0.25])); % axes
        % Plot performance against trial number (over blocks)
        SoloParamHandle(obj, 'block_left',  'value', plot(-1, 1, 'b*')); hold on; %
        SoloParamHandle(obj, 'block_right',  'value', plot(-1, 1, 'mo')); hold on; %
       % SoloParamHandle(obj, 'Legend','value',legend('Left','Right','Location','NorthWest'));
       
        set(get(value(h1), 'XLabel'),'String','Trials');
        set(get(value(h1), 'YLabel'),'String','Percentage Score');
        title(value(h1), '        Sliding Window Plot','Color','b');
        
        set(get(value(h2), 'XLabel'),'String','Blocks');
        title(value(h2), 'Block Average Plot','Color','b');
        
        set_saveable({h1;sliding_left;sliding_right;h2;block_left;block_right}, 0);
        set(gcf, 'Units', oldunits);

    case 'update',
        TrialTracker.value = value(TrialTracker) + 1;
        sides_till_now = side_list(1:n_done_trials);
        Trials.value = sprintf('%i (L:%i, R:%i) ', value(TrialTracker), sum(sides_till_now), length(find(sides_till_now == 0)));
        evs = value(LastTrialEvents);
        rts = value(RealTimeStates);
        
        hh = value(hit_history);

        % Note: It's fine to not have left or right answer poke after direct
        % delivery in Classical2afc
        % Find first left-right response after odor delivery:
        u = find(evs(:,1)==rts.wait_for_apoke  & (evs(:,2)==3 | evs(:,2)==5));

        % If direct delivery, then it's always a hit
        if (length(find(evs(:,1)== rts.left_dirdel)) > 0)  | (length(find(evs(:,1) == rts.right_dirdel)) > 0)
            hh(n_done_trials) = 1;
            if side_list(n_done_trials)==1,
                rew = value(LeftRewards); rew(n_done_trials)=1; LeftRewards.value = rew;
            elseif side_list(n_done_trials)==0,
                rew = value(RightRewards); rew(n_done_trials)=1; RightRewards.value = rew;
            end;
            % If it's corr poke or "only if"  poke, then its a hit only if the side poke
            % matched the trial side
        elseif ~isempty(u)
            if (evs(u(1),2)==3  &  side_list(n_done_trials)==1) % left
                rew= value(LeftRewards); rew(n_done_trials)=1; LeftRewards.value= rew;
                hh(n_done_trials) = 1;
            elseif (evs(u(1),2)==5  &  side_list(n_done_trials)==0),
                rew=value(RightRewards); rew(n_done_trials)=1; RightRewards.value=rew;
                hh(n_done_trials) = 1;
            else % no poke and not direct delivery
                hh(n_done_trials) = 0;
            end;
        else
            hh(n_done_trials) = 0;
        end;

        if hh(n_done_trials) == 1, RewardTracker.value = value(RewardTracker)+1; end;
        
        
        % update performance plotting
            left_index = find(sides_till_now==1);
            right_index = find(sides_till_now == 0);
            BlockSize = value(trial_per_block);
            if length(left_index) >=BlockSize & sides_till_now(n_done_trials)
                perform_left(n_done_trials,2) = sum(LeftRewards(left_index(end-BlockSize+1:end))); % left hits over the last 20 trials
                perform_left(n_done_trials,1) = (perform_left(n_done_trials,2)/BlockSize)*100; % left score over the last 20 trials
                perform_left(n_done_trials,3) = BlockSize - perform_left(n_done_trials,2); % left missed trials
                perform_left(n_done_trials,4) = 0;  % not decided yet
            end
            if length(right_index) >= BlockSize & ~sides_till_now(n_done_trials)
                perform_right(n_done_trials,2) = sum(RightRewards(right_index(end-BlockSize+1:end))); % right hits over the last 20 trials
                perform_right(n_done_trials,1) = (perform_right(n_done_trials,2)/BlockSize)*100; % ritht score over the last 20 trials
                perform_right(n_done_trials,3) = BlockSize - perform_right(n_done_trials,2); % right missed trials
                perform_right(n_done_trials,4) = 0;  % not decided yet
            end
            %current_score.value = (perform_left(n_done_trials,1)+perform_right(n_done_trials,1))/2;
            if n_done_trials >= BlockSize
                a = sum(LeftRewards(n_done_trials-BlockSize+1:n_done_trials));
                b = sum(RightRewards(n_done_trials-BlockSize+1:n_done_trials));
                perform_overall(n_done_trials,2) = a+b;
                perform_overall(n_done_trials,1) = (a+b)/BlockSize*100;
            end

        % update Reward View
        rew_val = sprintf('%i (L:%i, R: %i) ', value(RewardTracker), sum(value(LeftRewards)), sum(value(RightRewards)));
        Rewards.value = rew_val;
        
        

        % reset the events store
        push_history(LastTrialEvents);

        LastTrialEvents.value = [];
        hit_history.value = hh;
        prevtrial.value = parse_trial(evs, rts);
        
        RewardsSection(obj,'plot_options');
        
    case 'plot_options'
        BlockSize = value(trial_per_block);
        %temp_end = n_done_trials - BlockSize + 1;
        
        switch value(performance_plot),
            case 'Score'
                sliding_left_ydata = perform_left(1:n_done_trials,1);
                sliding_right_ydata = perform_right(1:n_done_trials,1);
                block_left_ydata = perform_left(1:BlockSize:n_done_trials,1);
                block_right_ydata = perform_right(1:BlockSize:n_done_trials,1);
                y_label = 'Percentage Score';
            case 'Hits'
                sliding_left_ydata = perform_left(1:n_done_trials,2);
                sliding_right_ydata = perform_right(1:n_done_trials,2);
                block_left_ydata = perform_left(1:BlockSize:n_done_trials,2);
                block_right_ydata = perform_right(1:BlockSize:n_done_trials,2);
                y_label = '# Hits in Last Block';
            case 'Miss'
                sliding_left_ydata = perform_left(1:n_done_trials,3);
                sliding_right_ydata = perform_right(1:n_done_trials,3);
                block_left_ydata = perform_left(1:BlockSize:n_done_trials,3);
                block_right_ydata = perform_right(1:BlockSize:n_done_trials,3);
                y_label = '# Missed trials';
            case 'False'
                sliding_left_ydata = perform_left(1:n_done_trials,4);
                sliding_right_ydata = perform_right(1:n_done_trials,4);
                block_left_ydata = perform_left(1:BlockSize:n_done_trials,4);
                block_right_ydata = perform_right(1:BlockSize:n_done_trials,4);
                y_label = 'Percentage False';
                
        end
        sliding_left_x = (1:n_done_trials);
        z = find(sliding_left_ydata < 0);
        sliding_left_ydata(z) = [];
        sliding_left_x(z) = [];
        set(value(sliding_left),'XData', sliding_left_x, 'YData',sliding_left_ydata);
        
        sliding_right_x = (1:n_done_trials);
        z = find(sliding_right_ydata < 0);
        sliding_right_ydata(z) = [];
        sliding_right_x(z) = [];
        set(value(sliding_right),'XData', sliding_right_x, 'YData',sliding_right_ydata);
        
        block_left_x = (1: size(block_left_ydata,1));
        z = find(block_left_ydata < 0);
        block_left_x(z) = [];
        block_left_ydata(z) = [];
        set(value(block_left),'XData',block_left_x,'YData',block_left_ydata);
        
        block_right_x = (1: size(block_right_ydata,1));
        z = find(block_right_ydata < 0);
        block_right_x(z) = [];
        block_right_ydata(z) = [];
        set(value(block_right),'XData',block_right_x,'YData',block_right_ydata);
        
        set(get(value(h1),'YLabel'),'String',y_label);       
        
    otherwise,
        error(['Don''t know how to handle action ' action]);
end;
function [] = update_sides_and_rewards_plot(obj)

    GetSoloFunctionArgs;
    % SoloFunction('update_sides_and_rewards_plot', 'ro_args', ...
    %    {'side_list', 'n_done_trials', 'hit_history', 'WaterDelivery', 'RewardPorts'});
    
    % SoloParamHandles declared here are visible only here and will be
    % persistent: next time after their creation that the function is
    % called, GetSoloFunctionArgs will return these, too.
    %
    if ~exist('h', 'var'),
        oldunits = get(gcf, 'Units'); set(gcf, 'Units', 'normalized');
        SoloParamHandle(obj, 'h', 'value', axes('Position', [0.06, 0.85, 0.8, 0.12])); % axes

        SoloParamHandle(obj, 'p', 'value', plot(1, 1, 'b.')); hold on; % blue dots
        SoloParamHandle(obj, 'o', 'value', plot(1, 1, 'ro'));          % next trial indicator

        set(value(h), 'YTick', [0 1], 'YTickLabel', {'Right', 'Left'});
        xlabel('trial num');

        set(gcf, 'Units', oldunits);

        % "width", an EditParam to control the # of trials in the plot:
        SoloParamHandle(obj, 'width', 'type', 'edit', 'label', 'ntrials', ...
            'labelpos', 'bottom','TooltipString', 'number of trials in plot', ...
            'value', 90, 'position', [490 645 35 40]);
        set_callback(width, 'update_sides_and_rewards_plot');
    end;    

    mn = max(round(n_done_trials-2*width/3), 1);
    mx = min(floor(mn+width), length(side_list));
    
    set(value(p), 'XData', n_done_trials+1:mx, 'YData', side_list(n_done_trials+1:mx));
    set(value(h), 'Ylim', [-0.5 1.5], 'XLim', [mn-1 mx+1]);
    set(value(o), 'XData', n_done_trials+1, 'YData', side_list(n_done_trials+1));

    return;
    

function [hgraph] = analyze_bouts(rat, task, date, varargin)

% TASK: Any
%
% Description:
% Given the hit history of a session, plots the hit rate in sliding windows of
% 'bout_size' trials. Also plots a line at the y-value equalling "good
% accuracy" (where 'good' is set by the experimenter depending on the
% task). The hit rates in each window ('bins') is returned as the only
% output value.
%
% It is used to coarsely assess hit rate across a session.
%
% hit history is a double array of "1"s (correct trial) and "0"s (incorrect
% trial).

if ~isstr(rat)
    if nargin < 5   % src, event + 3 mandatory
        error('Either make the rat a string, or give me more args!');
    end;
    rat = date; task = varargin{1}; date = varargin{2};
    varargin = varargin(3:end);
end;

pairs = { ...
    'pitch_task', 0     ; ...
    'psychometric', 0   ; ...
    'binmin', 0         ; ...
    'binmax', 0         ; ...
    'action', 'init'    ; ...
    'y_min', 0.3        ; ...
    'win', 15        ; ...
    'last_win', 0       ; ...
    'binsamp', 0; ...
    };
parse_knownargs(varargin, pairs);


switch action
    case 'init'
        figure;
        subplot(2,2,[1 2]);

        % Plot performance rates in windows
        [h, l, last_win] = hit_rates(rat, task, date);
        set(l, 'ButtonDownFcn', {@analyze_bouts, rat, task, date, ...
            'action', 'show_details', 'binmin', binmin, 'binmax', binmax, ...
            'last_win', last_win});
        set(gca,'Position', [0.03 0.5 0.96 0.45]);
        hgraph = gca;
        if ~psychometric
            change_sets = tone_sets_alternate(rat, task, date, 'pitch_task',pitch_task);
            for k = 1:cols(change_sets)
                line([change_sets{k}(1) change_sets{k}(1)], [y_min 1], 'LineStyle', '--');
            end;
        else
            psych_on = get_psychometric_trials(rat, task, date, 'binsamp', binsamp);
            line([min(psych_on) min(psych_on)], [y_min 1], 'LineStyle',':', 'Color',[0 0.8 0], 'LineWidth',3);
            text(min(psych_on)+2, y_min+0.05, 'Psych. sampling', 'FontAngle','italic','FontSize',11);
        end;

        % Also show side bias information
        subplot(2,2,3);
        set(gca, 'Position', [0.03 0.05 0.35 0.35], 'Tag','sides');
        side_rewards(rat, task, date, 'windows', 50, 'show_trend',1);

        % Not to mention timeout distribution
        subplot(2,2,4);
        set(gca, 'Position', [0.45 0.05 0.45 0.35], 'Tag', 'tohist')
        timeout_histogram(rat, task, date);

        set(gcf,'Position',[50 175 690 620], 'MenuBar', 'none', 'Toolbar', 'none');

    case 'show_details'
        k = get(gca, 'CurrentPoint');
        k = floor(k(1,1));
        if k < win, k = win+1; elseif k > last_win, k = last_win-5; end;
        show_detailed_hits(rat, task, date, k-win, k+win, 'binmin', binmin, 'binmax', binmax);

    otherwise
        error('Invalid action!: %s', action);
end;

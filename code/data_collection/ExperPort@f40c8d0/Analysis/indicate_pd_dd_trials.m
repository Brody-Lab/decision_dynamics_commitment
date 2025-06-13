function [t_pd, t_dd] = indicate_pd_dd_trials(saved, saved_history, task, title, varargin)
% ------------------------------------------------------------------------------------------
% function [t_pd, t_dd] = indicate_pd_dd_trials(saved, saved_history, task, title, varargin)
%
%   Classifies tasks as being either pitch discrimination or duration discrimination and plots
%   task-type indicator points on the active figure at the following y-values:
%     * pd_y (y-value where PD trials are indicated)
%     * dd_y (y-value where DD trials are indicated)
% ------------------------------------------------------------------------------------------

pairs = { ...
    'pd_y', 1.02; ...
    'dd_y', 1.03; ...
    'plot_on', 1; ...
    };
parse_knownargs(varargin,pairs);

% Pitch discrimination trials are those that have 1KHz on the LHS and 15
% KHz set for RHS
pitch_L = cell2mat(saved_history.ChordSection_Tone_Freq_L);
pitch_R = cell2mat(saved_history.ChordSection_Tone_Freq_R);
t_pd = intersect(find(pitch_L==1), find(pitch_R == 15));

% Duration discrimination trials are those that have:
% equal pitch on LHS and RHS
dd_L = cell2mat(saved_history.ChordSection_Tone_Dur_L);
dd_R = cell2mat(saved_history.ChordSection_Tone_Dur_R);
dd_durations = find(pitch_L == pitch_R);
%dd_10 = find(pitch_L == pitch_R);
t_dd = dd_durations; %intersect(dd_durations, dd_10);

if length(t_dd) > 0 && length(t_pd) > 0
    maxie = max(max(t_dd), max(t_pd));
elseif length(t_dd) > 0
    maxie = max(t_dd);
elseif length(t_pd) > 0
    maxie = max(t_pd);
else
    error('Neither pitch nor duration trials found!');
end;

if plot_on
    hold on;
    % plot indicator bars
    pd_y_dots = ones(size(t_pd)) * pd_y;
    plot(t_pd, pd_y_dots, 'k.');
    dd_y_dots = ones(size(t_dd)) * dd_y;
    plot(t_dd, dd_y_dots, 'm.');
end;
%set(gca, 'YTick', [pd_y, dd_y], 'YTickLabel', {'PD Trial', 'DD Trial'});

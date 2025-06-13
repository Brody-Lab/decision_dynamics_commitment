function [t_pd, t_dd] = separate_pd_dd_trials(rat, task, date, title, varargin)
% ------------------------------------------------------------------------------------------
% function [t_pd, t_dd] = separate_pd_dd_trials(saved, saved_history, task, title, varargin)
%
%   Classifies tasks as being either pitch discrimination or duration discrimination and plots
%   task-type indicator points on the active figure at the following y-values:
%     * pd_y (y-value where PD trials are indicated)
%     * dd_y (y-value where DD trials are indicated)
% ------------------------------------------------------------------------------------------

pairs = { ...
    'plot_single', 1; ...
    'pd_y', 1.02; ...
    'dd_y', 1.03; ...
    'lower_bound', 0.99; ...
    'upper_bound', 1.01; ...
    'switch_intro_date', '05/12/09' ; ...
    };
parse_knownargs(varargin,pairs);

load_datafile(rat, task, date);

% Pitch discrimination trials are those that have 1KHz on the LHS and 15
% KHz set for RHS
the_day = [date(1:2) '/' date(3:4) '/' date(5:6)];
if datenum(the_day, 'yy/mm/dd') < datenum(switch_intro_date, 'yy/mm/dd')
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
else
    task_type = saved_history.ChordSection_Task_Type;
    t_pd = find(strcmp(task_type, 'Pitch Disc'));
    t_dd = find(strcmp(task_type, 'Duration Disc'));
end;

    hh = eval(['saved.' task '_hit_history']);
    hit_rates(rat, task, date, ...
        'plot_single', 1);
    hold on;

    if length(t_dd) > 0 && length(t_pd) > 0
        maxie = max(max(t_dd), max(t_pd));
    elseif length(t_dd) > 0
        maxie = max(t_dd);
    elseif length(t_pd) > 0
        maxie = max(t_pd);
    else
        error('Neither pitch nor duration trials found!');
    end;

    hold on;
    % plot indicator bars
    pd_y_dots = ones(size(t_pd)) * pd_y;
    plot(t_pd, pd_y_dots, 'k.');
    dd_y_dots = ones(size(t_dd)) * dd_y;
    plot(t_dd, dd_y_dots, 'm.');

    if plot_single
        if (pd_y == 1.02) && (dd_y == 1.03)
            axis([0 maxie lower_bound upper_bound]);
            set(gca, 'YTick', [1 1.01 1.02 1.03],'YLim', [0.99 1.04], 'YTickLabel', {'Miss', 'Hit', 'PD Trial', 'DD Trial'});
        else
            set(gca, 'YTick', [pd_y, dd_y], 'YTickLabel', {'PD Trial', 'DD Trial'});
        end;
    else
        axis([0 maxie 0.6 1.2]);
    end;
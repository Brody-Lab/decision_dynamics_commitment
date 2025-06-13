function [] = show_task_progression(ratname, startdate, enddate, varargin)
% Plots a rat's progression through different levels of the task
% (primary/secondary conditioning vs. final task) on a day-to-day basis,
% indicated by the start and end dates provided.
% startdate: The day (e.g. 18, 25) from which to start plotting data
% enddate: The last day for which to plot data
%
% Alternately, for a discontinuous set of dates, use dateset to send an
% array of dates (e.g. [18:21 23:25])
%
% NOTE:
% 1) This script currently only works for duration_discobj since only this
% protocol has the fields 'ChordSection_Tone_Loc' and 'ChordSection_GO_Loc'
% 2) The files loaded are only of the first session ("a") of a given day -
% this script is intended for quick-and-dirty monitoring of a rat's
% progress through primary, secondary, and final conditioning across
% multiple days
%
% Sample usage:
% show_task_progression('cuauhtemoc', 18, 26);

pairs = { ...
    'dateset',  startdate:enddate ; ...
    }; parse_knownargs(varargin, pairs);

dateprefix = '0510';


figure;

num_plots = length(dateset);
rows = ceil(num_plots/3);
set(gcf, 'Position', [350 350 800 rows*150]);
ind = 1;
for curr_date = dateset
    subplot(rows, 3, ind);
    today = [dateprefix int2str(curr_date)];
    plot_days_progress(ratname, today, 'a');
  %  set(gca,'Units', 'pixels');
  %  pos = get(gca,'Pos');
  %  set(gca, 'Position', [pos(1) pos(2) 0.3 pos(4)]);
    ind = ind+1;
end;

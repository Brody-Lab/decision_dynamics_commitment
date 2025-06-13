function [] = cannula_psychdriver()

% cannula_psychdriver
% ---------------------
% >>>> Date tables
% old baseline dates
Grimesby__baseline ={'080331','080408'};
Pips__baseline = {'080408','080413'};
Blaze__baseline = {'080414','080420'};
Violet__baseline = {'080527','080603'};
% <<<<<<<<< Date tables 
% This script is only for plotting single days/arbitrary date
% ranges/arbitrary set of dates.
% ---------------------
ratname = 'Pips';
pool_alldays = 1; pool_baseline = pool_alldays;
given_title = 'new saline'; 
curvecolor = [1 1 1]*0.5;

%---- if plotting 1 day
singledate='080605a';
curvecolor ='r';
 psych_plotsingleday_vs_avgwk(ratname,singledate,'maniptype','singleday','curvecolor', curvecolor,...
     'pool_baseline', pool_baseline);

%--- if plotting range
dateset_from = '080410';
dateset_to = '080504';
%  fl = get_files(ratname,'fromdate', dateset_from,'todate', dateset_to);
%  psych_plotsingleday_vs_avgwk(ratname,'date range','maniptype','singleday_multi','in_dateset', fl,...
% 'curvecolor', curvecolor);

%---- if plotting arbitrary set of dates
%in_dateset = rat_task_table(ratname, 'action', 'cannula__muscimol'); in_dateset = in_dateset(:,1);
%in_dateset = rat_task_table(ratname, 'action', 'cannula__saline'); in_dateset = in_dateset(:,1);
%curvecolor = 'g';
%flist = get_files(ratname, 'from', in_dateset{1}, 'end', sub__dateoffset(in_dateset(end), 5));

% get date AFTER in_dateset
% out_dateset = sub__getnextday(in_dateset, flist);
% in_dateset = out_dateset;
% 
% psych_plotsingleday_vs_avgwk(ratname,given_title,'maniptype','singleday_multi',...
%     'pool_baseline', pool_alldays, 'pool_alldays',pool_alldays,...
%     'in_dateset', in_dateset,'curvecolor', curvecolor);

% ------------------------------------------------------------
% Subroutines
% ------------------------------------------------------------

% given set of dates, returns the dates 'doffset' days away from each date
% in the list
function [outdates] = sub__dateoffset(indates,doffset)
outdates = {};
for d = 1:length(indates)
    str = indates{d};
 newstr=yearmonthday(datenum(str2double(str(1:2)),str2double(str(3:4)),str2double(str(5:6))) + doffset);
 outdates{end+1} = newstr;
end;

% returns the date for the datafile following each date in the list
% 'indates'
function [outdates] = sub__getnextday(indates, datelist)
outdates={};

for d = 1:length(indates)
    idx = find(strcmpi(datelist, indates{d}));    
    try
         outdates{end+1}=datelist{idx+1};
    catch
   error('%s: Either didn''t find the date or datelist needs to be longer', indates{d});
    end;      
end;



% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

% ---- For this stuff, use sessionsummary

% plot muscimol
% psych_plotsingleday_vs_avgwk(ratname, ...
% 'muscimol','maniptype','muscimol','pool_alldays',pool_alldays);

% plot saline
% psych_plotsingleday_vs_avgwk(ratname, ...
% 'saline','maniptype','saline','pool_alldays',pool_alldays);

% plot days of no manipulation
%psych_plotsingleday_vs_avgwk(ratname,'non-days','maniptype','none','from',fromdate,'pool_alldays',pool_alldays)

% PLOT PAIRS -------------------

% No manipulations versus saline
%psych_plotsingleday_vs_avgwk(ratname, 'blah','maniptype', 'plot_pair','manip_pair1', 'none', ...
% 'pair1_color', [0 0 1], 'pair1_errcolor', [0.8 0.8 1],'pair1_text','nothing','from',fromdate,'pool_alldays',pool_alldays)

% Muscimol versus saline
%psych_plotsingleday_vs_avgwk(ratname, 'blah','maniptype', 'plot_pair','from',fromdate,'pool_alldays',pool_alldays)



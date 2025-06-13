function [times trials] = sessiontime(ratname, from,to,varargin)
% Returns the average duration of a session.
% Also plots the duration of sessions for each date in the date range

pairs = { ...
    'plotme', 1 ; ... % if false, only returns duration array, does not plot data
    };
parse_knownargs(varargin,pairs);

ratrow = rat_task_table(ratname);
task = ratrow{1,2};
dates = get_files(ratname, 'fromdate', from, 'todate', to);

times = [];
trials = [];
for d = 1:rows(dates)
    tmp = sub__currtime(ratname, task, dates{d});
    if sum(tmp) == 0,
        n = 0; t = 0;
    else
        n= tmp(2);
        t = tmp(1);
    end;
    times = [times t];
    trials = [trials n];
end;

times = times / 60; % convert to minutes
times = times / 60; % convert to hours

c = sub__hour2str(mean(times));

if plotme > 0
    fprintf(1,'Average session duration = %s\n', c{1});
    yrange = 0:0.5:4;
    ylbls = sub__hour2str(yrange);
    

    figure;
    set(gcf,'Menubar','none','Toolbar','none','Position',[6   706   563   151]);
    plot(1:length(times), times, '.b');
    idx = find(times > 2);
    hold on;
    plot(idx, times(idx),'.r');
    line([0 length(times)+1],[2 2], 'LineStyle',':','Color','r');
    set(gca,'XTickLabel', dates,'XTick', 1:rows(dates),'XLim', [0 rows(dates)+1],...
        'YTick',yrange,'YTickLabel',ylbls,'YLim',[0.5 4]);
    xlabel('Session date');
    ylabel('Session duration (in hours)');
    title(ratname);
    
     figure;
    set(gcf,'Menubar','none','Toolbar','none','Position',[200   200   563   151]);
    plot(1:length(times), (times ./ trials)*3600,'.b');
     set(gca,'XTickLabel', dates,'XTick', 1:rows(dates),'XLim', [0 rows(dates)+1]);
     ylabel('Duration of a trial (in seconds, not hours)')
   
end;

function [out] = sub__currtime(ratname, task, date)

status = load_datafile(ratname, date);
if status < 1
    out = [0 0];
    return;
end;
evs = eval(['saved_history.' task '_LastTrialEvents']);
t = eval(['saved.' task '_n_done_trials']);

efirst = evs{1}; elast = evs{end};
firsttime = efirst(1,3);
lasttime = elast(end,3);

mini = lasttime-firsttime;
out = [mini t];

% yrange is a vector of fractions of hours.
% returns a string of format h:mm - where h is hours and mm is minutes
function [ylbl] = sub__hour2str(yrange)
ylbl = {};
for k = 1:length(yrange)
    frac = round(mod((yrange(k) * 100),100)/100 * 60); % leave only the fraction of the last hour...and convert to minutes
    if mod(frac,10) > 8, frac = frac+1; end; % round off if really close.
    if frac == 59, frac = 00;
    elseif frac > 30, yrange(k) = yrange(k)-1; end; 
    ylbl{end+1} = sprintf('%i:%i', round(yrange(k)), frac);
    2;
end;

2;
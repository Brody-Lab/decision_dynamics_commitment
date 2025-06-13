function [] = sessiontime(rat, task, varargin)
% Returns the average duration of a session.
% Also plots the duration of sessions for each date in the date range

pairs = { ...
    'from', '000000'; ...
    'to', '999999'; ...
    };
parse_knownargs(varargin,pairs);

dates = get_files(rat, 'fromdate', from, 'todate', to);

times = [];
for d = 1:rows(dates)
    times = [times currtime(rat, task, dates{d})];
end;

times = times / 60; % convert to minutes
times = times / 60; % convert to hours

c = hour2str(mean(times));
fprintf(1,'Average session duration = %s\n', c{1});

yrange = 0:0.33:2;
ylbls = hour2str(yrange);

figure;
plot(1:length(times), times, '.b');
set(gca,'XTickLabel', dates,'XTick', 1:rows(dates),'XLim', [0 rows(dates)+1],...
    'YTick',yrange,'YTickLabel',ylbls,'YLim',[0.5 1.5]);
xlabel('Session date');
ylabel('Session duration (in hours)');
title(rat);


function [mini] = currtime(rat, task, date)

load_datafile(rat, task, date);
evs = eval(['saved_history.' task '_LastTrialEvents']);

efirst = evs{1}; elast = evs{end};
firsttime = efirst(1,3);
lasttime = elast(end,3);

mini = lasttime-firsttime;

function [ylbl] = hour2str(yrange)
ylbl = {};
for k = 1:length(yrange)
    frac = round(mod((yrange(k) * 100),100)/100 * 60);
    if mod(frac,10) > 8, frac = frac+1; end;
    if frac == 59, frac = 00;
    elseif frac > 30, yrange(k) = yrange(k)-1; end;
    ylbl{end+1} = sprintf('%i:%i', round(yrange(k)), frac);
end;
function [h, l, end_idx, binned] = hit_rates(rat, task, date, varargin);

% plots the hit rate of the rat in a forward-looking sliding window of
% a specified size (bout_size).
% Returns:
% h = label for the y-axis
% l = handle to the axis on which hit rate is plotted
% last_win = the trial # for which the last window was computed.


pairs = { ...
    'running_avg', 20; ...
    'good', 0.8; ...
    'plot_title', sprintf('%s:%s (%s)\nHit rates', make_title(rat), make_title(task), date) ; ...
    'verbose', 0        ; ...
    'plot_single', 0    ; ...
    'y_min', 0.3        ; ...
    'multiday', 0       ; ...   % when on, doesn't print "50%" and "80%" by indicator lines
    'fsize', 12         ; ...
    'show_to_zero', 0;  ...
    'lookahead', 0 ; ...
    'graphic', 1 ; ... % when 0, only output is h. h is the kernalized y-values.
    };

parse_knownargs(varargin, pairs);

plot_title = [plot_title sprintf(' (Running avg of %i)', running_avg)];
if ~strcmpi(computer, 'MAC'), fsize = 9; end;

load_datafile(rat, date);
hit_history = eval(['saved.' task '_hit_history']);

hit_history = hit_history(find(~isnan(hit_history)));
overall_rate = mean(hit_history);

hh = hit_history;
nums=[];
t = (1:length(hh))';
a = zeros(size(t));
for i=1:length(hh),
    x = 1:i;
    kernel = exp(-(i-t(1:i))/running_avg);
    kernel = kernel(1:i) / sum(kernel(1:i));

    a(i) = sum(hh(x)' .*kernel);
end;
num = a;

plot(num, '.-');

line([1 length(num)], [good good], 'LineStyle','--','Color','b');
line([1 length(num)], [0.5 0.5], 'LineStyle', '--', 'Color', 'r');

text(3, 0.9, sprintf('Mean=%2.1f%%', overall_rate*100)); 

%set(t,'FontSize',14,'FontWeight','bold');

set(gca,'YLim',[0.4 1], 'YTick',0:0.2:1, 'YTickLabel', 0:20:100);

ylabel('Hit rate');
xlabel('Trial #');
function [] = mocty_analyze()
% mocty_analyze.m
% Analyze Moctezuma's progress day by day


ratname = 'moctezuma';
task = 'duration_discobj';
date_prefix = '0510';

h = findobj('Tag', 'duration_main');
if ~isempty(h)
    delete(h);
end;

h = figure;
set(h, 'Position', [70    19   845   658]);
set(h,'Tag', 'duration_main');

h2 = findobj('Tag', 'duration_hist');
if ~isempty(h2)
    delete(h2);
end;

h2 = figure;
set(h2,'Tag', 'duration_hist');

switch ratname
    case 'cuauhtemoc'
        date_titles = { ...
            '23', '23 Oct 2005 - Day 7 (Day 3 of task)'; ...
            '24', '24 Oct 2005 - Day 8 (Day 4 of task)'; ...
            '25', '25a Oct 2005 - Day 9 (Day 5 of task)'; ...
            '25', '25b Oct 2005 - Day 9 (Day 5 of task)'; ...
            };
    case 'moctezuma'
        date_titles = { ...
            '21', '23 Oct 2005 - Day 5'; ...
            '22', '22 Oct 2005 - Day 6'; ...
            '24', '24a Oct 2005 - Day 7'; ...
            '25', '25 Oct 2005 - Day 8 - Psychometric curve'; ...
            };
    otherwise
        ratname = 'moctezuma';      % Mocty is the default rat
           date_titles = { ...
            '21', '23 Oct 2005 - Day 5'; ...
            '22', '22 Oct 2005 - Day 6'; ...
            '24', '24a Oct 2005 - Day 7'; ...
            '25', '25 Oct 2005 - Day 8 - Psychometric curve'; ...
            };
end;

set(h, 'Name', ['Duration Discrimination (300 vs 1000ms): ' ratname]);
set(h2, 'Name', ['DD(0.3/1 s): ' ratname ': Performance %age']);


bin_cell = cell(0,0);
for curr = 1:size(date_titles,1)
    figure(h);
    if strcmp(ratname, 'cuauhtemoc') && curr == 4
        hh = get_hit_history_2(ratname, task, [date_prefix date_titles{curr,1}], 'f_ver', 'b');
    else
        hh = get_hit_history_2(ratname, task, [date_prefix date_titles{curr,1}]);
    end;

    subplot(2,2,curr);
    binned = analyze_bouts(hh, 'plot_title', date_titles{curr,2});
    bin_cell{curr} = binned;

    figure(h2);
    subplot(2,2,curr);
    %  axes('Position', axes_pos{curr}, 'parent', h2);
    x_bins = [0.4 0.5 0.6 0.7 0.8 0.9];
    histo = hist(bin_cell{curr}, x_bins);
    bar(x_bins, (histo/length(binned))*100);
    xlim([0.5 1]); ylim([0 100]); xlabel('Hit rate'); ylabel('% Trials');
    %gca(set,'YTick',[10:10:100]);
    title(date_titles{curr,2});
end;

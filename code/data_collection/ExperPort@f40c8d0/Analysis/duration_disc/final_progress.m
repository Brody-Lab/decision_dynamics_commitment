function [] = final_progress(rat, task, dates)

% Plots the hit rate on the final (localisation off) task for a rat, as a
% function of sessions and blocks.
% Input args:
% 1. Rat name: e.g. "timur_lang"
% 2. Task: e.g. "duration_discobj"
% 3. Dates: r-by-1 cell array where each row contains a date
%
% These three values must be able to be concatenated into a valid datafile
% name.
% e.g. data_duration_discobj_timur_lang_060401a.mat
%
% The script assumes that the "dates" array starts with the first day on
% which the rat was presented the final task.

clf;
if rows(dates) == 1, dates = dates'; end;

plot_cell = {}; ctr = 1;

for k = 1:rows(dates)
    hit_blocks = show_localisation(rat, task, dates{k}, 'plot_final_hits', 1, 'verbose', 0);
    for m = 1: rows(hit_blocks),
        % c1: title, c2: size, c3: hit rate
        plot_cell(ctr, 1:3) = { ['D' num2str(k) 'B' num2str(m)], length(hit_blocks{m,1}), hit_blocks{m,2}};        
        ctr = ctr+1;
    end;
end;

trials = cell2mat(plot_cell(:,2));
yvals = cell2mat(plot_cell(:,3));
p = yvals/100; stdev = sqrt((p .* (1-p)) ./ trials);
errorbar(1:rows(plot_cell), yvals, stdev*100, stdev*100, '.b');
hold on; plot(1:rows(plot_cell), cell2mat(plot_cell(:,3)), '-r');
set(gca, 'XTick', 1:rows(plot_cell), 'XTickLabel', plot_cell(:,1), 'XLim', [0 rows(plot_cell)+1], 'YLim', [0 100]);

for k = 1:rows(plot_cell)
    text(k-0.1, yvals(k)-7, sprintf('(%i)', trials(k)));
end;

title(sprintf('%s: %s: %s to %s', make_title(rat), make_title(task), dates{1}, dates{end}));
xlabel('Day of learning');
ylabel('% correct');

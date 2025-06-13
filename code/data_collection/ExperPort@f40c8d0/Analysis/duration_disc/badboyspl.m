function [] = badboyspl(rat, task,date)
  
load_datafile(rat, task, date);

bbspl = saved_history.TimesSection_BadBoySPL;

bb = zeros(length(bbspl), 1);

i = find(strcmpi(bbspl, 'normal'));
bb(i) = 1;

i = find(strcmpi(bbspl, 'Louder'));
bb(i) = 2;

i = find(strcmpi(bbspl,'Loudest'));
bb(i) = 3;

figure;
set(gcf,'Position', [100 100 640 145], 'Menubar', 'none','Toolbar','none')
plot(1:length(bb), bb, '.r');
ylabel('BadboySPL');
set(gca,'YTick', 1:3, 'YTickLabel', {'normal','Louder','LOUDEST'}, 'XLim', ...
        [1 length(bb)], 'YLim', [0 4]);
xlabel('Trial #');
s = sprintf('%s: %s (%s)\nBadBoySPL', make_title(rat), make_title(task), date);
title(s);
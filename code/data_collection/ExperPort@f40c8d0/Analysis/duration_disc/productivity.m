function [] = productivity(date)

ratlist = rat_task_table('', 'get_current',1);

prod =  {} ; % key: rat, value : number trials
for r = 1:length(ratlist)
    stat = load_datafile(ratlist{r,1}, date);
    if stat ==1
        prod{end+1,1} = ratlist{r,1};
        prod{end,2} = eval(['saved.' ratlist{r,2} '_n_done_trials;']);
        prod{end,3} = ratlist{r,2};
    else
        fprintf(1,'No data for %s\n',ratlist{r});
    end;
end;

figure;
p = cell2mat(prod(:,2));
plot(1:length(p),p,'.b');
hold on;
idx = find(strcmpi(prod(:,3),'dual_discobj'));
plot(idx, p(idx),'.r');
set(gca,'XTick',1:length(p),'XTickLabel',ratlist(:,1));
set(gcf,'Menubar','none','Toolbar','none');
title(sprintf('# trials done on %s',date));
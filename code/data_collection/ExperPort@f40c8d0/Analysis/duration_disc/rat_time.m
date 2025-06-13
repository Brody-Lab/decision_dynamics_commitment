function [] = rat_time()

ratlist = rat_task_table('', 'get_current',1);

from=-3;
to=-1;

currx = 10; curry = 10;
ht = 300;
for r = 1:length(ratlist)
    ratname = ratlist{r};
    time_per_state(ratname, from,to,'plot_totaltime',0);
    
    set(gcf,'Position',[currx curry ht ht]);
    fprintf(1,'%s...\n', ratname);
    curry = curry + ht + 10;
    if (curry > 700),
        curry = 10;
        currx = currx+ ht +10;
    end;
end;
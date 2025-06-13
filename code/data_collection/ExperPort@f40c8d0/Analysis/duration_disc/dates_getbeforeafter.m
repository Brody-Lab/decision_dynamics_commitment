function [] = dates_getbeforeafter(area_filter, task)

% ACx round 2 rats
ratlist = rat_task_table('','action', ['get_' task '_psych'],'area_filter', area_filter);

% cannula rats
% ratlist = {'S002','S007', 'S005', 'S013','S017','S024','S014'};

mytask = 0;
if strcmpi(task(1:3),'dur'),
    mytask = 'duration_discobj';
else
    mytask = 'dual_discobj';
end;

for r=1:length(ratlist)
    ratname=ratlist{r};
    ratrow = rat_task_table(ratname);
bef=ratrow{1,4};
aft=ratrow{1,5};

fprintf(1,'"%s"=>[1,"%s","%s","%s"]\n', ratname, mytask, bef{1}, aft{2});
end;

function [] = psych_roundlesion(area_filter)
% show psych curve on last session before surgery and first session after
% surgery

ratlist = rat_task_table('','action','get_duration_psych','area_filter',area_filter);
% r2 =rat_task_table('','action','get_pitch_psych','area_filter',area_filter);

experimenter='Shraddha';
infile='psych_before';

for r=1:length(ratlist)
    loadpsychinfo(ratlist{r}, 'infile','psych_before','lastfew',1,'justgetdata',1);
	axes__format(gca);
    loadpsychinfo(ratlist{r}, 'infile','psych_after','isafter',1, ...
        'dstart',1, 'dend', 1, 'justgetdata',1);
    axes__format(gca);
    
end;
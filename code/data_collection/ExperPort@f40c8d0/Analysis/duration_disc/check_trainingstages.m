function [] = check_trainingstages(date)

ratlist = rat_task_table('','get_current',1);

for r = 1:rows(ratlist)
    ratname = ratlist{r};
        fprintf(1,'%s:',ratname);
    status=load_datafile(ratname, date,'ftype','Settings');
    if status < 0,fprintf(1,'MISSING FILE ****\n'); end;
    b = saved.SessionDefinition_training_stages;

    if rows(b) < 1
        fprintf(1,'NO TRAINING STAGES!!\n');
    else
        fprintf(1,'# stages = %i\n', rows(b))
    end;
end;
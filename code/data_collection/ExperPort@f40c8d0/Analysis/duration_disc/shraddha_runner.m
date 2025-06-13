function  [sig_struct] = shraddha_runner
% shraddha_runner.m
% % runs any scripts that I want to have running while I'm gone.

% SHOWPROGRESS2FINAL -----------------------------------------------------
sig_struct=0;
% ratlist = {'Sirius','Riddle', 'Lucius', 'Treebeard','Celeborn','Balrog', 'Denethor'};
%
% for r = 1:length(ratlist)
%     ratname =ratlist{r};
%     showprogress2final(ratname,'action','load_finaltask')
% end;
%

% first offset2cout


if 0 % rxntime analysis
    close all;
    ispitch = 0;

    % % pitch rats
    % measure = 'offset2cout';
    % tasktype = 'pitch';
    %
    % if strcmpi(tasktype,'pitch'), ispitch = 1; else ispitch=0; end;
    % rxn_time_driver('action','save',...
    %     'ratlist', rat_task_table('','action', ['get_' tasktype '_psych']),...
    %     'outfile',['rxntime_' tasktype '_' measure],...
    %     'rxntime_measure', measure ...
    %     );

    % duration -offset
    measure = 'offset2cout';
    tasktype = 'duration';

    if strcmpi(tasktype,'pitch'), ispitch = 1; else ispitch=0; end;
    rxn_time_driver('action','save',...
        'ratlist', rat_task_table('','action', ['get_' tasktype '_psych']),...
        'outfile',['rxntime_' tasktype '_' measure],...
        'rxntime_measure', measure ...
        );

    % duration - onset
    measure = 'onset2cout';
    rxn_time_driver('action','save',...
        'ratlist', rat_task_table('','action', ['get_' tasktype '_psych']),...
        'outfile',['rxntime_' tasktype '_' measure],...
        'rxntime_measure', measure ...
        );
end;

%pitch spl analysis
if 0
    sigleft = []; 
    sigright = [];
    ratlist = rat_task_table('','action','get_pitch_psych');
    for r = 1:length(ratlist)
        ratname = ratlist{r};
        fprintf(1,'%s ...\n',ratname);
        if strcmpi(ratname,'Bilbo')
            fprintf(1,'Ignoring %s ...\n',ratname);
        else
            [x y]=spl_influence(ratname, 'psych_level',2);
            sigleft=  horzcat(sigleft,x);
            sigright=horzcat(sigright,y);
        end;
    end;

    fprintf(1,'Significance summary: Do rats go "Right" more for higher SPLs?\n');
    c = 1;
    for r = 1:length(ratlist)
        ratname = ratlist{r};
        if strcmpi(ratname,'Bilbo')            
        else
            fprintf(1,'%s:\tLeft side: %i\tRight side: %i\n',ratname(1:4), sigleft(c), sigright(c));
            c=c+1;
        end;
    end;
end;

% -------------------
% Runners for ACx round 2 experiments (Feb 09)

if 1
    % savepsychinfo for all pitch rats
    ratlist = rat_task_table('','action','get_pitch_psych', 'area_filter','ACx2');
    for r = 1:length(ratlist)
        ratname = ratlist{r};
        fprintf(1,'%s ...\n',ratname);
        savepsychinfo(ratname,'action','after');
    end;
end;

if 1
    % savepsychinfo for all duration rats
    ratlist = rat_task_table('','action','get_duration_psych', 'area_filter','ACx2');
    for r = 1:length(ratlist)
        ratname = ratlist{r};
        fprintf(1,'%s ...\n',ratname);
        savepsychinfo(ratname,'action','after');
    end;
end;

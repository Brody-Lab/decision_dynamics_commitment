function [] = metric_beforeafter(ratname)

mymetric='hrate';

ratrow = rat_task_table(ratname);
befdate = ratrow{1,4};
aftdate = ratrow{1,5};

if strcmpi(mymetric, 'numtrials')
    bmetric=numtrials_oversessions(ratname, 'from',befdate{1},'to',befdate{2},...
        'graphic',0);
    ametric=numtrials_oversessions(ratname,'from',aftdate{1},'to',aftdate{2},...
        'graphic',0);

else
    bmetric=session_hrate_oversessions(ratname, befdate{1}, befdate{2});
    ametric=session_hrate_oversessions(ratname, aftdate{1}, aftdate{2});
end;

% data should be an C-by-N cell (C=number of clusters; N=#bars in each
% cluster)
% sampledata = { ...
%    [C1_1], [C1_2], [C1_3] ; ...
%    [C2_1], [C2_2], [C2_3] ; ] ;
%
% colourset is a N-by-3 set of colours;  (each row is one colour)
% so if bars (1,2,3) in each cluster are to be (orange, grey, green),
% colourset = [ ...
%    1 0.5 0 ; ...
%    0.9 0.9 0.9; ...
%    0 1 0 ]
%
[sig p] = permutationtest_diff(bmetric, ametric, 'typeoftest','onetailed_gt0');

makebargroups({bmetric, ametric}, [0 0 1; 1 0 0]);

if strcmpi(mymetric,'numtrials')
    set(gca,'YLim',[0 300], 'YTick',0:50:300, 'XTick',[]);
else
    set(gca,'YLim',[0 1.5],'YTick',0:0.25:1, 'YTickLabel',0:25:100,'XTick',[]);
    ylabel('Accuracy rate (%)');
end;
axes__format(gca);


fprintf(1,'Before = %2.1f%% (%2.1f)\nAfter = %2.1f%% (%2.1f)\n', ...
    mean(bmetric), std(bmetric)/sqrt(length(bmetric)), ...
    mean(ametric), std(ametric)/sqrt(length(ametric)));

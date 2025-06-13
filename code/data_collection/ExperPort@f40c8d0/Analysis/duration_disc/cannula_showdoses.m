function [] = cannula_showdoses

ratlist = {'S007','S013','S024','S005','S014','S017','S002'};

durclr = [1 0.5 0];
freqclr = [0 0 1];
tasklist = [];

doselist = 0;
clrlist = 0;
f1=figure; % individual line graphs
f2=figure; % group-coloured line graph


durpile = [];
freqpile = [];
for r = 1:length(ratlist)
    can = rat_task_table(ratlist{r}, 'action', 'cannula__muscimol');
    clr = rand(1,3)
    doses = cell2mat(can(:,3))
    eval(['doselist.' ratlist{r} '= doses;']);
    eval(['clrlist.' ratlist{r} ' = clr;']);

    set(0,'CurrentFigure', f1);
    plot(doses,'.r','Color',clr,'MarkerSize',20); hold on;

    set(0,'CurrentFigure',f2);
    ratrow = rat_task_table(ratlist{r}); task = ratrow{1,2};
    if strcmpi(task(1:3), 'dur')
        plot(doses,'.r','Color',durclr,'MarkerSize',20); hold on;
        tasklist = horzcat(tasklist, 'd');
        durpile = horzcat(durpile, doses');
    else
        plot(doses,'.r','Color',freqclr,'MarkerSize',20); hold on;
        tasklist = horzcat(tasklist, 'p');
        freqpile = horzcat(freqpile, doses');
    end;
end;

title('Doses used for each rat');
set(gca,'XLim',[0 8], 'YLim',[0 0.2]);
set(0,'CurrentFigure',f1);
legend(ratlist);

for r = 1:length(ratlist)
    d = eval(['doselist.' ratlist{r} ';']);
    set(0,'CurrentFigure', f1);
    plot(d,'-r', 'Color', eval(['clrlist.' ratlist{r}]));

    set(0,'CurrentFigure',f2);
    if strcmpi(tasklist(r),'d')
        plot(d,'-r', 'Color', durclr);
    else
        plot(d,'-r', 'Color', freqclr);
    end;
end;

f3=figure; % all rats in one group plotted at single x point
set(0,'CurrentFigure',f3); set(gcf,'Position',[987   469   261   444]);
td = sub__makedensity(durpile); tf = sub__makedensity(freqpile);
plot(ones(length(durpile))*1, durpile, '.r', 'Color',[1 1 1]*0.5,'MarkerSize',20);
for d = 1:rows(td)
    text(0.8,td(d,1), sprintf('%i',td(d,2)),'FOntSize',14,'FontWeight','bold');
end;
hold on;
plot(ones(length(freqpile))*2, freqpile, '.r', 'Color',[1 1 1]*0.5,'MarkerSize',20);
for d = 1:rows(tf)
    text(2.2,tf(d,1), sprintf('%i',tf(d,2)),'FOntSize',14,'FontWeight','bold');
end;

set(gca,'XTick',[1 2], 'XLim',[0 3],'XTickLabel',{'dur','freq'},'YLim', [0 0.2]);
title('Muscimol doses shown by group');


function [tally] = sub__makedensity(f)

unq = unique(f);
tally=[];
for k=1:length(unq)
    sz = length(find(f == unq(k)));
    tally =vertcat(tally, [unq(k) sz]);
end;


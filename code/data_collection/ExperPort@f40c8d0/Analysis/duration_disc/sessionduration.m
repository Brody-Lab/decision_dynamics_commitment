function [] = sessionduration(ratlist, doffset,varargin)
% plots duration of a training session for all current rats for the last
% week
pairs = {...
    'graphic', 1 ; ...
    };
parse_knownargs(varargin,pairs);

%ratlist = rat_task_table('','get_current',1);

date = getdate(doffset);

ht = 150;
wt = 400;
sz = get(0,'ScreenSize');
x = 10; y =900;
xlbl = {};
f1=figure;set(gcf,'Position',[22         603        1188         292]);
f2=figure;set(gcf,'Position',[22         200        1188         292]);
msize = 20;

numtrials = [];
sessiondur =[];
for k = 1:length(ratlist)
    ratname =ratlist{k};
    ratrow = rat_task_table(ratname);
    task = ratrow{1,2};
    tmp= sub__currtime(ratlist{k},task,date);
    set(0,'CurrentFIgure',f1);

    p1=plot(k,tmp(1)./60,'.r','MarkerSize',msize);
    hold on;
    set(0,'CurrentFigure',f2);
    p2=plot(k,tmp(2),'.r','MarkerSize',msize);
    hold on;

    if tmp(1) == 0, set(p1,'Color','r'); set(p2,'Color','r'); end;
    xlbl{end+1} = ratlist{k};
    
    sessiondur = horzcat(sessiondur, tmp(1));
    numtrials = horzcat(numtrials, tmp(2));
end;

set(0,'CurrentFigure',f1);
line([1 length(xlbl)],[60 60],'LineStyle',':','Color','r','LineWidth',2);
line([1 length(xlbl)],[120 120],'LineStyle',':','Color','r','LineWidth',2);
set(gca,'XTick',1:length(xlbl), 'XTickLabel',xlbl);
maxie = max(sessiondur);
set(gca,'YTick',0:30:maxie, 'YTickLabel', 0:0.5:maxie/2);
set(gcf,'Tag','sessionduration');
ylabel('Minutes');
xlabel('rats');
t=title(sprintf('Session duration for %s',date));
set(t,'FontSize',12,'FontWEight','bold');


set(0,'CurrentFigure',f2);
set(gca,'XTick',1:length(xlbl), 'XTickLabel',xlbl);
set(gcf,'Tag','sessionduration');
ylabel('# trials');
xlabel('rats');
t=title(sprintf('# trials for %s',date));
set(t,'FontSize',12,'FontWEight','bold');

function [out] = sub__currtime(ratname, task, date)

status = load_datafile(ratname, date);
if status < 1
    out = [0 0];
    return;
end;
evs = eval(['saved_history.' task '_LastTrialEvents']);
t = eval(['saved.' task '_n_done_trials']);

efirst = evs{1}; elast = evs{end};
firsttime = efirst(1,3);
lasttime = elast(end,3);

mini = lasttime-firsttime;
out = [mini t];


function [ylbl] = hour2str(yrange)
ylbl = {};
for k = 1:length(yrange)
    frac = round(mod((yrange(k) * 100),100)/100 * 60);
    if mod(frac,10) > 8, frac = frac+1; end;
    if frac == 59, frac = 00;
    elseif frac > 30, yrange(k) = yrange(k)-1; end;
    ylbl{end+1} = sprintf('%i:%i', round(yrange(k)), frac);
end;
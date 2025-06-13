function [] = ibo_plotnumtrials(area_filter)
% plots number of trials spanning surgery for duration and frequency rats
% of specified area filter

field2use = 'numtrials';


global Solo_datadir;

durlist = rat_task_table('','action', 'get_duration_psych','area_filter', area_filter);
freqlist = rat_task_table('','action', 'get_pitch_psych','area_filter', area_filter);
ratlist = [durlist freqlist];

DUR_ID = 1;
FREQ_ID = 0;
dur_clr = group_colour('duration');
freq_clr = group_colour('frequency');
2;

% key: ratname, value: # trials on days before and days after lesion
before_list=[]; % ratname, # trials pre
after_list=[];  % ratname, # trials post
avg_before=[];  % ratname, average before_list.ratname
normed=[];      % ratname, [ post1 post2 ] / mean(pre)


f1=figure;
f2=figure;

set4permute=[];
tlist=NaN(size(ratlist));

for f = 1:length(ratlist)
    ratname =ratlist{f};
    ratrow = rat_task_table(ratname); task =ratrow{1,2};

    % psych before
    load([Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep 'psych_compiles' filesep ratname '_psych_before.mat']);

    switch field2use
        case 'hitrate'
            nb=sub__hrate(hit_history, numtrials)*100;
            2;
        otherwise
            nb=numtrials;
    end;
    if length(nb) > 7, nb = nb(end-6:end); end;
            eval(['before_list.' ratname ' = nb;']);
            mnb =mean(nb);
            eval(['avg_before.' ratname ' = mnb;']);

    % psych after
    load([Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep 'psych_compiles' filesep ratname '_psych_after.mat']);
    eval(['after_list.' ratname '= numtrials;']);

    switch field2use
        case 'hitrate'
            na=sub__hrate(hit_history, numtrials)*100;
        otherwise
            na=numtrials;
    end;

    if strcmpi(task(1:3), 'dur'),
        clr = dur_clr;
        tlist(f) = DUR_ID;
    else
        clr = freq_clr;
        tlist(f)=FREQ_ID;
    end;
    
    set(0,'CurrentFigure',f1);
    plot([ length(nb)*-1:1:-1 1:length(na)], [nb na], '-b','Color',clr); hold on;
    plot([length(nb)*-1:1:-1 1:length(na)], [nb na],'.b','Color',clr);

    set(0,'CurrentFigure', f2);
    plot(1:3, [1 na(1)/mnb na(2)/mnb], '-b', 'Color',clr); hold on;
    plot(1:3, [1 na(1)/mnb na(2)/mnb], '.b', 'Color',clr);
    %     plot(na,'-b','Color',clr); plot(na, '.b', 'Color',clr); hold on;

    normed = vertcat(normed, [na(1)/mnb, na(2)/mnb]);

end;

% set(0,'CurrentFigure',f1);
% set(gcf,'Position',[100 200 800 300]);
% xlabel('Day');
% ylabel('# trials');
% title(sprintf('%s:BEFORE lesion', area_filter));
%
%  set(0,'CurrentFigure',f2);
%  set(gcf,'Position',[300 500 200 600]);
%  xlabel('Day');
%  set(gca,'XLim', [0 4],'XTick',[1 2 3], 'XTickLabel', {'mean(-7:-1)', '+1', '+2'});
%  ylabel('normalized numtrials');
%  title(sprintf('%s:Avg last 7 to first post', area_filter));

% figure - group avg'd norm first day
figure;
dlist =normed(tlist==DUR_ID,:);
flist=normed(tlist==FREQ_ID,:);
incell={[dlist(:,1)], [flist(:,1)]; ...
    [ dlist(:,2)],[ flist(:,2)]; } ;
xlist= makebargroups( incell, [dur_clr; freq_clr] , ...
    'what2show', 'median', 'errtype', 'iqr');
line([-2 xlist(end)+1], [1 1],'LineStyle',':','Color', [1 1 1]*0.3,'LineStyle',':');
hold on;

msize=20;
durlite=group_colour('durlite');
freqlite=group_colour('freqlite');
plot(ones(size(dlist(:,1)))*xlist(1,1), dlist(:,1), '.k','MarkerSize', msize,'Color',durlite);
plot(ones(size(flist(:,1)))*xlist(1,2), flist(:,1), '.k','MarkerSize',msize,'Color',freqlite);
plot(ones(size(dlist(:,2)))*xlist(2,1), dlist(:,2),'.k','MarkerSize', msize,'Color',durlite);
plot(ones(size(flist(:,2)))*xlist(2,2), flist(:,2), '.k','MarkerSize', msize,'Color',freqlite);

set(gca,'XLim',[-1 xlist(end)+1],'YLim',[0 2], 'YTick',0:0.5:2);
ylabel('Normalized # trials');
set(gca,'XTickLabel', {'Day 1', 'Day 2'});
axes__format(gca);

%  (dlist(:,1), flist(:,1), ...
%      'what2show','median','errtype','iqr', ...
%      'g1_clr',dur_clr, 'g2_clr', freq_clr, ...
%      'g1_lbl','Timing', 'g2_lbl','Frequency');


[sig p]=permutationtest_diff(dlist(:,1), ...
    flist(:,1));
2;

function [h] = sub__hrate(hh, numtrials)
h = NaN(size(numtrials));
cumtrials=cumsum(numtrials);

for k=1:length(numtrials)
    if k<2, sidx=1; else sidx=cumtrials(k-1)+1; end;
    eidx=cumtrials(k);
    
    h(k)=mean(hh(sidx:eidx));    
end;


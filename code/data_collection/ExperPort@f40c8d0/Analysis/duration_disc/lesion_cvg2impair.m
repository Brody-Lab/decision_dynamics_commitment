function [] = lesion_cvg2impair()
% looks at both ACx lesion datasets
% pairs dur and freq rats with similar overall % coverages and asks if, for
% similar coverage, freq rats are more impaired than dur rats.
%
% !!!! MANUALLY SET:
% 1) use_metric. if 'impair', set correct dataset (addfname.
% Refer to input files in 'Set_Analysis' folder to pick correct name).
% 2) postpsych
% 3) psychthresh
% 4) ignore_trialtype
% see loadpsychinfo.m for descriptions of these switches

global Solo_datadir;
outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep 'impair_metric' filesep];
% addfname  = 'forcelinear_alltrials';

area_filter= 'ACx'; %'mPFC';
use_metric = 'impair'; % [ weber | impair ]
addfname  = 'forcelinear_alltrials'; % 'last7_first2'; %

if strcmpi(area_filter, 'ACx')
    inroiset={'Hpc'};
elseif strcmpi(area_filter,'mPFC')
    inroiset = {'PrL','IL'};
else
    error('unknown ROI');
end;

postpsych=0;
psychthresh=0;
ignore_trialtype=1;

% print variable values to ensure compatibility with impair loaded filename
varlist = {'postpsych','psychthresh','ignore_trialtype'};
fprintf(1,'----------\n');
fprintf(1,'addfname:\t%s\n', addfname);
for v=1:length(varlist)
    fprintf(1,'\t%s:\t%i\n', varlist{v}, eval(varlist{v}));
end;
fprintf(1,'----------\n');

nlist={'durcvg','freqcvg','durimpair','freqimpair','durname','freqname'};

% run script for ACx data
[out] = lesion_compare2groups('area_filter',area_filter,...
    'area_filter_pct',0,...
    'viewopt', 7, 'inroiset',inroiset,...
    'use_metric', use_metric,'impair_addfname', addfname, ...
    'postpsych', postpsych,'psychthresh', psychthresh, 'ignore_trialtype', ignore_trialtype);
if strcmpi(area_filter,'ACx'), pfx = 'ACx1'; else pfx ='mPFC';end;

for k=1:length(nlist)
    eval([pfx '_' nlist{k} '=out{k};']);
    eval([pfx '_' nlist{k} '=sub__makerowvec(' pfx '_' nlist{k} ');']);
end;

if strcmpi(area_filter,'ACx')
    % round 2 and 3
    for roundnum=2:3
        [out] = lesion_compare2groups('area_filter',['ACx' num2str(roundnum)],...
            'area_filter_pct',0,...
            'viewopt', 7,'inroiset', inroiset,...
            'use_metric', use_metric,'impair_addfname', addfname, ...
            'postpsych', postpsych,'psychthresh', psychthresh, 'ignore_trialtype', ignore_trialtype);

        for k=1:length(nlist)
            eval(['ACx' num2str(roundnum) '_' nlist{k} '=out{k};']);
            eval(['ACx' num2str(roundnum) '_' nlist{k} '=sub__makerowvec(ACx' num2str(roundnum) '_' nlist{k} ');']);
        end;
    end;

    % get saline values
    switch use_metric
        case 'weber'
            [dsal fsal gsal] = webers_seh_format('ACxallsaline',postpsych,psychthresh, ignore_trialtype);
            yl=[-.25 1];
            ylbl='(Post-Pre) Weber change';
            ty1=0.9;
            ty2=0.85;
            tx=0.1;

        case 'hitrate'
            [dsal fsal gsal] = surgery_effect_hrate('ACxallsaline', postpsych,'graphic',0);
            yl=[-0.25 0.1];
            ylbl='(Post-Pre) % change';
            ty1=0.09;
            ty2=.08;
            tx=0.8;

        case 'impair'
            fname = [outdir 'ACxallsaline_impair_' addfname '_calc7'];
            load(fname);
            dsal = diff_list;
            fsal = fname_list;
            gsal = grpnames;
            yl=[-0.2 1];
            ylbl='IMPAIR';
            ty1=yl(2)*0.9;
            ty2=yl(2)*0.8;
            if strcmpi(area_filter,'mPFC')
                tx=0.45;
            else
                tx=-0.2;
            end;
    end;
else
    yl=[-0.2 1];
    ylbl='IMPAIR';
    ty1=yl(2)*0.9;
    ty2=yl(2)*0.8;
    tx=0.45;
end;

% figure;
% p1=plot(ones(size(ACx1_durcvg)), ACx1_durcvg,'.b','MarkerSize',25); hold on;
% p2=plot(ones(size(ACx1_freqcvg))*2, ACx1_freqcvg,'.r','MarkerSize',25);
% p3=plot(ones(size(ACx2_durcvg))*3, ACx2_durcvg,'.b','MarkerSize',25);
% p4=plot(ones(size(ACx2_freqcvg))*4, ACx2_freqcvg,'.r','MarkerSize',25);
% set(gca,'XLim',[0 5], 'YLim',[0 1],'XTick',[1:4], 'XTickLabel',{'dur1','freq1','dur2','freq2'});
% set(gcf,'Position',[200 100 500 730]);
% title(sprintf('Acx1&2:Raw weber plots (postpsych=%i)', postpsych));

if strcmpi(area_filter,'ACx')
%     durs = [ACx2_durcvg];
%     dn=[ACx2_durname];
%     dimp = [ACx2_durimpair];
%     
    2;

    durs = [ACx1_durcvg ACx2_durcvg ACx3_durcvg];
     dn=[ACx1_durname ACx2_durname ACx3_durname];
     dimp = [ACx1_durimpair ACx2_durimpair ACx3_durimpair];
else
    durs = [mPFC_durcvg];
    dn=mPFC_durname;
    dimp = mPFC_durimpair;
end;

[dursort di] = sort(durs);
dnsort = dn(di);
dimpsort = dimp(di);



if strcmpi(area_filter,'ACx')
%     freqs=[ sub__makerowvec(ACx2_freqcvg)];
%     fn=[sub__makerowvec(ACx2_freqname)];
%     fimp=[sub__makerowvec(ACx2_freqimpair)];
%     
     freqs=[sub__makerowvec(ACx1_freqcvg) sub__makerowvec(ACx2_freqcvg)];
     fn=[sub__makerowvec(ACx1_freqname) sub__makerowvec(ACx2_freqname)];
     fimp=[sub__makerowvec(ACx1_freqimpair) sub__makerowvec(ACx2_freqimpair)];
else
    freqs= sub__makerowvec(mPFC_freqcvg);
    fn=sub__makerowvec(mPFC_freqname);
    fimp=sub__makerowvec(mPFC_freqimpair);
end;

[freqsort fi] = sort(freqs);
fnsort = fn(fi);
fimpsort = fimp(fi);

% now do mega regression
y = [dimpsort'; fimpsort'];
cvg = [dursort'; freqsort']; if cols(cvg)>1, cvg=cvg'; end;
tasktype = [ones(length(dursort),1)*-0.5; ones(length(freqsort),1)*0.5];

if isempty(fimpsort)
    do_regress=0;
else
    do_regress=1;
end;

2;

if do_regress>0
    [b bint]=regress(y,[cvg tasktype.*cvg ones(size(cvg))]);

    [bd bdint]=regress(dimpsort',[dursort' ones(size(dursort))']);
    [bf bfint]=regress(fimpsort',[freqsort' ones(size(freqsort))']);

    fprintf(1,'%s\n', repmat('-',1,50));
    fprintf(1, 'ALL data: y= C + TT*C + k:\n');
    regressprint(b, bint);

    fprintf(1,'%s\n', repmat('-',1,50));
    fprintf(1, 'TIMING: y= C + k:\n');
    regressprint(bd, bdint);

    fprintf(1,'%s\n', repmat('-',1,50));
    fprintf(1, 'FREQ: y= C + k:\n');
    regressprint(bf, bfint);
    fprintf(1,'%s\n', repmat('-',1,50));
end;


2;


% now do one including a third variable of saline or ibo
% if strcmpi(area_filter,'ACx')
% t1 = dsal{1}; if cols(t1) > 1, t1=t1'; end;
% t2 = dsal{2}; if cols(t2) > 1, t2=t2'; end;
% y2 =[y; t1; t2];
% allsal = length(t1)+length(t2);
%
% cvg = [cvg; zeros(allsal,1)]; % all saline rats have 0 coverage.
% tasktype = [tasktype; ones(length(t1),1); zeros(length(t2), 1)];
% dosetype = [ones(length(y),1); zeros(allsal,1)];
% end;
% 2;

dur_clr = [1 0.5 0]; freq_clr = [0 0.3 1];
msize=8;
figure;
dlite = group_colour('durlite');
flite = group_colour('freqlite');
if do_regress>0
    line([dursort(1) dursort(end)], [bd(1)*dursort(1)+bd(2), bd(1)*dursort(end)+bd(2)],'LineWidth',2,'Color',dlite); hold on;
end;

plot(dursort, dimpsort, 'ob','MarkerSize', msize,'MarkerEdgeColor','k','MarkerFaceColor',dur_clr);

if ~isempty(freqsort)
    if do_regress>0
        line([freqsort(1) freqsort(end)], [bf(1)*freqsort(1)+bf(2), bf(1)*freqsort(end)+bf(2)],'LineWidth',2,'Color',flite);
    end;
    plot(freqsort, fimpsort, 'or','MarkerSize', msize,'MarkerEdgeColor','k','MarkerFaceColor',freq_clr);
end;
2

% % uncomment this to get rat names
% for k=1:length(dursort)
%     text(dursort, dimpsort, dnsort);
% end;
% 
% for k=1:length(freqsort)
%     text(freqsort, fimpsort, fnsort);
% end;

if strcmpi(area_filter,'ACx')
    % saline
    dmsize=9;
    plot(ones(size(dsal{1}))*-0.2, dsal{1},'db', 'Color',dur_clr,'MarkerEdgeColor','k','MarkerFaceColor',dur_clr,'MarkerSize',dmsize);
    plot(ones(size(dsal{2}))*-0.2, dsal{2},'dr','Color',freq_clr,'MarkerEdgeColor','k','MarkerFaceColor',freq_clr,'MarkerSize',dmsize);
end;

% horizontal line
line([-0.25 -0.13], [0 0], 'LineStyle',':','Color',[ 1 1 1] * 0.5,'LineWidth',2);
line([-0.07 1], [0 0], 'LineStyle',':','Color',[ 1 1 1] * 0.5,'LineWidth',2);
% vertical line
line([0.5 0.5], yl, 'LineStyle',':','Color',[ 1 1 1] * 0.5,'LineWidth',2);
% slashes separating saline from ibo
line([-0.13 -0.1], [-0.05 0.05],'Color','k','LineWidth',2);
line([-0.11 -0.08], [-0.05 0.05],'Color','k','LineWidth',2);
% text(dtx, ty1, 'Timing', 'Color', dur_clr,'FontSize',12,'FontWeight','bold');
% text(tx, ty2,'Frequency','COlor', freq_clr,'FOntSize',12, 'fontWeight','bold');

if do_regress>0
    % mark regression values
    if b(3) > 0, sg='+'; else sg='-'; end;
    text(tx,0.9, sprintf('IMPAIR = %1.2fcvg +%1.2f(task x cvg) %s %1.2f', b(1), b(2),sg, abs(b(3))),'FontSize',14);
    % if bd(2) > 0, sg='+'; else sg='-'; end;
    % text(tx,0.9, sprintf('TIMING = %1.2fC %s %1.2f', bd(1), sg, abs(bd(2))),'FontSize',18, 'Color', dur_clr,'FontWeight','bold');
    % if bf(2) > 0, sg='+'; else sg='-'; end;
    % text(tx,0.8, sprintf('FREQ = %1.2fC %s %1.2f', bf(1), sg, abs(bf(2))),'FontSize',18, 'Color', freq_clr,'FontWeight','bold');
end;


set(gca,'YLim',yl,'XTick',-0.2:0.2:1, 'XTickLabel',...
    {'Saline',0:20:100}, ...
    'YTick',0:0.2:1);
xlabel(sprintf('%s coverage (%%)', area_filter));
ylabel(ylbl);
axes__format(gca);
set(gca,'XLim',[-0.25 1]);
title(sprintf('All %s - postpsych=%i',area_filter, postpsych));

if strcmpi(area_filter,'mPFC')
    set(gca,'YTick',-0.2:0.2:1);
    set(gca,'YLim', [-.4 1]);
    set(gca,'XTick', 0.4:0.1:1, 'XTickLabel', 40:10:100)
    set(gca,'XLim',[0.4 1]);
end;

set(gcf,'Position',[150   535   734   336]);





function [v] = sub__makerowvec(v)
if rows(v) > 1, v=v'; end;

function [] = lesion_multiROI_regress()

roiset={{'AuD','A1','AuV', 'TeA'}; {'S1'}; {'Hpc'}};
lbls={'ACx','S1','Hpc'};

nlist={'durcvg','freqcvg','durimpair','freqimpair','durname','freqname'};

cvg=0;

for r=1:rows(roiset)
    eval(['cvg.' lbls{r} '=sub__getcvg(roiset{r,1}, nlist);']);
end;

% first timing --------------------------

durs = [cvg.ACx.ACx_durname cvg.ACx.ACx2_durname cvg.ACx.ACx3_durname];
durh = [cvg.Hpc.ACx_durname cvg.Hpc.ACx2_durname cvg.Hpc.ACx3_durname];
durs1 = [cvg.S1.ACx_durname cvg.S1.ACx2_durname cvg.S1.ACx3_durname];

if ~(cellstr_are_equal(durs, durh) && cellstr_are_equal(durs,durs1) && ...
    cellstr_are_equal(durh, durs1))
    error('mismatch');
end;
clear durh durs1;

d_acxcvg=[cvg.ACx.ACx_durcvg cvg.ACx.ACx2_durcvg cvg.ACx.ACx3_durcvg]; d_acxcvg=d_acxcvg';
d_s1cvg=[cvg.S1.ACx_durcvg cvg.S1.ACx2_durcvg cvg.S1.ACx3_durcvg]; d_s1cvg=d_s1cvg';
d_hpcvg=[cvg.Hpc.ACx_durcvg cvg.Hpc.ACx2_durcvg cvg.Hpc.ACx3_durcvg]; d_hpcvg=d_hpcvg';

dimp = [cvg.ACx.ACx_durimpair cvg.ACx.ACx2_durimpair cvg.ACx.ACx3_durimpair]';

xd=[d_acxcvg d_hpcvg d_s1cvg ones(size(d_acxcvg)) ];
% [b bint]=regress(dimp',x);
% 
% fprintf(1,'%s\n', repmat('-',1,50));
% fprintf(1, 'ALL data: y= ACX + HPC + S1 + k:\n');
% regressprint(b, bint);

% first freq --------------------------

freqs = [cvg.ACx.ACx_freqname cvg.ACx.ACx2_freqname];
freqh = [cvg.Hpc.ACx_freqname cvg.Hpc.ACx2_freqname];
freqs1 = [cvg.S1.ACx_freqname cvg.S1.ACx2_freqname];

if ~(cellstr_are_equal(freqs, freqh) && cellstr_are_equal(freqs,freqs1) && ...
    cellstr_are_equal(freqh, freqs1))
    error('mismatch');
end;
clear freqh freqs1;

f_acxcvg=[cvg.ACx.ACx_freqcvg cvg.ACx.ACx2_freqcvg cvg.ACx.ACx3_freqcvg]; f_acxcvg=f_acxcvg';
f_s1cvg=[cvg.S1.ACx_freqcvg cvg.S1.ACx2_freqcvg cvg.S1.ACx3_freqcvg]; f_s1cvg=f_s1cvg';
f_hpcvg=[cvg.Hpc.ACx_freqcvg cvg.Hpc.ACx2_freqcvg cvg.Hpc.ACx3_freqcvg]; f_hpcvg=f_hpcvg';

fimp = [cvg.ACx.ACx_freqimpair cvg.ACx.ACx2_freqimpair cvg.ACx.ACx3_freqimpair]';

xf=[f_acxcvg f_hpcvg f_s1cvg ones(size(f_acxcvg)) ];
% [b bint]=regress(fimp',x);
% 
% fprintf(1,'%s\n', repmat('-',1,50));
% fprintf(1, 'ALL data: y= ACX + HPC + S1 + k:\n');
% regressprint(b, bint);

% COMBINE --------------

imp = [dimp; fimp];
x = [xd; xf];
 [b bint]=regress(imp,x);
% 
 fprintf(1,'%s\n', repmat('-',1,50));
 fprintf(1, 'ALL data: y= ACX + HPC + S1 + k:\n');
 regressprint(b, bint);
 
 2;
 
 % CORRELATION BTWN ALL CVG
2;
imp=[dimp; fimp];
 nm=[durs freqs];
 acx=[f_acxcvg; d_acxcvg];
 hpc=[f_hpcvg; d_hpcvg];
 s1=[f_s1cvg; d_s1cvg];
 
 figure;
  plot3(acx,hpc,imp,'.b'); p=corrcoef(acx,hpc);
%  plot(acx,hpc,'.b'); p=corrcoef(acx,hpc);
%  grid on;
 title('ACx-hpc');
 hold on;
 for r=1:length(nm)
      text(acx(r)+0.015,hpc(r), imp(r),nm{r},'FontSize', 10);
% text(acx(r)+0.015,hpc(r),nm{r},'FontSize', 10);
 end;
 fprintf(1,'ACx-HPc: %1.2f\n', p(1,2));
 axes__format(gca);
 set(gca,'YLim',[-0.03 0.2], ...
     'XLim',[-0.02 1], ...
     'ZLim',[-0.02 1]);
%   set(gca,'YLim',[-0.03 0.2]);
 zlabel('IMPAIR');
 xlabel('ACx'); ylabel('Hpc');
 
 
 figure;
%  plot(acx,s1,'.k'); p=corrcoef(acx,s1);
plot3(acx,s1,imp,'.k');p=corrcoef(acx,s1);
  for r=1:length(nm)
     text(acx(r)+0.015,s1(r), imp(r),nm{r},'FontSize', 10);
 end;
 title('ACx-s1');
 fprintf(1,'ACx-s1: %1.2f\n', p(1,2));
 xlabel('ACx'); ylabel('S1');
 zlabel('IMP');
 set(gca,'YLim',[-0.03, 0.8]);
 set(gca,'XLim',[-0.02,1]);
 set(gca,'ZLim',[-0.01 1],'ZTick',0:0.2:1);
 axes__format(gca);
 
 
%  plot(acx,hpc,'ACx-vs-hpc'); p=corrcoef(acx,hpc);
%  fprintf(1,'ACx-HPc: %1.2f', p);
%  
 


function [myout] = sub__getcvg(inroiset, nlist)

myout=0;
use_metric='impair';
addfname='forcelinear_alltrials';
postpsych=1;
psychthresh=1;
ignore_trialtype=1;
% run script for ACx data
[out] = lesion_compare2groups('area_filter','ACx',...
    'area_filter_pct',0,...
    'viewopt', 7, 'inroiset',inroiset,...
    'use_metric', use_metric,'impair_addfname', addfname, ...
    'postpsych', postpsych,'psychthresh', psychthresh, 'ignore_trialtype', ignore_trialtype);

for k=1:length(nlist)
    eval(['myout.ACx_' nlist{k} '=out{k};']);
    eval(['myout.ACx_' nlist{k} '=sub__makerowvec(myout.ACx_' nlist{k} ');']);
end;

for roundnum=2:3
    [out] = lesion_compare2groups('area_filter',['ACx' num2str(roundnum)],...
        'area_filter_pct',0,...
        'viewopt', 7,'inroiset', inroiset,...
        'use_metric', use_metric,'impair_addfname', addfname, ...
        'postpsych', postpsych,'psychthresh', psychthresh, 'ignore_trialtype', ignore_trialtype);

    for k=1:length(nlist)
        eval(['myout.ACx' num2str(roundnum) '_' nlist{k} '=out{k};']);
        eval(['myout.ACx' num2str(roundnum) '_' nlist{k} '=sub__makerowvec(myout.ACx' num2str(roundnum) '_' nlist{k} ');']);
    end;
end;


function [v] = sub__makerowvec(v)
if rows(v) > 1, v=v'; end;



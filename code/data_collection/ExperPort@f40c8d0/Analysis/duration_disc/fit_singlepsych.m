function [bstruct astruct] = fit_singlepsych(ratname, varargin)
% compares fit of before/after psych curve to linear or sigmoid fit.
% returns q-values of each fit.
% see Numerical Recipes 1992 edition for definition of q-value (section 15.2 and 6.2)
% and merit chi2 metric (section 15.1)
%

pairs =  { ...
    'acxflag', 1 ; ...
    'postpsych', 1 ; ...
    'psychthresh', 1 ; ...
    'ignore_trialtype', 0 ; ...
    'graphic', 0 };
parse_knownargs(varargin, pairs);

preflipped=acxflag;

bef=[];
aft=[];

alist={'betahat', 'overall_betahat',...
    'xx','yy','overall_weber',...
    'origbins', 'bins','replongs','tallies',...
    'concat_hh','concat_side_choice','concat_tones', ...
    'overall_xc','overall_xmid','overall_xf','sigmoidfit','linearfit'};

ratrow=rat_task_table(ratname); task=ratrow{1,2};

loadpsychinfo(ratname, 'infile', [ratname '_psych_before'], ...
    'justgetdata',1,...
    'preflipped', preflipped, ...
    'psychthresh',psychthresh,...
    'ignore_trialtype', ignore_trialtype, ...
    'lastfew', 7,...
    'eliminate_Mondays', 0,...
    'daily_bin_variability', 0, ...
    'graphic', 0, ...
    'postpsych',postpsych, ...
    'ACxround1', acxflag);
origbins=bins;
if strcmpi(task(1:3),'dur')    
    bins=log(bins);
    mp = sqrt(200*500);
    xrange = log([binmin binmax]);
else
    mp=sqrt(8*16);
    bins=log2(bins);
    xrange = log2([binmin binmax]);
end;

for a=1:length(alist)
    eval(['bef.' alist{a} '=' alist{a} ';'])
end;
allreps = nansum(replongs); bef.reps = allreps;
alltallies = nansum(tallies); bef.tallies = alltallies;
bef.p = allreps ./ alltallies; blah=bef.p;
tmp = replongs ./tallies;
bef.sdp = (blah .* (1-blah)) ./alltallies;
bef.sdp = sqrt(bef.sdp);
bef.xrange=xrange;

oldbefp = bef.p;

idx=find(bef.p>0.99);
if ~isempty(idx)
%     warning('FOund bin with perfect value. making it slightly imperfect');
    bef.p(idx)=0.99;
end;

idx=find(bef.p<0.01);
if ~isempty(idx)
%     warning('FOund bin with perfect value. making it slightly imperfect');
    bef.p(idx)=0.01;
end;

if strcmpi(ratname,'Treebeard')
    2;
end;

loadpsychinfo(ratname, 'infile', [ratname '_psych_after'], ...
    'justgetdata',1,...
    'preflipped', preflipped, ...
    'psychthresh',psychthresh,...
    'ignore_trialtype', ignore_trialtype, ...
    'dstart',1, 'dend',2 , ...
    'eliminate_Mondays', 0,...
    'daily_bin_variability', 0, ...
    'graphic', 0,...
    'postpsych', postpsych, ...
    'ACxround1', acxflag);
origbins=bins;
if strcmpi(task(1:3),'dur')
    bins=log(bins);
    xrange = log([binmin binmax]);
else
    bins=log2(bins);
    xrange = log2([binmin binmax]);
end;
for a=1:length(alist)
    eval(['aft.' alist{a} '=' alist{a} ';'])
end;

if rows(replongs)>1
allreps = nansum(replongs); 
alltallies = nansum(tallies);
else
allreps = replongs;
alltallies = tallies;
end;
    aft.reps =allreps;
 aft.tallies = alltallies;
aft.p = allreps ./ alltallies; 
aft.xrange = xrange;

oldaftp = aft.p;

idx=find(aft.p>0.99);
if ~isempty(idx)
%     warning('FOund bin with perfect value. making it slightly imperfect');
    aft.p(idx)=0.99;
end;

idx=find(aft.p<0.01);
if ~isempty(idx)
% %     warning('FOund bin with perfect value. making it slightly imperfect');
    aft.p(idx)=0.01;
end;
blah=aft.p;

aft.sdp = (blah .* (1-blah)) ./alltallies;
aft.sdp = sqrt(aft.sdp);

tmp = replongs ./tallies;


ttypes={'bef','aft'};


for k=1:length(ttypes)
    ttype = ttypes{k};

    [s qlin qsig]=comparefits(eval([ttype '.bins']), ... 
         eval([ttype '.p']), ...
        eval([ttype '.sdp']), ...
        eval([ttype '.sigmoidfit']), ...
        eval([ttype '.linearfit']),...
       graphic, ...
        eval([ttype '.xrange']), ...
        eval([ttype '.xx']), ...
        eval([ttype '.yy']));
    
    fprintf(1,'Slope = %3.3f\n', s);
   
    
    b=normalizedbias(eval([ttype '.origbins']), mp, ...
    eval([ttype '.reps']), ...
    eval([ttype '.tallies']));
  
    eval([ttype '.slope=s;']);
    eval([ttype '.bias=b;']);
    eval([ttype '.qlin=qlin;']);
    eval([ttype '.qsig=qsig;']);
end;

 bstruct= [];
 astruct=[];
outp={'slope','bias','qlin','qsig'};
for k=1:length(outp)
    eval(['bstruct.' outp{k} '=bef.' outp{k} ';']);
        eval(['astruct.' outp{k} '=aft.' outp{k} ';']);
end;
bstruct.reps = bef.reps;
bstruct.tallies = bef.tallies;
bstruct.p = oldbefp;

astruct.reps = aft.reps;
astruct.tallies = aft.tallies;
astruct.p = oldaftp;


% -------------------------------------------
% SUBROUTINES
% -------------------------------------------


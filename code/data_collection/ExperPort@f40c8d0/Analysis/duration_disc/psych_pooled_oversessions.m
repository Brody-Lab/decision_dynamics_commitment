function [out] = psych_pooled_oversessions(ratname, varargin)
% Simple interface to access psych_oversessions.m, the script which pools
% psychometric data across sessions to give an aggregate psychometric curve
% Examples of use:
% psych_pooled_oversessions('Rucastle','use_dateset', 'given', 'given_dateset',{'080623a','080627a'},'daily_bin_variability',1)

pairs = { ...
    'daily_bin_variability', 0 ; ... % when true, shows the average daily replong value for each bin - the std shown is that of the daily replongs, not that of the pooled data.
    'from', '000000'; ...
    'to', '999999'; ...
    'given_dateset', {} ; ...
    'use_dateset','range'; ... % [range | given]
    'usefig', 0 ; ... % a figure handle if that's where you want the data plotted
    'removefigtag', 0 ; ... % empty tag of active figure if 1
    'justgetdata', 0 ; ...
    'suppress_calcpair', 0 ; ... % set to 1 to suppress output from calc_pair    
    'usefid', 1 ; ... % fid to fprintf to
    'no__tones_list', 0 ; ... % set to 1 for rats that don't have ChordSection_tones_list in their data set.
    };
parse_knownargs(varargin,pairs);

ratrow = rat_task_table(ratname);
task = ratrow{1,2};
numbins =8;

if strcmpi(use_dateset,'range')
    dateset = get_files(ratname, 'fromdate',from,'todate',to);
else
    dateset = given_dateset;
    from = dateset{1}; to = dateset{end};
end;

if strcmpi(task(1:3),'dur')
    leftf = 'dur_short'; rightf ='dur_long';
    ispitch=0;
     [l h]= calc_pair('d',sqrt(200*500),0.95,'suppress_out', suppress_calcpair);
    binmin = l; binmax= h;
    mult=1000;
    blockf='psych';
else
    leftf = 'pitch_low'; rightf='pitch_high';
    ispitch=1;
    mm = from(3:4);
    yy = from(1:2);
    if (str2double(yy) < 8) && (str2double(mm) < 29)
        [l h] = calc_pair('p',11.31,1.4);
    else
        [l h]= calc_pair('p',11.31,1);
    end;
    binmin =l; % 5.1
    binmax =h;%18.4; %17.6
    mult=1;
    blockf='pitch_psych';
end;

datafields = { 'blocks_switch', 'sides', 'flipped', 'tones_list', blockf};%leftf, rightf};

get_fields(ratname, 'use_dateset', 'given', 'given_dateset', dateset, ...
'datafields',datafields, 'suppress_out', 1, 'usefid', usefid);

% deal with the fields that were introduced in summer 07.
% blocks_switch, psych flag, flipped.
if sum(isnan(blocks_switch)) == length(blocks_switch)
    warning('%s:%s:blocks_switch all NaN\n', mfilename, ratname);
    blocks_switch=eval(blockf);
end;
    
if sum(isnan(flipped)) == length(flipped) % if flipped field doesn't exist  
    flipped = 0;                          % the rat wasn't flipped.
end;

% eval(['left_tone = ' leftf ';']);
% eval(['right_tone =' rightf ';']);

% remove bad data
cumtrials = cumsum(numtrials);
mega_badtrials = [];
new_numtrials = [];
for k = 1:length(cumtrials)
    sidx = 1; if k > 1, sidx = cumtrials(k-1)+1; end;
    eidx = cumtrials(k);
 
    tones = tones_list(sidx:eidx) * mult;

    btr = union(find(tones < binmin), find(tones > binmax));
    if ~isempty(btr)
        warning(sprintf('%s:%s:%s:%i trials with out-of-range tones!', mfilename, ratname, dates{k}));
        mega_badtrials = horzcat(mega_badtrials, (sidx-1)+btr);    
    end;
    new_numtrials(k) = numtrials(k) - length(btr);
end;

numtrials = new_numtrials;
oktrials = setdiff(1:length(tones_list), mega_badtrials);
flist = {'tones_list', 'blocks_switch','sides','hit_history'};

if length(flipped)>1 && sum(diff(flipped))~=0
        error('mixed flipped array')
end;

for f = 1:length(flist)
    try
    eval([flist{f} ' = ' flist{f} '(oktrials);']);
    catch
        error(sprintf('%s: filtering failed\n', flist{f}));
    end;
end;
% <<< end remove bad data

in={};
in.dates = dates;
in.numtrials = numtrials;
in.binmin=binmin;
in.binmax=binmax;

in.ltone=tones_list;
in.rtone=tones_list;
in.slist = sides;
in.psych_on = blocks_switch;
in.hit_history = hit_history;
in.flipped = flipped;



out = psych_oversessions(ratname,in, ...
    'justgetdata',0,'pitch', ispitch,...
    'num_bins', numbins,...
    'usefig', usefig, ...
    'justgetdata', justgetdata, ...
    'daily_bin_variability', daily_bin_variability,'plot_marker','.',...
    'usefid', usefid);

% % now put in overall_hrate, session_hrate

 validsess = [out.psychdates out.failedfit_dates];
 allsess = [validsess out.poolxclude_dates];
 hh =[]; % binary hit_history for valid sessions
 hh_avg = NaN(size(allsess));
 cumtrials=cumsum(numtrials);
 for n = 1:length(numtrials)
     if ismember(n, validsess)
     if n == 1, sidx = 1; else sidx = cumtrials(n-1) + 1; end;
     eidx = cumtrials(n);     
     curr = hit_history(sidx:eidx);
     bs = blocks_switch(sidx:eidx);
     curr = curr(bs > 0); % store only psych trials
     
     hh = horzcat(hh, curr);
     hh_avg(n) = sum(curr) / length(curr);
     end;
 end;

 out.session_hrate = hh_avg;
 out.overall_hrate = sum(hh) / length(hh);

incdates = [out.psychdates out.failedfit_dates];
if removefigtag > 0, set(usefig,'Tag', ''); end;

fprintf(usefid, '%s\n\tInput dates:\n\t\t', mfilename);
for k = 1:length(dates)
    fprintf(usefid, '%s ', dates{k});
end;
fprintf(usefid, '\n');

fprintf(usefid, '\tIncluded dates:\n\t\t');

if length(incdates) > 0
for k = 1:length(incdates)
    fprintf(usefid, '%s ', dates{incdates(k)});
end;
else
    fprintf(usefid, 'none');
end;

fprintf(usefid, '\n\tExcluded dates:\n\t\t');
tmp = out.poolxclude_dates;
if length(tmp) > 0
for k = 1:length(tmp)
    fprintf(usefid, '%s ', dates{tmp(k)});
end;
else
    fprintf(usefid, 'none');
end;
fprintf(usefid, '\n');

alldates = [incdates out.poolxclude_dates];
if rows(out.replongs) ~= length(alldates),
   error('%s:Mismatch between date vector and replong vector', mfilename);
end;


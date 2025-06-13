function [] = add_to_logdiff(ratname, task, date);

global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;
indir = [Solo_datadir filesep 'Data' filesep ratname filesep];
fname = [indir 'logdiff.mat'];
load(fname);
% got logdiff, hit_history, max_trials, logflag, psychflag,dates

% backup old data
fname_bkp = [indir 'logdiff_yesterday.mat'];
save(fname_bkp, 'dates','logdiff', 'hit_history','max_trials','logflag','psychflag');


% rename things that may interfere with variables in today's flie
% f_logdiff = logdiff;
% f_hit_history = hit_history;
% f_max_trials = max_trials;

load_datafile(ratname, task, date);

% sharpening stuff
lon = cell2mat(saved_history.ChordSection_vanilla_on);
pson = 0;
if strcmpi(task(1:3),'dur')
    pson = cell2mat(saved_history.ChordSection_psych_on);
else
    pson = cell2mat(saved_history.ChordSection_pitch_psych);
end;
ld = cell2mat(saved_history.ChordSection_logdiff);
hh = eval(['saved.' task '_hit_history']);
maxt = eval(['saved_history.' task '_Max_Trials']);
maxt = cell2mat(maxt); maxt = maxt(end);

idx = find(~isnan(hh));
maxt = length(idx);

hit_history = [hit_history hh(1:maxt)];
logdiff = [logdiff; ld(1:maxt)];
max_trials=[max_trials maxt];
logflag = [logflag; lon(1:maxt)];
psychflag = [psychflag; pson(1:maxt)];
dates{end+1} = date;

save(fname, 'dates','logdiff', 'hit_history','max_trials','logflag','psychflag');

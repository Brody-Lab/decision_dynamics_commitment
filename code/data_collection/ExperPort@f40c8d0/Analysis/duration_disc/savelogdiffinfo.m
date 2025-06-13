function [] = savelogdiffinfo(ratname, varargin)
% Saves data for all sessions where rat was sharpening.
% Gets the date range from the third column of the corresponding rat as in
% rat_Task_Table.m
pairs = { ...
    'outfile', 'logdiff_before' ; ...
    'trainphase', 'before';...    
    'experimenter', 'Shraddha'; ...
    };

parse_knownargs(varargin,pairs);

global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;

if strcmpi(trainphase,'before')
    date_col = rat_task_table('','action','get_prepsych_col');
    outfile = 'logdiff_before';
elseif strcmpi(trainphase,'after')
    date_col = rat_task_table('','action','get_postpsych_col');
    outfile = 'logdiff_after';
else
    date_col = rat_task_table('','action','get_sharp_col');
    outfile = 'logdiff';
end;

outdir = [Solo_datadir filesep 'Data' filesep];
if ~strcmpi(experimenter,'')
    outdir = [outdir experimenter filesep];
end;
outdir = [outdir ratname filesep];
    
fname = [outdir outfile '.mat'];
fprintf(1, 'Output file is:\n%s\n', fname);

if ~exist(outdir, 'dir'), error('Directory does not exist!:\n%s\n', outdir); end;

% look up dates for logdiff from rat table
ratrow = rat_task_table({ratname});
task = ratrow{1,2};

sdates = ratrow{1,date_col};
from = sdates{1}; to = sdates{2};
if strcmpi(to,'999999'),  to = yearmonthday;  end;


fprintf(1,'\tDates are from %s to %s...',from,to);
dates = get_files(ratname, 'fromdate', from, 'todate', to);

% idx = find(strcmpi(dates,'070409a'));
% Hack for Queen
%dates = vertcat(dates(1:idx-1), dates(idx+1:end));

if strcmpi(task(1:3),'dur')
    fields = {'logdiff','logflag','psych','left_prob', 'bbspl','events'};
else
    fields = {'logdiff','logflag','pitch_psych','left_prob','bbspl','events'};
end;
get_fields(ratname, 'task',task, 'from', from, 'to',to,'datafields',fields);
if strcmpi(task(1:3),'dur')
    psychflag = psych;
else
    psychflag = pitch_psych;
end;


save(fname, 'dates','logdiff', 'hit_history','numtrials','logflag','psychflag','left_prob','bbspl');



% for d = 1:rows(dates)
%     date = dates{d};
%     load_datafile(ratname,task,date);
%
%     % sharpening stuff
%     lon = cell2mat(saved_history.ChordSection_vanilla_on);
%     pson = 0;
%     if strcmpi(task(1:3),'dur')
%         pson = cell2mat(saved_history.ChordSection_psych_on);
%     else
%         pson = cell2mat(saved_history.ChordSection_pitch_psych);
%     end;
%     ld = cell2mat(saved_history.ChordSection_logdiff);
%     hh = eval(['saved.' task '_hit_history']);
%     maxt = eval(['saved_history.' task '_Max_Trials']);
%     maxt = cell2mat(maxt); maxt = maxt(end);
%
%     idx = find(~isnan(hh));
%     maxt = length(idx);
%
%     hit_history = [hit_history hh(1:maxt)];
%     logdiff = [logdiff; ld(1:maxt)];
%     max_trials=[max_trials maxt];
%     logflag = [logflag; lon(1:maxt)];
%     psychflag = [psychflag; pson(1:maxt)];
%     fprintf(1,'.');
% end;
%
% fprintf(1,'\n');
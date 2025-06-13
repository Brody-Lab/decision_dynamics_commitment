function [vanilla_hits psych_hits] = hitrate_breakdown(ratname, varargin)
% returns average hit rates for non-psychometric (vanilla) as well as
% psychometric trials
% 4 output params:
% 1) vanilla_hits: sx3 array where rows are sessions and columns are the
% average hit rate, sem hit rate, and # trials. For non-psychometric trials
% only.
% 2) psych_hits: sx3 array with same metrics as vanilla_hh except that these are for psychometric trials

pairs = { ...
    'binmin', 200 ; ...
    'binmax', 500 ; ...
    'infile', 'psych' ; ...
    'dstart', 1; ... % Use only session # 'dstart' to session 'dend'
    'dend', 1000; ...
    'lastfew', 1000; ...
    'experimenter','Shraddha';...
    'psychdates', {} ; ... % only these sessions will be used to compute psychometric hitrate
    };
parse_knownargs(varargin,pairs);


global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;
outdir = [Solo_datadir filesep 'Data' filesep experimenter filesep ratname filesep];
fname = [outdir infile '.mat'];

load(fname);

% if exist('events','var'),
%     sess_events = events;
% end;


% ------------------------------------------------------
% Optional preprocessing: Extract only first X sessions
% ------------------------------------------------------
     % -----------------------------------
    % Variables to filter a range of sessions
    % in your dataset >> BEGIN    
    dend = min(dend, rows(dates));
    cumtrials = cumsum(numtrials(1:dend));
    lastidx = cumtrials(end);
    startidx = 1;
    
    if lastfew < 1000
        lastfew = min(rows(dates), lastfew);
        dstart = rows(dates)-(lastfew-1);
    end;

    if dstart > 1
        startidx= cumtrials(dstart-1) +1;
    end;    
    fprintf(1,'*** %s: Date filter: Using %i to %i (%i to %i)\n', mfilename, dstart, dend, startidx, lastidx);
    % << END filtering session dates


dates = dates(dstart:dend);
numtrials = numtrials(dstart:dend);
cumtrials = cumsum(numtrials);

logdiff = logdiff(startidx:lastidx);
hit_history = hit_history(startidx:lastidx);
logflag = logflag(startidx:lastidx);
psychflag = psychflag(startidx:lastidx);
left_tone = left_tone(startidx:lastidx);
right_tone = right_tone(startidx:lastidx);
side_list = side_list(startidx:lastidx);
% sess_events = sess_events(startidx:lastidx);


%Fields are: 'dates','logdiff', 'hit_history','numtrials',
%'logflag','psychflag','left_tone','right_tone', 'side_list');

nonpsych = find(psychflag < 1);
psych = find(psychflag > 0);

vanilla_hits = {}; % each number in this array is the average of a session
psych_hits = {};

for sess = 1:length(numtrials)
    start_idx = 1;
    if sess > 1, start_idx = cumtrials(sess-1)+1; end;    
    end_idx = cumtrials(sess);

    % vanilla
    idx = intersect(nonpsych, start_idx:1:end_idx); % find all vanilla trials
    hh = hit_history(idx);
    vanilla_hits = vertcat(vanilla_hits, {mean(hh) std(hh)/sqrt(length(hh)) length(hh)});
    if sum(strcmpi(psychdates,dates{sess}))>0
        %psych
        idx = intersect(psych, start_idx:1:end_idx);
        hh = hit_history(idx);
        psych_hits = vertcat(psych_hits, {mean(hh) std(hh)/sqrt(length(hh)) length(hh)});
    end;
end;
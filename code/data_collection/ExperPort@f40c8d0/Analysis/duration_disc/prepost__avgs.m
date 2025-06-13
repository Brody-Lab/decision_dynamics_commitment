function [pre_out post_out pre_lastfew post_firstfew] = prepost__avgs(ratname, experimenter,varargin)
pairs = {...
    'pre_lastfew', 7;...
    'post_firstfew', 3 ; ...
    'trial_filter', 'all'; ... % which trials to return? [all|psych_only|nonpsych_only]
    };
parse_knownargs(varargin,pairs);

% prepare incase file needs to be loaded
global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;
outdir = [Solo_datadir filesep 'Data' filesep experimenter filesep ratname filesep];


% before
infile = 'psych_before';
fname = [outdir infile '.mat'];
load(fname);

% save only data from the last session
cumtrials = cumsum(numtrials);
fnames = {'hit_history', 'side_list', ...
    'left_tone','right_tone', ...
    'logdiff','logflag', 'psychflag'};
for f = 1:length(fnames)
    if length(cumtrials) <= pre_lastfew
        str=['pre_' fnames{f} ' = ' fnames{f} ';'];
    else
        str=['pre_' fnames{f} ' = ' fnames{f} '((cumtrials(end-pre_lastfew))+1:cumtrials(end));'];
    end;
    eval(str);
end;
lf = pre_lastfew-1;
if length(cumtrials) <= pre_lastfew
    pre_dates = dates;
    pre_numtrials = numtrials;
else
    pre_dates = dates(end-lf:end);
    pre_numtrials = numtrials(end-lf:end);
end;

% now load 'after' data
infile = 'psych_after';
fname = [outdir infile '.mat'];
load(fname);

fnames = {'hit_history', 'side_list', ...
    'left_tone','right_tone', ...
    'logdiff','logflag', 'psychflag'};

cumtrials = cumsum(numtrials);
for f = 1:length(fnames)
    str=[fnames{f} ' = ' fnames{f} '(1:cumtrials(post_firstfew));'];
    eval(str);
end;

dates = dates(1:post_firstfew);
numtrials = numtrials(1:post_firstfew);
[preavg pre_tallies]= sub__chunk_session_hrate(pre_dates, pre_numtrials, pre_psychflag, pre_hit_history,'trial_filter',trial_filter);
pre_out = {};
pre_out.session_hrate = preavg;
pre_out.session_numtrials = pre_numtrials;
pre_out.hrate_numtrials = pre_tallies;

post_out={};
[postavg post_tallies] = sub__chunk_session_hrate(dates, numtrials, psychflag, hit_history,'trial_filter',trial_filter);

post_out.session_hrate = postavg;
post_out.session_numtrials = numtrials;
post_out.hrate_numtrials = post_tallies;



function [set_out tallies] = sub__chunk_session_hrate(dates, numtrials, psych, hit_history,varargin)
pairs = {...
    'trial_filter', 'all'; ... % which trials to return? [all|psych_only|nonpsych_only]
    };
parse_knownargs(varargin,pairs);

trials_so_far = 0;
mean_hh=[]; tallies = [];

cumtrials = cumsum(numtrials);
for s = 1:length(dates)
    if s == 1, sidx = 1; else sidx = cumtrials(s-1)+1; end;
    eidx = cumtrials(s);

    % use only vars from current session before filtering
    curr_psych = psych(sidx:eidx);
    curr_hh = hit_history(sidx:eidx);
    switch trial_filter
        case 'all'
            idx = 1:length(curr_psych);
        case 'psych_only'
            idx = find(curr_psych>0);
        case 'nonpsych_only'
            idx = find(curr_psych ==0);
        otherwise
            error('invalid trial filter');
    end;
           
    %  idx = 1:length(curr_psych);
    mean_hh =  vertcat(mean_hh, mean(curr_hh(idx)));
    tallies = vertcat(tallies, length(idx));
end;

set_out = mean_hh;
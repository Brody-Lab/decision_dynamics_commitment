function [hrate last_few_pre] = hitrate_raw_xsessions_onerat(ratname,varargin)
% Plots session hitrate as a function of day before/after surgery.

pairs =  { ...
    'infile', 'psych' ; ... % name for output file. Default is: psych.mat
    'experimenter','Shraddha'; ...
    'from', '000000'; ...
    'to', '999999'; ...
    'given_dateset', {} ; ...
    'use_dateset',''; ... % [psych_before | psych_after | given | '' | span_surgery]
    % which data to use? Filter settings ------------------------------------
    'first_few', 3; ... % use data only from first X sessions
    %(note: if 'use_dataset' = 'span_surgery', this becomes X+1 sessions, counting first X of post + the last pre session)
    'psych_only', 2 ; ... % 0 = use nonpsych trials only; 1=use psych trials only; 2 = use nonpsych and psych
    % what to plot?

    };
parse_knownargs(varargin, pairs);
% get rat info and set up fields needed
ratrow = rat_task_table(ratname);
task = ratrow{1,2};

psychf='psych';left_stim ='dur_short';
right_stim ='dur_long';
if strcmpi(task(1:3),'dua')
    psychf='pitch_psych';
    left_stim = 'pitch_low';
    right_stim = 'pitch_high';
end;

datafields = {psychf,left_stim,right_stim,'sides'};


% ----------------------------------------------------------
% BEGIN Date set retrieving module: Use this piece of code to get either
% a pre-buffered date set, a range, or a specified date_set.
% To use this, have four switches in your 'pairs' cell array:
% 1 - 'vanilla_task' - binary; indicates whether rat was lesioned during
% vanilla task (1) or not (0)
% 2 - 'use_dateset' - specifies how to obtain dates to analyze
% 3 - infile - file from which to buffer (if different from psych_before
% and psych_after)
% 4 - experimenter - Shraddha


% prepare incase file needs to be loaded
global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;
outdir = [Solo_datadir filesep 'Data' filesep experimenter filesep ratname filesep];

last_few_pre=NaN; % how many days pre-surgery in this dataset?

switch use_dateset
    case 'psych_before'
        infile = 'psych_before';
        fname = [outdir infile '.mat'];
        load(fname);

        psych = psychflag;
        sides = side_list;
        %  dur_short = left_tone;
        %  dur_long = right_tone;
    case 'psych_after'
        infile = 'psych_after';
        fname = [outdir infile '.mat'];
        load(fname);

        psych = psychflag;
        sides = side_list;
        %  dur_short = left_tone;
        %  dur_long = right_tone;

    case 'given'
        get_fields(ratname,'use_dateset','given', 'given_dateset', given_dateset,'datafields',datafields);
        left_tone = eval(left_stim);
        right_tone = eval(right_stim);
        psych = eval(psychf);

    case ''
        get_fields(ratname,'from',from,'to',to,'datafields',datafields);
        left_tone = eval(left_stim);
        right_tone = eval(right_stim);
        psych = eval(psychf);

    case 'span_surgery'
        last_few_pre=5;
        first_few = first_few + last_few_pre; % 3 pre sessions & X post sessions = X+3;
        infile = 'psych_before';
        fname = [outdir infile '.mat'];
        load(fname);

        % save only data from the last session
        cumtrials = cumsum(numtrials);
        fnames = {'hit_history', 'side_list', ...
            'left_tone','right_tone', ...
            'logdiff','logflag', 'psychflag'};
        for f = 1:length(fnames)
            if length(cumtrials) <= last_few_pre
                str=['pre_' fnames{f} ' = ' fnames{f} ';'];
            else
                str=['pre_' fnames{f} ' = ' fnames{f} '((cumtrials(end-last_few_pre))+1:cumtrials(end));'];
            end;
            eval(str);
        end;
        lf = last_few_pre-1;
        if length(cumtrials) <= last_few_pre
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

        for f = 1:length(fnames)
            str=[fnames{f} ' = horzcat(pre_' fnames{f} ', ' fnames{f} ');'];
            eval(str);
        end;
        newdates = pre_dates;
        newdates(end+1:end+length(dates)) = dates;
        dates= newdates;
        numtrials = horzcat(pre_numtrials, numtrials);

        psych = psychflag;
    otherwise
        error('invalid use_dateset');
end;
% END Date set retrieving module
% ---------------------------------------------------------

2;

cumtrials = cumsum(numtrials);
first_few = min(length(numtrials), first_few);
trials_so_far = 0;

hrate=[];
for s = 1:first_few
    sidx = trials_so_far + 1;
    eidx = (sidx + numtrials(s))-1;
        
    curr_hh = hit_history(sidx:eidx);
    if numtrials(s) < 2, sem_hh = NaN; else sem_hh = std(curr_hh)/sqrt(numtrials(s)); end;
    hrate= vertcat(hrate, [mean(curr_hh) sem_hh]);
    
    trials_so_far = trials_so_far + numtrials(s);
end;

2;

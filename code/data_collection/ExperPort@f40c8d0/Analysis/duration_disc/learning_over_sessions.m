function [] = learning_over_sessions(ratname,varargin)
% Analysis: Hit rates over time within and across sessions
% examples:
%for a range of dates
pairs =  { ...
    'infile', 'psych' ; ... % name for output file. Default is: psych.mat
    'experimenter','Shraddha'; ...
    'vanilla_task', 0; ...  % set to 1 for those rats that were lesioned during steady state in discriminating a single stimulus pair
    'from', '000000'; ...
    'to', '999999'; ...
    'given_dateset', {} ; ...
    'use_dateset',''; ... % [psych_before | psych_after | given | '' | range | span_surgery]
    % which data to use? Filter settings ------------------------------------
    'first_few', 3; ... % use data only from first X sessions
    %(note: if 'use_dataset' = 'span_surgery', this becomes X+1 sessions, counting first X of post + the last pre session)
    'psych_only', 2 ; ... % 0 = use nonpsych trials only; 1=use psych trials only; 2 = use nonpsych and psych
    % what to plot?
    'showdates',0;... % if 1, shows dates atop performance
    
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


if vanilla_task
    date_set = ratrow{1,rat_task_table('','action','get_postpsych_col')};
    date_set2 = ratrow{1,rat_task_table('','action','get_prepsych_col')};
    dates = {date_set2{2}, date_set{end}};
    %get_fields(ratname,'use_dateset','given',
    %'given_dateset',dates,'datafields',datafields);

    get_fields(ratname,'use_dateset','range', 'from', dates{1}, 'to',dates{2}, 'datafields',datafields);
    psych = eval(psychf);
else
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
            
        case 'range'
            get_fields(ratname,'from',from,'to',to,'datafields',datafields);
            left_tone = eval(left_stim);
            right_tone = eval(right_stim);
            psych = eval(psychf);
        case 'span_surgery'
            last_few_pre=3;
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
end;
% END Date set retrieving module
% ---------------------------------------------------------

super_chunked = [];
trials_so_far = 0;
numchunks = [];
window= [];
mean_hh=[];
my_tally=[];
first_few = min(length(numtrials), first_few);

numtrials

for s = 1:first_few
    fprintf(1,'s=%i\n',s);
    sidx = trials_so_far + 1;
    eidx = (sidx + numtrials(s))-1;

    % use only vars from current session before filtering
    curr_psych = psych(sidx:eidx);
    curr_hh = hit_history(sidx:eidx);

    if psych_only == 1
        idx = find(curr_psych > 0);
    elseif psych_only == 2
        idx = 1:length(curr_psych);
    elseif psych_only == 0
        idx = find(curr_psych < 1);
        elsel
        error('psych_only can only be: 0, 1 or 2.');
    end;  

    out = hrate_over_time(curr_hh(idx));
    numt=0;
    if length(out.chunked_hh) == 0 % not a single chunk
        fprintf(1,'Ignoring %s; not enough chunks\n', dates{s});
        numchunks = horzcat(numchunks, length(out.chunked_hh));
        super_chunked{end+1} = [];
    else
        super_chunked{end+1} = out.chunked_hh;
        mean_hh = vertcat(mean_hh, out.overall_hh);
        trials_so_far = trials_so_far + numtrials(s);
        numchunks = horzcat(numchunks, length(out.chunked_hh));
        my_tally=vertcat(my_tally, out.tally);
        numt=numtrials(s);
        % fprintf('%s has %i trials and %i chunks\n',dates{s}, length(idx), numchunks(end));
    end;
end;
window = out.window; % window is the same for all so we can just pick the last one.

figure;
axes('Position',[0.05 0.12 0.9 0.78]);
chunks_so_far = 0;
valid=0;
prevdate = 0;
for k = 1:length(numchunks)
    fprintf(1,'%i: %i\n', k, chunks_so_far);
    if numchunks(k) == 0,
        %mp = mean([chunks_so_far  chunks_so_far+1]);
        line([chunks_so_far+0.5 chunks_so_far+0.5], [0 1],'LineStyle',':','Color','k');hold on;
        t=text(chunks_so_far+0.5, 0.55, 'NO DATA'); set(t,'FontSize',14,'Color','r', 'FontWeight','bold');
        chunks_so_far = chunks_so_far+50;
        line([chunks_so_far+0.5 chunks_so_far+0.5], [0 1],'LineStyle',':','Color','k');
    else        

        valid=valid+1;
        hh_chunk = super_chunked{k};

        start_chunk = chunks_so_far+1;
        end_chunk = (start_chunk + length(hh_chunk))-1;
        
        currdate = dates{valid}(1:6);
        fprintf(1,'\tDate is %s\n', currdate);
        if k > 1
            datediff = str2double(currdate) - str2double(prevdate);
            if datediff ~= 1
                if k==4, clr = [1 1 0.8]; else clr = [0.8 1 0.8]; end;
                patch([start_chunk start_chunk end_chunk end_chunk], ...
                    [0.52 0.98 0.98 0.52], clr,'EdgeColor','none');
            end;
        end;
        
        plot(start_chunk:end_chunk, hh_chunk, '-r');
        hold on;
        mp = mean([chunks_so_far  chunks_so_far+length(hh_chunk)]);
        chunks_so_far = chunks_so_far + length(hh_chunk);

        line([chunks_so_far+0.5 chunks_so_far+0.5], [0 1],'LineStyle',':','Color','k','LineWidth',2);

        datetmp = dates{valid}; datetmp = datetmp(3:6);

        if showdates > 0
            mytxt=sprintf('%i%%\n%s (%i)',round(mean_hh(valid,1)*100), [currdate(3:4) '/' currdate(5:6)], numtrials(k));
        else
        mytxt=sprintf('%i%%\n(%i)',round(mean_hh(valid,1)*100), numtrials(k));
        end;
        t=text(((start_chunk+end_chunk)/2), 1.02, mytxt);
        set(t,'FontWeight','bold','FontSize',11);

        prevdate = dates{valid}(1:6);
    end;
end;


line([0 chunks_so_far], [0.8 0.8], 'LineStyle',':','Color',[0.5 0.5 0.5]);
if (length(super_chunked) > 0)
    ck1 = length(super_chunked{1}) + length(super_chunked{2}) + length(super_chunked{3});
    line([ck1 ck1], [0 1],'Color','b', 'LineWidth',3);
end;
xl=xlabel(sprintf('Window of %i trials', window));
yl=ylabel('Hit rate (%)');
set(xl,'FontWeight','bold','FontSize',14);
set(yl,'FontWeight','bold','FontSize',14);
set(gca,'YLim',[0.5 1.1],'FontWeight','bold','FontSize',12,'XLim',[0 chunks_so_far+10]);
set(gca,'YTick',0:0.25:1, 'YTickLabel',0:25:100);
set(gcf,'Position',[300 500 1200 300],'Toolbar','none');
t=title(sprintf('%s: Success rate through the session on %s', ratname, dates{1}));
set(t,'FontWeight','bold','FontSize',14);

uicontrol('Tag', 'figname', 'Style','text', 'String', [ratname '_learningprogress_' use_dateset], 'Visible','off');

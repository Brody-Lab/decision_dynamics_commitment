
function [session_to pct_noto dates] = timeout_rate_oversessions(ratname,varargin)
% Plots # trials as a function of day before/after surgery.
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
    % special marks ------------------------
    'mark_special', []; ... % dates to mark in special colour
    'specialclr', [1 0 0];...
    % modifications of timeout rate: which one to plot? ----------
    'split_by_side', 1 ; ... % plot one series for 'LEFT' trial timeouts, and another for 'RIGHT'
        'mark_manips', 1; ... % when true, marks saline days as green and muscimol days as red
        % view options
        'graphic', 1 ; ...
        'rawdata_only', 0 ; ... % returns timeout count per trial as a cell array, one entry per session
    };
parse_knownargs(varargin, pairs);
% get rat info and set up fields needed
ratrow = rat_task_table(ratname);
task = ratrow{1,2};

datafields = {'pstruct','rts','sides'};

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

    case ''
        get_fields(ratname,'from',from,'to',to,'datafields',datafields);

    case 'span_surgery'
        last_few_pre=5;
        first_few = first_few + last_few_pre; % 3 pre sessions & X post sessions = X+3;
        infile = 'psych_before';
        fname = [outdir infile '.mat'];
        load(fname);

        % save only data from the last session
        cumtrials = cumsum(numtrials);
        fnames = {'hit_history', 'pstruct','rts','sides'};
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

        fnames = {'hit_history', 'pstruct','rts','sides'};
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

sidx=1;
eidx=1;
cumtrials = cumsum(numtrials);

to_array__left = NaN(size(numtrials));
to_array__right = NaN(size(numtrials));
session_to = [];
pct_noto = [];
to_count_cell = {};
for d = 1:length(numtrials)
    if d > 1, sidx = cumtrials(d-1)+1;end;
    eidx=cumtrials(d);

    fprintf(1,'%i: %i to %i\n', d, sidx, eidx);

    currevs=pstruct(sidx:eidx);
    currrts=rts(sidx:eidx);
    sl = sides(sidx:eidx);

    tcount = NaN;
    if length(currevs) > 0
        tcount = sub__timeout_count(currevs);
        leftt = find(sl==1);
        rightt=find(sl==0);
        
        to_array__left(d) = sum(tcount(leftt))/length(leftt);
        to_array__right(d)= sum(tcount(rightt))/length(rightt);
        session_to = horzcat(session_to, sum(tcount)/numtrials(d));
        pct_noto = horzcat(pct_noto, length(find(tcount == 0)) / numtrials(d));
        
    end;
    
    to_count_cell{end+1} = tcount;
    tcount = NaN;
end;

if rawdata_only > 0
    return;
end;

if graphic == 0, return; end;
%---------------------------------------------------------------------
% Plot "Average # timeouts / trial"

figure;
set(gcf,'Position',[56   574   600   198]);
msize = 24;

if split_by_side > 0
lcolor = [1 0 0];
rcolor = [1 0 0];

l=plot(to_array__left,'.b','MarkerSize',msize,'COlor', lcolor); hold on;
l=plot(to_array__right,'*b', 'MarkerSize',msize*0.6,'COlor', rcolor); hold on;
t=title(sprintf('%s: Timeout rate by trial side\n%s to %s', ratname, dates{1}, dates{end}));
legend({'LEFT', 'RIGHT'});
else    l=plot(session_to, '.b', 'MarkerSize', msize,'Color', [1 1 1] *0.3); hold on;
    t=title(sprintf('%s: Session-wide timeout rate\n%s to %s', ratname, dates{1}, dates{end}));   
    
    if mark_manips > 0
    can = rat_task_table(ratname, 'action', 'cannula__muscimol');
    tmparray = sub__markmanips(can, dates, session_to);
    l=plot(tmparray(:,1), tmparray(:,2),'.b','MarkerSize',msize,'Color', [1 0 0]);   
    
     can = rat_task_table(ratname, 'action', 'cannula__saline');
    tmparray = sub__markmanips(can, dates, session_to);
    l=plot(tmparray(:,1), tmparray(:,2),'.b','MarkerSize',msize,'Color', [0 1 0]);   
end;

end;
    
if length(mark_special) > 0
    plot(mark_special, to_array(mark_special), '.b','MarkerSize',msize,'COlor', specialclr);
end;
line([0 length(dates)+1], [1 1], 'LineStyle',':', 'Color', [1 0.5 0],'LineWidth',2);
line([0 length(dates)+1], [2 2], 'LineStyle',':', 'Color', [1 0 0],'LineWidth',2);

set(gca,'XTickLabel', sub__trimdates(dates),'XTick', 1:1:length(dates), 'XLim', [0 length(dates)+1]);
ymax = max(1, max(max(to_array__left), max(to_array__right))*1.2);
set(gca,'YLim',[0 ymax]);

t=xlabel('Day #');
t=ylabel('Avg # timeouts per trial');

axes__format(gca);
set(gca,'FontSize', 14);
set(gca,'Position',[0.1 0.17 0.8 0.7]);
set(gcf,'Position',[ 56         417        1118         355]);   

sign_fname(gcf,mfilename);


%---------------------------------------------------------------------
% Plot "Pct NO TO"

figure;
set(gcf,'Position',[200 200 600 200],'Toolbar','none','Menubar','none');
plot(pct_noto*100,'.b','MarkerSize',msize,'COlor', 'k');

set(gca,'XTickLabel', sub__trimdates(dates),'XTick', 1:1:length(dates), 'XLim', [0 length(dates)+1]);
set(gca,'YLim',[40 100],'YTick',50:25:100);

line([0 length(dates)+1], [50 50], 'LineStyle',':', 'Color', [1 0 0],'LineWidth',2);
line([0 length(dates)+1], [75 75], 'LineStyle',':', 'Color', [1 0 0],'LineWidth',2);


t=xlabel('Day #');
t=ylabel('% trials with no timeouts'); 
axes__format(gca);
set(get(gca,'YLabel'),'FontSize', 14);set(get(gca,'XLabel'),'FontSize', 14);
set(gca,'FontSize', 14);
set(gca,'Position',[0.1 0.17 0.8 0.7]);
t=title(sprintf('%s: % trials with no timeout\n%s to %s', ratname, dates{1}, dates{end}));
sign_fname(gcf,mfilename);




% ---------------------------------------------
% Subroutines
% ---------------------------------------------

%  returns # timeouts per trial in a given set of events
function [tcount] = sub__timeout_count(evs)
p = evs;
winsize = 15;

tcount = [];
for k = 1:rows(p)
    tcount = horzcat(tcount, rows(p{k}.timeout));
end;


function [trm] = sub__trimdates(dates)
trm = {};
for k = 1:length(dates)
    trm{end+1} = [dates{k}(3:4) '/' dates{k}(5:6)];
end;

% returns d-by-2 array of 
% 1) index # of dates with manipulation of interest
% 2) # trials in 90 minutes on that day
function [tmparray] = sub__markmanips(maniparray, dates, numt)
tmpd =maniparray(:,1);
tmparray=[];
for k = 1:length(tmpd)
    idx = find(strcmpi(dates, tmpd{k}));
    if ~isempty(idx)
        tmparray = vertcat(tmparray, [idx, numt(idx)]);
    end;
end;




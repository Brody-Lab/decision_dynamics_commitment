function [numtrials last_few_pre] = numtrials_oversessions(ratname,varargin)
% Plots # trials as a function of day before/after surgery.

pairs =  { ...
    'infile', 'psych' ; ... % name for output file. Default is: psych.mat
    'experimenter','Shraddha'; ... 
    'from', '000000'; ...
    'to', '999999'; ...
    'given_dateset', {} ; ...
    'use_dateset',''; ... % [psych_before | psych_after | given | '' | span_surgery]
    % which data to use? Filter settings ------------------------------------
    'lastfew', 7 ; ... % use data from last few X sessions
    'first_few', 3; ... % use data only from first X sessions
    %(note: if 'use_dataset' = 'span_surgery', this becomes X+1 sessions, counting first X of post + the last pre session)
    'psych_only', 2 ; ... % 0 = use nonpsych trials only; 1=use psych trials only; 2 = use nonpsych and psych
    'normal_session_length', 120; ... % the average session length is 90 minutes
    % what to plot?
    'mark_breaks', 1; ... % when true, marks dates following 1+days of break in purple
    'mark_manips', 1; ... % when true, marks saline days as green and muscimol days as red
    'close_rawnumtrials', 1; ... %when true, reports only # trials in 90 minutes.
    'graphic', 1 ; ... 
    };
parse_knownargs(varargin, pairs);
% get rat info and set up fields needed
ratrow = rat_task_table(ratname);
task = ratrow{1,2};

datafields = {'events_raw'};




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
savedir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep];
savef = [savedir 'numtrials_' ratname '_'];


last_few_pre=NaN; % how many days pre-surgery in this dataset?

switch use_dateset
    case 'psych_before'
        infile = 'psych_before';
        fname = [outdir infile '.mat'];
        load(fname);

        psych = psychflag;
        %  dur_short = left_tone;
        %  dur_long = right_tone;
    case 'psych_after'
        infile = 'psych_after';
        fname = [outdir infile '.mat'];
        load(fname);

        psych = psychflag;

        %  dur_short = left_tone;
        %  dur_long = right_tone;

    case 'given'
        savef=[savef 'given.mat'];       
        try 
            load(savef);
        catch
        get_fields(ratname,'use_dateset','given', 'given_dateset', given_dateset,'datafields',datafields);
        save(savef, 'dates','events_raw','numtrials');
        end;

    case ''
            savef=[savef from '_' to '.mat'];       
        try 
            load(savef);
        catch
            get_fields(ratname,'from',from,'to',to,'datafields',datafields);
            save(savef, 'dates','events_raw','numtrials');
        end;

    case 'span_surgery'
        last_few_pre=5;
        first_few = first_few + last_few_pre; % 3 pre sessions & X post sessions = X+3;
        infile = 'psych_before';
        fname = [outdir infile '.mat'];
        load(fname);

        % save only data from the last session
        cumtrials = cumsum(numtrials);
        fnames = {'hit_history', 'events_raw'};
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

        fnames = {'hit_history', 'events_raw'};
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

trials_so_far = 0;

% plot data
msize = 24;

%sessiondurs = sub__getdurs(events_raw,numtrials);

[lasttnum] = sub___limittime(events_raw, numtrials, normal_session_length);

 brkcolor = [0.5 0 1];
if mark_breaks > 0
    bidx = datebreaks(dates); bidx = find(bidx == 1);
end;

if graphic == 0
    return;
end;

% % Figure 1 --- Total # trials
% figure;
% set(gcf,'Position', [140 400 1000 310]);
% axes('Position', [0.08 0.15 0.9 0.7]);
% 
% ymax = (floor(max(numtrials)/50)+1)*50;
% for y = 50:50:ymax
%     line([0 length(numtrials)], [y y],'Color',[1 1 1]*0.7, 'LineWidth',2,'LineStyle',':');
%     hold on;
% end;
% 
% lcolor = [1 0.5 0];
% brkcolor = [0.5 0 1];
% l=plot(numtrials,'.b','MarkerSize',msize,'COlor', lcolor);
% 
% if mark_breaks > 0
%     bidx = datebreaks(dates); bidx = find(bidx == 1);
%  %   plot(bidx,numtrials(bidx), '.b', 'MarkerSize',msize,'COlor', brkcolor);
% end;

% 
% t=title(sprintf('%s: TOTAL # trials per session\n%s to %s', ratname, dates{1}, dates{end}));
% set(t,'FontSize',16,'FontWeight','bold');
% 
% xtk=2:2:length(numtrials);
% set(gca,'XTickLabel', dates(xtk),'XTick', xtk);
% set(gca,'YTick', 0:50:max(numtrials),'FontSize',16,'FontWeight','bold','YLim',[0 ymax]);
% t=xlabel('Day #');set(t,'FontSize',16,'FontWeight','bold');
% t=ylabel('# trials (session duration may vary)');set(t,'FontSize',16,'FontWeight','bold');
% 
% sign_fname(gcf, mfilename);
% 
% if close_rawnumtrials > 0
%     close gcf;
% end;

% Figure 2 --- # trials in 90 minutes
figure;

ymax = (floor(max(lasttnum)/50)+1)*50;
for y = 50:50:ymax
    line([0 length(numtrials)], [y y],'Color',[1 1 1]*0.7, 'LineWidth',2,'LineStyle',':');
    hold on;
end;
plot(lasttnum, '.k', 'MarkerSize',msize,'Color',[1 1 1]*0.3); hold on;

if mark_breaks > 0
    plot(bidx, lasttnum(bidx), '.b', 'MarkerSize',msize,'COlor', brkcolor);
end;

if mark_manips > 0    
    can = rat_task_table(ratname, 'action', 'cannula__muscimol');
    tmparray = sub__markmanips(can, dates, lasttnum);
    if ~isempty(tmparray)
        l=plot(tmparray(:,1), tmparray(:,2),'.b','MarkerSize',msize,'Color', [1 0 0]);
    end;

    can = rat_task_table(ratname, 'action', 'cannula__saline');
    tmparray = sub__markmanips(can, dates, lasttnum);
    if ~isempty(tmparray)
        l=plot(tmparray(:,1), tmparray(:,2),'.b','MarkerSize',msize,'Color', [0 1 0]);
    end;
end;



set(gca,'XTickLabel', sub__trimdates(dates),'XTick', 1:1:length(dates), 'XLim', [0 length(dates)+1]);
set(gca,'YTick', 0:50:max(numtrials),'FontSize',16,'FontWeight','bold','YLim',[0 ymax]);
xlabel('Session');
ylabel('# trials in 90 minutes');
title(sprintf('%s: # trials in %i minutes\n%s to %s', ratname, normal_session_length, dates{1}, dates{end}));
set(gcf,'Position',[ 124          30        1037         302]);

axes__format(gca);
set(gca,'FontSize', 14);
sign_fname(gcf, mfilename);



% ------------------------------------------------------------------------
% Subroutines
% ------------------------------------------------------------------------

function [trm] = sub__trimdates(dates)
trm = {};
sidx = 3; if length(dates) > 20, sidx = 4;end;
for k = 1:length(dates)
    
    trm{end+1} = [dates{k}(sidx:4) '/' dates{k}(5:6)];
end;

% returns d-by-2 array of
% 1) index # of dates with manipulation of interest
% 2) # trials in 90 minutes on that day
function [tmparray] = sub__markmanips(maniparray, dates, numt)
tmparray=[];
    if isempty(maniparray),return;end;
tmpd =maniparray(:,1);

for k = 1:length(tmpd)
    idx = find(strcmpi(dates, tmpd{k}));
    if ~isempty(idx)
        tmparray = vertcat(tmparray, [idx, numt(idx)]);
    end;
end;


% returns session duration in seconds
function [t]= sub__getdurs(events,numtrials)

cumtrials = cumsum(numtrials);
t=[];

for k = 1:length(numtrials)
    sidx = 1;
    if numtrials(k) > 0
        if k > 1, sidx = cumtrials(k-1)+1; end;
        eidx= cumtrials(k);

        evs = events(sidx:eidx);
        efirst = evs{1}; elast = evs{end};
        firsttime = efirst(1,3);
        lasttime = elast(end,3);
        t = horzcat(t, lasttime-firsttime);
    else
        t = horzcat(t, NaN);
    end;
end;

% returns the trial # of the last trial that ended under limmin minutes
function [idx_array] = sub___limittime(events, numtrials, limmin)
numsecs = limmin * 60;
%fprintf(1,'numsecs = %i\n', numsecs);
idx_array = NaN(size(numtrials));

cumtrials = cumsum(numtrials);
t=[];

for k = 1:length(numtrials)
    sidx = 1;
    if numtrials(k) > 0
        %  fprintf(1,'**********************\n');
        if k > 1, sidx = cumtrials(k-1)+1; end;
        eidx= cumtrials(k);
        evs = events(sidx:eidx);

        if k == length(numtrials) - 1
            2;
        end;
           
        
        firste = evs{1}; % first trial of this session
        laste = evs{end}; % last trial

        sessionstart = firste(1,3); % session starts with the first event of the 2nd trial

        %         fprintf(1,'%i: First trial started at %3.1f\n',k, tmpe(1,3));
        %         fprintf(1,'\t Session duration = %3.1f minutes\n', (laste(end,3) - tmpe(1,3))/60);
        %
        m = length(evs);
        foundit = 0;
        
        if m == 1
            idx_array(k) = m;
        end;

        while (m > 1) && (foundit < 1)
            currevs = evs{m};
            firsttime = currevs(1,3);
            if k == length(numtrials)-1
                fprintf(1,'\t#%i: %3.1f\n', m, (firsttime-sessionstart));
            end;
            if (firsttime-sessionstart) < numsecs
                idx_array(k) = m; % first trial, working backwards that starts under limmin minutes
                foundit = 1;
            else
                m=m-1;
            end;
        end;
    end;
end;



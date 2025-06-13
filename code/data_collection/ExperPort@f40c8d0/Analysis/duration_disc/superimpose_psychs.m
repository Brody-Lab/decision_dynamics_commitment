function [failed_dates dates] = superimpose_psychs(ratname,varargin)
% superimposes psychometric curves from individual sessions.
% examples of use:
% superimpose_psychs('Hare','use_dateset','given_set','given_dateset',{'070331a','070401a','070402a','070404a'});
% if you want each day's curve to be on a different figure, give the script
% an array of figure handles for the variable 'figlist'.

pairs = {...
    'psychthresh', 1 ; ...  % consider a session as being psychometric only if it has over psychthresh trials with the psych flag on
    'vanilla_task', 0 ; ...
    'experimenter','Shraddha' ; ...
    % Which dates to use? ---------------------
    'use_dateset', 'psych_before' ; ... % [psych_before | psych_after | given | span_surgery | '']
    'given_dateset', {} ; ... % when 'use_dateset' = given_set, this cell array should contain a set of dates (yymmdd) for which superimposed graphs will be plotted
    'from','000000';...
    'to', '999999';...
    'dstart', 1; ... % option to plot only session A to session B; this is where you set value for A...
    'dend', 1000; ... % and this is where you set value for B
    'lastfew', 1000; ... % option to plot only last X sessions
    % Which figure to plot on? -------------------------
    'usefig', 0 ; ... % if you want all curves to be plotted on a single figure you provide
    'figlist', [] ; ... % if you want different days to be plotted on different figures, make this an array; if not, leave it empty.

    % graph manipulations ------------------------------
    'align2zero', 0 ; ... % set to 1 if you want the 50% point to be at x=0.
    'forcecurvecolour', 0 ; ... % set to 1 to have all graphs be of the same colour. Colour used is specified by 'curvecolour'
    'curvecolour', 'r';...
    }; parse_knownargs(varargin,pairs);

% use examples:
% #1. Plot all psych curves from before on a new graph
% superimpose_psychs('Hare', 'use_dateset','psych_before');
% #2. Plot all psych curves from AFTER on a specified figure handle
% superimpose_psychs('Hare', 'use_dateset','psych_after','usefig', 1);
% (here, all graphs will be plotted on a figure with handle=1)
% #3. Plot only first 3 psych curves from AFTER, each on a different figure
% superimpose_psychs('Hare','use_dateset','psych_after', 'dend',3,
% 'figlist', [1 2 3]);
% (here, day 1 AFTER will be plotted on fig 1
%        day 2                      on fig 2
%        day 3                      on fig 3)

ratrow = rat_task_table(ratname);
task = ratrow{1,2};
if strcmpi(task(1:3),'dua'),
    pitch=1;
    [binmin binmax] = calc_pair('p',sqrt(8*16),1);
else
    pitch=0;
    binmin=200;
    binmax=500;
end;

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
% To use this, have two switches in your 'pairs' cell array:
% 1 - 'vanilla_task' - binary; indicates whether rat was lesioned during
% vanilla task (1) or not (0)
% 2 - 'use_dateset' - specifies how to obtain dates to analyze

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
        case 'psych_after'
            infile = 'psych_after';
            fname = [outdir infile '.mat'];
            load(fname);

            psych = psychflag;
            sides = side_list;


        case 'given'
            if cols(given_dateset) > 1, given_dateset = given_dateset'; end;
            dates = given_dateset;

        case ''
            dates = get_files(ratname, 'fromdate', from,'todate',to);

        case 'span_surgery'
            first_few = first_few + 1; % 1 pre session & X post sessions = X+1;
            infile = 'psych_before';
            fname = [outdir infile '.mat'];
            load(fname);

            % save only data from the last session
            cumtrials = cumsum(numtrials);
            fnames = {'hit_history', 'side_list', ...
                'left_tone','right_tone', ...
                'logdiff','logflag', 'psychflag'};
            for f = 1:length(fnames)
                str=['pre_' fnames{f} ' = ' fnames{f} '((cumtrials(end-1))+1:cumtrials(end));'];
                eval(str);
            end;
            pre_dates = dates{end};
            pre_numtrials = numtrials(end);

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
            newdates{1} = pre_dates;
            newdates(end+1:end+length(dates)) = dates;
            dates= newdates;
            numtrials = [pre_numtrials numtrials];

            psych = psychflag;
        otherwise
            error('invalid use_dateset');
    end;
end;
% END Date set retrieving module
% ---------------------------------------------------------

% Loading from pre-buffered file -------------------------------------
if strcmpi(use_dateset(1:5),'psych')
    in={};

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

    
     setidx=dstart:dend;
    

    in.ltone = left_tone(startidx:lastidx);
    in.rtone = right_tone(startidx:lastidx);
    in.psych_on = psychflag(startidx:lastidx);
    in.slist = side_list(startidx:lastidx);
    in.dates = dates(dstart:dend);
    in.hit_history = hit_history(startidx:lastidx);
    in.numtrials = numtrials(dstart:dend);
    in.binmin =binmin;
    in.binmax = binmax;

    dates = dates(dstart:dend);

    out = psych_oversessions(ratname, in,'pitch', pitch,'psychthresh',psychthresh);
    f = findobj('Tag', [ratname '_psych_curve']); close(f);
    fnames = fieldnames(out);
    for f=1:length(fnames)
        eval([ fnames{f} ' = out.' fnames{f} ';']);
    end;

    leftover = setdiff(1:length(xcomm), failed_dates);
    old_dates = dates;
    dates= dates(leftover);

    % print out failed dates
    fprintf(1,'----------------\n');
    fprintf(1,'Failed dates:\n');
    for f = 1:length(failed_dates)
        fprintf(1,'\t%s\n', old_dates{failed_dates(f)});
    end;
    fprintf(1,'----------------\n');

    % now plot

    % which figure to use?
    %    f=findobj('Tag',[ratname '_psych_curve']);
    if usefig > 0, set(0,'CurrentFigure', usefig); f = usefig;
    elseif ~isempty(figlist)
    else, f=figure;
    end;
    set(f,'Tag', 'blah');

    colourlist=[];
    r=0; % index for replong
    for d = 1:rows(old_dates)
        %        fprintf(1,'%s...\n',old_dates{d});
        if sum(ismember(failed_dates,d)) > 0
        else
            r=r+1;
            replong_today = replongs(r,:);
            tally_today = tallies(r,:);
            pct_today = replong_today ./tally_today;
            [xx yy] = logistic_fitter('get_interpolated', bins, pitch, betahat(r,:),pct_today,sqrt(bins(1)*bins(end)));

            if ~isempty(figlist),
                if length(figlist) < d
                    error('# figure handles in figlist should be equal to the # curves plotted');
                end;
                set(0,'CurrentFigure',figlist(d)); hold on;
                f= figlist(d);
            end;

            if forcecurvecolour > 0, currcolour = curvecolour;
            else currcolour=rand(1,3);end;

            if align2zero > 0
                midstim = logistic_fitter('get_midpoint', xx, yy);
                xx= xx-midstim;
            end;
            %            l=plot(bins(1:end-1), pct_today, '.r');
            %            set(l,'Color',currcolour);hold on;
            l=plot(xx,yy, '-r');
            set(l,'Color',currcolour,'LineWidth',2);hold on;
            colourlist = vertcat(colourlist, currcolour);
        end;
    end;

    assignin('caller','pooled_fit', overall_betahat);
    assignin('caller','weber_set1', weber);
    assignin('caller','pooled_replong', replongs);
    assignin('caller','pooled_tally', tallies);
    assignin('caller','psychdates',psychdates);
    assignin('caller','dates',dates);

    dates = old_dates;
    if strcmpi(task(1:3),'dur')
        bins = log(bins);
    else
        bins = log2(bins);
    end;
end;

% If we're not preloading from a file -------------------------------------
if strcmpi(use_dateset,'given') || strcmpi(use_dateset,'')
    % which figure to use?
    f=findobj('Tag',[ratname '_psych_curve']);
    if usefig > 0
        set(0,'CurrentFigure', usefig)
        f = usefig;
    elseif ~isempty(figlist)
    elseif isempty(f)
        f=figure;
    else
        set(0,'CurrentFigure',f);
    end;
    set(f,'Tag', 'blah');

    metrics = []; %weber, bias
    bin_list = [];
    failed_dates = [];
    colourlist=[];

    perday_replong=[];
    perday_tally=[];
    perday_betahat=[];

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
    
    for d = setidx
        tmp = dates{d}; prevtmp='';
        if d > 1, prevtmp = dates{d-1}; end;
        if strcmpi(tmp(1:end-1),prevtmp(1:end-1))
            warning('Potential duplicate: %s & %s found. Skipping %s.\n', prevtmp, tmp, tmp);
        else
            if forcecurvecolour > 0, currcolour = curvecolour;
            else currcolour=rand(1,3);end;

            if ~isempty(figlist),
                if length(figlist) < d
                    error('# figure handles in figlist should be equal to the # curves plotted');
                end;

                set(0,'CurrentFigure',figlist(d));
                f= figlist(d);
            end;

            [weber betahat bias xx yy xmid xcomm xfin replong tally]=psychometric_curve(ratname, 0, ...
                'usedate', tmp,'usefig', f, ...
                'plotcurveonly', 1,'curvecolour',currcolour, ...
                'suppress_stdout',1, 'align2zero', align2zero);%,curvecolour);
            hold on;
            if weber ~=-1
                metrics = vertcat(metrics, [weber bias]);
                if rows(bins) > 1, bins = bins'; end;
                bin_list =vertcat(bin_list, bins);
                colourlist = vertcat(colourlist, currcolour);

                perday_tally = vertcat(perday_tally, tally);
                perday_replong = vertcat(perday_replong, replong);

                if rows(betahat)>1, betahat =betahat'; end;
                perday_betahat = vertcat(perday_betahat,betahat);
            else
                failed_dates = horzcat(failed_dates,d);
            end;
        end;
    end;

    %     % % histogram of distributions
    %     figure; set(gcf,'Position', [200 200 350 200],'Toolbar','none','Tag','bias_hist');
    %     % subplot(1,2,1);
    %     % hist(metrics(:,1)); % plot webers.
    %     % xlabel('Weber ratio per session');
    %     % title(sprintf('%s: Session Weber distribution: %s', ratname, use_dateset));
    %     % subplot(1,2,2);
    %     hist(metrics(:,2)); % plot bias
    %     xlabel('Bias per session');
    %     title(sprintf('%s: Bias: %s', ratname, use_dateset));

    fprintf(1,'Failed dates:\n');
    for s = 1:length(failed_dates); fprintf(1,'\t%s\n', dates{s});end;

    assignin('caller', 'metrics',metrics);
    assignin('caller', 'failed_dates', failed_dates);
    assignin('caller','indie_replong',perday_replong);
    assignin('caller','indie_tally',perday_tally);
    assignin('caller','indie_fits', perday_betahat);

    bins = bin_list(1,:);
end;

if ~isfinite(bins) %|| isempty(bins), % absolutely no psych sessions found
    return;
end;


% label your axes
bins = bins(1:end-1);
xlim = [bins(1)*0.995 bins(end)*1.001];
if strcmpi(task(1:3),'dur')
    realbins = exp(bins);
else
    realbins = 2.^bins;
end;

%realbins = bins;
realbins = round((realbins*100)/100);
if align2zero
    xlim = xlim-midstim;
    bins = bins - midstim;
end;
if usefig ==0
    final_figlist = [];
    if isempty(figlist)
        final_figlist = [f];
    else
        final_figlist = figlist;
    end;

    for fidx = 1:length(final_figlist)
        set(0,'CurrentFigure',final_figlist(fidx));
        if strcmpi(task(1:3),'dur')
            %       set(gca,'XTick', bins,'XTickLabel',realbins);
            set(gca,'XTick',[]);
            set(gca,'XLim',xlim);
            xlabel('Duration (ms)');
        else
            %       set(gca,'XTick', bins,'XTickLabel',realbins);
            set(gca,'XTick',[]);
            set(gca,'XLim',xlim);
            xlabel('Frequency (KHz)');
        end;
        ylabel('% "Long"');
    end;
    if length(final_figlist) == 1
        title(sprintf('%s: Superimposed psych curves for %s', ratname, use_dateset));
    end;
end;

% plot colours for series
if forcecurvecolour == 0
    figure;
    plot(0,0,'.k'); c=1;
    for d = 1:rows(dates)
        t=text(1, d, dates{d});
        if sum(ismember(failed_dates, d)) ==0
            set(t,'Color', colourlist(c,:),'FontSize',12); c=c+1;
        else
            set(t,'Color','r','FontWeight','bold','FontSize',12);
        end;
    end;
    title('Colours used for various dates');
    set(gca,'YLim',[0 rows(dates)+1],'XLim',[0.95 2]);
    set(gcf,'Position',[100 100 100 300],'Toolbar','none');
end;

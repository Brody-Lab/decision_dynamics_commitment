function [] = psychnums_over_time(ratname,varargin)
% Plots 25,50,75 percent points on a rat's psych curve over a specified
% period of time.
% sample use
% psychnums_over_time('Hatty','use_dateset','','from','080315','to','999999')

[l h] = calc_pair('p', sqrt(8*16), 1,'suppress_out', 1);
[l2 h2] = calc_pair('d', sqrt(200*500), 0.95,'suppress_out', 1);

pairs = {...
    'psychthresh', 1 ; ...  % consider a session as being psychometric only if it has over psychthresh trials with the psych flag on
    'vanilla_task', 0 ; ...
    'experimenter','Shraddha' ; ...
    % Which dates to use? ---------------------
    'use_dateset', '' ; ... % [psych_before | psych_after | given | span_surgery | '']
    'last_few_pre', 5; ...
    'given_dateset', {} ; ... % when 'use_dateset' = given_set, this cell array should contain a set of dates (yymmdd) for which superimposed graphs will be plotted
    'from','000000';...
    'to', '999999';...
    'dstart', 1; ... % option to plot only session A to session B; this is where you set value for A...
    'dend', 1000; ... % and this is where you set value for B
    'lastfew', 1000; ... % option to plot only last X sessions
    'first_few', 3; ...
    % Plotting & Plot appearance -------------------------
    'usefig', 0 ; ... % if you want all curves to be plotted on a single figure you provide
    'mark_breaks', 1; ... % when 'true', marks data following 1+ day of break
    'mark_manips', 1; ... % when 'true', marks saline days in green and muscimol days in red
    % Save data? ---------------------------------------
    'mkover', 0 ; ... % set to 1 to save data in rat's data file under name "psychnums.mat"
    }; parse_knownargs(varargin,pairs);

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

psychf='psych';
if strcmpi(task(1:3),'dua')
    psychf='pitch_psych';
end;

datafields = {psychf};

if mkover == 0
    outdir = Shraddha_filepath(ratname, 'd');
    load([outdir{1} 'psychnums.mat']);
else

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
            case 'psych_after'
                infile = 'psych_after';
                fname = [outdir infile '.mat'];
                load(fname);
                psych = psychflag;

            case 'given'
                if cols(given_dateset) > 1, given_dateset = given_dateset'; end;
                dates = given_dateset;

            case ''
                dates=get_files(ratname,'fromdate',from,'todate',to);

            case 'span_surgery'
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

    final__xcomm = [];
    final__xmid = [];
    final__xfin = [];
    final__weber= [];
    final__min = [];
    final__max = [];
    

    % If we're not preloading from a file -------------------------------------
    if strcmpi(use_dateset,'given') || strcmpi(use_dateset,'')

        % -----------------------------------
        % Variables to filter a range of sessions
        % in your dataset >> BEGIN
        dend = min(dend, rows(dates));
        failed_dates = [];

        if lastfew < 1000
            lastfew = min(rows(dates), lastfew);
            dstart = rows(dates)-(lastfew-1);
        end;

        if dstart > 1
            startidx= cumtrials(dstart-1) +1;
        end;
        %   fprintf(1,'*** %s: Date filter: Using %i to %i (%i to %i)\n', mfilename, dstart, dend, startidx, lastidx);
        setidx=dstart:dend;
        % << END filtering session dates

        for d = setidx
            tmp = dates{d}; prevtmp='';
            if d > 1, prevtmp = dates{d-1}; end;
            if strcmpi(tmp(1:end-1),prevtmp(1:end-1))
                warning('Potential duplicate: %s & %s found. Skipping %s.\n', prevtmp, tmp, tmp);
            else
                [weber betahat bias xx yy xmid xcomm xfin replong tally bins]=psychometric_curve(ratname, 0, ...
                    'usedate', tmp, 'noplot', 1, 'suppress_stdout',1);
            %    hold on;

                if weber ==-1
                    failed_dates = horzcat(failed_dates,d);
                    final__xcomm = horzcat(final__xcomm,NaN);
                    final__xmid = horzcat(final__xmid ,NaN);
                    final__xfin = horzcat(final__xfin,NaN);
                    final__weber= horzcat(final__weber,NaN);
                                        final__min= horzcat(final__min,NaN);  final__max= horzcat(final__max,NaN);
                else
                    final__xcomm = horzcat(final__xcomm,xcomm);
                    final__xmid = horzcat(final__xmid ,xmid);
                    final__xfin = horzcat(final__xfin,xfin);
                    final__weber= horzcat(final__weber,weber);
                     final__min= horzcat(final__min,replong(1)/tally(1));  final__max= horzcat(final__max,replong(end)/tally(end));
                end;
            end;
        end;

        if strcmpi(task(1:3),'dua')
            final__xcomm = log2(final__xcomm);
            final__xmid = log2(final__xmid);
            final__xfin = log2(final__xfin);
         
        else
            final__xcomm = log(final__xcomm);
            final__xmid = log(final__xmid);
            final__xfin = log(final__xfin);
       
        end;
        % Loading from pre-buffered file -------------------------------------
    else %strcmpi(use_dateset(1:5),'psych')
        in={};

        % -----------------------------------
        % Variables to filter a range of sessions
        % in your dataset >> BEGIN
        dend = min(dend, length(dates));
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

        out = psych_oversessions_better(ratname, in,'pitch', pitch,'psychthresh',psychthresh,'noplot',1);
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

        final__xcomm = xcomm;
        final__xmid = xmid;
        final__xfin = xfin;
        final__weber= weber;
    end;

    outdir = Shraddha_filepath(ratname, 'd');
    save([outdir{1} 'psychnums.mat'], 'final__xcomm', 'final__xfin','final__xmid', 'final__min', 'final__max', 'weber','bins','dates');
end;

[ax1 ax2] = sub__plotpsychnum(final__min, final__max, final__xcomm, final__xfin, final__xmid, weber,dates,task,mark_breaks,mark_manips, ratname);
if strcmpi(task(1:3),'dua')
    ytk = log2(bins);
    ytklbl = round(bins * 10)/10;
    ylim = log2([binmin binmax]);
    mp = log2(sqrt(binmin*binmax));
else
    ytk = log(bins);
    ytklbl = round(bins);
    ylim = log([binmin binmax]);
    mp = log(sqrt(binmin*binmax));
end;

if strcmpi(use_dateset,'span_surgery')
    line([last_few_pre+0.5 last_few_pre+0.5], ylim, 'LineStyle',':','Color', [0.3 0.3 0.3],'LineWidth',2);
end;

line([0 length(final__xcomm)+1], [mp mp], 'LineStyle',':','Color', [0.3 0.3 0.3],'LineWidth',2);

%text(0.3,sqrt(ytk(end-3)*ytk(end-2)), 'LEFT bias','FontWeight','bold','FontAngle','italic','FontSize',14);
%text(0.3, sqrt(ytk(3)*ytk(4)), 'RIGHT bias','FontWeight','bold','FontAngle','italic','FontSize',14);

t=title(sprintf('%s: 25,50,75%% points on psych curve\n%s to %s', ratname, dates{1}, dates{end}));
set(t,'FontSize',16,'FontWeight','bold');

set(gca,'YTick',ytk,'YTickLabel', ytklbl,'YLim', ylim,'XLim', [0 length(final__xcomm)+1]);
% final__xcomm = mybase.^final__xcomm;
% final__xmid = mybase.^final__xmid;
% final__xfin = mybase.^final__xfin;

sign_fname(gcf,mfilename);


% ---------------------------------------------------------
% Subroutines
% ---------------------------------------------------------
function [ax1 ax2] = sub__plotpsychnum(mn, mx, xc, xf, xm, wb,dates,tsk, markbreak,mark_manips,ratname)
msize = 24;
lcolor = [103 106 154] ./255;

if strcmpi(tsk(1:3),'dua')
    ylbl = 'Frequency (kHz)';
    ylbl2 = 'High';
else
    ylbl = 'Duration (ms)';
    ylbl2 = 'Long';
end;

figure;

set(gcf,'Position', [140 400 1000 310]);
axes('Position', [0.08 0.15 0.86 0.7]);
grey = [1 1 1] * 0.5;
newr = [1 0.4 0.4];

% plot 25,50,75 points
l=plot(xc,'+b','MarkerSize',msize*0.5,'COlor', grey); hold on;
plot(xm,'.b','MarkerSize',msize,'COlor', grey);
% plot second axis
[ax h1 h2] = plotyy(1:length(xf), xf, 1:length(mn), mn); 

set(h1, 'Marker','*','MarkerSize',msize*0.7,'Color', grey,'LineStyle','none');
set(h2, 'Marker', '.', 'MarkerSize', msize*0.75','Color',newr,'LineStyle','none');

ax1 = ax(1); ax2 = ax(2); hold on;
set(gcf,'CurrentAxes',ax2); hold on;

plot(ax2, 1:length(mx), mx,'.', 'MarkerSize', msize*0.75','Color',newr,'LineStyle','none');
line([0 length(mx)+1], [0.1 0.1], 'Color', newr,'LineWidth',2,'LineStyle',':'); 
text( length(mx)+0.5, 0.15, '10%','FontAngle','italic','FontWeight','bold','FontSize',14,'Color',newr); 
line([0 length(mx)+1], [0.9 0.9], 'Color', newr,'LineWidth',2,'LineStyle',':'); 
text( length(mx)+0.5, 0.85, '90%','FontAngle','italic','FontWeight','bold','FontSize',14,'Color',newr); 

set(gcf,'CurrentAxes',ax1); hold on;

% if markbreak > 0 && length(dates) > 1 % mark data following break in different colour
%     bcolor = [1 1 1] * 0;
%     isbreak = datebreaks(dates);
%     bidx = find(isbreak == 1);
%     plot(ax1,bidx,xc(bidx),'.b','MarkerSize',msize,'COlor', bcolor);
%     plot(ax1,bidx,xf(bidx),'.b','MarkerSize',msize,'COlor', bcolor);
%     plot(ax1,bidx,xm(bidx),'.b','MarkerSize',msize,'COlor', bcolor);
% end;

if mark_manips > 0
    scolor = [0 1 0]; mcolor =[1 0 0];

    can = rat_task_table(ratname, 'action', 'cannula__saline');
    tmparray = sub__markmanips(can, dates);
    if ~isempty(tmparray)
        l=plot(ax1,tmparray, xc(tmparray),'.b','MarkerSize',msize,'Color', scolor);
        l=plot(ax1,tmparray, xf(tmparray),'.b','MarkerSize',msize,'Color', scolor);
        l=plot(ax1,tmparray, xm(tmparray),'.b','MarkerSize',msize,'Color', scolor);

    end;
    
     can = rat_task_table(ratname, 'action', 'cannula__muscimol');
    tmparray = sub__markmanips(can, dates);
    if ~isempty(tmparray)
        l=plot(ax1,tmparray, xc(tmparray),'.b','MarkerSize',msize,'Color', mcolor);
        l=plot(ax1,tmparray, xf(tmparray),'.b','MarkerSize',msize,'Color', mcolor);
        l=plot(ax1,tmparray, xm(tmparray),'.b','MarkerSize',msize,'Color', mcolor);
    end;

    %     can = rat_task_table(ratname, 'action', 'cannula__saline');
    %     tmparray = sub__markmanips(can, dates, lasttnum);
    %     if ~isempty(tmparray)
    %         l=plot(tmparray(:,1), tmparray(:,2),'.b','MarkerSize',msize,'Color', [0 1 0]);
    %     end;
end;


set(ax1,'FontSize',16,'FontWeight','bold');
set(ax2,'FontSize',16,'FontWeight','bold','FontAngle','italic');

set(ax1,'XLim',[0 length(xf)+1],'XTick',1:1:length(dates),'XTickLabel', sub__trimdates(dates));
set(ax2,'XLim',[0 length(xf)+1],'XTick',1:1:length(dates),'XTickLabel', {});
set(ax2,'YLim',[0 1], 'YTick',0:0.2:1,'YTickLabel',0:20:100);
subdates={};

xlabel('Day#');
ylabel(ax1,ylbl);

ylabel(ax2,['Min/Max % ' ylbl2]);
set(get(ax1,'XLabel'),'FontSize',16,'FontWeight','bold');
set(get(ax1,'YLabel'),'FontSize',16,'FontWeight','bold');

set(get(ax2,'XLabel'),'FontSize',16,'FontWeight','bold','Color','k');
set(get(ax2,'YLabel'),'FontSize',16,'FontWeight','bold','Color','r','FontAngle','italic');


set(ax2,'YColor','r');
set(ax1,'YColor','k');


function [trm] = sub__trimdates(dates)
trm = {};
sidx = 3; if length(dates) > 20, sidx = 4;end;
for k = 1:length(dates)

    trm{end+1} = [dates{k}(sidx:4) '/' dates{k}(5:6)];
end;

% returns d-by-2 array of
% 1) index # of dates with manipulation of interest
% 2) # trials in 90 minutes on that day
function [tmparray] = sub__markmanips(maniparray, dates)
tmparray=[];
if isempty(maniparray),return;end;
tmpd =maniparray(:,1);

for k = 1:length(tmpd)
    idx = find(strcmpi(dates, tmpd{k}));
    if ~isempty(idx)
        tmparray = vertcat(tmparray, idx);
    end;
end;


function [dateset avgx avgy err binvals set_bins] = psychfits_oversessions(ratname, varargin)
pairs = { ...
    'use_dateset', 'psych_before' ; ... % [psych_before | psych_after | given | span_surgery | '']
    'last_few_pre', 5; ...
    'given_dateset', {} ; ... % when 'use_dateset' = given_set, this cell array should contain a set of dates (yymmdd) for which superimposed graphs will be plotted
    'from','000000';...
    'to', '999999';...
    'dstart', 1; ... % option to plot only session A to session B; this is where you set value for A...
    'dend', 1000; ... % and this is where you set value for B
    'lastfew', 1000; ... % option to plot only last X sessions
    'first_few', 3; ...
    'num_bins', 8 ; ...
    % --- How to plot data? ------------------------------------
    'color__range', 0 ; ... % plots psychometric curves in dark_to_light shade of the same colour.
    'colorrange_colour', [0 0 0.2]; % default is blue
    'plot_separately', 0 ; ... % plots each day's psych curve on a separate figure
    % --- Plot anything underneath the data? -------------------
    'underplot', 0 ; ...
    'underplot__pts', 0 ; ...
    'underplot__errbar', 0 ; ...    
    };
parse_knownargs(varargin,pairs);

ratrow = rat_task_table(ratname,'get_rat_row');

% Implement use_dateset to get the right dateset for which to buffer
% psychometric fit data over sessions.
% ----------------------------------------------------------
% BEGIN Date set retrieving module: Use this piece of code to get either
% a pre-buffered date set, a range, or a specified date_set.
% To use this, have two switches in your 'pairs' cell array:
% 1 - 'vanilla_task' - binary; indicates whether rat was lesioned during
% vanilla task (1) or not (0)
% 2 - 'use_dateset' - specifies how to obtain dates to analyze


switch use_dateset
    case 'psych_before'
        dates =  ratrow{4};
        dateset = get_files(ratname, 'fromdate', dates{1}, 'todate', dates{2});

        lf = last_few_pre-1;
        if length(dateset) > lf+1
            dateset = dateset(end-lf:end);
        else
            last_few_pre = length(dateset);
        end;
    case 'psych_after'
        dates =  ratrow{5};
        dateset = get_files(ratname, 'fromdate', dates{1}, 'todate', dates{2});
    case 'given'
        if cols(given_dateset) > 1, given_dateset = given_dateset'; end;
        dateset = given_dateset;
    case ''
        dateset=get_files(ratname,'fromdate',from,'todate',to);

    case 'span_surgery'
        first_few = first_few + last_few_pre; % 3 pre sessions & X post sessions = X+3;

        dates_pre = ratrow{4};
        lf= last_few_pre-1;
        myfiles = get_files(ratname, 'fromdate', dates{1}, 'todate', dates{2});
        dates_pre = myfiles(end-lf:end);

        dates_post = ratrow{5};
        myfiles = get_files(ratname, 'fromdate', dates{1}, 'todate', dates{2});
        dateset = vertcat(dates_pre, myfiles);
    otherwise
        error('invalid use_dateset');
end;
% END Date set retrieving module
% ---------------------------------------------------------

dateset

ratrow = rat_task_table(ratname);
task = ratrow{1,2};

if strcmpi(task(1:3),'dur')
    b=[200 316 500]; lb = log(b);
    mp = sqrt(200*500);
    logmp = log(mp);
    ispitch = 0;
else
    mp = sqrt(8*16);
    b = [8 mp 16]; lb = log2(b);
    logmp = log2(mp);
    ispitch =1;
end;

psych_data = {};
if plot_separately == 0
    figure;

    if underplot > 0
        if ~isempty(underplot__errbar)
            xdata = get(underplot__errbar, 'XData');
            ydata = get(underplot__errbar, 'YData');
            ldata = get(underplot__errbar, 'LData');
            udata = get(underplot__errbar, 'UData');
            lsize = get(underplot__errbar, 'LineWidth');
            msize = get(underplot__errbar, 'MarkerSize');
            clr = get(underplot__errbar, 'Color');
            errorbar(xdata,ydata, ldata,udata, ...
                'Color', clr, 'MarkerSize', msize,'LineWidth', lsize);
            hold on;
        end;

        if ~isempty(underplot__pts)
            xdata = get(underplot__pts, 'XData');
            ydata = get(underplot__pts, 'YData');
            msize = get(underplot__pts, 'MarkerSize');
            clr = get(underplot__pts, 'Color');
            plot(xdata,ydata, '.r', 'Color', clr, 'MarkerSize', msize);
            hold on;
        end;
    end;
end;

newdateset = {}; % keep only dates with valid psych fits
excludateset = {}; % list of dates that were excluded because of low trial count
sumreplongs = zeros(1,num_bins);
sumtallies = zeros(1,num_bins);
set_bins = [];

for d = 1:length(dateset)
    if plot_separately > 0, figure;
        if underplot > 0
            if ~isempty(underplot__errbar)
                xdata = get(underplot__errbar, 'XData');
                ydata = get(underplot__errbar, 'YData');
                ldata = get(underplot__errbar, 'LData');
                udata = get(underplot__errbar, 'UData');
                lsize = get(underplot__errbar, 'LineWidth');
                msize = get(underplot__errbar, 'MarkerSize');
                clr = get(underplot__errbar, 'Color');
                errorbar(xdata,ydata, ldata,udata, ...
                    'Color', clr, 'MarkerSize', msize,'LineWidth', lsize);
                hold on;
            end;
            if ~isempty(underplot__pts)
                xdata = get(underplot__pts, 'XData');
                ydata = get(underplot__pts, 'YData');
                msize = get(underplot__pts, 'MarkerSize');
                clr = get(underplot__pts, 'Color');
                plot(xdata,ydata, '.r', 'Color', clr, 'MarkerSize', msize);
                hold on;
            end;
        end;
    end;
    if color__range >0
        mult = 0.12*d;
        firstone = min(1,colorrange_colour(3)+mult);
        clr = [colorrange_colour(1:2)+mult firstone];
    else
        clr = rand(1,3);
    end;

    
    [weber bfit bias xx yy xmid xcomm xfin replong tally bins] = ...
        psychometric_curve(ratname,0,'usedate', dateset{d},'noplot', 1, 'suppress_stdout',1);

    set_bins = bins;

    fnames = {'weber', 'bfit', 'bias', 'xx', 'yy', 'xmid', 'xcomm' ,'xfin' ,'replong', 'tally','bins'};

    empty_bins = find(tally < 1);
    
    if ~isempty(empty_bins)
        fprintf(1,'*** Warning: %s was excluded!\n', dateset{d});
                
                excludateset{end+1} = dateset{d};
    else        
        newdateset{end+1}= dateset{d};
        eval(['psych_data.date' num2str(d) ' = 0;']);

        for f = 1:length(fnames)
            eval(['psych_data.date' num2str(d) '.' fnames{f} ' = ' fnames{f} ';']);
        end;
        sumreplongs = replong + sumreplongs;
        sumtallies = tally + sumtallies;
        
        if abs(sum(set_bins - bins)) > 0
            error('Bins are changing from day to day. Now why should this be?');
        end;
        set_bins = bins;

        plot(xx,yy,'.r','Color',clr); hold on;

        if plot_separately > 0
            set(gca,'YLim',[0 1],'XLim', [lb(1) lb(3)], 'XTick', lb,'XTickLabel', b);
            legend(dateset{d},'Location', 'SouthEast');
        end;
    end;
end;

dateset = newdateset;

set(gca,'YLim',[0 1],'XLim', [lb(1) lb(3)], 'XTick', lb,'XTickLabel', b);
if plot_separately == 0
    legend(dateset,'Location', 'SouthEast');
else
    figure__tile(250,200,'left2right');
end;

% Don't extrapolate because we're not going to normalize -- this is one's
% rats's variation so we shouldn't have to get shift/scale parameters for
% each day.
%figure;
%sub__plotset(extrapol_data, dateset);

[extrapol_data] = sub__extrapolatebig(psych_data, ispitch, mp);
interpol_data= sub__interpolate(extrapol_data, logmp);

[avgx avgy err] = sub__average(interpol_data);

binvals = sumreplongs ./ sumtallies;

% l=errorbar(avgx, avgy, err, err,'.b');
% set(l,'Color',[0.8 0.8 0.8],'LineWidth',1,'MarkerSize',2);
% plot(x, avgy, '.k');

if ~isempty(excludateset)
fprintf(1,'*****\nEXCLUDED DATES:\n');
for k=1:length(excludateset), fprintf(1,'\t%s\n',excludateset{k}); end;
fprintf(1,'*****\n');
end;

%--------------------------------------------------------------------
% Subroutines
%--------------------------------------------------------------------
function [data] = sub__extrapolatebig(data,ispitch, bin_midpoint)
fnames = fieldnames(data);
for f = 1:length(fnames)
    ratname = fnames{f};
    eval(['out = data.' ratname ';']);
    xx = out.xx;
    rangex = max(xx) - min(xx);
    [newxx newyy] = logistic_fitter('get_interpolated', out.bins, ispitch, ...
        out.bfit, NaN, bin_midpoint,...
        min(xx) - (0.5*rangex) : 0.0002 : max(xx) + (0.5*rangex));
    out.xx = newxx;
    out.yy = newyy;
    eval(['data.' ratname ' = out;']);
end;

%
%
% average over the columns of y-entries
function [x avgy err] = sub__average(data)
fnames = fieldnames(data);

firstrat = fnames{1};
eval(['out = data.' firstrat ';']);
y = out.newyy;
if rows(y)> 1, y = y'; end;
avgy=y;

for f = 1:length(fnames)
    ratname = fnames{f};
    eval(['out = data.' ratname ';']);
    curryy = out.newyy; if rows(curryy)> 1, curryy = curryy'; end;
    avgy = vertcat(avgy, curryy);
    x=out.newxx;
end;
err = std(avgy) ./ rows(avgy);
avgy = mean(avgy);

% given a collection of xx and yy pairs with disparate x-axes values, find
% an x-axis to which all old xx-yy values can be commonly interpolated
% preparation for averaging
function [data1] =  sub__interpolate(data1,mp)
bufferx = [];
lastx = [];
olddata1=data1;

fnames = fieldnames(data1);

largestofmin = 0;
smallestofmax = +1000;
minnie = +1000; maxie = -1000;
for f = 1:length(fnames)
    ratname = fnames{f};
    eval(['out = data1.' ratname ';']);
    lastx = out.xx; % to get a sense of how many x-values are in any given xx-yy pair
    largestofmin = max(largestofmin, min(lastx));
    smallestofmax = min(smallestofmax, max(lastx));
    minnie = min(minnie, min(lastx));
    maxie = max(maxie, max(lastx));
end;

newmin =largestofmin;
newmax = smallestofmax;
stepsize = (newmax-newmin) / length(lastx);
newxx = newmin:stepsize:newmax;
idx=find(abs(newxx - mp) == min(abs(newxx-mp)));
if newxx(idx) < 0
    newxx2 = [ newxx(1:idx) mp newxx(idx+1:end)];
else
    newxx2 = [ newxx(1:idx-1) mp newxx(idx:end)];
end;
newxx = newxx2;

% now make new interpolated yy values for each xx-yy pair, using newxx
%first for 'before' curves
fnames = fieldnames(data1);
for f = 1:length(fnames)
    ratname = fnames{f};
    eval(['out = data1.' ratname ';']);
    out.newxx = newxx;
    out.newyy = interp1(out.xx ,out.yy, out.newxx,'spline','extrap');
    eval(['data1.' ratname ' = out;']);
end;

%
%
% plot all curves from a given set
function [] = sub__plotset(data,lgnd, varargin)
fnames = fieldnames(data);

if nargin < 3, xplot = 'xx';
else xplot = varargin{1};
end;

if nargin < 4, yplot = 'yy';
else yplot = varargin{2};
end;

for f = 1:length(fnames)
    ratname = fnames{f};
    eval(['out = data.' ratname ';']);
    %   eval(['currcolour = plotclr.' ratname ';']);
    currcolour = rand(1,3);

    l=plot(eval(['out.' xplot]), eval(['out.' yplot]), '-r');
    set(l,'Color',currcolour,'LineWidth',2);   hold on;
end;

legend(lgnd,'Location','SouthEast');

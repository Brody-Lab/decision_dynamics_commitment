function [] = loadpsychinfo(ratname,varargin)
% Looks at a variety of performance metrics for psychometric sessions,
% showing summary graphs for each one
% When 'justgetdata' flag is used, the following fields are assigned in the
% caller's namespace:
% fields = {'bias_val','weber','means_hh','sem_hh', 'lds', ...
% 'psychdates', 'cpoke_stats', 'apoke_stats','dates',...
% 'overall_weber','bfit','xcomm','xmid','xfin'};
%
% Example uses:
% Show psych for last session before lesion
% loadpsychinfo('Celeborn','lastfew',1,'justgetdata',1,'infile','psych_before')
% Show psych for first session after lesion
% loadpsychinfo('Celeborn','dstart',1,'dend',1, 'isafter',1,'infile','psych_after','justgetdata',1)
% Show psych for first 3 sessions after lesion
% loadpsychinfo('Celeborn','dstart',1,'dend',3, 'isafter',1,'infile','psych_after','justgetdata',1)

[l h] = calc_pair('p', sqrt(8*16), 1,'suppress_out', 1);
[l2 h2] = calc_pair('d', sqrt(200*500), 0.95,'suppress_out', 1);
[l3 h3] = calc_pair('p', sqrt(8*16), 1.4,'suppress_out', 1);

pairs = { ...
    'infile', 'psych_before' ; ...
    'experimenter','Shraddha'; ...
    'preflipped', 0 ; ... % set to 1 for old rats that don't have 'flipped' field
    'ACxround1', 0 ; ... % pitch limits were different for ACx round 1
    'isafter', 0 ; ... % flag passed to file that does the saving (savepsychinfo)
    % which sessions to analyze? ----------------------------------------
    'dstart', 1 ; ...  %first session to analyze from
    'dend', 1000; ...  %last session to analyze to
    'lastfew', 1000; ...
    'eliminate_Mondays',0 ; ... % when true, removes sessions that fall on a Monday
    'ignore_trialtype', 0 ; ... % set to 1 to pool both psych and non-psych trials
    'psychthresh', 1 ; ... % set to 1 to ignore dates where there are < 2 values in a given bin.    
    'postpsych', 0 ; ... % set to 1 to use as the dateset only those days with valid number of psych trials
    % binning data -----------------------------------------------------
    'binmin_dur', l2 ; ...
    'binmax_dur', h2 ; ...
    'binmin_pitch', l ; ...
    'binmax_pitch', h ; ...
    'binmin_pitchold', l3; ...
    'binmax_pitchold', h3; ...
    'num_bins', 8 ; ...
    'bgcolor', 'grey'; ... % background color of figures
    % see comments above for fields assigned
    'justgetdata', 0 ; ... % if true, doesn't plot anything, just assigns data in caller's namespace
    'patch_bounds', 1 ; ... % see psych_oversessions.m
    'daily_bin_variability', 1; ... % see psych_oversessions for description
    'graphic', 1 ; ... % suppresses figures
    };
parse_knownargs(varargin,pairs);

% fprintf(1,'****%s:%s:%s ****\n',mfilename, ratname, infile);

if ignore_trialtype > 0    
    psychthresh=0;
    postpsych=0;
end;


ratrow = rat_task_table(ratname);
task = ratrow{1,2};
if strcmpi(task(1:3), 'dur'),
    binmin = binmin_dur;
    binmax = binmax_dur;
    pitch = 0;
    num_bins = 8;
    midpt = sqrt(200*500);
    xtk =[binmin midpt binmax];
    logbins = log(xtk);
    xtklbl = round(xtk);
else
    if ACxround1 > 0
        binmin=binmin_pitchold;
        binmax=binmax_pitchold;
    else
        binmin = binmin_pitch;
        binmax = binmax_pitch;
    end;
    pitch = 1;
    numbins = 9;
    midpt = sqrt(8*16);
    xtk =[binmin midpt binmax];
    logbins = log2(xtk);
    xtklbl = round(xtk * 10)/10;
end;

switch bgcolor
    case 'grey', bgcolor = [0.8 0.8 0.8];
    case 'red', bgcolor = [1 0.8 0.8];
    case 'blue', bgcolor = [0.8 0.8 1];
    case 'green', bgcolor = [0.8 1 0.8];
    otherwise bgcolor = [0.8 0.8 0.8];
end;

outfields = {'overall_weber', 'overall_psychhrate', 'overall_hrate', 'overall_betahat', 'overall_ci',...
    'overall_xc','overall_xmid', 'overall_xf',...
    'weber', 'bias_val','betahat','xcomm','xmid','xfin', ...
    'pstruct','failedfit_dates','psychdates','dates', 'numtrials',...
    'rxn', 'replongs', 'tallies', ...
    'concat_tones', 'concat_side_choice', 'concat_hh', ...
    'binmin','binmax','num_bins', 'xx','yy', 'bins', ...
    'sigmoidfit','linearfit', ...
    'useidx'
    };

global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;
%outdir = [Solo_datadir filesep 'Data' filesep experimenter filesep ratname filesep];
outdir = [Solo_datadir filesep 'Data' filesep experimenter filesep 'Set_Analysis' filesep 'psych_compiles' filesep];
fname = [outdir infile '.mat'];

try
    load(fname);
catch
    if isafter>0
        savepsychinfo(ratname,'action','after','outfile',infile);
    else
        savepsychinfo(ratname,'outfile', infile);
    end;
    load(fname);
end;

% ------------------------------------------------------
% Optional preprocessing: Extract only first X sessions
% ------------------------------------------------------

% -----------------------------------
% Variables to filter a range of sessions
% in your dataset >> BEGIN

% ---- DON"T FILTER DATES IF POSTPSYCH IS SET
if postpsych==0

    [useidx] = sub__whichdates2use(dates, dstart, dend, lastfew);
    fprintf(1,'%s:postpsych OFF:Using S#:', mfilename);
    fprintf(1,'%i ', useidx);
    fprintf(1,'\n');
    dates=dates(useidx);
    cumtrials=cumsum(numtrials); % original indexing without filtering
    numtmp = numtrials(useidx);

    fnames = {'logdiff','hit_history','logflag','psychflag', ...
        'blocks_switch','left_tone', 'right_tone', 'side_list', 'pstruct'};
    if preflipped ==0, fnames{end+1} = 'flipped'; end;
    for f =1:length(fnames)
        if exist(fnames{f},'var')
            if strcmpi(fnames{f},'blocks_switch') && sum((isnan(eval(fnames{f})))) > 0
                % keep this var as is
            else
                try
                    eval([fnames{f} ' = sub__getsubset(' fnames{f} ', useidx, cumtrials, 0);']);
                catch
                    error('%s:%s:%s:retrieval of subset indices failed',mfilename, ratname, fnames{f});
                end;
            end;
        end;
    end;
    numtrials = numtrials(useidx);

    % USING_BLOCKS_SECTION = 0;

    if exist('blocks_switch','var') && (sum(isnan(blocks_switch)) == 0) % a file created since blocks_switch was created
        if length(blocks_switch) == length(hit_history) % blocks_switch was implemented for this rat.
            psychflag = blocks_switch;
            USING_BLOCKS_SECTION = 1;
        else
            error('Blocks Switch should have the same dimension as hit_history.');
        end;
    end;
end;


% ------------------------------------------------------
% psych curve
% ------------------------------------------------------

if (sum(psychflag) > 0) || (ignore_trialtype > 0)

    in={};
    myf = {'hit_history', 'numtrials','binmin','binmax','dates','flipped'};
    for f = 1:length(myf)
        if ~exist('flipped','var'), flipped = 0; end;

        eval(['in.' myf{f} ' = ' myf{f} ';']);
    end;
    in.ltone=left_tone;
    in.rtone=right_tone;
    in.slist = side_list;
    in.psych_on = psychflag;
    %
    %     out.tallies , out.replongs , out.xcomm , out.xmid , out.xfin
    % out.weber , out.overall_betahat , out.overall_xc , out.overall_xf
    % out.overall_xmid out.overall_weber, out.overall_ci,
    % out.psychdates ,out.logtones,
    % out.bins ,out.failed_dates
    % out.overall_hrate

    remgraphic=graphic;
    if postpsych>0, graphic=0;end; % psych_oversessions will have gotten all the data, not the selected
    % sessions that we want, so we don't
    % want to see fitted graphs from that
    % data collection.
    %

    out = psych_oversessions(ratname,in, ...
        'justgetdata',justgetdata,'pitch', pitch,...
        'psychthresh',psychthresh,'ignore_trialtype', ignore_trialtype, ...
        'num_bins', num_bins,'daily_bin_variability',daily_bin_variability, ...
        'patch_bounds', patch_bounds, 'noplot', 1);

    graphic=remgraphic;

    if postpsych>0
        fprintf(1,'!! %s: postpsych=ON; original set=sessions with sufficient trials !!\n',mfilename);

        nufftrials=find(out.errorcodes ~= 1); % 0 and 2 have enough trials; 1 is the code for insufficient trials.
        notherway = sort([out.psychdates out.failedfit_dates]);
        if length(nufftrials) ~= length(notherway)
            error('\tmismatch');
        elseif sum(nufftrials-notherway) ~= 0
            error('\tnufftrials different from notherway');
        end;

        fprintf(1,'\t%i of %i sessions meet criteria\n',length(nufftrials), length(dates));

        % now further filter nufftrials indices to keep first/last few.
        %
        [useidx] = sub__whichdates2use(nufftrials, dstart, dend, lastfew);
        % the dates you want are nufftrials(useidx).
        useidx=nufftrials(useidx);
        fprintf(1,'\tUsing S#:', mfilename);
        fprintf(1,'%i ', useidx);
        fprintf(1,'\n');


        outNew=[];
        outNew.ratname=ratname;
        outNew.pitch=pitch;
        outNew.flipped =in.flipped;

        numlist={'binmin','binmax', 'bins', 'errorcodes','num_bins',...
            'poolxclude_dates','psychdates'}; % simply transfer
        for k=1:length(numlist), eval(['outNew.' numlist{k} '= out.' numlist{k} ';']); end;

        cumtrials=cumsum(numtrials);


        % make another cumtrials for just psychometric trials.
        cumptrials=cumsum(out.ptrials);
        outNew.concat_hh = sub__getsubset(out.concat_hh, useidx, cumptrials);
        outNew.concat_side_choice = sub__getsubset(out.concat_side_choice, useidx, cumptrials);
        outNew.concat_tones = sub__getsubset(out.concat_tones, useidx, cumptrials);

        outNew.allhh = sub__getsubset(hit_history, useidx, cumtrials);
        tmp=out.raw_tones; % psych tones for all sessions
        outNew.raw_tones=cell2mat(tmp(useidx)); % keep only those of wanted sessions

        tmp=out.raw_sc;
        outNew.raw_sc=cell2mat(tmp(useidx));


        collist = {'xcomm','xmid','xfin','weber'}; % one number per session
        for k=1:length(collist), eval(['outNew.' collist{k} '= out.' collist{k} '(useidx);']); end;

        rowlist={'replongs','tallies','betahat'}; % one row per session
        for k=1:length(rowlist),
            try
                eval(['outNew.' rowlist{k} '= out.' rowlist{k} '(useidx,:);']);
            catch
                2;
            end;
        end;

        % one value for pooled data
        filtered_out = logistic_fitter('init',outNew.raw_tones, outNew.raw_sc, sqrt(outNew.binmin*outNew.binmax), pitch);

        % make call to comparefits
        alltallies = sum(outNew.tallies,1);
        p = sum(outNew.replongs, 1) ./ alltallies;

        idx=find(p>0.99);
        if ~isempty(idx)
%             warning('FOund bin with perfect value. making it slightly imperfect');
            p(idx)=0.99;
        end;

        idx=find(p<0.01);
        if ~isempty(idx)
%             warning('FOund bin with perfect value. making it slightly imperfect');
            p(idx)=0.01;
        end;
        sigma = (p .* (1-p)) ./ alltallies;
        sigma=sqrt(sigma);

        if pitch > 0
            b=log2(outNew.bins);
            xr = log2([outNew.binmin outNew.binmax]);
        else
            b=log(outNew.bins);
            xr = log([outNew.binmin outNew.binmax]);
        end;


        [s qlin qsig betahat bestfit_yy]=comparefits(b, p, sigma, filtered_out.sigmoidfit, filtered_out.linearfit, 0, xr);

        hh = outNew.concat_hh(~isnan(outNew.concat_hh));
        % pooled fields
        outNew.logtones = filtered_out.logtones;
        outNew.overall_xc= filtered_out.xcomm;
        outNew.overall_xf = filtered_out.xfin;
        outNew.overall_xmid = filtered_out.xmid;
        outNew.overall_weber = filtered_out.weber;
        outNew.overall_psychhrate = sum(hh)/length(hh);
        outNew.overall_hrate=sum(outNew.allhh)/length(outNew.allhh);
        outNew.overall_ci = filtered_out.ci;
        outNew.overall_betahat = filtered_out.betahat;
        outNew.mp = filtered_out.mp;
        outNew.xx = filtered_out.interp_x;
        outNew.yy = bestfit_yy; %filtered_out.interp_y;
        outNew.sigmoidfit=filtered_out.sigmoidfit;
        outNew.linearfit=filtered_out.linearfit;
        outNew.qlin = qlin;
        outNew.qsig = qsig;
        outNew.bestfit_betahat = betahat;

        out=outNew;     
    else        
        out.overall_psychhrate = out.overall_hrate;
        out.overall_hrate=sum(hit_history)/length(hit_history);
        out.pitch =pitch;
        out.ratname = ratname;
        out.flipped = flipped;
        out.binmin = binmin;
        out.binmax = binmax;
    end;
    
    if graphic > 0
            if isafter > 0
                psych_plotbeforeafter(out,'r','fig', gcf, 'usefig', 1, ...
                    'ylbl_pos',0.2,'daily_bin_variability',daily_bin_variability,...
                    'patch_bounds',0);
            else
                psych_plotbeforeafter(out,'b','usefig',0, 'daily_bin_variability', daily_bin_variability,'patch_bounds', patch_bounds);
            end;
            2;
    end;

    %justgetdata=1;

    % for other functions' copy-pasting needs:
    myf = fieldnames(out);
    for f = 1:length(myf)
        eval([myf{f} ' = out.' myf{f} ';']);
    end;

    if ~justgetdata
        set(gcf,'Position',[0    140   530   250],'Color', bgcolor);
        set(gca,'XTick', logbins, 'XTickLabel', xtklbl,'YTick',0:0.25:1,'YTickLabel',0:25:100,...
            'FontWeight','bold', 'YLim',[0 1], 'XLim', [logbins(1) logbins(3)]);
        xm = overall_xmid; xc = overall_xc; xf = overall_xf;
        line([xm xm], [0 0.5], 'LineStyle',':','Color','r','LineWidth',2); % rat's midpoint
        line([0 xm], [0.5 0.5], 'LineStyle',':','Color','r','LineWidth',2);

        line([xc xc],[0 0.25], 'LineStyle',':','Color','r','LineWidth',2); % 25% mark
        line([0 xc], [0.25 0.25],'LineStyle',':','Color','r','LineWidth',2);

        line([xf xf], [0 0.75], 'LineStyle',':','Color','r','LineWidth',2);  % 75% mark
        line([0 xf], [0.75 0.75],'LineStyle',':','Color','r','LineWidth',2);

        line([logbins(2) logbins(2)], [0 1],'LineStyle',':','Color','k','LineWidth',2);
    end;
    if pitch == 0
        bias_val = exp(xmid) - sqrt(binmin*binmax);
        overall_bias = exp(overall_xmid) - sqrt(binmin*binmax);
    else
        bias_val = 2.^(xmid) - sqrt(binmin*binmax);
         overall_bias = 2.^(overall_xmid) - sqrt(binmin*binmax);
    end;
    try
        psychdates = dates(psychdates);
    catch
        error('whoops, error');
    end;
else
    failed_dates = 1:length(dates);
    overall_hrate= sum(hit_history)/length(hit_history);
    psychdates = [];
    outfields2 = {'overall_weber', 'overall_psychhrate', 'overall_betahat', 'overall_ci', ...
        'overall_xc','overall_xmid','overall_xf','weber', 'bias_val', ...
        'concat_hh', ...
        'betahat','xcomm','xmid','xfin', 'xx','yy', 'bins' ...
        };
    for f=1:length(outfields2)
        eval([outfields2{f} ' = NaN;']);
        if justgetdata
            assignin('caller',outfields2{f}, eval(outfields2{f}));
        else
            assignin('base',outfields2{f}, eval(outfields2{f})); ;
        end;
    end;

    if justgetdata
        assignin('caller','overall_hrate', overall_hrate);
    else
        assignin('base','overall_hrate', overall_hrate); ;
    end;

end;
uicontrol('Tag', 'figname', 'Style','text', 'String', [ratname '_psych'], 'Visible','off');

% ------------------------------------------------------
% Hit history plot
% ------------------------------------------------------

Monday_idx = []; % days that are a Monday

% if ~justgetdata
%     sub__plottaskvars();
% end;
% ------------------------------------------------------
% Weber & bias_val plot
% ------------------------------------------------------
% if ~justgetdata
%     sub__plot1();
% end;
% uicontrol('Tag', 'figname', 'Style','text', 'String', [ratname '_weber'], 'Visible','off');
% 

% ------------------------------------------------------
% Overall performance metric: Hit rate, Weber ratio, bias_val
% ------------------------------------------------------
outfields{end+1} = 'means_hh';
outfields{end+1}  = 'sem_hh';
outfields{end+1} = 'lds';
% show overall hit rate
lds = {};
means_hh = [];
sem_hh = [];

% first for all logdiffs
unld = unique(logdiff);
nonpsych = find(psychflag < 1);
for k = 1:length(unld)
    idx = find(logdiff == unld(k));
    idx= intersect(idx, nonpsych);
    if length(idx) > 5
        hh = hit_history(idx);
        means_hh = horzcat(means_hh, mean(hh));
        sem_hh = horzcat(sem_hh, std(hh)/sqrt(length(hh)));
        lds = horzcat(lds, num2str(unld(k)));
    end;
end;
% now overall non-psych hit rate
hh = hit_history(find(psychflag < 1));
no_hh = hh;
means_hh = horzcat(means_hh, mean(hh));
sem_hh = horzcat(sem_hh, std(hh)/sqrt(length(hh)));
lds = horzcat(lds, 'v');

% now overall psych hit rate
hh = hit_history(find(psychflag > 0));
ps_hh=hh;
means_hh = horzcat(means_hh, mean(hh));
sem_hh = horzcat(sem_hh, std(hh)/sqrt(length(hh)));
lds =horzcat(lds, 'ps');

if ~justgetdata
    sub__plot2();
end;
uicontrol('Tag', 'figname', 'Style','text', 'String', [ratname '_overallavg'], 'Visible','off');


% ------------------------------------------------------
% Assigning variables in caller's namespace
% ------------------------------------------------------
if justgetdata
    for i = 1:length(outfields)
        try
            assignin('caller',outfields{i}, eval(outfields{i}));
        catch
            eval([outfields{i} '=NaN;']);
            fprintf(1,'\t\t\tWARNING: %s: %s not found; setting to NaN\n', ratname, outfields{i});
            assignin('caller',outfields{i}, eval(outfields{i}));
        end;
    end;
end;

% -------------------------------------------------------------------------
% SUBROUTINES BEGIN HERE
% -------------------------------------------------------------------------

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculates and plots hit rate
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sub__plot_hitrate(hh,numtrials)
running_avg = 30;
good=0.8;

nums=[];
t = (1:length(hh))';
a = zeros(size(t));
for i=1:length(hh),
    x = 1:i;
    kernel = exp(-(i-t(1:i))/running_avg);
    kernel = kernel(1:i) / sum(kernel(1:i));

    a(i) = sum(hh(x)' .*kernel);
end;
num = a;

plot(num, '.-');

line([1 length(num)], [good good], 'LineStyle','--','Color','b');
line([1 length(num)], [0.5 0.5], 'LineStyle', '--', 'Color', 'r');

%set(t,'FontSize',14,'FontWeight','bold');
nums = [nums ; {num}]; hold on;
cumtrials = cumsum(numtrials);
for i=2:length(numtrials)
    line([cumtrials(i-1) cumtrials(i-1)], [0 1.5], 'LineStyle','-','Color','k');
end;

set(gca,'YLim',[0.4 1], 'YTick',0:0.2:1, 'YTickLabel', 0:20:100);

ylabel('Hit rate');
xlabel('Trial #');

offset =0;
for k=1:length(numtrials)
    currhh = hh(offset+1:offset+numtrials(k));
    t=text(offset+(numtrials(k)/2), 0.45, sprintf('%i', round(mean(currhh) * 100)));
    set(t,'FontWeight','bold');
    offset = offset+numtrials(k);
end;

% Draws vertical lines separating session info
function [] = sub__draw_separators(numtrials,low,hi);
offset=0;
for k = 1:length(numtrials),
    offset=offset+numtrials(k);
    line([offset offset], [low hi], 'LineStyle','-', 'Color','k');
end


% determines subset of sessions wanted using arg 2,3,4
function [useidx] = sub__whichdates2use(dateset, dstart, dend, lastfew)
useidx=1:length(dateset);

str=sprintf('both ''lastfew'' and ''dend'' have been set. dstart=%i,dend=%i,lastfew=%i\n', dstart,dend,lastfew);
if lastfew < 1000 && dend<1000
    error(str);
elseif lastfew < 1000
    if dstart > 1
        error('sorry, dstart must be 1 if using lastfew');
    end;
    lastfew = min(lastfew, length(dateset));
    dstart=length(useidx)-(lastfew-1);
    dend = length(useidx);
    %    useidx = useidx(end-(lastfew-1):end);
elseif dend < 1000 % first few X sessions
    dstart=1;
    % useidx=useidx(1:i);
else
    dstart=1; dend=length(dateset); % use whole set
end;

d2use=dstart:dend;
% base case - dateset isn't long enough; must use all dates therein
if length(dateset) < length(d2use)
    fprintf(1,'\t%s:Not enough dates to filter; using whole set\n', mfilename);
    useidx = 1:length(dateset);
else
    useidx=useidx(dstart:dend);
end;


% given array spanning data over sessions, returns subset as
% specified by 2nd 3rd and 4th input param
% dateswanted = array with subset session numbers
% cumtrials = cumsum(numtrials in each session)
% uselnflag = set to 1 for arrays with only 1 value per
% session. for these we don't index into cumtrials, we use the
% raw dateswanted as our index numbers
function [outdat] = sub__getsubset(dat, dateswanted, cumtrials, uselnflag)
outdat=[];
isrowvector= rows(dat)>1;
for k=1:length(dateswanted)
    d=dateswanted(k);
    if d==1, sidx=1; else sidx=cumtrials(d-1)+1;end;
    eidx=cumtrials(d);

    if isrowvector>0
        outdat=vertcat(outdat,dat(sidx:eidx));
    else
        outdat = horzcat(outdat,dat(sidx:eidx));
    end;
end;

function [] = sub__plot1()
figure;
set(gcf,'Position',[-33   589   440   390],'Color', bgcolor,'Menubar','none','TOolbar','none','Tag','loadpsych');
subplot(3,1,1);
if weber ~= -1
    if ~isstr(weber)
        l=plot(weber,'.g');
        set(l,'Color',[0.32 0.49,1], 'MarkerSize',20);

        %             hold on; l2 = plot(Monday_idx, weber(Monday_idx), '.g');
        %             set(l2,'Color',[0.6 0.6 0.4], 'MarkerSize',20);
        xlabel('Day'); ylabel('Weber ratio');
        %            set(gca,'YLim',[0 max(weber)+0.1], 'YTick',0:max(weber)+0.1);
        hold on;
        % line([0 length(weber)+1], [0.2 0.2],'LineStyle',':','Color','b');
        % line([0 length(weber)+1], [0.3 0.3],'LineStyle',':','Color','b');

        % line([0 length(weber)+1], [0.5 0.5],'LineStyle',':','Color','r');
    end;
end;
set(gca,'FontWeight','bold','FontSize',11);
title('Behaviour of Weber ratio over days');

subplot(3,1,2);
if bias_val ~= -1
    if ~isstr(bias_val)
        l=plot(1:length(bias_val), bias_val,'.g');
        set(l,'Color',[0.32 0.49,1], 'MarkerSize',20);
        hold on;
        %             l2 = plot(Monday_idx, bias_val(Monday_idx), '.g');
        %             set(l2,'Color',[0.6 0.6 0.4], 'MarkerSize',20);
        line([1 length(bias_val)],[0 0],'Color','k','LineStyle',':');
        if mean(bias_val) > 0,
            text(3, -2,'RIGHT', 'FontSize',12, 'Color', 'r','FontWeight','bold');
        else
            text(1, +2, 'LEFT', 'FontSize', 12,'COlor','r', 'FontWEight','bold');
        end;

        xlabel('Day'); ylabel('bias_val (ms)');
        title('Behavior of biasval over days');

        lim = max(abs(bias_val));

        set(gca,'YLim', [(-1*lim)-10 lim+10],'FontWeight','bold','FontSize',11);
    end;
end;
subplot(3,1,3);
l=plot(1:length(numtrials), numtrials,'.g');
set(l,'Color',[0.32 0.49,1], 'MarkerSize',20);hold on;
for k = 1:3
    line([1 length(numtrials)], [100*k 100*k],'Color','k','LineStyle',':');
end;
%     l2 = plot(Monday_idx, numtrials(Monday_idx), '.g');
%     set(l2,'Color',[0.6 0.6 0.4], 'MarkerSize',20);
title('# trials per session');ylabel('numtrials'); xlabel('day');
set(gca,'FontWeight','bold','FontSize',11);


function [] = sub__plot2()
figure; set(gcf,'Position',[ 1136         145         250         500],'Color',bgcolor);

subplot(3,1,1);% Average hit rate

p=patch([0 0 2 2],[0 0.5 0.5 0], [1 0 0]);
set(p,'facealpha',0.2,'EdgeColor','none'); hold on;
p=patch([0 0 2 2],[0.8 1 1 0.8], [1 1 0]);
set(p,'facealpha',0.2,'EdgeColor','none'); hold on;

try
    barweb(means_hh, sem_hh, 0.5, [], [],'Rat','Avg. hit rate (%) (SEM)');
catch
    addpath('Analysis/duration_disc/stat_sandbox/');
    barweb(means_hh, sem_hh, 0.5, [], [],'Rat','Avg. hit rate (%) (SEM)');
end;


set(gca,'YLim',[0.5 1], 'YTick',0.5:0.1:1, 'YTickLabel',50:10:100,'XTick',0.7:0.15:1.3,'XTickLabel',lds);
title('Overall success rate');
t=text(1.2, 0.9, sprintf('%2.0f%% (%2.0f)\nPs: %2.0f%% (%2.0f)', ...
    mean(no_hh)*100, std(no_hh*100)/sqrt(length(no_hh)), mean(ps_hh)*100, std(ps_hh*100)/sqrt(length(ps_hh))));
set(t,'FontSize',12);

subplot(3,1,2);
if weber ~= -1
    if ~isstr(weber)
        barweb(mean(weber), std(weber), 0.25, ratname, [],'Rat', 'Average weber (SD)');
        set(gcf,'Color',bgcolor);
        t=text(1.2, 0.1, sprintf('%1.2f (%1.2f)', mean(weber), std(weber)));
        title('Overall Weber ratio');
    end;
end;
set(t,'FontWeight','bold','FontSize',14);

subplot(3,1,3);
if bias_val ~=-1
    if ~isstr(bias_val)
        if pitch == 0
            bias_val = exp(xmid) - sqrt(binmin*binmax);
            overall_bias = exp(overall_xmid) - sqrt(binmin*binmax);
            units = 'ms';

        else
            bias_val = 2.^(xmid) - sqrt(binmin*binmax);
            overall_bias = 2.^(overall_xmid) - sqrt(binmin*binmax);
            units = 'KHz';
        end;
        barweb(mean(bias_val), std(bias_val), 0.25, ratname, [],'Rat','Average bias (SD)');
        bias_valdir = 'LEFT'; if mean(bias_val) > 0, bias_valdir='RIGHT'; end;
        fprintf('Bias (session-average): %2.1f (%2.1f) %s to the %s\n', mean(bias_val), std(bias_val),units, ...
            bias_valdir);
        bias_valdir = 'LEFT'; if mean(overall_bias) > 0, bias_valdir='RIGHT'; end;
        fprintf('Bias (pooled): %2.1f %s to the %s\n', overall_bias, units, bias_valdir);
    end;
end;
set(t,'FontWeight','bold','FontSize',14);
title('Overall bias');



function [] = sub__plottaskvars()
figure;
set(gcf,'Position', [400         852        900        450],'Color', bgcolor);
axes;
patch([0 0 sum(numtrials) sum(numtrials)], [0 0.5 0.5 0],[1 0.8 0.8]); hold on;
patch([0 0 sum(numtrials) sum(numtrials)], [0.8 1 1 0.8],[1 1 0.6]);
offset=0;
for k = 1:length(numtrials),
    tmp = dates{k};
    wkday = weekday(sprintf('%s-%s-20%s', tmp(3:4), tmp(5:6), tmp(1:2)));

    if wkday == 2 % mark Mondays
        patch([offset offset offset+numtrials(k) offset+numtrials(k)], ...
            [0.8 1 1 0.8], [0.8 0.8 0.4]);
        Monday_idx = horzcat(Monday_idx, k);
    end;
    t= text(offset+ 10, 1.05, dates{k});
    set(t,'FontWeight','bold');
    offset=offset+numtrials(k);
end;
sub__plot_hitrate(hit_history,numtrials);
sub__draw_separators(numtrials,0,1);
pos = get(gca,'Position');
set(gca,'Position',[0.04 0.6 0.9 0.35],'XLim',[0 sum(numtrials)],'XTick',[sum(numtrials)],'FontWeight','bold','FontSize',10);


% tones plot
axes;
plot(left_tone,'.b'); hold on;
plot(right_tone,'.r');
sub__draw_separators(numtrials,0,1);
if strcmpi(task(1:3),'dur')
    ylabel('Duration (ms)');
    ylim = [binmin binmax] ./1000;
else
    ylabel('Frequency (KHz)');
    ylim = [binmin binmax];
end;
pos = get(gca,'Position');
set(gca,'Position',[0.04 0.4 0.9 0.15],'FontWeight','bold','FontSize',10,'XLim',[0 sum(numtrials)],'XTick',[sum(numtrials)],'YLim',ylim);

axes;
plot(left_prob,'-b');
set(gca,'Position',[0.04 0.25 0.9 0.1]);
ylabel('LeftProb'); set(gca,'YTick',[0 0.5 1],'YLim',[0 1],'FontWeight','bold','FontSize',10);

axes;
bbspl_array = zeros(size(bbspl));
bbspl_array(find(strcmpi(bbspl,'normal'))) = 1;
bbspl_array(find(strcmpi(bbspl,'Louder'))) = 2;
bbspl_array(find(strcmpi(bbspl,'LOUDEST'))) = 3;
bbspl=bbspl_array;
plot(bbspl,'-r'); set(gca,'Position',[0.04 0.05 0.9 0.1], 'FontWeight','bold','FontSize',10,'YLim',[0 4],'YTick',[1 2 3],'YTickLabel',{'nor','Lou','DEST'});
ylabel('BBSPL');

uicontrol('Tag', 'figname', 'Style','text', 'String', [ratname '_hrate'], 'Visible','off');



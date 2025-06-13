function [out]  = psych_oversessions(ratname,in,varargin)
% Takes raw data from multiple sessions and computes:
% 1) fits and weber ratios for each session
% 2) the logistic fit and weber ratio for the pooled data.
% Plots fitted psych curve from pooled data
% Returns the output of get_weber but amassed into an array
pairs = { ...
    'justgetdata', 1; ...
    'pitch', 0 ; ...
    'psychthresh',1; ...        % set to 1 to ignore dates where there are < 2 values in a given bin.
    'mintrials', 5 ; ...        % there should be at least 5 trials to make a valid session
    'ignore_trialtype', 0 ; ... % set to 1 to include all trials (psych and nonpsych) when fitting curve 
    'num_bins', 9 ; ...
    % Plotting options --------------
    %  'nohist', 0 ; ... % set to 1 if you don't want histogram showing stimulus distributions
    'usefig', 0 ; ... % figure handle for plotting - if 0, uses a fresh figure
    'noplot', 0 ; ... % not even a summary plot.
    'pool_only_good_days', 1 ; ... % only pool data from days where each bin has at least two values
    % what do the plotted (binned) points represent?
    'daily_bin_variability', 0 ; ... % when true, the points on the graph indicate the std of daily "% longs" and NOT that of the raw data pooled over days
    'err_userange', 0 ; ... % if true, error bars show the range of the session values; if false, they are the sd of the daily values
    'plot_marker', 'o'; ... % marker for plotting binned "% long" on y-axis of psych curve
    'patch_bounds', 1 ; ... % if true, puts a light yellow patch around the 0-10 and 90-100% mark of the y-axis of the psych curve.
    'usefid', 1 ; ... % fid to fprintf to
    };
parse_knownargs(varargin, pairs);

ratrow = rat_task_table(ratname);
task = ratrow{1,2};

% ltone = stimulus param of duration/pitch for each trial (LEFT)
% rtone
% hit_history = binary string of hits and misses
% numtrials = array with # trials per session (Sx1 double array where S is
% # sessions)
% psych_on = binary array of psych trial (1) or not (0)
% slist = binary array indicating trial side (1 = left, 0 = right)
% binmin, binmax = endpoints for binning ltone and rtone
myf = {'ltone', 'rtone','hit_history', 'numtrials', 'psych_on', ...
    'slist','binmin','binmax','flipped'};
for f = 1:length(myf)
    eval([myf{f} ' = in.' myf{f} ';']);
end;

if sum(flipped) == length(flipped),
    flipped = 1;
elseif sum(flipped) == 0
    flipped = 0;
elseif ~isnan(sum(flipped))
    error('%s: Why are some trials flipped and others not?', mfilename);
end;


replong = zeros(1,num_bins); tally = zeros(1, num_bins);

xcomm = []; % (one per session) 16% stimulus mark
xfin = [];  % (one per session) 84% stimulus mark
xmid =[];   % (one per session) 50% stimulus mark
weber =[];  % (one per session)
betahat=[];    % parameter estimates for general logistic fit
psychdates=[]; % indexes of those sessions for which # psych trials exceeded threshold needed to call it a psych session.
offset = 0;
perday_tally = [];      % stores tallies from individual sessions -- for cross-checking
perday_replong = [];    % stores replong from individual sessions

dates=in.dates;
failedfit_dates = [];
poolxclude_dates = [];
fit_good = []; % binary array indicating whether a given day had a good fit (1) or not (0)

raw_tones=[];
raw_sc=[];
concat_tones = []; % tones concatenated over sessions
concat_side_choice = []; % side_choice concatenated over sessions
concat_hh = [];
errorcodes = NaN(size(numtrials)); % see text below call to sub__ to get code dictionary
ptrials = []; % # psych trials in the session.

for d = 1:length(numtrials)
    % Set up tones array
    idx = offset+1:offset+numtrials(d);
    t1 = ltone(idx);
    t2 = rtone(idx);
    sides = slist(idx);
    hh = hit_history(idx);
    psych = psych_on(idx);

    %     if flipped > 0
    %         left = 0; right = 1-left;
    %     else
    left = 1; right = 1-left;
    %     end;
    tones = zeros(size(t1));

    tones(find(sides == left)) = t1(find(sides == left));
    tones(find(sides == right)) = t2(find(sides == right));

    % Set up "reported long array"
    left_t = find(sides == left);
    rep_long = hh;
    rep_long(intersect(left_t, find(hh == 0))) = 1;
    rep_long(intersect(left_t,find(hh==1))) = 0;
    if flipped > 0
        rep_long = 1-rep_long;
    end;

    % now get psychometric trials
    if ignore_trialtype > 0 
        trials = 1:length(psych);
    else
        trials = find(psych > 0);
    end;
    

    rep_long = rep_long(trials); % side choice array
    if pitch < 1,         tones = tones(trials) * 1000;
    else tones = tones(trials); end;

    badtrials = union(find(tones < binmin-0.3), find(tones > binmax+0.3));
    if ~isempty(badtrials)
        if pitch>0 % try with older pitch bins
            [l3 h3] = calc_pair('p', sqrt(8*16), 1.4,'suppress_out', 1);
            binmin=l3; binmax=h3;
            badtrials = union(find(tones < binmin-0.3), find(tones > binmax+0.3));
            if ~isempty(badtrials)
                warning('%s:%s:%s:Bad tone values found!!!', mfilename, ratname, dates{d});
            els                warning('!!%s:%s has old pitch bins', mfilename, ratname);
            end;

        else
            warning('%s:%s:%s:Bad tone values found!!!', mfilename, ratname, dates{d});
        end;
    end;

    
    % remove any trials with NaN side choices
    goodtrials = find(~isnan(rep_long));
    tones=tones(goodtrials);
    rep_long=rep_long(goodtrials);

    [bins fit_failed wb bf xc xm xf ci replong_today tally_today] = ...
        sub__do_daily_psych_calc(binmin, binmax, num_bins,pitch, tones, rep_long, psychthresh, ignore_trialtype);
    
    % errorcode
    % 0= Good data.
    % 1= Failed; Insufficient trials
    % 2= Sufficient trials but fit failed
    
    if (wb == -1 && ~isempty(find(tally_today < 2)) && (ignore_trialtype == 0)) || sum(tally_today) < mintrials % this happens because there weren't enough psychometric trials for this session
        % perhaps the rat sharpened for the whole session (in the
        % days before the session started with psychometric trials) OR
        % there was enough data but the sigmoid fit wasn't good
        %  failed_dates = horzcat(failed_dates, d);
        poolxclude_dates = horzcat(poolxclude_dates, d);
        tmp_tones = NaN(1,length(tones));
        tmpsc = NaN(1,length(rep_long));
        tmp_replong = NaN(1,length(bins));
        tmp_tally = NaN(1,length(bins));
        xc=NaN; xm = NaN; xf = NaN; wb = NaN; bf = nan(1,4);
        tmp_fit_good = 0;
        tmp_hh = NaN(size(hh));
        errorcodes(d)=1;
    elseif fit_failed > 0 % we want to keep the data from the bad fits
        failedfit_dates = horzcat(failedfit_dates, d);
        xc=NaN; xm = NaN; xf = NaN; wb = NaN; bf = nan(1,4);
        tmp_tones = tones;
        tmpsc = rep_long;
        tmp_replong = replong_today;
        tmp_tally= tally_today;
        tmp_fit_good = 0;
        tmp_hh = hh;
        errorcodes(d)=2;
    else
        psychdates = horzcat(psychdates, d);
        tmp_tones = tones;
        tmpsc = rep_long;
        tmp_replong = replong_today;
        tmp_tally= tally_today;
        tmp_fit_good = 1;
        tmp_hh = hh;
        errorcodes(d)=0;
    end;

    raw_tones{end+1}=tones;
    raw_sc{end+1}=rep_long;
    
    ptrials = horzcat(ptrials, sum(tally_today,2));
    % contains data ONLY for psych trials
    % contains NaNs on those days not included as psych sessions
    concat_tones = horzcat(concat_tones, tmp_tones);
    concat_side_choice = horzcat(concat_side_choice, tmpsc);
    concat_hh = horzcat(concat_hh, tmp_hh);
    
    perday_tally = vertcat(perday_tally, tmp_tally);
    perday_replong = vertcat(perday_replong, tmp_replong);
    fit_good = horzcat(fit_good, tmp_fit_good);

    xcomm=horzcat(xcomm, xc);
    xfin=horzcat(xfin,xf);
    xmid=horzcat(xmid, xm);
    weber=horzcat(weber, wb);
    if length(bf) < 4, 
        bf = [bf NaN NaN]; % pad to make n-by-4 vector
    end;
    try        
    betahat = vertcat(betahat, bf);
    catch            
        error('betahat addition failed');
    end;

    offset = offset+numtrials(d);
end;

% ------------------------------------------------
% Now work on pooled data

if pool_only_good_days > 0
    good_days = find(sum(perday_tally,2) > 0);
    replong = sum(perday_replong(good_days,:),1);
    tally = sum(perday_tally(good_days,:), 1);
end;

% perform logistic regression and calculate POOLED Weber ratio
%out = weber_caller(bins, replong, tally, pitch,binmin, binmax);
low_tally = find(tally < 2);
if (isempty(tally) || ~isempty(low_tally)) && (ignore_trialtype == 0)
    % for other functions' copy-pasting needs:
    out.tallies = 0;
    out.replongs = 0;
    out.xcomm = NaN;
    out.xmid = NaN;
    out.xfin = NaN;
    out.weber = -1;
    out.overall_betahat = NaN;
    out.overall_xc=NaN;
    out.overall_xf=NaN;
    out.overall_xmid=NaN;
    out.overall_weber = -1;
    out.overall_hrate=NaN;
    out.overall_ci = NaN;
    out.psychdates = {};
    out.logtones = [];
    out.bins = [];
    out.failedfit_dates = failedfit_dates;
    out.errorcodes=errorcodes;
    return;
end;


% now compute logistic fit for pooled data

% keep only those tones and side choices that are not NaN
ne = ~isnan(concat_tones); ne2 = ~isnan(concat_side_choice);
if ( sum(ne == ne2) ~= length(ne)) % the two should be the same
    error('Indices that are NaN in concat_tones don''t match those in concat_side_choice');
end;

tmp_tones = concat_tones(ne); tmp_sc = concat_side_choice(ne);

out = logistic_fitter('init',tmp_tones, tmp_sc, sqrt(binmin*binmax),pitch);

p=replong./tally;

idx=find(p>0.99);
if ~isempty(idx)
%     warning('FOund bin with perfect value. making it slightly imperfect');
    p(idx)=0.99;
end;

idx=find(p<0.01);
if ~isempty(idx)
%     warning('FOund bin with perfect value. making it slightly imperfect');
    p(idx)=0.01;
end;



sigma=(p .* (1-p)) ./ tally;
sigma=sqrt(sigma);
if pitch > 0
    b=log2(bins);
    xr = log2([in.binmin in.binmax]);
else
    b=log(bins);
    xr = log([in.binmin in.binmax]); 
end;

if ~isstruct(out.sigmoidfit)
    s=NaN;
    qlin=NaN;
    qsig=NaN;
    betahat=NaN(4,1);
    bestfit_yy=NaN;   
else
    [s qlin qsig betahat bestfit_yy]=comparefits(b, p, sigma, out.sigmoidfit, out.linearfit, 0, xr);
end;

hh = concat_hh(~isnan(concat_hh));
% pooled fields
x = out.logtones;
overall_xc= out.xcomm;
overall_xf = out.xfin;
overall_xmid = out.xmid;
overall_weber = out.weber;
overall_hrate = sum(hh)/length(hh);
overall_ci = out.ci;
overall_betahat = out.betahat;
overall_slope = s;
mp = out.mp;
xx = out.interp_x;
yy = bestfit_yy;
linearfit=out.linearfit;
sigmoidfit=out.sigmoidfit;



out = {};
% for other functions' copy-pasting needs:
fnames = {'xcomm','xmid','xfin','weber','betahat',...
    'psychdates', 'failedfit_dates', 'poolxclude_dates', ...
    'overall_weber','overall_hrate', 'overall_ci',...
    'overall_betahat','overall_xc','overall_xmid','overall_xf',...
    'bins','concat_tones','concat_side_choice', ...
    'linearfit', 'sigmoidfit', ...
    'raw_tones','raw_sc', 'concat_hh', 'binmin','binmax','num_bins','errorcodes',...
    'ptrials'};
for idx =1:length(fnames)
    eval(['out.' fnames{idx} ' = ' fnames{idx} ';']);
end;
out.replongs = perday_replong;
out.tallies = perday_tally;
out.xx = xx;
out.yy = bestfit_yy;

if noplot > 0
    return;
end;

% Plotting begins here ---------------------------
beforeColor = 'b';
afterColor = 'r';
myColor = 'b';
ylbl_pos = 0.2;

if justgetdata
    f = findobj('Tag', [ratname '_psych_curve']);
    if ~isempty(f), 
        fig = f; set(0,'CurrentFigure',fig); myColor = afterColor; ylbl_pos= 0.15;
    elseif usefig ~= 0
        fig = usefig;
    else
        fig = figure;
    end;
else
    if usefig == 0
        figure;
    end;
end;


mega_tally = sum(sum(out.tallies)); % total # trials in psych curve
miniaxis = [bins(1), sqrt(binmin*binmax) bins(end)];

if pitch > 0
    mybins = log2(bins);
    hist__lblfmt = '%1.1f';
    hist__xlbl = 'Bins of frequencies (kHz)';
    psych__xtick = log2(miniaxis);
    psych__xlbl = 'Tone frequency (kHz)';
    %     if flipped > 0
    %         psych__ylbl = 'frequency of reporting "Low" (%)';
    %     else
    psych__ylbl = 'frequency of reporting "High" (%)';
    %     end;
    txtform =  '[%1.1f,%1.1f] kHz';
    unittxt = 'kHz';
    roundmult = 10;
    log_mp = log2(sqrt(binmin*binmax));
    mybase = 2;
    unittxt='kHz';
    unitfmt = '%2.1f';
else
    mybins = log(bins);
    hist__lblfmt='%i';
    hist__xlbl = 'Bins of durations (ms)';
    psych__xtick = log(miniaxis);
    psych__xlbl = 'Tone duration (ms)';
    %     if flipped > 0
    %         psych__ylbl = 'frequency of reporting "Short" (%)';
    %     else
    psych__ylbl = 'frequency of reporting "Long" (%)';
    %     end;
    txtform =  '[%i,%i] ms';
    log_mp = log(sqrt(binmin*binmax));
    roundmult = 1;
    mybase = exp(1);
    unittxt = 'ms';
    unitfmt = '%i';
end;

xlim=[mybins(1) mybins(end)];
mymin = round(binmin*roundmult)/roundmult;
mymax=round(binmax*roundmult)/roundmult;
hist__xtklbl = round(bins*roundmult)/roundmult;
psych__xtklbl = round(miniaxis * roundmult)/roundmult;
fsize=14;

% print to stdout
bias_val = (mybase^(overall_xmid))-(mybase^(mp));
% fprintf(usefid, '%s\n', mfilename);
% fprintf(usefid, '\tPooled Midpoint: %1.1f\n',mybase^(overall_xmid));
% fprintf(usefid, '\tbias_val: %1.1f\n', bias_val);
% fprintf(usefid, '\tPooled weber is: %1.2f\n', overall_weber);


curr_x = 0.05; curr_width = 0.4;
if ~justgetdata

    % Show histogram of cue parameter
    axes('Position', [curr_x 0.2 curr_width 0.6]);
    bar(mybins, tally, 'stacked');
    lbl = cell(0,0);
    for k = 1:length(bins)
        h = text(mybins(k), tally(k)+3, int2str(tally(k)));
        set(h, 'FontSize',fsize,'FontWeight','bold');
        lbl{k} = sprintf(hist__lblfmt, bins(k));
    end;

    x=xlabel(hist__xlbl);set(x,'FontSize',16,'FontWeight','bold');
    set(gca,'XTick', mybins, 'XTickLabel', hist__xtklbl,...
        'XLim', [mybins(1)*0.99 1.01*mybins(end)], 'YLim', [0 1.1*max(tally)],...
        'FontSize', 16, 'FontWeight','bold');
    y=ylabel('Sample size (n)');set(y,'FontSize',16,'FontWeight','bold');
    t= title(sprintf('%s: %s (%s-%s): \nTone sampling distribution (n=%i)', make_title(ratname), make_title(task), dates{psychdates(1)}, dates{psychdates(end)}, mega_tally));
    set(t, 'FontSize', 16, 'FontWeight','bold');
    curr_x = curr_x + 0.5;
    % axes__format(gca);
end;

% plotting psych curve
if justgetdata,
    if ~(strcmpi(get(gcf,'Tag'), [ratname '_psych_curve'])) && usefig == 0,
        axes('Position', [0.1 0.15 0.8 0.75]);
    end;
else
    axes('Position', [curr_x 0.15 curr_width 0.75]);
end;

hold on;
replongs = nansum(perday_replong);
tallies = nansum(perday_tally);

if daily_bin_variability > 0
    rowsum = sum(perday_replong'); ne = find(~isnan(rowsum));
    ne_rep = perday_replong(ne,:); ne_tally = perday_tally(ne,:);

    p = ne_rep ./ ne_tally;

    numSess = rows(p);


    if rows(p) == 1
        mu = p;
        errmin = NaN(size(p)); errmax = NaN(size(p));
        dailytxt = '1 session';
    else
        mu = mean(p);

        if err_userange > 0 || length(p) < 3
            errmin = mu-min(p); errmax = max(p)-mu;
            dailytxt = 'Mean (RNG)';
        else
            stdev = std(p) / sqrt(rows(p));
            errmin = stdev; errmax = stdev;
            dailytxt = 'Mean (SEM)';
        end;
    end;
    errmin; errmax;
    p = mu;

else
    p = replong ./ tally;
    numSess = rows(p);
    variance = (p .* (1-p)) ./ tally ;
    stdev = sqrt(variance);
    errmin = stdev; errmax = stdev;


    dailytxt = 'Binned: Pooled across sessions (SD)';
end;


% >>>>>>>>>>>>> PLOTTING CODE
if patch_bounds > 0
    patch([min(xx) min(xx) max(xx) max(xx)], [0 0.15 0.15 0], [1 1 0.8],'EdgeColor','none');
    hold on;
    patch([min(xx) min(xx) max(xx) max(xx)], [1 0.85 0.85 1], [1 1 0.8],'EdgeColor','none');
end;


l=plot(xx, yy, '-r','LineWidth',2,'Color',myColor);

out.plot_interpol = l;
% plot(mybins, replongs ./ tallies, 'or','Color', myColor,'MarkerSize', 10,'LineWidth',2,'Marker', plot_marker);
l=errorbar(mybins, p, errmin, errmax, '.r','Color',myColor,'MarkerSize',20);
out.plot_errorbar = l;

line([log_mp log_mp],[0 1], 'LineStyle',':','Color','k','LineWidth',2); % intended midpoint


xm = overall_xmid;
xc = overall_xc;
xf  = overall_xf;
myxc = round((mybase^xc)*roundmult)/roundmult;
myxm = round((mybase^xm)*roundmult)/roundmult;
myxf = round((mybase^xf)*roundmult)/roundmult;

fct=0.04;

if ~justgetdata
    % now plot
    uicontrol('Style','text','String', dailytxt,'Position',[0.6 0.003 0.4 0.035] .* get(gcf,'Position'),'BackgroundColor', [1 0.7 0.7], 'FontWeight','bold','FontSize',12);
    % both binned points as well as fitted logistic


    hold on;
    l=errorbar(mybins, p, errmin, errmax, '.r');
    set(l,'Color',[0.4 0.4 0.4],'LineWidth',2,'MarkerSize',20);

    line([xm xm], [0 0.5], 'LineStyle',':','Color','r','LineWidth',3); % rat's midpoint
    line([0 xm], [0.5 0.5], 'LineStyle',':','Color','r','LineWidth',3);
    t=text(xlim(1)*1.001, 0.5+fct, sprintf(['x@50%%=' unitfmt ' ' unittxt], myxm));
    set(t,'FontSize', 14,'FontAngle','italic','FontWeight','bold');

    line([xc xc],[0 0.25], 'LineStyle',':','Color','r','LineWidth',3); % 25% mark
    line([0 xc], [0.25 0.25],'LineStyle',':','Color','r','LineWidth',3);
    t=text(xlim(1)*1.001, 0.25+fct, sprintf(['x@25%%=' unitfmt ' ' unittxt], myxc));
    set(t,'FontSize', 14,'FontAngle','italic','FontWeight','bold');

    line([xf xf], [0 0.75], 'LineStyle',':','Color','r','LineWidth',3);  % 75% mark
    line([0 xf], [0.75 0.75],'LineStyle',':','Color','r','LineWidth',3);
    t=text(xlim(1)*1.001, 0.75+fct, sprintf(['x@75%%=' unitfmt ' ' unittxt], myxf));
    set(t,'FontSize', 14,'FontAngle','italic','FontWeight','bold');
end;

set(gca,'XTick',psych__xtick,'XLim', xlim, 'XTickLabel', psych__xtklbl, ...
    'YTick',0:0.25:1, 'YTickLabel', 0:25:100, 'YLim',[0 1], ...
    'FontSize',14,'FontWeight','bold');

if flipped > 0, flptxt = 'Flipped sides'; else flptxt = 'Unflipped sides'; end;

text(psych__xtick(end)*0.95, 0.05, flptxt,'FontWeight','bold','Color','k','FontSize', 12);
text(psych__xtick(end)*0.95, ylbl_pos, sprintf('numSess=%i', numSess), 'Color',myColor','FontWeight','bold','FontSize', 14);
text(psych__xtick(end)*0.95, 0.1, dailytxt, 'Color','k','FontWeight','bold','FontSize', 12);

xlbl=xlabel(psych__xlbl);
ylbl=ylabel(psych__ylbl);
t = title(sprintf(['%s: %s: \n[Min,Max] =' txtform ' (n=%i)'], make_title(ratname), make_title(task), mymin, mymax,length(trials)));
set(t, 'FontSize', 14, 'FontWeight', 'bold');

t=title(sprintf('%s: Overall psychometric curve',ratname));
% axes__format(gca);

if justgetdata
    set(xlbl,'FontSize',fsize,'FontWeight','bold');
    set(ylbl,'FontSize',fsize,'FontWeight','bold');
    set(t, 'FontSize', fsize, 'FontWeight', 'bold');
    set(gca,'FontSize', fsize,'FontWeight','bold');

    set(fig, 'Position', [225 279 800 419]);
    set(gcf,'Tag',[ratname '_psych_curve']);
else
    set(gcf,'Menubar','none','Toolbar','none','Position',[440   437   794   297]);
end;

% -------------------------------------------------------------------------
% Subroutines
% -------------------------------------------------------------------------


% does logistic fit for a single day
% There are two scenarios which affect output:
% 1. There weren't enough psych trials - weber is -1, points on psych curve
% are NaN and fit_failed is 1
function [bins fit_failed weber betahat xcomm xmid xfin ci replong_today tally_today] = ...
    sub__do_daily_psych_calc(binmin,binmax, num_bins,ispitch,tones,rep_long,psychthresh, ignore_trialtype)


if length(tones) < num_bins*2 % base case - no valid trials
      weber=-1;
    betahat=[0 0];
    xmid =NaN;xcomm=NaN; xfin=NaN;
    fit_failed=1;
    ci=NaN;
    replong_today=NaN(1,num_bins);
    tally_today=zeros(1,num_bins);
    bins=generate_bins(binmin,binmax, num_bins, 'pitches', ispitch);
    return;
end;
    
    
% need to do this for LHS endpoint;
% everything else is taken care of
[bins replong_today tally_today] = bin_side_choice(binmin, binmax, num_bins, ispitch, tones, rep_long);

if psychthresh > 0 && (ignore_trialtype == 0), low_tally = find(tally_today < 2);
else low_tally=[]; end;

if isempty(low_tally)
    % Now calculate weber for current session
    %out = weber_caller(bins, replong_today, tally_today, pitch,binmin, binmax);
    out = logistic_fitter('init',tones, rep_long, sqrt(binmin*binmax),ispitch);
    xcomm = out.xcomm;
    xmid = out.xmid;
    xfin = out.xfin;
    weber = out.weber;
    betahat = out.betahat;
    ci = out.ci;
    fit_failed = out.fit_failed;
else
    weber=-1;
    betahat=[0 0];
    xmid =NaN;xcomm=NaN; xfin=NaN;
    fit_failed=1;
    ci=NaN;
end;
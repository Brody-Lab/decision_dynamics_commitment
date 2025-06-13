function [weber bfit bias xx yy xmid xcomm xfin replong tally bins] = psychometric_curve(ratname, doffset, varargin)


pairs =  { ...
    % Filters & sending data to be plotted (instead of loading file and
    % computing from data therein) ----------------------------
    'drop_last', 0 ; ...    % ignore last X trials
    'trial_set', [] ;  ...  % allows user to provide preset trial numbers
    %    'psych_flag_date', '06/01/23' ; ...
    'replong_in', []  ; ... % Used to construct curve when given raw "reported long" values for bins
    'tally_in', [] ; ...    % Used to construct curve when given raw tallies for each bin
    'spoonfeed', 0 ; ...    % 1 means construct curve using given raw data of tally and replong
    % Data-related parameters (end points, task-related switches)--------
    'binmin', 0; ...
    'binmax', 0 ; ...
    'pitches', 0 ; ...      % 1 means use fields that store pitches
    'binsamp', 0 ; ...    % 1 means that tones are only equal to bin centers
    'num_bins', 8 ; ...
    'psychthresh', 0; ...   % throw away psych curves that don't have atleast two numbers in each bin. Set this to 1
    'flpstatus', 'Unflipped\nsides' ; ...
    % when a psych curve is discarded, the weber
    % ratio returned is -1
    % Which method to use to compute psych curve?
    'use_psignifit', 1 ; ... % when false, uses Matlab's nlinfit; when true, uses the psignifit toolbox
    'unlog_x', 0 ;...       % when true, x is brought back to stimulus units (out of log units)
    % Plot appearance -----------------------------
    'fsize', 12 ; ...
    'usefig', 0; ...        % when set to a figure handle, plots curve on provided figure. Does not do anything more than plot points and the spline
    'dont_format_axes', 0 ; ...
    'usedate', '0' ; ...    % ignore doffset and use supplied date
    'plotcurveonly', 0 ; ...
    'curvecolour', 'r'; ...
    'nodist', 0 ; ...       % 1 means don't print histogram of bin sizes
    'noplot', 0 ; ...       % 1 means don't plot anything
    'suppress_stdout', 0;...% 1 means don't output anything to stdout
    'graphic_getweber', 0 ; ... % 1 means plot the actual and stretched graph during weber calculations

    % passed by GUI callback only -------------
    'rlist', [] ; ...
    'plist', [] ; ...
    'dlist', [] ; ...
    };
parse_knownargs(varargin, pairs);

% if (use_psignifit > 0) && isempty(psignifit_in_path)
%     addpath('Analysis/duration_disc/psignifit/');
% end;

if usefig > 0
    nodist=1;
end;

ratrow = rat_task_table({ratname});
task = ratrow{1,2};

if ~isstr(doffset)
    if str2double(usedate) == 0,currdate=getdate(doffset);else    currdate = usedate;end;
else
    currdate=doffset;
end;
if ~suppress_stdout,fprintf(1, 'File date is: %s\n', currdate); end;

if ~strcmpi(computer, 'MAC'), fsize = 9; end;
if strcmpi(task, 'dual_discobj'),
    pitches = 1;
    mm = currdate(3:4);
    yy = currdate(1:2);
    if 0%(str2double(yy) < 8) && (str2double(mm) < 29)        
        [l h] = calc_pair('p',11.31,1.4,'suppress_out',suppress_stdout);
    else
        [l h]= calc_pair('p',11.31,1,'suppress_out',suppress_stdout);
    end;
    binmin =l; % 5.1
    binmax =h;%18.4; %17.6
    mybase = 2;
    unittxt='kHz';
    unitfmt = '%2.1f';
    roundmult  = 10;
elseif strcmpi(task, 'duration_discobj'),
    pitches = 0;
    [l h]= calc_pair('d',sqrt(200*500),0.95,'suppress_out',suppress_stdout);
    binmin =l; % 5.1
    binmax =h;%18.4; %17.6
    %  binmin=196.6401;
    %  binmax=508.4541;
    %  binmin = 300;
    %  binmax = 800;
    mybase = exp(1);
    unittxt = 'ms';
    unitfmt = '%i';
    roundmult = 1;
end;

if ~isstr(ratname)
    if nargin < 5   % src, event + 3 mandatory
        error('Either make the ratname a string, or give me more args!');
    end;
end;

if ~isempty(rlist)
    ratname = get(rlist, 'String'); ratname = ratname{get(rlist, 'Value')};
    task = get(plist, 'String'); task = [lower(task{get(plist, 'Value')}) 'obj'];t
    currdate = get(dlist, 'String'); currdate = currdate{get(dlist, 'Value')};
    binmin = str2num(get(binmin, 'String')); binmax = str2num(get(binmax, 'String'));
end;

if suppress_stdout == 0
fprintf(1,'******\n%s...\n', currdate);
end;
load_datafile(ratname, currdate);

% Set up tones array
if pitches == 0
    t1 = saved.ChordSection_tone1_list;
    t2 = saved.ChordSection_tone2_list;

    if binmin == 0
        t1from = saved_history.ChordSection_Tone_Dur1;
        temp_un = unique(cell2mat(t1from(2:end)));
        if length(temp_un) > 1
            error('Lower tone frequency was changed during the trials. Manually set a binmin value.');
        else
            binmin = temp_un*1000;
        end;
    end;

    if binmax == 0
        t2to = saved_history.ChordSection_Tone_Dur2;
        temp_un = unique(cell2mat(t2to(2:end)));
        if length(temp_un) > 1
            error('Upper tone frequency was changed during the trials. Manually set a binmax value.');
        else
            binmax = temp_un*1000;
        end;
    end;

else
    t1 = saved.ChordSection_pitch1_list;
    t2 = saved.ChordSection_pitch2_list;
end;


if isfield(saved_history, 'ChordSection_right_is_low')
    flipped = cell2mat(saved_history.ChordSection_right_is_low);
    if length(unique(flipped(2:end))) > 1,
        error('>1 flipped value. CHeck settings!');
    else
        flipped = flipped(2);
    end;
else
    flipped = 0;
end;
    

left = 1; right = 1-left;
tones = zeros(size(t1));
sides = saved.SidesSection_side_list;

left_trials = find(sides == left);
right_trials = find(sides == right);

USING_BLOCKS_SECTION = 0;

if isfield(saved_history, 'BlocksSection_Blocks_Switch') % file as of 0710
    block_switch = cell2mat(saved_history.BlocksSection_Blocks_Switch);
    if sum(block_switch) > 0 % Block_Switch implemented
        USING_BLOCKS_SECTION = 1;
        tone_list = saved.ChordSection_tones_list;
        tones(left_trials) = tone_list(left_trials);
        tones(right_trials) = tone_list(right_trials);
    else % var is there but this mode of psych sessions haven't been implemented
        tones(left_trials) = t1(left_trials);
        tones(right_trials) = t2(right_trials);
    end;
else
    tones(left_trials) = t1(left_trials);
    tones(right_trials) = t2(right_trials);
end;

% Set up "reported long array"
left_t = find(sides == left);
hh = eval(['saved.' task '_hit_history']); rep_long = hh;
rep_long(intersect(left_t, find(hh == 0))) = 1;
rep_long(intersect(left_t,find(hh==1))) = 0;

if flipped > 0
    rep_long = 1-rep_long;
    flipped =0;
    flpstatus = 'Flipped\nsides';
end;
   

the_day = [currdate(1:2) '/' currdate(3:4) '/' currdate(5:6)];

if isempty(trial_set)
    % now get psychometric trials
    if pitches > 0
        if USING_BLOCKS_SECTION
            psych_on = block_switch;
            psych = find(block_switch >0);
        else
            psych_on = saved_history.ChordSection_pitch_psych;
            psych = find(cell2mat(psych_on) > 0);
        end;
    else
        the_day = [currdate(1:2) '/' currdate(3:4) '/' currdate(5:6)];
        %         if datenum(the_day, 'yy/mm/dd') < datenum(psych_flag_date, 'yy/mm/dd')
        %             t1r = saved_history.ChordSection_Tone1_random;
        %             t2r = saved_history.ChordSection_Tone2_random;
        %             t1r = t1r(1:end-drop_last); t2r = t2r(1:end-drop_last); % drop last X trials here
        %             psych = intersect(find(strcmp(t1r,'on')), find(strcmp(t2r,'on')));
        %     else
        if USING_BLOCKS_SECTION
            psych_on = block_switch;
            psych = find(block_switch >0);
        else
            psych_on = saved_history.ChordSection_psych_on;
            psych = find(cell2mat(psych_on) > 0);
        end;
        %         end;
    end;
    contigs = make_contigs(psych);
    if cols(contigs) >1
        sprintf('Found > 1 contig of randomised trials; taking only the last one')
        trials = contigs{cols(contigs)};
    else
        trials = contigs{1};
    end;

    done_trials = eval(['saved.' task '_n_done_trials']);
    i = find(trials > done_trials);
    if ~isempty(i)
        trials = trials(1:i(1)-1);
    end;
else
    trials = trial_set;
end;


% Analyse only psychometric trials
rep_long = rep_long(trials);

if pitches  > 0
    tones = tones(trials);
else
    tones = tones(trials) * 1000;
end;

% need to do this for LHS endpoint; everything else is taken care of
[bins replong tally] = bin_side_choice(binmin, binmax, num_bins, pitches, tones, rep_long);

miniaxis = [bins(1), sqrt(binmin*binmax) bins(end)];
if pitches > 0
    mybins = log2(bins);
    hist__lblfmt = '%1.1f';
    hist__xlbl = 'Bins of frequencies (kHz)';
    psych__xtick = log2(miniaxis);
    psych__xlbl = 'Tone frequency (kHz)';
    if flipped > 0
        psych__ylbl = 'frequency of reporting "Low" (%)';
    else
        psych__ylbl = 'frequency of reporting "High" (%)';
    end;
    txtform =  '[%1.1f,%1.1f] kHz';
    unittxt = 'kHz';
    roundmult = 10;
    log_mp = log2(sqrt(binmin*binmax));
else
    mybins = log(bins);
    hist__lblfmt='%i';
    hist__xlbl = 'Bins of durations (ms)';
    psych__xtick = log(miniaxis);
    psych__xlbl = 'Tone duration (ms)';
    if flipped > 0
        psych__ylbl = 'frequency of reporting "Short" (%)';
    else
        psych__ylbl = 'frequency of reporting "Long" (%)';
    end;
    txtform =  '[%i,%i] ms';
    log_mp = log(sqrt(binmin*binmax));
    roundmult = 1;
end;
xlim=[mybins(1) mybins(end)];
mymin = round(binmin*roundmult)/roundmult;
mymax=round(binmax*roundmult)/roundmult;
hist__xtklbl = round(bins*roundmult)/roundmult;
psych__xtklbl = round(miniaxis * roundmult)/roundmult;

if spoonfeed > 0
    replong = replong_in;
    tally = tally_in;
    trials = ones(1, sum(tally));
end;
%out = weber_caller(bins, replong, tally, pitches,binmin, binmax);

% --------------------------------------------------------
% Fitting section
% --------------------------------------------------------

% Case 1 --- Not enough trials to fit data
low_tally = find(tally < 1);
if ~isempty(low_tally) % there are some bins missing data; ignore psych curve
    fprintf(1,'****\n');
    tally
    fprintf(1,'****\n');
    warning('Psychometric_curve.m:%s has at least one missing bin; skipping...\n',currdate);
    weber=NaN;
    bfit=[NaN NaN];
    xx=[]; yy=[]; xcomm=NaN; xfin=NaN; xmid=NaN;
    bias=NaN;
    fprintf(1,'******\n');
    return;
end;

out = logistic_fitter('init',tones, rep_long, sqrt(binmin*binmax),pitches,'graphic_getweber', graphic_getweber);
fnames = fieldnames(out);
for f = 1:length(fnames)
    eval([fnames{f} ' = out.' fnames{f} ';']);
end;
xx = interp_x;
yy = interp_y;
x=logtones;

% Case 2 --- Have enough data, but not a good logistic fit
if weber == -1
    warning('Psychometric_curve.m: %s had a very bad fit. Ignoring...\n',currdate);
    pct = replong ./tally;
    if noplot == 0
        if usefig == 0, figure; end;
        if nodist == 0
            subplot(1,2,1); hist(logtones, mybins);
            x=xlabel(hist__xlbl);set(x,'FontSize',16,'FontWeight','bold');
            set(gca,'XTick', mybins, 'XTickLabel', hist__xtklbl,...
                'XLim', [mybins(1)*0.99 1.01*mybins(end)], 'YLim', [0 1.1*max(tally)],...
                'FontSize', 16, 'FontWeight','bold');
            y=ylabel('Sample size (n)');set(y,'FontSize',16,'FontWeight','bold');
            t= title(sprintf('%s: %s (%s): \nTone sampling distribution (n=%i)', make_title(ratname), make_title(task), currdate, length(trials)));
            set(t, 'FontSize', 16, 'FontWeight','bold');

            subplot(1,2,2);
        end;
        l=plot(mybins, pct, '.r');
        if chitest_sig > 0,
            set(gca,'BackgroundColor','y');
        end;
        set(l,'MarkerSize',18);
        set(gca,'XTick',psych__xtick,'XLim', xlim, 'XTickLabel', psych__xtklbl, ...
            'YTick',0:0.25:1, 'YTickLabel', 0:25:100, 'YLim',[0 1], ...
            'FontSize',18,'FontWeight','bold');
        xlabel(psych__xlbl);
        ylabel(psych__ylbl);


        t = title(sprintf(['%s: %s (%s): \n[Min,Max] =' txtform ' (n=%i)'], make_title(ratname), make_title(task), currdate, mymin, mymax,length(trials)));
        set(t, 'FontSize', 14, 'FontWeight', 'bold');
    end;

    bfit = betahat;
    bias=0;

    sign_fname(gcf, mfilename);
    fprintf(1,'******\n');
    return;
end;

% Case 3 --- Have enough data & good logistic fit
bfit = betahat;

% If bias < 0,
% => my_mid - actual_mid < 0
% => my_mid < actual_mid
% => I have a RIGHT BIAS.
if pitches > 0
    bias = 2^(xmid)-2^(mp);
else
    bias = exp(xmid)-exp(mp);
end;
myxc = round((mybase^xcomm)*roundmult)/roundmult;
myxm = round((mybase^xmid)*roundmult)/roundmult;
myxf = round((mybase^xfin)*roundmult)/roundmult;

% don't plot, just return data
if noplot > 0,
    bfit = betahat;
    xmid = mybase^xmid;
    xcomm = mybase^xcomm;
    xfin = mybase^xfin;
    fprintf(1,'******\n');
    return;
end;

% print parameters of curve to stdout
if ~suppress_stdout
    fprintf(1,['Midpoint is: ' unitfmt '\n'], myxm);
    fprintf(1,['[25, 75]%% = [ ' unitfmt ' , ' unitfmt ' ] %s\n'], myxc,myxf,unittxt);
    fprintf(1,'Bias is: %1.1f\n', bias);
    fprintf(1,'Weber is: %1.2f\n', weber);
    %     fprintf(1,'Parameter estimates:\n');
    %     for i = 1:length(betahat)
    %         fprintf(1,'\t%d\n',betahat(i));
    %     end;
end;

% ---------------------------------------------
% Plotting begins here
% ---------------------------------------------
p = replong ./ tally;
variance = (p .* (1-p)) ./ tally;
stdev = sqrt(variance);

if usefig  == 0, fig = figure; set(fig, 'MenuBar','none', 'Toolbar', 'none');
else fig = usefig; end;

% plot tally of tones in each bin
curr_x = 0.07; curr_width = 0.4;

% histogram
if nodist==0
    axes('Position', [curr_x 0.2 curr_width 0.6]);
    bar(mybins, tally, 'stacked');
    lbl = cell(0,0);
    for k = 1:length(bins)
        h = text(mybins(k), tally(k)+1, int2str(tally(k)));
        set(h, 'FontSize',fsize,'FontWeight','bold');
        lbl{k} = sprintf(hist__lblfmt, bins(k));
    end;
    x=xlabel(hist__xlbl);set(x,'FontSize',16,'FontWeight','bold');
    set(gca,'XTick', mybins, 'XTickLabel', hist__xtklbl,...
        'XLim', [mybins(1)*0.99 1.01*mybins(end)], 'YLim', [0 1.1*max(tally)],...
        'FontSize', 16, 'FontWeight','bold');
    y=ylabel('Sample size (n)');set(y,'FontSize',16,'FontWeight','bold');
    t= title(sprintf('%s: %s (%s): \nTone sampling distribution (n=%i)', make_title(ratname), make_title(task), currdate, length(trials)));
    set(t, 'FontSize', 16, 'FontWeight','bold');
    curr_x = curr_x + 0.5;
else
    curr_x = 0.1; curr_width = 0.85;
end;

if usefig == 0
    if nodist == 0
        axes('Position', [curr_x 0.2 curr_width 0.6]);
    end;
else
    set(0,'CurrentFigure', usefig);
end;

% now for the psych curve

patch([min(mybins) min(mybins) max(mybins) max(mybins)], [0 0.1 0.1 0], [1 1 0.8],'EdgeColor','none');
hold on;
patch([min(mybins) min(mybins) max(mybins) max(mybins)], [1 0.9 0.9 1], [1 1 0.8],'EdgeColor','none');

% both binned points as well as fitted logistic
if plotcurveonly == 0
    l=errorbar(mybins, p, stdev, stdev, '.r');hold on;
    set(l,'Color',[0.4 0.4 0.4],'LineWidth',2,'MarkerSize',20);
end;

l=plot(xx, yy, '-r');
set(l,'LineWidth',2,'Color',curvecolour);
%         if chitest_sig > 0,
%             set(gca,'BackgroundColor','y');
%         end;
line([log_mp log_mp],[0 1], 'LineStyle',':','Color','k','LineWidth',2); % intended midpoint

fct=0.04;
line([xmid xmid], [0 0.5], 'LineStyle',':','Color','r','LineWidth',3); % rat's midpoint
line([0 xmid], [0.5 0.5], 'LineStyle',':','Color','r','LineWidth',3);
t=text(xlim(1)*1.001, 0.5+fct, sprintf(['x@50%%=' unitfmt ' ' unittxt], myxm));
set(t,'FontSize', 14,'FontAngle','italic','FontWeight','bold');

line([xcomm xcomm],[0 0.25], 'LineStyle',':','Color','r','LineWidth',3); % 25% mark
line([0 xcomm], [0.25 0.25],'LineStyle',':','Color','r','LineWidth',3);
t=text(xlim(1)*1.001, 0.25+fct, sprintf(['x@25%%=' unitfmt ' ' unittxt], myxc));
set(t,'FontSize', 14,'FontAngle','italic','FontWeight','bold');

line([xfin xfin], [0 0.75], 'LineStyle',':','Color','r','LineWidth',3);  % 75% mark
line([0 xfin], [0.75 0.75],'LineStyle',':','Color','r','LineWidth',3);
t=text(xlim(1)*1.001, 0.75+fct, sprintf(['x@75%%=' unitfmt ' ' unittxt], myxf));
set(t,'FontSize', 14,'FontAngle','italic','FontWeight','bold');

if strcmpi(task(1:3), 'dur'), offset = 0.965; else offset = 0.96;
end;
text(xlim(end)*offset, 0.1, sprintf(flpstatus), 'Color', [0 0 1],'FontWeight','bold','FontSize', 16);

if dont_format_axes == 0
    set(gca,'XTick',psych__xtick,'XLim', xlim, 'XTickLabel', psych__xtklbl, ...
        'YTick',0:0.25:1, 'YTickLabel', 0:25:100, 'YLim',[0 1], ...
        'FontSize',18,'FontWeight','bold');
    xlabel(psych__xlbl);
    ylabel(psych__ylbl);
    t = title(sprintf(['%s: %s (%s): \n[Min,Max] =' txtform ' (n=%i)'], make_title(ratname), make_title(task), currdate, mymin, mymax,length(trials)));
    set(t, 'FontSize', 14, 'FontWeight', 'bold');
end;

text(xlim(1)*1.005, 0.95, sprintf('weber=%2.2f', weber),'FontSize',18,'FontWeight','bold');

if unlog_x > 0
    if strcmpi(task(1:3),'dur')
        xx = exp(xx);
    else
        xx= 2.^x;
    end;
end;

if usefig == 0
    if nodist > 0, set(fig,'Position', [225 279 485 435]);
    else set(fig, 'Position', [225 279 800 419]); end;
else
    if pitches > 0, returnbins = log2(bins); else returnbins=log(bins); end;
    assignin('caller', 'bins', returnbins);
end;

%sign_fname(gcf, mfilename);
fprintf(1,'******\n');


set(gcf,'Menubar','figure');
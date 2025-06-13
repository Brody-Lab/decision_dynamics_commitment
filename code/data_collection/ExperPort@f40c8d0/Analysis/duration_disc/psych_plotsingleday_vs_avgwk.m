function [last_plotted_errbar last_plotted_pts txt_handle session_hrate overall_hrate] = psych_plotsingleday_vs_avgwk(ratname, datetoplot, varargin)

% Plot psych curve of manipulation (Single day/pooled/daily psych curves
% averaged) against a baseline average psych curve before manipulation.
%
% Example uses:
%
%% Plotting two manipulations atop the baseline
% psych_plotsingleday_vs_avgwk('Lascar', 'blah','maniptype',
% 'plot_pair','manip_pair1', 'none', 'pair1_color', [0 0 1],
% 'pair1_errcolor', [0.8 0.8 1],'pair1_text','nothing','from','080325')
%
%% Plot saline versus muscimol against baseline:
% psych_plotsingleday_vs_avgwk('Lascar', 'blah','maniptype', 'plot_pair')
%
%% Plot days of no manipulation starting from a certain date:
% psych_plotsingleday_vs_avgwk('Lascar','non-days','maniptype','none','from
% ','080324')
%
%% Plot average of session curves for all saline infusion days
% psych_plotsingleday_vs_avgwk('Lascar','Saline','maniptype','saline')

pairs = { ...
    % Parameters used to create psych curve ----------
    'numbins', 8; ...
    'maniptype', 'baseline' ; ... % [baseline | singleday | singleday_multi | none | muscimol | saline | anaesth | anyoldset | plot_pair]
    'do_preavg', 1 ; ... % when true, computes and plots average of last 7 sessions before manipulation
    'usefig', 0 ; ... % set this to indicate where you want manipulation data to be plotted (when do_preavg = 0)
    % Filters, pooling ----------
    'musc__conc_filter', 1 ; ... % use only days with muscimol [ ] < 'musc__conc_filter' mg/mL
    'from', '000000'; ...
    'to', '999999'; ...
    'pool_baseline', 0 ; ...
    'pool_alldays', 0 ; ... % when true, all days of manipulation are pooled and the psychometric
    'in_dateset', {}; ... % use for option 'singleday_multi'
    % curve is just taken for that one pool.
    % Options for plotting two manipulations on the same graph
    % as baseline -------------------------------------
    'curvecolor', 'r'; ...
    'manip_pair1', 'muscimol' ; ...
    'manip_pair2', 'none' ; ...
    'pair1_color', [1 0 0] ; ...
    'pair1_errcolor', [1 0.8 0.8]; ...
    'pair2_color', [0 0.5 0] ; ...
    'pair2_errcolor', [0.8 1 0.8]; ...
    'pair1_text', 'Muscimol'; ...
    'pair2_text', 'No infusion'; ...
    'lbl_y', 0.1; ... % y-pos at which to place text '# sessions = %i'
    % ---------------------------------------------------
    'graphic', 1; ... % set to 0 if you don't want to see plots
    'getalldata', 0 ; ... % set to 1 to have session_hrate be filled with a struct full of details about the psychometric curve
    'write2file', 0 ;... % set to 1 to write output to a file
    'usefid', 1 ; ... % if 0, makes a new file "mfilename_ratname". otherwise, writes to this fid
    };
parse_knownargs(varargin, pairs);

overall_hrate = NaN;


fname = [mfilename '_' ratname];
if write2file && usefid == 1
    global Solo_datadir;
    outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep ratname filesep];
    [outdir fname]
    try
        usefid = fopen([outdir fname '.txt'], 'w+');
    catch
        error('Cannot open file');
    end;
end;


ratrow = rat_task_table(ratname);
task = ratrow{1,2};

fprintf(usefid, '>>>>>>>> %s: %s\n', mfilename, maniptype);

if strcmpi(task(1:3),'dur')
    bins = [200 sqrt(200*500) 500];
    xtk = log(bins);
    xtklbl = round(bins);
    xaxlbl = 'Duration (ms)';
    mult = 0.95;
    logt = 'log(';
else
    bins = [8 sqrt(8*16) 16];
    xtk = log2(bins);
    xtklbl = round(bins*10)/10;
    xaxlbl = 'Frequency (kHz)';
    mult = 0.9;
    logt = 'log2(';
end;
binmin = bins(1); binmax = bins(end);

if do_preavg > 0
    if pool_baseline > 0
        dates =  ratrow{4};edit
        dateset = get_files(ratname, 'fromdate', dates{1}, 'todate', dates{2});
        lf = 6;
        if length(dateset) > lf+1
            dateset = dateset(end-lf:end);
        else
            last_few_pre = length(dateset);
        end;
        [dateset xx yy basebinvals basebins] = sub__pooledpsych(ratname, dateset, task, binmin, binmax, numbins);
        close gcf;
        figure;
        l = plot(xx,yy, '.k');
        last_plotted_errbar = l;
        last_plotted_pts = l;

        avgx = xx;
        avgy = yy;
        err=NaN;
    else
        [dateset avgx avgy err basebinvals basebins]= psychfits_oversessions(ratname, 'last_few_pre',7);
        if ~strcmpi(maniptype,'baseline'),     close gcf; end;

        figure;
        [last_plotted_errbar last_plotted_pts] = sub__drawbaselinegraph(gcf, avgx, avgy, err);
        %     last_plotted_errbar=errorbar(avgx, avgy, err, err,'.b'); hold on;
        %     set(last_plotted_errbar,'Color',[0.8 0.8 0.8],'LineWidth',1,'MarkerSize',2);
        %     last_plotted_pts = plot(avgx, avgy, '.k');
    end;

    eval(['basebins = ' logt  'basebins);']);

    set(gca,'YLim',[0 1], 'YTick', 0:0.25:1, 'YTickLabel',0:25:100, ...
        'XLim', [xtk(1) xtk(3)], 'XTick', xtk,'XTickLabel', xtklbl);

    t=xlabel(xaxlbl);
    fig = gcf;
    txt_handle=0;

    if strcmpi(maniptype,'singleday_multi'), close gcf; end;
end;

if strcmpi(maniptype,'baseline') > 0
    title(sprintf('%s: Baseline avg psych curve (%s to %s)', ratname, dateset{1}, dateset{end} ));
    axes__format(gca);

    return;
end;

switch maniptype
    case 'singleday'
        [weber bfit bias xx yy xmid xcomm xfin replong tally bins] = ...
            psychometric_curve(ratname,0,'noplot', 1,'usedate',datetoplot);

        set(0,'CurrentFigure', fig);
        hold on;
        plot(basebins, basebinvals, 'ok','MarkerSize', 9,'LineWidth',2);

        plot(xx,yy,'.r','Color',curvecolor);

        eval(['bins = ' logt  'bins);']);
        plot(bins, replong ./tally, 'or','MarkerSize', 9,'LineWidth',2,'Color', curvecolor);
        text(mult*xtk(3), 0.1, sprintf('n=%i',sum(tally)),'FontSize', 28,'FontWeight','bold');

        set(gca,'YLim',[0 1], 'YTick', 0:0.25:1, 'YTickLabel',0:25:100, ...
            'XLim', [xtk(1) xtk(3)], 'XTick', xtk,'XTickLabel', xtklbl);

        t=xlabel(xaxlbl);

        title(sprintf('%s:%s', ratname, datetoplot));
        axes__format(gca);
        sign_fname(gcf,mfilename);

    case 'singleday_multi'
        % collect baseline data
        base_x = avgx;
        base_y = avgy;
        base_err = err;

        for d = 1:length(in_dateset)

            [weber bfit bias xx yy xmid xcomm xfin replong tally bins] = ...
                psychometric_curve(ratname,0,'noplot', 1,'usedate',in_dateset{d});

            figure;
            if pool_baseline == 0
                [last_plotted_errbar last_plotted_pts] = sub__drawbaselinegraph(gcf, base_x, base_y, base_err);
            else
                plot(base_x,base_y,'.k');

            end;
            hold on;
            plot(basebins, basebinvals, 'ok','MarkerSize', 9,'LineWidth',2);

            plot(xx,yy,'.r','Color',curvecolor);

            eval(['bins = ' logt  'bins);']);
            plot(bins, replong ./tally, 'or','MarkerSize', 9,'LineWidth',2,'Color', curvecolor);
            text(mult*xtk(3), 0.1, sprintf('n=%i',sum(tally)),'FontSize', 28,'FontWeight','bold');

            set(gca,'YLim',[0 1], 'YTick', 0:0.25:1, 'YTickLabel',0:25:100, ...
                'XLim', [xtk(1) xtk(3)], 'XTick', xtk,'XTickLabel', xtklbl);

            t=xlabel(xaxlbl);

            title(sprintf('%s:%s', ratname, in_dateset{d}));
            axes__format(gca);
            sign_fname(gcf,mfilename);
        end;

    case 'anyoldset'
        if pool_alldays == 0
            [dateset avgx avgy err]= psychfits_oversessions(ratname, 'use_dateset', 'given', 'given_dateset', in_dateset, ...
                'color__range', 1);
            %    close gcf;
            set(0,'CurrentFigure', fig); hold on;
            l=errorbar(avgx,avgy, err,err, '.b');
            last_plotted_errbar = l;
            set(l,'Color',[1 0.8 0.8],'LineWidth',1,'MarkerSize',2);

            last_plotted_pts = plot(avgx, avgy, '.r');
        else
            [dateset xx yy] = sub__pooledpsych(ratname, in_dateset, task, binmin, binmax, numbins);
            close gcf;
            set(0,'CurrentFigure', fig); hold on;
            l = plot(xx,yy, '.b');
            last_plotted_errbar = l;
            last_plotted_pts = l;
        end;

        t=text(xtk(end)*mult, lbl_y, sprintf('%s(sess=%i)', upper(maniptype(1:2)), rows(dateset)));
        set(t,'FontSize',18,'FontWeight','bold');
        txt_handle =t ;

        if getalldata > 0
            out.avgx = avgx;
            out.avgy = avgy;
            out.err = err;
            session_hrate = out;
        end;


    case 'saline'
        salinedays = rat_task_table(ratname, 'action','cannula__saline');
        salinedays = salinedays(:,1);

        if do_preavg == 0
            if usefig == 0, fig = figure;
            else fig = usefig; end;
        end;

        out = psych_pooled_oversessions(ratname, 'use_dateset', 'given', 'given_dateset',salinedays, ...
            'daily_bin_variability', pool_alldays, ...
            'usefig', fig,'removefigtag', 1, 'justgetdata', 1, 'suppress_calcpair', 1, 'usefid', usefid);
        out.dateset = salinedays;
        set(0,'CurrentFigure', fig); hold on;
        last_plotted_errbar = out.plot_errorbar;
        last_plotted_pts = out.plot_interpol;
        numsessions = length(out.psychdates) + length(out.failedfit_dates);

        % now get timeout rate
        [st noto] = timeout_rate_oversessions(ratname, 'use_dateset','given','given_dateset', salinedays, ...
            'graphic', 0);

        out.session_to = st;
        out.pct_noto = noto;

        xtk = get(last_plotted_errbar, 'XData');
        t=text(xtk(end)*mult, lbl_y, sprintf('%s(sess=%i)',upper(maniptype(1:2)), numsessions));
        set(t,'FontSize',18,'FontWeight','bold');
        txt_handle = t;
        if getalldata > 0
            session_hrate = out;
        else
            session_hrate = out.session_hrate;
            overall_hrate = out.overall_hrate;
        end;

    case 'muscimol'
        if do_preavg == 0
            if usefig == 0, fig = figure;
            else fig = usefig; end;
        end;

        muscdays = rat_task_table(ratname, 'action','cannula__muscimol','filter_by_dose',0, 'usefid', usefid);
        %         idx = find(cell2mat(muscdays(:,3)) < musc__conc_filter);
        %         muscdays = muscdays(idx,:);
        d = muscdays(:,1);
        muscdoses = cell2mat(muscdays(:,3));
        muscdays = d;

        out = psych_pooled_oversessions(ratname, 'use_dateset', 'given', 'given_dateset',muscdays, ...
            'daily_bin_variability', pool_alldays, ...
            'usefig', fig,'removefigtag', 1, 'justgetdata', 1, 'suppress_calcpair', 1, 'usefid', usefid);
        out.dateset = muscdays;
        set(0,'CurrentFigure', fig); hold on;
        last_plotted_errbar = out.plot_errorbar;
        last_plotted_pts = out.plot_interpol;
        numsessions = length(out.psychdates) + length(out.failedfit_dates);

        % now get timeout rate
        [st noto] = timeout_rate_oversessions(ratname, 'use_dateset','given','given_dateset', muscdays, ...
            'graphic', 0);

        out.session_to = st;
        out.pct_noto = noto;
        out.doses = muscdoses;


        xtk = get(last_plotted_errbar, 'XData');
        t=text(xtk(end)*mult, lbl_y, sprintf('%s(sess=%i)',upper(maniptype(1:2)), numsessions));
        set(t,'FontSize',18,'FontWeight','bold');
        txt_handle = t;
        if getalldata > 0
            session_hrate = out;
        else
            session_hrate = out.session_hrate;
            overall_hrate = out.overall_hrate;
        end;
    case 'none'
        if do_preavg == 0
            if usefig == 0, fig = figure;
            else fig = usefig; end;
        end;

        ratrow = rat_task_table(ratname);
        postdates = ratrow{1,5};
        nondays = get_files(ratname, 'fromdate', postdates{1}, 'todate', postdates{2});

        %         if strcmpi(from,'000000')
        %             % start from first day post-baseline
        %             basedates =  ratrow{4}; str = basedates{2};
        %             from=yearmonthday(datenum(str2double(str(1:2)),str2double(str(3:4)),str2double(str(5:6)))+1);
        %         end;
        %         f = get_files(ratname, 'fromdate', from,'todate',to);
        %         manipdays = rat_task_table(ratname, 'action','cannula');
        %
        %       % Turn this line on to get the difference between manipulation days and a date range
        %       %  nondays  = setdiff(f, manipdays(:,1));
        %         nondays = manipdays(strcmpi(manipdays(:,2),'N'),1);

        out = psych_pooled_oversessions(ratname, 'use_dateset', 'given', 'given_dateset',nondays, ...
            'daily_bin_variability', pool_alldays, ...
            'usefig', fig, 'removefigtag', 1, 'justgetdata', 1,'suppress_calcpair', 1, 'usefid', usefid);
        out.dateset = nondays;

        % now get timeout rate
        [st noto] = timeout_rate_oversessions(ratname, 'use_dateset','given','given_dateset', nondays, ...
            'graphic', 0);

        out.session_to = st;
        out.pct_noto = noto;


        set(0,'CurrentFigure', fig); hold on;
        last_plotted_errbar = out.plot_errorbar;
        last_plotted_pts = out.plot_interpol;
        numsessions = length(out.psychdates) + length(out.failedfit_dates);

        xtk = get(last_plotted_errbar, 'XData');
        t=text(xtk(end)*mult, lbl_y, sprintf('%s(sess=%i)',upper(maniptype(1:2)), numsessions));
        set(t,'FontSize',18,'FontWeight','bold');
        txt_handle = t;
        if getalldata > 0
            session_hrate = out;
        else
            session_hrate = out.session_hrate;
            overall_hrate = out.overall_hrate;
        end;

    case 'anaesth'
        if do_preavg == 0
            if usefig == 0, fig = figure;
            else fig = usefig; end;
        end;

        ratrow = rat_task_table(ratname);
        manipdays = rat_task_table(ratname, 'action','cannula');
        andays = manipdays(strcmpi(manipdays(:,2),'A'),1);

        out = psych_pooled_oversessions(ratname, 'use_dateset', 'given', 'given_dateset',andays, ...
            'daily_bin_variability', pool_alldays, ...
            'usefig', fig, 'removefigtag', 1, 'justgetdata', 1,'suppress_calcpair', 1, 'usefid', usefid);
        out.dateset = andays;

        % now get timeout rate
        [st noto] = timeout_rate_oversessions(ratname, 'use_dateset','given','given_dateset', andays, ...
            'graphic', 0);

        out.session_to = st;
        out.pct_noto = noto;


        set(0,'CurrentFigure', fig); hold on;
        last_plotted_errbar = out.plot_errorbar;
        last_plotted_pts = out.plot_interpol;
        numsessions = length(out.psychdates) + length(out.failedfit_dates);

        xtk = get(last_plotted_errbar, 'XData');
        t=text(xtk(end)*mult, lbl_y, sprintf('%s(sess=%i)',upper(maniptype(1:2)), numsessions));
        set(t,'FontSize',18,'FontWeight','bold');
        txt_handle = t;
        if getalldata > 0
            session_hrate = out;
        else
            session_hrate = out.session_hrate;
            overall_hrate = out.overall_hrate;
        end;

    case 'all_four' % none, musc, and saline
        none_clr = [0 0 0];
        musc_clr = [1 0 0];
        sal_clr = [0 0.5 0];
        anaesth_clr = [1 1 1] * 0.3;

        if ~exist('fig','var'),
            fig =figure; end;

        % none
        [lerr lpt t nonedata ohrate1] = psych_plotsingleday_vs_avgwk(ratname, 'none', ...
            'maniptype', 'none', 'lbl_y', 0.3, 'do_preavg', 0, 'usefig', fig,...
            'from', from, 'to',to,'pool_alldays', pool_alldays,'write2file', write2file, 'usefid', usefid, ...
            'getalldata', 1);
        set(lerr,'Color', none_clr);
        set(lpt,'Color', none_clr);
        set(t,'Color', none_clr);

        hold on;
        [lerr lpt t saldata ohrate2] = psych_plotsingleday_vs_avgwk(ratname, 'saline', ...
            'maniptype', 'saline', 'lbl_y',0.2, 'do_preavg', 0,'usefig', fig,...
            'from', from, 'to',to,'pool_alldays', pool_alldays,'write2file', write2file, 'usefid', usefid, ...
            'getalldata', 1);
        set(lerr,'Color', sal_clr);
        set(lpt,'Color', sal_clr);
        set(t,'Color', sal_clr);

        [lerr lpt t muscdata ohrate3] = psych_plotsingleday_vs_avgwk(ratname, 'muscimol', ...
            'maniptype', 'muscimol', 'lbl_y',0.1, 'do_preavg', 0,'usefig', fig,...
            'from', from, 'to',to,'pool_alldays', pool_alldays,'write2file', write2file, 'usefid', usefid, ...
            'getalldata', 1);
        set(lerr,'Color', musc_clr);
        set(lpt,'Color', musc_clr);
        set(t,'Color', musc_clr);

        [lerr lpt t andata ohrate4] =  psych_plotsingleday_vs_avgwk(ratname, 'anaesth', ...
            'maniptype', 'anaesth', 'lbl_y',0.4, 'do_preavg', 0,'usefig', fig,...
            'from', from, 'to',to,'pool_alldays', pool_alldays,'write2file', write2file, 'usefid', usefid, ...
            'getalldata', 1);

        datetoplot = 'No infusion, Saline, Muscimol, and Anaesthesia';
        set(gcf,'Position',[526   301   522   378]);
        fig = gcf;

        % now return the hit rates to the calling function
        out = 0;
        out.none = nonedata;
        out.saline = saldata;
        out.muscimol = muscdata;
        out.anaesth = andata;


        out.pair2_overall_hrate = ohrate2;

        last_plotted_errbar = out;
        set(0,'CurrentFigure', fig);


    case 'plot_pair'
        if ~exist('fig','var'),
            fig =figure; end;


        [lerr lpt t shrate1 ohrate1] = psych_plotsingleday_vs_avgwk(ratname, pair1_text, ...
            'maniptype', manip_pair1, 'lbl_y', 0.2, 'do_preavg', 0, 'usefig', fig,...
            'from', from, 'to',to,'pool_alldays', pool_alldays,'write2file', write2file, 'usefid', usefid);
        set(lerr,'Color', pair1_color);
        set(lpt,'Color', pair1_color);
        set(t,'Color', pair1_color);

        hold on;
        [lerr lpt t shrate2 ohrate2] = psych_plotsingleday_vs_avgwk(ratname, pair2_text, ...
            'maniptype', manip_pair2, 'do_preavg', 0,'usefig', fig,...
            'from', from, 'to',to,'pool_alldays', pool_alldays,'write2file', write2file, 'usefid', usefid);
        set(lerr,'Color', pair2_color);
        set(lpt,'Color', pair2_color);
        set(t,'Color', pair2_color);

        datetoplot = [ pair1_text ' and ' pair2_text ];
        set(gcf,'Position',[526   301   522   378]);
        fig = gcf;

        %         % plot difference in hit rate of both sets
        %         msize = 35;
        %         figure;
        %         errorbar(1, mean(shrate1), std(shrate1), std(shrate1), 'Color', pair1_color,'MarkerSize', msize,'LineWidth',2); hold on;
        %         errorbar(2, mean(shrate2), std(shrate2), std(shrate2), 'Color', pair2_color,'MarkerSize', msize,'LineWidth',2);
        %         plot([1 2], [mean(shrate1) mean(shrate2)], '.r', 'Color', 'k','MarkerSize', msize,'LineWidth',2);
        %         set(gca,'XLim',[0.8 2.2], 'YLim',[0.5 1], 'YTick', 0.5:0.25:1, 'YTickLabel', 50:25:100);
        %         set(gca,'XTick', [1 2],'XTickLabel', { pair1_text, pair2_text});
        %         ylabel('Session hit rate (%)');
        %         axes__format(gca);

        % now return the hit rates to the calling function
        out = 0;
        out.pair1_session_hrate = shrate1;
        out.pair2_session_hrate = shrate2;
        out.pair1_overall_hrate = ohrate1;
        out.pair2_overall_hrate = ohrate2;

        last_plotted_errbar = out;
        set(0,'CurrentFigure', fig);

    otherwise
        error('maniptype should be one of: [ singleday | muscimol | saline ] ');
end;

if ~strcmpi(maniptype,'singleday_multi')
    pfx1 = '';
    if do_preavg > 0, pfx1 = 'PRE averaged compared to'; end;
    title(sprintf('%s: %s %s', ratname, pfx1, datetoplot));
    axes__format(gca);
    sign_fname(gcf,mfilename);
end;




% ------------------------------------------
% Subroutines
% ------------------------------------------
function [used_dates xx yy binvals bins] = sub__pooledpsych(ratname, dateset, task, binmin, binmax, numbins)

if strcmpi(task(1:3),'dur')
    leftf = 'dur_short'; rightf ='dur_long';
    ispitch=0;
else
    leftf = 'pitch_low'; rightf='pitch_high';
    ispitch=1;
end;

datafields = { 'blocks_switch', 'sides', leftf, rightf};

get_fields(ratname, 'use_dateset', 'given', 'given_dateset', dateset, ...
    'datafields',datafields);

%dateset = dates;

eval(['left_tone = ' leftf ';']);
eval(['right_tone =' rightf ';']);

in={};
in.dates = dates;
in.numtrials = numtrials;
in.binmin=binmin;
in.binmax=binmax;

in.ltone=left_tone;
in.rtone=right_tone;
in.slist = sides;
in.psych_on = blocks_switch;
in.hit_history = hit_history;

fprintf(usefid, '*** \n');
fprintf(usefid, '*** WARNING: flipped flag not yet implemented!\n');
fprintf(usefid, '*** \n');
in.flipped = zeros(size(hit_history));

out = psych_oversessions(ratname,in, ...
    'justgetdata',1,'pitch', ispitch,...
    'psychthresh',1,'num_bins', numbins,...
    'noplot', 1);

if length(out.psychdates) < length(dateset)
    fprintf(usefid, '*** WARNING!!! Some dates were excluded from pooling:\n');
    df = setdiff(1:length(dateset), out.psychdates);
    for bctr=1:length(df), fprintf(usefid, '\t%s\n', dateset{df(bctr)}); end;
end;
fprintf(usefid, '*********\n');

used_dates = dateset(out.psychdates);

xx = out.xx;
yy = out.yy;
weber = out.overall_weber;
% tones = out.concat_tones;
% side_choice = out.concat_side_choice;
replongs = sum(out.replongs);
tallies = sum(out.tallies);

binvals = replongs ./tallies;
bins =out.bins;


% subroutine to draw baseline the standard way (black line, greay error
% bars)
function [lerr lpts] = sub__drawbaselinegraph(fig, avgx, avgy, err)
tmpfig = get(0,'CurrentFigure');
set(0,'CurrentFigure', fig);

% test print
%fprintf(usefid, 'peekaboo!\n');


lerr=errorbar(avgx, avgy, err, err,'.b'); hold on;
set(lerr,'Color',[0.8 0.8 0.8],'LineWidth',1,'MarkerSize',2);
lpts = plot(avgx, avgy, '.k');

txt_handle=0;

set(0,'CurrentFigure', tmpfig);




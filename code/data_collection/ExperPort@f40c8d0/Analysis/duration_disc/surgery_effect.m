function [bdates adates bhits ahits adatenums] = surgery_effect(ratname,varargin)
% Looks at a number of metrics before and after surgery.
% Ideally, the date ranges for 'before' and 'after' are those from columns
% in rat_task_table.
% However, this script relies on input files saved using another script
% (savepsychinfo) and will only use fieldnames saved during the running of
% that script.
% Default file names:
% File containing BEFORE data: psych_before
% File containing AFTER data: psych_after

%
% Cascade of scripts:
%   surgery_effect
%       |-- loadpsychinfo
%           | -- psych_oversessions ---> plots psych curve
pairs = { ...
    'before_file', 'psych_before'; ...
    'after_file', 'psych_after'; ...
    'ACxround1', 0  ; ... % set to 1 for round 1 ACx rats
    'preflipped', 0 ; ... % set to 1 for old rats lacking 'flipped' field
    'psych_session', 1; ... % set to 0 for rats which were lesioned during sharpening stage
    'graphic', 1 ; ... % set to 0 to not show before/after bar graphs
    'numMetrics', 5 ; ... % used to be 6, but apoke_dur is no longer computed.
    'numMetricsShow', 5 ; ...
    'assess_normality', 0 ; ... % when set, runs Kolmogrov-Smirnov tests on each of the metrics to assess normality
    % What sessions to use? -------------------
    'first_day_post', 0 ; ... % when set, compares pre-lesion data only to the data from the first day after lesion
    'eliminate_Mondays', 0 ; ... % when set, does not use sessions that fall on a Monday
    'do_sigtest', 0 ; ...
    'days_before', [1 1000]; ... % which session in the set to use?
    'days_after', [1 3]; ...
    'lastfew_before', 7;... % set this parameter to use the last X sessions BEFORE lesion
    'lastfew_after', 1000; ... % set this parram to use last X sessions AFTER lesion
    'psychthresh', 1 ; ...  % set to 1 to ignore dates where there are < 2 values in a given bin
    'postpsych', 0 ; ... % set to 1 to limit dateset to those with sufficient # psych trials
    'ignore_trialtype', 0 ; ... % set to 1 to include all trials, inc. non-psych
    'daily_bin_variability', 0 ; ... % see psych_oversessions for description.
    % --- appearance ---
    'psychgraph_only', 0 ; ... % set to 1 to return only the before/after curves
    'compute_sig', 0 ; ... % set to 1 to compute significance of before/after
    'return_residuals', 0 ; ... % set to 1 to return residuals ... and return.
    'reject_null_colour','r' ; ...
    'dont_reject_colour', 'b'; ...
    'figwidth', 300; 'figheight', 200; ...
    % --- flags to hide/show different graphs
    'showhist', {} ;... % 1x2 cell array; 1 - array to be histogrammed; 2- title for histogram; 3 - xlabel
    'closehist', 0; ... % close all figures tagged 'metric_hist'
    'nopsych', 0 ; ... % when 1, closes window showing before/after psych curves
    'histweber_only',0; ... % when 1, only graph that comes up is the distribution of webers before and after
    'verbose', 0 ;... % print summary data on stdout.
    % --- output of variables ---------
    'output_vars', 0 ; ... % used by invoking scripts
    % will retrieve before/after pooled values, significance for each task metric
    % also session counts for before/after metrics
    % also parameter estimates and CI for before & after
    };

% All of the data fields are stored 2-column cell arrays.
% Column 1 contains data for BEFORE surgery.
% Column 2 contains data for corresponding metric AFTER surgery
BEFORE_COL = 1;
AFTER_COL = 2;

fnames = {'discriminability_points',...
    'overall_webers','overall_betahats','overall_cis', ...
    'webers','betahats','bias_cell','proportions',...
    'sessdates','pdates','failed_cell'...
    'rawhh_cell', 'means_hh_cell','sem_hh_cell','lds_cell', ...
    'vanilla_cell','psych_cell','vanilla_hits','psych_hits',...
    'cpoke_dur','apoke_dur','timeout_cell', 'rxn_cell',...
    'replongs_cell','tallies_cell', ...
    'alltones_cell','allsidechoices_cell',...
    'bininfo_cell','xx_cell','yy_cell','bins_cell'};

for f = 1:length(fnames)
    eval([ 'persistent ' fnames{f} ';']);
end;

if isstr(ratname) % not a callback
    parse_knownargs(varargin,pairs);
else % callback - ignore first two arguments
    parse_knownargs(varargin(2:end), pairs);
end;

if isstr(ratname) % not a callback; load data
    % initialize all cells
    for f = 1:length(fnames)
        eval([ fnames{f} ' = {[] []};']);
    end;
    % arrays to print out
    ratrow = rat_task_table(ratname);
    task=ratrow{1,2};
    %    datafields = {'webers', 'bias_cell', 'cpoke_dur', 'vanilla_hits','psych_hits','rxn_cell' };
    %    data_titles = {'Weber ratio', 'Side bias', ...
    %        'Time till Trial Initiation', 'Hits (non-psych)','Hits (psych)','Rxn Time'};
    %    data_ylbls = {'(SD)', 'milliseconds (SD)', 'seconds (SD)','%','%','milliseconds (SD)'};

    datafields = {'webers','vanilla_hits','psych_hits'};
    data_titles= {'Weber ratio', 'Hits (non-psych)','Hits(psych)'};
    data_ylbls = {'(SD)', '%','%'};
    %     if strcmpi(task(1:3),'dur')
    %         datafields{end+1} = 'timeout_cell';
    %         data_titles{end+1} = '% No Timeouts';
    %         data_ylbls{end+1} = '# TOs per session';
    %     end;
    % close all figures save the assumptions one.
    close(findobj('Tag','normplot'));
    close(findobj('Tag', 'metric_hist'));
    close(findobj('Tag', 'eqvar'));
%     close(findobj('Tag', 'psych'));
    close(findobj('Tag', 'psychcount'));
    close(findobj('Tag', 'weber_hist'));
    close(findobj('Tag','num_points'));
    close(findobj('Tag','parci_plot'));

    vanilla_hits = {};
    psych_hits={};

    numMetrics = length(datafields);
    numMetricsShow = length(datafields);

    % ---------------------------------------------------------------------
    % Collect data from before/after files
    % ---------------------------------------------------------------------
    file_list = {before_file, after_file};
    % set up date limits
    datelim_names = {'days_before','days_after'};
    last_names = {'lastfew_before', 'lastfew_after'};
    msg = {'BEFORE:\n', 'AFTER:\n'};

    for f_col = [BEFORE_COL AFTER_COL]
        darray = eval(datelim_names{f_col});

        fprintf(1,'%s',msg{f_col});
        if f_col == 2,   
            set(0,'CurrentFigure',f); 
            patch_bounds=0;
        else
            patch_bounds=0;
        end;
        
        if f_col == 1, isafter=0; else isafter=1;end;
                
        loadpsychinfo(ratname, 'infile', [ratname '_' file_list{f_col}], 'justgetdata',1,...
            'ACxround1', ACxround1, ...
            'preflipped', preflipped, ...
            'psychthresh',psychthresh,...
            'postpsych', postpsych, ... 
            'ignore_trialtype', ignore_trialtype, ...
            'isafter', isafter, ...
            'dstart', darray(1), 'dend', darray(2),'lastfew', eval(last_names{f_col}),...
            'eliminate_Mondays', eliminate_Mondays,...
            'daily_bin_variability', daily_bin_variability, 'patch_bounds', patch_bounds);


        if f_col == 1
            f=gcf;
            %             set(gcf,'Position', [321   376   663   448]);
        else
            set(gcf,'Position',[250 250 800 600],'Tag','psych');
            set(gca,'Position',[0.1 0.1 0.8 0.8]);
        end;

        weber = weber';
        bias_val = bias_val';
        
        means_hh = means_hh';
        sem_hh = sem_hh';

        discriminability_points{:,f_col} = horzcat(xcomm', xmid', xfin');
        betahats{:,f_col} = betahat;
        webers{:,f_col} = weber;
        bias_cell{:,f_col} = bias_val;
%         cpoke_dur{:,f_col} = cpoke_stats;
%         apoke_dur{:,f_col} = apoke_stats;
        rawhh_cell{:,f_col} = concat_hh;
        means_hh_cell{:,f_col} = means_hh;
        sem_hh_cell{:,f_col} = sem_hh;
        lds_cell{:,f_col} = lds;
        sessdates{:,f_col} = dates;
        overall_webers{:,f_col}=overall_weber;
        pdates{:,f_col} = psychdates;
        failed_cell{:,f_col} = failedfit_dates;
        blah_cell{:,f_col} = ones(10,1);
        overall_betahats{:,f_col} = overall_betahat;
        overall_cis{:,f_col} = overall_ci;
        rxn_cell{:,f_col}=rxn;
        replongs_cell{:,f_col} = replongs;
        tallies_cell{:,f_col} = tallies;
        alltones_cell{:,f_col} = concat_tones;
        allsidechoices_cell{:,f_col} = concat_side_choice;
        bininfo_cell{:,f_col} = [binmin binmax num_bins];
        xx_cell{:,f_col} = xx;
        yy_cell{:,f_col} = yy;     
        bins_cell{:,f_col} = bins;

        % compute other metrics
        if strcmpi(task(1:3),'dur')
            try
            timeout_cell{:,f_col}= pct_noto;
            catch
                timeout_cell{:,f_col}=NaN(size(concat_hh));
            end;
            ispitch=0;
        else
            ispitch=1;
        end;
        
        if psychgraph_only == 0
        % vanilla & psych for before
        [vh ph] = hitrate_breakdown(ratname, 'infile',file_list{f_col},'psychthresh',psychthresh,...
            'psychdates',pdates{:,f_col},'dstart',darray(1),'dend',darray(2),'lastfew', eval(last_names{f_col}));
        vanilla_cell{:,f_col} = vh;
        psych_cell{:,f_col} = ph;

        if isstr(weber) && isstr(bias_val)
            if ~isempty(ph)
                error('Inconsistent. If weber and bias_val are empty, psych_cell should be, too!');
            end;
            numMetrics = numMetrics -3 ;
        end;

        % make _hits arrays
        tmp = vanilla_cell{:,f_col};
        tmp = cell2mat(tmp(:,1));
        vanilla_hits{f_col} = tmp(find(~isnan(tmp)));


        tmp = psych_cell{:,f_col};
        if ~isempty(tmp)
            psych_hits{f_col} = cell2mat(tmp(:,1));
        else
            psych_hits{f_col} = -1;
        end;
        end;
    end;
    % end FOR loop where before/after vars are collected
    
    bdates = pdates{:,1};
    adates = pdates{:,2};
    
    bhits = rawhh_cell{:,1}; ahits = rawhh_cell{:,2};
    
    % Compute significance of difference between before and after curve
    bins = get(gca,'XTick');
    before_data ={};
    before_data.tones = alltones_cell{:,1};
    before_data.side_choices = allsidechoices_cell{:,1};
    
    after_data ={};
    after_data.tones = alltones_cell{:,2};
    after_data.side_choices = allsidechoices_cell{:,2};
    
    if strcmpi(task(1:3),'dua'), bins = 2.^bins; else bins = exp(bins); end;
    if compute_sig > 0
    [sig_curve p_curve] = permutationtest_psychcurves(before_data, after_data, binmin, binmax, num_bins, strcmpi(task(1:3), 'dua'));
    else 
        sig_curve =NaN;
        p_curve=NaN;
    end;

    % set position for figure with before/after psych curves
    set(gcf, 'Position',   [20 350 480 450]);
    set(gca,'Position',[0.15 0.15 0.8 0.75]);
    set(gca,'FontSize',18);
    set(get(gca,'XLabel'),'FontSize',24);
    set(get(gca,'YLabel'),'FontSize',18);
    set(get(gca,'title'),'FontSize',20);
    xtick = get(gca,'XTick');
    xmin=xtick(1); xmax=xtick(end);
    xmid = (xmin+xmax)/2;
    if strcmpi(task(1:3),'dua')
        set(gca,'XTick', [xmin xmid xmax], 'XTickLabel', round(2.^[xmin xmid xmax] * 10)/10);
    else
        set(gca,'XTick', [xmin xmid xmax], 'XTickLabel', round(exp([xmin xmid xmax])));
    end
    
    set(gca,'XLim',[xmin xmax], 'YLim', [0 1]);

    % if any parameter estimates for AFTER fall OUTSIDE the conf. interval
    % of those for BEFORE, set background to yellow -- the two curves are
    % different.
    bh2 = overall_betahats{:,2};
%     ci= overall_cis{:,1};    % get CI for 'before' estimates
%     for i = 1:length(bh2)
%         if bh2(i) < ci(i,1) || bh2(i) > ci(i,2)
% %            fprintf(1,'***PARAMETER %i is DIFFERENT in AFTER curve***\n', i);
%             % set(gca,'Color','y');
%         end;
%     end;

    f = findobj('Parent',gcf,'Tag','figname');
    for fidx = 1:length(f)
        delete(f(fidx));
    end;
    
    uicontrol('Tag', 'figname', 'Style','text', 'String', sprintf('%s_beforeafter_psych',ratname), 'Visible','off');
    if psychgraph_only > 0
        assignin('caller','sig_curve', sig_curve);
        assignin('caller','p_curve', p_curve);
        return;
        sign_fname(gcf,mfilename);
    end;
    
    % This is end of execution when psychgraph_only flag is set.
    % -------------------------------------------------------------------
%     return;

    % compute residuals over days.
    rep_before = sum(replongs_cell{:,1});
    tallies_before = sum(tallies_cell{:,1});
    pct_before = rep_before ./ tallies_before;

    pct_after = {};
    rep_after = replongs_cell{:,2};
    tallies_after = tallies_cell{:,2};
    for k = 1:rows(rep_after)
        if sum(tallies_after(k,:)) > 0
        pct_after{end+1} = rep_after(k,:) ./ tallies_after(k,:);
        else
            pct_after{end+1} = -1;
        end;
    end;

    res=psych_residuals(pct_before, pct_after);
%    filled_res = (ones(size(dates))*-1)';
%    not_failed = ~ismember(1:length(dates),failed_dates);
%    filled_res(find(not_failed > 0)) = res;

    if return_residuals > 0
        assignin('caller','residuals', res);
        assignin('caller','failed_dates', failed_dates);
        return;
    end;


    % From here on, plot other measures of performance from before and
    % after
    if ~isempty(timeout_cell{:,1}) && graphic > 0
        plot_me(4,timeout_cell{:,1}, timeout_cell{:,2}); set(gcf,'Tag','metric_hist','Position',[1000 700 330 130],'Toolbar','none');
        title(sprintf('%s: %% Session with no timeouts',ratname));
    end;
    if graphic > 0
        try
        plot_me(4,rxn_cell{:,1},rxn_cell{:,2});  set(gcf,'Tag','metric_hist','Position',[1000 500 330 130],'Toolbar','none');
        catch
            addpath('Analysis/duration_disc/stat_sandbox/');
                    plot_me(4,rxn_cell{:,1},rxn_cell{:,2});  set(gcf,'Tag','metric_hist','Position',[1000 500 330 130],'Toolbar','none');
        end;
        title(sprintf('%s: Reaction time',ratname));
    end;

    % now trim means_hh_cell & sem_hh_cell to
    % only have those logdiffs in
    % common
    [common idx_before idx_after] = intersect(lds_cell{:,BEFORE_COL}, lds_cell{:,AFTER_COL});
    tmp = means_hh_cell{:,BEFORE_COL};
    means_hh_cell{:,BEFORE_COL} = tmp(idx_before);
    tmp = sem_hh_cell{:,BEFORE_COL};
    sem_hh_cell{:,BEFORE_COL} = tmp(idx_before);
    lds_cell{:,BEFORE_COL} = common;

    tmp = means_hh_cell{:,AFTER_COL};
    means_hh_cell{:,AFTER_COL}  = tmp(idx_after);
    tmp = sem_hh_cell{:,AFTER_COL};
    sem_hh_cell{:,AFTER_COL} = tmp(idx_after);
    lds_cell{:,AFTER_COL} = common;

    if graphic > 0,set(gcf,'Tag', 'psych');end;

    % ----------------------------------
    % Figure 3: # datapoints (sessions) for each metric
    % ----------------------------------
    if graphic > 0
        sz = []; % col 1- before; col2 - after
        for k = 1:length(datafields)
            tmp_b = eval([datafields{k} '{:,' num2str(BEFORE_COL) '}']);
            tmp_a = eval([datafields{k} '{:,' num2str(AFTER_COL) '}']);
            sz = vertcat(sz, [length(tmp_b), length(tmp_a)]);
        end;

        pcount_bef = length(pdates{:,BEFORE_COL});
        pcount_aft = length(pdates{:,AFTER_COL});

        figure; set(gcf,'Position',[1 150 650 150],'Toolbar','none','Tag','num_points');
        %  axes('Position',[0.05 0.1 0.8 0.75]);
        p=bar(1:rows(sz), sz(:,BEFORE_COL),0.5);
        set(p,'FaceColor',[170 255 255] ./255,'EdgeColor',[0 0 104]./255);
        ylabel('# Sessions');

        hold on;
        p2=bar(1:rows(sz), sz(:,AFTER_COL),0.25);
        set(p2,'FaceColor',[163 52 60]./255,'EdgeColor','none');

        %plot([-1 0], [pcount_bef pcount_aft], 'og');

        %   text(-1.5, pcount_bef-5, sprintf('# psych\nbefore'));
        %    text(-0.5, pcount_aft-5, sprintf('# psych\nafter'));
        set(gca,'XTick', 1:rows(sz), 'XTickLabel', datafields,'XLim',[0.5 rows(sz)+0.5], 'YLim',[0 max(max(sz))+1] );
        t=title('# datapoints for each metric');set(t,'FontSize',12,'FontWeight','bold');
%        uicontrol('Tag', 'figname', 'Style','text', 'String', sprintf('%s_beforeafter_datacount',ratname), 'Visible','off');
sign_fname(gcf,mfilename);
    end;
end;

% ----------------------------------
% Figure 4: Bar graph of before/after average values for each of the five
% performance metrics
% ----------------------------------
if graphic > 0
    figure;
    % plot top row of bar graph (mean hitrate for different situations)
    set(gcf,'Position', [65   863   220*numMetrics   221],'Tag', 'normplot');
   % uicontrol(gcf, 'Style','text', 'String', ratname, 'Position',[50 570 300 20],'FontSize',14, 'FontWeight','bold', 'BackgroundColor', [171/255 186/255 122/255]);
    dbef = sessdates{:,BEFORE_COL}; daft = sessdates{:,AFTER_COL};
    dstr = sprintf('Performance before (%s-%s)\n & after (%s-%s) surgery',dbef{1}, dbef{end}, daft{1}, daft{end});
    %uicontrol(gcf, 'Style','text', 'STring', dstr, 'Position',[50 550 300 20], 'FontWeight','bold', 'BackgroundColor', [171/255 186/255 122/255]);

    alphaval = 0.05/numMetrics;
    axes_width = 0.75 /numMetricsShow;
    axes_ht = 0.75;
    p_array = [];

    for f = 1:length(datafields)
        str=datafields{f};
        bef = eval([str '{:,BEFORE_COL}']);
        aft = eval([str '{:,AFTER_COL}']);

        p=bargraph_metric_compare(bef,aft, f, axes_width, axes_ht,alphaval, data_titles{f},data_ylbls{f});
        p_array = horzcat(p_array, p);
    end;
    uicontrol(gcf,'Style','text','String', ratname,'Units','normalized','Position',[0.01 0.88 0.1 0.1],'BackgroundColor','w',...
        'FontSize',16,'ForegroundColor',[0 140/255 204/255],'FontWeight','bold');
    uicontrol(gcf,'Style','text','String', sprintf('alpha=%1.3f',0.05/numMetrics),...
        'Units','normalized','Position',[0.8 0.01 0.15 0.1],'BackgroundColor','w',...
        'FontSize',16,'FontWeight','bold');
    %uicontrol('Tag', 'figname', 'Style','text', 'String', sprintf('%s_beforeafter_means',ratname), 'Visible','off');
    sign_fname(gcf,mfilename);
end;

% if nopsych >0, close(findobj('Tag','psych')); end;

% Plot overall weber - before is blue, after is red.
if graphic > 0
    plot_weber_hist(ratname, webers, overall_webers,BEFORE_COL, AFTER_COL);
end;

% Section where normality is assessed for each performance metric
if assess_normality > 0, do_normality_plot(); end;% we'll fix this when we need this
% show significance of before/after metric differences for those metrics
% that were manually shown to meet assumptions
if do_sigtest > 0,do_hitsigs_only();end; % we'll fix this when we need this

% show histogram for metric distribution across sessions
if length(showhist) > 0 && graphic > 0
    figure; set(gcf,'Tag','metric_hist',...
        'Position',[  826   147   427   274],'Toolbar','none');
    hist(showhist{1});
    t=title(showhist{2});set(t,'FontSize',12,'FontWeight','bold');
    t=xlabel(showhist{3});    set(t,'FontSize',12,'FontWeight','bold');
    t=ylabel('Session #');    set(t,'FontSize',12,'FontWeight','bold');
    set(gca,'FontSize',12);
end;
if closehist > 0
    f =findobj('Tag', 'metric_hist');
    close(f);
end;

if histweber_only >0
    % close all figures save the assumptions one.
    close(findobj('Tag','normplot'));
    %    close(findobj('Tag', 'metric_hist'));
    close(findobj('Tag', 'eqvar'));
    close(findobj('Tag', 'psych'));
    close(findobj('Tag', 'psychcount'));
end;

% Compare parameter estimates for 'AFTER' curve to those for 'BEFORE'
% curve; do the latter fall within the confidence interval of the former?
ci = overall_cis{:,1}; bh = overall_betahats{:,1};
if graphic > 0
    figure; set(gcf,'Position',[10 2 300 150],'Toolbar','none','Tag','parci_plot');
    for idx = 1:length(bh)
        c = ci(idx,:);
        p=patch([idx-0.2 idx-0.2 idx+0.2 idx+0.2], [c(1) c(2) c(2) c(1)], [0.7 0.7 0.7]);
        hold on;
        set(p,'EdgeColor','none');
        line([idx-0.2 idx+0.2], [bh(idx) bh(idx)], 'LineWidth',2,'Color',[0.4 0.4 0.4]);
        % fprintf(1,'Width of ci for %i = %1.3f\n', idx, abs(c(2)-c(1)));

    end;
    %l=errorbar(1:length(bh),bh, ci(:,1), ci(:,2),'.r');
    %set(l,'Color',[0.4 0.4 0.4]);

    hold on;
    bh2 =overall_betahats{:,2};
    l=plot(1:length(bh2), bh2, '^b');
    set(l,'Color', [1 0 0],'MarkerSize',10);
    %legend({'Before', 'After'},'boxoff');
    set(gca,'XTick',1:4,'XTickLabel',{'Pmax','m','n','Rise rate'});
    set(get(gca,'XLabel'),'FontSize',18,'FontWeight','bold');
    set(get(gca,'YLabel'),'FontSize',18,'FontWeight','bold');
    set(get(gca,'title'),'FontSize',18,'FontWeight','bold');
    set(gca,'FontSize',18,'FontWeight','bold');
    title('Parameter estimates for logistic curve for before and after');
end;
%uicontrol('Tag', 'figname', 'Style','text', 'String', sprintf('%s_beforeafter_paramestim',ratname), 'Visible','off');
sign_fname(gcf,mfilename);

% Finally, give verbose output -------------------------------------
if verbose
    dash = [repmat('-',1,100) '\n'];
    % Raw webers
    fprintf(1,dash);
    fprintf(1,'Weber ratios for individual sessions:\n');
    bef = webers{:,BEFORE_COL};aft = webers{:,AFTER_COL};
    print_sidebyside(bef,aft,'%1.4f');

    fprintf(1,dash);
    fprintf(1,'Dates with failed psych sessions (not enough trials or bad fit)\n');
    bef = sessdates{:,BEFORE_COL};
    bef = bef(failed_cell{:,BEFORE_COL});
    aft = sessdates{:,AFTER_COL};
    aft = aft(failed_cell{:,AFTER_COL});
    fprintf(1,'\tBefore: %i of %i\n',length(failed_cell{:,BEFORE_COL}), ...
        length(sessdates{:,BEFORE_COL}));
    fprintf(1,'\tAfter: %i of %i\n',length(failed_cell{:,AFTER_COL}), ...
        length(sessdates{:,AFTER_COL}));
    print_sidebyside(bef,aft,'%s');
    fprintf(1,dash);
    if strcmpi(task(1:3),'dur')
        fprintf(1,'Timeout % BEFORE:\n');
        timeout_cell{:,BEFORE_COL}
        fprintf(1,'\nTimeout % BEFORE:\n');
        timeout_cell{:,AFTER_COL}
    end;
    fprintf(1, 'Rxn time BEFORE:\n');
    rxn_cell{:,BEFORE_COL}
    fprintf(1,'Rxn time AFTER:\n');
    rxn_cell{:,AFTER_COL}
end;

if output_vars > 0
    % return all metrics on which significance was called
    metric_sig ={};
    for d = 1:length(datafields)
        metric_sig{d,1} = data_titles{d};
        metric_sig{d,2} = eval(datafields{f});
        metric_sig{d,3} = p_array(d);
        s=0;
        if p_array(d) < alphaval
            metric_sig{d,4} = 1; % called sig
        elseif p_array(d) == 2 % data didn't exist
            metric_sig{d,4} = 2;
        else
            metric_sig{d,4} = 0;
        end;
    end;
    % next return all parameter estimates and corresponding CIs for curve
    % fit
    param_estim = {};
    param_estim.betahats = overall_betahats;
    param_estim.cis = overall_cis;

    % finally return the # datapoints for each metric
    metric_numpoints = sz;

    assignin('caller', 'metric_sig',metric_sig);
    assignin('caller','param_estim', param_estim);
    assignin('caller','metric_numpoints', metric_numpoints);
end;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper functions begin here
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% print entries from bef and aft in 2 columns.
% Use format 'fmat' to print content of arrays
% e.g. if printing array of strings, fmat='%s'.
% e.g. if printing small numbers, fmat =%1.4f'.
function [] = print_sidebyside(bef, aft, fmat)
smaller = min(length(bef), length(aft));
fprintf(1,'BEFORE\t\t\tAFTER\n');
for idx = 1:smaller
    if iscell(bef),
        b = bef{idx}; a = aft{idx};
    else
        b=bef(idx); a=aft(idx);
    end;
    fprintf(1, [fmat '\t\t\t' fmat '\n'],b,a);
end;

if length(aft) ~= length(bef)
    bigger_array = 'bef';
    spacer_prec= '';
    if length(aft)> length(bef),
        bigger_array = 'aft';
        spacer_prec='\t\t\t';
    end;

    for idx = smaller+1:length(eval(bigger_array))
        if iscell(eval(bigger_array)),b = eval([bigger_array '{idx};']);
        else b= eval([bigger_array '(idx)']);end;
        fprintf(1,[spacer_prec fmat '\n'], b);
    end;
end;

% -------------------------------------------------------------------------
% when given 'bef'ore and 'aft'er arrays of a specific metric, plots bar
% graph of mean and std as part of current figure.
function [p] = bargraph_metric_compare(bef,aft,idx,axes_width, axes_ht,alphaval,mytitle,ylbl)
axes('Position', [0.1+((idx-1)*(axes_width*1.2)) 0.12 axes_width axes_ht]);

% invalid value -- don't compute significance
if (length(bef) == 1 && bef == -1) || (length(aft) == 1 && aft == -1)
    p = 2;
    return;
end;

if ~isstr(bef) && ~isstr(aft)
    barweb([mean(bef) mean(aft)], ...
        [std(bef) std(aft)]);

    % ht = max(mean(bef)+std(bef),mean(aft)+std(aft));
    % if ht < 0, ylim = [ht*1.3 0]; else ylim=[0 1.3*ht]; end;
    min_ylim = min(mean(bef)-std(bef),mean(aft)-std(aft));
    if min_ylim > 0, min_ylim = 0;end;
    max_ylim = max(mean(bef)+std(bef),mean(aft)+std(aft));
    ylim = [min_ylim*1.5 max_ylim*1.5];
    ht = max_ylim;

    set(gca,'XTIck',[],'FontSize',14,'FontWeight','bold','YLim',ylim);
    [sig p]= permutationtest_diff(bef, aft,'alphaval',alphaval);

    hold on; line([0.85 1.15], [ht*1.1 ht*1.1],'Color','k');
    if sig > 0 % significant,
        t=text(0.9, ht*1.15, sprintf('* (p=%1.3f)',p));
    else
        t=text(0.9, ht*1.15, sprintf('n.s. (%1.2f)',p));
    end;
    y=ylabel(ylbl);
    x=get(gca,'XLabel'); set(x,'FontSize',16,'FontWeight','bold');
    set(y,'FontSize',16, 'FontWeight','bold');
else
    t=text(0.5,0.5, 'n/a');
    set(t,'FontSize',10);
end;
t=title(mytitle);
set(t,'FontSize',16,'FontWeight','bold');

% plot histogram of weber ratios before and after
function [] = plot_weber_hist(ratname,webers, overall_webers, BEFORE_COL, AFTER_COL)
figure; set(gcf,'Position',[800 140 380 140],'Toolbar','none','Tag','weber_hist');
bins = 0:0.02:0.5;

if (length(webers{:,AFTER_COL}) > 1) || (webers{:,AFTER_COL} ~= -1)
    hist(webers{:,AFTER_COL},bins);
    p=findobj(gca,'Type','patch'); set(p,'FaceColor', [1 0 0],'EdgeColor',[1 0 0],'facealpha',0.75);
    hold on;
    line([overall_webers{:,AFTER_COL} overall_webers{:,AFTER_COL}], [0 8], 'Color','r','LineWidth',4);
    t=text(overall_webers{:,AFTER_COL}, 3, 'Pooled after'); set(t,'Color','red');
    weberrange = webers{:,AFTER_COL};
end;

if (length(webers{:,BEFORE_COL}) > 1) || (webers{:,BEFORE_COL} ~= -1)
    hist(webers{:,BEFORE_COL},bins);
    p=findobj(gca,'Type','patch');
    set(p,'facealpha',0.25, 'EdgeColor','none');
    line([overall_webers{:,BEFORE_COL} overall_webers{:,BEFORE_COL}], [0 6], 'Color','b','LineWidth',3,'LineStyle',':');
    t=text(overall_webers{:,BEFORE_COL}, 5, 'Pooled before'); set(t,'Color','blue');
    weberrange = webers{:,BEFORE_COL};
end;

title(sprintf('Distribution of Weber ratio before and after: %s', ratname));
if  ((length(webers{:,BEFORE_COL}) > 1) || (webers{:,BEFORE_COL} ~= -1)) && ...
        ((length(webers{:,AFTER_COL}) > 1) || (webers{:,AFTER_COL} ~= -1))
    weberrange = [webers{:,BEFORE_COL}; webers{:,AFTER_COL}];
end;

binsize = bins(2)-bins(1);
set(gca,'XLim',[min(weberrange) - (2* binsize) ...
    max(weberrange) + (2* binsize) ]);

% -------------------------------------------------------------------------
% normalises metric and conducts kolmogrov-smirnov test against standard
% Normal distribution
% returns a cell array which contains:
% i) 1/0: reject/don't reject null hypothesis
% ii) the array of standardized metric
% iii) intrapolated x-values in (ii)
% iv) normcdf values for (iii)
% The last three are for plotting cdf of the standardized metric against
% the Normal distribution
function [vals] = isnormal(my_metric)

my_metric2 = my_metric(find(~isnan(my_metric)));
std_metric = (my_metric2 - mean(my_metric2))/std(my_metric2);

h = kstest(std_metric);
xx = min(std_metric):0.001:max(std_metric);

vals = { h, std_metric, xx, normcdf(xx) };

% -------------------------------------------------------------------------
% subroutine to automate task of plotting cdfplots of the metric
function [] = plotnorm(ratname, my_array, numMetrics, ...
    currnum, titlestr, xlbl,...
    beforecol, aftercol)

f = findobj('Tag','normplot');
set(0,'CurrentFigure',f);
reject_colour = 'r';
dont_reject_colour = 'b';
axes_width = 0.8/numMetrics;
axes_ht = 0.35;

% BEFORE --------------
axes('Position', [0.05+((currnum-1)*(axes_width*1.1)) axes_ht+0.25 axes_width axes_ht]);
% callback for histogram
tstr = [titlestr ': Before'];
uicontrol('Units','normalized','Position', [0.05+((currnum-1)*(axes_width*1.1)) 0.95 0.03 0.07], ...
    'Style','pushbutton',  'String', 'Hist',...
    'Callback',{@surgery_effect, 'showhist', {my_array{:,beforecol}, tstr, xlbl},'graphic',0});

%subplot(2, numMetrics, currnum);
vals = isnormal(my_array{:,beforecol});
cdfplot(vals{2}); hold on; plot(vals{3}, vals{4},'-k');
if vals{1} >0 % reject
    set(gca,'Color', reject_colour);
end;
normhbefore = vals{1};

t=title(tstr);
set(t,'FontSize',12);
set(gca,'FontSize',12);

% AFTER ----------------
axes('Position', [0.05+((currnum-1)*(axes_width*1.1)) 0.1 axes_width axes_ht]);
%callback for histogram
tstr=[titlestr ': After'];
uicontrol('Units','normalized','Position', [0.05+((currnum-1)*(axes_width*1.1)) axes_ht+0.1 0.03 0.07], ...
    'Style','pushbutton','String', 'Hist', ...
    'Callback',{@surgery_effect, 'showhist', {my_array{:,aftercol}, tstr, xlbl}, 'graphic',0});

%subplot(2,numMetrics, numMetrics+currnum);
vals = isnormal(my_array{:,aftercol});
cdfplot(vals{2}); hold on; plot(vals{3}, vals{4},'-k');
if vals{1} >0 % reject
    set(gca,'Color', reject_colour);
end;
normhafter = vals{1};
t=title(tstr);
set(t,'FontSize',12);
set(gca,'FontSize',12);

% now plot variances for both groups
axes_width = 0.8/numMetrics;
axes_ht = 0.7;
f = findobj('Tag','eqvar');
set(0,'CurrentFigure', f);
axes('Position',[0.05+((currnum-1)*(axes_width*1.1)) 0.1 axes_width axes_ht]);
l=plot([1 2], [std(my_array{:,beforecol}).^2 std(my_array{:,aftercol}).^2], '.b');
set(l,'MarkerSize',20);

set(gca,'XLim',[0 3],'XTick',[1 2], 'XTickLabel',{'before','after'});
t=xlabel(xlbl);set(t,'FontSize',12);
ylabel('Variance');
t=title(sprintf([tstr '\n']));
set(t,'FontSize',12);
set(gca,'FontSize',12);

tmp = my_array{:,beforecol}; if cols(tmp) > 1, tmp = tmp'; end;
levene_array = [tmp ones(size(tmp))];

tmp = my_array{:,aftercol}; if cols(tmp) > 1, tmp = tmp'; end;
levene_array = vertcat(levene_array, [tmp 2*ones(size(tmp))]);
h = Levenetest(levene_array);
if h > 0 % reject,
    set(gca,'Color', reject_colour);
end;

% now change colour on summary graphs
f = findobj('Tag', sprintf('%s_assumption_summary', ratname)); set(0,'CurrentFigure',f);
% normality test
f = findobj('Tag', sprintf('%s_norm_summary', ratname));
set(gcf,'CurrentAxes',f);
patch_colour = 'w'; if normhbefore > 0, patch_colour = reject_colour; end;
patch([currnum currnum currnum+1 currnum+1],[1 2 2 1], patch_colour);
text(currnum+0.1, 1.5, titlestr);

patch_colour = 'w'; if normhafter > 0, patch_colour = reject_colour; end;
patch([currnum currnum currnum+1 currnum+1],[0 1 1 0], patch_colour);

% homoscedasticity test
f = findobj('Tag', sprintf('%s_eqvar_summary', ratname));
set(gcf,'CurrentAxes',f);
patch_colour = 'w'; if h > 0, patch_colour = reject_colour; end;
patch([currnum currnum currnum+1 currnum+1],[0 1 1 0], patch_colour);
text(currnum+0.1, 0.5, titlestr);

% -------------------------------------------------------------------------
% Plots to ensure metrics meet normality assumption before doing
% significance testing
function [] = do_normality_plot()
normality_cell = {};
normality_cell{AFTER_COL, 1} = isnormal(webers{:,AFTER_COL});

% mini view of whether assumptions are met for various tests
figure;
set(gcf,'Tag',sprintf('%s_assumption_summary',ratname), 'Name', 'Assumptions met?', ...
    'Position', [200 200 500 200]); %, 'Menubar','none','Toolbar','none');

axes('Position', [0.05 0.05 0.9 0.3]); % bottom axis of homoscedasticity
set(gca,'Tag', sprintf('%s_eqvar_summary', ratname),'XLim',[1 numMetrics+1],'YLim',[0 1], 'XTick',[], 'YTick',[]);
title(sprintf('%s: Equal variance assumption', ratname));

axes('Position',[0.05 0.5 0.9 0.4]); % top axis of normality assumption
set(gca,'Tag', sprintf('%s_norm_summary', ratname), 'XLim',[1 numMetrics+1], 'YLim', [0 2], 'XTick', [], 'YTick',[]);
title(sprintf('%s: Normality assumption', ratname));


figure;
set(gcf,'Tag','eqvar','Name','Variances Before & After', ...
    'Position', [ 520   870   880   160]);

figure;
axes('Position', [0.95 0 0.05 1], 'Color','y', 'XLim',[0 1], 'YLim',[0 1], 'YTick',[], 'XTick',[]);
t=text(0.5,0.2, ratname);set(t,'Rotation', 90,'FontWeight','bold','FontSize',40);

set(gcf,'Position', [120 500 1400 330],'Tag','normplot','Name','Normality of Metrics');
% close histogram button
uicontrol('Units','normalized','Position', [0 0.95 0.05 0.07], ...
    'Style','pushbutton',  'String', 'Close all hist',...
    'Callback',{@surgery_effect, 'closehist',1,'graphic',0});
ratrow = rat_task_table(ratname); task=ratrow{1,2};
if strcmpi(task(1:3),'dur'), biasunit = 'milliseconds'; else biasunit = 'KHz'; end;
plotnorm(ratname, webers, numMetrics, 1, 'Weber ratio', 'ratio value', BEFORE_COL, AFTER_COL);
plotnorm(ratname, bias_cell, numMetrics, 2, 'Bias', biasunit, BEFORE_COL, AFTER_COL);
plotnorm(ratname, cpoke_dur, numMetrics, 3, 'Trial initiation time', 'milliseconds',BEFORE_COL, AFTER_COL);
plotnorm(ratname, apoke_dur, numMetrics, 4, 'Wait for Answer Poke', 'milliseconds', BEFORE_COL, AFTER_COL);

vanilla_bef = vanilla_cell{:,BEFORE_COL};
vanilla_bef = cell2mat(vanilla_bef(:,1)); vanilla_bef = vanilla_bef(find(~isnan(vanilla_bef)));
vanilla_aft = vanilla_cell{:,AFTER_COL};
vanilla_aft = cell2mat(vanilla_aft(:,1)); vanilla_aft = vanilla_aft(find(~isnan(vanilla_aft)));
vanilla = {vanilla_bef vanilla_aft};

psych_bef = psych_cell{:,BEFORE_COL};
psych_bef= cell2mat(psych_bef(:,1)); psych_bef = psych_bef(find(~isnan(psych_bef)));
psych_aft = psych_cell{:,AFTER_COL};
psych_aft = cell2mat(psych_aft(:,1));psych_aft = psych_aft(find(~isnan(psych_aft)));

psych = {psych_bef psych_aft};
plotnorm(ratname,vanilla, numMetrics, 5, 'Hit rate (non-psychometric)', '%', BEFORE_COL, AFTER_COL);
plotnorm(ratname,psych, numMetrics, 6, 'Hit rate (psychometric)', '%', BEFORE_COL, AFTER_COL);

function [] = do_hitsigs_only()
vanilla_bef = vanilla_cell{:,BEFORE_COL}; % 1 - mean, 2 - sem, 3 - # trials in session
vanilla_bef = cell2mat(vanilla_bef(:,1)); %vanilla_bef = vanilla_bef(find(~isnan(vanilla_bef)));

vanilla_aft = vanilla_cell{:,AFTER_COL};
vanilla_aft = cell2mat(vanilla_aft(:,1)); %vanilla_aft = vanilla_aft(find(~isnan(vanilla_aft)));

psych_bef = psych_cell{:,BEFORE_COL};
psych_bef= cell2mat(psych_bef(:,1)); %psych_bef = psych_bef(find(~isnan(psych_bef)));
psych_aft = psych_cell{:,AFTER_COL};
psych_aft = cell2mat(psych_aft(:,1));% psych_aft = psych_aft(find(~isnan(psych_aft)));

alphaval = 0.05/2;
sigpsych = permutationtest_diff(psych_bef, psych_aft,'alphaval', alphaval);
sigvanilla = permutationtest_diff(vanilla_bef, vanilla_aft,'alphaval',alphaval);


% plot
figure; set(gcf,'Tag', 'hits_sig');
subplot(1,2,1);
barweb([mean(psych_bef) mean(psych_aft)], [std(psych_bef)/length(psych_bef), std(psych_aft)/length(psych_aft)]);
hold on; line([0.85 1.15], [1.2 1.2],'Color','k');
if sigpsych > 0 % significant,
    t=text(1, 1.3, '*');
else
    t=text(1, 1.3, 'n.s.');
end;
set(t,'FontSize',14,'FontWeight','bold');
text(1, 1.5, sprintf('alpha = %1.3f', alphaval));

set(gca,'YLim', [0 1.5], 'YTick', 0:0.2:1, 'YTickLabel', 0:20:100,'XTick',[]);
title('Psychometric trials');
subplot(1,2,2);
barweb([mean(vanilla_bef) mean(vanilla_aft)], [std(vanilla_bef)/length(vanilla_bef), std(vanilla_aft)/length(vanilla_aft)]);
hold on; line([0.85 1.15], [1.2 1.2],'Color','k');
if sigpsych > 0 % significant,
    t=text(1, 1.3, '*');
else
    t=text(1, 1.3, 'n.s.');
end;
set(t,'FontSize',14,'FontWeight','bold');
text(1, 1.5, sprintf('alpha = %1.3f', alphaval));
set(gca,'YLim', [0 1.5], 'YTick', 0:0.2:1, 'YTickLabel', 0:20:100,'XTick',[]);
title('Vanilla trials');



function [outdata] = triallen_influence(ratname, varargin)
% This script works for duration_discobj
% In the case where the short and long tone trial durations are mostly
% non-overlapping, analyzes the rat's performance in the section that
% _does_ overlap.
% The goal is to retrospectively determine if the rat made its decision
% based on poke duration. If a 'hit' were defined relative to the poke
% duration midpoint (instead of our intention where a 'hit' is relative
% to the tone duration midpoint), how well is the rat doing?

pairs =  { ...
    'action', 'run' ; ... % [save | save_both | load | run ]
    % Which dates to use? ---------------------
    'use_dateset', 'range' ; ... % [psych_before | psych_after | given | span_surgery | '']
    'given_dateset', {} ; ... % when 'use_dateset' = given_set, this cell array should contain a set of dates (yymmdd) for which superimposed graphs will be plotted
    'from','000000';...
    'to', '999999';...
    'dstart', 1; ... % option to plot only session A to session B; this is where you set value for A...
    'dend', 1000; ... % and this is where you set value for B
    'lastfew', 1000; ... % option to plot only last X sessions
    'yoff',100; ...
    % appearance and misc -----------------------
    'graphic', 1 ; ...
    'verbose', 1 ; ...
    'show_monotonicity_hist',0;...
    'vanilla_task', 0 ; ...
    'psych_only', 1 ; ... % when set, checks influence of trial length only on psychometric trials
    'sharp', 0 ; ... % if true, uses dates for sharpening stage
    'numbins',8;...
    'leftcolour', [0.4 0.4 1]; ...
    'rightcolour', [ 0 0 0.5];...
    % data-specific switches -----------------------
    'useVPDSetPoint', 1 ; ...
    };
parse_knownargs(varargin, pairs);

global Solo_datadir;
outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep ratname filesep ];
if ~exist(outdir, 'dir'), error('Directory does not exist!:\n%s\n', outdir); end;
ratrow = rat_task_table(ratname);
task = ratrow{1,2};

if strcmpi(task(1:3),'dua'), leftf = 'pitch_tonedurL'; rightf='pitch_tonedurR';
else leftf='dur_short'; rightf='dur_long';end;

fields = {'MinValidPokeDur','MaxValidPokeDur', 'Min_2_GO', ...
    'Max_2_GO', leftf, rightf, ...
    'vpd','prechord','logdiff', 'blocks_switch', ...
    'sides'};

if useVPDSetPoint > 0
    fields{end+1} = 'VPDSetPoint';
end;

if strcmpi(task(1:3),'dua'), fields{end+1} = 'pitch_psych'; else fields{end+1} = 'psych'; end;

if strcmpi(use_dateset,'range'),
    given_dateset = get_files(ratname, 'fromdate', from,'todate', to);
end;

switch action
    case 'save'
        if strcmpi(use_dateset,'range'), use_dateset = 'psych_before';end;
        fname = [outdir 'triallen_' use_dateset '.mat'];
        fprintf(1,'Saving trial length info in:\n%s\n', fname);

        get_fields(ratname, 'use_dateset', use_dateset, ...
            'given_dateset',given_dateset, 'from', from, 'to',to, ...
            'datafields', fields);

        if strcmpi(task(1:3),'dua'), dur_short = pitch_tonedurL; dur_long= pitch_tonedurR;end;

        if useVPDSetPoint > 0
            save(fname, 'MinValidPokeDur','MaxValidPokeDur', 'Min_2_GO', 'VPDSetPoint', ...
                'Max_2_GO', 'dur_short','dur_long',...
                'psych','vpd','prechord','logdiff', 'blocks_switch', ...
                'sides', 'numtrials','hit_history','dates');

        else
            save(fname, 'MinValidPokeDur','MaxValidPokeDur', 'Min_2_GO', ...
                'Max_2_GO', 'dur_short','dur_long',...
                'psych','vpd','prechord','logdiff', 'blocks_switch', ...
                'sides', 'numtrials','hit_history','dates');
        end;

        return;

    case 'save_both'
        triallen_influence(ratname, 'action', 'save', 'use_dateset','psych_before');
        triallen_influence(ratname, 'action', 'save', 'use_dateset','psych_after');
        return;

    case 'load'
        fname = [outdir 'triallen_' use_dateset '.mat'];
        fprintf(1,'Loading from:\n%s\n', fname);
        load(fname);
    case 'run'
        get_fields(ratname, 'use_dateset', use_dateset, ...
            'given_dateset',given_dateset, 'from', from, 'to',to, ...
            'datafields', fields);

        if strcmpi(from, '000000'), from=given_dateset{1};end;
        if strcmpi(to, '999999'), to=given_dateset{end};end;


        if strcmpi(task(1:3),'dua'), dur_short = pitch_tonedurL; dur_long= pitch_tonedurR;end;

        if strcmpi(task(1:3),'dua')
            psych=pitch_psych;
        end;

        2;

    case 'runchanakya'


        fields = {'MinValidPokeDur','MaxValidPokeDur', 'Min_2_GO', ...
            'Max_2_GO', leftf, rightf, ...
            'vpd','prechord','logdiff', 'blocks_switch', ...
            'sides'};

        load_datafile('chanakya','051213a');
        MinValidPokeDur=cell2mat(saved_history.VpdsSection_MinValidPokeDur);
        MaxValidPokeDur=cell2mat(saved_history.VpdsSection_MaxValidPokeDur);
        Min_2_GO = zeros(size(MinValidPokeDur));
        Max_2_GO = zeros(size(MaxValidPokeDur));
        short_tones=cell2mat(saved_history.ChordSection_Tone_Dur_L);
        dur_short=short_tones;
        long_tones=cell2mat(saved_history.ChordSection_Tone_Dur_R);
        dur_long=long_tones;
        logdiff=NaN(size(MinValidPokeDur));
        blocks_switch=zeros(size(MinValidPokeDur));
        psych=zeros(size(MinValidPokeDur));

        ntrials = 116;

        hit_history=saved.dual_discobj_hit_history;
        sides=saved.SidesSection_side_list;
        prechord=saved.ChordSection_prechord_list;
        vpd=saved.VpdsSection_vpds_list;
        slist={'hit_history','sides','prechord','vpd'};
        for s=1:length(slist)
            eval([slist{s} '=' slist{s} '(1:ntrials)'';']);
        end;

        %         uncomment this section to analyze only timing trials
        %         timetask = find(dur_short-dur_long ~=0); % keep only timing trials
        %         flist = {'MinValidPokeDur','MaxValidPokeDur','Min_2_GO','Max_2_GO','short_tones','dur_short',...
        %             'long_tones','dur_long','logdiff','blocks_switch', 'psych', 'hit_history','sides','prechord','vpd'};
        %         for f=1:length(flist)
        %             eval([flist{f} '=' flist{f} '(timetask);']);
        %         end;

        2;

    otherwise error('Invalid action');
end;
% --- End field-retrieval


ratrow = rat_task_table(ratname);
task = ratrow{1,2};

fields = {'MinValidPokeDur','MaxValidPokeDur', 'Min_2_GO', ...
    'Max_2_GO', 'dur_short','dur_long',...
    'psych','vpd','prechord','logdiff', 'blocks_switch',...
    'sides'};

if useVPDSetPoint > 0
    fields{end+1} = 'VPDSetPoint'; end;


% if ~isnan(blocks_switch)% Block_Switch implemented
%     if sum(blocks_switch) > 0
%         psych = blocks_switch;
%     end;
% end;

if psych_only > 0
    if strcmpi(action,'runchanakya')
        idx=1:length(blocks_switch);%     idx = find(blocks_switch>0);%find(psych > 0);
    else
        idx = find(blocks_switch>0);%find(psych > 0);
    end;
    for f = 1:length(fields)
        eval([fields{f} ' = ' fields{f} '(idx);']);
    end;
    hit_history=hit_history(idx);
    sc = side_choice(hit_history, sides);

    short_idx = find(sides == 1);
    long_idx = find(sides == 0);

    % get trial lengths.
    short_tones = dur_short(short_idx);
    short_vpd = vpd(short_idx);
    short_triallen = short_tones + short_vpd;

    long_tones = dur_long(long_idx);
    long_vpd = vpd(long_idx);
    long_triallen = long_tones + long_vpd;

    [xshort binned_hits_short sd_hit_short nshort] = ...
        sub__bin_hits(short_triallen, numbins, sc(short_idx));
    fprintf(1,repmat('-',1,50));
    fprintf(1,'SHORT:\n');
    xshort
    nshort

    [xlong binned_hits_long sd_hit_long nlong] = ...
        sub__bin_hits(long_triallen, numbins, sc(long_idx));
    fprintf(1,repmat('-',1,50));
    fprintf(1,'LONG:\n');
    xlong
    nlong


    figure;
    set(gcf,'Toolbar','none','Position',[360   545   460   313]);

    toosmall=find(nshort<5); 
    xsh2=xshort;xsh2(toosmall)=NaN;
    binsh2=binned_hits_short; binsh2(toosmall)=NaN;
    sdsh2=sd_hit_short; sdsh2(toosmall)=NaN;
    l=errorbar(xsh2, binsh2, sdsh2, sdsh2,'.b', 'Color',leftcolour);    
    set(l,'Color',leftcolour,'LineWidth',1.5,'MarkerSize',20);
    hold on;
    l2=plot(xshort(toosmall),binned_hits_short(toosmall),'ob', 'Color',leftcolour,'MarkerSize',8,'LineWidth',2);
    
    toosmall=find(nlong<5);
    xl2=xlong;xl2(toosmall)=NaN;
    binln2=binned_hits_long; binln2(toosmall)=NaN;
    sdln2=sd_hit_long; sdln2(toosmall)=NaN;
    
    r=errorbar(xl2, binln2, sdln2, sdln2,'.r','Color',rightcolour);
    set(r,'Color',rightcolour,'LineWidth',1.5,'MarkerSize',20);
    l2=plot(xlong(toosmall),binned_hits_long(toosmall),'ob', 'Color',rightcolour,'MarkerSize',8,'LineWidth',2);
    minnie = min(min(xshort), min(xlong));
    maxie = max(max(xshort), max(xlong));
    line([minnie maxie], [80 80], 'LineStyle',':','LineWidth',1.5,'Color','k');
    line([minnie maxie], [20 20], 'LineStyle',':','LineWidth',1.5,'Color','k');

    t=title(sprintf('Influence of trial length on side choice:%s (n=%i)',ratname, length(idx)));
    set(t,'FontSize',14,'FontWeight','bold');
    x=xlabel('Trial length(s)');set(x,'FontSize',16,'FontWeight','bold');
    y=ylabel('% reported "Short"');set(y,'FontSize',16,'FontWeight','bold');
    % legend({'tones < mp','tones >mp'});
    set(gca,'XLim',[minnie*0.9 maxie*1.1], 'YLim',[-5 105],'FontSize',16,'FontWeight','bold');
    uicontrol('Tag', 'figname', 'Style','text', 'String', sprintf('%s_%s_triallen',ratname,use_dateset), 'Visible','off');

    pos = get(gcf,'Position');
    uicontrol('Style','text','String', sprintf('%s - %s: Psych only', from,to), 'Position', [0.01*pos(3) 0.02*pos(4), 150 15],'FontWeight','bold','FontSize',12);

else   % -------------- BRANCH 2: Use all trials in session



    % Change names
    % filter any psychometric trials
    % Remember, this is removing trials across days!!!!!
    %     idx = 1:length(hit_history);%find(psych < 1);
    %     numpsych =find(psych>0);
    %
    %     for f = 1:length(fields)
    %         eval([fields{f} ' = ' fields{f} '(idx);']);
    %     end;
    %     hit_history=hit_history(idx);

    idx=1:length(hit_history);

    %  fprintf(1,'Psych=%i, so after filtering=%i and %i\n', length(numpsych), length(vpd), length(MinValidPokeDur));
    fprintf(1,'All %i trials kept.\n', length(idx));

    nopsychtr = length(idx);


    if useVPDSetPoint == 0
        fprintf(1,'VPDSetPoint ignored ...\n');
        VPDSetPoint = MaxValidPokeDur;
    end;


    % ------------------------------------
    % Get variable period ranges
    % ------------------------------------

    %     if length(unique(MinValidPokeDur)) > 1 || length(unique(VPDSetPoint))>1,
    %         error('>1 Pre-sound range. Check datafile'); ...
    %     end;
    if length(unique(Min_2_GO)) > 1 || length(unique(Max_2_GO))>1, error('>1 Post-sound range. Check datafile'); ...
    end;

pre_min = MinValidPokeDur(1);
pre_max = VPDSetPoint(20);
post_min = Min_2_GO(1);
post_max = Max_2_GO(1);

unld = unique(logdiff);

outdata = {};

hit_array = []; % r-by-2 matrix; column1: logdiff; column 2: average hit rate
for g = 1:length(unld)
    idx = find(logdiff == unld(g));
    if length(idx) > 5

        outdata{end+1,1} = unld(g);

        if verbose > 0
            fprintf(1,'\n\nLogdiff %1.1f\n', unld(g));
        end;
        idx = find(logdiff == unld(g));
        logd_short = dur_short(idx);
        logd_long = dur_long(idx);
        pre = vpd(idx);
        post = prechord(idx);
        logd_sides = sides(idx);
        hh = hit_history(idx);

        % trial length distribution
        if length(unique(logd_short)) > 1 || length(unique(logd_long))>1,
            error('>1 tone pair! check datafile');
        end;


        logd_short = logd_short(1);
        logd_long = logd_long(1);

        % store hits
        hit_array = [hit_array; unld(g) mean(hh)];

        if verbose > 0
            % Print summary info
            fprintf(1,'VPD specified range: [%1.1f, %1.1f]\n', pre_min, pre_max);
            fprintf(1,'VPD sampled extremes: [%1.1f, %1.1f]\n', min(pre), max(pre));
            fprintf(1,'Post sampled extremes: [%1.1f, %1.1f]\n', min(post), max(post));
            fprintf(1,'Short tone: %1.1f, Long tone: %1.1f\n', logd_short*1000, logd_long*1000);
        end;


        % ------------------------------------
        % Calculate trial length
        % ------------------------------------

        stim = zeros(size(logd_sides)); stim(find(logd_sides > 0)) = logd_short;
        stim(find(logd_sides < 1)) = logd_long;
        trial_length = stim + pre + post;

        idx_left = find(logd_sides > 0);
        idx_right = find(logd_sides < 1);

        short_realtrials = trial_length(idx_left);
        long_realtrials = trial_length(idx_right);
        if verbose > 0
            fprintf(1,'Short trials: %1.1f-%1.1f\n', min(short_realtrials), max(short_realtrials));
            fprintf(1,'Long trials: %1.1f-%1.1f\n',min(long_realtrials), max(long_realtrials));

        end;
        % Plot trial length distribution

        w=get(0,'ScreenSize');
        if graphic > 0
            figure;
            %set(gcf, 'Position', [10 g*300, 0.9*1000, 220]);
            set(gcf, 'Position', [10 g*300, 0.9*1200, 220]);
            %            set(gcf,'Menubar','none','Toolbar','none');

            %             axes('position',[0.04 0.2 0.15 0.5]);
            %             hist(short_realtrials);
            %             p=findobj(gca,'Type','patch'); set(p,'FaceColor', [1 0 0],'EdgeColor',[1 0 0],'facealpha',0.75);
            %             hold on;
            %             hist(long_realtrials);
            %             p=findobj(gca,'Type','patch');
            %             set(p,'facealpha',0.25, 'EdgeColor','none');
            %
            %             title('Trial length distribution');
            %             xlabel('Trial length (s)');
            %             ylabel('#trials');
            %   legend({'Short','Long'})

            %             t=text(0.1, 10,sprintf('n=%i',length(long_realtrials))); set(t,'Color',rightcolour);
            %             text(0.1, 5,sprintf('n=%i',length(short_realtrials)), 'Color', leftcolour);
            %             ymax = get(gca,'Position'); xmax=get(gca,'XLim');
            %             text(0.1, 15, sprintf('n=%i',length(idx)), 'Color','k','FontWeight','bold','FontSize',12);

        end;
        % -------------------
        % Look at side choice as a function of tone and trial length
        % -------------------

        sc = zeros(size(hh));

        % sc = 1 means 'chose left'
        % sc = 0 means 'chose right'
        sc(find(logd_sides > 0 & hh > 0)) = 1; % short tone trial correct
        sc(find(logd_sides < 1 & hh < 1)) = 1; % long tone trial incorrect

        sc_longt = sc(idx_right);
        sc_shortt = sc(idx_left);

        % Make sure side_choice is infact what we think it is
        tmp = sc(find(logd_sides > 0 & hh < 1)); if sum(tmp) > 0, ...
                error('sc defined inccorectly!'); end;
        tmp = sc(find(logd_sides < 1 & hh > 0)); if sum(tmp) > 0, ...
                error('sc defined incorrectly!'); end;

        % Get side choice rate as fn of trial length
        [xshort binned_hits_short sd_hit_short] = sub__bin_hits(short_realtrials, numbins, ...
            sc_shortt);
        % Want frequency going RIGHT
        % for short trials
        binned_hits_short = 100 - binned_hits_short;

        [xlong binned_hits_long sd_hit_long] = sub__bin_hits(long_realtrials, numbins, sc_longt);

        % ------
        % Plot frequency of "Error" for both short and long trials
        % --------


        corrshort=corrcoef(xshort', sd_hit_short');
        corrlong=corrcoef(xlong, sd_hit_long);

        outdata{end,2} = corrshort(1,2);
        outdata{end,3} = corrlong(1,2);

        if graphic > 0
            if show_monotonicity_hist >0
                axes('position',[0.25 0.17 0.5 0.7]);
            else
                %                             axes('position',[0.27 0.2 0.7 0.7]);
            end;
            l = errorbar(xlong, binned_hits_long, sd_hit_long, sd_hit_long, '.b',...
                'Color',rightcolour,'MarkerSize',24,'LineWidth',2);
            hold on;
            if strcmpi(task(1:3),'dua'),
                lf='''Low'' trials'; rt='''High'' trials'; ylbl = '% reported "Low"';
            else lf ='''Short'' trials'; rt='''Long'' trials'; ylbl='% reported "Short"';
            end;
            text(xlong(end)*1.02, 100,lf,'FontWeight','bold','FontSize', 14,'Color',leftcolour); %'left'
            text(xlong(end)*1.02, 85,rt,'FontWeight','bold','FontSize', 14,'Color',rightcolour); % 'right' trials


            l = errorbar(xshort, 100-binned_hits_short,sd_hit_short,sd_hit_short, '.b',...
                'Color', leftcolour, 'MarkerSize',24,'LineWidth',2);
            line([min(xshort) max(xlong)], [75 75], 'LineStyle', ':', 'Color',rightcolour);

            xlim= [xshort(1)*0.8 1.1*xlong(end)];
            % Show correlation coeff
            t=text(xshort(1)*0.9, 100, sprintf('r=%1.2f',corrshort(1,2)), 'Color','k','FontSize',12,'FontWeight','bold');
            if abs(corrshort(1,2) > 0.55), set(t,'BackgroundColor','y'); end;
            t=text(xshort(1)*0.9, 10, sprintf('r=%1.2f',corrlong(1,2)), 'Color','k','FontSize',12, 'FontWeight','bold');
            if abs(corrlong(1,2) > 0.55), set(t,'BackgroundColor','y'); end;

            % axes formatting
            set(gca,'YLim',[0 110],'YTick',0:20:100,...
                'FontSize',14,'FontWeight','bold',...
                'XLim',xlim);
            t=xlabel('Trial length (seconds)');
            set(t,'FontSize',14,'FontWeight','bold');
            t=ylabel(ylbl);
            set(t,'FontSize',14,'FontWeight','bold');

            %  legend({'Long tones','Short tones'});
            t=sprintf('%s (%s-%s): Log difference of %1.1f',ratname, from, to,unld(g));
            t=title(t);
            set(t,'FontSize',14,'FontWeight','bold');
        end;

        % calculate monotonicity
        if show_monotonicity_hist > 0
            axes('position',[0.8 0.55 0.15 0.3]);
            [slope dist] = monotonicity_test(xshort, sd_hit_short,'figtitle', 'Monotonicity test:SHORT','newfig',0);
            set(gca,'YTIck',[],'XTick',[]); xlabel('');
            if dist > 2, set(gca,'Color', 'y');end;
            if verbose > 0
                fprintf(1,'\nMonotonicity distance: %1.1f', dist);
            end;
            axes('position',[0.8 0.05 0.15 0.3]);
            [slope dist] = monotonicity_test(xlong, sd_hit_long,'figtitle', 'Monotonicity test:LONG','newfig',0);
            if dist > 2, set(gca,'Color','y'); end;
            if verbose >0
                fprintf(1,'\nMonotonicity distance: %1.1f', dist);
            end;
            set(gca,'YTIck',[],'XTick',[]); xlabel('');
        else
            [shortslope shortdist] = monotonicity_test(xshort, sd_hit_short,'graphic',0);
            [longslope longdist] = monotonicity_test(xlong, sd_hit_long,'graphic',0);
            outdata{end,4} = shortslope;
            outdata{end,5} = shortdist;
            outdata{end,6} = longslope;
            outdata{end,7} = longdist;
        end;
    end;
end;

% if length(hit_array(:,1)) > 3
% figure;
% plot(hit_array(:,1), hit_array(:,2), '.k','MarkerSize',20);
% title('Hit rate for different tone pairs');
% ylabel('% success');
% xlabel('Logdiff');
% end;

end; % end BRANCHES -- psych or no psych.


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subroutines
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Bins the range "to_bin" into "numbins" equally-spaced bins
% For each bin, calculates the hit rate.
% Returns:
% 1) The bin centers
%  2) The mean hit rate for the bin
% 3) The sem for the bin
function [x binned_hrate binned_sem n] = sub__bin_hits(to_bin, numbins, hits)
idx_crosschk = [];
binwidth = (max(to_bin) - min(to_bin)) / numbins;
[n,x] = hist(to_bin,numbins);
[n2, x2] = sub__purge_empties(n,x);

binned_hrate = []; binned_sem = [];
idx_so_far = []; % avoid rebinning
for k = 1:numbins
    idx=[];
    if k == 1,
        idx = find(to_bin < x(k));
        if rows(idx)>1, idx=idx';end;
    end;
    newidx=find(to_bin > (x(k)-(binwidth/2)) & ...
        to_bin <= (x(k)+(binwidth/2)) );
    if rows(newidx)>1, newidx=newidx';end;
    idx = [ idx newidx];

    if k == numbins
        newidx=find(to_bin > x(k)+(binwidth/2));
        if rows(newidx)>1, newidx=newidx';end;
        idx = [idx newidx];
    end;
    idx = unique(idx);

    idx = setdiff(idx, idx_so_far);
    idx_so_far = [idx_so_far idx];
    idx_crosschk = [ idx_crosschk  length(idx)];

    hitbin = hits(idx); hitbin = hitbin*100;
    binned_hrate = [binned_hrate mean(hitbin);];
    binned_sem = [binned_sem std(hitbin)/sqrt(length(hitbin))];

end;

2;
%idx_crosschk
%n

% removes bins for which there are no entries
function [n2 x2] = sub__purge_empties(n,x)
n2=n;x2=x;

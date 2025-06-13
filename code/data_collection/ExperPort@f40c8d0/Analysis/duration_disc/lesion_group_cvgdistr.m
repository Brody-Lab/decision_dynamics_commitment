function [out] = lesion_group_cvgdistr(firstarg, secondarg, varargin)
% Interactive graphical viewer for % coverage for each slice of a set of brain areas.
% Requires output file "lesion_coverage_calc.mat" created by running
% "lesion_coverage_runner.m"
%
% Note: This file does not compute % coverage -- it is a way of vieweing
% the results of other files that have already done this computation.
%
% Example uses:
% initialize (no input arguments required)
% >> lesion_group_cvgdistr

% USE CASE: Slicewise difference between two groups
% Task group: combine
% Group rats: show group average
% Add : Yes
% Which data: Interpolated
% Click "Compute slicewise"

% USE CASE: Compare area % coverage
% Task group: combine
% group rats: Show group avg
% add: Show individual
% Which data: interpolated
% Dropdown: Areawise bar graph -> click "Compute net coverage"

% USE CASE: Want some of the areas combined, excluding others
% Change roiset.

% USE CASE: See trendline of coverage for each rat
% task group : duration or frequency
% group rats: show individual
% add across areas: yes
% ---> COMPUTE SLICEWISE

persistent datafile all_slices_interpolated;
persistent mega_lesioncvg;   % contains lesioncvg data for all rats.
persistent bufferL bufferR ; % contains coverage data for rois for all rats.
persistent NXmarked__L NXmarked__R; % contains arrays distinguishing N (n.a.) from X (no lesion) for all rats
persistent ratset durset freqset;
persistent roiexists; % struct of binary strings indicating whether an roi exists at each slice or not
persistent use_ND_info; % when 1, treats N vs X as in subroutines; when 0, treats all empty spots as N

pairs = { ...
    'action','init'; ...
    'tasktype', 'duration' ; ...
    'area_filter', 'ACx'; ...
    'metric', 'cvgpts' ; ... % pctcvg | cvgpts
    'scoring_file', 'scoring_0806' ; ...
    'NDmethod', 'ignore' ; ... % bestcase | worstcase | ignore
    'interp_opt', {'none','pchip', 'spline','linear','nearest'} ; ... % {'bestcase','worstcase','ignore'}; ...
    'durclr', [1 0.5  0]; ...
    'freqclr',[0 0.3 1] ; ...
    'clr_by_grp', 1 ; ... % mark only as duration or frequency rat
    'interp_datafile', 'lesion_coverage_calc__interpol'; ...
    'raw_datafile', 'lesion_coverage_calc' ; ...
    'datafile', 'lesion_coverage_calc__interpol' ; ...
    'all_slices_interpolated', 1 ; ... % set to 1 to ignore coverage values in spots we know are ND
    'summing_show_average',1 ; ...
    };
parse_knownargs(varargin,pairs);

% file for hippocampus is lesion_coverage_calc_Hpc.mat

if strcmpi(area_filter,'ACx')
    atlas_beginpos= -3;           % mm from Bregma
    roiset = {'AuD','A1','AuV','TeA'}; ... %{'AuD', 'A1','AuV','TeA'} ; ...
        slice_interval=0.12 ; ... % distance between slices
         use_ND_info=1;
         raw_datafile = 'lesion_coverage_calc'; 
         interp_datafile = 'lesion_coverage_calc__interpol';
elseif strcmpi(area_filter,'mPFC')
    atlas_beginpos=5.64;
    slice_interval = 0.3; % APPROXIMATE VALUE; unlike ACx, atlas slices for mPFC are not at regular intervals
%     roiset= {'Cg','PrL','IL','MO','M2'};
      roiset={'PrL','IL'};
    use_ND_info=0;
    raw_datafile = interp_datafile;
elseif strcmpi(area_filter,'ACx2') || strcmpi(area_filter,'ACx3')
    atlas_beginpos=-1.6;
    roiset = {'AuD','A1','AuV','TeA'}; ...{'S1','Ect','Prh',
        slice_interval=0.12;
    use_ND_info=0;
end;

diffclrs = [ 1 0 0; 0 0.5 0; 0 0 0.5; 1 0.5 0 ; 0.5 0 0.5 ; 0.5 0.5 1];
diffclrs_freq = [1 0.5 0.5; 0 0.5 0.2; 0.8 0.8 0; 0.5 0.4 1; 0.1 0.4 1];
%  diffclrs = diffclrs_freq;
durset = rat_task_table('','action','get_duration_psych','area_filter',area_filter);
freqset= rat_task_table('','action','get_pitch_psych','area_filter',area_filter);

if nargin == 0, firstarg = 0; secondarg = 0; end;

switch action
    case 'init'
        clear mega_lesioncvg bufferL bufferR NXmarked__L NXmarked__R roiexists ratset;

        % main console
        figure; ht = 400; wd = 600;
        clr = [1 1 1] * 0.3;  %[247 117 148] ./ 255;
        set(gcf,'Tag', 'lesionviewer_main', 'Color', clr, ...
            'Position', [10 30 wd ht],'Menubar','none','Toolbar','none');

        % make controls for main figure
        hdr_clr = [ 1 1 1]*0; hdr_txt= [ 0 1 0 ];
        y = ht; x = 20;
        twidth =150;
        fsize = 12;

        uicontrol('Style','text','String', [area_filter ' histology analysis'], 'FontSize',14,'FontWeight','bold',...
            'Position', [20 ht-30 550 20],'BackgroundColor',hdr_clr, 'ForegroundColor', hdr_txt);
        y=y-80;
        uicontrol('Style','text','String', 'Task group:','Position',[20 y+5 twidth*0.75 20],'FontSize',fsize, 'FontWeight','bold','ForegroundColor','w','BackgroundColor',clr,'FontAngle','italic');
        p=uicontrol('Style','popupmenu','Tag','ratset_opt','String', {'duration','frequency','combine'}, 'Value',3,'Position',[150 y twidth 30]);
        y=y-30;
        uicontrol('Style','text','String', 'Group rats?','Position',[20 y+10 twidth*0.75 20],'FontSize',fsize, 'FontWeight','bold','ForegroundColor','w','BackgroundColor',clr,'FontAngle','italic');
        uicontrol('Style','popupmenu','Tag', 'grouprats', 'String',{'show individual trends', 'show group average'},'Value',2,'Position', [150 y twidth 30]);
        uicontrol('Style','text','STring','Indie plot:','Position',[320 y+10 twidth*0.5 20],'FontSize',fsize, 'FontWeight','bold','ForegroundColor','w','BackgroundColor',clr,'FontAngle','italic');
        uicontrol('Style','popupmenu','Tag','show_metric_opt','String', {'pct_coverage','total point count'}, 'Value',2, 'Position',[400 y twidth 30]);

        y=y-30;
        uicontrol('Style','text','String', 'Add across areas?','Position',[20 y+10 twidth*0.75 20],'FontSize',fsize, 'FontWeight','bold','ForegroundColor','w','BackgroundColor',clr,'FontAngle','italic');
        p=uicontrol('Style','popupmenu','Tag','addareas','String', {'No, show each separately', 'Yes, show combined view'}, 'Value',2,'Position',[150 y twidth*1.2 30]);
        y=y-50;
        uicontrol('Style','text','STring','Which data to load?:','Position',[5 y+10 twidth 20],'FontSize',fsize, 'FontWeight','bold','ForegroundColor','w','BackgroundColor',clr,'FontAngle','italic');
        uicontrol('Style','popupmenu','Tag','load_interp_opt','String', {'Raw', 'Pre-interpolated'}, 'Value',1, 'Position',[150 y twidth 30],'ForegroundColor','r', 'FontWeight','bold');
        %            'Callback', {'lesion_group_cvgdistr','action','toggle_interp_data'});
        uicontrol('Style','text','STring','Interpolating ND:','Position',[315 y+10 twidth*0.75 20],'FontSize',fsize, 'FontWeight','bold','ForegroundColor','w','BackgroundColor',clr,'FontAngle','italic');
        uicontrol('Style','popupmenu','Tag','interp_opt_main','String', interp_opt, 'Value',2, 'Position',[430 y twidth*0.5 30]);
        y=y-50;

        uicontrol('String', 'ROI pt count','FontWeight','bold','FontSize',10, 'Position',[20 y twidth*0.5 40],'Callback',{'lesion_group_cvgdistr','action', 'roi_count_plot','all_slices_interpolated', all_slices_interpolated});
        uicontrol('String', 'Compute slicewise','FontWeight','bold','FontSize',12, 'Position',[130 y twidth 40],'Callback',{'lesion_group_cvgdistr','action', 'go_button','all_slices_interpolated', all_slices_interpolated});
        uicontrol('String', 'close figures','Position',[500 y 90 30],'Callback',{'lesion_group_cvgdistr', 'action','closefigs'},'FontWeight','bold');

        % separator
        y = y-30;
        uicontrol('Style','text','String', '', 'FontSize',14,'FontWeight','bold',...
            'Position', [20 y 400 10],'BackgroundColor',[0.5 1 0.5]*0.8, 'ForegroundColor', hdr_txt);

        % Computing net coverage of ROIs
        y= y-40;
        uicontrol('Style','popupmenu', 'Tag', 'net_cvg_viewopt','String',...
            {'Show 3D-bar of all data', ...
            'Areawise 2D plot',...
            'Areawise bar graph', ...
            'Areawise/mm-wise bar graph'},'Position', [20 y twidth 20]);
        uicontrol('String', 'Compute net coverage','FontWeight','bold','FontSize',12, 'Position',[250 y twidth 40],'Callback',{'lesion_group_cvgdistr','action', 'net_pct_cvg','all_slices_interpolated',all_slices_interpolated});

        % Compute proportion
        y=y-30;
        % separator
        uicontrol('Style','text','String', '', 'FontSize',14,'FontWeight','bold',...
            'Position', [20 y 400 10],'BackgroundColor',[0.5 1 0.5]*0.8, 'ForegroundColor', hdr_txt);
        y=y-40;
        uicontrol('String', 'Distribution among ROIs','FontWeight','bold','FontSize',12, 'Position',[20 y twidth 40],'Callback',{'lesion_group_cvgdistr','action', 'lesion_distribution','all_slices_interpolated',all_slices_interpolated});

        mega_lesioncvg=[];
        bufferL = 0;
        bufferR = 0;
        roiexists = 0; % will be 1/0 to indicate whether, at a given slice, the roi has some area (1) or not (0).

    case 'buffer_data'

        itag = findobj('Tag', 'load_interp_opt');
        if get(itag,'Value') == 2 % pre-interpolated
            all_slices_interpolated =1;
            datafile = interp_datafile;
        else
            all_slices_interpolated =0;
            datafile = raw_datafile;
        end;

        % load file with rat-specific lesion coverage structs
        global Solo_datadir;
         histodir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Histo' filesep area_filter filesep];
      %  histodir = ['..' filesep 'Histo' filesep area_filter filesep];
        infile = [histodir datafile '.mat'];
        load(infile);


        NXmarked__L = []; % convert to struct
        NXmarked__R = [];

        if use_ND_info > 0
            % now load file which distinguishes ND (no data) from X (no lesion)
            infile = [histodir 'scoring' filesep scoring_file];
            load(infile);
            % variables of interest are only ACx_NXmarked__LEFT and
            % ACx_NXmarked__RIGHT. Delete all others
            clear ACx_lesionyesno__LEFT ACx_lesionyesno__RIGHT ACx_task PFC_lesion_yesno PFC_task ACx_lesion_coverage_scriptgen;

            for k = 1:2:length(ACx_NXmarked__LEFT)
                currat = ACx_NXmarked__LEFT{k};curr = ACx_NXmarked__LEFT{k+1};

                tmpcurr = curr;tmpcurr(2) = curr(3);tmpcurr(3) = curr(2);
                curr = tmpcurr;

                eval(['NXmarked__L.' currat ' = curr;']);

                currat = ACx_NXmarked__RIGHT{k};
                curr = ACx_NXmarked__RIGHT{k+1};
                tmpcurr = curr;tmpcurr(2) = curr(3);tmpcurr(3) = curr(2);
                curr = tmpcurr;

                eval(['NXmarked__R.' currat ' = curr;']);
            end;
        else % set all positions with no data to ND

            for r = 1:length(ratset)
                eval(['NXmarked__L.' ratset{r} ' = [];']);
                eval(['NXmarked__R.' ratset{r} ' = [];']);
            end;
        end

        mega_lesioncvg = [];

        % for each rat/roi combination treat ND and X. Save resulting data
        % in mega_lesioncvg.

        for m = 1:length(roiset)
            roi = roiset{m};
            % mark which slices have particular ROIs and which don'tpick any rat - I've arbitrarily picked Lory.
            if strcmpi(area_filter,'ACx')
                mystruct = eval(['Lory_lesioncvg.' roi ';']);
            elseif strcmpi(area_filter,'ACx2')
                mystruct = eval(['S050_lesioncvg.' roi ';']);
            elseif strcmpi(area_filter,'ACx3')
                mystruct = eval(['S038_lesioncvg.' roi ';']);                
            else
                mystruct = eval(['Hudson_lesioncvg.' roi ';']);
            end;

            tmp = ~isnan(mystruct.areapts__L);
            eval(['roiexists.' roi ' = tmp;']);

            eval(['bufferL.' roi ' = [];']);
            eval(['bufferR.' roi ' = [];']);

            for r = 1:length(ratset)
                ratname = ratset{r};
                if strcmpi(ratname,'Jabber'), ratname = 'Eaglet'; % Jabber and Eaglet's records got mixed up so now histology just calls him Eaglet
                end;

                if use_ND_info > 0
                    mystruct = eval([ratname '_lesioncvg.' roi ';']);
                    % Left hem -------------------------
                    lft = eval(['mystruct.' metric '__L;']);
                    tmp = eval(['NXmarked__L.' ratname ';']); % incorporate knowledge of ND or X

                    % SWAPPING already done in lesion_interpolate
                    lft = sub__treatX(lft, tmp, all_slices_interpolated);
                    lft(eval(['roiexists.' roi]) == 0) = NaN;
                    eval(['mystruct.' metric '__L = lft;']);
                    %    lft = sub__treatND(lft, tmp, NDmethod);

                    bufftmp = eval(['bufferL.' roi ';']);bufftmp = vertcat(bufftmp, lft);
                    eval(['bufferL.' roi ' = bufftmp;']);

                    % Right hem -------------------------
                    rt = eval(['mystruct.' metric '__R;']);
                    tmp = eval(['NXmarked__R.' ratname ';']);%incorporate knowledge of ND or X

                    rt = sub__treatX(rt, tmp, all_slices_interpolated);
                    rt(eval(['roiexists.' roi]) == 0) = NaN;
                    eval(['mystruct.' metric '__R = rt;']);
                    % rt = sub__treatND(rt, tmp, NDmethod);

                    bufftmp = eval(['bufferR.' roi ';']);bufftmp = vertcat(bufftmp, rt);
                    eval(['bufferR.' roi ' = bufftmp;']);

                    eval([ratname '_lesioncvg.' roi ' = mystruct;']);
                end;

                eval(['mega_lesioncvg.' ratname ' = ' ratname '_lesioncvg;']);
            end;
        end;

        2;
        
    case 'go_button'
        [ratset clr_by_grp] = sub__getratset(durset, freqset);
        lesion_group_cvgdistr(0,0,'action','buffer_data','metric', metric, 'all_slices_interpolated', all_slices_interpolated);
        % set group-rats variable
        gobj = findobj('Tag','grouprats'); if get(gobj,'Value') == 1, summing_show_average = 0; else summing_show_average = 1; end;
        % set add-areas variable
        aobj = findobj('Tag','addareas'); if get(aobj,'Value') == 1, lesion_group_cvgdistr(0,0,...
                'action','show_cvg_separately','summing_show_average', summing_show_average, ...
                'clr_by_grp', clr_by_grp, 'all_slices_interpolated', all_slices_interpolated);
        else lesion_group_cvgdistr(0,0,'action','add_thru_rois','summing_show_average', summing_show_average,...
                'clr_by_grp', clr_by_grp, 'all_slices_interpolated', all_slices_interpolated); end;

        % for each
    case 'net_pct_cvg'
        [ratset clr_by_grp] = sub__getratset(durset, freqset);
        lesion_group_cvgdistr(0,0,'action','buffer_data','metric', metric, 'all_slices_interpolated', all_slices_interpolated);

        out = lesion_group_cvgdistr(0,0,'action','compute_roi_points', 'all_slices_interpolated', all_slices_interpolated);
        totalroisum = out{1};
        roinet = out{2}; % roinet.AuD = sum of points across all slices
        areacount = out{3}; % areacount.AuD = point count at each slice

        out = lesion_group_cvgdistr(totalroisum,0,'action','compute_rat_roi_spread', 'all_slices_interpolated', all_slices_interpolated);
        duravg = out{1};
        freqavg = out{2};
        ratsum = out{3};
        ratnetcount = out{4}; % ratnetcount.Boromir.AuD.L = #

        maxslices= 33;
        mm_interval = ceil(1 / slice_interval); % how many in a group?
        numgrps = ceil(maxslices/mm_interval);

        % make a matrix of (rat x roi x pct)
        xlbls = {}; % ratname
        ylbls = {}; % roi

        rnames = fieldnames(ratnetcount);
        qnames = 0;

        qn = fieldnames(roinet);
        lmatrix = NaN(length(qn), length(rnames));
        rmatrix = NaN(length(qn), length(rnames));

        lgrped = cell(numgrps,1); % each cell is q-by-r
        rgrped = cell(numgrps,1);

        for g=1:numgrps,  lgrped{g} = NaN(length(qn), length(rnames));rgrped{g} = NaN(length(qn), length(rnames)); end;

        for r = 1:length(rnames)
            curr = eval(['ratnetcount.' rnames{r} ';']);
            xlbls{end+1} =rnames{r};

            qnames = fieldnames(curr);
            for q = 1:length(qnames) % rois
                cvgptsL = eval(['mega_lesioncvg.' rnames{r} '.' qnames{q} '.cvgpts__L;']);
                cvgptsR = eval(['mega_lesioncvg.' rnames{r} '.' qnames{q} '.cvgpts__R;']);

                curroi = eval(['curr.' qnames{q} ';']);
                rn = eval(['roinet.' qnames{q} ';']);
                areact = eval(['areacount.' qnames{q} ';']);

                ylbls{end+1} = qnames{q};
                lmatrix(q,r) = (curroi.L / rn)*100;
                rmatrix(q,r) = (curroi.R / rn)*100;

                %                 fprintf(1,'(%i,%i)\n\t', q,r);
                for g = 1:numgrps
                    sidx = (mm_interval* (g-1))+1; eidx = min(mm_interval*g, length(areact));
                    %                     fprintf(1,'%i to %i, ', sidx, eidx);

                    tmp = lgrped{g}; tmp(q,r) = nansum(cvgptsL(sidx:eidx))/nansum(areact(sidx:eidx));
                    lgrped{g} = tmp;

                    tmp = rgrped{g}; tmp(q,r) = nansum(cvgptsR(sidx:eidx))/nansum(areact(sidx:eidx));
                    rgrped{g} = tmp;
                end;
                %                 fprintf(1,'\n');
            end;
        end;

        % ldata is a repmat(R,A,1)
        % where R  = # rats
        %       A  = # ROI in set
        % so that R instances of (A-by-1) column vectors are stacked
        % (each stack is for a particular rat, and each stack has
        % that rat's coverage for each ROI in turn)

        viewopt = findobj('Tag','net_cvg_viewopt');
        val = get(viewopt, 'Value'); % 1 is 3d bar graph, 2 is areawise 2D plot

        % x will be A-by-R matrix.
        % where x(a,r) = coverage in ROI a for rat r
        xl = lmatrix; %reshape(ldata, length(rnames), length(qnames))';
        xr = rmatrix;%reshape(rdata, length(rnames), length(qnames))';

        % ---------------
        % val 1 -3d plot
        % ---------------
        if val == 1
            figure; set(gcf,'Position',[ 197 561  1402 380],'Toolbar','none','Tag','bar3d_pctcvg');
            subplot(1,2,1);
            bar3(xl,'detached');
            set(gca,'XTickLabel', xlbls, 'YTickLabel',ylbls);xlabel('Rat name');ylabel('ROI');zlabel('% coverage');
            title('LEFT');

            subplot(1,2,2);
            bar3(xr,'detached');
            set(gca,'XTickLabel', xlbls, 'YTickLabel',ylbls);xlabel('Rat name');ylabel('ROI');zlabel('% coverage');
            title('RIGHT');

            % --------------------------------------
            % point plot with a figure for each ROI
            % --------------------------------------
        elseif val == 2
            posx = 50; posy=200; wd = 300*2; ht = 200;
            msize =10;

            abbrev_rnames = cell(size(rnames));
            for r=1:length(rnames), abbrev_rnames{r} = rnames{r}(1:3);end;

            cmap = colormap;

            for q = 1:length(roiset)
                figure; set(gcf,'Position',[posx posy wd ht],'Toolbar','none','Menubar','figure');
                subplot(2,1,1);

                for l = 25:25:100, line([0 length(rnames)+1], [l l],'LineStyle',':','COlor',[1 1 1]*0.3); hold on; end;

                for c = 1:cols(xl)
                    plot(c, xl(q,c), '.r', 'MarkerSize', msize, 'Color', cmap(round((xl(q,c)/100)*rows(cmap)),:));
                end;

                xlabel('Rat name'); ylabel('LEFT');
                set(gca,'XTick', 1:cols(xl), 'XTickLabel', abbrev_rnames,'XLim',[0 length(rnames)+1],...
                    'YLim',[0 100],'YTick', 0:25:100);
                title(sprintf('%s % Coverage', qnames{q})); axes__format(gca);

                subplot(2,1,2);
                for l = 25:25:100, line([0 length(rnames)+1], [l l],'LineStyle',':','COlor',[1 1 1]*0.3); hold on; end;
                plot(1:cols(xr), xr(q,:), '.r', 'MarkerSize', msize);
                xlabel('Rat name'); ylabel('RIGHT');
                set(gca, 'XLim',[0 cols(xr)+1], 'XTick', 1:cols(xr), 'XTickLabel', abbrev_rnames,...
                    'YLim',[0 100],'YTick', 0:25:100);
                title(sprintf('%s % Coverage', qnames{q})); axes__format(gca);

                posx = posx+ wd+ 20;
                if posx > 1000, posx = 200; posy = posy+ht+50; end;
            end;
            % -----
            % bargraph for each group, which each bar showing range of coverage for a given ROI
            % -----
        elseif val == 3

            isdur = zeros(size(rnames));
            for r=1:length(rnames), if ismember(rnames{r}, durset) || strcmpi(rnames{r}, 'Eaglet'), isdur(r) = 1; end;end;

            hset = {'l','r'}; hemname ={'LEFT', 'RIGHT'}; hempos = [500 200];
            for h = 1:2

                % left hem first
                figure; set(gcf,'Position',[300 hempos(h) 850 240],'Toolbar','none','Menubar','figure','Tag', 'bar_pctcvg');
                xmax = (3*length(qnames)-1)+1;
                line([0 xmax], [50 50], 'LineStyle', ':','Color',[1 1 1]*0.3,'LineWidth',4);

                for q = 1:length(qnames) % go down each column of xl and xr
                    currx = (3* (q-1)) + 1;
                    arr = eval(['x' hset{h} '(q, isdur == 1)']);
                    curry = mean(arr);    sem = std(arr) / sqrt(length(arr));
                    patch([currx-0.5 currx-0.5 currx+0.5 currx+0.5], ...
                        [0 curry curry 0], ...
                        durclr,'EdgeColor','none'); hold on;
                    line([currx currx], [curry-sem curry+sem],'Color','k');

                    arr = eval(['x' hset{h} '(q, isdur == 0)']);
                    curry = mean(arr);    sem = std(arr) / sqrt(length(arr));
                    currx = currx+1;
                    patch([currx-0.5 currx-0.5 currx+0.5 currx+0.5], ...
                        [0 curry curry 0], ...
                        freqclr,'EdgeColor','none');
                    line([currx currx], [curry-sem curry+sem],'Color','k');
                end;
                ylabel('% coverage');
                text(xmax-3, 95, 'Duration','Color', durclr, 'FontSize',14, 'FontAngle', 'italic','FontWeight','bold');
                text(xmax-3, 85, 'Frequency','Color', freqclr, 'FontSize',14, 'FontAngle', 'italic','FontWeight','bold');
                set(gca,'XTick', 1:3:xmax, 'XTickLabel', qnames,'XLim',[0 xmax],'YLim',[0 100],'YTick',0:20:100);
                title(hemname{h},'Color','k');

                axes__format(gca);
                uicontrol('Tag', 'figname', 'Style','text', 'String', sprintf('roi_pctcvg_%s',hemname{h}), 'Visible','off');
            end;
            % ----------------------------
            % bargraph for each group, which each bar showing range of coverage for a given ROI in a rostrocaudal range
            % ----------------------------
        else
            isdur = zeros(size(rnames));
            for r=1:length(rnames), if ismember(rnames{r}, durset) || strcmpi(rnames{r}, 'Eaglet'), isdur(r) = 1; end;end;

            hset = {'l','r'}; hemname ={'LEFT', 'RIGHT'}; hempos = [500 200];
            for h = 1:2

                curr = eval([hset{h} 'grped;']);

                % left hem first
                figure; set(gcf,'Position',[100 hempos(h) 200*length(qnames) 240],'Toolbar','none','Menubar','figure','Tag', 'bar_pctcvg');
                axes('Position', [0.05 0.1 0.93 0.78]);
                xmax = ((3*length(qnames)*numgrps)-1)+1;
                line([0 xmax], [50 50], 'LineStyle', ':','Color',[1 1 1]*0.3,'LineWidth',4);hold on;
                line([0 xmax], [75 75], 'LineStyle', ':','Color',[0.5 1 0.5]*0.3,'LineWidth',4);

                currx = 1;
                xtk = [];

                for q = 1:length(qnames) % go down each column of xl and xr
                    spos = currx;
                    for g=1:numgrps
                        tmp = curr{g};
                        arr = tmp(q, isdur == 1)*100;

                        curry = mean(arr);    sem = std(arr) / sqrt(length(arr));                         dur = curry;
                        patch([currx-0.5 currx-0.5 currx+0.5 currx+0.5], ...
                            [0 curry curry 0], ...
                            durclr,'EdgeColor','none'); hold on;
                        line([currx currx], [curry-sem curry+sem],'Color','k');

                        arr = tmp(q, isdur == 0)*100;
                        curry = mean(arr);    sem = std(arr) / sqrt(length(arr)); freq = curry;
                        currx = currx+1;

                        patch([currx-0.5 currx-0.5 currx+0.5 currx+0.5], ...
                            [0 curry curry 0], ...
                            freqclr,'EdgeColor','none');
                        line([currx currx], [curry-sem curry+sem],'Color','k');

                        xtk = horzcat(xtk, currx-0.5);

                        if abs(dur - freq) > 20
                            text(currx-0.5, 85, '*','Color','r','FontSize', 20, 'FontWeight','bold');
                        end;

                        currx= currx+2;
                    end;
                    epos = currx;

                    text(mean([spos,epos]-4), 95,qnames{q},'FontWeight','bold','FontSize',18);
                    line([currx-1 currx-1], [0 100], 'Color','k','LineWidth',2);
                    currx = currx+1;
                end;
                title(hemname{h});
                set(gca,'XTick',xtk, 'XTickLabel', repmat(1:4,1, length(qnames)), 'YTick', 0:25:100);
                ylabel('% coverage');
                axes__format(gca);
                uicontrol('Tag', 'figname', 'Style','text', 'String', sprintf('mmwise_roi_pctcvg_%s',hemname{h}), 'Visible','off');
            end;
        end;

        % shows proportion each ROI composes of the total roiset
        % and proportion of the lesion that lives in each ROI (and how much is
        % unaccounted for)
    case 'lesion_distribution'
        if isempty(mega_lesioncvg) || mega_lesioncvg == 0,
            [ratset clr_by_grp] = sub__getratset(durset, freqset);
            lesion_group_cvgdistr(0,0,'action','buffer_data','metric', metric, ...
                'all_slices_interpolated', all_slices_interpolated);
        end;


        totalpoints = 0;
        roitotal = 0;
        rattotallesion = 0;
        roict = NaN(length(roiset),1);
        for r = 1:length(ratset)
            if strcmpi(ratset{r},'Jabber'), ratset{r} = 'Eaglet'; end;
            eval(['totalpoints.' ratset{r} '=0;']);
            for q=1:length(roiset)
                roi = roiset{q};
                eval(['totalpoints.' ratset{r} '.' roi '= ' ...
                    'nansum(mega_lesioncvg.' ratset{r} '.' roi '.cvgpts__R);']);
                %     'nansum(mega_lesioncvg.' ratset{r} '.' roi '.cvgpts__L);']);  % +' ...

                if r == length(ratset)
                    eval(['roitotal.' roi '= ' ...
                        'nansum(mega_lesioncvg.' ratset{r} '.' roi '.areapts__R);' ]);
                    %   'nansum(mega_lesioncvg.' ratset{r} '.' roi '.areapts__L);']);  %+' ...

                    roict(q) = eval(['roitotal.' roi]);
                end;

            end;

            % denominator -- total lesion size of both hemispheres
            eval(['rattotallesion.' ratset{r} '= ' ...
                'sum(mega_lesioncvg.' ratset{r} '.lesionpt__L) +' ...
                'sum(mega_lesioncvg.' ratset{r} '.lesionpt__R);']);

        end;

        % populate raw numbers into a matrix which can be used for plotting
        durct = NaN(length(durset), length(roiset)); % row is rat, col is roi
        durtotallesion = NaN(length(durset),1);
        for r = 1:length(durset)
            if strcmpi(durset{r},'Jabber'), durset{r} = 'Eaglet'; end;
            for q = 1:length(roiset)
                durct(r,q) = eval(['totalpoints.' durset{r} '.' roiset{q}]);
            end;
            durtotallesion(r) = eval(['rattotallesion.' durset{r} ';']);
        end;

        freqct = NaN(length(durset), length(roiset));
        freqtotallesion = NaN(length(freqset),1);
        for r = 1:length(freqset)
            for q = 1:length(roiset)
                freqct(r,q) = eval(['totalpoints.' freqset{r} '.' roiset{q}]);
            end;
            freqtotallesion(r) = eval(['rattotallesion.' freqset{r} ';']);
        end;

        % duration
        durmeanvals = mean(durct,1); dur__pieceopie = durmeanvals ./ mean(durtotallesion);
        freqmeanvals = mean(freqct,1); freq__pieceopie = freqmeanvals ./ mean(freqtotallesion);

        colormap summer;

        % duration pie
        xlbls= {};
        dur__pieceopie(end+1) = 1-sum(dur__pieceopie);
        for q = 1:length(roiset),
            xlbls{q} = sprintf('%s(%i%%)', roiset{q}, round(dur__pieceopie(q)*100));
        end;
        xlbls{end+1} = sprintf('%s(%i%%)', 'The rest', round(dur__pieceopie(end)*100));

        figure;
        set(gca,'Position',[0.01 0.01 0.95 0.95]);
        p= pie(dur__pieceopie ,xlbls);
        c = get(gca,'Children');
        for k =1:length(c), if strcmpi(get(c(k),'Type'), 'text'), set(c(k),'FontWeight','bold','FontSize',18), end; end;

        title('Duration');
        axes__format(gca);
        set(gcf,'Position',[440 24 800 700]);

        2;
        % frequency pie
        figure;
        xlbls= {};
        freq__pieceopie(end+1) = 1-sum(freq__pieceopie);
        for q = 1:length(roiset),
            xlbls{q} = sprintf('%s(%i%%)', roiset{q}, round(freq__pieceopie(q)*100));
        end;
        xlbls{end+1} = sprintf('%s(%i%%)', 'The rest', round(freq__pieceopie(end)*100));
        pie(freq__pieceopie, xlbls);
        title('Frequency');
        axes__format(gca);
        c = get(gca,'Children');
        for k =1:length(c), if strcmpi(get(c(k),'Type'), 'text'), set(c(k),'FontWeight','bold','FontSize',18), end; end;
        set(gcf,'Position',[440 24 800 700]);


        2;

    case 'add_thru_rois'

        use_mean_sd = 1; % set to true to use Mean+/-SD for graphs; when false, uses median and shows 25/75 percentiles as errorbars

        out = lesion_group_cvgdistr(0,0,'action','compute_roi_points', 'all_slices_interpolated', all_slices_interpolated);
        totalroisum = out{1};

        % get coverage
        out = lesion_group_cvgdistr(totalroisum,0,'action','compute_rat_roi_spread', 'all_slices_interpolated', all_slices_interpolated);
        duravg = out{1};
        freqavg = out{2};
        ratsum = out{3};

        % now plot coverage for group
        maxslice = 47;
        mm_interval = ceil(1 / slice_interval);
        halfmm = ceil(0.5 / slice_interval);
        halftks = 1+halfmm:halfmm:maxslice;
        xtks = 1:mm_interval:maxslice;
        xtklbls = atlas_beginpos:-1: atlas_beginpos - (length(xtks)-1);

        t = findobj('Tag','show_metric_opt'); tstr = get(t,'String'); showopt = tstr{get(t,'Value')};
        % set up figure, axes, tickmarks etc.,

        figure;
        set(gcf,'Tag', 'sumcvg');
        ax_right=axes('Units','normalized', 'Position', [0.07 0.1 0.89 0.37],'Tag', 'axR');
        if summing_show_average > 0
            sub__maketicks(xtks,maxslice);
        else
            if strcmpi(showopt(1:3),'pct'), sub__maketicks(xtks,maxslice);
            else maxy = 8000; sub__maketicks(xtks,maxslice,1000:1000:maxy,[], maxy);
            end;
        end;

        ax_left=axes('Units', 'normalized', 'Position', [0.07 0.55 0.89 0.37],'Tag', 'axL');
        if summing_show_average > 0
            sub__maketicks(xtks,maxslice);
        else
            if strcmpi(showopt(1:3),'pct'), sub__maketicks(xtks,maxslice);
            else maxy = 8000;sub__maketicks(xtks,maxslice,1000:1000:maxy,[], maxy);
            end;
        end;
        msize=10;lwdth=1;
        nannie_L = []; nannie_R =[];

        % show average "% coverage" trends
        if summing_show_average > 0
            str = {'dur','freq'};
            for t = 1:length(str)
                % ---- Do left hemisphere
                in = eval([str{t} 'avg.L']);
                rep_roisum = repmat(totalroisum.L, rows(in), 1);
                pct = in ./ rep_roisum;

                if use_mean_sd > 0
                    curr = nanmean(pct)*100;
                    sd = nanstd(pct)*100;
                    err_below = sd;
                    err_above = sd;
                else
                    qt = nan(3,cols(pct));
                    for k = 1:cols(pct),
                        tmp1 = pct(:,k);
                        tmp = prctile(tmp1, [25 50 75]); %percentile(tmp1(~isnan(tmp1)), [25 50 75]);
                        qt(:,k) = tmp;
                    end;
                    curr = qt(2,:)*100;
                    err_below = (qt(2,:) - qt(1,:))*100; err_above= (qt(3,:) - qt(2,:))*100;
                end;

                set(gcf,'CurrentAxes',ax_left);
                nanspots = sum(isnan(eval([str{t} 'avg.L']))); nannie = find(nanspots >= ceil(rows(eval([str{t} 'avg.L']))/2));

                %p=errorbar(1:length(curr), curr, err_below, err_above, ...
                p=plot(curr , ...
                    '-r', 'Color', eval([str{t} 'clr']),'LineWidth',3,'Marker','.','MarkerSize',msize+5); hold on;
                yvals = curr(nannie); yvals(isnan(yvals) > 0) = 0;

                % plot all data points at each level
                %                 c = eval([str{t} 'clr'])+0.1; c(c > 1) = 1;
                %                 for k = 1:cols(pct)
                %                     plot(ones(rows(pct),1)*k, pct(:,k)*100, ...
                %                     '.r', 'Color', c,'LineWidth',3,'Marker','.','MarkerSize',msize+5);
                %                 end;


                % mark spots where < 3 rats have contributed to data with
                % an x
                plot(nannie,yvals, 'xr','MarkerSize',15,'LineWidth',2,'Color',  eval([str{t} 'clr']));
                nannie_L = union(nannie_L, nannie);

                % ---- Now do right hemisphere
                in = eval([str{t} 'avg.R']);
                pct = in ./ rep_roisum;
                if use_mean_sd > 0
                    curr = nanmean(pct)*100;
                    sd = nanstd(pct)*100;
                    err_below = sd;
                    err_above = sd;

                else
                    qt = nan(3,cols(pct));
                    for k = 1:cols(pct),
                        tmp1 = pct(:,k);
                        tmp = prctile(tmp1, [25 50 75]); %percentile(tmp1(~isnan(tmp1)), [25 50 75]);
                        qt(:,k) = tmp;
                    end;
                    curr = qt(2,:)*100;
                    err_below = (qt(2,:) - qt(1,:))*100; err_above= (qt(3,:) - qt(2,:))*100;
                end;

                %                 curr = ( nanmean(eval([str{t} 'avg.R'])) ./ totalroisum.R ) * 100;
                %                 sd = ( nanstd(eval([str{t} 'avg.R'])) ./ totalroisum.R ) * 100;
                set(gcf,'CurrentAxes',ax_right);
                nanspots = sum(isnan(eval([str{t} 'avg.R']))); nannie = find(nanspots >= ceil(rows(eval([str{t} 'avg.R']))/2));

                %                p=errorbar(1:length(curr), curr, err_below, err_above, ...
                p = plot(curr, ...
                    '-r', 'Color', eval([str{t} 'clr']),'LineWidth',3,'Marker','.','MarkerSize',msize+5); hold on;
                yvals = curr(nannie); yvals(isnan(yvals) > 0) = 0;

                % plot all data points at each level
                %                 c = eval([str{t} 'clr'])+0.1; c(c > 1) =
                %                 1;
                %                 for k = 1:cols(pct)
                %                     plot(ones(rows(pct),1)*k, pct(:,k)*100, ...
                %                     '.r', 'Color', c,'LineWidth',3,'Marker','.','MarkerSize',msize+5);
                %                 end;

                % mark spots where < 3 rats have contributed to data with
                % an x
                plot(nannie,yvals, 'xr','MarkerSize',15,'LineWidth',2 ,'Color',  eval([str{t} 'clr']));
                nannie_R = union(nannie_R, nannie);
            end;
            uicontrol('Style','text','String', 'X: data from < 3 rats in either/both groups', 'Position', [15 5 250 10],...
                'FontWeight','bold','FontSize', 12,'BackgroundColor',get(gcf,'Color'));

            % if showing individual trends
        else
            t = findobj('Tag','show_metric_opt'); tstr = get(t,'String'); showopt = tstr{get(t,'Value')};

            set(ax_right,'Position', [0.07 0.15 0.8 0.37],'Tag', 'axR');
            set(ax_left, 'Position', [0.07 0.55 0.8 0.37],'Tag', 'axL');
            fig_ht = 400;

            chkpos = fig_ht-30;
            for r=1:length(ratset)
                ratname = ratset{r};
                if clr_by_grp > 0
                    isdur = ismember(ratname, durset);
                    if isdur, clr = durclr; else clr = freqclr; end;
                else
                    clr = diffclrs(r,:);
                end;

                if strcmpi(ratname, 'Jabber'), ratname = 'Eaglet'; end;

                uicontrol('Style','checkbox','String', [ratname '_L'], 'FontWeight','bold', 'ForegroundColor', 'w', 'Position',[925 chkpos     100 30],'BackgroundColor', clr, 'Callback',{'lesion_group_cvgdistr','action','toggle_indie_trend'},'Value',1);
                uicontrol('Style','checkbox','String', [ratname '_R'],  'FontWeight','bold', 'ForegroundColor', 'w', 'Position',[925 chkpos-200 100 30],'BackgroundColor', clr, 'Callback',{'lesion_group_cvgdistr','action','toggle_indie_trend'},'Value',1);
                chkpos = chkpos-30;

                set(gcf,'CurrentAxes',ax_left);
                if strcmpi(showopt(1:3),'pct')
                    currL = (eval(['ratsum.' ratname '.L;']) ./ totalroisum.L)*100;
                    currR = (eval(['ratsum.' ratname '.R;']) ./ totalroisum.R)*100;
                else
                    currL = eval(['ratsum.' ratname '.L;']);
                    currR = eval(['ratsum.' ratname '.R;']);
                end;

                p=plot(currL,'-r', 'Color', clr,'LineWidth',2,'Marker','.','MarkerSize',msize, 'Tag', [ratname '_L']); hold on;
                               plot(currL,'.r', 'Color', clr,'MarkerSize',20);
                %                set(p,'Tag', [curr_rat 'L'],'ButtonDownFcn', {@lesion_group_cvgdistr, 'action','show_slice','roi',roi});

                set(gcf,'CurrentAxes',ax_right);
                p=plot(currR,'-r', 'Color', clr,'LineWidth',2,'Marker','.','MarkerSize',msize,'Tag', [ratname '_R']); hold on;
               plot(currR,'.r', 'Color', clr,'MarkerSize',20); hold on;
                % set(p,'Tag', [curr_rat 'R'],'ButtonDownFcn', {@lesion_group_cvgdistr, 'action','show_slice','roi',roi});
            end;

            uicontrol('Style','popupmenu', 'String',interp_opt, 'Value',2,'Position', [800 chkpos-220 100 30],'Tag','interp_method');
            uicontrol('String','interpolate', 'FontWeight','bold','Position',[925 chkpos-210 100 30],'Callback',{'lesion_group_cvgdistr', 'action','interpolate_indie', 'all_slices_interpolated', all_slices_interpolated});
        end;

        if summing_show_average > 0 || strcmpi(showopt(1:3),'pct')
            ylbl = '% coverage';ymax = 105;ytk = 0:25:100;str = 'Cumulative % coverage (';
        else
            ylbl = 'total # points';ymax = max(totalroisum.L);ytk = 0:1000:ymax;str = 'Total point count (';
        end;
        
        lastx=0;
        firstx=100;
        for q = 1:length(roiset),
            str = [str roiset{q}];
            if q < length(roiset), str = [str ', ']; end;
            roie = eval(['roiexists.' roiset{q} ';']);
            lastx = max(lastx, max(find(roie==1)));
            firstx=min(firstx, min(find(roie==1)));
        end;
        
          if lastx-firstx < 10,
            xtks = 1:2:lastx+1;
            xtklbls=atlas_beginpos:-0.5: atlas_beginpos - (length(xtks)-1);
        end;

        % more axis formatting
        set(gcf,'CurrentAxes',ax_left); ylabel({ylbl,'(Left)'});
        set(gca,'XLim',[firstx-0.5 lastx+1],'XTick',xtks, 'XTickLabel', [],'YLim',[0 ymax],'YTick',ytk,'Tag','axL');

        str=  [str ')'];
% 
%         set(gcf,'CurrentAxes',ax_left); title(str);
%         set(gca,'XLim',[-0.5 maxslice+1],'XTick',xtks, 'XTickLabel', [],'YLim',[0 ymax],'YTick',ytk,'Tag','axL');
       axes__format(gca);   

        set(gcf,'CurrentAxes',ax_right); ylabel({ylbl,'(Right)'});
       set(gca,'XLim',[firstx-0.5 lastx+1]);
%       set(gca,'XTick', 1:lastx);
       set(gca,'XTick',xtks, 'XTickLabel', xtklbls,'YLim',[0 ymax],'YTick',ytk,'Tag','axR');

        axes__format(gca);
        xlabel('mm AP from bregma');

        set(gcf,'Position',[554 30        1046         400],'Toolbar','none');

        % plot difference in % coverage between the two groups
        if (summing_show_average > 0) && length(ratset) > 5
            figure;
            set(gcf,'Tag', 'cvg_diffgrps');
            ax_right=axes('Units','normalized', 'Position', [0.07 0.1 0.89 0.37],'Tag', 'axR');
            sub__maketicks(xtks,maxslice,-100:25:100, [],100);

            ax_left=axes('Units', 'normalized', 'Position', [0.07 0.55 0.89 0.37],'Tag', 'axL');
            sub__maketicks(xtks,maxslice,-100:25:100, [],100);

            % get dur and freq data--- LEFT hem
            indur = duravg.L;
            rep_roisumdur = repmat(totalroisum.L, rows(indur), 1);
            durpct = (indur ./ rep_roisumdur)*100;

            infreq = freqavg.L;
            rep_roisumfreq = repmat(totalroisum.L, rows(infreq), 1);
            freqpct = (infreq ./ rep_roisumfreq)*100;

            if use_mean_sd > 0
                curr = sum([nanmean(freqpct); -1*nanmean(durpct)],1);
                %                     sd = nanstd(pct)*100;
                %                     err_below = sd;
                %                     err_above = sd;
            else
                durqt = nan(3,cols(durpct));
                for k = 1:cols(durpct),
                    tmp1 = durpct(:,k);
                    tmp = prctile(tmp1, [25 50 75]); %percentile(tmp1(~isnan(tmp1)), [25 50 75]);
                    durqt(:,k) = tmp;
                end;
                dur_median = durqt(2,:);
                %                    err_below = (qt(2,:) - qt(1,:))*100; err_above=
                %                    (qt(3,:) - qt(2,:))*100;

                freqqt = nan(3,cols(freqpct));
                for k = 1:cols(freqpct),
                    tmp1 = freqpct(:,k);
                    tmp = prctile(tmp1, [25 50 75]); %percentile(tmp1(~isnan(tmp1)), [25 50 75]);
                    freqqt(:,k) = tmp;
                end;
                freq_median = freqqt(2,:);
                curr = sum([freq_median; -1*dur_median],1);
            end;
            sumcurr = curr;

            % do sig test
            sigdiff = NaN(1, cols(durpct));
            pval_diff = NaN(1,cols(durpct));

            emptydur = (sum(isnan(durpct),1) == rows(durpct));
            emptyfreq = (sum(isnan(freqpct),1) == rows(freqpct));

            if sum(abs(emptydur-emptyfreq)) > 0,
                error('Empty slices in durpct and freqpct should be the same');
            end;

            tmpdur = durpct(:,setdiff(1:cols(durpct), find(emptydur>0)));
            if sum(sum(isnan(tmpdur),1)) > 0, error('All NaNs in dur array not accounted for'); end;

            tmpfreq = freqpct(:,setdiff(1:cols(durpct), find(emptydur>0)));
            if sum(sum(isnan(tmpfreq),1)) > 0, error('All NaNs in freq array not accounted for'); end;


            blnkct = sum(emptydur);
            denom = 33 - blnkct;

            aval = (0.05 / denom)/2; % multiple-comparison correction
            bspots = find(emptydur > 0);
            for k = 1:cols(durpct)
                if ~ismember(bspots, k)
                    [sigdiff(k) pval_diff(k)] = permutationtest_diff(freqpct(:,k), durpct(:,k), 'alphaval', aval);

                end;
            end;

            set(gcf,'CurrentAxes',ax_left);
            p=plot(curr,'-r', 'Color', 'r','LineWidth',3,'Marker','.','MarkerSize',msize+5); hold on;
            sigpos = find(sigdiff==1);
            plot(sigpos, 80*ones(length(sigpos),1), '*r', 'MarkerSize', msize,'LineWidth', 3);
            for k = 1:cols(durpct)
                if ~isnan(pval_diff(k))
                    if pval_diff(k) < 0.1
                        if pval_diff(k) < 0.05
                            if pval_diff(k) < 0.01, c = [1 0 0 ];
                            else c = [1 0.5 0]; end;
                        else
                            c=[1 1 0];
                        end;

                        patch([k-0.5 k-0.5 k+0.5 k+0.5],[80 100 100 80], c, 'EdgeColor','none');
                        text(k, 90, num2str(k),'FontWeight','bold','FontSize',10);
                    end;
                end;
            end;

            % plot points where < 3 rats have contributed to the data
            yvals = sumcurr(nannie_L); yvals(isnan(yvals) > 0) = 0;
            plot(nannie_L, yvals,'xk', 'MarkerSize',15,'LineWidth',2);
            uicontrol('Style','text','String', 'X: data from < 3 rats in either/both groups', 'Position', [15 5 250 10],...
                'FontWeight','bold','FontSize', 12,'BackgroundColor',get(gcf,'Color'));

            % Now repeat for RIGHT HEMISPHERE

            %             freqpct = (nanmean(freqavg.R) ./ totalroisum.R)*100;
            %             durpct = (nanmean(duravg.R) ./ totalroisum.R)*100;
            %             curr = [freqpct; -1*durpct];sumcurr = sum(curr,1);

            indur = duravg.R;
            durpct = (indur ./ rep_roisumdur)*100;
            infreq = freqavg.R;
            freqpct = (infreq ./ rep_roisumfreq)*100;
            if use_mean_sd > 0
                curr = sum([nanmean(freqpct); -1*nanmean(durpct)],1);
                %                     sd = nanstd(pct)*100;
                %                     err_below = sd;
                %                     err_above = sd;
            else
                durqt = nan(3,cols(durpct));
                for k = 1:cols(durpct),
                    tmp1 = durpct(:,k);
                    tmp = prctile(tmp1, [25 50 75]); %percentile(tmp1(~isnan(tmp1)), [25 50 75]);
                    durqt(:,k) = tmp;
                end;
                dur_median = durqt(2,:);
                %                    err_below = (qt(2,:) - qt(1,:))*100; err_above=
                %                    (qt(3,:) - qt(2,:))*100;

                freqqt = nan(3,cols(freqpct));
                for k = 1:cols(freqpct),
                    tmp1 = freqpct(:,k);
                    tmp = prctile(tmp1, [25 50 75]); %percentile(tmp1(~isnan(tmp1)), [25 50 75]);
                    freqqt(:,k) = tmp;
                end;
                freq_median = freqqt(2,:);
                curr = sum([freq_median; -1*dur_median],1);
            end;
            sumcurr = curr;


            % do sig test
            sigdiff = NaN(1, cols(durpct));
            pval_diff = NaN(1,cols(durpct));

            emptydur = (sum(isnan(durpct),1) == rows(durpct));
            emptyfreq = (sum(isnan(freqpct),1) == rows(freqpct));

            if sum(abs(emptydur-emptyfreq)) > 0,
                error('Empty slices in durpct and freqpct should be the same');
            end;

            tmpdur = durpct(:,setdiff(1:cols(durpct), find(emptydur>0)));
            if sum(sum(isnan(tmpdur),1)) > 0, error('All NaNs in dur array not accounted for'); end;

            tmpfreq = freqpct(:,setdiff(1:cols(freqpct), find(emptyfreq>0)));
            if sum(sum(isnan(tmpfreq),1)) > 0, error('All NaNs in freq array not accounted for'); end;

            blnkct = sum(emptydur);
            denom = 33 - blnkct;

            aval = (0.05 / denom)/2; % multiple-comparison correction
            bspots = find(emptydur > 0);
            for k = 1:cols(durpct)
                if ~ismember(bspots, k)
                    [sigdiff(k) pval_diff(k)] = permutationtest_diff(freqpct(:,k), durpct(:,k), 'alphaval', aval);

                end;
            end;

            set(gcf,'CurrentAxes',ax_right);
            p=plot(curr,'-r', 'Color', 'r','LineWidth',3,'Marker','.','MarkerSize',msize+5); hold on;
            sigpos = find(sigdiff==1);

            plot(sigpos, 80*ones(length(sigpos),1), '*r', 'MarkerSize', msize,'LineWidth', 3);
            for k = 1:cols(durpct)
                if ~isnan(pval_diff(k))
                    if pval_diff(k) < 0.1
                        if pval_diff(k) < 0.05
                            if pval_diff(k) < 0.01, c = [1 0 0 ];
                            else c = [1 0.5 0]; end;
                        else
                            c=[1 1 0];
                        end;

                        patch([k-0.5 k-0.5 k+0.5 k+0.5],[80 100 100 80], c, 'EdgeColor','none');
                        text(k, 90, num2str(k),'FontWeight','bold','FontSize',10);
                    end;
                end;
            end;

            yvals = sumcurr(nannie_R); yvals(isnan(yvals) > 0) = 0;
            plot(nannie_R, yvals,'xk', 'MarkerSize',15,'LineWidth',2);

            % more axis formatting
            set(gcf,'CurrentAxes',ax_left);
            ylabel('LEFT (% cvg)');
            set(gca,'XLim',[-0.5 maxslice+1],'XTick',xtks, 'XTickLabel', [],'YLim',[-105 105],'YTick',-100:25:100,'Tag','axL');
            str = 'Freq coverage - Dur coverage (';
            for q = 1:length(roiset), str = [str roiset{q}]; if q < length(roiset), str = [str ', ']; end; end;
            str=  [str ')'];
            set(gcf,'CurrentAxes',ax_left); title(str);
            axes__format(gca);

            set(gcf,'CurrentAxes',ax_right);
            ylabel('RIGHT (% cvg)');
            set(gca,'XLim',[-0.5 maxslice+1],'XTick',xtks, 'XTickLabel', xtklbls,'YLim',[-105 105],'YTick',-100:25:100,'Tag','axR');
            axes__format(gca);


            set(gcf,'Position',[790 700 1046  400], 'Toolbar','none');
            uicontrol('Tag', 'figname', 'Style','text', 'String', 'Freq_minus_dur_cvg', 'Visible','off');
        end;

    case 'show_cvg_separately'
        % get coverage
        out = lesion_group_cvgdistr(0,0,'action','compute_roi_points', 'all_slices_interpolated', all_slices_interpolated);
        totalroisum = out{1};
        out = lesion_group_cvgdistr(totalroisum,0,'action','compute_rat_roi_spread', 'all_slices_interpolated', all_slices_interpolated);
        duravg = out{1};
        freqavg = out{2};
        ratsum = out{3};

        % now plot coverage for group
        maxslice = 47;

        mm_interval = ceil(1 / slice_interval);
        halfmm = ceil(0.5 / slice_interval);
        xtks = 1:mm_interval:maxslice;
        halftks = 1+halfmm:halfmm:maxslice;
        xtklbls = atlas_beginpos:-1: atlas_beginpos - (length(xtks)-1);
        for m = 1:length(roiset)
            roi = roiset{m};

            % set up figure, axes, tickmarks etc.,
            figure;
            set(gcf,'Tag', roi);
            ax_right=axes('Units','normalized', 'Position', [0.1 0.1 0.89 0.42],'Tag', 'axR');

            % mark patch where roi doesn't exist
            currexist = eval(['roiexists.' roi ';']);
            empt = find(currexist == 0);
            maxy = 120;

            for k=1:length(empt)
                e = empt(k);
                patch([e e e+1 e+1], [0 maxy maxy 0], [0.8 0.8 1]*0.9,'EdgeColor','none');
            end;

            for x=1:length(xtks)
                line([xtks(x) xtks(x)], [0 105],'Color', [1 1 1]*0,'LineStyle',':','LineWidth',2); hold on;
            end;

            ax_left=axes('Units', 'normalized', 'Position', [0.1 0.55 0.89 0.42],'Tag', 'axL');

            % mark patch where roi doesn't exist
            currexist = eval(['roiexists.' roi ';']);
            empt = find(currexist == 0);
            for k=1:length(empt)
                e = empt(k);
                patch([e e e+1 e+1], [0 maxy maxy 0], [0.8 0.8 1]*0.9,'EdgeColor','none');
            end;
            for x=1:length(xtks)
                line([xtks(x) xtks(x)], [0 105],'Color', [1 1 1]*0,'LineStyle',':','LineWidth',2); hold on;
            end;

            msize=10;
            lwdth=1;

            % plot coverage data for the roi
            lftbuff = eval(['bufferL.' roi ';']);
            rtbuff = eval(['bufferR.' roi ';']);

            for r = 1:rows(lftbuff)
                clr = diffclrs(r,:);
                curr_rat = ratset{r};

                set(gcf,'CurrentAxes',ax_left);
                curr = lftbuff(r,:)*100;
                p=plot(curr,'-r', 'Color', clr,'LineWidth',lwdth,'Marker','.','MarkerSize',msize); hold on;
                set(p,'Tag', [curr_rat 'L'],'ButtonDownFcn', {@lesion_group_cvgdistr, 'action','show_slice','roi',roi});

                set(gcf,'CurrentAxes',ax_right);
                curr = rtbuff(r,:)*100;
                p=plot(curr,'-r', 'Color', clr,'LineWidth',lwdth,'Marker','.','MarkerSize',msize); hold on;
                set(p,'Tag', [curr_rat 'R'],'ButtonDownFcn', {@lesion_group_cvgdistr, 'action','show_slice','roi',roi});
            end;

            % more axis formatting
            set(gcf,'CurrentAxes',ax_left);
            patch([-0.3 -0.3 0.5 0.5], [0 105 105 0],[1 1 0.8],'EdgeColor','none');
            text(0, 25, roi,'FOntSize', 18, 'FontWeight','bold','Rotation',90);
            ylabel('LEFT');
            set(gca,'XLim',[-0.5 maxslice+1],'XTick',xtks, 'XTickLabel', [],'YLim',[0 105],'YTick',0:25:100,'Tag','axL');
            axes__format(gca);

            set(gcf,'CurrentAxes',ax_right);
            ylabel('RIGHT');
            patch([-0.3 -0.3 0.5 0.5], [0 105 105 0],[1 1 0.8],'EdgeColor','none');
            text(0, 25, roi,'FOntSize', 18, 'FontWeight','bold','Rotation',90);
            set(gca,'XLim',[-0.5 maxslice+1],'XTick',xtks, 'XTickLabel', xtklbls,'YLim',[0 105],'YTick',0:25:100,'Tag','axR');
            axes__format(gca);

            set(gcf,'Position',[ 33 (340*(m-1))-110        720         330],...
                'Menubar','none','Toolbar','none');
        end;

        % interpolate individual coverages to cover the NaN points
    case 'interpolate_indie'
        kids = get(gcf,'Children');
        t = findobj('Tag','interp_method'); ipopt = get(t,'String'); ipval = get(t,'Value'); interp_method = ipopt{ipval};

        out = lesion_group_cvgdistr(0,0,'action','compute_roi_points', 'all_slices_interpolated', all_slices_interpolated);
        totalroisum = out{1};

        for k = 1:length(kids)
            if strcmpi(get(kids(k),'Type'),'axes')
                set(gcf,'CurrentAxes', kids(k));
                axkids = get(kids(k), 'Children');
                for a = 1:length(axkids)
                    t = get(axkids(a),'Tag');
                    if ~isempty(t) && (strcmpi(t(end-1:end),'_L') || strcmpi(t(end-1:end),'_R'))
                        p = axkids(a);

                        if strcmpi(interp_method,'none')
                            t2 = [t 'interp'];
                            p2 = findobj('Tag', t2);
                            if ~isempty(p2), set(p2,'Visible','off'); end;
                        else
                            xval = get(p,'XData'); yval = get(p,'YData');
                            nempt = find(~isnan(yval) > 0);
                            isempt = setdiff(xval, nempt);
                            newy = interp1([0 nempt length(xval)+1], [0 yval(nempt) 0], xval, interp_method);
                            newy(nempt) = NaN;
                            %newy(find(newy > 100)) = 100;
                            newy(find(newy < 0)) = 0;

                            % doesn't matter which hem you take totalroisum
                            % from since both hems should have the same
                            % count
                            roisum = totalroisum.L;
                            newy(find(roisum == 0)) = NaN; % there should be no points where there are no ROIs
                            % cap upper bound
                            df = newy - roisum; idx = find(df > 0); % find those places where the interpolated value is > total point count
                            newy(idx) = roisum(idx);


                            t2 = [t 'interp'];
                            p2 = findobj('Tag', t2);
                            if ~isempty(p2)
                                set(p2,'XData', xval,'YData', newy);
                            else
                                p2 = plot(xval, newy, '.r', 'LineStyle',':', 'Color', get(p,'Color'),'LineWidth',2,'MarkerSize',10,'Marker','o','Tag',t2);
                            end;
                            set(p2,'Visible',get(p,'Visible'));
                        end;
                    end;
                end;
            end;
        end;


        % shows total # points for each slice for each ROI
    case 'roi_count_plot'
        [ratset clr_by_grp] = sub__getratset(durset, freqset);
        lesion_group_cvgdistr(0,0,'action','buffer_data','metric', metric, 'all_slices_interpolated', all_slices_interpolated);

        maxslice = 47;
        mm_interval = ceil(1 / slice_interval);
        halfmm = ceil(0.5 / slice_interval);
        halftks = 1+halfmm:halfmm:maxslice;
        xtks = 1:mm_interval:maxslice;
        xtklbls = atlas_beginpos:-1: atlas_beginpos - (length(xtks)-1);
        msize=10;lwdth=1;

        figure;  set(gcf,'Position',[565         643        1033         232],...
            'Toolbar','none');

        %         ax_left=axes('Position', [0.07 0.55 0.8 0.37], 'Tag', 'ax_roi_L');
        maxy = 8000;
        %         sub__maketicks(xtks,maxslice,1000:1000:maxy,[], maxy);
        ax_right=axes('Position', [0.07 0.1 0.8 0.75], 'Tag', 'ax_roi_R');
        sub__maketicks(xtks,maxslice,1000:1000:maxy,[], maxy);
        fig_ht = 400;
        chkpos = fig_ht-30;

        % buffer total number of points in an ROI
        if ~exist('ratset','var') || isempty(ratset)

        end;
        r = ratset{1}; eval(['mystruct = mega_lesioncvg.' r ';']);
        maxpts = 0;
        for q = 1:length(roiset)
            clr = diffclrs(q,:);
            roi = roiset{q};
            eval(['curr = mystruct.' roi ';']);

            %   uicontrol('Style','checkbox','String', [roi '_L'], 'FontWeight','bold', 'ForegroundColor', 'w', 'Position',[925 chkpos     100 30],'BackgroundColor', clr, 'Callback',{'lesion_group_cvgdistr','action','toggle_indie_trend'},'Value',1);
            uicontrol('Style','checkbox','String', [roi '_R'],  'FontWeight','bold', 'ForegroundColor', 'w', 'Position',[925 chkpos-200 100 30],'BackgroundColor', clr, 'Callback',{'lesion_group_cvgdistr','action','toggle_indie_trend'},'Value',1);
            chkpos = chkpos-30;

            %   set(gcf,'CurrentAxes', ax_left);
            %   p=plot(curr.areapts__L,'-r', 'Color', clr,'LineWidth',2,'Marker','.','MarkerSize',msize, 'Tag', [roi '_L']); hold on;
            set(gcf,'CurrentAxes', ax_right);
            p=plot(curr.areapts__R,'-r', 'Color', clr,'LineWidth',2,'Marker','.','MarkerSize',msize, 'Tag', [roi '_R']); hold on;
            maxpts = max(maxpts, max(curr.areapts__R));
        end;

        %         set(gcf,'CurrentAxes',ax_left);
        %         set(gca,'XLim',[-0.5 maxslice+1],'XTick',xtks, 'XTickLabel', xtklbls);
        %         axes__format(gca);

        set(gcf,'CurrentAxes',ax_right);
        set(gca,'XLim',[-0.5 maxslice+1]);
        set(gca,'XTick',1:1:maxslice);
        %'XTick',0:maxslice, 'XTickLabel', xtklbls,
        set(gca,'YLim', [0 1.05*maxpts]);
        title('ROI total point count');
      %  axes__format(gca);

    case 'show_slice'
        ratname = get(firstarg,'Tag');
        roi = get(gcf,'Tag');
        xpos = get(gca,'CurrentPoint');
        xpos = round(xpos(1,1));

        cf = gcf;

        f=findobj('Tag', 'lesion_cvgdistr_gruntwork');
        if isempty(f), f=figure; end;
        set(0,'CurrentFigure', f);
        clf;
        hem = ratname(end);
        ratname = ratname(1:end-1);
        if strcmpi(ratname, 'Jabber'), ratname = 'Eaglet'; end;
        lesion_slice_coverage(ratname,roi, ...
            'slices', xpos,'hem', hem,...
            'graphic_gruntwork',1, 'verbose_gruntwork', 1,'usefig_gruntwork', f);

        pos = get(gcf,'Position');
        set(gcf,'Position',[803 -78 pos(3) pos(4)],'Menubar','none','Toolbar','none');
        set(gcf,'Tag', 'lesion_cvgdistr_gruntwork');
        set(0,'CurrentFigure', cf);

        figure(f);

    case 'closefigs'
        % Close all windows generated by this script
        taglist = [roiset 'sumcvg', 'bar_pctcvg', 'bar3d_pctcvg'];
        %  taglist = {taglist, 'sessionview','loadpsych','pokeviewer','sessionduration','dailyglimpse','dailypsych'};
        for currt = 1:length(taglist)
            f = findobj('Tag',taglist{currt});
            for k = 1:length(f)
                b = f(k);
                eval(sprintf('close %i', b));
            end;
        end;
        return;

    case 'compute_roi_points'
        totalroisum = []; % how many total points were in the ROI? keys: rois, values: # points per slice.
        totalroisum.L = [];
        totalroisum.R = [];

        roinet = [];
        areacount = [];

        if isempty(mega_lesioncvg) || (~isstruct(mega_lesioncvg) && mega_lesioncvg == 0),
            [ratset clr_by_grp] = sub__getratset(durset, freqset);
            lesion_group_cvgdistr(0,0,'action','buffer_data','metric', metric, ...
                'all_slices_interpolated', all_slices_interpolated);
        end;

        % buffer total number of points in an ROI
        r = ratset{1}; eval(['mystruct = mega_lesioncvg.' r ';']);
        for q = 1:length(roiset)
            roi = roiset{q};
            eval(['curr = mystruct.' roi ';']);

            tmpcL = curr.areapts__L;if rows(tmpcL)>1, tmpcL=tmpcL'; end;
            tmpcR = curr.areapts__R;if rows(tmpcR)>1, tmpcR=tmpcR'; end;
            
            totalroisum.L = vertcat(totalroisum.L, tmpcL);
            totalroisum.R = vertcat(totalroisum.R, tmpcR);

            %            eval(['roinet.' roi '=[];']);
            %            eval(['areacount.' roi '=[];']);
            eval(['roinet.' roi ' = nansum(curr.areapts__L);']);
            eval(['areacount.' roi ' = curr.areapts__L;']);
        end;

        % Note: Points where none of the ROIs exist have 0 as the # of
        % points
        if length(roiset) > 1
            totalroisum.L = nansum(totalroisum.L);
            totalroisum.R = nansum(totalroisum.R);
        else
            totalroisum.L(isnan(totalroisum.L) > 0) = 0;
            totalroisum.R(isnan(totalroisum.R) > 0) = 0;
        end;

        out = {};
        out{1} = totalroisum;
        out{2} = roinet;
        out{3} = areacount;

    case 'compute_rat_roi_spread'
        totalroisum = firstarg;
        % now add points for all rois for each rat
        duravg = []; duravg.L = []; duravg.R = [];
        freqavg = []; freqavg.L =[]; freqavg.R = [];
        ipopt = findobj('Tag', 'interp_opt_main'); ipstr = get(ipopt, 'String');
        if all_slices_interpolated > 0,
            ipmethod = 'none';
        else
            ipmethod = ipstr{get(ipopt,'Value')};
        end;

        ratnetcount = []; % rat.roi.L = (sum of all points covering an ROI in a given rat hemisphere)

        for r=1:length(ratset)
            ratname = ratset{r};
            isdur = ismember(ratname, durset);
            if strcmpi(ratname,'Jabber'), ratname = 'Eaglet'; end;
            eval(['mystruct = mega_lesioncvg.' ratname ';']);

            eval(['ratsum.' ratname ' = [];']);
            eval(['ratsum.' ratname '.L = [];']);
            eval(['ratsum.' ratname '.R = [];']);

            eval(['ratnetcount.' ratname '=[];']);

            tmpstruct = eval(['ratsum.' ratname ';']);
            nxl = eval(['NXmarked__L.' ratname ';']);
            nxr = eval(['NXmarked__R.' ratname ';']);

            mega_roie = [];

            % add coverage points for each ROI
            for q = 1:length(roiset)
                roi = roiset{q};
                eval(['roistruct = mystruct.' roi ';']);

                % sanity check - if a rat has NaN on a given slot, it should be because either:
                % 1. the roi does not exist at that point
                % 2. he has an 'N' marked for that entire slice.
                roie = eval(['roiexists.' roi ';']); empties = find(roie == 0);
                if isempty(mega_roie)
                    mega_roie = roie;
                else
                    mega_roie = or(mega_roie, roie);
                end;

                nannie = find(isnan(roistruct.cvgpts__L) > 0);
                for n = 1:length(nannie)
                    if ~(ismember(nannie(n), empties) || strcmp(nxl(nannie(n)),'N'))
                        fprintf(1,'%s: %s: %iL: Found a NaN where I shouldn''t have',ratname, roi, nannie(n));
                    end;
                end;

                nannie = find(isnan(roistruct.cvgpts__R) > 0);
                for n = 1:length(nannie)
                    if ~(ismember(nannie(n), empties) || strcmp(nxr(nannie(n)),'N'))
                        fprintf(1,'%s: %s: %iR: Found a NaN where I shouldn''t have\n',ratname, roi, nannie(n));
                    end;
                end;

                tmpcL = roistruct.cvgpts__L;
                if rows(tmpcL) > 1, tmpcL=tmpcL';end;
                tmpcR=roistruct.cvgpts__R;
                if rows(tmpcR)>1, tmpcR=tmpcR'; end;

                tmpstruct.L = vertcat(tmpstruct.L, tmpcL);
                tmpstruct.R = vertcat(tmpstruct.R, tmpcR);

                tmpnet = eval(['ratnetcount.' ratname]);
                eval(['tmpnet.' roi ' = [];']);
                eval(['tmpnet.' roi '.L = nansum(roistruct.cvgpts__L);']);
                eval(['tmpnet.' roi '.R = nansum(roistruct.cvgpts__R);']);

                eval(['ratnetcount.' ratname '= tmpnet;']);
            end;

            % at this point, tmpstruct should be a struct with two arrays,
            % one for each hemisphere.
            % Each array should be R-by-S, where R = # ROIs, and S = #
            % slices in the set.
            isempt = find(mega_roie == 0);
            % tmpstruct should now have the points added across all ROIs.
            % if not working with completely interpolated data, set those
            % we know to be ND to be NaN.
            if length(roiset) > 1
                tmpstruct.L = nansum(tmpstruct.L);
                tmpstruct.R = nansum(tmpstruct.R);

                if all_slices_interpolated == 0
                    nanspots = strfind(nxl,'N'); tmpstruct.L(nanspots) = NaN;
                    tmpstruct.L(isempt) = NaN;
                    nanspots = strfind(nxr,'N'); tmpstruct.R(nanspots) = NaN;
                    tmpstruct.R(isempt) = NaN;
                end;
            end;

            % what we're interpolating is the number of coverage points on
            % any given slice... for each rat.
            if ~strcmpi(ipmethod, 'none')
                [x lvalip] = sub__interpolatedata(1:length(tmpstruct.L), tmpstruct.L, ipmethod,totalroisum.L);
                [x rvalip] = sub__interpolatedata(1:length(tmpstruct.R), tmpstruct.R, ipmethod,totalroisum.R);

                isempt = find(mega_roie == 0);
                lvalip(isempt) = NaN;
                rvalip(isempt) = NaN;

                %                figure; plot(tmpstruct.L,'.r'); hold on; plot(lvalip,'ob'); title('LEFT');
                %                figure; plot(tmpstruct.R,'.r'); hold on;
                %                plot(rvalip,'ob'); title('RIGHT');
            else
                lvalip = tmpstruct.L;
                rvalip = tmpstruct.R;
            end;

            if isdur > 0
                duravg.L = vertcat(duravg.L, lvalip);
                duravg.R = vertcat(duravg.R, rvalip);
            else
                freqavg.L = vertcat(freqavg.L, lvalip);
                freqavg.R = vertcat(freqavg.R, rvalip);
            end;

            eval(['ratsum.' ratname '= tmpstruct;']);
        end;

        out = {};

        out{1} = duravg; % row: rat, col: sum(points for all roi)
        out{2} = freqavg; % same as duravg but for frequency rats
        out{3} = ratsum; % same thing as duravg and freqavg but in a different format. key: rat, value: sum(points for all roi)
        out{4} = ratnetcount; % rat.roi.hem = sum points in that roi


    case 'toggle_indie_trend'
        tg = findobj('Tag',get(firstarg,'String'));
        if get(firstarg,'Value') > 0
            set(tg,'Visible','on');
            tg = findobj('Tag',[get(firstarg,'String') 'interp']); % show the interpolated graph, if it exists
            if ~isempty(tg)
                set(tg, 'Visible','on');
            end;
        else
            set(tg,'Visible','off');
            tg = findobj('Tag',[get(firstarg,'String') 'interp']);
            if ~isempty(tg)
                set(tg, 'Visible','off');
            end;
        end;

        %     case'toggle_interp_data'
        %         itag = findobj('Tag','load_interp_opt');
        %         str = get(itag,'String');
        %         if get(itag,'Value') == 2
        %             all_slices_interpolated = 1;
        %             infile = interp_datafile;
        %         else
        %             all_slices_interpolated = 0;
        %             infile = raw_datafile;
        %         end;
        %
        %         fprintf(1,'**** Data source changed to %s. Recompute data\n', upper(str{get(itag,'Value')}));

    otherwise
        error('invalid action');


end;


% -------------------------------------------------------------------------
% Subroutines

% marks spots which are known to be devoid of lesion "X" as being 0 in
% cvgarray
function [cvgarray] = sub__treatX(cvgarray, NDstring, all_slices_interpolated)
emptyspots = findstr(NDstring, 'X');

if ~isempty(emptyspots) && ~all_slices_interpolated,  % mark empty spots
    esp = cvgarray(emptyspots);
    valid = union(find(isnan(esp) > 0) , find(esp == 0));
    if length(valid) < length(esp)
        error('Empty spots should either be 0 or NaN.');
    end;
    cvgarray(emptyspots) = 0;
elseif ~isempty(emptyspots)
    cvgarray(emptyspots) = 0;
end;


function [cvgarray] = sub__treatND(cvgarray, NDstring, method)
ndspots = findstr(NDstring,'N');
non_nd = setdiff(1:length(NDstring), ndspots);

newarray = NaN(size(cvgarray));
newarray(non_nd) = cvgarray(non_nd);
switch method
    case 'bestcase'  % set ND value to be equal to smallest closest value
        for k = 1:length(ndspots)
            pos = ndspots(k);
            dist = abs(pos - non_nd);
            closest = non_nd(find(dist == min(dist)));
            if length(closest) > 1
                if length(closest) > 2
                    error('There can be atmost two closest points: one on either side of the void');
                else
                    newval = min(cvgarray(closest));
                end;
            else
                newval = cvgarray(closest);
            end;
            newarray(pos) = newval;
        end;

        cvgarray = newarray;
    case 'worstcase' % set ND spots to zero
        if ~isempty(ndspots),  % mark empty spots
            esp = cvgarray(ndspots);
            if sum(isnan(esp)) ~= length(esp)
                error('Why are some non-NaN spots being marked as being empty?');
            end;
            cvgarray(emptyspots) = 0;
        end;

    case 'ignore'
        % do nothing
    otherwise
        error('Invalid ND treatment method');
end;

function [] = sub__maketicks(xtks,maxslice,yvals, miniyvals, maxy)

lwdth = 2;
lclr = [1 1 1] * 0.3;
if nargin == 2,
    yvals = 25:25:100;
    miniyvals = 10:10:100;
    maxy=100;
end;

for x=1:length(xtks)
    line([xtks(x) xtks(x)], [0 maxy*1.05],'Color', lclr,'LineStyle',':','LineWidth',lwdth); hold on;
end;

for y = 1:length(yvals)
    line([0 maxslice], [yvals(y) yvals(y)], 'LineStyle',':','Color', lclr, 'LineWidth',lwdth);
end;
yvals =miniyvals;
% for y = 1:length(yvals)
%     line([0 maxslice], [yvals(y) yvals(y)], 'LineStyle',':','Color', lclr, 'LineWidth',lwdth / 2);
% end;

function [ratset clr_by_grp] = sub__getratset(durset, freqset)
% get ratset
robj = findobj('Tag','ratset_opt'); r = get(robj,'String'); idx = get(robj,'Value');
switch r{idx}
    case 'duration', ratset = durset; clr_by_grp=0;
    case 'frequency', ratset = freqset; clr_by_grp=0;
    case 'combine', ratset = [durset freqset]; clr_by_grp=1;
    otherwise
        error('invalid ratset');
end;

function [xip yip] = sub__interpolatedata(xval, yval, interp_method, roisum)
nempt = find(~isnan(yval) > 0);
isempt = setdiff(xval, nempt);
newy = interp1([0 nempt length(xval)+1], [0 yval(nempt) 0], xval, interp_method);

newy(nempt) = NaN;
newy(find(newy < 0)) = 0;
newy(nempt) = yval(nempt);

% doesn't matter which hem you take totalroisum
% from since both hems should have the same
% count
newy(find(roisum == 0)) = NaN; % there should be no points where there are no ROIs
% cap upper bound
df = newy - roisum; idx = find(df > 0); % find those places where the interpolated value is > total point count
newy(idx) = roisum(idx);

xip = xval;
yip = newy;



%         if ~(clr_by_grp >0|| summing_show_average>0)
%             % legend
%             figure; set(gcf,'Position',[766   639   128   215],'Menubar','none','TOolbar','none');
%             axes('Position',[0.01 0.01 0.95 0.96], 'XTick',[], 'YTick',[]);
%             for k =1:length(ratset)
%                 patch([0 0 1 1], [k k+1 k+1 k], diffclrs(k,:), 'EdgeColor','none');
%                 text(0.2, k+0.5, ratset{k}, 'FontWEight','bold','FOntSize', 16,'Color','w');
%             end;
%         end;
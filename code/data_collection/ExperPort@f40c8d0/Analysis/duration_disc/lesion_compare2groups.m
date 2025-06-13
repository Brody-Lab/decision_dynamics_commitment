function [out] = lesion_compare2groups(varargin)

% Compares aggregate lesion coverage in duration and frequency groups in
% variety of ways, depending on value of viewopt.
% 1 is 3d bar graph,
% 2 is areawise 2D plot
% 3 is areawise bar graph
% 4 is areawise mmwise bargraph
% 5 is correlational graph
% 6 is % coverage for all areas combined (sum of) for each group. Shows
% second graph with coverage of each rat (1d data, no impairment info)
% 7 is - show no graphs. return coverage and impairment value for dur/freq
% group

pairs= { ...
    'area_filter','ACx2'; ...
    'viewopt', 7 ; ...
    % --- Input files
    'interp_datafile', 'lesion_coverage_calc__interpol'; ...
    'raw_datafile', 'lesion_coverage_calc' ; ...
    'datafile', 'lesion_coverage_calc' ; ...
    'datafile_hpc','lesion_coverage_calc_Hpc' ; ...
    'scoring_file', 'scoring_0806' ; ...
    'impair_addfname', 'BLAH'; ...
    % --- Options for lesion extent
    'use_ND_info', 0 ; ... % set to 1 to mark N versus X
    'swapJabberandEaglet',0; ...
    'all_slices_interpolated', 1 ; ...
    'area_filter_pct', 0.7 ; ... % in correlation plot, show only rats with greater than this % coverage
    'inroiset',{}; ... % way to force your own roi set
    'pool_hems', 0 ; ... % set to 1 to combine data across hemispheres
    'markratnames', 1 ; ... % set to 0 to prevent rat identifiers from being put on the correlation graphs
    % --- Options for impairment measure
    'postpsych', 0 ; ... % use only psych trials from valid psych sessions
    'psychthresh', 1 ; ...
    'ignore_trialtype', 1 ; ...
    'use_metric', 'hitrate'; ... % what measure of impairment to use ; 'hitrate' or 'weber'
    % --- Flags for recursive calls
    'basecase', 1 ; ... % set to 0 to indicate to self that I should return after doing computations and not plot data
    };
parse_knownargs(varargin,pairs);
try
    grp1_clr = group_colour('duration');
catch
    addpath('Analysis/duration_disc/graphicutil/');
    grp1_clr = group_colour('duration');
end;

grp2_clr = group_colour('frequency');

% SWAPPING 2 and 3 has been commented out!

grp1= rat_task_table('','action','get_duration_psych','area_filter',area_filter);
grp2=rat_task_table('','action','get_pitch_psych','area_filter',area_filter);

highimp_freq = {'S047','S044','Bilbo','S028'};

hpc_file='lesion_coverage_calc_Hpc';

if strcmpi(area_filter(1:3),'ACx')
    if strcmpi(area_filter, 'ACx')
        roiset= {'A1','AuD','AuV','TeA'}; %, 'S1','Ect','Prh','Hpc'}; %,'Ect','Prh','S1'};
        atlas_beginpos= -3;           % mm from Bregma
        slice_interval=0.12 ; ... % distance between slices
            swapJabberandEaglet=1;
        use_ND_info=1;
        datafile = interp_datafile;
    elseif strcmpi(area_filter,'ACx2') || strcmpi(area_filter,'ACx3')
        roiset= {'A1','AuD','AuV','TeA'}; %, 'S1','Ect','Prh','Hpc'}; %,'Ect','Prh','S1'};
        atlas_beginpos=-1.65;
        slice_interval=0.12;
        datafile = raw_datafile;
    elseif strcmpi(area_filter,'ACxall')
        graphic=0;
    else
        error('invalid area name');
    end;
else
    roiset={'PrL','IL'}; % ,'Cg','MO','M2'};
    grp1={'Shelob','Wraith','Hudson','Celeborn','Treebeard','Nazgul'};
    grp2={'Shadowfax','Watson','Moria','Evenstar','Sherlock'};
    atlas_beginpos=5.64;
    slice_interval = 0.3; % APPROXIMATE VALUE; unlike ACx, atlas slices for mPFC are not at regular intervals
    datafile = interp_datafile;
end;
allrats = [grp1 grp2];


if ~isempty(inroiset)
    roiset=inroiset;
end;

% LOAD datafiles -------------------------------------------------------

% load file with rat-specific lesion coverage structs
if strcmpi(area_filter,'ACxall')
    minisets={'ACx','ACx2'};
    % these fields may have different ordering depending on subset
    reclist = {'xl','xr','grp1_bothpctcvg','grp2_bothpctcvg', ...
        'totalroisum','rnames','grp1','grp2','qnames'};
    for r=1:length(reclist)
        eval([reclist{r} '=[];']);
    end;
    
    grp1_pctcvg=[];
    grp1_pctcvg.L=[];
    grp1_pctcvg.R=[];
    
    grp2_pctcvg=[];
    grp2_pctcvg.L=[];
    grp2_pctcvg.R=[];
    
    mega_lesioncvg=[];
    ratnetcount=[];
    
    for m=1:length(minisets)
        out=lesion_compare2groups('area_filter',minisets{m},'inroiset', inroiset, ...
            'area_filter_pct',area_filter_pct,'postpsych',postpsych,...
            'use_metric',use_metric,'impair_addfname',impair_addfname,'pool_hems',pool_hems, ...
            'basecase', 0);

        qnew=out.qnames;
        sidx=1;
        if m>1
            qold=qnames(:,m-1);
            if ~cellstr_are_equal(qnew,qold)
                warning('roi names not matching across sets');
                oldxl = out.xl;
                oldxr = out.xr;
                %             oldg1=out.grp1_ptct;
                %             oldg2=out.grp2_ptct;

                reordxl = NaN(size(oldxl));
                reordxr = NaN(size(oldxr));

                %             reordg1.L = NaN(size(oldg1.L));
                %             reordg1.R = NaN(size(oldg1.R));
                %
                %             reordg2.L = NaN(size(oldg2.L));
                %             reordg2.R = NaN(size(oldg2.R));
                %
                for q=1:length(qold)
                    idx=find(strcmpi(qnew,qold{q}));
                    fprintf(1,'%s: %i to %i\n', qold{q}, idx, q);
                    reordxl(q,:)=oldxl(idx,:);
                    reordxr(q,:)=oldxr(idx,:);

                    %                 reordg1.L(q,:)=oldg1.L(idx,:);
                    %                 reordg1.R(q,:)=oldg1.R(idx,:);
                    %
                    %                 reordg2.L(q,:)=oldg2.L(idx,:);
                    %                 reordg2.R(q,:)=oldg2.R(idx,:);
                end;

                xl = horzcat(xl,reordxl);
                xr = horzcat(xr,reordxr);
                %             grp1_ptct.L = horzcat(grp1_ptct.L,reordg1.L);
                %             grp1_ptct.R = horzcat(grp1_ptct.R,reordg1.R);
                %
                %             grp2_ptct.L = horzcat(grp2_ptct.L,reordg2.L);
                %             grp2_ptct.R = horzcat(grp2_ptct.R, reordg2.R);

                sidx=3;
            end;
        end;

        2;

        for r=sidx:length(reclist)
            try
                eval([reclist{r} '=horzcat(' reclist{r} ', out.' reclist{r} ');']);
            catch
                error('died');
            end;
        end;
        
        grp1_pctcvg.L = vertcat(grp1_pctcvg.L, out.grp1_pctcvg.L)
        grp1_pctcvg.R = vertcat(grp1_pctcvg.R, out.grp1_pctcvg.R)
         grp2_pctcvg.L = vertcat(grp2_pctcvg.L, out.grp2_pctcvg.L)
        grp2_pctcvg.R = vertcat(grp2_pctcvg.R, out.grp2_pctcvg.R)
        
        
        fnames = fieldnames(out.mega_lesioncvg);
        for f=1:length(fnames)
            mega_lesioncvg=setfield(mega_lesioncvg, fnames{f}, eval(['out.mega_lesioncvg.' fnames{f}]));
            ratnetcount=setfield(ratnetcount, fnames{f}, eval(['out.ratnetcount.' fnames{f}]));

        end;
        2;
        
    end;

    % at this point, we have for all ACx rounds, the following datafields:
    % xl, xr, rnames, grp1, grp2, qnames grp1_bothpctcvg, grp1_pctcvg.L/R
    % mega_lesioncvg
    % same for group 2

    2;

else
    global Solo_datadir;
    histodir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Histo' filesep area_filter filesep];
    infile = [histodir datafile '.mat'];
    load(infile);

    if strcmpi(area_filter,'ACx') && swapJabberandEaglet > 0
        Jabber_lesioncvg=Eaglet_lesioncvg;
    end;

    if ismember('Hpc',roiset)
        allrats=[grp1 grp2];
        for r=1:length(allrats),
            eval([allrats{r} '_lesioncvgOLD = ' allrats{r} '_lesioncvg;']);
            str=['clear ' allrats{r} '_lesioncvg;'];
            eval(str);
        end;
        if exist('Eaglet_lesioncvg', 'var')
            clear Eaglet_lesioncvg;
        end;
        infile2 = [histodir datafile_hpc '.mat'];
        load(infile2);

        if exist('Eaglet_lesioncvg','var'), Jabber_lesioncvg=Eaglet_lesioncvg; end;
        for r=1:length(allrats),
            eval([allrats{r} '_lesioncvgOLD.Hpc=' allrats{r} '_lesioncvg.Hpc;']);
            eval([allrats{r} '_lesioncvg = ' allrats{r} '_lesioncvgOLD;']);
            eval(['clear ' allrats{r} '_lesioncvgOLD;']);
        end;
        if exist('Jabber_lesioncvg','var'), Eaglet_lesioncvg=Jabber_lesioncvg; end;
    end;

    % >> Lory_lesioncvg.AuD
    %
    % ans =
    %
    %      pctcvg__L: [1x33 double]
    %      pctcvg__R: [1x33 double]
    %      cvgpts__L: [1x33 double]
    %      cvgpts__R: [1x33 double]
    %     areapts__L: [1x33 double]
    %     areapts__R: [1x33 double]


    % load and store ND-versus-X data
    % now load file which distinguishes ND (no data) from X (no lesion)
    if use_ND_info > 0
        infile = [histodir 'scoring' filesep scoring_file];
        load(infile);

        % variables of interest are only ACx_NXmarked__LEFT and
        % ACx_NXmarked__RIGHT. Delete all others
        clear ACx_lesionyesno__LEFT ACx_lesionyesno__RIGHT ACx_task PFC_lesion_yesno PFC_task ACx_lesion_coverage_scriptgen;
        NXmarked__L = 0; % convert to struct
        NXmarked__R = 0;

        for k = 1:2:length(ACx_NXmarked__LEFT)
            currat = ACx_NXmarked__LEFT{k};curr = ACx_NXmarked__LEFT{k+1};

            tmpcurr = curr;tmpcurr(2) = curr(3);tmpcurr(3) = curr(2);
            curr = tmpcurr;

            eval(['NXmarked__L.' currat ' = curr;']);

            currat = ACx_NXmarked__RIGHT{k};
            curr = ACx_NXmarked__RIGHT{k+1};
            % tmpcurr = curr;tmpcurr(2) = curr(3);tmpcurr(3) = curr(2);
            curr = tmpcurr;

            eval(['NXmarked__R.' currat ' = curr;']);
        end;
    else
        for r=1:length(allrats)
            eval(['NXmarked__L.' allrats{r} '=[];']);
            eval(['NXmarked__R.' allrats{r} '=[];']);
        end;
    end;
    % Collect total number of points in ROI -----------------------
    if swapJabberandEaglet>0, Jabber_lesioncvg = Eaglet_lesioncvg;end;
    rand('twister',sum(100*clock));
    r = 1 + (length(allrats)-1).*rand(1,1);
    out = sub__compute_roi_pts(eval([allrats{round(r)} '_lesioncvg']), roiset);

    totalroisum = out{1};
    roinet = out{2}; % roinet.AuD = sum of points across all slices
    areacount = out{3}; % areacount.AuD = point count at each slice
    roiexists = out{4}; % roiexists.AuD = binary [1 - exists, 0 - does not]

    % Buffer lesion data into a super struct -------------------------------------

    mega_lesioncvg = struct;

    for m = 1:length(roiset)
        roi = roiset{m};
        for r = 1:length(allrats)
            ratname = allrats{r};
            if strcmpi(ratname,'Jabber'), ratname = 'Eaglet'; % Jabber and Eaglet's records got mixed up so now histology just calls him Eaglet
            end;

            mystruct = eval([ratname '_lesioncvg.' roi ';']);
            % Left hem -------------------------
            lft = mystruct.cvgpts__L;
            tmp = eval(['NXmarked__L.' ratname ';']); % incorporate knowledge of ND or X
            lft = sub__treatX(lft, tmp, all_slices_interpolated); lft(eval(['roiexists.' roi]) == 0) = NaN;
            mystruct.cvgpts__L = lft;

            % Right hem -------------------------
            rt = mystruct.cvgpts__R;
            tmp = eval(['NXmarked__R.' ratname ';']);%incorporate knowledge of ND or X
            rt = sub__treatX(rt, tmp, all_slices_interpolated); rt(eval(['roiexists.' roi]) == 0) = NaN;
            mystruct.cvgpts__R = rt;

            eval([ratname '_lesioncvg.' roi ' = mystruct;']);
            eval(['mega_lesioncvg.' ratname ' = ' ratname '_lesioncvg;']); rt(eval(['roiexists.' roi]) == 0) = NaN;
            mystruct.cvgpts__R = rt;
        end;
    end;

    % Now group the groups' data for these ROI --------------------
    out = sub__group_roi_data(mega_lesioncvg, grp1, grp2, totalroisum, ...
        all_slices_interpolated, ...
        NXmarked__L, NXmarked__R, roiset, roiexists);
    grp1_ptct = out{1};
    grp2_ptct = out{2};
    ratsum = out{3};
    ratnetcount = out{4};


    %--------------------------------------------------------------------------
    % Start the analysis
    rnames = fieldnames(ratnetcount);
    qnames = 0;

    maxslices= 47;
    mm_interval = ceil(1 / slice_interval); % how many in a group?
    numgrps = ceil(maxslices/mm_interval);
    % make a matrix of (rat x roi x pct)
    xlbls = {}; % ratname
    ylbls = {}; % roi


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

            curroi = eval(['curr.' qnames{q} ';']); % ratnetcount.rnames{r}.qnames{q} = Sum total points for this ROI for this rat
            rn = eval(['roinet.' qnames{q} ';']);   % ROI size (all slices summed)
            areact = eval(['areacount.' qnames{q} ';']); % ROI size (slicewise)

            ylbls{end+1} = qnames{q};
            lmatrix(q,r) = (curroi.L / rn)*100;
            rmatrix(q,r) = (curroi.R / rn)*100;
            %                 fprintf(1,'(%i,%i)\n\t', q,r);
            for g = 1:numgrps
                sidx = (mm_interval* (g-1))+1; eidx = min(mm_interval*g, length(areact));
                %                     fprintf(1,'%i to %i, ', sidx, eidx);

                tmp = lgrped{g}; tmp(q,r) = nansum(cvgptsL(sidx:eidx))/nansum(areact(sidx:eidx));
         fprintf(1,'%s: Group %i\n', qnames{q}, g); 
                lgrped{g} = tmp

                tmp = rgrped{g}; tmp(q,r) = nansum(cvgptsR(sidx:eidx))/nansum(areact(sidx:eidx));
                rgrped{g} = tmp
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

    % x will be A-by-R matrix.
    % where x(a,r) = coverage in ROI a for rat r
    xl = lmatrix; %reshape(ldata, length(rnames), length(qnames))';
    xr = rmatrix;%reshape(rdata, length(rnames), length(qnames))';
end;

if basecase == 0 % recursive call; simply assign fields and getouttahere.
    viewopt = 8;
end;

% ---------------
% viewopt 1 -3d plot
% ---------------
if viewopt == 1
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
elseif viewopt == 2
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
        set(gca,'XLim', [0 cols(xr)+1], 'XTick', 1:cols(xr), 'XTickLabel', abbrev_rnames,...
            'YLim',[0 100],'YTick', 0:25:100);
        title(sprintf('%s % Coverage', qnames{q})); axes__format(gca);
        posx = posx+ wd+ 20;
        if posx > 1000, posx = 200; posy = posy+ht+50; end;
    end;
    % -----
    % bargraph for each group, which each bar showing range of coverage for a given ROI
    % -----
elseif viewopt == 3

    isdur = zeros(size(rnames));
    isbad = NaN(size(highimp_freq)); ictr=1;
    freqsofar=0;
    for r=1:length(rnames),
        if ismember(rnames{r}, grp1), isdur(r) = 1;
        else freqsofar = freqsofar+1; end;
        if ismember(rnames{r}, highimp_freq), isbad(ictr)=freqsofar; ictr=ictr+1; end;
    end;

    if pool_hems > 0
        xboth = NaN(size(xl));
        xboth = (xl + xr)/2;
        hset = {'both'}; hemname = {'Both hems'}; hempos=[500];
    else
        hset = {'l','r'}; hemname ={'LEFT', 'RIGHT'}; hempos = [500 200];
    end;
    for h = 1:length(hset)
        % xl - rows are ROIs; cols are rat totals.
        dset = {}; % data to send to makebargroups
        for q = 1:length(qnames) % go down each column of xl and xr
            dset{q,1} = eval(['x' hset{h} '(q, isdur == 1)']);
            dset{q,2} = eval(['x' hset{h} '(q, isdur == 0)']);
        end;

        [x mn sems]=makebargroups(dset, [grp1_clr; grp2_clr],'errtype','std');
        dlite = group_colour('durlite');
        flite=group_colour('freqlite'); msize=20;
        graylite=[1 1 1] * 0.5

        hold on;
        for xlist=1:rows(x)
            if xlist == 3
                2;
            end;
            curr=dset(xlist,:);
            plot(ones(size(curr{1}))*x(xlist,1), curr{1}, '.b', 'Color', graylite,'MarkerSize',msize);
            plot(ones(size(curr{2}))*x(xlist,2), curr{2}, '.b','Color',graylite,'MarkerSize',msize);

            tmp=curr{2};
            plot(ones(size(isbad))*x(xlist,2),tmp(isbad), '.r', 'Color','r', 'LineWidth',1,'MarkerSize',msize);
            
        end;

        xmax=x(end,end)+0.5;
        xl=[-0.5 xmax+0.5];
        line(xl, [50 50], 'LineStyle', ':','Color',[1 1 1]*0.5,'LineWidth',2);

        set(gca,'XTick', 1:4:xmax, 'XTickLabel', qnames,'XLim',xl,'YLim',[0 100], 'YTick',0:20:100);
        title([area_filter ':' hemname{h}],'Color','k');
        axes__format(gca);
        ylabel('% Coverage');
        xlabel('ROI');
        set(gcf,'Position',[300 hempos(h) 850 240],'Toolbar','none','Menubar','figure','Tag', 'bar_pctcvg');
    end;
    % ----------------------------
    % bargraph for each group, which each bar showing range of coverage for a given ROI in a rostrocaudal range
    % ----------------------------
elseif viewopt == 4
    isdur = zeros(size(rnames));
    for r=1:length(rnames), if ismember(rnames{r}, grp1), isdur(r) = 1; end;end;

    hset = {'l','r'}; hemname ={'LEFT', 'RIGHT'}; hempos = [500 200];
    for h = 1:2

        curr = eval([hset{h} 'grped;']);

        % left hem first
        figure; set(gcf,'Position',[100 hempos(h) 200*length(qnames) 240],'Toolbar','none','Menubar','figure','Tag', 'bar_pctcvg');
        axes('Position', [0.03 0.1 0.95 0.78]);
        xmax = ((3*length(qnames)*numgrps)-1)+1;
        line([0 xmax], [50 50], 'LineStyle', ':','Color',[1 1 1]*0.5,'LineWidth',2);hold on;
        line([0 xmax], [75 75], 'LineStyle', ':','Color',[0.5 1 0.5]*0.5,'LineWidth',2);

        currx = 1;
        xtk = [];

        for q = 1:length(qnames) % go down each column of xl and xr
            spos = currx;
            for g=1:numgrps
                tmp = curr{g};
                arr = tmp(q, isdur == 1)*100;

                curry = mean(arr);    sem = std(arr) / sqrt(length(arr));                         g1 = curry;
                patch([currx-0.5 currx-0.5 currx+0.5 currx+0.5], ...
                    [0 curry curry 0], ...
                    grp1_clr,'EdgeColor','none'); hold on;
                line([currx currx], [curry-sem curry+sem],'Color','k');

                arr = tmp(q, isdur == 0)*100;
                curry = mean(arr);    sd = std(arr) ; g2 = curry;
                currx = currx+1;

                patch([currx-0.5 currx-0.5 currx+0.5 currx+0.5], ...
                    [0 curry curry 0], ...
                    grp2_clr,'EdgeColor','none');
                line([currx currx], [curry-sd curry+sd],'Color','k');

                xtk = horzcat(xtk, currx-0.5);

                if abs(g1 - g2) > 25
                    plot(currx-0.5, 105, 'vr','Color','r', 'LineWidth',2,'Marker','v');
                end;

                currx= currx+2;
            end;
            epos = currx;

            text(mean([spos,epos]-4),115,qnames{q},'FontWeight','bold','FontSize',14);
            line([currx-1 currx-1], [0 100], 'Color','k','LineWidth',2);
            currx = currx+1;
        end;
        title(hemname{h});
        set(gca,'Position',[0.05 0.1 0.9 0.8]);
        set(gca,'XTick',xtk, 'XTickLabel', repmat(1:numgrps,1, length(qnames)), 'YTick', 0:25:100);
        set(gca,'XLim',[0 max(xtk)+2],'YLim',[0 120])
        axes__format(gca);
    end;

elseif viewopt ==5 % correlational graph
    % get impairment data
    [diff fname_list grpnames] = surgery_effect_hrate(area_filter,postpsych, 'graphic', 0,'psychhitrate',1);

    %  surgery_effect_hrate('ACx','both_groups_allhrate');
    %      [resid fname_list grpnames] = surgery_effect_residuals;
    %      diff = resid;

    if rows(diff{1}) > 1, diff{1} = diff{1}'; end; if rows(diff{2})>1, diff{2} = diff{2}'; end;
    if rows(fname_list{1}) > 1, fname_list{1} = fname_list{1}'; end; if rows(fname_list{2}) > 1, fname_list{2} = fname_list{2}'; end;

    diffcat = [diff{1} diff{2}];
    fnamecat= [fname_list{1} fname_list{2}];
    ydata = sub__sortval(diffcat, fnamecat, allrats,swapJabberandEaglet);

    isdur = zeros(size(rnames));
    for r=1:length(rnames), if ismember(rnames{r}, grp1), isdur(r) = 1; end;
    end;

    hset = {'l','r'}; hemname ={'LEFT', 'RIGHT'}; hempos = [500 200];
    xpos = 20; ht = 175; wd = 650;
    p_set = [];

    impair_cvg_pairs = cell(length(qnames), 1);
    % each entry is for one ROI-hem combination.
    % Each value is a R-by-2 array, rows are rats, cols are
    % (impairment_measure, coverage_measure)

    durcoeff = 0; %key: ROI, value: corrcoef.
    freqcoeff = 0;
    coeffsig = 0; %key ROI/hem, value: [p sig]

    ctr  = 1;
    for q = 1:length(qnames) % go down each column of xl and xr
        for h = 1:2
            figure; set(gcf,'Position',[xpos hempos(h) wd ht],'Toolbar','none','Menubar','figure');
            xdata_dur = eval(['x' hset{h} '(q, isdur == 1)']); ydata_dur = ydata(isdur == 1);
            xdata_freq =  eval(['x' hset{h} '(q, isdur == 0)']); ydata_freq = ydata(isdur==0);

            if rows(xdata_dur)>1, xdata_dur=xdata_dur';end;
            if rows(ydata_dur)>1, ydata_dur=ydata_dur';end;
            if rows(xdata_freq)>1, xdata_freq=xdata_freq';end;
            if rows(ydata_freq)>1, ydata_freq=ydata_freq';end;

            dcorr=corrcoef(xdata_dur, ydata_dur);
            fcorr=corrcoef(xdata_freq, ydata_freq);
            eval(['durcoeff.' qnames{q} hset{h} '= dcorr(1,2)']);
            eval(['freqcoeff.' qnames{q} hset{h} '= fcorr(1,2)' ]);
            [minip minisig] = sub__sigtestonepair([xdata_dur' ydata_dur'], [xdata_freq' ydata_freq'], length(qnames)*2);
            eval(['coeffsig.' qnames{q} hset{h} '= [minip minisig]']);

            xdata = horzcat(xdata_dur, xdata_freq);

            p = corrcoef(xdata,ydata);
            p_set = horzcat(p_set, p(1,2));
            if cols(xdata) > 1, xdata = xdata'; end; if cols(ydata) > 1, ydata =ydata'; end;
            impair_cvg_pairs{ctr} = [ydata xdata]; ctr = ctr+1;

            lwdth =4;
            line([-10 100],[0 0],'LineStyle',':','Color',[1 1 1]*0.3,'LineWidth', lwdth); hold on;
            line([50 50], [-0.15 +0.1],'LineStyle',':','Color',[1 1 1]*0.3,'LineWidth',lwdth);


            plot(xdata(isdur==1), ydata(isdur==1), '.r','MarkerSize',20,'Color',grp1_clr);
            plot(xdata(isdur==0), ydata(isdur==0), '.r','MarkerSize',20,'Color',grp2_clr);

            if markratnames >0
                for k = 1:length(allrats)
                    text(xdata(k)-1, ydata(k)+0.02, upper(allrats{k}(1:2)),'FontWeight','bold');
                end;
            end;

            text(85, 0.08, sprintf('r= %1.2f', p(1,2)),'FontWeight','bold','FontSize',18);
            xlabel('% coverage');
            %            set(gca,'XLim',[-1 100]);
            set(gca,'YLim',[-0.15 +0.1],'XTick',0:20:100, ...
                'YTick',-0.15:0.05:0.1, 'YTickLabel', -15:5:10 );
            ylabel({'POST-PRE (%)', '(Lower is worse)'});

            %             set(gca,'XLim',[-1 100],'YLim',[-0.15 +0.15],'XTick',0:20:100);
            %             ylabel({'Residual (higher is worse)'});

            title([qnames{q} ': ' hemname{h}]);
            axes__format(gca);
            set(gca,'Position',[0.12 0.23 0.83 0.65],'FontSize', 14);
            set(get(gca,'XLabel'), 'FontSize',14);
            set(get(gca,'YLabel'), 'FontSize',14);
            set(get(gca,'Title'), 'FontSize',14);

            uicontrol('Tag', 'figname', 'Style','text', 'String', sprintf('impair_correl_%s_%s',qnames{q},hemname{h}), 'Visible','off');
        end;
        xpos = xpos+wd;
    end;

    % how significant is this correlation?
    bigun = max(abs(p_set));
    [p sig] = sub__sigtest(impair_cvg_pairs, bigun);
    fprintf(1,'%s\n\tHighest correlation found = %1.2f (p=%1.3f, sig=%i)\n', mfilename, bigun, p, sig);

elseif viewopt == 6 % viewpoint ==6

    if strcmpi(area_filter,'ACxall')
        grp1_pct = grp1_pctcvg;
        grp2_pct = grp2_pctcvg;

        hemless_grp1 = grp1_bothpctcvg;
        hemless_grp2 = grp2_bothpctcvg;

        roiset = qnames;

        grp1_clr = group_colour('duration');
        grp2_clr = group_colour('frequency');


        isdur = zeros(size(rnames));
        isbad = NaN(size(highimp_freq)); ictr=1;
        freqsofar=0;
        for r=1:length(rnames),
            if ismember(rnames{r}, grp1), isdur(r) = 1;
            else freqsofar = freqsofar+1; end;
            if ismember(rnames{r}, highimp_freq), isbad(ictr)=freqsofar; ictr=ictr+1; end;
        end;

    else

        grp1_pct = [];
        grp1_pct.L = grp1_ptct.L / totalroisum.L;
        grp1_pct.R = grp1_ptct.R / totalroisum.R;

        grp2_pct = [];
        if ~isempty(grp2_ptct.L)
            grp2_pct.L = grp2_ptct.L / totalroisum.L;
            grp2_pct.R = grp2_ptct.R / totalroisum.R;

            hemless_grp1 = (grp1_ptct.L + grp1_ptct.R) / (2*totalroisum.L);
            if isempty(grp2_ptct.L)
                hemless_grp2=[];
            else
                hemless_grp2 = (grp2_ptct.L + grp2_ptct.R) / (2*totalroisum.L);
            end;

        end;



        fprintf(1,'Group 1:-----\n');
        for g=1:length(grp1)
            fprintf(1,'%s=%2.1f\n', grp1{g}, hemless_grp1(g)*100);
        end;
        if ~isempty(grp2_ptct.L)
            fprintf(1,'Group 2:-----\n');
            for g=1:length(grp2)
                fprintf(1,'%s = %2.1f\n', grp2{g}, hemless_grp2(g)*100);
            end;
        end;

    end;
    
    if pool_hems > 0

    makebargraph(hemless_grp1, hemless_grp2, ...
        'g1_clr', grp1_clr,'g2_clr',grp2_clr, ...
        'figtitle', 'Overall percent coverage', ...
        'g1_lbl', 'Timing', 'g2_lbl', 'Frequency');
    line([-1 3],[0.5 0.5], 'LineStyle',':','Color',[1 1 1]*0.3,'LineWidth',2)
    set(gca,'YTick', 0:0.1:1, 'YTickLabel',[0:0.1:1]*100,'YLim',[0 1]);
    ylabel('% coverage');
    %    title('ACx2 - excluding S025 from duration group');
    str='(';
    for r=1:length(roiset)
        str=[str roiset{r} ','];
    end;
    str=[str(1:end-1) ')'];
    title(sprintf('%s: %% cvg %s', area_filter, str));

    xt = get(gca,'XTick');
    gr =[1 1 1] * 0.3;
    msize = 25;
    plot(ones(size(hemless_grp1))*xt(1), hemless_grp1, '.b', 'Color',group_colour('durlite'), 'MarkerSize', msize);
    plot(ones(size(hemless_grp2))*xt(2), hemless_grp2, '.b', 'Color',group_colour('freqlite'), 'MarkerSize', msize);
    if exist('isbad','var'),
    plot(ones(size(isbad))*xt(2), hemless_grp2(isbad), '.r', 'Color','r', 'LineWidth',1.5, 'MarkerSize', msize);    
    end;

    axes__format(gca);

    % correlate impairment of only those rats who are at least 70% covered
    grp1_filtered = find(hemless_grp1 >= area_filter_pct);
    grp2_filtered = find(hemless_grp2 >= area_filter_pct);
    
    else
        hemlist = {'L','R'}; 
        for h=1:length(hemlist)
            g1 = eval(['grp1_pct.', hemlist{h} ';'])
            g2 = eval(['grp2_pct.', hemlist{h} ';'])
                
            makebargraph(g1,g2, ...
        'g1_clr', grp1_clr,'g2_clr',grp2_clr, ...
        'figtitle', 'Overall percent coverage', ...
        'g1_lbl', 'Timing', 'g2_lbl', 'Frequency');
    line([-1 3],[0.5 0.5], 'LineStyle',':','Color',[1 1 1]*0.3,'LineWidth',2)
    set(gca,'YTick', 0:0.1:1, 'YTickLabel',[0:0.1:1]*100,'YLim',[0 1]);
    ylabel('% coverage');
    %    title('ACx2 - excluding S025 from duration group');
    str='(';
    for r=1:length(roiset)
        str=[str roiset{r} ','];
    end;
    str=[str(1:end-1) ')'];
    title(sprintf('%s: %% cvg %s (%s)', area_filter, str, hemlist{h}));

    xt = get(gca,'XTick');
    gr =[1 1 1] * 0.3;
    msize = 25;
    plot(ones(size(g1))*xt(1), g1, '.b', 'Color',group_colour('durlite'), 'MarkerSize', msize);
    plot(ones(size(g2))*xt(2), g2, '.b', 'Color',group_colour('freqlite'), 'MarkerSize', msize);
    if exist('isbad','var'),
    plot(ones(size(isbad))*xt(2), g2(isbad), '.r', 'Color','r', 'LineWidth',1.5, 'MarkerSize', msize);    
    end;

    axes__format(gca);
 
        end;
        
    end;
    

    return;

    % get impairment data
    switch use_metric
        case 'hitrate'
            [diff fname_list grpnames] = surgery_effect_hrate(area_filter,postpsych, 'psychhitrate',1, 'graphic', 0);
            ylbl = '(POST-PRE) Hit rate';
        case 'weber'
            [diff fname_list grpnames] = webers_seh_format(area_filter, postpsych, 1, 1);
            ylbl='(POST-PRE) Weber';
        case 'impair'
            global Solo_datadir;
            outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep 'impair_metric' filesep];

            fname = [outdir area_filter '_impair_' impair_addfname '_calc7'];
            load(fname);
            diff=diff_list;
            ylbl='IMPAIR';
        otherwise
            error('invalid impairment metric');
    end;

    %keep only those meeting criteria
    diff_grp1 = [];
    grp1names = grp1(grp1_filtered);
    tmp=fname_list{1};tmpdiff = diff{1};
    %    for g=1:length(tmp)
    %        if ismember(tmp{g}, grp1names)
    %            diff_grp1 = horzcat(diff_grp1, tmpdiff(g));
    %        end;
    %    end;
    %
    grp2names = grp2(grp2_filtered);
    %    tmp=fname_list{2};tmpdiff=diff{2};
    %    diff_grp2=[];
    %    for g=1:length(tmp)
    %        if ismember(tmp{g}, grp2names)
    %             diff_grp2=horzcat(diff_grp2, tmpdiff(g));
    %        end;
    %    end;

    diff_grp1=diff{1};
    diff_grp2=diff{2};

    2;

    xdata_dur = hemless_grp1(grp1_filtered)*100;
    xdata_freq= hemless_grp2(grp2_filtered)*100;
    isdur = ones(length(xdata_dur),1);
    ydata_dur = diff_grp1;
    ydata_freq= diff_grp2;
    isdur =vertcat(isdur, zeros(length(xdata_freq),1));

    allrats = [grp1names grp2names];

    % --- plotting correlational graph
    figure;

    if rows(xdata_dur)>1, xdata_dur=xdata_dur';end;
    if rows(ydata_dur)>1, ydata_dur=ydata_dur';end;
    if rows(xdata_freq)>1, xdata_freq=xdata_freq';end;

    if rows(ydata_freq)>1, ydata_freq=ydata_freq';end;
    %             [minip minisig] = sub__sigtestonepair([xdata_dur' ydata_dur'], [xdata_freq' ydata_freq'], length(qnames)*2);
    %             eval(['coeffsig.' qnames{q} hset{h} '= [minip minisig]']);

    xdata = horzcat(xdata_dur, xdata_freq);
    ydata = horzcat(ydata_dur, ydata_freq);

    p = corrcoef(xdata,ydata);
    if cols(xdata) > 1, xdata = xdata'; end; if cols(ydata) > 1, ydata =ydata'; end;

    lwdth =4;
    if strcmpi(use_metric,'hitrate')
        yl=[-0.3 .1];
    else
        yl=[-0.3 1];
    end;
    line([-10 100],[0 0],'LineStyle',':','Color',[1 1 1]*0.3,'LineWidth', lwdth); hold on;
    line([50 50], yl,'LineStyle',':','Color',[1 1 1]*0.3,'LineWidth',lwdth);

    plot(xdata(isdur==1), ydata(isdur==1), '.r','MarkerSize',20,'Color',grp1_clr);
    plot(xdata(isdur==0), ydata(isdur==0), '.r','MarkerSize',20,'Color',grp2_clr);

    if strcmpi(area_filter,'ACx2')
        sbst = 3:4
    else
        sbst=1:2;
    end;
    if markratnames > 0
        for k = 1:length(allrats)
            text(xdata(k)*0.95, ydata(k)+0.02, upper(allrats{k}(sbst)),'FontWeight','bold');
        end;
    end;

    text(85, 0.08, sprintf('r= %1.2f', p(1,2)),'FontWeight','bold','FontSize',18);
    xlabel('% coverage');
    %            set(gca,'XLim',[-1 100]);

    if ~isempty(inroiset)
        str='(';
        for k=1:length(inroiset),
            str = [str ',' inroiset{k}];
        end;
        str=[str([1 3:end]) ')'];
    end;

    if strcmpi(use_metric,'hitrate')
        set(gca,'YLim',yl,'XTick',0:20:100, ...
            'YTick',yl(1):0.05:yl(2), 'YTickLabel', (yl(1):0.05:yl(2))*100 );
        ylabel(ylbl);
    else
        set(gca,'YLim',yl,'XTick',0:20:100, ...
            'YTick',-0.2:0.2:yl(2));
        ylabel(ylbl);
    end;

    axes__format(gca);
    set(gca,'XLim',[-3 100]);
    set(gcf,'Position',[360   583   645   275]);

elseif viewopt == 7 %viewopt is 7
    grp1_pct = [];
    grp1_pct.L = grp1_ptct.L / totalroisum.L;
    grp1_pct.R = grp1_ptct.R / totalroisum.R;

    grp2_pct = [];
    if ~isempty(grp2_ptct.L)
        grp2_pct.L = grp2_ptct.L / totalroisum.L;
        grp2_pct.R = grp2_ptct.R / totalroisum.R;
    end;

    if 1
        hemless_grp1 = (grp1_ptct.L + grp1_ptct.R) / (2*totalroisum.L);
        if ~isempty(grp2_ptct.L)
            hemless_grp2 = (grp2_ptct.L + grp2_ptct.R) / (2*totalroisum.L);
        else
            hemless_grp2=[];
        end;
    else
        hemless_grp1 = (grp1_ptct.L) / (1*totalroisum.L);
        if ~isempty(grp2_ptct.L)
            hemless_grp2 = ( grp2_ptct.L) / (1*totalroisum.L);
        else
            hemless_grp2=[];
        end;


    end;

    %     % trendline of coverage for each rat/ROI
    % elseif viewopt == 8
    %
    %     isdur = zeros(size(rnames));
    %     isbad = NaN(size(highimp_freq)); ictr=1;
    %     freqsofar=0;
    %     for r=1:length(rnames),
    %         if ismember(rnames{r}, grp1), isdur(r) = 1;
    %         else freqsofar = freqsofar+1; end;
    %         if ismember(rnames{r}, highimp_freq), isbad(ictr)=freqsofar; ictr=ictr+1; end;
    %     end;
    %
    %     if pool_hems > 0
    %         xboth = NaN(size(xl));
    %         xboth = (xl + xr)/2;
    %         hset = {'both'}; hemname = {'Both hems'}; hempos=[500];
    %     else
    %         hset = {'l','r'}; hemname ={'LEFT', 'RIGHT'}; hempos = [500 200];
    %     end;
    %     for h = 1:length(hset)
    %         % xl - rows are ROIs; cols are rat totals.
    %         dset = {}; % data to send to makebargroups
    %         for q = 1:length(qnames) % go down each column of xl and xr
    %             dset{q,1} = eval(['x' hset{h} '(q, isdur == 1)']);
    %             dset{q,2} = eval(['x' hset{h} '(q, isdur == 0)']);
    %         end;
    %
    %         [x mn sems]=makebargroups(dset, [grp1_clr; grp2_clr],'errtype','std');
    %         dlite = group_colour('durlite');
    %         flite=group_colour('freqlite'); msize=20;
    %         graylite=[1 1 1] * 0.5
    %
    %         hold on;
    %         for xlist=1:rows(x)
    %             if xlist == 3
    %                 2;
    %             end;
    %             curr=dset(xlist,:);
    %             plot(ones(size(curr{1}))*x(xlist,1), curr{1}, '.b', 'Color', graylite,'MarkerSize',msize);
    %             plot(ones(size(curr{2}))*x(xlist,2), curr{2}, '.b','Color',graylite,'MarkerSize',msize);
    %
    %             tmp=curr{2};
    %             plot(ones(size(isbad))*x(xlist,2),tmp(isbad), '.r', 'Color','r', 'LineWidth',1,'MarkerSize',msize);
    %         end;
    %
    %         xmax=x(end,end)+0.5;
    %         xl=[-0.5 xmax+0.5];
    %         line(xl, [50 50], 'LineStyle', ':','Color',[1 1 1]*0.5,'LineWidth',2);
    %
    %         set(gca,'XTick', 1:4:xmax, 'XTickLabel', qnames,'XLim',xl,'YLim',[0 100], 'YTick',0:20:100);
    %         title([area_filter ':' hemname{h}],'Color','k');
    %         axes__format(gca);
    %         ylabel('% Coverage');
    %         xlabel('ROI');
    %         set(gcf,'Position',[300 hempos(h) 850 240],'Toolbar','none','Menubar','figure','Tag', 'bar_pctcvg');
    %     end;


    % get impairment data
    switch use_metric
        case 'hitrate'
            [diff_list fname_list grpnames] = surgery_effect_hrate(area_filter,postpsych, 'psychhitrate',1, 'graphic', 0);
        case 'weber'
            [diff_list fname_list grpnames] = webers_seh_format(area_filter, postpsych,psychthresh, ignore_trialtype);
        case 'impair'
            global Solo_datadir;
            outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep 'impair_metric' filesep];
            if strcmpi(area_filter,'ACx'), pfx='ACxall'; else pfx='mPFC'; end;
            fname = [outdir area_filter '_impair_' impair_addfname '_calc7'];
            load(fname);
            2;
        otherwise
            error('invalid impairment metric');
    end;
    %keep only those meeting criteria

    %    % swap 'em
    %      nd=diff; diff{1} = nd{2}; diff{2}=nd{1}; clear nd;
    %    nf=fname_list; fname_list{1}=nf{2}; fname_list{2} = nf{1}; clear nf;
    %    ng = grpnames; grpnames{1} = ng{2}; grpnames{2}=ng{1}; clear ng;
    %
    out{1} = hemless_grp1;
    out{2} = hemless_grp2;
    out{3} = diff_list{1};
    out{4} = diff_list{2};
    out{5} = fname_list{1};
    out{6} = fname_list{2};

elseif viewopt == 8 % recursive call; send data to caller.
    out=[];

    idx=find(strcmpi(rnames, 'Eaglet'));
    if ~isempty(idx)
        rnames{idx}='Jabber';
    end;

    reclist = {'xl','xr', ... % percent coverage for each ROI for each animal
        'rnames','grp1','grp2', ...% names
        'qnames', ...
        'grp1_bothpctcvg','grp2_bothpctcvg', 'grp1_pctcvg','grp2_pctcvg', ... %
        'totalroisum','mega_lesioncvg','ratnetcount',... % number of points in all ROI (summed) for each slice ...
        };


    % pct coverage over all ROI for one animal
    % grp1_ptct should really be called grp1_count.
    % Each row is for one animal. Each column is sum of points in that
    % slice.
    grp1_bothpctcvg=(sum(grp1_ptct.L,2) + sum(grp1_ptct.R,2))' ./ (2*sum(totalroisum.L));
    grp2_bothpctcvg=(sum(grp2_ptct.L,2) + sum(grp2_ptct.R,2))' ./ (2*sum(totalroisum.L));

    % grp_cvg - has overall percent coverage per animalß
    grp1_pctcvg.L=sum(grp1_ptct.L,2) / sum(totalroisum.L);
    grp1_pctcvg.R=sum(grp1_ptct.R,2) / sum(totalroisum.R);

    grp2_pctcvg.L = sum(grp2_ptct.L,2)/ sum(totalroisum.L);
    grp2_pctcvg.R = sum(grp2_ptct.R,2)/sum(totalroisum.L);


    if rows(rnames) > 1, rnames=rnames'; end;
    for r=1:length(reclist)
        eval(['out.' reclist{r} '=' reclist{r} ';']);
    end;
  
    return;

elseif viewopt == 9 % percent coverage of entire ACx.
    figure;
    grp1_clr=group_colour('duration');
    grp2_clr=group_colour('frequency');
    dlite=group_colour('durlite');
    flite=group_colour('freqlite');


    makebargraph(grp1_bothpctcvg, grp2_bothpctcvg, ...
        'g1_clr', grp1_clr,'g2_clr',grp2_clr, ...
        'g1_lbl', '', 'g2_lbl', '');
    line([-1 3],[0.5 0.5], 'LineStyle',':','Color',[1 1 1]*0.3,'LineWidth',2)
    set(gca,'YTick', 0:0.2:1, 'YTickLabel',0:20:100,'YLim',[0 1.2]);
    ylabel('% coverage');
    %    title('ACx2 - excluiding S025 from duration group');
    roiset=qnames(:,end);
    str='(';
    for r=1:length(roiset)
        str=[str roiset{r} ','];
    end;
    str=[str(1:end-1) ')'];
    title(sprintf('%s: %% cvg %s', area_filter, str));

    xt = get(gca,'XTick');
    gr =[1 1 1] * 0.3;
    msize = 25;

    text(-0.5, 1.1,'Timing','Color',grp1_clr,'FontSize',18,'FontWeight','bold');
    text(-0.5, 1,'Frequency','Color',grp2_clr,'FontSize',18,'FontWeight','bold');
    set(gca,'XTick',[]);

    plot(ones(size(grp1_bothpctcvg))*xt(1), grp1_bothpctcvg, 'ob', 'Color',dlite, 'MarkerSize', msize*0.3,'LineWidth',2);
    plot(ones(size(grp2_bothpctcvg))*xt(2), grp2_bothpctcvg, 'ob', 'Color',flite, 'MarkerSize', msize*0.3,'LineWidth',2);

    axes__format(gca);




else
    error('invalid view option');

end;


% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
% Subroutines

function [out] = sub__compute_roi_pts(mystruct, roiset)
totalroisum = 0; % how many total points were in the ROI? keys: rois, values: # points per slice.
totalroisum.L = [];
totalroisum.R = [];

roinet = 0;
areacount = 0;
roiexists =0;


% buffer total number of points in an ROI
for q = 1:length(roiset)
    roi = roiset{q};
    eval(['curr = mystruct.' roi ';']);

    totalroisum.L = vertcat(totalroisum.L, sub__makerowvec(curr.areapts__L));
    totalroisum.R = vertcat(totalroisum.R, sub__makerowvec(curr.areapts__R));

    tmp = ~isnan(curr.areapts__L);
    eval(['roiexists.' roi ' = tmp;']);


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
    totalroisum.L = sum(totalroisum.L);
    totalroisum.R = sum(totalroisum.R);
end;

out = {};
out{1} = totalroisum;
out{2} = roinet;
out{3} = areacount;
out{4} = roiexists;


function [out] = sub__group_roi_data(mega_lesioncvg, grp1, grp2, totalroisum,...
    all_slices_interpolated, NXmarked__L, NXmarked__R, roiset, roiexists)

% now add points for all rois for each rat
grp1_ptct = 0; grp1_ptct.L = []; grp1_ptct.R = [];
grp2_ptct = 0; grp2_ptct.L =[]; grp2_ptct.R = [];
ipopt = findobj('Tag', 'interp_opt_main'); ipstr = get(ipopt, 'String');

if all_slices_interpolated > 0,ipmethod = 'none';
else ipmethod = ipstr{get(ipopt,'Value')};
end;

ratnetcount = 0; % rat.roi.L = (sum of all points covering an ROI in a given rat hemisphere)

ratset = [ grp1 grp2 ];

for r=1:length(ratset)
    ratname = ratset{r};
    isgrp1 = ismember(ratname, grp1);
    if strcmpi(ratname,'Jabber'), ratname = 'Eaglet'; end;
    eval(['mystruct = mega_lesioncvg.' ratname ';']);

    eval(['ratsum.' ratname ' = 0;']);
    eval(['ratsum.' ratname '.L = [];']);
    eval(['ratsum.' ratname '.R = [];']);

    eval(['ratnetcount.' ratname '=0;']);

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
            if rows(mega_roie)==1, roie=sub__makerowvec(roie);end;
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


        tmpstruct.L = vertcat(tmpstruct.L, sub__makerowvec(roistruct.cvgpts__L));
        tmpstruct.R = vertcat(tmpstruct.R, sub__makerowvec(roistruct.cvgpts__R));

        tmpnet = eval(['ratnetcount.' ratname]);
        eval(['tmpnet.' roi ' = 0;']);
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
    nxl = 'X'; nxr ='X';
    tmpstruct.L = nansum(tmpstruct.L);
    tmpstruct.R = nansum(tmpstruct.R);

    if length(roiset) > 1
        if all_slices_interpolated == 0
            nanspots = strfind(nxl,'N'); tmpstruct.L(nanspots) = NaN;
            tmpstruct.L(isempt) = NaN;
            nanspots = strfind(nxr,'N'); tmpstruct.R(nanspots) = NaN;
            tmpstruct.R(isempt) = NaN;
        end;
    end;

    lvalip = tmpstruct.L;
    rvalip = tmpstruct.R;


    if isgrp1 > 0
        grp1_ptct.L = vertcat(grp1_ptct.L, lvalip);
        grp1_ptct.R = vertcat(grp1_ptct.R, rvalip);
    else
        grp2_ptct.L = vertcat(grp2_ptct.L, lvalip);
        grp2_ptct.R = vertcat(grp2_ptct.R, rvalip);
    end;

    eval(['ratsum.' ratname '= tmpstruct;']);
end;

out = {};
out{1} = grp1_ptct;
out{2} = grp2_ptct;
out{3} = ratsum;
out{4} = ratnetcount;

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

function [sorted] = sub__sortval(d, origfnames, fnames2sortby,swapJandE)

if swapJandE>0
    origfnames{strcmpi(origfnames,'Jabber')} = 'Eaglet';
end;

sorted = NaN(size(d));
oldidx = NaN(size(d)); newidx = NaN(size(d));
for f = 1:length(fnames2sortby)
    idx=find(strcmpi(origfnames, fnames2sortby{f}) > 0);
    sorted(f) = d(idx);
    oldidx(f) = idx; newidx(f) = f;
end;

% set1 is a S-by-2 pair of (cvg, impair), and set2 is a T-by-2 pair of
% (cvg,impair).
% checks to see if corrcoef for two sets is sig different
function [p sig] = sub__sigtestonepair(set1, set2, numtests)

pear1 = corrcoef(set1(:,1), set1(:,2));
pear2 = corrcoef(set2(:,1), set2(:,2));
datadiff = pear1(1,2)-pear2(1,2);

numsims =1000;
s = rows(set1); t=rows(set2);
bigset = vertcat(set1,set2);

diffs = NaN(numsims,1);
for n=1:numsims
    jmbl = randperm(s+t);
    set1idx = jmbl(1:s); set2idx =jmbl(s+1:end);

    simset1 = bigset(set1idx,:); simpear1=corrcoef(simset1(:,1),simset1(:,2));
    simset2 = bigset(set2idx,:); simpear2=corrcoef(simset2(:,1),simset2(:,2));
    diffs(n)=simpear1(1,2)-simpear2(1,2);
end;

alphaval = 0.05/numtests; %Bonferroni
numsmaller = find(abs(diffs)<datadiff);
p = length(numsmaller)/numsims;
if p < alphaval, sig=1; else sig=0;end;



% each entry is for one ROI-hem combination.
% Each value is a R-by-2 array, rows are rats, cols are
% (impairment_measure, coverage_measure)
function [p sig] = sub__sigtest(impair_cvg_pairs, bigun)

alpha_val = 0.05;
numSims = 1000;
xceed_ct = 0; % tracks how many times a correlation this big has been obtained through all simulations
mega_p_set = NaN(numSims * length(impair_cvg_pairs), 1);
maxp_set = NaN(numSims, 1);
l = length(impair_cvg_pairs);
for s = 1:numSims
    % permute each one
    len = rows(impair_cvg_pairs{1});
    p_set = NaN(size(impair_cvg_pairs));
    for n = 1:length(impair_cvg_pairs)
        tmp = impair_cvg_pairs{n};
        permed = [tmp(randperm(len),1) tmp(:,2)];
        p = corrcoef(permed(:,1), permed(:,2));
        p_set(n) = p(1,2);
    end;
    mega_p_set(((s-1)*l)+1 : s*l) = p_set;

    maxp =max(abs(p_set));
    if maxp >= bigun, xceed_ct = xceed_ct+1; end;
    maxp_set(s) = maxp;
end;

figure;
hist(maxp_set, 0:0.1:+1); title('correlation values from significance test');
set(gcf,'Position',[ 22  7 538 208],'Toolbar','none','Menubar','figure');
n= hist(maxp_set, -1:0.1:+1);
line([bigun bigun], [0 max(n)], 'LineWidth',2,'Color','r');

p = xceed_ct/numSims; if p < 0.05, sig = 1; else sig =0; end;

bigger = length(abs(mega_p_set) >= bigun) / numSims;

% --------------------

function [v]= sub__makerowvec(v)
if rows(v) > 1
    v=v';
end;
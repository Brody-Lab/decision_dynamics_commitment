function [diff_list fnames_list group_names] = surgery_effect_hrate(area_filter, postpsych, varargin)
% hitrate before/after ibo lesion of a given group
% set 'psychhitrate' flag to determine whether hit rate is overall (0) or
% only for psychometric trials (1)

% Use cases
% 1. surgery_effect_hrate('ACx',1,'psychhitrate',1)
% gets psychometric hit rate for sessions with sufficient psychometric
% trials
% 2. surgery_effect_hrate('ACx',0,'psychhitrate',0)
% gets overall hit rate for all sessions (# sessions s defined in call to
% loadpsychinfo)


durclr=group_colour('duration');
freqclr=group_colour('frequency');

if ~isstr(postpsych)

    pairs = { ...
        'pool_all_trials',  1; ...     
        'single_group', 'pitch'; ... % if doing one group, which one?
        'graphic', 1 ; ... % draw plots?
        'sigtest', 1 ; ... % is freq different from dur?
        'psychhitrate',1 ; ...
        };
    parse_knownargs(varargin,pairs);
    
    FLG__USE_SPECIAL_FILE=0;
 
    if postpsych == 0     
        fpfx = 'hrateall_beforeafter_';
    else
        fpfx='hratepsych_beforeafter_';     
    end;
    
    if psychhitrate > 0
        fpfx2 = 'psychonly_';
    else
        fpfx2 = 'alltrials_';
    end;
    
    if FLG__USE_SPECIAL_FILE >0
        warning('Make sure you want to use the FIRST3PSYCH file');
         action='postpsych__USESPECIALFILE';
    else
       
        action='postpsych__REGULAR';
    end;
    
    if strcmpi(area_filter,'ACx')
        ACxround1=1;
    else
        ACxround1=0;
    end;

    global Solo_datadir;
    outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep];
    fname = [fpfx fpfx2 area_filter];
    infile=[outdir fname];
    warning off MATLAB:singularMatrix;

else % plotnsig
    if ~strcmpi(postpsych,'plotnsig')
        error('if second arg is string, should be ''plotnsig''');
    end;
    action='plotnsig';
    b=varargin{1};
    a=varargin{2};
    bf=varargin{3};
    af=varargin{4};
    fname=varargin{5};
    
    2;
end;

alphaval=0.05/2;
diff_list = {}; fnames_list = {};


switch action
    case 'postpsych__REGULAR'
        diff_list = cell(2,1);
        fnames_list = cell(2,1);
        group_names= {'duration','frequency'};
        try
            load(infile);
        catch         
            freqset = rat_task_table('','action','get_pitch_psych','area_filter',area_filter);
            [hfr hfraw] = sub__gethrates(freqset, ACxround1,postpsych,psychhitrate);

            durset = rat_task_table('','action','get_duration_psych','area_filter',area_filter);
            [hdur hdraw] = sub__gethrates(durset,ACxround1,postpsych,psychhitrate);

            save(infile,'hdur','hfr','hdraw','hfraw');
        end;

        tmpd=NaN(rows(hdur),1); tmpf=cell(rows(hdur),1);
        f=fieldnames(hdur);
        for k = 1:length(f)
            tmp=eval(['hdur.' f{k} ';']);
            tmpd(k)=tmp(:,2)-tmp(:,1);
            tmpf{k}=f{k};
        end;
        diff_list{1}=tmpd;
        fnames_list{1} = tmpf;

        tmpd=NaN(rows(hfr),1); tmpf=cell(rows(hfr),1);
        f=fieldnames(hfr);
        for k = 1:length(f)
            tmp=eval(['hfr.' f{k} ';']);
            tmpd(k)=tmp(:,2)-tmp(:,1);
            tmpf{k}=f{k};
        end;
        diff_list{2}=tmpd;
        fnames_list{2}=tmpf;

        if graphic>0
            surgery_effect_hrate(area_filter,'plotnsig', hdraw(:,1),hdraw(:,2), hfraw(:,1), hfraw(:,2),fname);
        end;


    case 'postpsych__USESPECIALFILE'
        if postpsych==0, error('the other switch should be used for this option');end;
        diff_list = cell(2,1);
        fname_list = cell(2,1);
        group_names= {'duration','frequency'};

        try
            load(infile);
        catch

            infile = ['duration_psych_' area_filter '_psychdata_LAST7FIRST3PSYCH.mat'];
            clr = group_colour('durlite');
            [b a fnames]=sub__psychhitrate(infile,clr, pool_all_trials, postpsych,0, 0); % duration

            s=find(strcmpi(fnames,'S041'));
            if ~isempty(s)
                nf={};
                nb=[];
                na=[];
                for k=1:s-1
                    nb(k)=b(k);
                    na(k)=a(k);
                    nf{k} = fnames{k};
                end;

                for k=s+1:length(fnames)
                    nb(k)=b(k);
                    na(k)=a(k);
                    nf{k} = fnames{k};
                end;

                b=nb; a=na; fnames=nf;
            end;

            diff_list{1} = a-b;
            fnames_list{1} = fnames;

            siggraphic =0;

            infile = ['pitch_psych_' area_filter '_psychdata_LAST7FIRST3PSYCH.mat'];
            clr = group_colour('freqlite');
            [bf af fnames]=sub__psychhitrate(infile,clr, pool_all_trials, postpsych, 0, 0); % frequency

            diff_list{2} = af-bf;
            fnames_list{2} = fnames;
            %         joinwithsigline(gca,1,2,0.035,0.05);
            %      %   text (1.3,0.05,sprintf('p=%1.3f',p),'FontSize', 14);
            %         if p<0.05, plotstar(gca,1.5, 0.055); end;
            %         if p<0.01, plotstar(gca,1.4, 0.055); end;


            save(infile,'diff_list','fnames_list','group_names','a','b','af','bf');
        end;

        if graphic>0
            surgery_effect_hrate(area_filter,'plotnsig',b,a,bf,af,fname);
        end;



    case 'plotnsig'
        figure;

        [sigdur pdur] = permutationtest_diff(a,b, 'typeoftest', 'onetailed_ls0','plotme',0, 0);
        [sigfreq pfreq] = permutationtest_diff(af,bf, 'typeoftest', 'onetailed_ls0','plotme',0,0);

        fprintf(1,'Duration: p-value: %1.3f, sig: %i\n', pdur, sigdur);
        fprintf(1,'Frequency: p-value: %1.3f, sig: %i\n', pfreq, sigfreq);


        durlite=group_colour('durlite');
        freqlite=group_colour('freqlite');
        msize = 28;
        errorbar(1:2, [mean(b), mean(a)], [std(b)/sqrt(length(b)) std(a)/sqrt(length(a))],'.k','Color', durclr,'MarkerSize', msize, 'LineWidth',2); hold on;
        plot(1:2, [mean(b), mean(a)], '-k','Color', durclr,'MarkerSize', msize, 'LineWidth',4);
        for k=1:length(b)
            plot([1 2], [b(k) a(k)],'Color', durlite,'LineWidth',2);
        end;

        errorbar(1:2, [mean(bf), mean(af)], [std(bf)/sqrt(length(bf)) std(af)/sqrt(length(af))], '.k','Color', freqclr,'MarkerSize', msize, 'LineWidth',2);
        plot(1:2, [mean(bf), mean(af)], '-k','Color', freqclr,'MarkerSize', msize, 'LineWidth',4);
        for k=1:length(bf)
            plot([1 2], [bf(k) af(k)],'Color',freqlite,'LineWidth',2);
        end;

        text(1.5, 0.99, 'Timing', 'Color', durclr,'FontSize',14,'FontWeight','bold');
        text(1.5, 0.97, 'Frequency', 'Color', freqclr,'FontSize',14,'FontWeight','bold');

        uicontrol('Tag', 'figname', 'Style','text', 'String', sprintf('%s_prepost',fname), 'Visible','off');
        set(gca,'YLim',[0.45 1],'YTick',0.5:0.1:1, 'YTickLabel', 50:10:100, 'XLim',[0.8 2.2]);
        ylabel('Pooled success rate (%)');
        set(gcf,'Position',[ 560   413   266   471]);
        set(gca,'XTick',[1 2], 'XTickLabel',{'Before','After'});
        title(subuscore(fname));
        axes__format(gca);

        % plot diff_list
        diff_list=cell(2,1);
        diff_list{1} = a-b;
        diff_list{2} = af-bf;
        msize = 20;

        figure;
        line([0 3], [0 0],'LineWidth',2,'LineStyle',':','Color',[1 1 1]*0.7);            hold on;
        plot(ones(size(diff_list{1})), diff_list{1},'.b','Color',durclr,'MarkerSize',msize);
        plot(ones(size(diff_list{2})) * 2, diff_list{2},'.b','Color',freqclr,'MarkerSize',msize);

        ylabel({'After-Before','(%; lower is worse)'});
        set(gca,'XTick', [1 2], 'XLim', [1-0.2 2+0.2], 'XtiCkLabel',{'Timing','Frequency'});
        yl=[-0.5 0.07];
        set(gca,'YLim',yl, 'YTick',yl(1):0.1:yl(2), 'YTickLabel', (yl(1):0.1:yl(2))*100);
        title(subuscore(fname));
        axes__format(gca);
        set(gcf,'Position',[ 560   113   266   471]);
        uicontrol('Tag', 'figname', 'Style','text', 'String', sprintf('%s_impairment',fname), 'Visible','off');

        % plot significance

        fsize=14;
        if pdur < alphaval,plotstar(gca,1,.045), else plotstar(gca,1, 0.045,'ns');end;
        if pdur < alphaval/10,plotstar(gca,1,.052);end;
        if pfreq < alphaval,plotstar(gca,2,0.045);end;
        if pfreq <alphaval/10,plotstar(gca,2,0.052);   end;

        %         % 1-duration, 2-freq
        if 0
            [s p] = permutationtest_diff(diff_list{2}, diff_list{1}, 'alphaval', 0.05, 'typeoftest','onetailed_ls0');
            fprintf(1,'Sig test for (freq - dur) < 0: p-value: %1.3f, Sig: %i\n', p, s);
            %         2;
        end;

    case 'single_group'
        if graphic > 0
            figure;
        end;

        diff_clr_flag = 1;

        infile = [ single_group '_psych_' area_filter '_psychdata_LAST7FIRST3PSYCH.mat'];
        if strcmpi(single_group, 'duration'), clr = durclr; else clr = freqclr; end;

        [b a]=sub__psychhitrate(infile,clr, pool_all_trials, ...
            postpsych, diff_clr_flag);
        if graphic > 0
            set(gca,'YLim',[0.65 1],'XLim',[0.8 2.2]);
            ylabel('Psych hit rate');
            set(gcf,'Position',[ 560   413   266   471]);
            title([single_group ': ' area_filter]);
        end;

    otherwise
        error('Invalid action');
end;

2;



% --------------------------------------------
% Subroutines


function [mean_bef mean_aft fnames] = sub__psychhitrate(infile,clr, ...
    pool, postpsych, diff_clr_flag, graphic)

diffclrs = [ 1 0 0; 0 0.5 0; 0 0 0.5; 1 0.5 0 ; 0.5 0 0.5];

global Solo_datadir;
indir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep];
idx=findstr(infile,'_');
texc = infile(1:idx(3)-1);
load([indir infile]);

if ~isempty(strfind(infile, 'pitch')), logt = 'log2('; else logt='log(';end;
fnames = fieldnames(rat_before);

if pool > 0
    mean_aft=NaN(size(fnames)); mean_bef = NaN(size(fnames));
    for f = 1:length(fnames)
        if strcmpi(fnames{f},'S045')
            2;
        end;
        t_a = eval(['rat_after.' fnames{f} ';']);
        nanidx=find(isnan(t_a.hit_history)>0);
        idx = find(t_a.psych_on == postpsych);
        if length(nanidx)>0,
            sprintf('!! WARNING: %s had %i NaNs in after hit_history!! ', fnames{f}, length(nanidx));
            t_a.hit_history=t_a.hit_history(~isnan(t_a.hit_history));
            t_a.psych_on= t_a.psych_on(~isnan(t_a.hit_history));
            idx=find(t_a.psych_on==postpsych);
        end;
        mean_aft(f) = sum(t_a.hit_history(idx)) / length(idx);

        t_b = eval(['rat_before.' fnames{f} ';']);
        idx = find(t_b.psych_on == postpsych);
        mean_bef(f) = sum(t_b.hit_history(idx)) / length(idx);

        if diff_clr_flag > 0, clr = diffclrs(min(rows(diffclrs), f), :); end;
        if graphic > 0
            plot(1:2, [mean_bef(f) mean_aft(f)], '.k','Color',clr); hold on;
            plot(1:2, [mean_bef(f) mean_aft(f)], '-k','Color',clr,'LineWidth', 2);
        end;
    end;
else
    after_cell = cell(size(fnames));
    before_cell = cell(size(fnames));
    %mean_aft = NaN(size(fnames)); mean_bef = NaN(size(fnames));
    mean_aft=[]; mean_bef=[];

    for f = 1:length(fnames)
        if postpsych == 0 && strcmpi(fnames{f},'Moria')
            fprintf(1,'**** EXCLUDING Moria\n');
        else
            if strcmpi(fnames{f},'S045')
                2;
            end;
            t_a = eval(['rat_after.' fnames{f} ';']);
            error('what function are you trying to call? this bit of code should be invalidated');
            hr_a = sub__psychhits(t_a.numtrials, t_a.psych_on, t_a.hit_history,postpsych);
            after_cell{f} = hr_a;
            mean_aft(end+1) = nanmean(hr_a);

            t_b = eval(['rat_before.' fnames{f} ';']);
            hr_b = sub__psychhits(t_b.numtrials, t_b.psych_on, t_b.hit_history,postpsych);
            before_cell{f} = hr_b;
            mean_bef(end+1) = nanmean(hr_b);

            if diff_clr_flag > 0, clr = diffclrs(min(rows(diffclrs), f), :); end;
            if graphic>0
                plot(1:2, [mean_bef(end) mean_aft(end)], '.k','Color',clr); hold on;
                plot(1:2, [mean_bef(end) mean_aft(end)], '-k','Color',clr,'LineWidth',2);
            end;
        end;
    end;
end;


if graphic > 0
    if diff_clr_flag > 0
        fig = get(0,'CurrentFigure');
        % legend
        figure; set(gcf,'Position',[766   639   128   215],'Menubar','none','TOolbar','none');
        axes('Position',[0.01 0.01 0.95 0.96], 'XTick',[], 'YTick',[]);
        for f =1:length(fnames)
            patch([0 0 1 1], [f f+1 f+1 f], diffclrs(min(rows(diffclrs), f), :), 'EdgeColor','none');
            text(0.2, f+0.5, fnames{f}, 'FontWEight','bold','FOntSize', 16,'Color','w');
        end;
        set(0,'CurrentFigure',fig);
    end;

    set(gca,'XLim',[0.8 2.2],'XTick', [1 2], 'XTickLabel',{'Before','After'}, 'YLim',[0.4 1]);
    title(texc);
    axes__format(gca);
    sign_fname(gcf,mfilename);
end;

function [hrate_list hrate_raw] = sub__gethrates(ratset,acxflag,postpsych,p_hrate)

preflipped=acxflag;
psychthresh=0;

hrate_list=[];
hrate_raw=[];
for r=1:length(ratset)
    ratname=ratset{r};
    tmp=NaN(1,2);   

    loadpsychinfo(ratname, 'infile', 'psych_before', ...
        'justgetdata',1,...
        'preflipped', preflipped, ...
        'psychthresh',psychthresh,...
        'lastfew', 7,...
        'eliminate_Mondays', 0,...
        'daily_bin_variability', 0, ...
        'graphic', 0, ...
        'postpsych',postpsych, ...
        'ACxround1', acxflag);
    if p_hrate > 0
        tmp(1)=overall_psychhrate;
    else
        tmp(1)=overall_hrate;
    end;

    loadpsychinfo(ratname, 'infile', 'psych_after', ...
        'justgetdata',1,...
        'preflipped', preflipped, ...
        'psychthresh',psychthresh,...
        'dstart',1, 'dend',3 , ...
        'eliminate_Mondays', 0,...
        'daily_bin_variability', 0, ...
        'graphic', 0,...
        'postpsych', postpsych, ...
        'ACxround1', acxflag,...
        'dontfitpsych',1);
    if p_hrate > 0
        tmp(2)=overall_psychhrate;
    else
        tmp(2)=overall_hrate;
    end;
    
    if sum(isnan(tmp))>0
        2;
    end;

    eval(['hrate_list.' ratname '= tmp;']);

    hrate_raw = vertcat(hrate_raw, tmp);

end;

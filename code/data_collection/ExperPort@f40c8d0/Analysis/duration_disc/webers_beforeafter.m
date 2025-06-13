function [wdur wfr] = webers_beforeafter(area_filter,action,postpsych,psychthresh, ignore_trialtype, varargin)
% for given lesion experiment returns weber of pooled before and after data
% for duration and frequency rats.
% output is two structs, where keys are rats, and values are (2x1)
% respective before and after weber ratios.

if length(varargin) > 0
    wdraw = varargin{1};
    wfraw=varargin{2};
end;

if strcmpi(area_filter,'ACx')
    ACxround1=1;
else
    ACxround1=0;
end;
% graph params
dur_clr=group_colour('duration');
freq_clr=group_colour('frequency');
msize=20;

global Solo_datadir;
outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep];

if postpsych==0
    fpfx='weberall_beforeafter_';
else
    fpfx='weberpsych_beforeafter_';
end;

fname = [fpfx area_filter];

warning off MATLAB:singularMatrix;

switch action    
    case 'indierat' % show averages before/after for one rat.
        ratname=area_filter;
        fname = [ratname '_' fpfx(1:end-1)];
        try
            load([outdir fname]);
        catch
            fprintf(1,'%s - No individual file found. Saving now...\n',ratname);
        sub__indiewebers(ratname,postpsych,psychthresh,ignore_trialtype);
        save([outdir fname]);
        end;
        
        
        
        
    case 'save'
        freqset = rat_task_table('','action','get_pitch_psych','area_filter',area_filter);
        [wfr wfraw] = sub__getwebers(freqset, ACxround1,postpsych,psychthresh, ignore_trialtype);
      %  wfraw(find(wfraw == -1)) = 1;

        durset = rat_task_table('','action','get_duration_psych','area_filter',area_filter);
        [wdur wdraw] = sub__getwebers(durset,ACxround1,postpsych,psychthresh, ignore_trialtype);
       % wdraw(find(wdraw == -1)) = 1;

        save([outdir fname],'wdur','wfr','wdraw','wfraw','postpsych');
    case 'plot'
        durlite=group_colour('durlite');
        freqlite=group_colour('freqlite');
        msize=20;

        figure;

        % TIMING
        sub__plotpair(wdraw, durlite);
        ma=mean(wdraw(:,1)); mb=mean(wdraw(:,2));
        sa=std(wdraw(:,1))/sqrt(rows(wdraw)); sb=std(wdraw(:,2))/sqrt(rows(wdraw));
        % plot group means

        errorbar(1:2, [ma mb], [sa sb],'.k','Color', dur_clr,'MarkerSize', msize, 'LineWidth',2);
        plot(1:2, [ma mb], '-k','Color', dur_clr,'MarkerSize', msize, 'LineWidth',4);

        % FREQUENCY
        sub__plotpair(wfraw, freqlite);
        ma=mean(wfraw(:,1)); mb=mean(wfraw(:,2));
        sa=std(wfraw(:,1))/sqrt(rows(wfraw)); sb=std(wfraw(:,2))/sqrt(rows(wfraw));
        % plot group means
        errorbar(1:2, [ma mb], [sa sb],'.k','Color', freq_clr,'MarkerSize', msize, 'LineWidth',2);
        plot(1:2, [ma mb], '-k','Color', freq_clr,'MarkerSize', msize, 'LineWidth',4);

        set(gca,'XLim',[0.7 2.3],'XTick',[1 2], 'XTickLabel',{'Before','After'});
        ylabel('Weber');
        title(subuscore(fpfx));
        set(gca,'YLim',[0 1.1]);
        axes__format(gca);
        set(gcf,'Toolbar','none','Position',[160   426   258   432]);
        uicontrol('Tag', 'figname', 'Style','text', ...
            'String', fname, 'Visible','off');

        % now plot differences in weber ratio
        figure;
        line([0 3],[ 0 0], 'LineStyle',':','Color',[1 1 1]*0.5,'LineWidth',2);hold on;
        plot(ones(size(wdraw,1)), wdraw(:,2)-wdraw(:,1),'.k','Color', dur_clr,'MarkerSize',msize);
        plot(ones(size(wfraw,1))*2, wfraw(:,2)-wfraw(:,1), '.k','Color',freq_clr,'MarkerSize',msize);
        set(gca,'XLim',[0.8 2.2],'XTick',[1 2],'XTickLabel',{'Timing','Frequency'});
        set(gca,'YTick',-0.2:0.2:1,'YLim',[-0.3 1.5]);
        ylabel({'After-Before;'; '(Weber; higher is worse)'});
         title(subuscore(fname));
        axes__format(gca);

        set(gcf,'Position',[500   426   258   432]);
        uicontrol('Tag', 'figname', 'Style','text', ...
            'String', [fname '_impair'], 'Visible','off');

        alphaval=0.05/2;
        [sigdur pdur] = permutationtest_diff(wdraw(:,2), wdraw(:,1), ...
            'alphaval', alphaval, 'typeoftest', 'onetailed_gt0','plotme',0, 0);

        [sigfreq pfreq] = permutationtest_diff(wfraw(:,2), wfraw(:,1), ...
            'alphaval', alphaval, 'typeoftest', 'onetailed_gt0','plotme',0, 0);

        %         [s p] = permutationtest_diff(wfraw(:,2)-wfraw(:,1), wdraw(:,2)-wdraw(:,1), ...
        %             'alphaval', alphaval, 'typeoftest', 'onetailed_gt0','plotme',0,0);

        %             plot significance
        fsize=14;
        if pdur < alphaval,plotstar(gca,1,1.2); else plotstar(gca,1, 1.2,'ns');end;
        if pdur < alphaval/10,plotstar(gca,1.4);end;
        if pfreq < alphaval,plotstar(gca,2,1.2); else plotstar(gca,2, 1.2,'ns');end;
        if pfreq <alphaval/10,plotstar(gca,2,1.4);   end;

        2;

        %         joinwithsigline(gca,1,2,1.2,1.3);
        %        text (1.3,0.05,sprintf('p=%1.3f',p),'FontSize', 14);
        %         if p<alphaval, plotstar(gca,1.5, 1.4); end;
        %         if p<alphaval/5, plotstar(gca,1.4, 1.4); end;

    case 'load'
        load([outdir fname]);
        webers_beforeafter(area_filter,'plot', postpsych,wdraw, wfraw);
        2;

    case 'justgetdata'
        try
            load([outdir fname]);
        catch
            fprintf(1,'COuld not find file for %s; resaving...\n', area_filter);
            webers_beforeafter(area_filter,'save',postpsych,psychthresh, ignore_trialtype);
            load([outdir fname]);
        end;

    otherwise
        error('unknown action');
end;


% -----------
% Subroutines

function [weber_list webers_raw] = sub__getwebers(ratset,acxflag,postpsych,psychthresh, ignore_trialtype)
preflipped=acxflag;
weber_list=[];
webers_raw=[];


for r=1:length(ratset)
    ratname=ratset{r};

    tmp=NaN(1,2);

    loadpsychinfo(ratname, 'infile', 'psych_before', ...
        'justgetdata',1,...
        'preflipped', preflipped, ...
        'psychthresh',psychthresh,...
        'ignore_trialtype', ignore_trialtype, ...
        'lastfew', 7,...
        'eliminate_Mondays', 0,...
        'daily_bin_variability', 0, ...
        'graphic', 0, ...
        'postpsych',postpsych, ...
        'ACxround1', acxflag);

    bef_xc=overall_xc;
    bef_xf=overall_xf;
    bef_xm=overall_xmid;
    
    tmp(1)=overall_weber;

    loadpsychinfo(ratname, 'infile', 'psych_after', ...
        'justgetdata',1,...
        'preflipped', preflipped, ...
        'psychthresh',psychthresh,...
        'ignore_trialtype', ignore_trialtype, ...
        'dstart',1, 'dend',3 , ...
        'eliminate_Mondays', 0,...
        'daily_bin_variability', 0, ...
        'graphic', 0,...
        'postpsych', postpsych, ...
        'ACxround1', acxflag);

    tmp(2)=overall_weber;
    aft_xc = overall_xc;
    aft_xf= overall_xf;
    aft_xm = overall_xmid;

    eval(['weber_list.' ratname '= tmp;']);

    webers_raw = vertcat(webers_raw, tmp);
end;


function [weberdat] = sub__indiewebers(ratname,postpsych,psychthresh, ignore_trialtype)

weberdat=cell{1,2};
  loadpsychinfo(ratname, 'infile', 'psych_before', ...
        'justgetdata',1,...
        'preflipped', preflipped, ...
        'psychthresh',psychthresh,...
        'ignore_trialtype', ignore_trialtype, ...
        'lastfew', 7,...
        'eliminate_Mondays', 0,...
        'daily_bin_variability', 0, ...
        'graphic', 0, ...
        'postpsych',postpsych, ...
        'ACxround1', acxflag);

    bef_xc=overall_xc;
    bef_xf=overall_xf;
    bef_xm=overall_xmid;
    
    tmp(1)=overall_weber;

    loadpsychinfo(ratname, 'infile', 'psych_after', ...
        'justgetdata',1,...
        'preflipped', preflipped, ...
        'psychthresh',psychthresh,...
        'ignore_trialtype', ignore_trialtype, ...
        'dstart',1, 'dend',3 , ...
        'eliminate_Mondays', 0,...
        'daily_bin_variability', 0, ...
        'graphic', 0,...
        'postpsych', postpsych, ...
        'ACxround1', acxflag);

    tmp(2)=overall_weber;
    aft_xc = overall_xc;
    aft_xf= overall_xf;
    aft_xm = overall_xmid;

    eval(['weber_list.' ratname '= tmp;']);

    webers_raw = vertcat(webers_raw, tmp);



function [] = sub__plotpair(webers_raw, clr)
lw=2;
for k=1:rows(webers_raw),
    plot([1 2], webers_raw(k,:), '.b','Color', clr); hold on;
    plot([1 2], webers_raw(k,:),'-b','Color',clr,'LineWidth', lw);
end;

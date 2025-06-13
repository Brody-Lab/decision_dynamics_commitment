function [] = cannula_analysis_driver(varargin)

pairs = { ...
    'action','run'; ...
    'exclude_S007', 1; ...
    'mymetric', 'hrate'; ...
    };
parse_knownargs(varargin,pairs);

global Solo_datadir;
outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep];



switch action
    case 'save'
        ratlist = {'S005','S002','S007','S014', 'S013', 'S017','S024'};
        rattask = 'ddddppp';

        mega_out = 0;
        for r = 1:length(ratlist)
            close all;
            ratname = ratlist{r};
            dbstop if error;
            out= psych_plotsingleday_vs_avgwk(ratname, 'blah',...
                'maniptype','all_four',...
                'pool_alldays',1,'pool_baseline',1,...
                'do_preavg', 0, 'write2file', 1);
            out.task = rattask(r);
            uicontrol('Tag', 'figname', 'Style','text', ...
                'String', [ratname '_cannula_allfour'], 'Visible','off');
            eval(['mega_out.' ratname ' = out;']);
            saveps_figures;
        end;

        save('cannula_analysis_alldoses','mega_out');

    case 'sal_muscimol'

        load('cannula_analysis');

        figure;
        fnames =fieldnames(mega_out);

        %   dstats.noinf = [];
        dstats.musc = [];
        dstats.sal =[];

        %     pstats.noinf=[];
        pstats.musc = [];
        pstats.sal = [];

        for f = 1:length(fnames)
            out = eval(['mega_out.' fnames{f} ';']);

            if exclude_S007 && ~strcmpi(fnames{f}, 'S007')

                %       none_hr = out.none.session_hrate; avg_none = mean(none_hr); sem_none = std(none_hr)/sqrt(length(none_hr));
                sal_hr = out.saline.session_hrate; avg_sal = sal_hr; sem_sal = NaN;
                musc_hr = out.muscimol.session_hrate; avg_musc = mean(musc_hr); sem_musc = std(musc_hr)/sqrt(length(musc_hr));

                avg = [avg_sal avg_musc];
                sem = [sem_sal  sem_musc];

                %         eval([out.task 'stats.noinf = horzcat(' out.task 'stats.noinf, avg_none);']);
                eval([out.task 'stats.musc  = horzcat(' out.task 'stats.musc,  avg_musc);']);
                eval([out.task 'stats.sal  = horzcat(' out.task 'stats.sal,  avg_sal);']);

                if strcmpi(out.task, 'd'),
                    clr = [1 0.5 0];
                else clr = [0.5 0.5 1];
                end;
                %          % plot difference in hit rate of both sets
                %
                plot(1:2, avg, '.k','Color',clr); hold on;
                plot(1:2, avg, '-k','Color',clr); hold on;
            end;
        end;

        % plot group averages

        % axes formatting
        %
        text(1.5, 0.97, 'Duration', 'Color', [1 0.5 0],'FontSize',14,'FontWeight','bold');
        text(1.5, 0.9, 'Frequency', 'Color', [0 0 0.5],'FontSize',14,'FontWeight','bold');

        set(gca,'YLim',[0.65 1],'XLim',[0.8 2.2],'XTickLabel',{'Saline','Muscimol'}, 'XTick',1:2);
        ylabel('Psych hit rate');
        set(gcf,'Position',[ 560   413   350   471]);
        axes__format(gca);

        % now plot group average
        msize =20;
        %   n = dstats.noinf;
        s = dstats.sal;
        m = dstats.musc;
        errorbar(1:2, [mean(s) mean(m)],...
            [std(s)./sqrt(length(s)) std(m)./ sqrt(length(m))], ...
            '.k','Color', [1 0.5 0],'MarkerSize', msize, 'LineWidth',2);
        plot(1:2, [mean(s) mean(m)], '-k','Color', [1 0.5 0],'MarkerSize', msize, 'LineWidth',2);

        %   n = pstats.noinf;
        s = pstats.sal;
        m = pstats.musc;
        errorbar(1:2, [mean(s) mean(m)],...
            [std(s)./sqrt(length(s))  std(m)./ sqrt(length(m))], ...
            '.k','Color', [0 0 0.5],'MarkerSize', msize, 'LineWidth',2);
        plot(1:2, [mean(s) mean(m)], '-k','Color', [0 0 0.5],'MarkerSize', msize, 'LineWidth',2);

    case 'noinf_muscimol'
        load([outdir 'cannula_analysis']);

        figure;
        fnames =fieldnames(mega_out);

        dstats.noinf = [];
        dstats.musc = [];
        %     dstats.sal =[];

        pstats.noinf=[];
        pstats.musc = [];
        %     pstats.sal = [];

        for f = 1:length(fnames)
            out = eval(['mega_out.' fnames{f} ';']);

            if exclude_S007 && ~strcmpi(fnames{f}, 'S007')

                none_hr = out.none.session_hrate; avg_none = mean(none_hr); sem_none = std(none_hr)/sqrt(length(none_hr));
                %       sal_hr = out.saline.session_hrate; avg_sal = sal_hr; sem_sal = NaN;
                musc_hr = out.muscimol.session_hrate; avg_musc = mean(musc_hr); sem_musc = std(musc_hr)/sqrt(length(musc_hr));

                avg = [avg_none avg_musc];
                sem = [sem_none  sem_musc];

                eval([out.task 'stats.noinf = horzcat(' out.task 'stats.noinf, avg_none);']);
                eval([out.task 'stats.musc  = horzcat(' out.task 'stats.musc,  avg_musc);']);
                %        eval([out.task 'stats.sal  = horzcat(' out.task 'stats.sal,  avg_sal);']);

                if strcmpi(out.task, 'd'),
                    clr = [1 0.5 0];
                else clr = [0.5 0.5 1];
                end;
                %          % plot difference in hit rate of both sets
                %
                plot(1:2, avg, '.k','Color',clr); hold on;
                plot(1:2, avg, '-k','Color',clr); hold on;
            end;
        end;

        % plot group averages

        % axes formatting
        %
        text(1.5, 0.97, 'Duration', 'Color', [1 0.5 0],'FontSize',14,'FontWeight','bold');
        text(1.5, 0.97, 'Frequency', 'Color', [0 0 0.5],'FontSize',14,'FontWeight','bold');

        set(gca,'YLim',[0.65 1],'XLim',[0.8 2.2],'XTickLabel',{'no infusion','Muscimol'}, 'XTick',1:2);
        ylabel('Psych hit rate');
        set(gcf,'Position',[ 560   413   350   471]);
        axes__format(gca);

        % now plot group average
        msize =20;
        n = dstats.noinf;
        %  s = dstats.sal;
        m = dstats.musc;
        errorbar(1:2, [mean(n) mean(m)],...
            [std(n)./sqrt(length(n)) std(m)./ sqrt(length(m))], ...
            '.k','Color', [1 0.5 0],'MarkerSize', msize, 'LineWidth',2);
        plot(1:2, [mean(n) mean(m)], '-k','Color', [1 0.5 0],'MarkerSize', msize, 'LineWidth',2);

        n = pstats.noinf;
        %   s = pstats.sal;
        m = pstats.musc;
        errorbar(1:2, [mean(n) mean(m)],...
            [std(n)./sqrt(length(n))  std(m)./ sqrt(length(m))], ...
            '.k','Color', [0 0 0.5],'MarkerSize', msize, 'LineWidth',2);
        plot(1:2, [mean(n) mean(m)], '-k','Color', [0 0 0.5],'MarkerSize', msize, 'LineWidth',2);


    case 'muscminussal'

        load([outdir 'cannula_analysis_alldoses']);
        fnames =fieldnames(mega_out);

        dstats.noinf = [];
        dstats.musc = [];
        dstats.sal =[];
        dstats.muscfromsal = [];
        dstats.ratlist =[];

        pstats.noinf=[];
        pstats.musc = [];
        pstats.sal = [];
        pstats.muscfromsal =[];
        pstats.ratlist = [];

      %  mymetric = 'timeout'; % hrate or longresp or timeout

        for f = 1:length(fnames)
            out = eval(['mega_out.' fnames{f} ';']);

            if exclude_S007 && ~strcmpi(fnames{f}, 'S007')
                mdata = out.muscimol;
                mydose = rat_task_table(fnames{f}, 'action','getdose');
                idx= setdiff( find(mdata.doses == mydose), mdata.poolxclude_dates );

                switch mymetric
                    case 'hrate'
                        none_hr = out.none.session_hrate; none_hr = none_hr(~isnan(none_hr));
                        avg_none = mean(none_hr); sem_none = std(none_hr)/sqrt(length(none_hr));

                        sal_hr = out.saline.session_hrate; sal_hr = sal_hr(~isnan(sal_hr));
                        avg_sal = mean(sal_hr); sem_sal = std(sal_hr)/sqrt(length(sal_hr));

                        % remember to get only those sessions with appropriate
                        % muscimol dose
                        musc_hr = out.muscimol.session_hrate(idx);  musc_hr = musc_hr(~isnan(musc_hr));
                        avg_musc = mean(musc_hr); sem_musc = std(musc_hr)/sqrt(length(musc_hr));

                        avg = [avg_none avg_sal avg_musc];
                        sem = [sem_none sem_sal sem_musc];

                        muscfromsal = avg_musc - avg_sal; %avg_sal - avg_musc;

                        eval([out.task 'stats.noinf = horzcat(' out.task 'stats.noinf, avg_none);']);
                        eval([out.task 'stats.musc  = horzcat(' out.task 'stats.musc,  avg_musc);']);
                        eval([out.task 'stats.sal  = horzcat(' out.task 'stats.sal,  avg_sal);']);
                       % ylbl='Avg saline -Avg muscimol  (%)';
                       ylbl = 'Avg muscimol - Avg saline (%)';
                    case 'longresp'
                        bh = out.muscimol.betahat(idx,:); bh_musc = bh(:,1); %lower limit on muscimol (dose) days
                        bh = out.saline.betahat; bh_sal = bh(:,1); %saline
                        
                        muscfromsal =nanmean(bh_musc) -nanmean(bh_sal);
                        ylbl=sprintf('Lower bound of psych curve\n (musc-sal) (%%)');
                    case 'timeout'
                        to_musc = out.muscimol.session_to(idx);
                        to_sal = out.saline.session_to;
                        muscfromsal = mean(to_musc) - mean(to_sal);
                        ylbl=sprintf('Timeout rate\n(musc - sal)');
                    otherwise
                        error('sorry, metric not implemented.');
                end;

                eval([out.task 'stats.muscfromsal  = horzcat(' out.task 'stats.muscfromsal, muscfromsal);']);
                %sanity check
                tmp = eval([out.task 'stats.ratlist']);
                tmp{end+1} = fnames{f};
                eval([out.task 'stats.ratlist=tmp;']);
            end;
        end;

        % plot
        msize = 20;
        figure;
        tmp_d = dstats.muscfromsal; tmp_p = pstats.muscfromsal;
        [x1 x2]=makebargraph(tmp_d,tmp_p,...
            'g1_clr',group_colour('duration'), 'g2_clr', group_colour('frequency'), ...
            'g1_lbl','Timing','g2_lbl','Frequency');
        
      plot(ones(size(tmp_d))*x1, tmp_d, '.','Color', [1 1 1]*0.3, 'MarkerSize',msize);
      plot(ones(size(tmp_p))*x2, tmp_p, '.','Color', [1 1 1]*0.3, 'MarkerSize',msize);                
        %          mega = [tmp_d' ones(size(tmp_d')); tmp_p' ones(size(tmp_p'))*2]
        %          boxplot(mega);
        %          hold on;

%         patch([0.8 0.8 1.2 1.2], [0 mean(tmp_d) mean(tmp_d) 0],[1 0.5 0], 'EdgeColor','none'); hold on;
        %          line([1 1], [mean(tmp)-std(tmp) mean(tmp)+std(tmp)], 'Color', [1
        %          1 1]*0.5);


        %          tmp = pstats.muscfromsal;
%         patch([0.8 0.8 1.2 1.2]+1, [0 mean(tmp_p) mean(tmp_p) 0],[0.5 0.5 1], 'EdgeColor','none'); hold on;
        %          line([2 2], [mean(tmp)-std(tmp) mean(tmp)+std(tmp)],
        %          'Color', [1 1 1]*0.5);


%         set(gca,'XLim',[0.5 2.5], 'XTick', [1 2], 'XTickLabel', {'dur','freq'}); 
%        set(gca,'YLim', [-0.2 0.2],'Ytick', -0.1:0.05:0.2, 'YTickLabel',-10:5:20);
        axes__format(gca);
        ylabel(ylbl);
        uicontrol('Tag', 'figname', 'Style','text', 'String', ['Cannula_muscfromsal_' mymetric], 'Visible','off');

        % print rat names
        fprintf(1,'Duration rats: '); for r=1:length(dstats.ratlist), fprintf(1,'%s ', dstats.ratlist{r}); end; fprintf(1,'\n\n');
        fprintf(1,'Freq rats: '); for r=1:length(pstats.ratlist), fprintf(1,'%s ', pstats.ratlist{r}); end; fprintf(1,'\n\n');

    case 'run'
        
        load([outdir 'cannula_analysis']);

        figure;
        fnames =fieldnames(mega_out);

        dstats.noinf = [];
        dstats.musc = [];
        dstats.sal =[];

        pstats.noinf=[];
        pstats.musc = [];
        pstats.sal = [];

        for f = 1:length(fnames)
            out = eval(['mega_out.' fnames{f} ';']);

            if exclude_S007 && ~strcmpi(fnames{f}, 'S007')
                mdata = out.muscimol;
                mydose = rat_task_table(fnames{f}, 'action','getdose');
                idx= setdiff( find(mdata.doses == mydose), mdata.poolxclude_dates );

                none_hr = out.none.session_hrate; avg_none = mean(none_hr); sem_none = std(none_hr)/sqrt(length(none_hr));
                sal_hr = out.saline.session_hrate; avg_sal = sal_hr; sem_sal = NaN;
                musc_hr = out.muscimol.session_hrate; avg_musc = mean(musc_hr); sem_musc = std(musc_hr)/sqrt(length(musc_hr));

                avg = [avg_none avg_sal avg_musc];
                sem = [sem_none sem_sal sem_musc];

                eval([out.task 'stats.noinf = horzcat(' out.task 'stats.noinf, avg_none);']);
                eval([out.task 'stats.musc  = horzcat(' out.task 'stats.musc,  avg_musc);']);
                eval([out.task 'stats.sal  = horzcat(' out.task 'stats.sal,  avg_sal);']);

                if strcmpi(out.task, 'd'),
                    clr = [1 0.5 0];
                else clr = [0.5 0.5 1];
                end;
                %          % plot difference in hit rate of both sets
                %
                lwdth = 2;
                % %                  plot(1:3, avg, '.k','Color',clr,'LineWidth', lwdth); hold on;
                plot(1:3, avg, '-k','Color',clr,'LineWidth', lwdth); hold on;
            end;
        end;

        % plot group averages

        % axes formatting
        %
        text(2.5, 0.97, 'Duration', 'Color', [1 0.5 0],'FontSize',14,'FontWeight','bold');
        text(2.4, 0.99, 'Frequency', 'Color', [0 0 0.5],'FontSize',14,'FontWeight','bold');

        set(gca,'YLim',[0.65 1],'XLim',[0.8 3.2],'XTickLabel',{'no infusion','Saline','Muscimol'}, 'XTick',1:3);
        ylabel({'% correct', '(psychometric trials)'});
        set(gcf,'Position',[ 560   413   350   471]);
        axes__format(gca);

        % now plot group average
        msize =28;
        lwdth = 4;
        n = dstats.noinf;
        s = dstats.sal;
        m = dstats.musc;
        errorbar(1:3, [mean(n) mean(s) mean(m)],...
            [std(n)./sqrt(length(n)) std(s)./sqrt(length(s)) std(m)./ sqrt(length(m))], ...
            '.k','Color', [1 0.5 0],'MarkerSize', msize, 'LineWidth',4);
        plot(1:3, [mean(n) mean(s) mean(m)], '-k','Color', [1 0.5 0],'MarkerSize', msize, 'LineWidth',lwdth);

        n = pstats.noinf;
        s = pstats.sal;
        m = pstats.musc;
        errorbar(1:3, [mean(n) mean(s) mean(m)],...
            [std(n)./sqrt(length(n)) std(s)./sqrt(length(s)) std(m)./ sqrt(length(m))], ...
            '.k','Color', [0 0 0.5],'MarkerSize', msize, 'LineWidth',2);
        plot(1:3, [mean(n) mean(s) mean(m)], '-k','Color', [0 0 0.5],'MarkerSize', msize, 'LineWidth',lwdth);

        set(gca,'YTick',0.65:0.05:1,'YTickLabel', 65:5:100);
        uicontrol('Tag', 'figname', 'Style','text', 'String', 'cannula_all_thress', 'Visible','off');


    case 'dose_response'
        load([outdir 'cannula_analysis_alldoses']);
        fnames =fieldnames(mega_out);

        dstats = []; %dstats.ratname.mstats = [dose avg_perf_measure]
        pstats = [];

        for f = 1:length(fnames)
            out = eval(['mega_out.' fnames{f} ';']);

            if exclude_S007 && ~strcmpi(fnames{f}, 'S007')
                mdata = out.muscimol;
                hrate =[];to=[];lftmost=[];tallies=[]; tallymin=[]; tallymax=[];
                unq = unique(mdata.doses);
                baddates = mdata.poolxclude_dates;

                for q = 1:length(unq)
                    if (~strcmpi(fnames{f},'S005') || (strcmpi(fnames{f},'S005') && (unq(q) ~= 0.16)))
                    idx= setdiff( find(mdata.doses == unq(q)), mdata.poolxclude_dates );

                    hrate = vertcat(hrate,  [unq(q) mean(mdata.session_hrate(idx))]);
                    to = vertcat(to,        [unq(q) mean(mdata.pct_noto(idx))]);
                    tal = mdata.tallies(idx,:);
                    bh = mdata.betahat;
                    lftmost = vertcat(lftmost, [unq(q) mean(bh(idx,1));]);
                    tallies = vertcat(tallies,[unq(q) mean(sum(tal,2))]);
                    try
                    tallymin = vertcat(tallymin,[unq(q) min(sum(tal,2))]);
                    catch
                        2;
                    end;
                    tallymax = vertcat(tallymax, [unq(q) max(sum(tal,2))]);
                    end;
                end;

                eval([out.task 'stats.' fnames{f} '.hrate = hrate;']);
                eval([out.task 'stats.' fnames{f} '.to = to;']);
                eval([out.task 'stats.' fnames{f} '.lftmost = lftmost;']);
                eval([out.task 'stats.' fnames{f} '.tallies = tallies;']);
                eval([out.task 'stats.' fnames{f} '.tallymin = tallymin;']);
                eval([out.task 'stats.' fnames{f} '.tallymax = tallymax;']);                
            end;
        end;

        % plot dose-response curve
        durclr = [1 0.5 0];
        freqclr = [0 0 1];
        metrics = {'hrate', 'to','lftmost','tallies','tallymin'};
        metrics = 0;
        metrics.hrate = [];
        metrics.hrate.miny = 0.5;
        metrics.hrate.maxy = 1;
        metrics.lftmost = [];
        metrics.lftmost.miny = -0.02;
        metrics.lftmost.maxy = 0.2;
        metrics.tallies = [];
        metrics.tallies.miny = 0;
        metrics.tallies.maxy=250;
        metrics.tallymin = [];
        metrics.tallymin.miny = 0;
        metrics.tallymin.maxy=250;

        

        ssize = get(0,'ScreenSize'); sw = ssize(3); sh=ssize(4);
        mnames = fieldnames(metrics);

        for m = 1:length(mnames)
            currm = mnames{m};
            figure;
            fnames = fieldnames(dstats);
            for r = 1:length(fnames)
                t = eval(['dstats.' fnames{r} '.' currm]);
                try
                plot(t(:,1), t(:,2), '.b', 'Color', durclr,'MarkerSize',20);hold on;
                plot(t(:,1), t(:,2), '-b', 'Color', durclr);hold on;
                catch
                    2;
                end;
            end;
            fnames = fieldnames(pstats);
            for r = 1:length(fnames)
                t = eval(['pstats.' fnames{r} '.' currm]);
                plot(t(:,1), t(:,2), '.b', 'Color', freqclr,'MarkerSize',20);hold on;
                plot(t(:,1), t(:,2), '-b', 'Color', freqclr);hold on;
            end;
            2;
            xlabel('dose');
            ylabel(currm);

            set(gcf,'Position',[rand(1,1)*0.75*sw   rand(1,1)*0.75*sh   616   225]);
            axes__format(gca);
            set(gca,'XLim',[0 0.1]);
            str = eval(['metrics.' currm ';']);
            if ~isempty(str)
                yl1 = eval(['metrics.' currm '.miny;']);
                yl2 = eval(['metrics.' currm '.maxy;']);
                set(gca,'YLim', [yl1 yl2]);
            end;
            title(currm);
        end;

    case 'fixme'
        load('cannula_analysis_alldoses');
        2;

    otherwise
        error('unknown action');

end;
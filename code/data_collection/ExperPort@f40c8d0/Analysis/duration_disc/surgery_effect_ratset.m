function [allrat_residuals allrat_failed_dates] = surgery_effect_ratset(varargin)
% Running 'surgery_effect' for all data for all rats of certain task/area
% lesion
pairs = { ...
    'action', 'default' ; ... [ default | plot_residuals ]
    % Which set of rats ? ------------------------------------
    'area_filter', 'ACx'; ...
    'tasktype', 'duration'; ... % from rat_task_table
    % Which set of dates ? ------------------------------------
    'lastfew_before', 1000 ; ...
    'lastfew_after', 1000; ...
    'days_before', [1 1000] ; ...
    'days_after', [1 1000] ;...
    'eliminate_Mondays', 0 ; ...
    'usefig', 0 ; ... % when non-zero, should be a fig handle. All plots will be drawn on given fig
    'curvecolour', 0 ; ... % when non-zero is the colour of all plotted graphs
    };
parse_knownargs(varargin,pairs);

param_buffer={}; % keys are rats
% values are 1x3 cell arrays containing the variables
% metric_numpoints, metric_sig, and param_estim for each
% rat

dash = [repmat('-',1,100)];
fprintf(1,'%s\n',dash);
fprintf(1,'Area filter = %s\nSet = %s\n',area_filter, tasktype);
fprintf(1,'Days before = [%i %i], Days after = [%i %i]\n', days_before(1), days_before(2), ...
    days_after(1), days_after(1));
fprintf(1,'Last few before = %i, Last few after = %i\n', lastfew_before, lastfew_after);
fprintf(1,'%s\n',dash);

ratlist = rat_task_table('','action',['get_' tasktype '_psych'],'area_filter',area_filter);

switch action
    case 'plot_residuals'
        
        show_averages = 1;
        
        allrat_residuals = {};
        allrat_failed_dates = {};
        for r = 1:length(ratlist)
            ratname = ratlist{r};
            surgery_effect(ratname, 'lastfew_before', lastfew_before , 'lastfew_after', lastfew_after,...
                'days_before', days_before, 'days_after', days_after, ...
                'graphic', 0 , 'eliminate_Mondays', eliminate_Mondays, ...
                'output_vars',1,'suppress_stdout',1,'return_residuals',1);
            eval(['allrat_residuals.' ratname ' = residuals;']);
                        eval(['allrat_failed_dates.' ratname ' = failed_dates;']);
        end;

        % plot residuals
        if usefig > 0
            set(0,'CurrentFigure',usefig);
        else
            figure;
        end;
        ratcolour={};
        fnames = fieldnames(allrat_residuals);       
        
        residual_matrix=[];
        for idx = 1:length(fnames)
            if length(curvecolour) == 1 && curvecolour == 0
                curr_c = rand(1,3);
            else
                curr_c = curvecolour;
            end;
            currat = fnames{idx};
            eval(['ratcolour.' currat ' = curr_c;']);
            curr_res = eval(['allrat_residuals.' currat ';']);                       

         %   l   =   plot(find(curr_res >=0), curr_res(find(curr_res>=0)),'.b');hold on;
            l2  =   plot(find(curr_res >=0), curr_res(find(curr_res>=0)),'-b');hold on;
            % l2  =   plot(1:length(curr_res), curr_res,'-b');
            % l3  =   plot(find(curr_res<0), curr_res(find(curr_res <0)), 'xb');

            hold on;
%            set(l,'Color',curr_c);
            set(l2,'Color',curr_c);
            %set(l3,'Color',curr_c);

            xlim = get(gca,'XLim');
            set(gca,'XLim',[0 max(xlim(2), length(curr_res))]);
        end;

        x=xlabel('Day of post-recovery training'); set(x,'FontWeight','bold','FontSize',20);
        y=ylabel('%'); set(y,'FontWeight','bold','FontSize',20);
        set(gca,'FontSize',16,'FontWeight','bold');
        ar=strrep(tasktype,'_',' ');
        t=title(sprintf('%s-lesioned %sometric rats (n=%i)', area_filter, ar, length(ratlist)));
        set(t,'FontWeight','bold','FontSize',12);
        %         xlim = get(gca,'XLim');
        %         line([xlim(1) xlim(2)], [0 0],'LineStyle',':');

        lns =get(gca,'Children');
        for i =1:length(lns), currl= lns(i); set(currl,'LineWidth',2); end;
        if length(curvecolour) == 1 && curvecolour == 0
            % map colours to rats
            figure;set(gcf,'Position',[1200 100 100 500]);
            fnames = fieldnames(ratcolour);
            for idx=1:length(fnames)
                t=text(1, idx, fnames{idx});
                set(t,'Color', eval(['ratcolour.' fnames{idx}]) ,'FontWeight','bold','FontSize',12);

                t=title('Rat colours');
                set(t,'FontWeight','bold','FontSize',14);
                set(gca,'XLim',[0.5 1.5],'YLim',[0 length(fnames)+1]);
            end;
        end;

    otherwise
        for r = 1:2%length(ratlist)
            ratname = ratlist{r};
            surgery_effect(ratname, 'lastfew_before', lastfew_before , 'lastfew_after', lastfew_after,...
                'graphic',1, 'days_before', days_before, 'days_after', days_after, ...
                'output_vars',1,'suppress_stdout',1,'eliminate_Mondays',eliminate_Mondays);
            mycell = { metric_numpoints metric_sig param_estim };
            eval(['param_buffer.' ratname ' = mycell;']);
        end;

        assignin('base','param_buffer',param_buffer);

        % now plot patchwork of significance
        close all;
        ratlist = fieldnames(param_buffer);
        figure; set(gcf,'Color','w','Toolbar','none','Position',[60 500 630 230]);
        set(gcf,'Tag', 'metric_sig_chart');

        figure;set(gcf,'Color','w','Tag','paramestim_sig','Toolbar','none','Position',[700 400 330 380]);

        curr_m = 0;
        curr_b=0;
        ttl = {};
        for r = 1:length(ratlist)
            ratname =ratlist{r};
            eval(['curr = param_buffer.' ratname ';']);
            metrics = curr{2};

            set(0,'CurrentFigure',findobj('Tag','metric_sig_chart'));
            curr_m = cell2mat(metrics(:,4));

            for m = 1:rows(metrics)
                if metrics{m,4} == 1, clr = 'r';
                elseif metrics{m,4} == 2, clr = 'k';
                else clr = [0.6 0.6 0.6];
                end;
                patch([m m m+1 m+1], [r r+1 r+1 r], clr);
            end;
            ttl = metrics(:,1);

            set(0,'CurrentFigure',findobj('Tag','paramestim_sig'));
            curr_p = curr{3};
            bh = curr_p.betahats;
            bh1 = bh{:,1}; bh2 = bh{:,2}; curr_b = bh1;
            ci = curr_p.cis;
            ci1 = ci{:,1};
            for b =1:length(bh1)
                if bh2 == -1
                    clr='k';
                    patch([b b b+1 b+1], [r r+1 r+1 r], clr);
                else
                    if bh2(b) < ci1(b,1) || bh2(b) > ci1(b,2),clr = 'r'; else clr=[0.6 0.6 0.6];end;
                    patch([b b b+1 b+1], [r r+1 r+1 r], clr);
                end;
            end;

        end;

        set(0,'CurrentFigure',findobj('Tag','metric_sig_chart'));
        set(gca,'YTick',[1 length(ratlist)+1], 'XLim',[1 length(curr_m)+1],...
            'XTick', 1.5:1:length(curr_m)+0.5, 'XTickLabel', ttl,'YTick', 1.5:1:length(ratlist)+0.5,...
            'YTickLabel', ratlist);
        ar = strrep(tasktype, '_',' ');
        t=title(sprintf('%s rats (Area = %s)\nBefore sig diff from After?', ar, area_filter));
        set(t,'FontWeight','bold','FontSize',14);

        set(0,'CurrentFigure',findobj('Tag','paramestim_sig'));
        set(gca,'YTick',[1 length(ratlist)+1], 'XLim',[1 length(curr_b)+1],...
            'XTick', 1.5:1:length(curr_m)+0.5, 'XTickLabel', {'Pmax','m','n','Growth rate'},'YTick', 1.5:1:length(ratlist)+0.5,...
            'YTickLabel', ratlist);
        t=title(sprintf('%s rats (Area = %s)\nComparing param estimates for logistic fit?', ar, area_filter));
        set(t,'FontWeight','bold','FontSize',14);

end;

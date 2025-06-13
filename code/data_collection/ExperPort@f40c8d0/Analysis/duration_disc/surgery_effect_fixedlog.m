function [] = surgery_effect_fixedlog(ratname,varargin)

pairs = { ...
    'before_file', 'logdiff_before' ; ...
    'after_file','logdiff_after' ; ...
    'experimenter','Shraddha'; ...
    'action','load'; ...
    'brief_title', 0; ...
    'ratlist', {}; ... % comma-separated list of ratnames for which data files are to be saved (only when action='save_list')
    % Which days to include? ---------------------------------
    'days_before', [1 1000] ; ...
    'days_after', [1 1000];...
    'lastfew_before', 1000;...
    'lastfew_after', 1000;...
    };
parse_knownargs(varargin,pairs);

global Solo_datadir;
%'dates','logdiff', 'hit_history','numtrials','logflag','psychflag');

switch action
    case 'save_list'
        for r = 1:length(ratlist)
            ratname = ratlist{r};
            surgery_effect_fixedlog(ratname,'action','save');
        end;

    case 'save'
        savelogdiffinfo(ratname,'trainphase','before');
        savelogdiffinfo(ratname,'trainphase','after');
    case 'load'
        ratrow = rat_task_table(ratname);
        task = ratrow{1,2};

        dstart = days_before(1); dend= days_before(2);
        lastfew = lastfew_before;              

        % load 'BEFORE' file
        f = [Solo_datadir filesep 'Data' filesep experimenter filesep ratname filesep before_file]; load(f);
        datafields = {'dates','logdiff','hit_history','numtrials','logflag','psychflag'};
        
          % -----------------------------------
        % Variables to filter a range of sessions
        % in your dataset >> BEGIN
        dend = min(dend, rows(dates));
        cumtrials = cumsum(numtrials(1:dend));
        lastidx = cumtrials(end);
        startidx = 1;

        if lastfew < 1000
            lastfew = min(rows(dates), lastfew);
            dstart = rows(dates)-(lastfew-1);
        end;

        if dstart > 1
            startidx= cumtrials(dstart-1) +1;
        end;
        % << END filtering session dates

         for idx =1:length(datafields)            
             if strcmpi(datafields{idx}, 'dates') || strcmpi(datafields{idx}, 'numtrials')
                 tmp = eval(datafields{idx});
                 tmp = tmp(dstart:dend);
             else
                 tmp = eval(datafields{idx});
                 tmp = tmp(startidx:lastidx);
             end;
                            %  datafields{idx} = tmp;
            eval([datafields{idx} '_before = ' datafields{idx} ';']);
        end;

        % load 'AFTER' file
        f = [Solo_datadir filesep 'Data' filesep experimenter filesep ratname filesep after_file];load(f);

        dstart = days_after(1); dend= days_after(2);
        lastfew = lastfew_after;
        % -----------------------------------
        % Variables to filter a range of sessions
        % in your dataset >> BEGIN
        dend = min(dend, rows(dates));
        cumtrials = cumsum(numtrials(1:dend));
        lastidx = cumtrials(end);
        startidx = 1;

        if lastfew < 1000
            lastfew = min(rows(dates), lastfew);
            dstart = rows(dates)-(lastfew-1);
        end;

        if dstart > 1
            startidx= cumtrials(dstart-1) +1;
        end;
        % << END filtering session dates

        fprintf(1,'post has %i trials\n',lastidx);

        for idx =1:length(datafields)            
             if strcmpi(datafields{idx}, 'dates') || strcmpi(datafields{idx}, 'numtrials')
                 tmp = eval(datafields{idx});
                 tmp = tmp(dstart:dend);
             else
                 tmp = eval(datafields{idx});
                 tmp = tmp(startidx:lastidx);
             end;
           %  datafields{idx} = tmp;
            eval([datafields{idx} '_after = ' datafields{idx} ';']);
        end;

        un_before = unique(logdiff_before);
        un_after = unique(logdiff_after);
        
        % How many diffeent logdiffs was this animal performing to?
        figure;
        plot(ones(size(un_before))*1, un_before,'.b');
        hold on;
        plot(ones(size(un_after))*2, un_after,'.r');
        if length(un_before)+length(un_after) > 2, set(gca,'Color','y'); end;
        set(gcf,'Menubar','none','ToolBar','none','Position',[182 536 400 100]);
        set(gca,'XLim',[0 3], 'XTick', [1 2], 'XTickLabel',{'before','after'},'YLim',[0 1],'YTick',0.2:0.2:0.8);

        [means_before sd_before] = get_session_hrates(hit_history_before,numtrials_before);
        [means_after sd_after] = get_session_hrates(hit_history_after,numtrials_after);
        
        hh_bef=hit_history_before;
        hh_aft = hit_history_after;

        sem_before =  std(hh_bef)/sqrt(length(hh_bef));
        sem_after = std(hh_aft)/sqrt(length(hh_aft));

        figure;
              uicontrol('Tag', 'figname', 'Style','text', 'String', sprintf('%s_beforeafter_means',ratname), 'Visible','off');
        barweb([mean(hh_bef) mean(hh_aft)], ...
            [sem_before sem_after]);
        
        c = get(gca,'Children');
        for idx= 1:2        
            if strcmpi(get(c(idx),'Type'),'hggroup')
                set(c(idx),'LineWidth',3);
            end;
        end;
        if brief_title > 0
            t=title(sprintf('%s', ratname));  
            set(t,'FontSize',28, 'FontWeight','bold');
        else
        t=title(sprintf('%s: Before/after avg %% correct\nBefore:(%s-%s)\nAfter:(%s-%s)', ratname, dates_before{1}, dates_before{end}, dates_after{1},dates_after{end}));
        set(t,'FontSize',16,'FontWeight','bold');
        end;        
        ht = max(mean(hh_bef)+sem_before,mean(hh_aft)+sem_after);
        set(gca,'XLim',[0 2],'XTIck',[],'FontSize',16,'FontWeight','bold',...
            'YLim',[0 ht*1.3],'YTick',[0:0.2:1], 'YTickLabel',0:20:100);
        set(gcf,'Position',[587   431   403   314],'Toolbar','none');
        
    %   [sig p]= permutationtest_diff(means_before, means_after,'alphaval',0.05);
%sig=1;p=0.04;
       [sig p] =permutationtest_diff(hh_bef,hh_aft,'alphaval',0.05);
        hold on; line([0.85 1.15], [ht*1.1 ht*1.1],'Color','k','LineWidth',2);
        if sig > 0 % significant,
            t=text(0.85, ht*1.2, sprintf('* (p=%1.3f)',p));
        else
            t=text(0.85, ht*1.2, sprintf('n.s. (%1.2f)',p));
        end;
        ylabel('% Correct');
        set(t,'FontSize',28,'FontWeight','bold');
        set(get(gca,'YLabel'),'FontSize',30);
        set(get(gca,'title'), 'FontSize', 24);
        set(gca,'FontSize',30);

        % Now also show influence of trial length on responses
%         if strcmpi(task(1:3),'dur')
%             triallen_influence(ratname, 'use_dateset','psych_before');
%             triallen_influence(ratname, 'use_dateset','psych_after');
%         end;

    otherwise
        error('Invalid action');
end;


function [means sd] = get_session_hrates(hh, ntr)
means=[];
sd=[];
cumtrials =cumsum(ntr);
for i = 1:length(ntr)
    sidx=1;
    if i>1, sidx = cumtrials(i-1)+1; end;
    eidx=cumtrials(i);
    
    means = horzcat(means, mean(hh(sidx:eidx)));
    sd = horzcat(sd, std(hh(sidx:eidx)));
end;
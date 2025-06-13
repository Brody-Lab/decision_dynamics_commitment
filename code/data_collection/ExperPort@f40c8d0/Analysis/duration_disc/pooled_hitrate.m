function [] = pooled_hitrate(varargin)
% Shows the hit rate averaged over a collection of sessions for a set of
% rats.
% Expects rat name and date range in a cell. Each row contains
% information about a rat.
% rat_set{r,1} = 'Squeaker'; rat_set{r,2} = {'070221','070228'}, where
% 'r' refers to the row number.
% In this case, row 'r' of rat_set will obtain the average hit rate for
% all sessions between 21st and 28th Feb, 2007.
  
    pairs =  { ...
       'rat_set', {} ; ...
       'task', 'duration_discobj' ; ...
   };
  parse_knownargs(varargin, pairs);
  
  mega_mean = [];
  mega_sem = [];
  name_list = {};
  for r = 1:rows(rat_set)
     date_range = rat_set{r,2};
     rat = rat_set{r,1};
     name_list{r} = rat;
     
     [mean_pool sem_pool]= getavg(rat, task, date_range);
     
     mega_mean = [mega_mean; mean_pool];
     mega_sem = [mega_sem; sem_pool];
    
  end;
  
  %figure;
  %set(gcf,'Menubar','none','Toolbar','none');
  %mega_mean
  %bar(mega_mean, 1); hold on; 
  %errorbar(, [mean_pre mean_post], [sem_pre sem_post], [sem_pre ...
  %                    sem_post]); colormap summer;
  barweb(mega_mean, mega_sem, 0.2, name_list, [],'Rat',['Avg. hit rate ' ...
                      '(%)']);
  hold on;
  line([0 rows(rat_set)+1], [0.8 0.8], 'LineStyle',':','Color','r');
  set(gca,'XLim', [0 4], 'XTick', 1:rows(rat_set), 'XTickLabel', name_list, ...
          'YLim', [0 2], 'YTick', 0:0.2:1, 'YTickLabel', 0:20:100);
  t = ylabel('Average hit rate (%)');
set(t,'FontSize',14,'FontWeight','bold');
    t = xlabel('Rat');
set(t,'FontSize',14,'FontWeight','bold');
  
  
%       s = sprintf('Performance before and after ACx lesion');
%t = title(s);
%set(t,'FontSize',14,'FontWeight','bold');
  
function [avg sem] = getavg(rat, task, date_range)
  fprintf(1,'Dates range from : %s to %s\n',date_range{1}, date_range{2});
  dates = get_files(rat, 'fromdate', date_range{1}, 'todate', date_range{2});
  
  mega_hh = [];
  mega_tr = [];
  for d = 1:rows(dates)
    date = dates{d};
    load_datafile(rat, task, date);
    fprintf(1,' %s ', date);
    
    tr = eval(['saved.' task '_n_done_trials']);
    hit_history = eval(['saved.' task '_hit_history']);
    hh = hit_history(find(~isnan(hit_history)));
    hh = hh(2:end); tr = tr-1; % forget first trial
    
    mega_hh = [mega_hh hh];
    mega_tr = [mega_tr tr];
    
    miniavg = (sum(hh)/tr); minisem = sqrt(tr * 0.25) ; 
  %  fprintf(1, 'avg = %2.1f%%, sem = %2.1f\n', sum(hh)/tr * 100, minisem);
  
  end;
   
 % fprintf(1,'Check: mega_hh has %i entries and mega_tr has %i\n', ...
 %         length(mega_hh), length(mega_tr));
  avg = (sum(mega_hh)/sum(mega_tr));
  sem = sqrt(0.25)/sqrt(sum(mega_tr));

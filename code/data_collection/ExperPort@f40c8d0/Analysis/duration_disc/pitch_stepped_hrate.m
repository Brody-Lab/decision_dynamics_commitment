function [] = pitch_stepped_hrate(varargin)
  
    pairs =  { ...
       'rat_set', {} ; ...
       'task', 'dual_discobj' ; ...
   };
  parse_knownargs(varargin, pairs);
  
  mega_perf = {};
  name_list = {};
  for r = 1:rows(rat_set)
     date_range = rat_set{r,2};
     rat = rat_set{r,1};
     name_list{r} = rat;
     
     perf = getavgs(rat, task, date_range);
     mega_perf{rows(mega_perf)+1} = perf;
     
     2;
  end;
  
  %mega_mean
  %bar(mega_mean, 1); hold on; 
  %errorbar(, [mean_pre mean_post], [sem_pre sem_post], [sem_pre ...
  %                    sem_post]); colormap summer;
 % barweb(mega_mean, mega_sem, 0.2, name_list, [],'Rat',['Avg. hit rate ' ...
  %                    '(%)']);
  
  specarray = {'.b','.r'};
  for r = 1:length(mega_perf)
    figure;
  %set(gcf,'Menubar','none','Toolbar','none');
     temp = mega_perf{r};             
      errorbar(temp(:,1), temp(:,2), temp(:,3), ...
               temp(:,3),specarray{r},'MarkerSize',10);
      
  line([0 1.1], [0.8 0.8], 'LineStyle',':','Color','r');
   set(gca,'XLim', [0 1.2], ...
'YLim', [0 1.3], 'YTick', 0:0.2:1, 'YTickLabel', 0:20:100);
    t = ylabel('Average hit rate (%)');
  set(t,'FontSize',14,'FontWeight','bold');
      t = xlabel('Octave separation');
  set(t,'FontSize',14,'FontWeight','bold');
  
  legend(name_list{r});
  end;
  
  
 
function [perf] = getavgs(rat, task, date_range)
  fprintf(1,'Dates range from : %s to %s\n',date_range{1}, date_range{2});
  dates = get_files(rat, 'fromdate', date_range{1}, 'todate', date_range{2});
  
  perf = []; % r-by-3 matrix
  % col1 : logdiff value
  % col2 : average hit rate
  % col3 : standard deviation
  
  buffer = {}; % m-by-3
      buffer_arrays = [];

  % col 1: logdiff
  % col 2: array of hits/misses
  % col 3: array of trials
  for d = 1:rows(dates)
    date = dates{d};
    load_datafile(rat, task, date);
    fprintf(1,' %s ', date);
    
    tr = eval(['saved.' task '_n_done_trials']);
    hit_history = eval(['saved.' task '_hit_history']);
    hh = hit_history(find(~isnan(hit_history)));
    hh = hh(2:end); tr = tr-1; % forget first trial 
    
    logdiffs = cell2mat(saved_history.ChordSection_logdiff);
    logdiffs = logdiffs(2:end);
    if length(logdiffs) == length(hh) + 1
      logdiffs = logdiffs(1:end-1);
    elseif length(logdiffs) ~= length(hh)
      error('Logdiff and hh length does not match!\n');
    end;
    
    unq = unique(logdiffs);
    
    for u = 1:length(unq)
    idx = find(logdiffs == unq(u));
    
    if rows(buffer) < 1,
      buffer{1,1} = unq(u); buffer{1,2} = []; buffer{1,3} = [];
      buffer_arrays(1) = unq(u);
      fprintf(1,'\tAdded %1.1f to cell #%i and array # %i\n', unq(u), rows(buffer), length(buffer_arrays));
     end;
      
    mega_idx = find(buffer_arrays == unq(u));
    
    if isempty(mega_idx)% create new row if needed
      buffer{rows(buffer)+1,1} = unq(u);
      buffer{rows(buffer),2} = [];
      buffer{rows(buffer),3} = [];
      buffer_arrays = [buffer_arrays unq(u)];
      mega_idx = rows(buffer);
      
      fprintf(1,'\tAdded %1.1f to cell #%i and array #%i\n', unq(u), rows(buffer), ...
              length(buffer_arrays));
    end;
    
    buffer{mega_idx,2} = [buffer{mega_idx,2} hh(idx)];
    buffer{mega_idx,3} = [buffer{mega_idx,3} length(idx)];
    end;
     
  end;
   
 % fprintf(1,'Check: mega_hh has %i entries and mega_tr has %i\n', ...
 %         length(mega_hh), length(mega_tr));
 
 for r = 1:rows(buffer)
   perf(r,1) = buffer{r,1};
   if perf(r,1) ~= buffer_arrays(r), error('Pitch mismatch!'); end;
   perf(r,2) = sum(buffer{r,2})/sum(buffer{r,3});
   perf(r,3) = sqrt(0.25)/sqrt(sum(buffer{r,3}));
  end;

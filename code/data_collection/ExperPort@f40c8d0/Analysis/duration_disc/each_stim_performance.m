function [pair_perf pair_idx] = each_stim_performance(rat, task, varargin)
  % function [pair_perf pair_idx] = each_stim_performance(rat, task, varargin)
  % Shows hit average for each stimulus pair per session.
  % Returns a matrix with this information.
  % Rows: Stimulus pairs
  % Columns: Sessions
  % The first column contains the values of the stimulus pair
  % The first row contains the date
  
   pairs =  { ...
      'from', '000000'; ...
      'to', '999999';  ...
       };
   
   parse_knownargs(varargin, pairs);
   
    dates = get_files(rat, 'fromdate', from, 'todate', to);
    pair_perf = {};
    
    pair_idx = []; % has logdiff and row # where info stored in pair_perf
  
   pair_ctr = 1;
   
 for d = 1:rows(dates)
   load_datafile(rat, task, dates{d});
   mp = saved.ChordSection_MP;
   logdiff = cell2mat(saved_history.ChordSection_logdiff); logdiff = logdiff(1:end-1);
   hh = eval(['saved.' task '_hit_history']);
   numtrials = eval(['saved_history.' task '_n_done_trials']);
   
   un = unique(logdiff);
   
   if d == 1
      for ld = 1:length(un)
        trials = find(logdiff == un(ld));
        if length(trials) > 14   % ignore if <= 14 trials on stim; not
                                 % enough data
                  pair_idx = [pair_idx; un(ld) pair_ctr];
        avg = mean(hh(trials));
        pair_perf{pair_ctr,d} = avg;        
        pair_ctr = pair_ctr+1;
        end;
      end;
     
   else
     for ld = 1:length(un)
          trials = find(logdiff == un(ld));
        if length(trials) > 14   % ignore if <= 14 trials on stim; not
          
          idx = find(pair_idx(:,1) == un(ld));
          if isempty(idx)  % make new index
             pair_idx = [pair_idx; un(ld) pair_ctr];
             idx = pair_ctr;
             pair_ctr = pair_ctr + 1;
          end;
          
          avg = mean(hh(trials));
          pair_perf{idx,d} = avg;
         
         
       end;
     end;
     
   end;
   
   end;
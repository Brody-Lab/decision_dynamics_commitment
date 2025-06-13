function [pair_count] = pie_stimpair(rat, task, varargin)
  
  % Shows distribution of a rat's session in different vanilla pairs.
  % To be used for a rat which is being moved through different pairs of
  % stimuli, and may be spending much longer at a given pair
  % (i.e. difficulty level) than at others. This script will show the
  % breakdown of # trials spent at each stimulus pair used in a given
  % session
    
  % Note: This is a aggregative script, as it shows breakdown across
  % several sessions.
  
   pairs =  { ...
      'from', '000000'; ...
      'to', '999999'; };
  parse_knownargs(varargin, pairs);
  
  dates = get_files(rat, 'fromdate', from, 'todate', to);
 
  % Information for each stimulus pair (each row)
  % Col 1: Pair idx (octave separation for pitch, log-distance for
  % duration)
  % Col 2: Sum # trials spent at that pair
  % Col 3: Sum left-side hit rate for that pair
  % Col 4: Sum right-side hit rate for that pair 
  pair_count = {};
  
  for d = 1:rows(dates)
  load_datafile(rat, task, dates{d});
  ld = cell2mat(saved_history.ChordSection_logdiff); ld = ld(2:end);
  numtrial = eval(['saved.' task '_n_done_trials']);
  sides = saved.SidesSection_side_list; sides = sides(1:numtrial);
  lrew = saved.RewardsSection_LeftRewards;
  rrew = saved.RewardsSection_RightRewards;
  
  u = unique(ld);
  for k = 1:length(u)
    if rows(pair_count) < 1,pair_count{1,1} = u(k); pair_count{1,2} = 0; ...
          pair_count{1,3} = []; pair_count{1,4} = []; end;
     
    idx = find(cell2mat(pair_count(:,1)) == u(k));
    if isempty(idx)   
      pair_count{end+1, 1} = u(k); 
      pair_count{end, 2} = 0; pair_count{end, 3} = []; 
      pair_count{end,4} = [];
      idx = rows(pair_count);
    end;  
    
    % here we get the left/right hit rates for this stimulus pair
    % and determine the bias during this stimulus pair
    pidx = find(ld == u(k));
    lft = sum(lrew(pidx))/sum(sides(pidx)); % left hit rate
    rgt = sum(rrew(pidx))/length(find(sides(pidx) == 0)); % right hit rate
    
    pair_count{idx,2} = pair_count{idx,2} + length(pidx);
    pair_count{idx,3} = [pair_count{idx,3}  lft];
    pair_count{idx,4} = [pair_count{idx,4}  rgt];
  end;
  
  end;
  
  % %%%%
  % Plot the results
  % %%%%
  
  figure;
  set(gcf,'Menubar','none','Toolbar','none');
  
  
  % Generate pie chart showing time spent in each stimulus pair(breakdown)
  h = pie(cell2mat(pair_count(:,2)));
  lbls = cell(rows(pair_count), 1);
  mp = (log2(1)+log2(15))/2;
  for k = 1:length(lbls), 
    hf = pair_count{k,1}/2;
   % lbls{k} = sprintf('%1.1f: %2.2f, %2.2f KHz\n (%s - L: %2.0f, R:
   % %2.0f)', ...
  %  pair_count{k,1}, 2^(mp-hf), 2^(mp+hf), get(h(2*k),'String'), ...
  %  mean(pair_count{k,3})*100, mean(pair_count{k,4})*100);
   lbls{k} = sprintf('%1.1f: %s', ...
   pair_count{k,1}, get(h(2*k),'String'));
  end;
  
  h = pie(cell2mat(pair_count(:,2)), lbls);
  for k = 1:length(h)/2, set(h(2*k), 'FontSize', 14); end;
  s = sprintf(['%s (%s to %s):\nBreakdown of time spent at different ' ...
               'octaves\n\n'], rat, from, to);
  title(s);
  
function [] = examine_stimpair(rat, task, index, varargin)
  
  % Shows performance statistics for a soon have had have had have had
  % have half given stimulus pair (indicated by
  % "index").
  % This script allows closer examination of a rat's performance at those
  % stimulus pairs where I suspect bias.
  
  % For pitch discrimination, the index is the octave separation of the
  % stimulus pair in question.
  % For duration discrimination, the index is the log-distance (base e)
  % between the two stimulus durations.
 
  % This script currently works solely for pitch discrimination
    
  pairs =  { ...
      'from', '000000'; ...
      'to', '999999'; };
  parse_knownargs(varargin, pairs);
  
  dates = get_files(rat, 'fromdate', from, 'todate', to);
  
  leftrates = [];
  leftstd = []; % stdev for the session
  rightrates = [];
  rightstd = [];
  for d = 1:rows(dates)
    load_datafile(rat, task, dates{d});
    
    ld = cell2mat(saved_history.ChordSection_logdiff);
    numtrial = eval(['saved.' task '_n_done_trials']);
    sides = saved.SidesSection_side_list;
    lrew = saved.RewardsSection_LeftRewards;
    rrew = saved.RewardsSection_RightRewards;
    
    % Use only those trials containing our stimpair of choice
    idx = find(ld == index);
    if ~isempty(idx)
      % Measure: left hit rate and right hit rate
      lrate = sum(lrew(idx))/sum(sides(idx));
      leftrates = [ leftrates lrate ];
      leftstd = [ leftstd sqrt(lrate*(1-lrate)) ];
      
      rrate = sum(rrew(idx))/length(find(sides(idx) == 0));
      rightrates =[ rightrates rrate ];
      rightstd = [ rightstd sqrt(rrate * (1-rrate))];
    end;   
    
  end;
  
  
  figure;
  set(gcf,'Menubar','none','Toolbar','none');
  s = sprintf('%s (%s to %s)\nPerformance for idx: %1.1f', rat, from, to, ...
              index);
  
  
  bar(leftrates, 0.1, 'b');
  hold on;
  
  % draw error bars
  
  plot(1:length(leftrates), leftrates, '-b');
 % errorbar(1:length(leftrates), leftrates, leftstd, leftstd);
  
  plot(1:length(leftrates), rightrates, '-hr', 'MarkerSize', 10);
 % errorbar(1:length(leftrates), rightrates, rightstd, rightstd);
  
  xlabel('Session #');
  ylabel('Left or right hit rate');
  legend({'Left', '', 'Right'}, 'Location', 'NorthWest');
  set(gca, 'Xlim', [ 0 length(dates)+1 ], 'YLim', [0 1.5]);
  title(s);

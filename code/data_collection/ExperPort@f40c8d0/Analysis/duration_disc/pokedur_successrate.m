function [] = pokedur_successrate(rat, task,varargin)
%function [] = pokedur_successrate(rat, task,date)
%
%  Analyses hit rate as a function of trial length for a given session
 pairs =  { ...
      'from', '000000'; ...
      'to', '999999'; };
  parse_knownargs(varargin, pairs);
  
  dates = get_files(rat, 'fromdate', from, 'todate', to);
  
  mega_trial_length = [];
  mega_hh = [];
  mega_sides = [];
  
  for d = 1:rows(dates)
  date = dates{d};
    load_datafile(rat, task, date);
  
  pre = saved.VpdsSection_vpds_list;
  post = saved.ChordSection_prechord_list;
  sides = saved.SidesSection_side_list;
  
  tr = eval(['saved.' task '_n_done_trials']);
  hit_history = eval(['saved.' task '_hit_history']);
  hh = hit_history(find(~isnan(hit_history)));
  
  sides =sides(1:length(hh));
  pre = pre(1:length(hh));
  post = post(1:length(hh));
  
  stim = zeros(size(sides)); stim(find(sides > 0)) = 0.3; 
  stim(find(sides < 1)) = 0.7;
  trial_length = stim + pre + post;
  
  mega_trial_length = [mega_trial_length trial_length];
  mega_sides = [ mega_sides sides ];
  mega_hh = [ mega_hh hh ] ;
  
  end;
  
  trial_length = mega_trial_length;
  hh = mega_hh;
  sides = mega_sides;
  
  binned_hits = [];
  idx_crosschk = [];
  
  figure;
  set(gcf,'Menubar','none','Toolbar','none');
  numbins = 10;
  binwidth = (max(trial_length) - min(trial_length)) / numbins;
  [n,x] = hist(trial_length,numbins);
  for k = 1:numbins
    idx = [];
    if k == 1,
      idx = find(trial_length < x(k));
    end;  
        idx = [ idx ...
                find(trial_length > (x(k)-(binwidth/2)) & trial_length <= ...
                     (x(k)+(binwidth/2)))];
       idx = unique(idx);
    idx_crosschk = [ idx_crosschk  length(idx)];
    hitbin = hh(idx);
    
    binned_hits = [binned_hits mean(hitbin);];
  end;
  
  % Get data showing the best the rat could do by using poke duration
% $$$   [p_short p_long threshes] = poke_duration_performance(0.2, 0.6, 0.1,0.3, 0.3, ...
% $$$                                                   0.7, 'return_pdfs',1);
% $$$   predictedperf = (p_short + p_long)/2; % assume 50/50 left and right
% $$$                                         % side trials
% $$$                                                  
  
  
  % Plotting begins
  subplot(2,1,1);
  hist(trial_length,numbins);
  xlabel('Cin duration (seconds)');
  ylabel('# trials');
   s = sprintf('%s: %s (%s to %s)\nBinned trial duration', make_title(rat), ...
               make_title(task), from, to);
title(s);
  
  subplot(2,1,2);
  plot(x, binned_hits,'.b','MarkerSize',10);
  hold on;
  line([min(trial_length) max(trial_length)], [0.8 0.8], 'LineStyle',':', 'Color','r');
  xlabel('Cin duration (seconds)');
  ylabel(sprintf('Avg hit rate for trials\n with above binned length'));
  set(gca,'YLim',[0.7 1.1]);
 
  
   s = sprintf('%s: %s (%s)\nHit rate for binned trial duration segments', make_title(rat), make_title(task), date);
title(s);

% $$$ subplot(3,1,3);
% $$$   plot(threshes,predictedperf,'.r');
% $$$   
% $$$   n
% $$$   idx_crosschk
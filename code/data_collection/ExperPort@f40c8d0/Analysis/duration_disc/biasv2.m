function [] = sessionperf(rat, task, date, varargin)
    pairs = { ... 
      'third', 'pre_go' ; ...
      'showloc', 1 ; ...
      'lookahead', 1; ...  % rate computed by look-ahead or look-back?
      };
  parse_knownargs(varargin, pairs);
  
  if strcmpi(task, 'd'), task = 'duration_discobj';
  elseif strcmpi(task, 'p'), task = 'dual_discobj';
  end;
  
  load_datafile(rat, task, date);
  
  side = saved.SidesSection_side_list;
  hh = eval(['saved.' task '_hit_history;']);
  hh = hh(find(~isnan(hh)));
  side = side(1:length(hh));
  
  winsize = 15;
  
  lrate = [];
  rrate = [];
  
  if lookahead > 0,
  for k = 1:(length(hh)-winsize)
    idx = k:(k+winsize)-1;
    mini_s = side(idx); mini_h = hh(idx);
    leftidx = find(mini_s > 0); rightidx = find(mini_s < 1);
    lrate = [lrate sum(mini_h(leftidx))/length(leftidx)];
    rrate = [rrate sum(mini_h(rightidx))/length(rightidx)];
  end;
  else
    for k = 1:length(hh)
      idx = max(k-winsize, 1):k;
       mini_s = side(idx); mini_h = hh(idx);
    leftidx = find(mini_s > 0); rightidx = find(mini_s < 1);
    if length(leftidx) > 0,
      lrate = [lrate sum(mini_h(leftidx))/length(leftidx)];
    else 
      lrate = [lrate 0];
    end;
    if length(rightidx) > 0,
      rrate = [rrate sum(mini_h(rightidx))/length(rightidx)];
    else 
      rrate = [rrate 0];
    end;
    end;
    end;
  
  figure;
   nump = 3; % no. plots
   ht = 680;
  % if strcmpi(task(1:3), 'dua'), nump = 2; ht = 680 * (2/3); end;
   
   
   set(gcf,'Menubar','none', 'Toolbar','none', 'Position', [200 100 750 ht]);
  
   % Plot 1: Hit rates -----------
  subplot(nump,1,1); 
  v = cell2mat(saved_history.ChordSection_vanilla_on);
  if sum(v) > 1,
    plot_logdiff_perf(rat, task, date, 'nofig', 1, 'bout_size',winsize);
  else
    hit_rates(rat, task, date, 'bout_size', winsize);
    end;
  set(gca, 'XTick', [0:20:length(hh)-winsize]);
  
  % Plot 2: Bias -----------------
  subplot(nump,1,2);
  s = sprintf('%s: %s: (%s)\nSide Bias: Look-ahead sliding window (%i trials)', ...
              make_title(rat), make_title(task), date, winsize);
% $$$   subplot(2,1,1);
% $$$   plot(1:length(side), side, '.b');
% $$$   set(gca, 'YTick', [0 1], 'YTickLabel', {'Right', 'Left'}, 'YLim', ...
% $$$            [-1 2]);                     
% $$$   subplot(2,1,2);
  blah = plot(1:length(lrate), lrate, '-b', 1:length(rrate), rrate, ...
              '-r');
  set(blah(1), 'Color', [0.6 0.4 0.8]);
  xlabel(sprintf('Trial (i to i+%i)', winsize));
  ylabel('Hit rate');
  legend({'Left', 'Right'}, 'Location', 'SouthWest');
  title(s);
  set(gca, 'YLim', [0.5 1], 'XTick', [0:20:length(hh)-winsize]);
  
  % Plot 3: Whatever your heart desires ----------
  if nump == 3,
    subplot(3,1,3);
    if strcmpi(third, 'pre_go')
      pre_go(rat, task,date, 'newfig',0, 'from', winsize+1);
    elseif strcmpi(third, 'presound')
      presound_increment(rat, task, date, 'newfig', 0, 'from', winsize+1);
    elseif strcmpi(third, 'lprob')
      lprob(rat, task, date, 'newfig', 0, 'from', winsize+1);
    elseif strcmpi(third, 'bias'),
      temp = lrate - rrate;
      goodrun = zeros(size(temp)); goodrun(1) = 1;
      notbiased = temp < 0.2 & temp > -0.2;
      for k=2:length(temp)
        if notbiased(k),
          if ~notbiased(k-1)
            goodrun(k) = 1;
          else
            goodrun(k) = goodrun(k-1) +1;
          end;        
        end;
      end;
      
    %  plot(1:length(goodrun), goodrun, '-b');
    plot(1:length(temp), temp, '-b');
    hold on;
    line([1 length(temp)], [0.2 0.2], 'LineStyle',':', 'Color','r');
    line([1 length(temp)], [-0.2 -0.2], 'LineStyle',':', 'Color','r');
   
      set(gca,'YLim', [-0.5 0.5]);
      xlabel('Trial #'); ylabel('(Hit rate)L - (Hit rate)R');
      set(gca,'XTick', 0:20:length(temp));
      s = sprintf('%s: %s (%s)\nBias (trial-by-trial)', make_title(rat), ...
                  make_title(task), date);    
      title(s);
      end;
  end;
  
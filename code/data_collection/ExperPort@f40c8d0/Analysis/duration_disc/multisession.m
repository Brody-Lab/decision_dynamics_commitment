function [] = multisession(rat,task,from,to,varargin)
%  runs sessionperf.m  for given rat and task, generating one graph
%  for each day  in the range of dates
  
  pairs = { ... 
      'third', 'pre_go' ; ...
      'showloc', 1 ; ...
      'lookahead', 1; ...  % rate computed by look-ahead or look-back?
      'good', 0.8; ...
      'multiday', 0; ...
      };
  
dates = get_files(rat,'fromdate', from,'todate',to);
parse_knownargs(varargin, pairs);
  
mega_lrate = [];
mega_rrate = [];
mega_binned = [];
breakpoints = []; t = 0;
for x = 1:rows(dates)
  date = dates{x};
  
  [a, b, last_win, binned] = hit_rates(rat, task, date);
  mega_binned = [mega_binned binned];
  breakpoints = [breakpoints t+last_win];  
  t = t+last_win;
end;

  x = 1:last_win;
    xx = 1:0.01:t;
    yy = spline(x, mega_binned, xx);
    l = plot(x,mega_binned, '-k');
    line([1 last_win], [good good], 'LineStyle','--','Color','b');
    line([1 last_win], [0.5 0.5], 'LineStyle', '--', 'Color', 'r');
    if multiday > 0,
        text(last_win, good, sprintf('%2.1f%%', good*100), 'Color','b', 'FontAngle','italic');
        text(last_win, 0.5, sprintf('%2.1f%%', 0.5*100), 'Color','r', 'FontAngle','italic');
    end;

function [pair_perf pair_idx] = plot_pair_perf(rat, task, varargin)
  % function [pair_perf pair_idx] = plot_pair_perf(rat, task, varargin)
  % Plots a performance vs. session graph for each stimulus pair that 
  % a rat has discriminated in the sessions requested
  % Performance for each stimulus pair is plotted as a distinct series
  % e.g.
  % If the animal has discriminated stimuli at log-differences of 0.3,
  % 0.4, and 0.5 from Jan 12 - Jan 15,
  % calling the function from 060112 to 060115 will generate a plot
  % with three lines, each showing the average performance as a function
  % of session # for a particular stimulus pair.
    
  pairs = { 'from', '000000' ; ...
            'to', '999999'; ...
            'filter_rule', 'pair_idx(r,1) < 0.7'; 
            };
  parse_knownargs(varargin, pairs);
  
  
  [pair_perf pair_idx] = each_stim_performance(rat, task, 'from', from, ...
                                               'to', to);
  
  figure; 
  set(gcf,'Menubar','none','Toolbar', 'none', 'Position', [200 200 400 400]);
 s = sprintf('%s: Pair Performance for %s - %s', rat, from, to);

 
 for r = 1:rows(pair_perf)
   if pair_idx(r,1) < 1.5 & pair_idx(r,1) > 0.2
   x = cell2mat(pair_perf(r,:));
   x
   l = plot(1:length(x), x, '.-');
   set(l, 'Color', rand(1,3), 'LineWidth', 3);
   hold on;
   end;
 end;
 
 lgd = {}; ctr = 1;
 for k = 1:rows(pair_idx)
     fprintf(1, 'Got %s\n', num2str(pair_idx(k,1)));
   if pair_idx(k,1) < 1.5 & pair_idx(k,1) > 0.2
       fprintf(1, 'Got %s\n', num2str(pair_idx(k,1)));
   lgd{ctr} = num2str(pair_idx(k,1));
   ctr = ctr+1;
   end;
 end; 
 
 line([1 cols(pair_perf)], [0.8 0.8], 'LineStyle', '-', 'Color','r');
 legend(lgd,'Location', 'SouthWest');
 set(gca, 'YLim', [0 1]);

  title(s);
 
  
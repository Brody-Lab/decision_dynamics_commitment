function [lp] = get_lprob(ratname, task, date, varargin)
  
  pairs = { ...
      'from', 1 ; ...
      'newfig', 1 ; ...
      };
  parse_knownargs(varargin, pairs);
  
  load_datafile(ratname, date);
  lp = cell2mat(saved_history.SidesSection_LeftProb);
  
  if newfig > 0, figure; end;
  plot(from:length(lp), lp(from:end), '-b');
  set(gca,'XLim', [from max(2,length(lp))],'YLim',[0 1],'YTick', [0 0.2 0.5 0.8 1]);
  
  s = sprintf('%s: %s (%s)\n Value of LProb', make_title(ratname), make_title(task), ...
              date);
t =  title(s);
set(t,'FontSize',14);
  xlabel('Trial #');
  ylabel('LProb (from 0 to 1)');
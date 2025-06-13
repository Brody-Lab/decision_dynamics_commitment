function [] = pre_go(rat, task, date, varargin)
  
  pairs = { ...
      'newfig', 1; ...
      'from', 1; ... % plot points from this trial #; to allow
                     % compatibility with lookahead averaging plots
      };
  parse_knownargs(varargin, pairs);
  
    if strcmpi(task, 'd'), task = 'duration_discobj';
  elseif strcmpi(task, 'p'), task = 'dual_discobj';
  end;
  

load_datafile(rat, task, date);

mingo = cell2mat(saved_history.ChordSection_Min_2_GO);
maxgo = cell2mat(saved_history.ChordSection_Max_2_GO);

if newfig > 0, figure; end;
set(gcf,'Menubar', 'none','Toolbar','none');
k = plot(from:length(mingo), mingo(from:end), '-r', from:length(maxgo), ...
     maxgo(from:end), '.b'); 
set(k(1), 'Color', [0.5 0.5 0]); set(k(2), 'Color', [0 0.4 0]);
set(gca,'XLim', [from length(maxgo)]);

s = sprintf('%s: %s (%s)\nPre-GO time', make_title(rat), make_title(task), date);
title(s);
legend({'Min2GO', 'Max2GO'}, 'Location','SouthEast'); 
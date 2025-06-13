function [] = raw_loc(rat, task, date)
  % Plots GO localisation and Tone localisation values for entire session
  
  load_datafile(rat, task, date);
  
  go_loc = saved_history.ChordSection_GO_Loc;
  tone_loc = saved_history.ChordSection_Tone_Loc;
  
  goloc = zeros(length(go_loc), 1);
  toneloc = zeros(length(tone_loc), 1);
  
  idx = find(strcmpi(go_loc, 'on'));
  goloc(idx) = 1;
  idx = find(strcmpi(tone_loc, 'on'));
  toneloc(idx) = 1;
  
  figure; set(gcf,'Menubar','none','Toolbar','none');
  plot(1:length(goloc), goloc, '.g', 1:length(toneloc), toneloc, '-b');
  legend({'GO Loc', 'Tone Loc'}, 'Location', 'NorthWest');
  set(gca, 'YLim', [-1 2], 'YTickLabel', {'', 'off', 'on', ''}, 'YTick', ...
           -1:1:2);
  
  s = sprintf('%s: %s (%s)\nPre-GO time', make_title(rat), make_title(task), date);
title(s);
  
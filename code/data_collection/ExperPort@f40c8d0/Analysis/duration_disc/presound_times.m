function [] = presound_times(rat,task, date)
% plots pre-sound time for the task  
  load_datafile(rat, task,date);
  
  pst = saved.VpdsSection_vpds_list;
  t = eval(['saved.' task '_n_done_trials;']);
  minnie = cell2mat(saved_history.VpdsSection_MinValidPokeDur);
  maxie = cell2mat(saved_history.VpdsSection_MaxValidPokeDur);
  pst = pst(1:t);
  
  figure;
set(gcf,'Position', [100 100 650 215], 'Menubar', 'none','Toolbar','none')
plot(1:length(pst), pst, '.g', 1:length(minnie), minnie, '-r', 1:length(maxie), ...
     maxie, '-b');
set(gca,'XLim', [1 t]);
ylabel('Pre-sound time (s)');
xlabel('Trial #');
s = sprintf('%s: %s (%s)\nPre-sound time', make_title(rat), make_title(task), date);
title(s);
legend({'pst', 'MinPST', 'MaxPST'}, 'Location','SouthEast'); 
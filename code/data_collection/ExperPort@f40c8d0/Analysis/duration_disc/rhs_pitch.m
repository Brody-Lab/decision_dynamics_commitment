function [] = rhs_pitch(rat, date);
  
  load_datafile(rat, 'dual_discobj',date);
  
  figure;
  set(gcf,'Menubar', 'none','Toolbar','none','Position',[200 200 900 300]);
  % Plot1 : RHS Duration
  subplot(1,2,1);
  d2 = cell2mat(saved_history.ChordSection_Tone_Dur_R);
  plot(1:length(d2), d2);
  ylabel('RHS duration (seconds)'); xlabel('Trial #');
  title(sprintf('%s: %s (%s)\nRHS Tone Duration', make_title(rat), ...
                make_title('dual_discobj'), date));
  
 
  % Plot2: Cue SPL
  subplot(1,2,2);
  spl = cell2mat(saved_history.ChordSection_Tone_SPL_L);
  gospl = cell2mat(saved_history.ChordSection_SoundSPL_L);
  plot(1:length(spl), spl, 'or', 1:length(gospl), gospl, '-g');
  legend({'Tone SPL', 'GO SPL'},'Location', 'SouthEast');
  ylabel('Sound SPL'); xlabel('Trial #');
  title(sprintf('%s: %s (%s)\nCue & GO signal intensity', make_title(rat), ...
                make_title('dual_discobj'), date));
  
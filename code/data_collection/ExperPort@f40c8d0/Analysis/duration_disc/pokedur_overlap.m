function [] = pokedur_overlap(minPre, maxPre, minpreGO, maxpreGO,stim1,stim2)
  
  % Determines the total poke duration for short (300ms) and long (800ms)
  % sound stimuli in the protocol duration_discobj.
  % When given a range of times for the variable pre- and post- cue
  % silent periods, will graphically show the range of poke durations.
  % This tool can be used to determine pre- and post- ranges that will 
  % overlap the poke durations for both sounds
    
  % Results:
  % Find that (0.15-0.6) pre and (0.1-0.2) lead to an overlap of 100ms in
  % the two ranges.
  % Tighter overlap would lead either to:
  % - increasing post-cue time, not favoured because it taxes animal's
  % patience
  % - minimising pre-sound time, which may confound whether animal times
  % the sound or the poke duration.
    
  % Other findings:
  % Cannot set pre-sound time to 0.1-0.2 because poke duration dominated by
  % cue length  
  % Cannot set pre-sound to (0,0.6) because there is no overlap in this
  % case.
    
  
%  stim1 = 0.3;
%  stim2 = 0.8;
  
  
  shortRange = [ stim1 + minPre + minpreGO, stim1 + maxPre + maxpreGO];
  longRange = [ stim2 + minPre + minpreGO, stim2 + maxPre + maxpreGO];
  
  
  figure;
  set(gcf,'Position', [200 200 500 100],'Menubar','none','Toolbar','none');
  line([shortRange(1) shortRange(2)], [1 1], 'Color', 'r');hold on;
  line([longRange(1) longRange(2)], [2 2], 'Color', 'b');
  set(gca, 'XLim', [0 2], 'YLim', [-1 3]);
  title('Depiction of total poke length for each stimulus');
  
  legend({num2str(stim1), num2str(stim2)});
  
  
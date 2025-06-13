function [] = show_pitchpairs(rat, varargin)
  
  pairs = { ...
      'from', '000000'; ...
    'to', '999999' ; ...
      };
  
  parse_knownargs(varargin, pairs);
  
  date_set = get_files(rat, 'fromdate', from, 'todate', to);
 
  for d = 1:rows(date_set)
    load_datafile(rat, 'dual_discobj', date_set{d});
    n = saved.dual_discobj_n_done_trials;
    t1 = cell2mat(saved_history.ChordSection_Tone_Freq_L); t1 = t1(1:n);
    t2 = cell2mat(saved_history.ChordSection_Tone_Freq_R); t2 = t2(1:n);
    
    figure;
    set(gcf,'Toolbar','none','Menubar','none');
    plot(1:n, t1, '.b', 1:n, t2, '.g');
    legend({'Left', 'Right'});
    title(date_set{d});
    
    datacursormode on;
    
    
  end;
function [m s] = make_webers_p()
  
  v_attila = psychometric_graphall('attila','dual_discobj','from', ...
                                   '061027','to','061102','pitches',1);  
  
  v_attila = cell2mat(v_attila(2:end,2));
  
  mp = sqrt(1*15); v_attila = v_attila * mp;
  m = mean(v_attila);
  s = std(v_attila);
   
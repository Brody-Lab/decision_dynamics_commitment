function [v_ghazni v_timur v_babur v_akbar] = make_webers()
  
  v_ghazni = psychometric_graphall('ghazni','duration_discobj','from', ...
                                   '060911','to','060918');
  v_timur = psychometric_graphall('timur_lang','duration_discobj','from', ...
                                   '060911','to','060920');
  v_babur = psychometric_graphall('Babur','duration_discobj','from', ...
                                  '061020','to','061030');
  v_akbar = psychometric_graphall('Akbar','duration_discobj','from', ...
                                  '061023','to','061026');
  

  v_ghazni = v_ghazni(2:end,2);
  v_timur = v_timur(2:end,2);
  v_babur = v_babur(2:end,2);
  v_akbar = v_akbar(2:end,2);
  
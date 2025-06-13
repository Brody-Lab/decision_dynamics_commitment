% [sma] = initialize_full_trial_structure(sma)

% Written by Carlos Brody May 2007

function [sma] = initialize_full_trial_structure(sma)
   
   sma = add_state(sma, 'name', 'state_0', ...
                   'default_statechange', 40, 'self_timer', 0.0001);
   
   for i=1:34,
      sma = add_state(sma, 'default_statechange', 35, 'self_timer', 0.001);
   end;
   
   sma = add_state(sma, 'name', 'check_next_trial_ready', ...
                   'default_statechange', 1, 'self_timer', 0.0001);
   
   for i=1:4,
      sma = add_state(sma, 'default_statechange', 35, 'self_timer', 1);
   end;
   
   
   sma.pre35_curr_state     = 1;
   sma.full_trial_structure = 1;
   
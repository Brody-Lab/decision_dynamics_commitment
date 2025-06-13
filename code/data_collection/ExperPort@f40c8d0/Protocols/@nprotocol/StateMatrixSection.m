function  [] =  StateMatrixSection(obj, action)

% global center1water;
global centervalve; %center1led;
global leftwater; %left1water;
% global left1led;        
global rightwater; %right1water;       
% global right1led;     
global shock;                       
global laser;

GetSoloFunctionArgs;

switch action
  case 'init',
    StateMatrixSection(obj, 'next_trial');
    
  case 'next_trial',
    sma = StateMachineAssembler('full_trial_structure');
    cLed_time = value(centerLed); 
    lValve_time = value(leftValve);
    rValve_time = value(rightValve);
    cPoke_time = value(cpokeTime);
    lPoke_time = value(lpokeTime);
    rPoke_time = value(rpokeTime);
    shock_prob = value(shockProp);
    lr_shock = value(LRshock);
    laser_prob = value(laserProp);
    lr_laser = value(LRlaser);
    a = rand();
    b = shock_prob;
    c = laser_prob;
    start_shock = value(shockStart_after);    %n_done_trials
    
    if laser_prob == 0 && shock_prob ~= 0 && a <= b && strcmp(lr_shock, 'Left') == 1 && n_done_trials >= start_shock 
        fprintf('\n-----------\nNext Trial\n-----------\nLaser = OFF\nShock = ON\nSide = LEFT\nProbability = %f\n-----------\n\n', ...
            shock_prob);
        sma = add_state(sma, 'default_statechange', 'waiting_4_cin', 'self_timer', 0.001);
        sma = add_state(sma, 'name', 'waiting_4_cin', ...
          'input_to_statechange', {'Cin', 'waiting_4_Cout'});
        sma = add_state(sma, 'name', 'waiting_4_cout', 'self_timer', cPoke_time, ...
          'input_to_statechange', {'Cout', 'check_next_trial_ready', 'Tup','center_light_on'});
        sma = add_state(sma, 'name', 'center_light_on', 'output_actions', {'DOut', centervalve}, ... 
          'self_timer', cLed_time, 'input_to_statechange', {'Tup', 'waiting_4_both'});
        sma = add_state(sma, 'name', 'waiting_4_both', ...
          'input_to_statechange', {'Lin', 'wait_4_leftvalveon', 'Rin', 'wait_4_rightvalveon'});
        sma = add_state(sma, 'name', 'wait_4_leftvalveon', 'self_timer', lPoke_time, ...
          'input_to_statechange', {'Tup', 'deliver_water_shock_left'});
        sma = add_state(sma, 'name', 'wait_4_rightvalveon', 'self_timer', rPoke_time, ...
          'input_to_statechange', {'Tup', 'deliver_water_right'});
        sma = add_state(sma, 'name', 'deliver_water_shock_left', 'output_actions', {'DOut', leftwater + shock}, ...
          'self_timer', lValve_time, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        sma = add_state(sma, 'name', 'deliver_water_right', 'output_actions', {'DOut', rightwater}, ...
          'self_timer', rValve_time, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
    elseif (laser_prob == 0 && shock_prob ~= 0 && a <= b && strcmp(lr_shock, 'Right') == 1) && n_done_trials >= start_shock 
        fprintf('\n-----------\nNext Trial\n-----------\nLaser = OFF\nShock = ON\nSide = RIGHT\nProbability = %f\n-----------\n\n', ...
            shock_prob);
        sma = add_state(sma, 'default_statechange', 'waiting_4_cin', 'self_timer', 0.001);
        sma = add_state(sma, 'name', 'waiting_4_cin', ...
          'input_to_statechange', {'Cin', 'waiting_4_cout'});
        sma = add_state(sma, 'name', 'waiting_4_cout', 'self_timer', cPoke_time, ...
          'input_to_statechange', {'Cout', 'check_next_trial_ready', 'Tup','center_light_on'});
        sma = add_state(sma, 'name', 'center_light_on', 'output_actions', {'DOut', centervalve}, ... 
          'self_timer', cLed_time, 'input_to_statechange', {'Tup', 'waiting_4_both'});
        sma = add_state(sma, 'name', 'waiting_4_both', ...
          'input_to_statechange', {'Lin', 'wait_4_leftvalveon', 'Rin', 'wait_4_rightvalveon'});
        sma = add_state(sma, 'name', 'wait_4_leftvalveon', 'self_timer', lPoke_time, ...
          'input_to_statechange', {'Tup', 'deliver_water_left'});
        sma = add_state(sma, 'name', 'wait_4_rightvalveon', 'self_timer', rPoke_time, ...
          'input_to_statechange', {'Tup', 'deliver_water_shock_right'});
        sma = add_state(sma, 'name', 'deliver_water_left', 'output_actions', {'DOut', leftwater}, ...
          'self_timer', lValve_time, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        sma = add_state(sma, 'name', 'deliver_water_shock_right', 'output_actions', {'DOut', rightwater + shock}, ...
          'self_timer', rValve_time, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
    elseif (laser_prob ~= 0 && shock_prob == 0 && a <= c && strcmp(lr_laser, 'Left') == 1)
        fprintf('\n-----------\nNext Trial\n-----------\nLaser = ON\nShock = OFF\nSide = LEFT\nProbability = %f\n-----------\n\n', ...
            laser_prob);
        sma = add_state(sma, 'default_statechange', 'waiting_4_cin', 'self_timer', 0.001);
        sma = add_state(sma, 'name', 'waiting_4_cin', ...
          'input_to_statechange', {'Cin', 'waiting_4_cout'});
        sma = add_state(sma, 'name', 'waiting_4_cout', 'self_timer', cPoke_time, ...
          'input_to_statechange', {'Cout', 'check_next_trial_ready', 'Tup','center_light_on'});
        sma = add_state(sma, 'name', 'center_light_on', 'output_actions', {'DOut', centervalve}, ... 
          'self_timer', cLed_time, 'input_to_statechange', {'Tup', 'waiting_4_both'});
        sma = add_state(sma, 'name', 'waiting_4_both', ...
          'input_to_statechange', {'Lin', 'wait_4_leftvalveon', 'Rin', 'wait_4_rightvalveon'});
        sma = add_state(sma, 'name', 'wait_4_leftvalveon', 'self_timer', lPoke_time, ...
          'input_to_statechange', {'Tup', 'deliver_water_left'});
        sma = add_state(sma, 'name', 'wait_4_rightvalveon', 'self_timer', rPoke_time, ...
          'input_to_statechange', {'Tup', 'deliver_water_right'});
        sma = add_state(sma, 'name', 'deliver_water_left', 'output_actions', {'DOut', leftwater + laser}, ...
          'self_timer', lValve_time, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        sma = add_state(sma, 'name', 'deliver_water_right', 'output_actions', {'DOut', rightwater}, ...
          'self_timer', rValve_time, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
    elseif (laser_prob ~= 0 && shock_prob == 0 && a <= c && strcmp(lr_laser, 'Right') == 1)
        fprintf('\n-----------\nNext Trial\n-----------\nLaser = ON\nShock = OFF\nSide = RIGHT\nProbability = %f\n-----------\n\n', ...
            laser_prob);
        sma = add_state(sma, 'default_statechange', 'waiting_4_cin', 'self_timer', 0.001);
        sma = add_state(sma, 'name', 'waiting_4_cin', ...
          'input_to_statechange', {'Cin', 'waiting_4_cout'});
        sma = add_state(sma, 'name', 'waiting_4_cout', 'self_timer', cPoke_time, ...
          'input_to_statechange', {'Cout', 'check_next_trial_ready', 'Tup','center_light_on'});
        sma = add_state(sma, 'name', 'center_light_on', 'output_actions', {'DOut', centervalve}, ... 
          'self_timer', cLed_time, 'input_to_statechange', {'Tup', 'waiting_4_both'});
        sma = add_state(sma, 'name', 'waiting_4_both', ...
          'input_to_statechange', {'Lin', 'wait_4_leftvalveon', 'Rin', 'wait_4_rightvalveon'});
        sma = add_state(sma, 'name', 'wait_4_leftvalveon', 'self_timer', lPoke_time, ...
          'input_to_statechange', {'Tup', 'deliver_water_left'});
        sma = add_state(sma, 'name', 'wait_4_rightvalveon', 'self_timer', rPoke_time, ...
          'input_to_statechange', {'Tup', 'deliver_water_right'});
        sma = add_state(sma, 'name', 'deliver_water_left', 'output_actions', {'DOut', leftwater}, ...
          'self_timer', lValve_time, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        sma = add_state(sma, 'name', 'deliver_water_right', 'output_actions', {'DOut', rightwater + laser}, ...
          'self_timer', rValve_time, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
    elseif (laser_prob == 0 && shock_prob ~= 0 && strcmp(lr_shock, 'null') == 1) 
        fprintf('\n-----------\nWHAT?!?!?! SHOCK BOTH SIDES?!?!?!?!\n-----------\n\n');    
    elseif (laser_prob ~= 0 && shock_prob == 0 && strcmp(lr_laser, 'null') == 1)
        fprintf('\n-----------\nDO YOU WANT TO LASER RANDOMLY AND HOPE TO GET SOME KIND OF RESULT ANYWAY?!?!?!\n-----------\n\n');
    elseif (laser_prob ~= 0 && shock_prob ~= 0)
        fprintf('\n-----------\nShok AND Laser?!??!\n-----------\n\n');
    elseif (shock_prob == 0 && laser_prob == 0) && (~strcmp(lr_shock, 'null') || ~strcmp(lr_laser, 'null'))
        fprintf('\n-----------\nYou don''t need to chose sides if the probability is 0!\nDUH!!\n-----------\n\n');
    else
        fprintf('\n-----------\nNext Trial\n-----------\nFree Water!!\n-----------\n\n')
        sma = add_state(sma, 'default_statechange', 'waiting_4_cin', 'self_timer', 0.001);
        sma = add_state(sma, 'name', 'waiting_4_cin', ...
          'input_to_statechange', {'Cin', 'waiting_4_cout'});
        sma = add_state(sma, 'name', 'waiting_4_cout', 'self_timer', cPoke_time, ...
          'input_to_statechange', {'Cout', 'check_next_trial_ready', 'Tup','center_light_on'});
        sma = add_state(sma, 'name', 'center_light_on', 'output_actions', {'DOut', centervalve}, ... 
          'self_timer', cLed_time, 'input_to_statechange', {'Tup', 'waiting_4_both'});
        sma = add_state(sma, 'name', 'waiting_4_both', ...
          'input_to_statechange', {'Lin', 'wait_4_leftvalveon', 'Rin', 'wait_4_rightvalveon'});
        sma = add_state(sma, 'name', 'wait_4_leftvalveon', 'self_timer', lPoke_time, ...
          'input_to_statechange', {'Tup', 'deliver_water_left'});
        sma = add_state(sma, 'name', 'wait_4_rightvalveon', 'self_timer', rPoke_time, ...
          'input_to_statechange', {'Tup', 'deliver_water_right'});
        sma = add_state(sma, 'name', 'deliver_water_left', 'output_actions', {'DOut', leftwater}, ...
           'self_timer', lValve_time, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        sma = add_state(sma, 'name', 'deliver_water_right', 'output_actions', {'DOut', rightwater}, ...
            'self_timer', rValve_time, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
    end;
  
    
    
    % MANDATORY LINE:
    dispatcher('send_assembler', sma, {'waiting_4_cin'});
    % I decided to call 'prepare next trial' during state 1 
    
  case 'reinit',

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);

    % Reinitialise at the original GUI position and figure:
    feval(mfilename, obj, 'init');
    
  otherwise,
    warning('%s : %s  don''t know action %s\n', class(obj), mfilename, action); %#ok<WNTAG>
end;

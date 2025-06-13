%function [ output_args ] = StateMatrixSection_comented( input_args )
%STATEMATRIXSECTION_COMENTED Summary of this function goes here
%   Detailed explanation goes here

% Typical section code-- this file may be used as a template to be added 
% on to. The code below stores the current figure and initial position when
% the action is 'init'; and, upon 'reinit', deletes all SoloParamHandles 
% belonging to this section, then calls 'init' at the proper GUI position 
% again.


% [x, y] = YOUR_SECTION_NAME(obj, action, x, y)
%
% Section that takes care of YOUR HELP DESCRIPTION
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'      To initialise the section and set up the GUI
%                        for it
%
%            'reinit'    Delete all of this section's GUIs and data,
%                        and reinit, at the same position on the same
%                        figure as the original section GUI was placed.
%
% x, y     Relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI. 
%


function  [] =  StateMatrixSection(obj, action)

global center1water;
global center1led;
global left1water;
global left1led;        %declare here the globals that you want the stateMatrixSection 
global right1water;       %to have access to, usually these are declared in the Settings_Custom.conf
global right1led;     %Declare var's in Protocol file as globals and initialize them, the
global shock;                         %GetSoloFunctionArgs should get them!!
global laser;                   %Hilighted globals are not in use...
%global leftValve;       
%global rightValve;      
%global right1led;       
%global left1water;      
%global right1water;

GetSoloFunctionArgs;

%

switch action
  case 'init',
    StateMatrixSection(obj, 'next_trial');
    
  case 'next_trial',
%Declare != state matrixs here!! if something, this sma, if something else
%then this other, if even somthing else, use this sma, while somthing, for
%something, etc etc etc you get the pic.
    sma = StateMachineAssembler('full_trial_structure');
           
    % DOut 00 -> null;
    % DOut 01 -> DIO 0;
    % DOut 02 -> DIO 1;
    % DOut 03 -> DIO 0 + DIO 1;
    % DOut 04 -> DIO 2;
    % DOut 05 -> DIO 0 + DIO 2;
    % DOut 06 -> DIO 1 + DIO 2;
    % DOut 07 -> DIO 0 + DIO 1 + DIO 2;
    % DOut 08 -> DIO 3;
    % DOut 09 -> DIO 0 + DIO 3;
    % DOut 10 -> DIO 1 + DIO 3;
    % DOut 11 -> DIO 0 + DIO 1 + DIO 3;
    % DOut 12 -> DIO 2 + DIO 3; 
    % DOut 13 -> DIO 0 + DIO 2 + DIO 3;
    % DOut 14 -> DIO 1 + DIO 2 + DIO 3;
    % DOut 15 -> DIO 0 + DIO 1 + DIO 2 + DIO 3;
    % DOut 16 -> DIO 4;
    % DOut 17 -> DIO 0 + DIO 4;
    % DOut 18 -> DIO 1 + DIO 4;
    % DOut 19 -> DIO 0 + DIO 1 + DIO 4;
    % DOut 20 -> DIO 2 + DIO 4; 
    % DOut 21 -> DIO 0 + DIO 2 + DIO 4;
    % DOut 22 -> DIO 1 + DIO 2 + DIO 4;
    % DOut 23 -> DIO 0 + DIO 1 + DIO 2 + DIO 4;
    % DOut 24 -> DIO 3 + DIO 4;
    % DOut 25 -> DIO 0 + DIO 3 + DIO 4;
    % DOut 26 -> DIO 1 + DIO 3 + DIO 4;
    % DOut 27 -> DIO 0 + DIO 1 + DIO 3 + DIO 4;
    % DOut 28 -> DIO 2 + DIO 3 + DIO 4;
    % DOut 29 -> DIO 0 + DIO 2 + DIO 3 + DIO 4;
    % DOut 30 -> DIO 1 + DIO 2 + DIO 3 + DIO 4;
    % DOut 31 -> DIO 0 + DIO 1 + DIO 2 + DIO 3 + DIO 4;
    % DOut 32 -> DIO 5
    % DOut 33 -> ... 1/binary ...
    %
    % DOuts for single DIO:
    % 1 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768
    %
    % In Rack #3: 
    % DIO 0 -> Center Valve? -> DOut, 1
    % DIO 1 -> Center Light  -> DOut, 2
    % DIO 2 -> Left Valve    -> DOut, 4
    % DIO 3 -> Left Light    -> DOut, 8
    % DIO 4 -> Right Valve   -> DOut, 16
    % DIO 5 -> Right Light   -> DOut, 32
    
    % If using scheduled waves, they have to be declared here, before the
    % states
    % IMPORTANT: the first state declared is state_0.
    % Default inputs: Lin: left line in; Lout: left line out; Rin, Rout;
    % Cin; Cout; Tup;
%     The next states are commented out because they are changed but i'll
%     not delete them for future refernce (when I will have forgotten how I
%     did all this)
    % State 0:
%     sma = add_state(sma, 'default_statechange','Waiting_4_Cin','self_timer',0.001);
    % State 1: wait for central poke in.
%     sma = add_state(sma, 'name', 'Waiting_4_Cin', ...
%       'input_to_statechange', {'Cin', 'Waiting_4_Cout'});
    % State 2: wait for central pole out. The poke has to last at least 0.3s
%     sma = add_state(sma, 'name', 'Waiting_4_Cout', 'self_timer', 0.3, ...
%       'input_to_statechange', {'Cout', 'check_next_trial_ready','Tup','Play_sound'});
    % The tup will be linked to a sound telling the rat that water is
    % available (if he pokes Lin or Rin).
    % State 3: play sound indicating that the rat can now poke into the
    % water pokes.
%     sma = add_state(sma, 'name', 'Play_sound','output_actions',{'DOut', 7},... %check sound output... not working...
%     'self_timer',0.2,'input_to_statechange',{'Tup', 'Waiting_4_both'});
    % Default outputs: DOut (digital output from #1 to 16) and AOut (analog
    % output, probably #1 and 2), watch out declaring it's case sensitive DOut and !Dout. Outputs are maintained during all the
    % duration of a state -> control the duration of the output by the
    % duration of the state.
    % State 4: wait for poke into left or right port.
%     sma = add_state(sma, 'name', 'Waiting_4_both', ...
%       'input_to_statechange', {'Lin', 'Wait_4_leftvalveon','Rin','Wait_4_rightvalveon'});
    % State 5: 
%     sma = add_state(sma, 'name', 'Wait_4_leftvalveon', 'self_timer', 0.1, ...
%       'input_to_statechange', {'Tup', 'Deliver_water_left'});
    % State 6:
%     sma = add_state(sma, 'name', 'Wait_4_rightvalveon', 'self_timer', 0.1, ...
%       'input_to_statechange', {'Tup', 'Deliver_water_right'});
    % State 7:
%     sma = add_state(sma, 'name', 'Deliver_water_left','output_actions', {'DOut',3}, 'self_timer', 0.1, ...
%       'input_to_statechange', {'Tup', 'check_next_trial_ready'});
    % State 8:
%     sma = add_state(sma, 'name', 'Deliver_water_right','output_actions', {'DOut',5}, 'self_timer', 0.1, ...
%       'input_to_statechange', {'Tup', 'check_next_trial_ready'});
% -------------------------------------------------------------------------------------
% Next the sma code that works for now and that we will use (it is not
% elegant but it works for now, I have to try to assemble a state matrix
% from a func file with parts of it all over the place... don't like to
% repete code... :|
% -------------------------------------------------------------------------
% case 'next_trial',
%  sma = StateMachineAssembler('full_trial_structure');
% these lines are way up there but they are needed....

% Initialize the var-s you will use;
    cValve_time = value(centerValve); 
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
    b = shock_prob;%I could have used the same var...
    c = laser_prob;%I could have used the same var...
    
% Here is what's happening in each line:
% First line:
% the general structure is composed of 'if-then' conditions which will
% build a != State Matrix corresponding to how the GUI is set! One could
% define all the possible combinations of the != var's but here I assume the
% standard errors and hope I dindn't forget any big thing...
% a && b are 2 vars created for the purpose of adding a probability vector
% to any event, in this case its the probability trial-by-trial that a
% given port will shock the rat. strcmp() or string compare is needed for
% matching the menu values to the condition we want, the == 1 is in theory
% not neesded because strcmp(lr_shock, 'Left'); should return 1 if tre and
% 0 if false...
% Second Line:
% This is just an output line to the command window that will help the user
% track trial by trial what will happen. It will be more dinamic (maybe with the values of the solenoid times etc...) and
% return an output so that it is possible to track a whole assey (ex:
% 1 = chock and 0 = free water and a tag for Left or right shock or light
% and return a string of 0001110101010101 in a var who's name can be
% left_light_assey or left_shock_assey_ratname?)... HAVE TO THINK THIS BETTER...
% Third Line untill elseif (then same):
% Syntax of sma, sma calls the State Machine Assembler that will in our
% case add_state [it can do other things too...]. This will help you create
% states that will form your matrix on a trial basis. so; sma =
% add_state(sma, 'name', 'yourStateName', 'input_to_statechange', {'event',
% 'where_to_go_in_case_of_event', 'other_event',
% 'where_to_go_in_this_case', etc...});
% IMPORTANT: when defining states names do not use capitalized letters if you want to use PokesPlot Plugin (see nProtocol.m) 
% events can be Cin, Cout, Lin, Lout, Rin, Rout, Tup (see default inputs
% above), outputs or actions (see above as well) can be called by using:
% 'output_actions', {'DOut_or_AOut', number_of_DIOLINE} or as in this case
% if you define DIOLINES in the settings_custom.conf you can use whatever
% name you attribute them. You can also set a timer for each state, this is
% usefull if you want to force an event in a time frame or restart, in this
% case ('self_timer', lValve_time) the 'self_timer' call is followed by a
% var which is getting it's value from the GUI; normal syntax is
% 'self_timer', whatever_number_or_fraction_of_seconds. If the self timer
% finishes the event is called Tup which can and will poin to another
% state. So here we go:

% LEFT SHOCK TRIAL    
    if laser_prob == 0 && shock_prob ~= 0 && a <= b && strcmp(lr_shock, 'Left') == 1
        fprintf('\n-----------\nNext Trial\n-----------\nLaser = OFF\nShock = ON\nSide = LEFT\nProbability = %f\n-----------\n\n', ...
            shock_prob);
        sma = add_state(sma, 'default_statechange', 'Waiting_4_Cin', 'self_timer', 0.001);
        sma = add_state(sma, 'name', 'Waiting_4_Cin', ...
          'input_to_statechange', {'Cin', 'Waiting_4_Cout'});
        sma = add_state(sma, 'name', 'Waiting_4_Cout', 'self_timer', cPoke_time, ...
          'input_to_statechange', {'Cout', 'check_next_trial_ready', 'Tup','center_valve_click'});
        sma = add_state(sma, 'name', 'center_valve_click', 'output_actions', {'DOut', center1water}, ... 
          'self_timer', cValve_time, 'input_to_statechange', {'Tup', 'Waiting_4_both'});
        sma = add_state(sma, 'name', 'Waiting_4_both', ...
          'input_to_statechange', {'Lin', 'Wait_4_leftvalveon', 'Rin', 'Wait_4_rightvalveon'});
        sma = add_state(sma, 'name', 'Wait_4_leftvalveon', 'self_timer', lPoke_time, ...
          'input_to_statechange', {'Tup', 'Deliver_water_left'});
        sma = add_state(sma, 'name', 'Wait_4_rightvalveon', 'self_timer', rPoke_time, ...
          'input_to_statechange', {'Tup', 'Deliver_water_right'});
        sma = add_state(sma, 'name', 'Deliver_water_left', 'output_actions', {'DOut', left1water + shock}, ...
          'self_timer', lValve_time, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        sma = add_state(sma, 'name', 'Deliver_water_right', 'output_actions', {'DOut', right1water}, ...
          'self_timer', rValve_time, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
% RIGHT SHOCK TRIAL  
    elseif (laser_prob == 0 && shock_prob ~= 0 && a <= b && strcmp(lr_shock, 'Right') == 1)
        fprintf('\n-----------\nNext Trial\n-----------\nLaser = OFF\nShock = ON\nSide = RIGHT\nProbability = %f\n-----------\n\n', ...
            shock_prob);
        sma = add_state(sma, 'default_statechange', 'Waiting_4_Cin', 'self_timer', 0.001);
        sma = add_state(sma, 'name', 'Waiting_4_Cin', ...
          'input_to_statechange', {'Cin', 'Waiting_4_Cout'});
        sma = add_state(sma, 'name', 'Waiting_4_Cout', 'self_timer', cPoke_time, ...
          'input_to_statechange', {'Cout', 'check_next_trial_ready', 'Tup','center_valve_click'});
        sma = add_state(sma, 'name', 'center_valve_click', 'output_actions', {'DOut', center1water}, ... 
          'self_timer', cValve_time, 'input_to_statechange', {'Tup', 'Waiting_4_both'});
        sma = add_state(sma, 'name', 'Waiting_4_both', ...
          'input_to_statechange', {'Lin', 'Wait_4_leftvalveon', 'Rin', 'Wait_4_rightvalveon'});
        sma = add_state(sma, 'name', 'Wait_4_leftvalveon', 'self_timer', lPoke_time, ...
          'input_to_statechange', {'Tup', 'Deliver_water_left'});
        sma = add_state(sma, 'name', 'Wait_4_rightvalveon', 'self_timer', rPoke_time, ...
          'input_to_statechange', {'Tup', 'Deliver_water_right'});
        sma = add_state(sma, 'name', 'Deliver_water_left', 'output_actions', {'DOut', left1water}, ...
          'self_timer', lValve_time, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        sma = add_state(sma, 'name', 'Deliver_water_right', 'output_actions', {'DOut', right1water + shock}, ...
          'self_timer', rValve_time, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
% LEFT LASER TRIAL  
    elseif (laser_prob ~= 0 && shock_prob == 0 && a <= c && strcmp(lr_laser, 'Left') == 1)
        fprintf('\n-----------\nNext Trial\n-----------\nLaser = ON\nShock = OFF\nSide = LEFT\nProbability = %f\n-----------\n\n', ...
            laser_prob);
        sma = add_state(sma, 'default_statechange', 'Waiting_4_Cin', 'self_timer', 0.001);
        sma = add_state(sma, 'name', 'Waiting_4_Cin', ...
          'input_to_statechange', {'Cin', 'Waiting_4_Cout'});
        sma = add_state(sma, 'name', 'Waiting_4_Cout', 'self_timer', cPoke_time, ...
          'input_to_statechange', {'Cout', 'check_next_trial_ready', 'Tup','center_valve_click'});
        sma = add_state(sma, 'name', 'center_valve_click', 'output_actions', {'DOut', center1water}, ... 
          'self_timer', cValve_time, 'input_to_statechange', {'Tup', 'Waiting_4_both'});
        sma = add_state(sma, 'name', 'Waiting_4_both', ...
          'input_to_statechange', {'Lin', 'Wait_4_leftvalveon', 'Rin', 'Wait_4_rightvalveon'});
        sma = add_state(sma, 'name', 'Wait_4_leftvalveon', 'self_timer', lPoke_time, ...
          'input_to_statechange', {'Tup', 'Deliver_water_left'});
        sma = add_state(sma, 'name', 'Wait_4_rightvalveon', 'self_timer', rPoke_time, ...
          'input_to_statechange', {'Tup', 'Deliver_water_right'});
        sma = add_state(sma, 'name', 'Deliver_water_left', 'output_actions', {'DOut', left1water + laser}, ...
          'self_timer', lValve_time, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        sma = add_state(sma, 'name', 'Deliver_water_right', 'output_actions', {'DOut', right1water}, ...
          'self_timer', rValve_time, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
% RIGHT LASER TRIAL  
    elseif (laser_prob ~= 0 && shock_prob == 0 && a <= c && strcmp(lr_laser, 'Right') == 1)
        fprintf('\n-----------\nNext Trial\n-----------\nLaser = ON\nShock = OFF\nSide = RIGHT\nProbability = %f\n-----------\n\n', ...
            laser_prob);
        sma = add_state(sma, 'default_statechange', 'Waiting_4_Cin', 'self_timer', 0.001);
        sma = add_state(sma, 'name', 'Waiting_4_Cin', ...
          'input_to_statechange', {'Cin', 'Waiting_4_Cout'});
        sma = add_state(sma, 'name', 'Waiting_4_Cout', 'self_timer', cPoke_time, ...
          'input_to_statechange', {'Cout', 'check_next_trial_ready', 'Tup','center_valve_click'});
        sma = add_state(sma, 'name', 'center_valve_click', 'output_actions', {'DOut', center1water}, ... 
          'self_timer', cValve_time, 'input_to_statechange', {'Tup', 'Waiting_4_both'});
        sma = add_state(sma, 'name', 'Waiting_4_both', ...
          'input_to_statechange', {'Lin', 'Wait_4_leftvalveon', 'Rin', 'Wait_4_rightvalveon'});
        sma = add_state(sma, 'name', 'Wait_4_leftvalveon', 'self_timer', lPoke_time, ...
          'input_to_statechange', {'Tup', 'Deliver_water_left'});
        sma = add_state(sma, 'name', 'Wait_4_rightvalveon', 'self_timer', rPoke_time, ...
          'input_to_statechange', {'Tup', 'Deliver_water_right'});
        sma = add_state(sma, 'name', 'Deliver_water_left', 'output_actions', {'DOut', left1water}, ...
          'self_timer', lValve_time, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        sma = add_state(sma, 'name', 'Deliver_water_right', 'output_actions', {'DOut', right1water + laser}, ...
          'self_timer', rValve_time, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
% NO SIDE SELECTED ON SHOCK TRIAL    
    elseif (laser_prob == 0 && shock_prob ~= 0 && strcmp(lr_shock, 'null') == 1) 
        fprintf('\n-----------\nWHAT?!?!?! SHOCK BOTH SIDES?!?!?!?!\n-----------\n\n');    
% NO SIDE SELECTED ON LASER TRIAL
    elseif (laser_prob ~= 0 && shock_prob == 0 && strcmp(lr_laser, 'null') == 1)
        fprintf('\n-----------\nDO YOU WANT TO LASER RANDOMLY AND HOPE TO GET SOME KIND OF RESULT ANYWAY?!?!?!\n-----------\n\n');
% SHOCK AND LASER TRIALS NOT CODED YET, do we need them?
    elseif (laser_prob ~= 0 && shock_prob ~= 0)
        fprintf('\n-----------\nShok AND Laser?!??!\nsorry, no code for this yet\n-----------\n\n');
% SIDE SET BUT ZERO PROBABILITY ON EITHER TRIAL    
    elseif (shock_prob == 0 && laser_prob == 0) && (~strcmp(lr_shock, 'null') || ~strcmp(lr_laser, 'null'))
        fprintf('\n-----------\nYou don''t need to chose sides if the probability is 0!\nDUH!!\n-----------\n\n');
% EVERYTHING ELSE IS FREE WATER
    else
        fprintf('\n-----------\nNext Trial\n-----------\nFree Water!!\n-----------\n\n')
        sma = add_state(sma, 'default_statechange', 'Waiting_4_Cin', 'self_timer', 0.001);
        sma = add_state(sma, 'name', 'Waiting_4_Cin', ...
          'input_to_statechange', {'Cin', 'Waiting_4_Cout'});
        sma = add_state(sma, 'name', 'Waiting_4_Cout', 'self_timer', cPoke_time, ...
          'input_to_statechange', {'Cout', 'check_next_trial_ready', 'Tup','center_valve_click'});
        sma = add_state(sma, 'name', 'center_valve_click', 'output_actions', {'DOut', center1water}, ... 
        'self_timer', cValve_time, 'input_to_statechange', {'Tup', 'Waiting_4_both'});
        sma = add_state(sma, 'name', 'Waiting_4_both', ...
          'input_to_statechange', {'Lin', 'Wait_4_leftvalveon', 'Rin', 'Wait_4_rightvalveon'});
        sma = add_state(sma, 'name', 'Wait_4_leftvalveon', 'self_timer', lPoke_time, ...
          'input_to_statechange', {'Tup', 'Deliver_water_left'});
        sma = add_state(sma, 'name', 'Wait_4_rightvalveon', 'self_timer', rPoke_time, ...
          'input_to_statechange', {'Tup', 'Deliver_water_right'});
        sma = add_state(sma, 'name', 'Deliver_water_left', 'output_actions', {'DOut', left1water}, ...
           'self_timer', lValve_time, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        sma = add_state(sma, 'name', 'Deliver_water_right', 'output_actions', {'DOut', right1water}, ...
            'self_timer', rValve_time, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
    end;

% P.S. the first state is by default:
% sma = add_state(sma, 'default_statechange', 'Waiting_4_Cin', 'self_timer', 0.001);
% P.P.S. Contrary to what I've sed previously the sma statements have
% capitalized letters, sorry you should chek out nprotocol.m or find and
% replace the capital 'D's 'C's etc....



    % MANDATORY LINE:
    dispatcher('send_assembler', sma, {'Waiting_4_Cin'});
    % I decided to call 'prepare next trial' during state 1 
    
  case 'reinit',

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);

    % Reinitialise at the original GUI position and figure:
    feval(mfilename, obj, 'init');
    
  otherwise,
    warning('%s : %s  don''t know action %s\n', class(obj), mfilename, action);
end;

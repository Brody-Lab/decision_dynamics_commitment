% function [ output_args ] = StateMatrixSection( input_args )

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

global left1water;
global left1led;
% global right1water; 
% global right1led;

GetSoloFunctionArgs;

switch action
  case 'init',
    StateMatrixSection(obj, 'next_trial');
    
  case 'prepare_next_trial',
    sma = StateMachineAssembler('full_trial_structure');
           

    % State 0:
    sma = add_state(sma, 'default_statechange','waiting_4_Cin','self_timer',0.001);
    % State 1: wait for center poke in
    sma = add_state(sma, 'name', 'waiting_4_Cin', 'input_to_statechange', {'Cin', 'waiting_4_Cout'});
    % State 2: wait for center poke out
    sma = add_state(sma, 'name', 'waiting_4_Cout', 'input_to_statechange', {'Cout', 'light_on_Left'});
    % State 3: light on left indicating that the rat can poke into the left poke
    sma = add_state(sma, 'name', 'light_on_Left','output_actions',{'DOut', left1led},'self_timer',2,'input_to_statechange',{'Tup', 'waiting_4_both_pokes', 'Lin', 'deliver_water_left', 'Rin', 'check_next_trial_ready', Cin, 'current_state'});
    % State 4: wait for poke
    sma = add_state(sma, 'name', 'waiting_4_both_pokes', 'input_to_statechange', {'Lin', 'deliver_water_left', 'Rin', 'check_next_trial_ready', 'Cin', 'light_on_left'});
    % State 5: 
    sma = add_state(sma, 'name', 'deliver_water_left','output_actions', {'DOut',left1water}, 'self_timer', 0.1, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});

% -------------------------------------------------------------------------

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

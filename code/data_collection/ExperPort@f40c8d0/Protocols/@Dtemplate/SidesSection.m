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


function [x, y] = SidesSection(obj, action, x, y)
   
GetSoloFunctionArgs;

switch action
  case 'init',
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);

    NumeditParam(obj, 'LeftProb', 0.5, x, y); next_row(y);
    set_callback(LeftProb, {mfilename, 'new_leftprob'});

    DispParam(obj, 'ThisTrial', 'LEFT', x, y); next_row(y);
    SoloParamHandle(obj, 'previous_sides', 'value', 'l');
    SubheaderParam(obj, 'title', 'Sides Section', x, y);
    next_row(y, 1.5);
    
    
  case 'new_leftprob',
    AntibiasSection(obj, 'update_biashitfrac', value(LeftProb));

  case 'next_trial',
    choiceprobs = AntibiasSection(obj, 'get_posterior_probs');    
    if rand(1) <= choiceprobs(1),  ThisTrial.value = 'LEFT';
    else                           ThisTrial.value = 'RIGHT';
    end;

    if strcmp(ThisTrial, 'LEFT'), previous_sides.value = [previous_sides(:) ; 'l'];
    else                          previous_sides.value = [previous_sides(:) ; 'r'];
    end;

  case 'get_previous_sides', 
    x = value(previous_sides);

  case 'get_left_prob'
    x = value(LeftProb);
    
  case 'get_current_side'
    if strcmp(ThisTrial, 'LEFT'), x = 'l';
    else                          x = 'r';
    end;

    
  case 'reinit',
    currfig = gcf;

    % Get the original GUI position and figure:
    x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);

    % Reinitialise at the original GUI position and figure:
    [x, y] = feval(mfilename, obj, 'init', x, y);

    % Restore the current figure:
    figure(currfig);
end;



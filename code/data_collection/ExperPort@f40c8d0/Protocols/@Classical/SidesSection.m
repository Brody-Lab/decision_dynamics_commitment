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
%            'prepare_next_trial'   Goes through the processing necessary
%                        to compute what the next trial's correct side
%                        should be.
%
%            'get_current_side'   Returns either the string 'l' or the
%                        string 'r', for which side is the current trial's
%                        correcy side. 
%
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
%
% x        When action == 'get_current_side', returns either the string 'l'
%          or the string 'r', for Left and Right, respectively.
%


function [x, y] = SidesSection(obj, action, x, y)
   
GetSoloFunctionArgs(obj);

switch action
  case 'init',
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf], 'saveable', 0);

    [x, y] = AntibiasSection(obj,     'init', x, y);
    
    NumeditParam(obj, 'LeftProb', 0.5, x, y); next_row(y);
    set_callback(LeftProb, {mfilename, 'new_leftprob'});
    MenuParam(obj, 'MaxSame', {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, Inf}, Inf, x, y, ...
      'TooltipString', sprintf(['\nMaximum number of consecutive trials where correct\n' ...
      'response is on the same side. Overrides antibias. Thus, for\n' ...
      'example, if MaxSame=5 and there have been 5 Left trials, the\n' ...
      'next trial is guaranteed to be Right'])); next_row(y);

    DispParam(obj, 'ThisTrial', '', x, y); next_row(y);
    SoloParamHandle(obj, 'previous_sides', 'value', []);
    DeclareGlobals(obj, 'ro_args', 'previous_sides');
    SubheaderParam(obj, 'title', 'Sides Section', x, y);
    next_row(y, 1.5);
    
    
  case 'new_leftprob',
    AntibiasSection(obj, 'update_biashitfrac', value(LeftProb));

  case 'prepare_next_trial',
    AntibiasSection(obj, 'update', value(LeftProb), hit_history(1:n_done_trials)', previous_sides(1:n_done_trials)); % <~> Transposed hit history so that it is the expected column vector. (Antibias errors out otherwise.) 2007.09.05 01:39
    
    if ~isinf(MaxSame) && length(previous_sides) > MaxSame && ...
        all(previous_sides(n_done_trials-MaxSame+1:n_done_trials) == previous_sides(n_done_trials)), %#ok<NODEF>
      if previous_sides(end)=='l', ThisTrial.value = 'RIGHT';
      else                         ThisTrial.value = 'LEFT'; 
      end;
    else
      choiceprobs = AntibiasSection(obj, 'get_posterior_probs');
      if rand(1) <= choiceprobs(1),  ThisTrial.value = 'LEFT';
      else                           ThisTrial.value = 'RIGHT';
      end;
    end;
    
    if strcmp(value(ThisTrial), 'LEFT'), previous_sides.value = [previous_sides(1:n_done_trials) ; 'l'];
    else                                 previous_sides.value = [previous_sides(1:n_done_trials) ; 'r'];
    end;
    if strcmp(value(ThisTrial), 'LEFT'), StimulusSection(obj, 'left_trial');
    else                                 StimulusSection(obj, 'right_trial');
    end;

    
  case 'get_previous_sides', 
    x = value(previous_sides); %#ok<NODEF>

  case 'get_left_prob'
    x = value(LeftProb);
    
  case 'get_current_side'
    if strcmp(ThisTrial, 'LEFT'), x = 'l'; %#ok<NODEF>
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



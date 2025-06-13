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


function [x, y] = PunishmentSection(obj, action, x, y)
   
GetSoloFunctionArgs(obj);

switch action
  case 'init',
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf], 'saveable', 0);

    NumeditParam(obj, 'DrinkTime', 20, x, y, 'TooltipString', sprintf('\nTime over which drinking is ok')); next_row(y);
    ToggleParam(obj, 'WarningSoundPanel', 1, x, y, 'OnString', 'warn show', 'OffString', 'warn hide', 'position', [x y 80 20]); 
    NumeditParam(obj, 'WarnDur',   4, x, y, 'labelfraction', 0.6, 'TooltipString', 'Warning sound duration in secs', 'position', [x+80 y 60 20]);
    NumeditParam(obj, 'DangerDur',15, x, y, 'labelfraction', 0.6, 'TooltipString', sprintf('\nDuration of post-drink period where poking is punished'), 'position', [x+140 y 60 20]); next_row(y);
    set_callback(WarningSoundPanel, {mfilename, 'WarningSoundPanel'});
      % start subpanel
      oldx = x; oldy = y; oldfigure = gcf;
      SoloParamHandle(obj, 'WarningSoundPanelFigure', 'saveable', 0, 'value', figure('Position', [120 120 430 156]));
      sfig = value(WarningSoundPanelFigure);
      set(sfig, 'MenuBar', 'none', 'NumberTitle', 'off', ...
        'Name', 'Warning sound', 'CloseRequestFcn', 'Classical(classical, ''closeWarningSoundPanel'')');
      SoundInterface(obj, 'add', 'WarningSound', 10,  10);
      SoundInterface(obj, 'set', 'WarningSound', 'Vol',   0.0002);
      SoundInterface(obj, 'set', 'WarningSound', 'Vol2',  0.004);
      SoundInterface(obj, 'set', 'WarningSound', 'Dur1',  4);
      SoundInterface(obj, 'set', 'WarningSound', 'Loop',  0);
      SoundInterface(obj, 'set', 'WarningSound', 'Style', 'WhiteNoiseRamp');
      
      SoundInterface(obj, 'add', 'DangerSound',  215,  10);
      SoundInterface(obj, 'set', 'DangerSound', 'Vol',   0.004);
      SoundInterface(obj, 'set', 'DangerSound', 'Dur1',  1);
      SoundInterface(obj, 'set', 'DangerSound', 'Loop',  1);
      SoundInterface(obj, 'set', 'DangerSound', 'Style', 'WhiteNoise');

      x = oldx; y = oldy; figure(oldfigure);
    % end subpanel
    SoloFunctionAddVars('SMASection', 'ro_args', {'DrinkTime', 'WarnDur', 'DangerDur'});
   
    [x, y] = PunishInterface(obj, 'add', 'PostDrinkPun', x, y);  %#ok<NASGU>
    next_row(y);
    
    %---------------------------------------------------------------
    %          WarningSoundPanel
    %---------------------------------------------------------------

  case 'WarningSoundPanel'
    if WarningSoundPanel==0, set(value(WarningSoundPanelFigure), 'Visible', 'off');
    else                     set(value(WarningSoundPanelFigure), 'Visible', 'on');
    end;

    %---------------------------------------------------------------
    %          CLOSE
    %---------------------------------------------------------------

  case 'close', 
    if exist('WarningSoundPanelFigure', 'var') && ishandle(value(WarningSoundPanelFigure)),
      delete(value(WarningSoundPanelFigure));
    end;

    
    %---------------------------------------------------------------
    %          REINIT
    %---------------------------------------------------------------
  case 'reinit',
    currfig = gcf;

    % Get the original GUI position and figure:
    x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename '_']);

    % Reinitialise at the original GUI position and figure:
    [x, y] = feval(mfilename, obj, 'init', x, y);

    % Restore the current figure:
    figure(currfig);
end;



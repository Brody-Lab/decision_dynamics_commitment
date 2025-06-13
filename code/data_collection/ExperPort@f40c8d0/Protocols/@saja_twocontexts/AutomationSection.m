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
%
%%% CVS version control block - do not edit manually
%%%  $Revision$
%%%  $Date$
%%%  $Source$


function [x, y] = AutomationSection(obj, action, varargin)
   
GetSoloFunctionArgs;
%%% Imported objects (see protocol constructor):
%%%  'AutomationCommands' (created empty on protocol constructor)

switch action
  case 'init',
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    x = varargin{1};
    y = varargin{2};
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);

    PushbuttonParam(obj, 'LoadAutoCommands', x,y, 'label', 'LoadAutoCommands', 'position', [x y 200 20]);
    set_callback(LoadAutoCommands,{mfilename, 'update_commandstring'});
    
    AutomationSection(obj,'update_commandstring');
    
    next_row(y);
    %next_row(y, 1.0);
    

    
  case 'update_commandstring'
    FilePath = fileparts(mfilename('fullpath'));
    CommandsFileName = fullfile(FilePath,'AutoCommands.m');
    if(exist(CommandsFileName,'file'))
        AutomationCommands.value = fileread(CommandsFileName);
        fprintf('\nNew auto commands file read: %s\n',CommandsFileName);
    else
        fprintf('\nWARNING: File %s does not exist.\n\n',CommandsFileName);
    end
    
    
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



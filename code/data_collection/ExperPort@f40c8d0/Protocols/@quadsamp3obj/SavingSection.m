% [x, y] = SavingSection(obj, action, x, y)
%
% Section that takes care of saving/loading, etc.
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
%            'savesets'  Save GUI settings to a file
%
%            'loadsets'  Load GUI settings to a file
%
%            'savedata'  Save all SoloParamHandles to a file
%
%            'loaddata'  Load all SoloParamHandles from a file
%
%       <~>  'saveboth'  Save GUI settings to a 'settings' file and all
%                          SoloParamHandles to a 'data' file, both without
%                          an interactive prompt. (One-click save all.)
%
% x, y     Only relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI. 
%

function [x, y] = SavingSection(obj, action, x, y, varargin)
   
   GetSoloFunctionArgs;
   % <~> changed & to && in line below
   if exist('SaveTime', 'var') && isa(SaveTime, 'SoloParamHandle'),
      SaveTime.value = datestr(now);
   end;
   
   switch action
    case 'init',      % ------------ CASE INIT --------------------
      % Save the figure and the position in the figure where we are
      % going to start adding GUI elements:
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);
      
      % <~> added for experimenter
      EditParam(obj, 'experimenter', '', x, y, ...
          'label', 'Experimenter Name', ...
          'TooltipString','This is used to specify the directory the rat data will live in,\ne.g. /ratter/SoloData/Data/experimenternamehere/ratnamehere.\nIf this is blank, dir is e.g. /ratter/SoloData/Data/ratnamehere\n<~>');
      next_row(y, 1.5);
      % <~> end added for experimenter
      
      EditParam(obj, 'ratname', 'ratname', x, y); next_row(y, 1.5);
      
      % <~> added feature to save both data & settings without dialog window
      PushButtonParam(obj, 'saveboth', x, y, ...
          'label', 'Quickly Save Data & Settings', ...
          'TooltipString', 'Click to SAVE and COMMIT both data and settings to the default names&places.\n<~>');
      set_callback(saveboth, {mfilename, 'saveboth'});
      next_row(y, 1.5);
      % <~> end added feature
      
      PushButtonParam(obj, 'loadsets', x, y, 'label', 'Load Settings');
      set_callback(loadsets, {mfilename, 'loadsets'});
      next_row(y);     
      PushButtonParam(obj, 'savesets', x, y, 'label', 'Save Settings');
      set_callback(savesets, {mfilename, 'savesets'});
      next_row(y, 1.5);     
      
      PushButtonParam(obj, 'loaddata', x, y, 'label', 'Load Data');      
      set_callback(loaddata, {mfilename, 'loaddata'});
      next_row(y);     
      PushButtonParam(obj, 'savedata', x, y, 'label', 'Save Data');
      set_callback(savedata, {mfilename, 'savedata'});
      next_row(y);     

      SoloParamHandle(obj, 'hostname', 'value', get_hostname);
      SoloParamHandle(obj, 'SaveTime', 'value', datestr(now));
      
      % SubheaderParam(obj, 'sectiontitle', 'Saving/Loading', x, y);
      % next_row(y, 1.5);
    
      return;
      
    case 'savesets',       % ------------ CASE SAVESETS --------------------
      if     nargin == 3, varargin = {x}; 
      elseif nargin == 4, varargin = {x y};
      elseif nargin >= 5, varargin = [{x y} varargin];
      end;
      pairs = { ...
        'interactive'    1   ; ...
        'commit'         1   ; ... % <~> turned back on (settings>>server)
        'experimenter'  ''   ; ... % <~> new
      }; parseargs(varargin, pairs);
        
      save_solouiparamvalues(value(ratname), ...
          'interactive', interactive, ...
          'experimenter', value(experimenter), ... % <~> new
          'commit', commit);
      return;
      
    case 'loadsets',       % ------------ CASE LOADSETS --------------------
      % Disallow starting to run until settings finish loading:
      rpbox('runstart_disable');
      load_solouiparamvalues(value(ratname), ...
          'experimenter', value(experimenter)); % <~> new
      rpbox('runstart_enable');
      
      return;

      
    case 'savedata',       % ------------ CASE SAVEDATA --------------------
      if     nargin == 3, varargin = {x}; 
      elseif nargin == 4, varargin = {x y};
      elseif nargin >= 5, varargin = [{x y} varargin];
      end;
      pairs = { ...
        'interactive'    1   ; ...
        'commit'         1   ; ...
        'asv'            0   ; ...
        'experimenter'  ''   ; ... % <~> new
      }; parseargs(varargin, pairs);

      save_soloparamvalues(value(ratname), ...
          'interactive', interactive, ...
          'experimenter', value(experimenter), ... % <~> new
          'commit', commit, ...
          'asv', asv);
      
      return;
      
    case 'loaddata',       % ------------ CASE LOADDATA --------------------
      % <~> Although this shouldn't happen, we should be consistent and
      %     restrict running here, too.
      % Disallow starting to run until data finish loading:
      rpbox('runstart_disable');

      load_soloparamvalues(value(ratname),...
          'experimenter', value(experimenter)); % <~> new
      rpbox('runstart_enable'); % <~>
      
      return;
    
      
    case 'check_autosave',
      if rem(n_done_trials,19) == 0 && n_done_trials>1,
         SavingSection(obj, 'savedata', ...
             'interactive', 0, ...
             'commit', 0, ...
             'experimenter', value(experimenter), ... % <~> new
             'asv', 1);
      end;

    
    % <~> added this case to handle quicksave of data & settings
    case 'saveboth',       % ------------ CASE SAVEBOTH --------------------
      if     nargin == 3, varargin = {x}; 
      elseif nargin == 4, varargin = {x y};
      elseif nargin >= 5, varargin = [{x y} varargin];
      end;
      pairs = { ...
        'interactive'    0   ; ...
        'commit'         1   ; ...
        'asv'            0   ; ...
        'experimenter'  ''   ; ...
      }; parseargs(varargin, pairs);

      save_soloparamvalues(value(ratname), ...
          'interactive', interactive, ...
          'experimenter', value(experimenter), ...
          'commit', commit, ...
          'asv', asv);

      save_solouiparamvalues(value(ratname), ...
          'interactive', interactive, ...
          'experimenter', value(experimenter), ...
          'commit', commit);
      
      return;
    % <~> end added this case
      
    
    case 'reinit',       % ------------ CASE REINIT --------------------
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
   
   
      
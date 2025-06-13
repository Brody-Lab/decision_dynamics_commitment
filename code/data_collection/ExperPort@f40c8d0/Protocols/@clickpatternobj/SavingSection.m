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

function [x, y] = SavingSection(obj, action, x, y)
   
   GetSoloFunctionArgs;
   
   switch action
    case 'init',      % ------------ CASE INIT --------------------
      % Save the figure and the position in the figure where we are
      % going to start adding GUI elements:
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);
      
      EditParam(obj, 'ratname', 'ratname', x, y); next_row(y, 1.5);
      
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
      next_row(y, 1.5);     

      SubheaderParam(obj, 'sectiontitle', 'Saving/Loading', x, y);
      next_row(y, 1.5);
    
      return;
      
    case 'savesets',       % ------------ CASE SAVESETS --------------------
      save_solouiparamvalues(value(ratname));

      return;
      
    case 'loadsets',       % ------------ CASE LOADSETS --------------------
      load_solouiparamvalues(value(ratname));
      
      return;

      
    case 'savedata',       % ------------ CASE SAVEDATA --------------------
      save_soloparamvalues(value(ratname));

      return;
      
    case 'loaddata',       % ------------ CASE LOADDATA --------------------
      load_soloparamvalues(value(ratname));
      
      return;
    
    
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
   
   
      
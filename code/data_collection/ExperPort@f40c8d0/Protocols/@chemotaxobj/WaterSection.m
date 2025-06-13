% [x, y] = WaterSection(obj, action, x, y)
%
% Section that takes care of Water Valves
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


function [x, y] = WaterSection(obj, action, x, y)
   
   GetSoloFunctionArgs;
   
   switch action
    case 'init',
      % Save the figure and the position in the figure where we are
      % going to start adding GUI elements:
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);

     

      EditParam(obj, 'Right_volume', 30, x, y, 'position', [x y 80 20], ...
                'labelfraction', 0.7, 'label', 'Right uL');  
      DispParam(obj, 'RightWValve', 0, x, y, 'position', ...
                [x+90 y 110 20], 'labelfraction', 0.65, ...
                'label', 'Rt Wtr time'); 
      next_row(y);

      EditParam(obj, 'Left_volume', 30, x, y, 'position', [x y 80 20], ...
                'labelfraction', 0.7, 'label', 'Left uL');  
      DispParam(obj, 'LeftWValve', 0, x, y, 'position', ...
                [x+90 y 110 20], 'labelfraction', 0.65, ...
                'label', 'Lt Wtr time');

      next_row(y, 1.5);
      
      SoloParamHandle(obj, 'water_table', 'value', WaterCalibrationTable, ...
                      'saveable', 0);
      
      SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', ...
                          {'LeftWValve', 'RightWValve'});
      set_callback({Right_volume;Left_volume}, {mfilename, 'calculate'});
      feval(mfilename, obj, 'calculate');

      
      
      
    case 'calculate', 
 
      
      [wt, errid, message] = ...
          interpolate_value(value(water_table), 'right1water', ...
                            value(Right_volume), 'gui_warning', 1);
      if isnan(wt),
         set(get_ghandle(RightWValve), 'BackgroundColor', [1 0.1 0.1]);
         RightWValve.value = 0.4; % Never dispense 0: it confuses the RTFSM
      else
         set(get_ghandle(RightWValve), 'BackgroundColor', 0.8*[1 1 1]);
         RightWValve.value = wt;
      end;

      [wt, errid, message] = ...
          interpolate_value(value(water_table), 'left1water', ...
                            value(Left_volume), 'gui_warning', 1);
      if isnan(wt),
         set(get_ghandle(LeftWValve), 'BackgroundColor', [1 0.1 0.1]);
         LeftWValve.value = 0.4; % Never dispense 0: it confuses the RTFSM
      else
         set(get_ghandle(LeftWValve), 'BackgroundColor', 0.8*[1 1 1]);
         LeftWValve.value = wt;
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
   
   
      
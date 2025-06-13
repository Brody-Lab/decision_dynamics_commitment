function [x, y] = TimesSection(obj, action, x, y)
   
   GetSoloFunctionArgs;
   
   switch action
    case 'init',
      % Save the figure and the position in the figure where we are
      % going to start adding GUI elements:
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);
      
      NumeditParam(obj, 'ITI',           0.5, x, y, ...
        'TooltipString', 'secs before trial end signal is sent'); next_row(y);
      NumeditParam(obj, 'ITI_reinit',      2, x, y, ...
        'TooltipString', 'secs penalty if poke during ITI'); next_row(y);
      NumeditParam(obj, 'ExtraITIOnError', 3, x, y, ...
        'TooltipString', 'extra secs pause if error trial'); next_row(y);

      next_row(y, 0.5);
      SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', ...
                          {'ITI', 'ITI_reinit', 'ExtraITIOnError'});
      
      SubheaderParam(obj, 'title', 'Times', x, y);
      next_row(y, 1.5);
      
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
   
   
      
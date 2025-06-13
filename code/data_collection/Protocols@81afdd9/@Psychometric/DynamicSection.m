

function [x, y] = DynamicSection(obj, action, x, y)
   
GetSoloFunctionArgs(obj);

switch action
  case 'init',
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
    
    NumeditParam(obj, 'nVars', 0, x, y);
    set_callback(nVars, {mfilename, 'nVars'});
    
  case 'nVars',
    varlist = GetSoloFunctionArgs('arglist', ['@' class(obj)], 'DynamicSection');
    % Can't keep track of number of existing vars in an SPH, because on
    % load data (load_soloparamvalues.m) that SPH will get modified. So we
    % count by hand:
    i = strmatch('var_', varlist);  existing_nVars = numel(i);
    
    if nVars > existing_nVars,       %#ok<NODEF>
      % If asking for more vars than exist, make them:
      orig_fig = double(gcf);
      x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
      
      next_row(y, 1 + existing_nVars);
      for newnum = (existing_nVars + 1):value(nVars),
        NumeditParam(obj, ['var_' num2str(newnum)], 0, x, y); next_row(y);       
      end;      
      figure(orig_fig);
      
    elseif nVars < existing_nVars,
      % If asking for fewer vars than exist, delete excess:
      for oldnum = (nVars+1):value(existing_nVars);
        sph = eval(['var_' num2str(oldnum)]);
        if is_validhandle(sph), delete(sph); end;
      end;
      drawnow;
    end;
 
    % Now check for whether we are in the middle of load settings or load
    % data.

    varhandles = {};
    for i = 1:value(nVars), varhandles = [varhandles ; {eval(['var_' num2str(i)])}]; end; %#ok<AGROW>
    load_solouiparamvalues(obj, 'ratname', 'rescan_during_load', varhandles);
    load_soloparamvalues(obj,   'ratname', 'rescan_during_load', varhandles);
    
    % ---------------------------------------------------------------------
    % 
    %   CASE REINIT 
    % 
    % ---------------------------------------------------------------------

  case 'reinit',
    currfig = double(gcf);

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
end




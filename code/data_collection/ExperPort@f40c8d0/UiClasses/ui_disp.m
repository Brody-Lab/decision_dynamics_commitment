%ui_disp       [uh] = ui_disp(varname, varargin)
%
% Takes a variable in the caller's workspace, called varname,
% and assigns it the value of a ui_disp_param_handle. 
% 
% All name-value pairs passed in to persistent_ui_disp are passed along to the
% ui_disp_param_handle creator. 
% 
% In addition, in the ui_disp_param_handle, param_owner is set to the 
% mfilename of the caller, and param_name is set to varname. These values
% override the ones specified by the caller for these two properties (i.e.,
% don't bother specifying values for these properties).
%


function [uh] = ui_disp(varname, varargin)

   st = dbstack; 
   if length(st)>1, [trash, caller] = fileparts(st(2).name); 
   else caller = 'base';
   end;
   
   varargin = [{'label' varname} varargin {'param_owner' caller 'param_name' varname}]; 
   uph = ui_disp_param_handle(varargin);
   
   assignin('caller', varname,  uph);
   
   if nargout > 0, uh = uph; end;
   
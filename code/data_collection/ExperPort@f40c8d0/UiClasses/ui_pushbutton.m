%ui_pushbutton       [] = ui_pushbutton(varname, varargin)
%
% Takes a variable in the caller's workspace, called varname,
% and assigns it the value of a ui_pushbutton_param_handle. 
% 
% All name-value pairs passed in to persistent_ui_pushbutton are passed along to the
% ui_pushbutton_param_handle creator. 
% 
% In addition, in the ui_pushbutton_param_handle, param_owner is set to the 
% mfilename of the caller, and param_name is set to varname. These values
% override the ones specified by the caller for these two properties (i.e.,
% don't bother specifying values for these properties).
%


function [] = ui_pushbutton(varname, varargin)

   st = dbstack; [trash, caller] = fileparts(st(2).name); 
   
   varargin = [{'label' varname} varargin {'param_owner' caller 'param_name' varname}]; 
   uph = ui_pushbutton_param_handle(varargin);
   
   assignin('caller', varname,  uph);
   
   
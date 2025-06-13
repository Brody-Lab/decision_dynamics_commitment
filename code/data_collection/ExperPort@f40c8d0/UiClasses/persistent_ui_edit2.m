%persistent_ui_edit2      [] = persistent_ui_edit2(varname, varargin)
%
% Creates a persistent variable in the caller's caller's workspace, called varname,
% and assigns it the value of a ui_edit_param_handle. 
% 
% All name-value pairs passed in to persistent_ui_edit are passed along to the
% ui_edit_param_handle creator. 
% 
% In addition, in the ui_edit_param_handle, param_owner is set to the 
% mfilename of the caller, and param_name is set to varname. These values
% override the ones specified by the caller for these two properties (i.e.,
% don't bother specifying values for these properties).
%


function [] = persistent_ui_edit2(varname, varargin)

   evalin('caller', ['evalin(''caller'', [''persistent ''' varname ']);']);
   st = dbstack; [trash, caller] = fileparts(st(3).name); 
   
   varargin = [varargin {'param_owner' caller 'param_name' varname}]; 
   uph = ui_edit_param_handle(varargin);
   
   assignin('caller', varname,  uph);
   
   
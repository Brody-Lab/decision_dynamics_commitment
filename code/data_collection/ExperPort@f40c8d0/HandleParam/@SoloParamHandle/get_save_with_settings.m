% [s] = get_save_with_settings(sph)
%
% Returns 1 if "save_with_settings" flag is on, 0 otherwise.
%
% If "save_with_settings" is on, then save_solouiparamvalues.m will save
% this SoloParamHandle's value in settings files even if the
% SoloParamHandle is not a GUI. 
%
% The default initial value for all SoloParamHandles is
% "save_with_settings" == "off." GUI SoloParamHandles are saved with
% settings files regardless of their "save_with_settings" value. 
%
% *** For the final word on which SoloParamHandles get saved in settings files,
% see the confusingly similarly named method of @SoloParamHandle
% gets_saved_with_settings.m ***
%
% Note that "saveable" overrides "save_with_setings". By default,
% "saveable" on, but if "saveable" is off, then "save_with_settings" will
% be ignored.
%
% See also @SoloParamHandle/set_save_with_setttings.m
%

function [s] = get_save_with_settings(sph)
   
   global private_soloparam_list
   
   s = get_save_with_settings(private_soloparam_list{sph.lpos});
      
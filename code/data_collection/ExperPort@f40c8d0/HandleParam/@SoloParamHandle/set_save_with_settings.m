% [sph] = set_save_with_settings(sph, sv)
%
% Sets the SoloParamHandle's "save_with_settings" flag to "on" if sv==1,
% and to "off" is sv==0.
%
% If "save_with_settings" is on, then save_solouiparamvalues.m will save
% this SoloParamHandle's value in settings files even if the
% SoloParamHandle is not a GUI. 
%
% The default initial value for all SoloParamHandles is
% "save_with_settings" == "off." GUI SoloParamHandles are saved with
% settings files regardless of their "save_with_settings" value.
%
% Note that "saveable" overrides "save_with_setings". By default,
% "saveable" on, but if "saveable" is off, then "save_with_settings" will
% be ignored.
%
% See also @SoloParamHandle/get_save_with_setttings.m
%

function [sph] = set_save_with_settings(sph, sv)

   sv = (sv==1);
   
   global private_soloparam_list;
   private_soloparam_list{sph.lpos} = ...
       set_save_with_settings(private_soloparam_list{sph.lpos}, sv);

   
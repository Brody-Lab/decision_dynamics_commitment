function [sph] = set_callback_on_load(sph, callback_on_load)
%
%
% Sets the sph's callback_on_load value to the value of the second
% argument. The only relevant aspect of it is whether it evaluates to
% "True" or "False", so a value of either 0 or 1 does fine.
%   
% By default, an SPH's callback_on_load value is 0; when it is 0, only GUI
% sphs whose value changes on load_soloparamvalues.m or
% load_soluiparamvalues.m will have their callback called.
%    But if an SPH's callback_on_load_value is set to 1 (or anything that
% evaluates to "True"), then the callback for that SPH will *always* be
% called after load_soloparamvalues.m or load_solouiparamvalues.m,
% regardless of whether the value of the SPH changed on the load or not.
% 
% See also @SoloParamHandle/get_callback_on_load.m
%
   
   global private_soloparam_list;
   private_soloparam_list{sph.lpos} = ...
       set_callback_on_load(private_soloparam_list{sph.lpos}, callback_on_load);

   

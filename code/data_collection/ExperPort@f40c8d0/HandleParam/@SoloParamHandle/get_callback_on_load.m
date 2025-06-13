function [cbck] = get_callback_on_load(sph)
%
% Return the callback_on_load value associated with the sph
%   
% callback_on_load is by default 0; in this mode, only GUI sphs whose value
% changes on load_soloparamvalues.m or load_soluiparamvalues.m will have
% their callback called.
%    But if an SPH's callback_on_load_value is set to 1 (or anything that
% evaluates to "True"), then the callback for that SPH will *always* be
% called after load_soloparamvalues.m or load_solouiparamvalues.m,
% regardless of whether the value of the SPH changed on the load or not.
% 
% See also @SoloParamHandle/set_callback_on_load.m
%

   global private_soloparam_list
   cbck = get_callback_on_load(private_soloparam_list{sph.lpos});

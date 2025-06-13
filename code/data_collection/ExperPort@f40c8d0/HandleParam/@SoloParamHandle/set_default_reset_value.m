%set_default_reset_value.m    [sph] = set_default_reset_value(sph, str)
%
% Sets the default reset value-- does not affect the SPH's value, this
% will only be done if restore_default_reset_value() is called. Default
% reset values are either empty (which means there is no default reset
% value), or cells with a single element, which is the default reset
% value. 

function [sph] = set_default_reset_value(sph, str)
   
   global private_soloparam_list;
   private_soloparam_list{sph.lpos} = ...
       set_default_reset_value(private_soloparam_list{sph.lpos}, str);

   
   
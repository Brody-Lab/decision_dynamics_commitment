%get_default_reset_value.m       [s] = get_default_reset_value(sph)
%
% Returns the default reset value. Doesn't affect the SPH's value-- just
% returns it to the caller for examination. Default reset values are
% either empty (which means there is no default reset value), or cells
% with a single element, which is the default reset value.
   
function [s] = get_default_reset_value(sph)

   global private_soloparam_list
   
   s = get_default_reset_value(private_soloparam_list{sph.lpos});
      
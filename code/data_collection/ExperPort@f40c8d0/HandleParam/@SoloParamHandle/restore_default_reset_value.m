%restore_default_reset_value.m   [sph] = restore_default_reset_value(sph)
%
% Sets the value of the SPH to be its default reset value. If the
% default reset value is empty, then the SPH's value is not changed; if the
% default reset value is non-empty, it is assumed to be a cell with a
% single element, and the SPH's value will become equal to that element.

function [sph] = restore_default_reset_value(sph)
   
   global private_soloparam_list;
   private_soloparam_list{sph.lpos} = ...
       restore_default_reset_value(private_soloparam_list{sph.lpos});

   
   
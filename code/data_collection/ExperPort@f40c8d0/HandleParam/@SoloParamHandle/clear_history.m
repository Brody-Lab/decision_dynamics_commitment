% [sph] = clear_history(sph)
%
% Clears the entire history record for this SoloParamHandle
%

function [sph] = clear_history(sph)
   
   global private_soloparam_list
   private_soloparam_list{sph.lpos} = ...
       clear_history(private_soloparam_list{sph.lpos});

   
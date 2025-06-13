function [sph] = set_saveable(sph, sv)

   global private_soloparam_list;
   private_soloparam_list{sph.lpos} = ...
       set_saveable(private_soloparam_list{sph.lpos}, sv);

   
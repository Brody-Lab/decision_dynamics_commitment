function [sph] = set_autoset_string(sph, str)

   global private_soloparam_list;
   private_soloparam_list{sph.lpos} = ...
       set_autoset_string(private_soloparam_list{sph.lpos}, str);

   
   
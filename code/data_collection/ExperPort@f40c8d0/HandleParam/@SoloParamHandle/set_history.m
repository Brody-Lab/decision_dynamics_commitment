function [sph] = set_history(sph, hist)
   
   global private_soloparam_list
   private_soloparam_list{sph.lpos} = ...
       set_history(private_soloparam_list{sph.lpos}, hist);

   
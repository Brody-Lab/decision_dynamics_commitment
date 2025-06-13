function [s] = get_saveable(sph)
   
   global private_soloparam_list
   
   s = get_saveable(private_soloparam_list{sph.lpos});
      
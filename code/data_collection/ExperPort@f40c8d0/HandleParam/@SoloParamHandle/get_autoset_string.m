function [s] = get_autoset_string(sph)
   
   global private_soloparam_list
   
   s = get_autoset_string(private_soloparam_list{sph.lpos});
      
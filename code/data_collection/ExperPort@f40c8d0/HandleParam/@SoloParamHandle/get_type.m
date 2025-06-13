function [t] = get_type(sph)
   
   global private_soloparam_list
   
   t = get_type(private_soloparam_list{sph.lpos});

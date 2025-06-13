function [n] = get_fullname(sp)

   global private_soloparam_list;
   
   n = get_fullname(private_soloparam_list{sp.lpos});
   
   
   
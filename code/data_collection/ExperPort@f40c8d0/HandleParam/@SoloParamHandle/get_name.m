function [n] = get_name(sp)

   global private_soloparam_list;
   
   n = get_name(private_soloparam_list{sp.lpos});
   
   
   
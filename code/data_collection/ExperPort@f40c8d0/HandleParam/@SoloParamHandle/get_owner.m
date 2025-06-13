function [o] = get_owner(sp)

   global private_soloparam_list;
   
   o = get_owner(private_soloparam_list{sp.lpos});
   
   
   
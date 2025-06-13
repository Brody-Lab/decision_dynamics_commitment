function [val] = value(sp)

   global private_soloparam_list;
   val = value(private_soloparam_list{sp.lpos});
   
   
   
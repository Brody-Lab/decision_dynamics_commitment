function [v] = subsref(sp, stct)

   global private_soloparam_list;
   v = subsref(private_soloparam_list{sp.lpos}, stct);

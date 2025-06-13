function [sph] = set_owner(sph, str)

   if isobject(str), str = ['@' class(str)]; end;
     
   global private_soloparam_list;
   private_soloparam_list{sph.lpos} = ...
       set_owner(private_soloparam_list{sph.lpos}, str);

   
   
% [n] = get_funcowner(sp)   Return the name of the function (.m file and,
% if applicable, subfunction) that the SoloParamHandle belongs to.
%

function [n] = get_funcowner(sp)

   global private_soloparam_list;
   
   n = get_funcowner(private_soloparam_list{sp.lpos});
   
   
   
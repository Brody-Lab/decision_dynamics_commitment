% [n] = get_funcowner(sp)   Return the name of the function (.m file and,
% if applicable, subfunction) that the SoloParam belongs to.
%

function [n] = get_funcowner(sp)
   
   n = sp.param_fullname(1:end-length(sp.param_name)-1);
   
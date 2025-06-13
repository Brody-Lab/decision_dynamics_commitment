function [vh] = get_history(sp, u)
   
   if nargin==1,
      vh = sp.value_history;
   else
      vh = sp.value_history{u};
   end;      
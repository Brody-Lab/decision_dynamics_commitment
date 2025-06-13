function [d] = eq(uph1, uph2)

   if   isa(uph1, 'ui_param_handle'), val1 = getvalue(uph1);
   else                               val1 = uph1;
   end;

   if   isa(uph2, 'ui_param_handle'), val2 = getvalue(uph2);
   else                               val2 = uph2;
   end;
   
   if ischar(val1) & ischar(val2),
       d = strcmp(val1, val2);
   elseif isnumeric(val1) * isnumeric(val2),
       d = (val1 == val2);
   else
       d = 0;
   end;
   
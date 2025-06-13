function [uph] = subsasgn(uph, stct, rhs)

   if ~strcmp(stct.type, '.'),
       error('Cannot yet deal with array or cell subscripting, only .fieldname subscript assignment');
   end;
   
   if ~strcmp(stct.subs, 'value'),
       error('Only ".value =" can be used, no other fieldnames allowed');
   end;
   
   setvalue(uph, rhs);
   
   
   
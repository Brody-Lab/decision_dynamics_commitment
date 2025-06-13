function [d] = logical(uph)

   val = get(uph, 'value');
   
   if ischar(val),
       d = str2num(val);
       if isempty(d),
           error('Value is a character string that cannot be converted to a double');
       end;
       return;
       
   else
       d = logical(val);
   end;
   
   
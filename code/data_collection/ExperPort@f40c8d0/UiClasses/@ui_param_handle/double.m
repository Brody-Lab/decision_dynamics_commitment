function [d] = double(uph)

   val = value(uph);
   
   if ischar(val),
       d = str2num(val);
       if isempty(d),
           error('Value is a character string that cannot be converted to a double');
       end;
       return;
       
   else
       d = val;
   end;
   
   
%setvalue.m  [up] = setvalue(up, value)     
%

function [up] = setvalue(up, val)

   h = get(up.ui_param, 'handle');
   if ischar(val),  set(h, 'String', val);
   elseif isnumeric(val) & min(size(val))==1,
       set(h, 'String', sprintf('%g ', val));
   else
       error('ui_disp_param values can only be scalar numbers or strings');
   end;

   
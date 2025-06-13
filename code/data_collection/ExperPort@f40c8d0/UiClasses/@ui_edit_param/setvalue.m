%setvalue.m  [up] = setvalue(up, value)     If this object's force_numeric is
%             empty or zero, strings are just put as is in the
%             edit box; and numbers are turned into strings before
%             they are displayed.
%                But if force_numeric is 1, values that are strings or are
%             empty cause a warning and the value is left untouched.
%
%

function [up] = setvalue(up, val)

   if up.force_numeric==1 & ~isnumeric(val),
       warning('This ui_edit_param''s force_numeric is on, so I will not assign it a non-numeric value');
       return;
   end;
        
   up.ui_param = setvalue(up.ui_param, val);     
   val         = value(up.ui_param);             % get value back after ui_param's range checking

   h = get(up.ui_param, 'handle');
   if ischar(val),  set(h, 'String', val);
   elseif isnumeric(val) & min(size(val))==1,
       set(h, 'String', sprintf('%g ', val));
   else
       error('ui_edit_param values can only be scalar numbers or strings');
   end;

   
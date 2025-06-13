%setvalue.m  [up] = setvalue(up, value)     
%
%

function [up] = setvalue(up, val)

   if isnumeric(val), strval = sprintf('%g ', val); elseif ischar(val) strval = val; 
   else error('value must be numeric or a string, and must be one of the menu items');
   end;
   
   h = get(up.ui_param, 'handle');
   string = get(h, 'String');
   listpos = find(strcmp(strval, string));
   if isempty(listpos),  % didn't find value on list
       error('Requested ui_menu_param value not found in its menu list');
   end;
   
   up.ui_param = setvalue(up.ui_param, val);     

   set(h, 'Value', listpos);

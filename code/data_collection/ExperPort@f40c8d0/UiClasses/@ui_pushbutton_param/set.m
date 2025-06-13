%set.m  [up] = set(up, fieldname, value)    Sets the content of a field of ui_pushbutton_param. 
% 
%

function [up] = set(up, fieldname, value)

switch lower(fieldname),        
    case {'param_owner' 'param_name'},
        up.ui_param = set(up.ui_param, fieldname, value);
        
    otherwise   % Must belong to the graphics... 
        h = get(up.ui_param, 'handle');
        set(h, fieldname, value);
        
end;

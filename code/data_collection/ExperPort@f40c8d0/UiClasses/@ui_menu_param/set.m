%set.m  [up] = set(up, fieldname, value)    Sets the content of a field of ui_menu_param. 
%                                           
%
%

function [up] = set(up, fieldname, value)

switch lower(fieldname),
    case 'value'
        setvalue(up, value);
        
    case {'param_owner' 'param_name'},
        up.ui_param = set(up.ui_param, fieldname, value);
        
    case 'label',
        set(up.label_handle, 'String', value);
        
    case 'tooltipstring',
        set(up.label_handle, 'ToolTipString', value);
        
    case 'range',
        error('the range property is not used for menu items');
        
    otherwise   % Must belong to the graphics... 
        h = get(up.ui_param, 'handle');
        set(h, fieldname, value);
        
end;

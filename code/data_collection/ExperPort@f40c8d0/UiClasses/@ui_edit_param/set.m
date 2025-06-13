%set.m  [up] = set(up, fieldname, value)    Sets the content of a field of ui_edit_param. 
%                                           If the fieldname is 'value',
%             and force_numeric is empty or zero, strings are just put as
%             is in the edit box; numbers are turned into strings before
%             they are displayed.
%                But if force_numeric is 1, values that are strings or are
%             empty cause a warning and the value is left untouched.
%
%

function [up] = set(up, fieldname, value)

switch lower(fieldname),
    case 'value'
        setvalue(up, value);
        
    case {'param_owner' 'param_name'},
        up.ui_param = set(up.ui_param, fieldname, value);
        
    case 'force_numeric',
        up.force_numeric = value;
        
    case 'label',
        set(up.label_handle, 'String', value);
        
    case 'tooltipstring',
        set(up.label_handle, 'ToolTipString', value);
        
    otherwise   % Must belong to the graphics... 
        h = get(up.ui_param, 'handle');
        set(h, fieldname, value);
        
end;

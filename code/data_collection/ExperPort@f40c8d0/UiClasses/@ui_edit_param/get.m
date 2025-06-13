function [val] = get(up, fieldname)

switch fieldname,
    case 'value',
        val = getvalue(up.ui_param);
        
    case {'handle' 'param_owner' 'param_name'},
        val = get(up.ui_param, fieldname);
        
    case 'position',
        h = get(up.ui_param, 'handle');
        val = get(h, 'Position');
        
    otherwise,
        val = up.(fieldname);
end;


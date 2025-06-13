function [up] = ui_param(varargin)

if isa(varargin, 'ui_param'),
    up = varargin;
    return;
    
else
    ui_param_defaults; range = []; handle = [];
    parseargs(varargin, pairs);

    up = struct(   ...
        'value',         value,         ...
        'param_owner',   param_owner,   ...
        'param_name',    param_name,    ...
        'range',         range,         ...
        'handle',        handle);
    up = class(up, 'ui_param');
    return;
end;


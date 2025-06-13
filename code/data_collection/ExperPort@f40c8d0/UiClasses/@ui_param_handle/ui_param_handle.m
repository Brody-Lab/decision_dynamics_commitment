function [uph] = ui_param_handle(varargin)

if isa(varargin, 'ui_param_handle'),
    uph = varargin;
    return;
else
    uph = struct('a', []);
    uph = class(uph, 'ui_param_handle');
end;

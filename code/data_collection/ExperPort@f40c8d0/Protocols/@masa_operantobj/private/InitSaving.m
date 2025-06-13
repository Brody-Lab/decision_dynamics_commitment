function [x, y] = InitSaving(obj, x, y)
%
% [x, y] = InitSaving(obj, x, y)
%
% args:    x, y                 current UI pos, in pixels
%
% returns: x, y                 updated UI pos
%
%

    EditParam(obj, 'RatName', 'ratname', x, y);   next_row(y);
    PushbuttonParam(obj, 'LoadSettings', x, y);   next_row(y);
    PushbuttonParam(obj, 'SaveSettings', x, y);   next_row(y);
    SoloFunction('LoadSettings', 'ro_args', 'RatName');
    SoloFunction('SaveSettings', 'ro_args', 'RatName');
    next_row(y, 0.5);

    PushbuttonParam(obj, 'LoadData', x, y);   next_row(y);
    PushbuttonParam(obj, 'SaveData', x, y);   next_row(y);
    SoloFunction('LoadData', 'ro_args', 'RatName');
    SoloFunction('SaveData', 'ro_args', 'RatName');
    return;

    
    

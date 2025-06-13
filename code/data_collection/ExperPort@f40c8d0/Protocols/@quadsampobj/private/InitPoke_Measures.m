function [x, y] = InitPoke_Measures(x, y, obj)
%
% [x, y] = InitPoke_Measures(x, y, obj)
%
% args:    x, y                 current UI pos, in pixels
%          obj                  A locsamp3obj object
%
% returns: x, y                 updated UI pos
%
    
    DispParam(obj, 'CenterPokes',   0, x, y); next_row(y);
    DispParam(obj, 'LeftPokes',     0, x, y); next_row(y);
    DispParam(obj, 'RightPokes',    0, x, y); next_row(y);
    next_row(y, 0.5);

    EditParam(obj, 'LastCpokeMins', 5, x, y); next_row(y);
    next_row(y, 0.5);
    return;

    
    

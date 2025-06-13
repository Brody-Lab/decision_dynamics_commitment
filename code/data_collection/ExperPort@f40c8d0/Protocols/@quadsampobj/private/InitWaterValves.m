function [x, y, RightWValveTime, LeftWValveTime] = InitWaterValves(obj, x, y);
%
% [x, y, RightWValveTime, LeftWValveTime] = InitWaterValves(x, y);
%


    % --- Water valve times
    EditParam(obj, 'RightWValveTime', 0.14, x, y);  next_row(y);
    EditParam(obj, 'LeftWValveTime',   0.2, x, y);  next_row(y);

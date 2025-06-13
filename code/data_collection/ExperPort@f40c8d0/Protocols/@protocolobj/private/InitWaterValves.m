function [x, y, RightWValveTime, LeftWValveTime] = InitWaterValves(obj, x, y, mychild);
%
% [x, y, RightWValveTime, LeftWValveTime] = InitWaterValves(obj, x, y);
%

if isempty(mychild)
    error('Invalid child object; pass the object of the child class that constructed this protocolobj instance');
end;
2;

c = ['@' class(value(mychild)) ];
    % --- Water valve times
       
        EditParam(obj, 'RightWValveTime', 0.14, x, y, 'param_owner', c);  next_row(y);
        EditParam(obj, 'LeftWValveTime',   0.2, x, y, 'param_owner', c);  next_row(y);
   
        global fake_rp_box;
    if fake_rp_box == -12 % disable these on new rigs because we're using the pumps; dispense times meaning nothing; nothing!
        set(get_ghandle(RightWValveTime), 'Enable', 'off');
        set(get_ghandle(LeftWValveTime), 'Enable', 'off');
    end;
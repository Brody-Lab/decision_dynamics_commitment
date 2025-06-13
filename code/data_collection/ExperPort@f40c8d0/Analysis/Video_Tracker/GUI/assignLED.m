function [LED] = assignLED(k, x, y)

if isempty(k),
    LED.exists = 0;
    LED.x      = NaN;
    LED.y      = NaN;
else
    LED.exists = 1;
    LED.x      = x(k);
    LED.y      = y(k);
end;
function [up] = setvalue(up, value)

range = up.range;

if ~ischar(value) & ~isempty(range),
    if value < range(1), value = range(1); end;
    if value > range(2), value = range(2); end;
end;

up.value = value;

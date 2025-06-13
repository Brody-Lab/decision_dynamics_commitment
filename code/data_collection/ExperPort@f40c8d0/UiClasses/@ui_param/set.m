function [up] = set(up, fieldname, value)

% if strcmp(fieldname, 'value') & ~ischar(value) & ~isempty(up.range),
%    if value < up.range(1), value = up.range(1); end;
%    if value > up.range(2), value = up.range(2); end;
% end;

up.(fieldname) = value;

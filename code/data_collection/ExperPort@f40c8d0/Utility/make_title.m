function [s] = make_title(s)

i = find(s == '_');
s(i) = ' ';

if ~isempty(i)
if i(end) == length(s), i = i(1:end-1); end;
s(i + 1) = upper(s(i + 1));
end;

s(1) = upper(s(1));



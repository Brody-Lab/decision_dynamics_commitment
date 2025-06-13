function [s] = tostring(a)

s = char(0,0);

for i = 1:rows(a)
    s = char(s, num2str(a(i,:)));
end;
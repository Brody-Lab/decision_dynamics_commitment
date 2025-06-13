function y=row(x)

s=size(x);

if s(1)>s(2)
    y=x.';
else
    y=x;
end
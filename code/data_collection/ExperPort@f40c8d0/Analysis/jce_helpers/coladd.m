function y=coladd(a,b)

b=repmat(b, 1, size(a,2));
y=a+b;

function y=exprise(b, x)

up=b(1);
dn=b(2);
c=b(3);

y=up-exp(x*-1*dn+c);


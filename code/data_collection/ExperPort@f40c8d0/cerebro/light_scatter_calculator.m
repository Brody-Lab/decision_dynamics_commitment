
x = -10:0.2:10;

a = 2.5;

r = sqrt(x.^2 + a^2);
A = 2 * pi .* r .* (r - abs(x));
S = 4 * pi .* (r.^2);
R = A./S;

R(1:50) = 1 - R(1:50);

figure; plot(x,R)
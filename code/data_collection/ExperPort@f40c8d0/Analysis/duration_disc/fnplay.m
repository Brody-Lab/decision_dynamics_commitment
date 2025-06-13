function [] = expplay

x=1:0.1:10;

y=exp(-x);
figure; plot(x,y,'.r');
title('Negative-exponential');

y=sub__invert(exp(x));
figure; plot(x,y,'.r');
title('Inverse exponential');

y=sub__invert(exp(-x));
figure; plot(x,y,'.r');
title('Inverse negative-exponential');

y=-1*sub__invert(exp(x));
figure; plot(x,y,'.r');
title('Negative inverse exponential');

y=-1*sub__invert(exp(-x));
figure; plot(x,y,'.r');
title('Negative inverse negative-exponential');

% returns 1/a
function [b] = sub__invert(a)

b=ones(size(a)) ./ a;
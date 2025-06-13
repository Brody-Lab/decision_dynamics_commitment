function [] = interp_sandbox

x = 0:10;
y = sin(x);

xx = min(x):0.01:max(x);
yy = interp1(x,y,xx,'pchip');

figure; 

subplot(2,1,1);
plot(x,y, '.b');
title('Original datapoints');
subplot(2,1,2);
plot(xx,yy,'.g');
title('Interpolated datapoints');


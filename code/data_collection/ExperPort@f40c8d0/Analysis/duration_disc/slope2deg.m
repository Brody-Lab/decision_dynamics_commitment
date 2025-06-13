function []=slope2deg
% simulation that tests conversion of slope value to an angle by atan
% funcction

slp=0:0.5:5;
deg = atan(slp)/(pi/2);

figure;
plot(slp,deg,'.b');
hold on;
plot(slp, log(deg),'.r');
ylabel('degree');
xlabel('slope');
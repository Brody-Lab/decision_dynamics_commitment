function [y] = sigmoid4param(beta, x)
%
% y0=beta(1)    sets the lower bound
% a=beta(2)     a+y0 is the upper bound
% x0=beta(3)    is the bias
% b=beta(4)     is the inverse slope (the lower the better)

% perfect step function
% betahat = [0,1, stimulus_midpoint, 0.001]


y0=beta(1);
a=beta(2);
x0=beta(3);
b=beta(4);

y=y0+a./(1+ exp(-(x-x0)./b));

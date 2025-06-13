function [s] = sigmoid_derivative(betahat, val)
% computes derivative of the four-parameter sigmoid function at x=val.

a=betahat(1);
b=betahat(2);
c=betahat(3);
d=betahat(4);

fac= (b/d);
expterm = exp((c-val)/d);

s = fac * ((expterm) / ((1 + expterm).^2);




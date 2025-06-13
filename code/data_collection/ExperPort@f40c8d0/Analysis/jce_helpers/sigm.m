function y = sigm(pars, xvals);
%  SIGM  -- sigm(pars, xvals).
%     A sigmoidal psychometric function using hyperbolic tangent (tanh)
% .pars(1) = bias, pars(2) = threshold
%  output: computes 0.5 * (1 + tanh(0.7447393 * (x - bias)/thresh))
%    at the values given in 'xvals'

bias = pars(1);
thresh = pars(2);

y = zeros(size(xvals));
y = 0.5 * (1 + tanh(0.7447393 * (xvals - bias)/thresh));
%% Note:  this gives threshold where y = .5(1+tanh(.7447393)) - .816)

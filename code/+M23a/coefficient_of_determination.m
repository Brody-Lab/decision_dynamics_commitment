function R2 = coefficient_of_determination(obsv, pred)
% R^2 metric to asses the goodness of fit
%
% ARGUMENT
%   
%   obsv
%       a vector of the observed values
%
%   pred
%       a vector of the predicted values
%
% RETURN
%
%   R2
%       a scalar metric
%
% EXAMPLE
% >> rng(1234);
% >> x = rand(100,1);
% >> y = rand(100,1);
% >> M23a.coefficient_of_determination(x,y)
validateattributes(obsv, {'numeric'}, {'vector'})
validateattributes(pred, {'numeric'}, {'vector'})
obsv = obsv(:);
pred = pred(:);
SStot = sum((obsv-mean(obsv)).^2);
SSres = sum((obsv-pred).^2);
R2 = 1-(SSres/SStot);

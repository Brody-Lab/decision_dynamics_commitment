function R2 = psth_coefficient_of_determination(obsv, pred)
% R2 for 
validateattributes(obsv, {'numeric'}, {'row'})
validateattributes(obsv, {'numeric'}, {'row'})
SStot = sum(obsv-mean(obsv)).^2);
SSres = sum((obsv-pred).^2);
R2 = 1-SSres/SStot;

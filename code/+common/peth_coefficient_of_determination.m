function R2 = peth_coefficient_of_determination(conditions, peth)
% goodness-of-fit of the peri-event time histogram across condtiions
%
% ARGUMENT
%
%   'conditions': a string vector specifying the groups of trials to be used. The names should be
%   field names in 'peth'
%
%   'peth': a structure
%
% RETURN
%
%   'R2': a scalar
validateattributes(conditions, {'string'},{'vector'})
validateattributes(peth, {'struct'},{'scalar'})
[SSresidual, SStotal] = deal(0);
for condition = conditions
    n = min(numel(peth.(condition).predicted), numel(peth.(condition).observed));
    pred = peth.(condition).predicted(1:n);
    obsv = peth.(condition).observed(1:n);
    SSresidual = SSresidual + sum(((pred - obsv)).^2);
    SStotal = SStotal + sum((mean(obsv) - obsv).^2);
end
R2 = 1 - SSresidual/SStotal;
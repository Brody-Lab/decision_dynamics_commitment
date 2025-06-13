% function olf = SetOdorFlow(olf, mixname, flow)
%   Sets the odor flow for all banks in the mix, in ml/min. (each bank gets an
%   individual flow based on the Mixture Ratio defined, see SetMixtureRatio
%   and GetMixtureRatio).  
function olf = SetOdorFlow(olf, mixname, flow)

    DoSimpleCmd(olf, sprintf('SET ODOR FLOW %s %f', mixname, flow));
    
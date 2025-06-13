% function olf = SetTotalFlow(olf, mixname, flow)
%
% Set the total flow for a mix.  This adjusts the carrier air and leaves
% the odor flow untouched.  
function olf = SetTotalFlow(olf, mixname, flow)

    DoSimpleCmd(olf, sprintf('SET DESIRED TOTAL FLOW %s %f', mixname, flow));

    
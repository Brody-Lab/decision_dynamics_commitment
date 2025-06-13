% function flow = GetCommandedCarrierFlow(olf, mixname)
%   Returns the *commanded* (not actual) odor flow for a given bank name
function flow = GetCommandedCarrierFlow(olf, mixname)
    flow = str2num(DoQueryCmd(olf, sprintf('GET COMMANDED CARRIER FLOW %s', mixname)));

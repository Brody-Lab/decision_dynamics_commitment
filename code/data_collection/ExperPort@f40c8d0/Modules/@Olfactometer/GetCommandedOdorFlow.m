% function flow = GetCommandedOdorFlow(olf, mixname)
%   Returns the *commanded* (not actual) odor flow for a given mixname
function flow = GetCommandedOdorFlow(olf, mixname)
    flow = str2num(DoQueryCmd(olf, sprintf('GET COMMANDED ODOR FLOW %s', mixname)));
    
% function flow = GetOdorFlow(olf, mixname)
%   Returns the *actual* odor flow for a given mix
function flow = GetOdorFlow(olf, mixname)

    flow = str2num(DoQueryCmd(olf, sprintf('GET ACTUAL ODOR FLOW %s', mixname)));
    

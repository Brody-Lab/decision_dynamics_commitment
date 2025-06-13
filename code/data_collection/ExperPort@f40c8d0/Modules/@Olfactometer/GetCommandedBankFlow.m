% function flow = GetCommandedOdorFlow(olf, bankname)
%   Returns the *commanded* (not actual) odor flow for a given bank name
function flow = GetCommandedBankFlow(olf, bankname)
    flow = str2num(DoQueryCmd(olf, sprintf('GET COMMANDED BANK FLOW %s', bankname)));
    
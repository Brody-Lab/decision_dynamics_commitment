% function olf = OverrideBankFlow(olf, bankname, newflow)
%
% This function changes the actual flow rate for a specific bank in
% a mix.  Note that the mix ratios defined for the mix might be
% violated, since this function forces the specific bank to an exact
% flow rate, while not touching the other banks in the mix.
% This function is intended to be used when troubleshooting the
% olfactometer and not during the normal course of operation.  Use
% SetBankFlow(), SetOdorFlow(), etc instead.
function olf = OverrideBankFlow(olf, bank, flow)
    DoSimpleCmd(olf, sprintf('OVERRIDE BANK FLOW %s %d', bank, flow));
    
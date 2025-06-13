% function olf = OverrideCarrierFlow(olf, mixname, newflow)
%
% This function changes the actual flow rate for the carrier air of
% a mix.   Nothing else is touched in the mix.  Since this function
% has the possibility of breaking other higher-level axioms about
% the olfactometer, such as the 'Programmed Total Flow', use
% SetTotalFlow() instead. This function is only here for
% troubleshooting purposes.
function olf = OverrideCarrierFlow(olf, mix, flow)
    DoSimpleCmd(olf, sprintf('OVERRIDE CARRIER FLOW %s %d', mix, flow));
    
% function olf = SetBankFlow(olf, BANK, FLOW_ML_S)
%
% Sets the flow rate for a specific BANK.  Note that the mixratio
% is applied to the all of the banks, so that this command actually
% changes the total flow for an entire mix, rather than the flow
% for this bank specifically.  It will, however, set the total flow
% for an entire mix so that this bank's flow will match FLOW_ML_S.
% If the above is confusing, say you have the following scenario:
%
% Mix_ratio = { 'Bank1', 60; ...
%               'Bank2', 40 };
% SetMixRatio(olf, 'Mix12', Mix_ratio); % specify a new mix ratio
% SetOdorFlow(olf, 'Mix12', 100); % set the odor flow, applying the
%                                 % above mix ratio
% GetOdorFlow(olf, 'Mix12'); % at this point 100 is returned, total
%                            % odor flow
% GetBankFlow(olf, 'Bank2'); % at this point 40 is returned, since
%                            % this bank is at 40 in the 60/40
%                            % mixture defined above
%
% % Now, we want to illustrate SetBankFlow()...
% SetBankFlow(olf, 'Bank2', 20);
% GetFlow(olf, 'Mix12'); % at this point 50 is returned
% GetFlow(olf, 'Bank2'); % at this point 20 is returned
%
% Stated another way, the axiom is that that the odor flow for a 
% specific bank must be respect the mixratios for the mix to which
% it belongs.
%
% To violate that axiom see see @Olfactometer/OverrideBankFlow
% instead!
function olf = SetBankFlow(olf, bankname, flow_ml_s)
     % figure out what mix this bank belongs to..
     idx = GetBankIndex_INTERNAL(olf, bankname);
     mix = olf.banks{idx, 2};
     % now grab the old total flow for all banks in this mix
     oldTotal = GetCommandedOdorFlow(olf, mix);
     % now grab just the odor flow for this bank
     oldBankFlow = GetCommandedBankFlow(olf, bankname);
     % now compute the new total flow -- how much we should
     % grow/shrink the new total flow based on the old flow and how
     % it relates to the flow_ml_s parameter..
     newTotal = flow_ml_s/oldBankFlow * oldTotal;
     % now set the new total flow
     SetOdorFlow(olf, mix, newTotal);
     % DONE!

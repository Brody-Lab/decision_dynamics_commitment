% function olf = SetMixRatio(olf, mixname, mixratios)
%   Pass a mixname
%   Pass in a NUM_NANKS_IN_MIX by 2 cell array of columns: 
%      BankName(string) MixRatio(double)
function olf = SetMixRatio(olf, mix, mixratios)

    mrs = '';
    for i=1:size(mixratios,1),
        mrs = strcat(mrs, sprintf(' %s=%f', mixratios{i,1}, mixratios{i,2}));
    end;
    
    DoSimpleCmd(olf, sprintf('SET MIX RATIO %s %s', mix, mrs));

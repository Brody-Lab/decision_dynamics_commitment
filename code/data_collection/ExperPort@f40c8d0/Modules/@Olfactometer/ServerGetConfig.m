% function olf = ServerGetConfig(olf)
%   Simply rereads the olf config from the server.  
function olf = ServerGetConfig(olf)

    olf.name = DoQueryCmd(olf, 'GET NAME', 1);
    olf.description = DoQueryCmd(olf, 'GET DESCRIPTION', 1);
    
    olf.banks = [];
    olf.mixes = GetMixNames_INTERNAL(olf);
    for i=1:size(olf.mixes,1),
        banks = GetBankInfo_INTERNAL(olf, olf.mixes{i});
        olf.banks = [ olf.banks; banks ];
    end;

% function bIndex = GetBankIndex_INTERNAL(olf, bankname)
%   don't call this -- internal to olf implementation
function bIndex = GetBankIndex_INTERNAL(olf, bankname)
    
    bnames = GetBankNames(olf);

    bIndex = 0;
    
    for i=1:size(bnames,1)
        if (bnames{i} == bankname),
            bIndex = i;
            break;
        end;
    end;
    if (~bIndex),
        error(sprintf('Bank %s is not a valid bankname!', bankname));
    end;

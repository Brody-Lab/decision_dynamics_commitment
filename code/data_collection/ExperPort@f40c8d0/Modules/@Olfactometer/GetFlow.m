% function flow = GetFlow(olf, bank_or_mixname)
%  returns the current actual flow in ml/min for a particular
%  bank or mix.  If a mix is specified, the carrier flow+odorflowtotal is returned.
function flow = GetFlow(olf, bank_or_mixname)
    
    if IsMix(olf, bank_or_mixname),
        % do mix version
        flow = str2num(DoQueryCmd(olf, sprintf('GET ACTUAL ODOR FLOW %s', bank_or_mixname))) + str2num(DoQueryCmd(olf, sprintf('GET ACTUAL CARRIER FLOW %s', bank_or_mixname)));
    else
        flow = str2num(DoQueryCmd(olf, sprintf('GET ACTUAL BANK FLOW %s', bank_or_mixname)));
    end;
    
    return;
    
function hmm = IsMix(olf, thing)
    
    hmm = 0;
    
    mixes = GetMixNames(olf);
    for i=1:size(mixes,1),
        if strcmp(thing, mixes{i}),
            hmm = 1;
            return;
        end;
    end;
    
    return;

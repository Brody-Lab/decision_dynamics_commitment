function [] = SaveData(obj, varargin)

pairs =  { ...
    'asv', 0; ...
    };
parse_knownargs(varargin, pairs);    

    GetSoloFunctionArgs;
    if asv > 0
            save_soloparamvalues(RatName, 'asv',1);
    else
        save_soloparamvalues(RatName);
    end;
    
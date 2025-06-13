function [] = SaveSettings(obj, varargin);

pairs =  { ...
    'asv', 0; ...
    };
parse_knownargs(varargin, pairs);

    GetSoloFunctionArgs;
    
    if asv > 0
        save_solouiparamvalues(RatName, 'asv', 1);
    else
        save_solouiparamvalues(RatName);
    end;



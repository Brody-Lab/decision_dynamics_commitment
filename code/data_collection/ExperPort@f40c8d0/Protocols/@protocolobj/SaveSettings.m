function [] = SaveSettings(obj, varargin);

pairs =  { ...
    'asv', 0; ...
    };
parse_knownargs(varargin, pairs);

    GetSoloFunctionArgs;
    
    if asv > 0
        save_solouiparamvalues(ratname, 'child_protocol', mychild, 'asv', 1);
    else
        save_solouiparamvalues(ratname, 'child_protocol', mychild, 'commit', 1);
    end;



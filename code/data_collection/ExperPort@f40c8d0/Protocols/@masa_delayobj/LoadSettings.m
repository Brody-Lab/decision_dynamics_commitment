function [] = LoadSettings(obj);

    GetSoloFunctionArgs;
    
    load_solouiparamvalues(ratname, 'experimenter', experimenter);
    
    VpdsSection(obj, 'change');
    
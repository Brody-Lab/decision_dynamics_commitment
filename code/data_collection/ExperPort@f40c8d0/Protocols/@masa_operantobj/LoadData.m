function [] = LoadData(obj);

    GetSoloFunctionArgs;
    
    load_soloparamvalues(ratname, 'experimenter', experimenter);
    
    ChordSection(obj,      'make_upload');
    ChordSection(obj,      'make_upload_othersounds');
    PokeDuration(obj,      'update');
    

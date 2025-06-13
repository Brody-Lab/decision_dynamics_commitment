function [] = LoadData(obj);

    GetSoloFunctionArgs;
    
    load_soloparamvalues(RatName);
    
    SidesSection(obj,        'set_future_sides');
    SidesSection(obj,        'update_plot');
    VpdsSection(obj,         'set_future_vpds');
    VpdsSection(obj,         'update_plot');
    PokeMeasuresSection(obj, 'update_plot');
    ChordSection(obj,        'make');

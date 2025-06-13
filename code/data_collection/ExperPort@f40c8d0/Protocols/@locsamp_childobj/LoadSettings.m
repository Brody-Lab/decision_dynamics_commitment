function [] = LoadSettings(obj);

    GetSoloFunctionArgs;
    
    load_solouiparamvalues(RatName);
    
    SidesSection(obj, 'set_future_sides');
    SidesSection(obj, 'update_plot');
    VpdsSection(obj, 'set_future_vpds');
    VpdsSection(obj, 'update_plot');
    ChordSection(obj, 'make');
    
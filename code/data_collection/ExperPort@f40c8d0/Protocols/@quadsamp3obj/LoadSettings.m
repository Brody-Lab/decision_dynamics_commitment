function [] = LoadSettings(obj);

    GetSoloFunctionArgs;
    
    load_solouiparamvalues(RatName);

    ReportHitsSection(obj, 'update'); 
    ReportHitsSection(obj, 'update_chooser');    
    
    
function [] = LoadData(obj);

    GetSoloFunctionArgs;
    
    load_soloparamvalues(RatName);

    ReportHitsSection(obj, 'update'); 
    ReportHitsSection(obj, 'update_chooser');    

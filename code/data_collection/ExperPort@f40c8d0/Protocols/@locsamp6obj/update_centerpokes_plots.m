function [] = update_centerpokes_plots(obj)

    GetSoloFunctionArgs;
    
    
    %    InitParam(me, 'LastPokeInTime', 'value', 0); InitParam(me, 'LastPokeOutTime');
    %    initialize_centerpokes_plot;

    if ~exist('initialized', 'var'),
        SoloParamHandle(obj, 'initialized');
    
    end;    
    

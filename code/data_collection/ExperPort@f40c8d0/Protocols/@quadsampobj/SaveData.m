function [] = SaveData(obj);

    GetSoloFunctionArgs;
    
    if ~exist('SaveTime', 'var'), SoloParamHandle(obj, 'SaveTime'); end;
    SaveTime.value = datestr(now);
    
    if ~exist('hostname', 'var'),
       SoloParamHandle(obj, 'hostname', 'value', get_hostname);
    end;
    
    save_soloparamvalues(RatName, 'commit', 1); 

   
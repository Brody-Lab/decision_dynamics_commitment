function  [x y] =  TimeVarsSection(obj, action, x, y)


GetSoloFunctionArgs(obj);


switch action
    
    %% init
    case 'init',
        EditParam(obj, 'cfix_time', '0.2', x, y, 'label', 'Fixation Time (s)');
        next_row(y, 1.5);
        SubheaderParam(obj, 'title', 'Penalty Time', x, y);
        
    case 'get_cfix_time',
        x = value(cfix_time);
        
    otherwise,
        disp('PunishmentSection ERROR: unknown case');
        
end

end
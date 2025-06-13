function  [x y] =  TimeVarsSection(obj, action, x, y)


GetSoloFunctionArgs(obj);


switch action
    
    %% init
    case 'init',
        DispParam(obj, 'cfix_time', '0.2', x, y, 'label', 'Fixation Time');
        next_row(y, 1);
        EditParam(obj, 'cfix_growth', '1.003', x, y, 'label', 'growth rate');
        next_row(y, 1);
        EditParam(obj, 'cfix_factor', '0.05', x, y, 'label', 'current factor');
        next_row(y, 1);
        EditParam(obj, 'cfix_time_lower', '0.75', x, y, 'label', 'final lower bound');
        next_row(y, 1);
        EditParam(obj, 'cfix_time_upper', '3', x, y, 'label', 'final upper bound');
        next_row(y, 1);
        EditParam(obj, 'cfix_time_tau', '0.5', x, y, 'label', 'final tau');
        next_row(y, 1);
        
        SubheaderParam(obj, 'title', 'Fixation Time Parameters', x, y);
        next_row(y, 1.5);
        
        EditParam(obj, 'penalty_time', '4', x, y, 'label', 'Penalty Time');
        next_row(y, 1);
        EditParam(obj, 'delay_time', '0.1', x, y, 'label', 'Delay Time');
        next_row(y, 1);
        EditParam(obj, 'drinking_time', '2', x, y, 'label', 'Drinking Time');
        next_row(y, 1);
        EditParam(obj, 'cbreak_penalty_time', '0.1', x, y, 'label', 'Cbreak Penalty');
        next_row(y, 1);
        SubheaderParam(obj, 'title', 'Time Constants', x, y);
        next_row(y, 1.5);
        
        EditParam(obj, 'forgiveness_delay', '0.5', x, y, 'label', 'Forgiveness Delay');
        next_row(y, 1);
        SubheaderParam(obj, 'title', 'Trial Variables', x, y);
        next_row(y, 1.5);
        
    case 'prepare_next_trial',
        if(completed_cfix == 1)
            cfix_factor.value = min(1, value(cfix_factor) * value(cfix_growth)); %#ok<NODEF>
        end
        cfix_time.value = cfix_factor * min(cfix_time_lower - cfix_time_tau * log(1 - rand), value(cfix_time_upper)); %#ok<STRNU>
        
    case 'get_cfix_time',
        x = value(cfix_time); %#ok<NODEF>
        
    case 'get_penalty_time',
        x = value(penalty_time);
        
    case 'get_delay_time',
        x = value(delay_time);
        
    case 'get_drinking_time',
        x = value(drinking_time);
        
    case 'get_cbreak_penalty_time',
        x = value(cbreak_penalty_time);
        
    case 'get_forgiveness_delay',
        x = value(forgiveness_delay);
        
    otherwise,
        disp('PunishmentSection ERROR: unknown case');
        
end

end
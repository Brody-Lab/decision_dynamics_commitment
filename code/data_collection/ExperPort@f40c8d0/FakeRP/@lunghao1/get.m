function [parval] = get(lh1, parname)

    lh1 = get_mylh1(lh1);
    
    switch parname,
        case 'UserData',
            parval = lh1.UserData;
                
        case 'lunghao1_id',
            parval = lh1.list_position;
            
        otherwise,
            error(['Don''t know how to get ' parname]);
    end;    
    
    

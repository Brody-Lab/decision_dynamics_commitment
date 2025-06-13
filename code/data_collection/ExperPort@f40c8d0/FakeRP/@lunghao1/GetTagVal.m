function tagval = GetTagVal(lh1, tagname)

    lh1 = get_mylh1(lh1);
    
    % Special cases first
    switch tagname,
        case 'Clock',
            if lh1.starttime==0, tagval=0; 
            else tagval = etime(clock, lh1.starttime);
            end;
            return;
            
        case 'State', 
            tagval = lh1.StateNow;
            return;
            
        otherwise,
    end;

    check_tagname(lh1, tagname);
    tagval = lh1.(tagname);
    return;
    
    

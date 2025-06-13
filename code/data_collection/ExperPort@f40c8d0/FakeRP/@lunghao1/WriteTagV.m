function [out] = WriteTagV(lh1, tagname, offset, datavec)
   
    lh1 = get_mylh1(lh1);
    switch tagname,
        case 'StateMatrix',
            lh1.StateMatrix  = datavec(1+offset:end);
            % line below commented out 16-Sep-05: in
            % no-dead-time-technology, writing the state matrix should not
            % affect the current state number
            % lh1.StateNow     = 35;
            save_mylh1(lh1);
            check_statechange_callback(lh1);
        
        otherwise,
            check_tagname(lh1, tagname);
            lh1.(tagname) = datavec(1+offset:end); 
            save_mylh1(lh1);
    end;
    out=1;
    return;
    
function [out] = SetTagVal(lh1, tagname, tagval)
	
	lh1 = get_mylh1(lh1);
    switch tagname,
        case 'ch1in',
            % fprintf(1, 'tagval=%.2f  ch1in=%.2f\n', tagval, lh1.ch1in)
            if tagval > lh1.ch1in & tagval > 0.45, SoftTrg1(lh1); 
            elseif tagval > lh1.ch1in & 0.15 < tagval & tagval < 0.45, SoftTrg3(lh1);    
            end;
            lh1.(tagname) = tagval;
            
        case 'ch2in',
            if tagval > lh1.ch2in, SoftTrg4(lh1); end;
            lh1.(tagname) = tagval;
            
        otherwise    
            check_tagname(lh1, tagname);
            lh1.(tagname) = tagval;
    end;
        
    save_mylh1(lh1);
    out = 1;
    
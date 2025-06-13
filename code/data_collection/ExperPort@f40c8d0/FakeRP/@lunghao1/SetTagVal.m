function [out] = SetTagVal(lh1, tagname, tagval)
	
	lh1 = get_mylh1(lh1);
	switch tagname,
        case 'Dio_Hi_Bits',
            lh1.(tagname) = tagval;
            save_mylh1(lh1);
            check_doutchange_callback(lh1);
            
        case 'Dio_Hi_Dur',
            lh1.(tagname) = tagval;
            if lh1.Dio_Hi_Dur < 0.1*6000,
                warning('Remember that Dio_Hi_Dur is in units of 1/6000 of a sec; you set Dio_Hi_Dur to less than 100 ms');
            end;
                
        case 'running', 
            'hi', 
            lh1.(tagname) = tagval;
            save_mylh1(lh1);
            check_statechange_callback(lh1);
            
        otherwise,
            check_tagname(lh1, tagname);
            lh1.(tagname) = tagval;
    end;

	save_mylh1(lh1);
    out = 1;
    
function [lh1] = WriteTagVEX(lh1, tagname, offset, datatype, datavec)

    lh1 = get_mylh1(lh1);
    check_tagname(lh1, tagname);
    lh1.(tagname) = datavec(1+offset:end); 
    save_mylh1(lh1);
    
    return;
    
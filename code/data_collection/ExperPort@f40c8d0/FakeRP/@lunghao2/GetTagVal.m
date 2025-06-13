function tagval = GetTagVal(lh1, tagname)

    lh1 = get_mylh1(lh1);
    check_tagname(lh1, tagname);
    tagval = lh1.(tagname);
    return;
    
    

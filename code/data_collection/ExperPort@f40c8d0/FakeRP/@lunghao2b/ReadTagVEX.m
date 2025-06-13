function out = ReadTagVEX(lh1, tagname, offset, npoints, format1, format2, nchannels)
  
    lh1 = get_mylh1(lh1);
    check_tagname(lh1, tagname);
    out = lh1.(tagname); out = out(1+offset : 1+offset+len); 
    
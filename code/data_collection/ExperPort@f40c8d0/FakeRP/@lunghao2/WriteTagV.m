function [out] = WriteTagV(lh1, tagname, offset, datavec)

    lh1 = get_mylh1(lh1);
    check_tagname(lh1, tagname);
%     if max(abs(datavec)*10000) >  1,
%         max(abs(datavec)),
%         warning('WARNING!!! REALLY LOUD SOUND!!! IT''LL GET AMPLIFIED BY A FACTOR OF 10,000!!!');
%     end;     
    lh1.(tagname) = datavec(1+offset:end); 
    save_mylh1(lh1);
    out = 1;
    return;
    
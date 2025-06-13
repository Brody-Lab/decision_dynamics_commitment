function [out] = WriteTagV(lh1, tagname, offset, datavec)

    lh1 = get_mylh1(lh1);
    check_tagname(lh1, tagname);
%     if max(abs(datavec)*10000) >  1,
%         max(abs(datavec)),
%         warning('WARNING!!! REALLY LOUD SOUND!!! IT''LL GET AMPLIFIED BY A FACTOR OF 10,000!!!');
%     end; 
    if isvector(datavec),
        lh1.(tagname) = datavec(1+offset:end); 
    elseif size(datavec, 1)==2 & length(datavec) > 2,
        lh1.(tagname) = datavec(:,1+offset:end);
    elseif size(datavec, 2)==2 & length(datavec) > 2,
        lh1.(tagname) = datavec(1+offset:end,:);
    else
        error(['Don''t know how to handle data vectors of this size and shape']);
    end;
        
    save_mylh1(lh1);
    out = 1;
    return;
    
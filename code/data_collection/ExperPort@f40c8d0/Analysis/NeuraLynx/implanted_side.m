function [ipsi,varargout]=implanted_side(cellid)


eibid=bdata('select eibid from cells where cellid="{S}"',cellid);
if isempty(eibid) || isnan(eibid)
    ipsi='';
    if nargout>1
        varargout{1}='';
    end
else
    implanted_left=bdata('select (region regexp "left") from ratinfo.eibs e,cells c where e.eibid=c.eibid and cellid="{S}"',cellid);
    
    if implanted_left
        ipsi='l';
        if nargout>1
            varargout{1}='r';
        end
    else
        ipsi='r';
        if nargout>1
            varargout{1}='l';
        end
    end
end
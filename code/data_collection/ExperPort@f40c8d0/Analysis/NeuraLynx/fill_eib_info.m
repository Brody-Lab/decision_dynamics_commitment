%%

[ratname,chid, data_p, cellid]=bdata('select ratname, a.channelid, path_name, cellid from channels a, cells b where a.channelid=b.channelid');

for cx=1:numel(cellid)
    
    fldr_clr=cell2mat(regexpi(data_p{cx},'black|red','match'));
    if ~isempty(fldr_clr)
    [eibid,eib_num]=bdata(['select eibid,eib_num from ratinfo.eibs where ratname="{S}" and eib_num like "%' fldr_clr(1) '"'],ratname{cx});
    else
    [eibid,eib_num]=bdata('select eibid,eib_num from ratinfo.eibs where ratname="{S}"',ratname{cx});
    end
        
    if ~isempty(eibid) && numel(eibid)==1
        mym(bdata,'update cells set eibid="{S}" where cellid="{S}"', eibid, cellid(cx));
        fprintf(1,'Updated rat %s with eib %s from folder %s\n',ratname{cx}, eib_num{1},data_p{cx});
    else
        fprintf(1,'Note sure which eib for rat %s from folder %s\n',ratname{cx}, data_p{cx});
    end
end



 


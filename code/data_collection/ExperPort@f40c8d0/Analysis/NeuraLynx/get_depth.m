function d=get_depth(cellid)

[ratname, sdate,etime]=bdata('select s.ratname, sessiondate, endtime from sessions s, cells c where s.sessid=c.sessid and cellid="{S}"',cellid);

[tdates, ttimes, depth]=bdata('select turn_date,turn_time, depth from ratinfo.turn_down_log where ratname="{S}" order by turn_date, turn_time',ratname{1});

for tx=1:numel(tdates)
    dn(tx)=datenum([tdates{tx} ' ' ttimes{tx}],'yyyy-mm-dd HH:MM:SS');
end

cell_date=datenum([sdate{1} ' ' etime{1}],'yyyy-mm-dd HH:MM:SS');

ind=qfind(dn,cell_date);
if ind==-1;
    d=0;
else
d=depth(ind);
end
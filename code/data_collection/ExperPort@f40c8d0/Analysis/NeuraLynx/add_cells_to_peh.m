function peh=add_cells_to_peh(peh,sessid)

[cellid, ts]=bdata('select cellid, ts from spktimes where sessid="{Si}"',sessid);

% if peh is a struct array instead of a cell array of structs, convert it
if isstruct(peh),
    y = cell(numel(peh),1);
    for tx=1:numel(peh),
        y{tx} = peh(tx);
    end;
    peh = y;
end;

for px=1:numel(peh)
	
	spikes=repmat(struct('cellid',0,'ts',[]),numel(cellid),1);	

    try
        s_time=peh{px}.states.state_0(1,2);
        e_time=peh{px}.states.state_0(2,1);
    catch
        fprintf(2,'End of session\n')
        continue
    end

    for sx=1:numel(cellid)
        spikes(sx).cellid=cellid(sx);
        spikes(sx).ts=qbetween(ts{sx}, s_time, e_time);	
    end
    peh{px}.spikes=spikes;
end

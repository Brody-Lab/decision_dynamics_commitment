function compnames = get_compnames


[ip_addr,rigid]=bdata('select ip_addr, rigid from ratinfo.riginfo order by rigid');
compnames = cell(0,3);
for rx=1:numel(rigid)
    if (rigid(rx) > 40 && rigid(rx) < 200) || rigid(rx) > 210 || rigid(rx) == 206
        continue;
    else
        compnames(end+1,:)={ip_addr{rx} num2str(rigid(rx)) ip_addr{rx}}; %#ok<AGROW>
    end
end

compnames(end+1,:)={'128.112.220.26' '70' '128.112.220.26'};


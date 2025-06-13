function rat=get_ratname(cellid)

rat=bdata('select ratname from cells where cellid="{S}"',cellid);
rat=rat{1};

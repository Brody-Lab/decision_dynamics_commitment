function single=is_single(cellid)

single=bdata('select single from cells where cellid="{S}"',cellid);

function [cstr]=getCellInfo(cellid)

[  eibid,sc_num,   cluster ,  single,   nSpikes ,  quality ,  overlap ,  iti_mn ,  iti_sd ,  trial_mn ,  trial_sd , filename]=bdata('select   eibid, sc_num,   cluster ,  single,   nSpikes ,  quality ,  overlap ,  iti_mn ,  iti_sd ,  trial_mn ,  trial_sd , filename from cells where cellid="{Si}"',cellid);
[region]=bdata('select region from ratinfo.eibs where eibid="{S}"',eibid); 

if isempty(region)
    region{1}='';
end

if isempty(sc_num)
	cstr='Sorry No cells here';
else
cstr=sprintf(['CellID: %i\nAD_Channel: %i\nCluster #: %i\nSingle? %i\n'...
	'# of Spikes: %i\nOverlap: %f\nBackround rate %.2f +/- %.2f Hz\n'...
	'Trial Rate %.2f +/- %.2f Hz\nEIB info: %s\n Filename:\n%s'],...
	 cellid, sc_num,   cluster ,  single,   nSpikes ,  overlap ,  iti_mn ,  iti_sd ,  trial_mn ,  trial_sd ,region{1}, filename{1});
end
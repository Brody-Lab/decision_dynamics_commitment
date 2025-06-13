function r=getRats(exprmtr_name)
try

   r=bdata('select ratname from ratinfo.rats where experimenter="{S}" and extant=1',exprmtr_name);
catch
end

if isempty(r)
	
    r={''};
end


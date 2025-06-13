function [x]=getExperimenters(op)

if ~op
	% get all experimenters
	
	ce=bdata('select distinct(experimenter) from ratinfo.rats where extant=1 order by experimenter');
    oe=bdata('select distinct(experimenter) from ratinfo.rats order by experimenter');
    
    keep=ones(size(oe));
    for ox=1:numel(oe)
        if any(strcmpi(oe{ox},ce)) || isempty(oe{ox})
            keep(ox)=0;
        end
    end
    
    oe=oe(keep==1);
    
    x=[ce;'Rigs'; oe];
    
else
	x=bdata('select distinct(experimenter) from sessions s,cells c where c.sessid=s.sessid order by experimenter');
end	
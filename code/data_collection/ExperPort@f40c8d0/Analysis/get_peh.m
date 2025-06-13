function peh=get_peh(varargin)
% peh=get_peh(sessid)
% peh=get_peh(ratname, sessiondate)



if nargin==1
	% Use sessid to get peh
	sessid=varargin{1};
	
else
	ratname=varargin{1};
	sdate=varargin{2};
	[sessid]=bdata('select sessid from sessions where ratname="{S}" and sessiondate="{S}"',ratname,sdate);
end

% Try to get peh from parsed_events table
peh=bdata('select peh from parsed_events where sessid="{S}"',sessid);
if isempty(peh)
	es=bdata('select evnt_strt from events where sessid="{Si}"',sessid);
	if isempty(es)
        protocol=bdata('select protocol from sessions where sessid="{S}"',sessid);        
        protocol=char(protocol);
		if ismember(lower(protocol), lower(bdata('show tables from protocol')))
			peh=bdata(['select ProtocolsSection_parsed_events from protocol.' protocol ' where sessid="{Si}"'],sessid);
			peh=convert_peh(peh);
		else
			fprintf(2,'Table protocol.%s does not exist\n',protocol);
		end
	else % we got the peh from events
		% Some of these are cells, some are not. eeek.
		peh=es{1}.peh;
		if iscell(peh(1))
			peh=cell2mat(peh);
		end
			
		
	end
else % we got the peh from parsed_events
	peh=peh{1};
end




function y=convert_peh(peh)
if ~isempty(peh)
	for tx=1:numel(peh)
		y(tx)=peh{tx}{1};
	end
	
	y=y(:);
else
	y=[];
end

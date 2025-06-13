% [] = sendtrial(obj)
%
% Pushes the scalar soloparamhandles for all trials to a table with the protocol name
%
%
% PARAMETERS:
% ----------
%
% obj     This is the protocol object
%



function [] = sendtrial(obj)
global global_check_flag;
try
[rigID e m] = bSettings('get','RIGS','Rig_ID');
if isnan(rigID)
    % if not running on a real rig, don't send to sql
	return
end    
protname=lower(class(obj));
    
% Check for a protocol table
if ~ismember(protname,lower(bdata('show tables from protocol')))
fprintf(2,'No table defined for this protocol');
return;
end

%get the column names for the protocol
[a,b,c,d,e,f]=bdata(['explain protocol.' protname]);

%The first 3 columsn MUST be sessid, trial_n and peh
if ~(strcmp(a{1},'sessid') &&strcmp(a{2},'trial_n'))
fprintf(2,'Malformed table for this protocol');
return;
end


sessid=getSessID(obj);



field_n=a(3:end);  % exclude sessid and n_trials
owner=class(obj);

% check if there are any methods with underscores.  If so freak out!
ms=methods(obj);
for mx=1:numel(ms)
	if strfind(ms{mx},'_')
		warning('sqlsummary:underscores','function names should not have underscores');
		
	end
end
	

% I have to make an exception for parsed events :(
	[fname{1},s]=strtok(field_n{1},'_');
	hname{1}=s(2:end);
% sending parsed_events_history to the server is now done in sendsummary	
%	peh=handle_hist('@dispatcher',fname{1},hname{1});
%

   vals{1}=[];

for fx=2:numel(field_n)	
	[fname{fx},s]=strtok(field_n{fx},'_');
	hname{fx}=s(2:end);
	vals{fx}=handle_hist(owner,fname{fx},hname{fx});
    for nx=1:numel(vals{fx})
        if isempty(vals{fx}{nx})
            vals{fx}{nx}='null';
        end
    end
end

colstr=field_n{2};
for vx=3:numel(fname)
	colstr=[colstr ',' field_n{vx} ];
end

pstr='"{Si}"';
for vx=2:numel(fname)
	pstr=[pstr ', "{S}"'];
end

varlist=',tx';
for vx=2:numel(fname)
	varlist=[varlist ', vals{' num2str(vx) '}{tx} '];
end

% check_vals(vals,field_n);

estr=['bdata(''insert into protocol.' protname ' (sessid, trial_n,' colstr ') values (' num2str(sessid) ',' pstr ')''' varlist ');'];

global_check_flag=0;
for tx=1:numel(vals{2})
	eval(estr);
end
catch
	showerror
	fprintf(2,'Failed to send');
end
global_check_flag=1;

% function check_vals(v,f)
% for i=1:numel(v)
% 	if ~isscalar(v{i}{1})
% 		f{i}
% 	end
% end
% 


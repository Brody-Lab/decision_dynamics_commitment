function load_old_data_into_protocoltable




curdir=pwd;

datadir=bSettings('get','GENERAL', 'Main_Data_Directory');
if isempty(datadir) || any(isnan(datadir))
	datadir=[filesep 'ratter'];
end

done=bdata('select distinct(sessid) from protocol.proanti2');
[all_sd,data_files,experimenters,ratnames,sessiondates]=bdata('select sessid,data_file,experimenter,ratname,sessiondate from sessions where protocol="proanti2" and experimenter="Carlos" order by experimenter');

[sess_todo, ix]=setdiff(all_sd, done);
if isempty(sess_todo)
	return;
end
experimenters=experimenters(ix);
ratnames=ratnames(ix);
data_files=data_files(ix);
sessiondates=sessiondates(ix);

[experimenters,ix]=sort(experimenters);
ratnames=ratnames(ix);
data_files=data_files(ix);
sessiondates=sessiondates(ix);
sess_todo=sess_todo(ix);
old_experimenter=experimenters{1};


for fx=1:numel(sess_todo)
	try
		data_file=data_files{fx};
		ratname=ratnames{fx};
		experimenter=experimenters{fx};
%		if ~strcmp(experimenter, old_experimenter)
%			remove_dir(old_experimenter);
%		end
		sessiondate=sessiondates{fx};
		sessid=sess_todo(fx);
		datapath=[datadir filesep 'Data' filesep experimenter filesep ratname filesep];
		% this is redundant, but easier than finding the unique rats....
		verifyPathCVS(datapath);
		
		cd(datapath);
		
		if isempty(data_file) % we'll have to try to guess the datafile name.
			sdate=sessiondate([3 4 6 7 9 10]);
			data_file=['data_@ProAnti2_' experimenter '_' ratname '_' sdate 'a.mat'];
		end
		
		% does our data file have the .mat extension?
		if ~strcmp('.mat',data_file(end-3:end))
			data_file=[data_file '.mat'];
		end
		%% get the file
		%  get all files for a the rat
		df=dir(data_file);
		if isempty(df)
			[sysout]=system(['cvs up ' data_file  ]);
		end
		
		%% Load the file.
		load(data_file);
		
		err=sendtrial(sessid, saved_history);
	catch
		showerror
		fprintf(1,'Failed to save %s to sql in save_soloparamvalues\n',data_file);
		err=1;
	end
	if err==0
	fprintf(1,'Session %d done\n',sessid);
	end
	clear saved saved_history
end


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



function [err] = sendtrial(sessid, saved_history)

%get the column names for the protocol
[a,b,b,b,b,b]=bdata('explain protocol.proanti2');
err=0;

peh_fn=a(3);
field_n=a(4:end);  % exclude sessid and n_trials

sh_fn=fieldnames(saved_history);
field_n=intersect(field_n,sh_fn);
field_n=[peh_fn; field_n(:)];

owner='ProAnti2';
	


for fx=1:numel(field_n)	
	[fname{fx},s]=strtok(field_n{fx},'_');
	hname{fx}=s(2:end);
	vals{fx}=saved_history.([fname{fx} '_' hname{fx}]);
    for nx=1:numel(vals{fx})
        if isempty(vals{fx}{nx})
            vals{fx}{nx}='null';
		elseif strcmp(hname{fx},'reward_baited')
			if strcmp(vals{fx}{nx},'give_reward')
				vals{fx}{nx}=1;
			else
				vals{fx}{nx}=0;
			end
		end
    end
end

colstr=field_n{1};
for vx=2:numel(fname)
	colstr=[colstr ',' field_n{vx} ];
end

pstr='"{Si}","{M}"';
for vx=2:numel(fname)
	pstr=[pstr ', "{S}"']; %#ok<*AGROW>
end

varlist=',tx,vals{1}(tx)';
for vx=2:numel(fname)
	varlist=[varlist ', vals{' num2str(vx) '}{tx} '];
end

check_vals(vals,field_n);

estr=['bdata(''insert into protocol.' owner ' (sessid, trial_n,' colstr ') values (' num2str(sessid) ',' pstr ')''' varlist ');'];

try
for tx=1:numel(vals{1})
	eval(estr);
end
catch
	showerror
	fprintf(2,'Failed to send');
	err=1;
end

function check_vals(v,f)
for i=1:numel(v)
	if ~isscalar(v{i}{1})
		f{i}
	end
end





function [vals,varargout]=check_sphDB(name, varargin)
% [vals]=check_sphDB(sph_name, varargin)
% [vals, rat, date, trial_n]=check_sphDB(sph_name, varargin)
% Usage: if you want to check the value of a certain sph that is in the
% protocols table for your protocol.
%
%
% eg. val=check_sphDB('goodPoke3','ratname','J033','sessiondate','2008-06')
%
% will return the goodPoke3 value from each trial for J033 in June 2008 ordered from earliest to latest.
%
% eg. val=check_sphDB('goodPoke3','protocol','proanti2','sessiondate','2008-06-05')
%
% Will return the goodPoke3 for ALL rats running the proanti2 protocol on
% June 5, 2008.  Note, your query will run much slower if you don't specify
% a rat. (This one took 9 seconds)
%
% if you use a vague name,
%
% eg. check_sphDB('AntiBias','ratname','J033','sessiondate','2008-06')
%
% You get a helpful message that shows all the matching names, so you can
% specify which one you like.
%
% If you specify a sessid you don't need any other specifiers other than
% the sph_name
%
% trial_n		a str with a logical expression. e.g. '=1' or  '<100'
% regexp_name	if this is set to 1, then instead of exactly matching the
%				ratname, we will regexp against the ratname.
% 
% pairs={'ratname'        , '*';...
% 	'sessid'         , [];...
% 	'protocol'       , '';...
% 	'experimenter'   , '%';...
% 	'sessiondate'    , '*';...
% 	'sph_name'       , '';...
% 	'trial_n'        , '>0';...
% 	'regexp_name'    , 0;...
% 	'vals'			, []};


pairs={'ratname'        , '*';...
	'sessid'         , [];...
	'protocol'       , '';...
	'experimenter'   , '%';...
	'sessiondate'    , '*';...
	'sph_name'       , '';...
	'trial_n'        , '';...
	'regexp_name'    , 0;...
	'vals'			, []};
parseargs(varargin,pairs);

if nargin==0
	warning('You must specify an SPH name');

	return
end



	if isempty(sessid) && isempty(ratname)
		[answ]=inputdlg('this query will take a long time, because you have not specified a rat\n Continue?');
		if answ(1)=='N' || answ(1)=='C'

			return;
		end
	end


	if isempty(sessid) && isempty(protocol) && ratname(1)=='*'
		warning('You must provide  either a ratname or a protocol or a sessid')

		return;
	elseif isempty(protocol)
		if isempty(sessid)
			if regexp_name
				protocol=bdata('select protocol from sessions where ratname regexp "{S}" order by sessiondate desc limit 1', ratname);
			else
				protocol=bdata('select protocol from sessions where ratname="{S}" order by sessiondate desc limit 1', ratname);

			end
		else
			protocol=bdata('select protocol from sessions where sessid="{S}"', sessid(1));
		end
		protocol=protocol{1};
	end

	% get all matching fields
	[fullname,b,b,b,b,b]=bdata(['show columns from protocol.' protocol ' where field regexp "{S}"'], name);

	if numel(fullname)~=1
		helpdlg([{'The SPH name matched the following names:'}; fullname ; {'Please be more specific'}])

		if nargout>0
			vals=fullname;
			for ox=2:nargout
				varargout{ox-1}=[];
			end
		end
		%if ans(1)=='N' || ans(1)=='C'
		%    return;
		% end
		return;
	end

	if ratname=='*'
		rat_clause='';
	elseif regexp_name
		rat_clause=[' ratname regexp "' ratname '" and '];
	else
		rat_clause=[' ratname = "' ratname '" and '];
	end

	if sessiondate=='*'
		sdate_clause='';
	else
		sdate_clause=[' sessiondate regexp "' sessiondate '" and '];
	end

	if experimenter=='%'
		experimenter_clause='';
	elseif strfind(experimenter,'%')
		experimenter_clause=[' experimenter like "' experimenter '" and '];
	else
		experimenter_clause=[' experimenter = "' experimenter '" and '];
	end

	if isempty(protocol)
		protocol_clause='';
	else
		protocol_clause=[' protocol = "' protocol '" and '];
	end

	
if isempty(trial_n)
	trial_clause='';
else
	trial_clause=[' trial_n ' trial_n ' and '];
end
	


	% make cases based on the inputs to make this more efficient.
	% also i think first make a temp table of sessids based on the
	% date/experimenter/ratname.  THEN fetch the rows of the protocol table.
	%

	% vals=bdata(['select '  fullname{1} ' from protocol.' protocol ' as p, sessions as s where s.sessid=p.sessid and ratname = "{S}" and experimenter like "{S}" and sessiondate regexp "{S}"'],...
	%     ratname, experimenter, sessiondate);
	if isempty(sessid)
		[ratname, protocol, sdate,sessid]=bdata(['select ratname, protocol,sessiondate,sessid from sessions where  ' rat_clause experimenter_clause protocol_clause sdate_clause ' true order by sessiondate']);
	else
		for sx=1:numel(sessid)
			[ratname, protocol, sdate]=bdata('select ratname, protocol,sessiondate from sessions where sessid="{S}"',sessid(sx));
		end
    end
	
    if isempty(sessid)
        		warning('check_sphDB:no_data','No sessions matched your request.')
                vals=[];
                for vox=2:nargout
                    varargout{vox}=[];
                end
                return
    end
    
	if numel(unique(protocol))~=1

		return;
	else
		protocol=protocol{1};
	end



if nargout>1
	ratlist={};
	sdatelist={};
	trials=[];
	valx=1;
	for sx=1:numel(sessid)
		[t,v]=bdata(['select trial_n,'  fullname{1} ' from protocol.' protocol ' as p where ' trial_clause ' p.sessid=' num2str(sessid(sx))]);
		vals=[vals;v];
		trials=[trials;t];
		ratlist(valx:valx+numel(v)-1,:)=repmat(ratname(sx),numel(v),1);
		sdatelist(valx:valx+numel(v)-1,:)=repmat(sdate(sx),numel(v),1);
		valx=valx+numel(v);
	end
	varargout{1}=(ratlist);
	varargout{2}=(sdatelist);
	varargout{3}=trials;


else
	for sx=1:numel(sessid)
		v=bdata([' select '  fullname{1} ' from protocol.' protocol ' as p where ' trial_clause ' p.sessid=' num2str(sessid(sx))]);
		vals=[vals;v];
	end
end





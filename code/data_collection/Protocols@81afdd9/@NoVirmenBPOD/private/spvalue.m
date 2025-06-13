% [val] = spvalue(funcname, varname, trialnum)
% []    = spvalue({'set_owner', owner});
% [val] = spvalue({'get_owner'});
% []    = spvalue({'set_trialnum', trialnum});
% [val] = spvalue({'get_trialnum'});
%
%
% If funcname, varname, and trialnum are all present, returns the value of
% the SoloParamHandle for the previously set owner, fullname [funcname '_' varname]
% for the trial number trialnum.
%
% If trialnum is missing, uses the previously set trialnum.
%
% To set owner or trialnum, use a call where the first param, funcname, is
% a cell; see call examples above.

% CDB Mar 2008

function [val] = spvalue(funcname, varname, this_trialnum)

persistent owner
persistent trialnum
persistent t_bdata

if nargin==3, trialnum = this_trialnum; end;

if nargin==1,
	switch funcname{1},
		case 'set_owner',
			owner = funcname{2};
			t_bdata=[];
		case 'get_owner',
			val = owner;
		case 'set_trialnum',
			trialnum = funcname{2};
		case 'get_trialnum',
			val = trialnum;
		otherwise
			warning('InvalidRequest:spvalue', 'Don''t know command "%s"', funcname)
	end;

	return;
end;

% try to get the local variable
val = handle_hist(owner, funcname, varname, trialnum);

% if there is none, try to get it from the database.
if isempty(val)

	full_varname=[funcname '_' varname];

	% if the t_bdata struct is empty, fill it 
	if isempty(t_bdata) || ~ismember(full_varname, fieldnames(t_bdata))
			protocol=neurobrowser('get_protocol');

		if ismember(lower(protocol),lower(bdata('show tables from protocol')))

			sessid=neurobrowser('get_sessid');
			full_varname=[funcname '_' varname];

			sqlstr=['select ' full_varname ' from protocol.' protocol ' where sessid=' num2str(sessid)];
			[tval]=bdata(sqlstr);
			t_bdata.(full_varname)=tval;

		end
	end
		
	
		% get the value from the bdata persistent
		try
			val=t_bdata.(full_varname)(trialnum);
		catch
		end

	end
end



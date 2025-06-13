function tsm = extract_alignment(mysessid, str, peh)
% function tsm = extract_alignment(mysessid, str, peh)
%
% returns a vector of times the events specified by str occured in each
% trial in session = mysessid; the third parameter peh is optional
%
% str is the alignment string, which must be in pseudo-pokesplot-style syntax. 
% may be joined by operators (e.g., +,-,*,/) with some evaluated spvalue, 
% as long as the sph had been saved to the protocols table. The shorthand
% pk. stands for "pokes.", and ps. stands for "states." Normally str should
% evaluate to a double, and this will be the alignment time. But sometimes
% more complex syntax precludes this; in those cases, make sure that a
% variable named "this_trial" acquires a value upon string evaluation; that
% will be the alignment time used.
%
% example str's include:
%
% ps.cpoke1(end,2)
% pk.C(end,2)
% ps.cpoke1(1,1) + spvalue(StimulusSection_fixed_stim_dur)
% ps.wait_for_spoke(1,2) - 2*spvalue(RewardsSection_reward_delay)
% u = find(pk.C(:,1)<ps.wait_for_spoke(end,1),1,'last'); this_trial=pk.C(u,2)
%
% **: note that the name of the sph must be its full name and not in quotes
%
% if a third parameter is provided, it is used as the peh (faster); 
% otherwise, we'll get it from the sql
%
% BWB, June 2009

[sessid protocol] = bdata('select sessid,protocol from sessions where sessid="{Si}"', mysessid);
if isempty(sessid),
	fprintf(2, 'Cannot find session %d in the sessions table', mysessid);
	tsm = [];
	return;
end;

str = str(~isspace(str)); % get rid of all spaces

% first get the peh
if nargin < 3,
	peh = get_peh(sessid);
end;

% next get all the requested soloparamhandle values
sp = strfind(str, 'spvalue');
if isempty(sp),
	spnames = {};
else
	for k = 1:length(sp),
		% get the name of the requested sp
		tstr = str(sp(k):end);
		tstr_end = find(tstr==')', 1, 'first');
		if isempty(tstr_end) || tstr(8)~='(',
			fprintf(1, 'There"s a syntax error, parens must come in matching pairs; correct before proceeding\n');
			tsm = [];
			return;
		end;
		tstr = tstr(1:tstr_end);
		spnames{k} = tstr(9:end-1); %#ok<AGROW>
	end
end;

% go to the protocols table to find the spvalues
% then store the values
for k = 1:length(spnames),
	sqlstr = sprintf(['select ' spnames{k} ' from protocol.' protocol{1} ' where sessid="{Si}"']);
	try
		val = bdata(sqlstr, sessid);
	catch
		fprintf(2, ['Cannot find sph ' spnames{k} ' from session %d in the ' protocol{1} ' protocol\n'], sessid);
		tsm = [];
		return;
	end;
	spvalues{k} = val; %#ok<AGROW,NASGU>
end;

% now go through every trial and evaluate str
tsm = zeros(length(peh), 1);
for i = 1:rows(peh),
	ps = peh(i).states; %#ok<NASGU>
    pk = peh(i).pokes;  %#ok<NASGU>
	if ~isempty(spnames),
		for k = 1:length(spnames),
			eval(sprintf([spnames{k} ' = spvalues{%d}(%d);'], k, i));
		end;
	end;
	
	try  % First try to see whether the alignment string returns a double:
		tsm(i) = eval(str);
    catch %#ok<CTCH>
      try % Alignment string didn't return a double, see if a variable called 
          % "this_trial" is defined somewhere in the alignment string.
        eval([str ';']); % Semicolon is to make sure no returns in str get printed to console
        if exist('this_trial', 'var'),
          tsm(i) = this_trial;
        else
          tsm(i) = NaN;  % Couldn't find 'this_trial'
        end;
      catch % Couldn't make it work %#ok<CTCH>
		tsm(i) = NaN;
      end;
	end;
end;

end

function v = spvalue(sp)
	v = sp;
end
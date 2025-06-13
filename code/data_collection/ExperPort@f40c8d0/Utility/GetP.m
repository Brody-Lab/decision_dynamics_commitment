function out = GetP(varargin)
% GETP
% Return values from the structure referred to by a structure pointer.
% 		
% VAL = GETP(SP)
% 		Return the structure
%
% VAL = GETP(SP,FIELD)
% 		Return the value of a FIELD
% 
% The structure pointer SP is simply a string which names the structure:
% for a STUCT named exper.control.param, SP = 'exper.control.param'
% SP can be a cell array of structure names, SP = {'s1','s2'}, in which
% case the output is a corresponding cell array 
% FIELD can also be a cell array of field names, FIELD = {'f1','f2'},
% in which case the output is a corresponding cell array VAL = {'v1','v2'}
% If both FIELD and SP are cell arrays, the return value is a cell matrix.
%
% ZF MAINEN, CSHL, 8/00
%

sp = varargin{1};
if ~iscell(sp) sp = {sp}; end

out = [];

for p=1:length(sp)
	% Here's the trick to make the pointer work!
	s = evalin('caller',sp{p});

	if ~isstruct(s)
		out{p} = [];
	elseif nargin == 1
		% A single parameter means we return just the struct
		out{p} = s;
	else
		field = varargin{2};
		if ~iscell(field) field = {field}; end
		c = 1;
		for n=1:length(field)
			f = field{n};
			if isfield(s,f)
				out{p,c} = getfield(s,f);
				c = c+1;
			end
		end
	end
end

out = stripcell(out);

	
	
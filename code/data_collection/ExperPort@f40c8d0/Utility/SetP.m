function out = SetP(varargin)
% SETP
% Set values in the structure referred to by a structure pointer.
% The structure pointer SP is simply a string which names the structure:
% STRUCT = exper.control.param WOULD MEAN SP = 'exper.control.param'.
% NOTE: acts directly on the structure, not on a copy.
% 		
% STRUCT = SETP(SP)
% 		Return the structure from the structure pointer, untouched
% STRUCT = SETP(SP,FIELD,VALUE)
% 		Set the value of one FIELD to VALUE
% STRUCT = SETP(SP,FIELD1,VALUE,[FIELD2,VALUE2],...,[FIELDN,VALUEN])
%		Set the values of multiple FIELD names
% 	
% SP can be a cell array of structure names, in which case all 
% structures with FIELD have it set to VALUE. It is not an error
% to operate on structures that do not have FIELD.
%
% ZF MAINEN, CSHL, 8/00
%

sp = varargin{1};
if ~iscell(sp) sp = {sp}; end
	
for p=1:length(sp)

	% here we get the actual structure
	s = evalin('caller',sp{p});

	% There are no fields unless this is a structure
%	if ~isstruct(s)
%		out{p} = [];
%	elseif nargin == 1
	if nargin == 1
		% A single parameter means we return just the structure
		out{p} = s;
	else
		c = 1;
		for n=2:2:nargin
			f = varargin{n};
			if isempty(inputname(n+1))
			% input is not a variable, but just a calaculation
			% try to evaluate it here
				a = varargin{n+1};
				if isnumeric(a)
					vs = mat2str(a);
				elseif isstr(a)
					vs = sprintf('''%s''',a);
				else
					message('Setp cannot handle this kind of assignment!','error');
				end
			else
				vs = inputname(n+1);
			end
			spfv = sprintf('%s.%s = %s;',sp{p},f,vs);
			evalin('caller',spfv);
			c = c+1;
		end
	end
	out{p} = evalin('caller',sp{p});
end

out = stripcell(out);
	

	
	
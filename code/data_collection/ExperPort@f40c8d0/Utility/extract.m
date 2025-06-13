function [out, varargout] = extract(s,field,ind)
% EXTRACT
% Extract a vector values from a specified field of a structure array 
% (currently must be 1 dimensional).
% SYNTAX: VEC = EXTRACT(S,FIELD,[IND])
% FIELD is a string, IND is an optional vector of indices

if nargin < 3
	ind = 1:length(s);
end

p = 0;
for n=ind
	p = p+1;
	val = getfield(s(n),field);	
	if ~isnumeric(val) 
		out(p) = {val};
	else
		out(p) = val;
	end
end


	
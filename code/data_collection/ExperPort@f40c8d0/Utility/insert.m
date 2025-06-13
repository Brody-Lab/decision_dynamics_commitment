function out = insert(s,field,vec,ind)
% INSERT
% Insert a vector values into a specified field of a structure array 
% (currently must be 1 dimensional).
% SYNTAX: S = INSERT(S,FIELD,VEC,[IND])
% FIELD is a string, IND is an optional vector of indices

if nargin < 4
	ind = 1:length(s);
end

for n=1:length(vec)
	p = ind(n);
	s(p) = setfield(s(p),field,vec(n));	
end
out = s;


	
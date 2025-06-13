function I = intersection(varargin)
if nargin < 2, I = []; return; end;
I = intersect(varargin{1}, varargin{2});
for n = 3:nargin,
	I = intersect(I, varargin{n});
end;
return;
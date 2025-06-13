function obj=set(obj, varargin)

if nargin<2
    warning('Must pass in a valid fieldname');
else
    for xi=1:(nargin-1)/2

        obj.(varargin{2*xi-1})=varargin{2*xi};
    end
end


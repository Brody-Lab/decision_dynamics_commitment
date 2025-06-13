function SetProperties(obj,varargin)

%
% SetProperties(obj,varargin)
%

for k=1:2:numel(varargin), obj.(varargin{k})=varargin{k+1}; end
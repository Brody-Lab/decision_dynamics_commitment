function varargout = shadeplot(x,lower,upper,varargin)
% SHADEPLOT plot a horizontal strip of shading
%   SHADEPLOT(X,LOWER,UPPER) plots a strip of shading defined by x-values X, lower bounds LOWER
%   along the y-axis, and upper bounds UPPER
%
%   SHADEPLOT(...,PARAM1,VAL1,PARAM2,VAL2,...) specifies one or more of the following name/value
%   pairs:
%
%       'FaceAlpha'     transparency of the shading, specified as a scalar value between 0 and 1
%                       inclusive. A value of 1 means completely opaque and 0 means completely
%                       transparent (invisible).
%
%       `FaceColor`     shading color, specified a three-element array representing the red, green,
%                       and blue components of the color. The intensities must be in the range
%                       [0,1]; for example, [0.5, 0.5, 1] for periwinkle.
%
%   Examples:
%       % plot shading representing the intervals containing 95% of simualted trajectories of Weiner
%       process
%       W = cumsum(randn(100,100),2)
%       FHMDDM.shadeplot(1:100, quantile(W, 0.025), quantile(W, 0.975))
%
%       % plot shading representing the 95% confidence intervals of the sample mean at each time 
%       step, estimated using bootstrapping
%       W = cumsum(randn(100,100),2)
%       ci = bootci(1000, @mean, W)
%       FHMDDM.shadeplot(1:100, ci(1,:), ci(2,:))
parser = inputParser;
addParameter(parser, 'facealpha', 0.2, ...
    @(x) validateattributes(x, {'numeric'}, {'scalar', '>=', 0, '<=', 1}))
addParameter(parser, 'facecolor', [0,0,0], ...
    @(x) validateattributes(x, {'numeric'}, {'numel', 3, '>=', 0, '<=', 1}))
parse(parser, varargin{:});
P = parser.Results; 
Y=[upper(:), lower(:)-upper(:)];
h = area(x,Y);
set(h(2),'edgecolor','none','facecolor', P.facecolor, 'facealpha', P.facealpha);
set(h(1),'EdgeColor','none','FaceColor', 'none');
if nargout > 0
    varargout{1} = h(2);
end
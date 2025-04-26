function [X,Y,Xdot,Ydot] = flows(hypothesis, component, varargin)
% generate flow field of a component of the deterministic dynamics of a given hypothesis
%
% ARGUMENT
%   `hypothesis`: a `char` or `string` identifying an attractor hypothesis
%
%   `component`: the component of the dynamics: "intrinsic", "leftinput", or "rightinput" 
%
% RETURN
%   `X`: a matrix indicating the values of the first dimension of the latent
%   
%   `Y`: a matrix indicating the values of the second dimension
%   
%   `Xdot`: a matrix indicating the drift along the first dimension
%   
%   `Ydot`: a matrix indicating the drift along the second dimension
%
% OPTIONAL ARGUMENT
%   'Delta_scale': a scale factor the default spacing, useful for plotting a heatmap
%
%   'apply_default_scale': whether to apply pre-specified scaling for the spacing
P = inputParser;
addParameter(P, 'Delta_scale', 1, @(x) isnumeric(x) && isscalar(x))
addParameter(P, 'apply_default_scale', true, @(x) islogical(x) && isscalar(x))
parse(P, varargin{:});
P = P.Results;
Specs = common.specify_flows;
Delta = Specs.Delta*P.Delta_scale;
if P.apply_default_scale
    Delta = Delta*Specs.Delta_scale.(component);
    offset = contains(component, "input")*Delta/2;
else
    offset = 0;
end
[X,Y] = meshgrid(Specs.xlim(1)+offset:Delta:Specs.xlim(2), ...
    Specs.ylim(1)+offset:Delta:Specs.ylim(2));
yoffset = -0.01;
if component == "intrinsic"
    switch hypothesis
        case "bistable"
            Xdot = -X.*(X+0.85).*(X-0.85);
            Ydot = -0.75*(Y-yoffset);
        case "DDM1"
            Xdot = zeros(size(X));
            Ydot = -1.5*(Y-yoffset);
            indices = (X >= 0.7) | (X<=-0.7);
            Xdot(indices) = 1.5*X(indices).*(0.49-X(indices).^2);
        case "RNN"
            Xdot = 1.5 * Y;
            Ydot = -1.5 * (Y-yoffset);
        case "noncanonical"
            Xdot = 5*(X-0.01).*(0.85+X).*(0.85-X);
            Ydot = 5*(0.5*abs(X)+0.1).*(X-2*(Y-yoffset));
    end
else
    sizes = size(X);
    inputsign = 2*(component=="rightinput") - 1;
    if hypothesis == "RNN"
        Ydot = inputsign*ones(sizes);
        Xdot = zeros(sizes);
    else
        Xdot = inputsign*ones(sizes);
        Ydot = zeros(sizes);
    end
end

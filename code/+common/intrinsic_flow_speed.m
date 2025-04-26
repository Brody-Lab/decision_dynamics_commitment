function [speed, X, Y] = intrinsic_flow_speed(hypothesis, varargin)
% speed of intrinsic flows for a given attractor hypothesis
%
% ARGUMENT
%   `hypothesis`: a `char` or `string` identifying an attractor hypothesis
%
% RETURN
%   `speed`: a matrix indicating the magnitude of the flow at each value of the latent variable
%
%   `X`: matrix containing the values of the first dimension of the latent
%
%   `Y`: matrix containing the values of the second dimension of the latent
%
% OPTIONAL ARGUMENT
%   `Delta_scale`: a scale factor the default spacing, useful for plotting a heatmap
P = inputParser;
addParameter(P, 'Delta_scale', 0.1, @(x) isnumeric(x) && isscalar(x))
parse(P, varargin{:});
P = P.Results;
[X,Y,Xdot,Ydot] = common.flows(hypothesis, 'intrinsic', 'Delta_scale', P.Delta_scale);
speed = (Xdot.^2 + Ydot.^2).^0.5;
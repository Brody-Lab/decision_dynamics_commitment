function [speed, X, Y] = input_flow_speed(hypothesis, varargin)
% speed of input flows for a given attractor hypothesis
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
%
%   'apply_default_scale': whether to apply pre-specified scaling for the spacing
P = inputParser;
addParameter(P, 'apply_default_scale', true, @(x) islogical(x) && isscalar(x))
addParameter(P, 'Delta_scale', 0.1, @(x) isnumeric(x) && isscalar(x))
parse(P, varargin{:});
P = P.Results;
[X,Y,Xdot_L,Ydot_L] = M23a.flows(hypothesis, 'leftinput', 'Delta_scale', P.Delta_scale, ...
    'apply_default_scale', P.apply_default_scale);
[~,~,Xdot_R,Ydot_R] = M23a.flows(hypothesis, 'rightinput', 'Delta_scale', P.Delta_scale, ...
    'apply_default_scale', P.apply_default_scale);
speed_L = (Xdot_L.^2 + Ydot_L.^2).^0.5;
speed_R = (Xdot_R.^2 + Ydot_R.^2).^0.5;
speed = (speed_L+speed_R)/2;
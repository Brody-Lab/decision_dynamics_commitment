function [difference, X, Y] = flow_speed_difference(hypothesis, varargin)
% difference in the speed of between input and intrinsic dynamics
%
% ARGUMENT
%   `hypothesis`: a `char` or `string` identifying an attractor hypothesis
%
% RETURN
%   `difference`: a matrix indicating the difference at each value of the latent variable
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
[intrinsicspeed, X, Y] = M23a.intrinsic_flow_speed(hypothesis, 'Delta_scale', P.Delta_scale);
[inputspeed, X2, Y2] = M23a.input_flow_speed(hypothesis, 'Delta_scale',  P.Delta_scale, ...
    'apply_default_scale', false);
difference = inputspeed - intrinsicspeed;
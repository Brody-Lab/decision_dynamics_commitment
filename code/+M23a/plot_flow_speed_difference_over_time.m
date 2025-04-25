function [] = plot_flow_speed_difference_over_time(hypothesis, varargin)
% change in the difference in the flow speed for a given attractor hypothesis
%
% ARGUMENT
%
%   `hypothesis`: a 'char' row vector specifying the attractor model
%
% OPTIONAL ARGUMENT
%   `axes`: The graphics object where the flow field is plotted. The default is the current axes
P = inputParser;
addParameter(P, 'axes', gca, @(x) ishandle(x))
parse(P, varargin{:});
P = P.Results;
axes(P.axes)
M23a.stylizeaxes  
timesteps = 0:0.1:1;
xlim([min(timesteps), max(timesteps)])
ylim([0.5 1.5])
xticks([])
yticks([])
if hypothesis == "noncanonical"
    plot(timesteps, timesteps*-1 + 1.5, 'k', 'linewidth', 2)
else
    plot(timesteps, ones(size(timesteps)), 'k', 'linewidth', 2)
end
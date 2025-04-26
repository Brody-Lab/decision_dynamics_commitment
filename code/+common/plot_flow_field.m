function plot_flow_field(hypothesis, component, varargin)
% Plot the flow field corresponding to an attractor hypothesis of perceptual decision-making
%
% ARGUMENT
%   `hypothesis`: a `char` or `string` identifying an attractor hypothesis
%
%   `component`: the component of the dynamics: "intrinsic", "leftinput", or "rightinput" 
%
% OPTIONAL ARGUMENT
%
%   'apply_default_scale': whether to apply pre-specified scaling for the spacing
%
%   `axes`: The graphics object where the flow field is plotted. The default is the current axes
%
%   Delta_scale: a scale factor the default spacing, useful for plotting a heatmap
    P = inputParser;
    addParameter(P, 'apply_default_scale', true, @(x) islogical(x) && isscalar(x))
    addParameter(P, 'axes', gca, @(x) ishandle(x))
    addParameter(P, 'Delta_scale', 1, @(x) isnumeric(x) && isscalar(x))
    parse(P, varargin{:});
    P = P.Results;
    Specs = common.specify_flows;
    colors = common.colors;
    [X,Y,Xdot,Ydot] = common.flows(hypothesis, component, 'Delta_scale', P.Delta_scale, ...
        'apply_default_scale', P.apply_default_scale);
    axes(P.axes)
    xticks([])
    yticks([])
    common.stylizeaxes    
    set(gca, 'dataaspectratio', [1,1,1])
    quiver(X,Y,Xdot,Ydot,'color', colors.(component), ...
        'autoscalefactor', Specs.quiverscale.(component), ...
        'linewidth', Specs.linewidth)
    xlim(Specs.xlim)
    ylim(Specs.ylim)
end
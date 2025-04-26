function varargout = plot_flow_speed(hypothesis, component, varargin)
% Plot the flow speed corresponding to an attractor hypothesis of perceptual decision-making
%
% ARGUMENT
%   `hypothesis`: a `char` or `string` identifying an attractor hypothesis
%
%   `component`: the component of the dynamics: "intrinsic", "leftinput", or "rightinput" 
%
% OPTIONAL ARGUMENT
%   `axes`: The graphics object where the flow field is plotted. The default is the current axes
%
%   'Delta_scale': a scale factor the default spacing, useful for plotting a heatmap
%
% OPTIONAL OUTPUT
%
%   1) handle to the color bar
    P = inputParser;
    addParameter(P, 'axes', gca, @(x) ishandle(x))
    addParameter(P, 'Delta_scale', 0.1, @(x) isnumeric(x) && isscalar(x))
    parse(P, varargin{:});
    P = P.Results;
    Specs = common.specify_flows;
    switch component
        case 'intrinsic'
            magnitude = log(common.intrinsic_flow_speed(hypothesis, 'Delta_scale', P.Delta_scale));
        case 'input'
            magnitude = log(common.input_flow_speed(hypothesis, 'Delta_scale', P.Delta_scale));
        case 'difference'
            magnitude = tanh(common.flow_speed_difference(hypothesis, 'Delta_scale', P.Delta_scale));
    end
    axes(P.axes)
    common.stylizeaxes    
    set(gca, 'dataaspectratio', [1,1,1])
    xlim(Specs.xlim)
    ylim(Specs.ylim)
    xticks([])
    yticks([])
    imagesc(Specs.xlim, Specs.ylim, magnitude)
    colormap(gca, Specs.colormap.(component))
    hcb = colorbar;
    hcb.Ticks = hcb.Limits;
    switch component
        case 'intrinsic'
            hcb.TickLabels = {'slow', 'fast'};
        case 'input'
            hcb.TickLabels = {'slow', 'fast'};
        case 'difference'
            hcb.TickLabels = {'intrinsic-dominant', 'input-dominant'};
    end
    hcb.FontSize = 18;
    if nargout > 0
        varargout{1} = hcb;
    end
end
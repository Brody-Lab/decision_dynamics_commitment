function plot_PCTH_choice_difference(Diff, varargin)
% plot the difference in the peri-stimulus time histograms between choices
validateattributes(Diff, {'struct'}, {'scalar'})
parser = inputParser;
addParameter(parser, 'axes', gca, @(x) ishandle(x) && isscalar(x))
addParameter(parser, 'plot_observed_ci', false, @(x) islogical(x) && isscalar(x))
addParameter(parser, 'plot_observed_est', true, @(x) islogical(x) && isscalar(x))
addParameter(parser, 'plot_shuffled_ci', false, @(x) islogical(x) && isscalar(x))
addParameter(parser, 'plot_shuffled_est', false, @(x) islogical(x) && isscalar(x))
parse(parser, varargin{:});
P = parser.Results; 
axes(P.axes)
M23a.stylizeaxes
Specs = M23a.specify_pericommitment_analyses;
if P.plot_shuffled_ci
    M23a.shadeplot(Diff.time_s, Diff.shuffled.ci(1,:), Diff.shuffled.ci(2,:), 'facealpha', 0.1);
end
if P.plot_shuffled_est
    plot(Diff.time_s, Diff.shuffled.est, 'k--', 'linewidth', Specs.linewidth);
end
if P.plot_observed_ci
    M23a.shadeplot(Diff.time_s, Diff.observed.ci(1,:), Diff.observed.ci(2,:), 'facealpha', 0.4);
end
if P.plot_observed_est
    plot(Diff.time_s, Diff.observed.est, 'k-', 'linewidth',  Specs.linewidth);
end
xlim([min(Diff.time_s), max(Diff.time_s)])
xticks([min(Diff.time_s), 0, max(Diff.time_s)])
if ~contains(Diff.ylabel, 'PC')
    ylim([0 ceil(max(ylim))])
    yticks(ylim)
    ylabel(Diff.ylabel, 'rotation', 0)
    title(' ')
else
    title(Diff.ylabel, 'rotation', 0)
    ylabel(' ')
end
xlabel('time from commitment (s)')

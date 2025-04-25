function plot_peth(pethset, condition, time_s, varargin)
%PLOT_PETH Plot the peri-event time histogram (PETH) of one neuron under on task condition
%   PLOT_PETH(PETHSET, CONDITION, TIME_S) plots the PETH in the task condition specified by the
%   string array CONDITION. The portion of the PETH to be plotted is specified by the vector TIME_S.
%
%   PLOT_PETH(...,PARAM1,VAL1,PARAM2,VAL2,...) specifies one or more of the following name/value
%   pairs:
%
%       `Axes`                      The axes in which the plots are made
%
%       'Linestyle_observed_mean'   A character row vector specifying the style of the line 
%                                   representing the observed mean. If it is empty, the mean is
%                                   not shown.
%
%       'Linestyle_predicted_mean'  A character row vector specifying the style of the line
%                                   representing the predicted mean. If empty, the mean is not
%                                   shown.
%
%       'Referenceevent'            A character row vector or a string specifying the event in the 
%                                   trial to which the PETH is aligned in time
%
%       'Show_observed_CI'          A scalar logical indicating whether the bootstrap confidence 
%                                   interval of the observed PETH should be plotted
%
%   Example:
%       % plot simulated peri-event time histograms
%       S = struct;
%       time_s = (0:99)*0.01;
%       figure
%       for condition = ["leftchoice", "rightchoice"]
%           S.(condition).predicted = sin(time_s)*(1+(condition=="rightchoice"));
%           noisy = poissrnd(repmat(S.(condition).predicted,100,1));
%           S.(condition).observed = mean(noisy);
%           ci = bootci(1e3, @mean, noisy);
%           S.(condition).lowerconfidencelimit = ci(1,:);
%           S.(condition).upperconfidencelimit = ci(2,:);
%           FHMDDM.plot_peth(S, condition, time_s)
%       end
validateattributes(pethset, {'struct'},{'scalar'})
validateattributes(condition, {'string'},{'scalar'})
validateattributes(time_s, {'numeric'}, {})
parser = inputParser;
addParameter(parser, 'axes', [], ...
    @(x) validateattributes(x, {'matlab.graphics.axis.Axes'},{'scalar'}))
addParameter(parser, 'linestyle_observed_mean', '--', @(x) ischar(x))
addParameter(parser, 'linestyle_predicted_mean', '-', @(x) ischar(x))
addParameter(parser, 'referenceevent', 'stereoclick', @(x) validateattributes(x, {'char'},{'row'}))
addParameter(parser, 'show_observed_CI', true, @(x) validateattributes(x, {'logical'},{'scalar'}))
parse(parser, varargin{:});
P = parser.Results; 
if isempty(P.axes)
    gca;
else
    axes(P.axes)
end
FHMDDM.prepareaxes
Colors = FHMDDM.colors;
nbins = numel(time_s);
if P.show_observed_CI
    lower = pethset.(condition).lowerconfidencelimit(1:nbins);
    upper = pethset.(condition).upperconfidencelimit(1:nbins);
    FHMDDM.shadeplot(time_s, lower, upper, 'facecolor', Colors.(condition));
end
if ~isempty(P.linestyle_observed_mean)
    plot(time_s, pethset.(condition).observed(1:nbins), P.linestyle_observed_mean, ...
        'linewidth', 1.5, ...
        'color', Colors.(condition))
end
if ~isempty(P.linestyle_predicted_mean)
    plot(time_s, pethset.(condition).predicted(1:nbins), P.linestyle_predicted_mean, ...
        'linewidth', 1.5, ...
        'color', Colors.(condition))
end
ylabel('spikes/s')
xlabel(['time from ' char(P.referenceevent), ' (s)'])
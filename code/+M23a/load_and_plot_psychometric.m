function load_and_plot_psychometric(datapath, expectedemissionspath, varargin)
parser = inputParser;
addParameter(parser, 'axes', [], ...
    @(x) validateattributes(x, {'matlab.graphics.axis.Axes'},{'scalar'}))
addParameter(parser, 'edges', [-inf, -30:10:30, inf], ...
    @(x) validateattributes(x, {'numeric'},{'vector'}))
addParameter(parser, 'legend', true, @(x) islogical(x) && isscalar(x))
addParameter(parser, 'observed_CI_facecolor', zeros(1,3))
addParameter(parser, 'observed_mean_linespec', '', @(x) ischar(x))
addParameter(parser, 'predicted_mean_linespec', 'k-', @(x) ischar(x))
addParameter(parser, 'resultsfolder', 'results', @(x) ischar(x))
parse(parser, varargin{:});
P = parser.Results; 
load(expectedemissionspath,'expectedemissions')
load(datapath, 'trials')
choices = cellfun(@(trial) trial.choice, trials);
Deltaclicks = cellfun(@(x) numel(x.clicktimes.R) - numel(x.clicktimes.L), trials);
Echoices = cellfun(@(x) x.rightchoice, expectedemissions{1});
M23a.plot_psychometric(choices, Deltaclicks, Echoices, varargin{:})

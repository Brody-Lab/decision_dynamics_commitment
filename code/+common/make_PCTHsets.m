function PCTHsets = make_PCTHsets(fitdatapath, alldatapath, resultsfolder, varargin)
% make a set of peri-commitment time histograms for each neuron in a session
%
% ARGUMENT
%
%   fitdatapath
%       absolute path of the MAT file containing the spike trains of the neurons used to fit the
%       drift-diffusion-coupled generalized linear model
%
%   alldatapath
%       absolute path to the MAT containing the spike trains of all the neurons in the recording,
%       even those not used to fit the model
%
%   resultsfolder
%       absolute path of the folder containing the model fits and predictions
parser = inputParser;
addParameter(parser, 'commitmentthreshold', 0.8, @(x) isnumeric(x) && isscalar(x))
addParameter(parser, 'filtersigma_timesteps', 5, @(x) isscalar(x) && isnumeric(x))
addParameter(parser, 'filterwidth_timesteps', 30, @(x) isscalar(x) && isnumeric(x))
addParameter(parser, 'time_s', -0.3:0.01:0.3, @(x) isnumeric(x) && isvector(x))
parse(parser, varargin{:});
P = parser.Results; 
PCTH = struct;
load([resultsfolder '\crossvalidation\paccumulator_choicespikes.mat'], 'paccumulator_choicespikes')
load(fitdatapath, 'trials', 'neurons')
load([resultsfolder '\crossvalidation\trainingsummaries.mat'], 'trainingsummaries')
kfold = numel(trainingsummaries);
[wEA, wCM] = deal(cell(1,kfold));
for k = 1:kfold
    wEA{k} = cellfun(@(theta) theta.v{1}(1), trainingsummaries{k}.thetaglm{1});
    wCM{k} = cellfun(@(theta) theta.beta{1}(1), trainingsummaries{k}.thetaglm{1});
end
wEA = mean(cell2mat(wEA),2);
wCM = mean(cell2mat(wCM),2);
brainarea = cellfun(@(neuron) string(neuron.brainarea), neurons);
[left, right, time_s] = M23a.pericommitment_time_histograms(paccumulator_choicespikes{1}, ...
    trials, varargin{:});
[shuffledleft, shuffledright] = M23a.pericommitment_time_histograms(paccumulator_choicespikes{1}, ...
    trials,'randomize', true, varargin{:});
PCTHsets = M23a.package_PCTHsets(brainarea, true(size(left,1),1), left, right, ...
    shuffledleft, shuffledright, time_s, wCM, wEA);

% analyze neurons that were not fit
All = load(alldatapath, 'trials', 'neurons');
usedindices = cellfun(@(neuron) neuron.neuronindex, neurons);
allindices = cellfun(@(neuron) neuron.neuronindex, All.neurons);
[~, notfitindices] = setxor(allindices, usedindices);
Notfit = All;
Notfit.neurons = Notfit.neurons(notfitindices);
for m = 1:numel(Notfit.trials)
    Notfit.trials{m}.spiketrains = Notfit.trials{m}.spiketrains(notfitindices);
end
brainarea = cellfun(@(neuron) string(neuron.brainarea), Notfit.neurons);
[left, right, time_s] = M23a.pericommitment_time_histograms(paccumulator_choicespikes{1}, Notfit.trials);
[shuffledleft, shuffledright] = M23a.pericommitment_time_histograms(paccumulator_choicespikes{1}, Notfit.trials, ...
    'randomize', true);
PCTHsets_notfit = M23a.package_PCTHsets(brainarea, false(size(left,1),1), left, right, ...
    shuffledleft, shuffledright, time_s, nan(numel(brainarea),1), nan(numel(brainarea),1));
PCTHsets = [PCTHsets; PCTHsets_notfit];
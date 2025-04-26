function PCTH = packagePCTHs(datapath, fulldatapath, resultsfolder)
% package the peri-commitment time histograms for a single session
%
% ARGUMENT
%
%   datapath
%       absolute path of the MAT file containing the spike trains of the neurons used to fit the
%       drift-diffusion-coupled generalized linear model
%
%   fulldatapath
%       absolute path to the MAT containing the spike trains of all the neurons in the recording,
%       even those not used to fit the model
%
%   resultsfolder
%       absolute path of the folder containing the model fits and predictions
PCTH = struct;
load([resultsfolder '\paccumulator_choicespikes.mat'], 'paccumulator_choicespikes')
load(datapath, 'trials', 'neurons')
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
[left, right, time_s] = M23a.pericommitment_time_histograms(paccumulator_choicespikes{1}, trials);
[shuffledleft, shuffledright] = M23a.pericommitment_time_histograms(paccumulator_choicespikes{1}, trials,'randomize', true);


PCTH.fit = struct;
PCTH.fit.brainarea = brainarea;
PCTH.fit.observed.left = left;
PCTH.fit.observed.right = right;
PCTH.fit.shuffled.left = shuffledleft;
PCTH.fit.shuffled.right = shuffledright;
PCTH.time_s = time_s;
PCTH.ntimesteps = numel(PCTH.time_s);
PCTH.fit.wCM = wCM;
PCTH.fit.wEA = wEA;
PCTH.fit.EI = (abs(wEA) - abs(wCM))./(abs(wEA) + abs(wCM));
PCTH.fit.nneurons = numel(PCTH.EI);
for datatype = ["observed", "shuffled"]
for choice = ["left", "right"]
    assert(size(PCTH.(datatype).(choice),1) == PCTH.nneurons);
    assert(size(PCTH.(datatype).(choice),2) == PCTH.ntimesteps);
end
end

% analyze neurons that were not fit
All = load(fulldatapath, 'trials', 'neurons');
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
PCTH.notfit = M23a.make_PCTH(brainarea, left, right, shuffledleft, shuffledright, time_s, wCM, wEA);

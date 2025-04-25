function accuracy = predictchoice(firsttimestep, lasttimestep, ntrainingtrials, neuronindices, trials)
% Accuracy in predicting the behavioral choice using a logistic classifer trained on spike counts
%
% ARGUMENT
%
%   firsttimestep
%       the first time step of the time window for counting spikes
%
%   lasttimestep
%       the last time step of the time window
%
%   ntrainingtrials
%       number of training trials
%
%   neuronindices
%       a linear index indicating which neurons to use
%
%   trials
%       a cell vector whose each element is a scalar containing a struct that contains the spike
%       trains
%
% RETURN
%
%   accuracy
%       a value between 0 and 1 indicating the out-of-sample prediction accuracy
validateattributes(firsttimestep, {'numeric'}, {'integer', 'positive', 'scalar'})
validateattributes(lasttimestep, {'numeric'}, {'integer', 'positive', 'scalar'})
validateattributes(neuronindices, {'numeric'}, {'integer', 'positive', 'vector'})
assert(firsttimestep<=lasttimestep)
validateattributes(trials, {'cell'}, {'vector'})
nneurons = numel(neuronindices);
trialindices = find(cellfun(@(trial) lasttimestep<=trial.ntimesteps, trials));
ntrials = numel(trialindices);
assert(ntrainingtrials<ntrials)
X = nan(ntrials,nneurons);
y = cellfun(@(trial) trial.choice, trials);
y = y(trialindices);
for i = 1:ntrials
    j = trialindices(i);
    for n = 1:nneurons
        X(i,n) = sum(trials{j}.spiketrains{n}(firsttimestep:lasttimestep));
    end
end
fraction_hold_out = 1 - ntrainingtrials/ntrials;
nrepeats = 10;
accuracy = 0;
for i = 1:nrepeats
    C = cvpartition(y,'HoldOut', fraction_hold_out, 'Stratify', true);
    trainindices = training(C);
    testindices = test(C);
    Xtrain = X(trainindices, :);
    Xtest = X(testindices, :);
    ytrain = y(trainindices);
    ytest = y(testindices);
    [B, FitInfo] = lassoglm(Xtrain,ytrain,'binomial');
    [~, index_min_deviance] = min(FitInfo.Deviance);
    w = [FitInfo.Intercept(index_min_deviance); B(:,index_min_deviance)];
    yhat = glmval(w,Xtest,'logit');
    accuracy = accuracy + (1-mean(abs(yhat-ytest), 'omitnan'))/nrepeats;
end
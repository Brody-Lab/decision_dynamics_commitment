function Mdl = fitmodel(spiketrains, trialcondition, varargin)
% fit a regularized linear model with basis functions to the spike train of one neuron
validateattributes(spiketrains, {'cell'}, {'vector'})
validateattributes(trialcondition, {'numeric'}, {'vector'})
parser = inputParser;
addParameter(parser, 'compression_u', 0,  ...
             @(x) validateattributes(x, {'numeric'}, {'scalar'}))
addParameter(parser, 'compression_v', 0,  ...
             @(x) validateattributes(x, {'numeric'}, {'scalar'}))
addParameter(parser, 'D_u', 5,  ...
             @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer'}))
addParameter(parser, 'D_v', 1:2:9,  ...
             @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer'}))
addParameter(parser, 'kfold', 5,  ...
             @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer'}))
addParameter(parser, 'repeats', 200,  ...
             @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer'}))
addParameter(parser, 'ridgeparameters', [0, 10.^(-1:0.5:3)],  ...
             @(x) validateattributes(x, {'numeric'}, {'nonnegative'}))
parse(parser, varargin{:});
P = parser.Results; 
ntrials = numel(spiketrains);
ntimesteps_each_trial = cellfun(@numel, spiketrains);
maxtimesteps = max(ntimesteps_each_trial);
spiketrains = cellfun(@(spiketrain) spiketrain(:), spiketrains, 'uni', 0);
Phi_u = BFM.basisfunctions(P.D_u, maxtimesteps, ...
    'compression', P.compression_u, 'unitary', true);
Phi_v = arrayfun(@(D_v) BFM.basisfunctions(D_v, maxtimesteps, ...
    'compression', P.compression_v, 'begins_at_0', true, 'unitary', true), P.D_v, 'uni', 0);
nD_v = numel(P.D_v);
X_alltrials = cell(ntrials,nD_v);
for i = 1:numel(spiketrains)
for m = 1:nD_v
    indices = 1:ntimesteps_each_trial(i);
    X_alltrials{i,m} = [Phi_u(indices,:), trialcondition(i)*Phi_v{m}(indices,:)];
end
end
nridgeparameters = numel(P.ridgeparameters);
Mdl = struct;
[Mdl.u, Mdl.v, Mdl.k_u, Mdl.k_v] = deal(cell(P.repeats,1));
Mdl.s = nan(P.repeats,nD_v);
for r = 1:P.repeats
    partitions = cvpartition(trialcondition, 'KFold', 2, 'Stratify', true);
    selectionindices = find(training(partitions,1));
    nselection = numel(selectionindices);
    SSE = zeros(nridgeparameters,nD_v);
    for m = 1:nD_v
        D_v = P.D_v(m);
        sI = zeros(P.D_u + D_v);
        for i = 1:nridgeparameters
            s = P.ridgeparameters(i);
            
            for j = P.D_u+(1:D_v)
                sI(j,j) = s;
            end
            cvp = cvpartition(nselection, 'KFold', P.kfold);
            for k = 1:P.kfold
                trainingindices = selectionindices(training(cvp,k));
                testindices = selectionindices(test(cvp,k));
                Xtrain = cell2mat(X_alltrials(trainingindices,m));
                Xtest = cell2mat(X_alltrials(testindices,m));
                ytrain = cell2mat(spiketrains(trainingindices));
                ytest = cell2mat(spiketrains(testindices));
                w = (Xtrain'*Xtrain + sI) \ (Xtrain'*ytrain);
                yhat = Xtest*w;
                SSE(i,m) = SSE(i,m) + sum((yhat-ytest).^2);
            end
        end
    end
    [~,index] = min(SSE(:));
    [i,m] = ind2sub([nridgeparameters, nD_v], index);
    s = P.ridgeparameters(i);
    D_v = P.D_v(m);
    sI = zeros(P.D_u + D_v);
    for j = P.D_u+(1:D_v)
        sI(j,j) = s;
    end
    estimationindices = test(partitions,1);
    X = cell2mat(X_alltrials(estimationindices,m));
    y = cell2mat(spiketrains(estimationindices));
    w = (X'*X + sI) \ (X'*y);
    u = w(1:P.D_u);
    v = w(P.D_u+(1:D_v));
    Mdl.u{r} = u;
    Mdl.v{r} = v;
    Mdl.k_u{r} = Phi_u*u;
    Mdl.k_v{r} = Phi_v{m}*v;
    Mdl.s(r) = s;
    r
end
Mdl.Phi_u = Phi_u;
Mdl.Phi_v = Phi_v;
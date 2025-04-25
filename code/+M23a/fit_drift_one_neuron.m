function b = fit_drift_one_neuron(y,t,varargin)
%{
Infer the slowly drifting baseline firing rate of one neuron

ARGUMENT
- `y`: a vector of floats indicating the firing rates on each trial
- `t`: a vector of positive integers indicating the time of each trial

RETURN
- `b`: a vector of length equal to the maximum time indicating the estimated baseline

OPTIONAL ARGUMENT
- `D`: a vector of the number of temporal basis functions to try
- `kfold`: number of cross-validation fold used for testing
- `lambda`: a vector of L2 regularization parameters to try
- `Phis`: a cell vector of basis functions.
- `T`: maximum time
%}

validateattributes(y, {'numeric'}, {'vector', 'nonnegative'})
validateattributes(t, {'numeric'}, {'vector', 'integer', 'positive'})
assert(numel(t)==numel(y))
parser = inputParser;
addParameter(parser, 'D', 1:10,  ...
             @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer'}))
addParameter(parser, 'kfold', 5,  ...
             @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer'}))
addParameter(parser, 'lambda', [0, 10.^(-5:0.5:-2)],  ...
             @(x) validateattributes(x, {'numeric'}, {'nonnegative'}))
addParameter(parser, 'Phis', {},  ...
             @(x) validateattributes(x, {'cell'}, {}))
addParameter(parser, 'T', [],  ...
             @(x) validateattributes(x, {'numeric'}, {'integer', 'positive', 'scalar'}))
parse(parser, varargin{:});
P = parser.Results; 
M = numel(y);
if isempty(P.T)
    T = max(t);
else
    T = P.T;
end
if isempty(P.Phis)
    Phis = arrayfun(@(D) BFM.basisfunctions(D, T, 'unitary', true), P.D, 'uni', 0);
    Ds = P.D;
else
    Phis = P.Phis;
    Ds = cellfun(@(Phi) size(Phi,2), Phis);
end
Xs = cell(numel(Ds),1);
for i = 1:numel(Ds)
    Xs{i} = nan(M,Ds(i));
    for m = 1:M
        Xs{i}(m,:) = Phis{i}(t(m),:);
    end
end
cvp = cvpartition(M, 'Kfold',P.kfold);
MSE = zeros(numel(Ds), numel(P.lambda));
for k = 1:P.kfold
    trainingindices = training(cvp,k);
    testindices = test(cvp,k);
    for i = 1:numel(Ds)
        Xtrain = Xs{i}(trainingindices,:);
        Xtest  = Xs{i}(testindices,:);
        ytrain = y(trainingindices);
        ytest = y(testindices);
        for j = 1:numel(P.lambda)
            lambdaI = P.lambda(j)*eye(Ds(i));
            w = (Xtrain' * Xtrain + lambdaI) \ (Xtrain' * ytrain);
            MSE(i,j) = MSE(i,j) + mean((Xtest*w - ytest).^2);
        end
    end
end
[~,linearindex] = min(MSE(:));
[i,j] = ind2sub([numel(Ds), numel(P.lambda)], linearindex);
D = Ds(i);
X = Xs{i};
lambda = P.lambda(j);
lambdaI = lambda * eye(D);
w = (X' * X + lambdaI) \ (X' * y);
b = Phis{i}*w;
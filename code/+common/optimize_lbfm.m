function optimalmodel = optimize_lbfm(spiketrains, trialgroups)
% Identify the optimal linear basis function model for a neuron
%
% ARGUMENT
%
%   spiketrains
%       A cell vector of the spike train of one neuron across trials
%
%   trialgroups
%       A vector of numbers or strings to indicate the group of the vector
%
% RETURN
% A struct with the following fields:
%
%   compression
%       A scalar parameter indicating the degree of overrepresentation of initial values
%
%   D
%       number of basis functions
%
%   w
%       a cell array containing for the optimal encoding weights for each group of trials
%
%   Phi
%       a matrix indicating the basis functions.
validateattributes(spiketrains, {'cell'}, {'vector'})
validateattributes(trialgroups, {'logical', 'numeric', 'string'}, {'vector'})
compressions = [0,2.^(-6:-3)];
Ds = 1:8;
kfold = 5;
MSE = nan(numel(compressions), numel(Ds));
trialgroups = findgroups(trialgroups);
ngroups = max(trialgroups);
repeats = 1;
for i = 1:numel(compressions)
    for j = 1:numel(Ds)
        SSE = 0;
        for r = 1:repeats
        for g = 1:ngroups
            trialindices = find(trialgroups == g);
            cvp = cvpartition(numel(trialindices), 'KFold', kfold);
            for k = 1:kfold
                trainingindices = trialindices(training(cvp,k));
                [w, Phi] = M23a.fit_linear_basis_functions_model(spiketrains(trainingindices), ...
                    'compression', compressions(i), 'D', Ds(j));
                testindices = trialindices(test(cvp,k));
                SSE = SSE + M23a.sse_lbfm(spiketrains(testindices), Phi, w);
            end
        end
        end
        MSE(i,j) = SSE/numel(spiketrains)/repeats;
    end
end
[~,linearindex] = min(MSE(:));
[i,j] = ind2sub([numel(compressions), numel(Ds)], linearindex);
optimalmodel = struct;
optimalmodel.compression = compressions(i);
optimalmodel.D = Ds(j);
for g = 1:ngroups
    trialindices = trialgroups==g;
    [w, Phi] = M23a.fit_linear_basis_functions_model(spiketrains(trialindices), ...
        'compression', compressions(i), 'D', Ds(j));
    optimalmodel.w{g,1} = w;
    optimalmodel.Phi = Phi;
end
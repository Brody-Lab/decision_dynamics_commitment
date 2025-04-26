function R2 = predict_peth_from_data(spiketrains, varargin)
% Out-of-sample prediction from the observed
parser = inputParser;
addParameter(parser, 'kfold', 2, @(x) isnumeric(x) && isscalar(x))
addParameter(parser, 'repeats', 9, @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer', 'nonnegative'}))
addParameter(parser, 'sigma', 10, @(x) isscalar(x) && isnumeric(x))
addParameter(parser, 'width', 40, @(x) isscalar(x) && isnumeric(x))
parse(parser, varargin{:});
P = parser.Results; 
ntrials = numel(spiketrains);
R2s = nan(P.repeats+1,1);
for i = 1:(P.repeats+1)
    cvp = cvpartition(ntrials, 'Kfold', P.kfold);
    R2test = nan(P.kfold,1);
    for k = 1:P.kfold
        trainingindices = training(cvp, k);
        testindices = test(cvp,k);
        trainingpeth = M23a.perievent_time_histogram(spiketrains(trainingindices), P.sigma, P.width);
        testpeth = M23a.perievent_time_histogram(spiketrains(testindices), P.sigma, P.width);
        trainingpeth = mean(trainingpeth, 'omitnan');
        testpeth = mean(testpeth, 'omitnan');
        ntimesteps = min(numel(trainingpeth), numel(testpeth));
        trainingpeth = trainingpeth(1:ntimesteps);
        testpeth = testpeth(1:ntimesteps);
        R2test(k) = M23a.coefficient_of_determination(testpeth, trainingpeth);
    end
    R2s(i) = mean(R2test);
end
R2 = median(R2s);
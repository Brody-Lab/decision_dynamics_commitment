function [R2median, pointestimate] = boostrap_peth_R2(obsvtrials, predtrials, varargin)
% goodness-of-fit of peth computed by botostrapping across trials
%
% ARGUMENT
%   obsvtrials
%       a cell array of observed trials
%
%   predtirals
%       a cell array containing the predicted response
%
% RETURN
%
%   R2median
%       the median of the statistics computed from bootstrapped samples of each neuron
%
%   pointestimate
%       The R2 computed without bootstrapping of each neuron
    parser = inputParser;
    addParameter(parser, 'filtersigma_timesteps', 10, @(x) isscalar(x) && isnumeric(x))
    addParameter(parser, 'filterwidth_timesteps', 40, @(x) isscalar(x) && isnumeric(x))
    addParameter(parser, 'nboot', 1e3, @(x) isscalar(x) && isnumeric(x))
    addParameter(parser, 'timestep_s', 0.01, @(x) isnumeric(x) && isscalar(x))
    parse(parser, varargin{:});
    P = parser.Results; 
    nneurons = numel(obsvtrials{1}.spiketrains);
    [pointestimate, R2median] = deal(nan(nneurons,1));
    for n = 1:nneurons
        obsvresponse = filterresponse(obsvtrials, P.filterwidth_timesteps, P.filtersigma_timesteps, ...
            n, P.timestep_s);
        predresponse = filterresponse(predtrials, P.filterwidth_timesteps, P.filtersigma_timesteps, ...
            n, P.timestep_s);
        ntrials = size(obsvresponse,1);
        indices = 1:ntrials;
        R2boot = nan(P.nboot,1);
        for b = 1:P.nboot
            bootindices = datasample(indices,ntrials);
            obsvpsth = mean(obsvresponse(bootindices,:), 'omitnan');
            predpsth = mean(predresponse(bootindices,:), 'omitnan');
            R2boot(b) = M23a.coefficient_of_determination(obsvpsth, predpsth);
        end
        R2median(n) = median(R2boot);
        obsvpsth = mean(obsvresponse, 'omitnan');
        predpsth = mean(predresponse, 'omitnan');
        pointestimate(n) = M23a.coefficient_of_determination(obsvpsth, predpsth);
    end
end
%%
function filtered = filterresponse(trials, filterwidth_timesteps, filtersigma_timesteps, n, timestep_s)
    maxtimesteps = max(cellfun(@(trial) trial.ntimesteps, trials));
    ntrials = numel(trials);
    filtered = nan(ntrials, maxtimesteps);
    for i = 1:ntrials
        tau = trials{i}.ntimesteps;
        filtered(i,1:tau) = M23a.convolve_counts_causalgaussian(trials{i}.spiketrains{n},...
            filterwidth_timesteps, filtersigma_timesteps)./timestep_s;
    end
end
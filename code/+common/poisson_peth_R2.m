function R2 = poisson_peth_R2(spiketrains)
maxtimesteps = max(cellfun(@numel, spiketrains));
ntrials = numel(spiketrains);
S = nan(ntrials,maxtimesteps);
for i = 1:ntrials
    ntimesteps = numel(spiketrains{i});
    S(i,1:ntimesteps) = spiketrains{i};
end
Sfiltered = nan(ntrials,maxtimesteps);
for i = 1:ntrials
    Sfiltered(i,:) = M23a.convolve_counts_causalgaussian(S(i,:), 10, 40);
end
Sfilteredmean = mean(Sfiltered, 'omitnan');
Smean = mean(S, 'omitnan');

nboot = 1e2;
for b = 1:nboot
    X = nan(ntrials,maxtimesteps);
    for t = 1:maxtimesteps
        X(:,t) = poissrnd(Smean(t), ntrials, 1);
    end
    Xfiltered = nan(ntrials,maxtimesteps);
    for i = 1:ntrials
        Xfiltered(i,:) = M23a.convolve_counts_causalgaussian(X(i,:), 10, 40);
    end
    Xfilteredmean = mean(Xfiltered, 'omitnan');
    R2(b) = M23a.coefficient_of_determination(Sfilteredmean, Xfilteredmean);
end
function PSTHs = peristimulus_time_histograms(trials,timestep_s)
% compute a peristimulus time histogram of each neuron recorded from one session
%
%=ARGUMENT
%
%   trials
%       a cell column array each element of which is a struct containing the observations on one
%       trial
%
%   timestep_s
%       duration of the time step the spike trains are computed
%
%=RETURN
%   
%   PSTHs
%       a cell column array each element of which is the peristimulus time histogram of a neuron 
validateattributes(trials, {'cell'}, {'vector'})
validateattributes(timestep_s, {'numeric'}, {'scalar', 'nonnegative'})
psthsettings = M23a.psthsettings;
maxtimesteps = ceil(psthsettings.duration_s/timestep_s);
time_s = (1:maxtimesteps)*timestep_s;
width = ceil(psthsettings.width_s/timestep_s);
sigma = ceil(psthsettings.sigma_s/timestep_s);
Trialindices = M23a.index_trials_for_psth(trials);
nneurons = numel(trials{1}.spiketrains);
PSTHs = arrayfun(@(x) {struct}, (1:nneurons)');
for condition = string(fieldnames(Trialindices)')
    trialindices = find(Trialindices.(condition));
    ntrials = numel(trialindices);
    for n = 1:nneurons
        disp(n)
        psth = nan(ntrials, maxtimesteps);
        for i = 1:ntrials
            trialindex = trialindices(i);
            tau = min(trials{trialindex}.ntimesteps, maxtimesteps);
            filteredresponse = M23a.convolve_counts_causalgaussian(trials{trialindex}.spiketrains{n},width,sigma);
            psth(i,1:tau) = filteredresponse(1:tau)/timestep_s;
        end
        PSTHs{n}.(condition) = struct;
        PSTHs{n}.(condition).observed = mean(psth, 'omitnan');
        try 
            ci = bootci(1e3, @(x) mean(x, 'omitnan'), psth);
        catch
            ci = nan(2, numel(time_s));
        end
        PSTHs{n}.(condition).lowerconfidencelimit = ci(1,:);
        PSTHs{n}.(condition).upperconfidencelimit = ci(2,:);
        PSTHs{n}.(condition).time_s = time_s;
    end
end
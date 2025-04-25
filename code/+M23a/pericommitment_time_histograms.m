function [left, right, time_s] = pericommitment_time_histograms(paccumulator, trials, varargin)
% Smooth time histogram around the inferred time of decision commitment
%
% ARGUMENT
%-`paccumulator`: moment-to-moment probability of the accumulator. Element `paccumulator{m}{t}(i)`
%corresponds to the i-th state of the accumulator at the t-th time step of the m-th trial. The first
%and last state of accumulator are assumed to correspond to commitment to the left and right choice,
%respectively.
%-`trials`: a cell array whose each element is a structure containing the moment-to-moment spike
%count of each neuron. The element `trials{m}.spiketrains{n}(t)` corresponds to the spike train
%response of the n-th neuron at the t-th time step on the m-th trial.
%
% OUTPUT
%-`left`: time-varying firing rate (spikes/s) aligned to the inferred time of commitment to the left choice
%-`right`: time-varying firing rate (spikes/s) aligned to the inferred time of commitment to the right choice
%-`time_s`: time relative to the inferred time of bound
%
% OPTIONAL ARGUMENT
%-`commitmentthreshold`: probability of the accumulator considered for a commitment
%-`time_s`: probability of the accumulator considered for a commitment
%-randomize: as a negative control, for each group of trials associated with either
%the left or the right choice, randomize the inferred time of commitment
validateattributes('paccumulator', {'char'}, {'row'})
validateattributes('modelname', {'char'}, {'row'})
validateattributes('outputpath', {'char'}, {'row'})
validateattributes('reportfolder', {'char'}, {'row'})
parser = inputParser;
addParameter(parser, 'commitmentthreshold', 0.9, @(x) isnumeric(x) && isscalar(x))
addParameter(parser, 'filtersigma_timesteps', 10, @(x) isscalar(x) && isnumeric(x))
addParameter(parser, 'filterwidth_timesteps', 30, @(x) isscalar(x) && isnumeric(x))
addParameter(parser, 'randomize', false, @(x) isscalar(x) && islogical(x))
addParameter(parser, 'time_s', -0.3:0.01:0.3, @(x) isnumeric(x) && isvector(x))
parse(parser, varargin{:});
P = parser.Results; 
ntrials = numel(paccumulator);
[t_commitleft, t_commitright] = deal(nan(ntrials,1));
for m = 1:ntrials
    commitleft = cellfun(@(x) x(1) > P.commitmentthreshold, paccumulator{m});
    commitright = cellfun(@(x) x(end) > P.commitmentthreshold, paccumulator{m});
    t = find(commitleft, 1);
    if ~isempty(t)
         t_commitleft(m) = t;
    end
    t = find(commitright, 1);
    if ~isempty(t)
         t_commitright(m) = t;
    end
end
Commit = struct;
Commit.left.trial = find(~isnan(t_commitleft));
Commit.left.timestep = t_commitleft(~isnan(t_commitleft));
Commit.right.trial = find(~isnan(t_commitright));
Commit.right.timestep = t_commitright(~isnan(t_commitright));
if P.randomize
    for side = ["left", "right"]
        ntrials = numel(Commit.(side).timestep);
        randomindices = randperm(ntrials);
        Commit.(side).timestep = Commit.(side).timestep(randomindices);
        for m = 1:ntrials
            trialindex = Commit.(side).trial(m);
            Commit.(side).timestep(m) = min(trials{trialindex}.ntimesteps,Commit.(side).timestep(m));
        end
    end
end
nneurons = numel(trials{1}.spiketrains);
SpikeTrains = struct;
maxtimesteps = max(cellfun(@(trial) trial.ntimesteps, trials));
for side = ["left", "right"]
    SpikeTrains.(side) = zeros(nneurons, 2*maxtimesteps-1);
    ntrials_per_timestep = zeros(1,2*maxtimesteps-1);
    for m = 1:numel(Commit.(side).trial)
        trialindex = Commit.(side).trial(m);
        timesteps = (maxtimesteps-Commit.(side).timestep(m)) + (1:trials{trialindex}.ntimesteps);
        ntrials_per_timestep(timesteps) = ntrials_per_timestep(timesteps) + 1;
        for n = 1:nneurons
            SpikeTrains.(side)(n,timesteps) = SpikeTrains.(side)(n,timesteps) + ...
                trials{trialindex}.spiketrains{n};
        end
    end
    SpikeTrains.(side) = SpikeTrains.(side)./ntrials_per_timestep;
end
[left, right] = deal(nan(nneurons,numel(P.time_s)));
timeindices = maxtimesteps + (-sum(P.time_s<0):sum(P.time_s>0));
timestep_s = 0.01;
for n = 1:nneurons
    filteredleft = M23a.convolve_counts_causalgaussian(SpikeTrains.left(n,:)/timestep_s, ...
        P.filterwidth_timesteps, P.filtersigma_timesteps);
    filteredright = M23a.convolve_counts_causalgaussian(SpikeTrains.right(n,:)/timestep_s, ...
        P.filterwidth_timesteps, P.filtersigma_timesteps);
    left(n,:) = filteredleft(timeindices);
    right(n,:) = filteredright(timeindices);
end
time_s = P.time_s;
function peth = perievent_time_histogram(spiketrains, sigma, width)
% compute a peristimulus time histogram of each neuron recorded from one session
%
%=ARGUMENT
%
%   spiketrains
%       a cell column array each element of which is the spike train of a trial
%
%=RETURN
%   
%   peth
%       perievent time histogram of a neuron 
validateattributes(spiketrains, {'cell'}, {'vector'})
maxtimesteps = max(cellfun(@numel, spiketrains));
ntrials = numel(spiketrains);
peth = nan(ntrials,maxtimesteps);
for i = 1:ntrials
    ntimesteps = numel(spiketrains{i});
    peth(i,1:ntimesteps) = M23a.convolve_counts_causalgaussian(spiketrains{i},width,sigma);
end
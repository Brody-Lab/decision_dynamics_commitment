function FR = firingrates(Cells, Trials, varargin)
% firing rates of each neuron on each trial
%
% ARGUMENT
% 
%   Cells
%       A structure with information on the Cells data
%
%   Trials
%       A structure providing information recording the behavioral data
%
% RETURN
% 
%   FR
%       A cell array whose element `FR{n}(i)` corresponds to the firing rate of the n-th neuron in
%       the i-th trial
%
% OPTIONAL ARGUMENT
%
%   maskmovement
%       A logical scalar indicating whether to set as NaN the firing rates
%       whose time bin involved the times when the animal was moving.
%
%   neuronindices
%       indices of the neurons considered
%
%   reference_event
%       A char array specifiying the event in each trial that is used as
%       the reference time for the counting window
%
%   time_s_from
%       The begining of the counting window, relative to the
%       REFERENCE_EVENT. An array or a scalar.
%
%   time_s_to
%       The end of the counting window, relative to the REFERENCE EVENT
%
%   trialindices
%       indices of the trials for which spikes are counted
P = inputParser;
addParameter(P, 'maskmovement', false, @(x) islogical(x) && isscalar(x))
addParameter(P, 'neuronindices', 1:numel(Cells.raw_spike_time_s), @(x) islogical(x)||isnumeric(x))
addParameter(P, 'reference_event', 'stereoclick', @(x) isstring(x) || ischar(x))
addParameter(P, 'time_s_from', 0, @(x) isnumeric(x) && isscalar(x))
addParameter(P, 'time_s_to', 1, @(x) isnumeric(x) && isscalar(x))
addParameter(P, 'trialindices', 1:numel(Trials.is_hit), @(x) islogical(x)||isnumeric(x))
parse(P, varargin{:});
P = P.Results;
if islogical(P.neuronindices)
    neuronindices = find(P.neuronindices);
else
    neuronindices = P.neuronindices;
end    
nneurons = numel(neuronindices);
if islogical(P.trialindices)
    trialindices = find(P.trialindices);
else
    trialindices = P.trialindices;
end
ntrials = numel(trialindices);
switch P.reference_event
    case "stereoclick"
        eventime_s = M23a.get_stereo_click_time(Trials);
    case "cpoke_out"
        eventime_s = Trials.stateTimes.cpoke_out;
    otherwise
        error("unrecognized reference event")
end
eventime_s = eventime_s(trialindices);
time_s_from = P.time_s_from + eventime_s;
time_s_to = P.time_s_to + eventime_s;
if P.maskmovement
    movementimes = Trials.stateTimes.cpoke_out(trialindices);
    time_s_to = min(time_s_to, movementimes);
end
duration_s = time_s_to - time_s_from;
FR = arrayfun(@(x) nan(ntrials,1), (1:nneurons)', 'UniformOutput', false);
for n = 1:nneurons
    neuronindex = neuronindices(n);
    for i = 1:ntrials
        FR{n}(i) = sum(Cells.raw_spike_time_s{neuronindex} >= time_s_from(i) & ...
                       Cells.raw_spike_time_s{neuronindex} < time_s_to(i));
    end
    FR{n} = FR{n}./duration_s;
end
function X = baseline_pretrial_spikecounts(Cells, Trials, varargin)
%
%   count spikes before the trial
%
%=ARGUMENT
%
%   Cells
%       a struct containing spike times and information about the electrophysiological recording5
%
%   Trials
%       a struct containing information about the task settings and behavioral events
%
%   trialindices
%       linear indices of trials to be used
%
%=RETURN
%
%   a matrix of dimensions number-of-trials-by-number-of-neurons
parser = inputParser;
addParameter(parser, 'reference_event', 'cpoke_in',  ...
             @(x) validateattributes(x, {'char'}, {'row'}))
addParameter(parser, 'time_begin_s', -2,  ...
             @(x) validateattributes(x, {'numeric'}, {'scalar'}))
addParameter(parser, 'time_end_s', 0,  ...
             @(x) validateattributes(x, {'numeric'}, {'scalar'}))
parse(parser, varargin{:});
P = parser.Results; 
ntrials = numel(Trials.stateTimes.(P.reference_event));
nneurons = numel(Cells.raw_spike_time_s);
X = nan(ntrials, nneurons);
for i = 1:ntrials
    t0 = Trials.stateTimes.(P.reference_event)(i);
    for n = 1:nneurons
        X(i,n) = sum(Cells.raw_spike_time_s{n} >= t0 + P.time_begin_s & ...
                     Cells.raw_spike_time_s{n} <  t0 + P.time_end_s);
    end
end
assert(all(all(~isnan(X))))
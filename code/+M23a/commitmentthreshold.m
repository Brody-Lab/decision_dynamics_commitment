function accumulator_probability_threshold = commitmentthreshold(P,commitment_trial_fraction)
%{
RETURN a threshold value for the probability of the accumulator that satisfies a value of the
fraction of trials on which decision commitment occurred.

ARGUMENT
-`P`: a nested array whose element `P{i}{j}{k} corresponds to the probability of the accumulator
variable being at the k-th state on the j-th time step of the i-th trial
-`commitment_trial_fraction`: a scalar between 0 and 1 indicating the fraction of trials on which
commitment should occur
%}
validateattributes(P, {'cell'}, {'vector'})
cellfun(@(x) validateattributes(x, {'cell'}, {'vector'}), P)
cellfun(@(x) cellfun(@(y) validateattributes(y, {'numeric'}, {'vector'}),x), P)
validateattributes(commitment_trial_fraction, {'numeric'}, {'scalar'})
assert(commitment_trial_fraction>=0 && commitment_trial_fraction <= 1)
thresholds = 0:0.01:1;
commit = nan(numel(P),numel(thresholds));
for i = 1:numel(P)
    pL = cellfun(@(x) x(1), P{i});
    pR = cellfun(@(x) x(end), P{i});
    for t = 1:numel(thresholds)
        commit(i,t) = any(pL>=thresholds(t)) || any(pR>thresholds(t));
    end
end
fraccommit = mean(commit);
index = find(fraccommit > commitment_trial_fraction, 1, 'last');
if isempty(index)
    accumulator_probability_threshold = NaN;
else
    accumulator_probability_threshold = thresholds(index);
end
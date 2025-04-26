function [timestep, rightward] = commitmenttime(P, threshold)
% time step of decision commitment on each trial
%
% ARGUMENT
%-`paccumulator`: moment-to-moment probability of the accumulator. Element `paccumulator{m}{t}(i)`
%corresponds to the i-th state of the accumulator at the t-th time step of the m-th trial. The first
%and last state of accumulator are assumed to correspond to commitment to the left and right choice,
%respectively.
%-`commitmentthreshold`: probability of the accumulator considered for a commitment
%
% OUTPUT
%-timestep: time step of commitment
%-rightward: whether the commitment is to a rightward or a leftward decision
validateattributes(P, {'cell'}, {'vector'})
cellfun(@(x) validateattributes(x, {'cell'}, {'vector'}), P)
cellfun(@(x) cellfun(@(y) validateattributes(y, {'numeric'}, {'vector'}),x), P)
validateattributes(threshold, {'numeric'}, {'scalar'})
assert(threshold>=0 && threshold <= 1)
ntrials = numel(P);
[timestep, rightward] = deal(nan(ntrials,1));
for m = 1:ntrials
    commitleft = cellfun(@(x) x(1) > threshold, P{m});
    commitright = cellfun(@(x) x(end) > threshold, P{m});
    tL = find(commitleft, 1);
    tR = find(commitright, 1);
    if ~isempty(tL) && isempty(tR)
         timestep(m) = tL;
         rightward(m) = 0;
    elseif isempty(tL) && ~isempty(tR)
         timestep(m) = tR;
         rightward(m) = 1;
    elseif ~isempty(tL) && ~isempty(tR)
        if tL < tR
            timestep(m) = tL;
            rightward(m) = 0;
        elseif tR > tL
            timestep(m) = tR;
            rightward(m) = 1;
        end
    end
end
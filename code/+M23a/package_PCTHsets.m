function PCTHsets = package_PCTHsets(brainarea, fit, left, right, shuffledleft, shuffledright, time_s, wCM, wEA)
% package data into a set of peri-commitment time histograms (PCTH) for each neuron
%
% ARGUMENT
%
%   brainarea
%       a vector of strings labelled the brain area of each neuron
%
%   left
%       PCTH computed from trials resulting in a left choice. Each row of this matrix corresponds to
%       a neuron and each column a time step
%
%   right
%       PCTH computed from trials resulting in a right choice. same format as `left`
%
%   shuffledleft
%       PCTH computed from trials ending in a left choice and the inferred time of commitment
%       shuffled among these trials
%
%   shuffledright
%       similar to `shuffledleft`
%
%   time_s
%       a vector indicating the time, in second of each time step relative the inferred time of
%       decision commitment
%
%   wCM
%       a vector of reals specifying each neuron's encoding weight of the commited choice
%
%   wEA
%       a vector of reals specifying each neuron's encoding weight of accumulated evidence
validateattributes(brainarea, {'string'}, {'vector'})
validateattributes(fit, {'logical'}, {'vector'})
validateattributes(left, {'numeric'}, {'2d', 'nonnegative'})
validateattributes(right, {'numeric'}, {'2d', 'nonnegative'})
validateattributes(shuffledleft, {'numeric'}, {'2d', 'nonnegative'})
validateattributes(shuffledright, {'numeric'}, {'2d', 'nonnegative'})
validateattributes(time_s, {'numeric'}, {'vector'})
validateattributes(wCM, {'numeric'}, {'vector'})
validateattributes(wEA, {'numeric'}, {'vector'})
nneurons = size(left,1);
PCTHsets = cell(nneurons,1);
for n = 1:nneurons
    PCTHsets{n}.fit = fit(n);
    PCTHsets{n}.brainarea = brainarea(n);
    PCTHsets{n}.observed.left = left(n,:);
    PCTHsets{n}.observed.right = right(n,:);
    PCTHsets{n}.shuffled.left = shuffledleft(n,:);
    PCTHsets{n}.shuffled.right = shuffledright(n,:);
    PCTHsets{n}.time_s = time_s;
    PCTHsets{n}.wCM = wCM(n);
    PCTHsets{n}.wEA = wEA(n);
    PCTHsets{n}.EI = (abs(wEA(n)) - abs(wCM(n)))./(abs(wEA(n)) + abs(wCM(n)));
end
function c = choiceselectivity(choices,firingrates)
% An index of how well an ideal observer can predict the behavioral choice based on the firing rates
% of a neuron
% 
% Choice selectivity is defined as the absolute difference between 0.5 and the area under the
% receiver operating characteristic computed by a binary classifier of choice based on the firing
% rates.
%
% ARGUMENT
%
%   choices
%       a logical vector. TRUE indicates a right choice
%
%   firingrates
%       a vector of firing rates of one neuron
%
% RETURN
%   an index ranging between 0 and 0.5. A value of 0 indicates
%
% EXAMPLE
%   >> rng(1234)
%   >> leftresponses = poissrnd(5,50,1);
%   >> rightresponses = poissrnd(10,50,1)
%   >> M23a.choiceselectivity([false(50,1); true(50,1)], [leftresponses; rightresponses])
%   
%   ans = 
%                   0.3662
validateattributes(choices, {'logical'}, {'vector'})
validateattributes(firingrates, {'numeric'}, {'vector', 'nonnegative'})
[~,~,~,area_under_ROC] = perfcurve(choices,firingrates,true);
c = abs(area_under_ROC-0.5);
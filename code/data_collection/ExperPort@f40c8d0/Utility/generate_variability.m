function [list] = generate_variability(lower_bound, upper_bound, hazard_rate, len, varargin)

pairs = { ...
    'decreasing', 0 ; ...       % when set, exponential DECAY occurs on prob, not growth
    };
parse_knownargs(varargin,pairs);

%
% Select values from a provided range. Assigns probability of selection
% using the hazard rate.
% Sample hazard rate values for different distributions:
%   0.01 - uniform probability
%   0.1  - exponential growth in probability of selection
% If 'decreasing' flag is set, exponential decay occurs in lieu of growth
% The higher the hazard rate, the faster the growth

if lower_bound > upper_bound,
    upper_bound = lower_bound;
end

range      = lower_bound:0.010:upper_bound;
prob       = hazard_rate*((1-hazard_rate).^(0:length(range)-1));
if decreasing
    cumprob = 1 - cumsum(prob/sum(prob));
else
    cumprob    = cumsum(prob/sum(prob));
end;

list = zeros(1, len);
for i=1:len
    r = rand(1);
    if decreasing
        list(i) = range(min(find(r>=cumprob)));
    else
        list(i) = range(min(find(r<=cumprob)));
    end;
end;


function [num] = hrate_kernalize(hh,varargin)
% given a hit_history array (binary array of hits and misses)
% plots running average based on an exponential filter with a specifiable running_avg 

pairs = { ...
    'running_avg', 20; ...
    };
parse_knownargs(varargin,pairs);

t = (1:length(hh))';
a = zeros(size(t));
for i=1:length(hh),
    x = 1:i;
    kernel = exp(-(i-t(1:i))/running_avg);
    kernel = kernel(1:i) / sum(kernel(1:i));

    a(i) = sum(hh(x)' .*kernel);
end;
num = a;


function [ind] = multiple_timeouts(p, varargin)
% Returns all trials with multiple timeouts
% Thresholds may be specified via the key-value pairs, 'lower_bound' and
% 'upper_bound'
% e.g. 
% multiple_timeouts(p) would return all trials with > 1 timeout
% multiple_timeouts(p,'lower_bound', 0) 
%   would return all trials with > 0 timeouts
% multiple_timeouts(p, 'lower_bound',0, 'upper_bound', 3)
%   would return all trials with > 0 and < 3 timeouts (i.e. with single or
%   double timeouts

pairs = {
    'lower_bound', 0    ; ...
    'upper_bound', Inf  ; ...
    };
parse_knownargs(varargin, pairs);

ind = cell(0,2); ctr = 1;
for k = 1:rows(p)
    if k == 66,
        2;
    end;
    if rows(p{k}.timeout) > lower_bound && rows(p{k}.timeout) < upper_bound
        ind{ctr,1} = k; ind{ctr,2} = rows(p{k}.timeout);ctr = ctr+1;
    end;
end;
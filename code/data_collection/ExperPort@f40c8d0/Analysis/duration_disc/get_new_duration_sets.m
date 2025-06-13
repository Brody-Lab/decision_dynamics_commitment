function [duration_set] = get_new_duration_sets(varargin)
% Given the current standard interval with end points,
% generates a new set of duration pairs whose midpoint is multiple_of_mid
% times the old midpoint.

if nargin == 3
   old_lo = varargin{1}; old_hi = varargin{2}; multiple_of_mid = varargin{3};
   midpoint= sqrt(old_lo * old_hi);
new_mp = multiple_of_mid * midpoint;
elseif nargin == 1
    new_mp = varargin{1};
else
    error('Either give me three args (old_low, old_high, and multiple_of_mid) or a single arg (standard interval');
end;

dist = 0.3;


new_mp = log(new_mp);

new_lo = exp(new_mp - dist); 
new_hi = exp(new_mp + dist);

duration_set = show_vanilla_sets(new_lo, new_hi, 'plotme', 0, 'gimme_all',1);

if nargin ==3
fprintf(1, 'Old set: (%3.0f, %3.0f)ms, Midpoint = %3.0fms\n', ...
    old_lo, old_hi, midpoint);
end;
fprintf(1, 'New set: (%3.0f, %3.0f)ms, Midpoint = %3.0fms\n', ...
    new_lo, new_hi, exp(new_mp));
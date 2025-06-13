function [bins_2, bins] = generate_bins(start, fin, steps, varargin)

% Generates a evenly log-spaced set of intervals with 'steps' entries from start to fin.
% By default, generates bins in log-space of base e (natural log space).
% If 'pitches' flag is set, generates bins in log-space of base 2
% (binary log space).

pairs = { ...
    'pitches', 0; ...
    'straight', 0; ...
    };
parse_knownargs(varargin, pairs);

steps = steps + 1; % here is a comment
if straight > 0
    space_tween = fin - start;
elseif pitches > 0
    space_tween = log2(fin) - log2(start);
else
    space_tween = log(fin) - log(start);
end;

step_size = space_tween / (steps-1);

bins = [];

for k = 1:steps
    if straight > 0
        bins(k) = (start) + ((k-1)*step_size);
    elseif pitches > 0
        bins(k) = log2(start) + ((k-1)*step_size);
    else
        bins(k) = log(start) + ((k-1)*step_size);
    end;
end;

% move every bin over by a half of its width to center
bins_2 = [];
for m = 1:steps-1
    bins_2(m) = (bins(m) + bins(m+1))/2;
end;

if straight > 0
    % do nothing
elseif pitches > 0
    bins_2 = 2.^(bins_2); 
    bins = 2.^(bins); 
else
    bins_2 = exp(bins_2); %bins_2 = round(bins_2);
    bins = exp(bins); bins = round(bins);
end;

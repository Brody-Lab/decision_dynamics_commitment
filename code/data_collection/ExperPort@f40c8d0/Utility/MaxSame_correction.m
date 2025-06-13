function [sl, nc] = MaxSame_correction(sl, MaxSame)

% For an array of binary values [01], eliminates runs of length MaxSame and
% above

nc = 1;
if MaxSame < 11,
    seg_starts  = find(diff([-Inf sl -1]));
    seg_lengths = diff(seg_starts);
    long_segs   = find(seg_lengths > MaxSame); 
    if isempty(long_segs), nc = 1; else nc = 0; end;
    while ~isempty(long_segs),
        switch_point = seg_starts(long_segs(1)) + ceil(seg_lengths(long_segs(1))/2);
        sl(switch_point) = 1 - sl(switch_point);
        seg_starts  = find(diff([-Inf sl]));
        seg_lengths = diff(seg_starts);
        long_segs   = find(seg_lengths > MaxSame);
    end;
end;

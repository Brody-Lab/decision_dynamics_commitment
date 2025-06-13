function [inds] = find_intersection_points(binned, thres)
% Helper function for analyze_bouts.m (in the same directory)
% Used to determine bout length, this script finds points in the bout
% sequence that cross the 'good' threshold. These points are then used by
% analyze_bouts.m to identify 'good bouts'.

inds = [];
% look for ascent
for bin = 1:length(binned)-1
    if binned(bin) < thres && binned(bin+1) >= thres
        inds= [inds bin];
    elseif binned(bin) >= thres && binned(bin+1) < thres
        inds = [inds bin];
    end;    
end;

% if last one is up, without a return, don't penalise it
if binned(inds(end)) < thres && binned(inds(end)+1) >= thres
    inds = [inds length(binned)];
end;


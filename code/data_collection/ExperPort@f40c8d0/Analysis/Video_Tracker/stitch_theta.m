function stitched_theta = stitch_theta(theta)
% takes head angle info from neuralynx video tracker, sorts out the missing
% points, then stitches them altogether so that 0 to 360 are identified and
% continuous


tol = 40;  % tolerance

% mark all 0 values to NaN: they are likely where the tracker got lost
theta(theta == 0) = NaN;
bad_points = find(isnan(theta));

% interpolate NaN's
[good_theta not_fixed] = naninterp(theta, 360, tol);

% if it was zero before but was probably just wrapping around, reset the
% value to 0
good_theta(not_fixed) = 0;  
stitched_theta = stitch_wrapped(good_theta, 360, tol);
function theta = compute_angle(LEDs, live)
% LEDs is a (column) vector of structs that contain the coordinates of the
% lights.
%
% live should be a vector the same length as LEDs, containing
% 0's and 1's indicating which LEDs have been identifed in this frame
%
% returns the angle of the line that best fits the lights provided.
% Note that since atan is used, this angle is [-pi/2, pi/2]


if sum(live) < 2, % if there's not at least two points,
    theta = NaN;
    return;
end;

ind = find(live == 1);
x = [LEDs(ind,1).x];
y = [LEDs(ind,1).y];

P = polyfit(x, y, 1);
theta = atan(P(1));  % arctan of the slope of the linear regression of the lights

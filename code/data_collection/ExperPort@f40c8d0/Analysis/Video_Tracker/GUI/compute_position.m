function [x y] = compute_position(LED, live)
% LEDs is a (column) vector of structs that contain the coordinates of the
% lights.
%
% live should be a vector the same length as LEDs, containing
% 0's and 1's indicating which LEDs have been identifed in this frame
%
% if there is only one point, returns that point

if issame(ones(size(live)), live) || issame([1 0 1], live),
    ind = find(live == 1);
    x = mean([LED(ind, 1).x]);
    y = mean([LED(ind, 1).y]);
elseif sum(live) == 1,
    ind = find(live == 1);
    x = LED(ind,1).x;
    y = LED(ind,1).y;
else % live is [0 1 1] or [1 1 0]
    % returns the position of the middle green LED
    x = LED(2,1).x;
    y = LED(2,1).y;
end;
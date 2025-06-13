% returns side choice (answered 'LEFT' or 'RIGHT') given hit_history and
% side list respectively
% side_choice has 1 for 'went left', and '0' for 'went right'.
function [side_choice] = side_choice(hh, sl)

side_choice = zeros(size(hh));

% Went left if : a) LHS trial and hit OR b) RHS trial and miss
lhs_hit = intersect(find(sl > 0), find(hh > 0));
rhs_miss = intersect(find(sl < 1), find(hh < 1));

side_choice(union(lhs_hit,rhs_miss)) = 1; 

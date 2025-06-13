function [k] = apoke_during_timeout(p)

k = [];

for i=1:length(p),
    got_it = 0;
    for j=1:rows(p{i}.timeout),

        timeout_trap(1,1:3) = { 'in', 'after_strict',  p{i}.timeout(j,1) };
        timeout_trap(2,1:3) = { 'out', 'before_strict',   p{i}.timeout(j,2) };

        left =  get_pokes_multiple_conditions(p{i}, 'left', timeout_trap, 'all');
        right = get_pokes_multiple_conditions(p{i}, 'right', timeout_trap, 'all');
        
        if ~isempty(left) || ~isempty(right), got_it = 1; end;
    end;
    if got_it >0, k = [k; i];end;
end;

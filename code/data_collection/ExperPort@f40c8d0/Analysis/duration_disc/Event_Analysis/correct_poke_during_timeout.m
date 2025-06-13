function [k] = correct_poke_during_timeout(p)

k = zeros(size(p));
correct_act = get_correct_sides(p);

for i=1:length(p),
    for j=1:rows(p{i}.timeout),

        timeout_trap(1,1:3) = { 'in', 'after_strict',  p{i}.timeout(j,1) };
        timeout_trap(2,1:3) = { 'out', 'before_strict',   p{i}.timeout(j,2) };

        first_left =  get_pokes_multiple_conditions(p{i}, 'left', timeout_trap, 'all');
        first_right = get_pokes_multiple_conditions(p{i}, 'right', timeout_trap, 'all');

        tout_poke = [];

        if isempty(first_left) & ~isempty(first_right),
            tout_poke = 'r';
        elseif isempty(first_right) & ~isempty(first_left),
            tout_poke = 'l';
        elseif ~isempty(first_right) & ~isempty(first_left),
            if first_right(1,1) < first_left(1,1), tout_poke = 'r';
            else tout_poke = 'l';
            end;
        end;

        if ~isempty(tout_poke) & tout_poke == correct_act(i),
            k(i) = 1;
        end;
    end;
end;

% b = isinside(x, y, box)
% returns whether the list of coordinates in [x y] are inside 
% the box, where box = [xpos ypos xwidth ywidth]
function b = isinside(x, y, box)
    if numel(box) ~= 4,
        b = 0;
        return;
    end;
    
    n = min(length(x), length(y));
    if n < 1,
        warning('isinside: one of the arguments is empty');
        b = 0;
        return;
    end;
    
    b = zeros(1,n);
    for i = 1:n,
        if x(i) > box(1) && x(i) < box(1)+box(3) ...
                && y(i) > box(2) && y(i) < box(2)+box(4),
            b(i) = 1;
        else
            b(i) = 0;
        end;
    end;
end

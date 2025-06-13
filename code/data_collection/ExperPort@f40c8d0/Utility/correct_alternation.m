function [s,nc] = correct_alternation(s, lprob, thresh)

% alt_side_tester

% lprob = 0.5;
% thresh  = 5;
% s = rand(1,1000) <= lprob;

done = 0;
over_t = 0; loops = 0;
nc = 0;
while ~done
    loops = loops + 1; over_t = 0;
    alt = alternating_sides(s);
    for k = 1:size(alt,2)
        if length(alt{k}) > thresh
            over_t = over_t + 1; 
            curr = alt{k};
            mp = floor(length(curr)/2);
%            sprintf('Before: %s', num2str(s(curr)))          
            s(curr(mp)) = 1 - s(curr(mp));
%            sprintf('After: %s', num2str(s(curr)))
        end;
    end;    
    if over_t == 0, done = 1; end;
    if over_t == 0 && loops == 1, nc = 1; end;
%    sprintf('Loop %1f, > %1f = %1f', loops, thresh, over_t)
end;
function [s] = cross_tester(p, to)


s = zeros(rows(p), 1);
for k = 1:rows(p)
    s(k) = to{k}.pre_sound + to{k}.cue + ...
        to{k}.pre_go + to{k}.go;
    
    s(k) = s(k) - rows(p{k}.timeout);
    
end;

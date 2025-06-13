function [flag] = is_multiple(a, b)
    % returns true if a is a multiple of b; else, false
    
flag = a/b == floor(a/b);
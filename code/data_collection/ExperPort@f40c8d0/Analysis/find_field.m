function [rlist] = find_field(n,str)
% returns the index and field names that (partially) match the given string
% n is a cell array of strings, str is the string you want to find. 
% Matching occurs from the end of the string.
i = length(str)-1;
rlist = [];
for r = 1:length(n), 
    tmp = n{r}; 
    if strcmpi(tmp(end-i:end), str), 
        fprintf(1,'%i:%s\n', r,n{r}); 
        rist = horzcat(rlist, r);
        
    end; 
end;
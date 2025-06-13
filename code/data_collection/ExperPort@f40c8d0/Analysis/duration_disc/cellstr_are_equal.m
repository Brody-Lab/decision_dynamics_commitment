function [v] = cellstr_are_equal(c1,c2)
% given two cells of strings, c1 and c2, returns 1 if the contents and
% order of contents are the same.
v=1;
if size(c1) ~= size(c2)
    v=0;
    return;
end;

for k=1:length(c1)
    try
        if ~strcmpi(c1{k}, c2{k})
            v=0;
            return;
        end;
    catch
        warning('%s:cannot match c1 and c2 for some reason',mfilename);
        v=0;
        return;
    end;
end;


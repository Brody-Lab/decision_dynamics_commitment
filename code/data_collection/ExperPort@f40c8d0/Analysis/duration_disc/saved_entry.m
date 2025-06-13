function [fval] = saved_entry(mystruct, fname)
% returns the contents of the field 'fname' from the struct 'mystruct'


fieldlist = fieldnames(mystruct);
idx1 = strfind(fieldnames(mystruct), fname);
fval = {};
for k = 1:rows(idx1)
    if ~isempty(idx1{k})
        fval{end+1,1} = fieldlist{k};
    end;
end;
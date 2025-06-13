function [newstruct] = sortstruct(oldstruct)

newstruct=[];
fnames=fieldnames(oldstruct);
fsort = sort(fnames);

for f=1:length(fsort)
    curr=fsort{f};
    eval(['newstruct.' curr '=oldstruct.' curr ';']);
    
end;
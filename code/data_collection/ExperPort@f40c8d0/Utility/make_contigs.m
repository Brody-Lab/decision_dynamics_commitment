function [contigs] = make_contigs(var)

breaks = find(diff(var) ~=1);

if isempty(breaks),
    contigs{1} = var;
    return;
else
    contigs{1} = var(1:breaks(1));
end;

for b=2:length(breaks)
    contigs{b} = var(breaks(b-1)+1:breaks(b));
end;

if breaks(end) ~= length(var)
    contigs{length(breaks)+1} = var(breaks(end)+1:end);
end;
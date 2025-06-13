function [alt_ind] = alternating_sides(inlist)

alt_ind = [];
if length(inlist) < 2, return; end;
t = diff(inlist); u = diff(t);
alt_ind = find_contiguous(u);   % find blocks of alternating sides
stitch = [];
for ctr = 1:size(alt_ind,2)        
    stitch = [stitch alt_ind{ctr}];
end;

l = length(inlist); a = size(alt_ind,1);
if isempty(find(stitch == l-1)) && inlist(end-1) ~= inlist(end)
    alt_ind{a+1} = [length(inlist)-1 length(inlist)];
end;
a = size(alt_ind,1);
if isempty(find(stitch == 1)) && inlist(1) ~= inlist(2) && length(inlist) > 2
    alt_ind{a+1} = [1 2];
end;

for k = 1:size(alt_ind,2), alt_ind{k}= sort(alt_ind{k}); end;

% ---------------------------------------------------------------
function [carray] = find_contiguous(in)
in = abs(in);

carray = cell(0,0); curr = 1;
for i = 2:length(in)
    if in(i-1) == 2 && in(i) ~= 2       % ending alternating block
        if size(carray,2) < curr, carray{curr} = [];end; 
        t = carray{curr}; 
        % boundary
        if i==2, t = [i-1 i i+1]; else t = [t t(end)+1 t(end)+2];end;
        carray{curr} = t;
        curr = curr+1;
    elseif in(i-1) ~= 2 && in(i) == 2   % starting a block
        t = i;
        if i == length(in), t = [t t(end)+1 t(end)+2]; end;        %boundary
        carray{curr} = t;        
    elseif in(i-1) == 2 && in(i) == 2   % in the middle of a block
        if size(carray,2) < curr, carray{curr} = [];end; 
        t = carray{curr};
        if i == 2, t = [1]; end;
        if isempty(t), t = [i]; else t = [t i]; end;
        if i == length(in), t = [t t(end)+1 t(end)+2]; end;        %boundary
        carray{curr} = t;
    end;
end;
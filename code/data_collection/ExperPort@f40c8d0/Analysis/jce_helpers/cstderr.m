
function y=stderr(x,dim)

if ~exist('dim','var')
    dim=1;
end


if iscell(x)
    for xi=1:numel(x)
        t{xi}=cstderr(x{xi},dim);
    end
    try
        y=cell2mat(t);
    catch
        y=t;
    end

else

y=nanstderr(x)
end
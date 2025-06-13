function y=between(x, start, finish)
% y=between(x, start, finish)
% works for 1D vectors.

if length(start)~=length(finish)
    y=[];
    return
end

if length(start)==1
    y=x((x>start)&(x<finish));
else
    y=[];
    for i=1:length(start)
        t=x((x>start(i))&(x<finish(i)));
        y=[y;t];
    end
end
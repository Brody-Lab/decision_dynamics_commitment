
function y=stderr2(x)

% Gives the standard error ignoring NaN
% divides by the number of NON-NaN values.

if size(x,1)==1
    x=x';
end

ncols=size(x,2);


y=zeros(1,ncols);

for i=1:ncols
    
    t=x(:,i);
    nt=t(~isnan(t));
    t=t(~isinf(t));
    y(i)=std(nt)/sqrt(length(nt));
    
end

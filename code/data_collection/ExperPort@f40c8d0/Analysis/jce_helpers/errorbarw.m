function [y,e]=errorPlot(n1,n2,n3)

if nargin==1
    y=mean(n1);
    e=stderr(n1);
    x=1:length(y);
    opt=[];
elseif nargin==2
    if ischar(n2)
        y=mean(n1);
        e=stderr(n1);
        x=1:length(y);
        opt=n2;
    else 
        x=n1;
        y=mean(n2);
        e=stderr(n2);
        opt=[];
    end
else 
    x=n1;
    y=mean(n2);
    e=stderr(n2);
    opt=n3
end

if opt
errorbar(x,y,e,opt)
else
    errorbar(x,y,e)
end

return
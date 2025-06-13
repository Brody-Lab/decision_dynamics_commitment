function [r,varargout]=pcorr(a,b);

[r,p]=corrcoef(a,b);
r=r(1,2);
p=p(1,2);
if nargout==2;
    varargout{1}=p;
end
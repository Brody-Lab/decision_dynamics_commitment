function [z,varargout]=r2z(x,n,a)

if nargin<3
    a=0.95;
end

x=col(x);
z=(log((1+x)./(1-x)))/2;
if nargout>1
    if exist('n','var')
        n=col(n);
        varargout{1}=[z+1./sqrt(n-3) z-+1./sqrt(n-3)];
    else
        disp('you need to say how many points were used to calculate each r')
    end
end
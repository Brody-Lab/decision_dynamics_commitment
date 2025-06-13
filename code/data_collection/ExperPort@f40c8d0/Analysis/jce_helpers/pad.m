function y=pad(x,n, p)
% function y=pad(x,n, p)
% function y=pad(x,n)
% pad takes a vector, x,  and an integer ,n, and pads x with zeros (or
% p) so that it is length n
% 

if nargin<3
    p=0;
end

if isempty(x)
    y=zeros(n,1)+p;
elseif length(x)<n
    [r,c]=size(x);
    if r<c
        z=zeros(1,n-c)+p;
        y=[x z];
    else
        z=zeros(n-r,1)+p;
        y=[x;z];
    end
    
elseif length(x)==n
    y=x;
elseif length(x)>n
    msgbox('WTF - n is smaller than x');
    y=x(1:n);
end
  

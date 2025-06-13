function y=jconv(krn,x)
%function y=jconv(krn,x);
% give data and a kernel, and return data of the same size but smooth.
%for some reason the two points on the ends are too low... basically it is
%an artifact of the tails of the gaussian.  you essentially end up with a
%result that is krn length small than your original vector.
% what i'm going to do is just set the first few values to be the same as
% the lenght(krn)/2 value.
if mod(length(krn),2)==1
    b=(length(krn)-1)/2;
    y=conv2(krn,x);
    y=y(:,b+1:end-b);
else
    b=(length(krn))/2;
    y=conv2(krn,x);
    y=y(:,b+1:end-b);
end
 fl=floor(sum(krn>0.001)/2);
 if fl
 y(:,1:fl)=repmat(y(:,fl), 1, fl);
 y(:,end-fl+1:end)=repmat(y(:,end-fl),1,fl);
 end
% NOTE: this is a bit of a hack
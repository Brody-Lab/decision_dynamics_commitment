function y = bin3(x,s)
% BIN3  Bin pixels in an image stack by averaging neighborhoods
%
%	Y = BIN3(X,[N M L]) averages pixels in NxMxL neighborhoods of X,
%  forming a new 3D array with dimensions reduced by a factor on N, M, L
%  X must be a 3 dimensional array and should have length and
%  width divisible by the integers N & M & L respectively.
% 
%  NOTE: works with 
% 
%	Y = BIN3(X,N) assumes M=N=L, a cubic neighborhood
%
%  Y = BIN3(X) assumes neighborhood of 2x2x2
% 
%  Z. Mainen
%  Cold Spring Harbor Lab
%  Jan, 2000
%

if nargin < 2
   n=2; m=2; l=2;
else
   if length(s) == 1
      m =s; n=s; l=s;
   else
      n = s(1);
      m = s(2);
      l = s(3);
   end
end

if sum(mod(size(x),[n m l]))
   error('BIN2: Array size must be a multiple of bin sizes')
end

w = size(x,1)/n;
h = size(x,2)/m;
d = size(x,3)/l;

y = zeros(w,h,d);

if isa(x,'double')
    for i=1:n
        for j=1:m
            for k=1:l
                y = y + x((0:w-1)*n+i,(0:h-1)*m+j,(0:d-1)*l+k);
            end
        end
    end
else 
    for i=1:n
        for j=1:m
            for k=1:l
                xd = x((0:w-1)*n+i,(0:h-1)*m+j,(0:d-1)*l+k);
                y = y + double(xd);
            end
        end
    end
end	

y = y/(m*n*l);




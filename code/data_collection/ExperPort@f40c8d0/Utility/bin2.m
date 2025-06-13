function y = bin2(x,s)
% BIN2  Bin pixels in an image by averaging neighborhoods
%
%	Y = BIN2(X,[N M]) averages pixels in NxM neighborhoods of X,
%  forming a new image with dimensions reduced by a factor on N, M
%  X must be a 2 dimensional array and should have length and
%  width divisible by the integer N & M respectively (which must be > 1).
% 
%	Y = BIN2(X,N) assumes M=N, a square neighborhood
%
%  Y = BIN2(X) assumes neighborhood of 2x2
% 
%  Z. Mainen
%  Cold Spring Harbor Lab
%  Jan, 2000
%

if nargin < 2
   n = 2; m = 2;
else
   if s == 1
       y = x;
       return
   end
   if length(s) < 2
      m = s; n= s;
   else
      n = s(1);
      m = s(2);
   end
end

if sum(mod(size(x),[n m]))
   error('BIN2: Array size must be a multiple of bin sizes')
end

w = size(x,1)/n;
h = size(x,2)/m;

y = zeros(w,h);

if isa(x,'double')
    for i=1:n
        for j=1:m
            y = y + x((0:w-1)*n+i,(0:h-1)*m+j);
        end
    end
else
    for i=1:n
        for j=1:m
            xd = x((0:w-1)*n+i,(0:h-1)*m+j);
            y = y + double(xd);
        end
    end
end    
y = y/(m*n);
   
   


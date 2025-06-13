function out = Stack(a,s)
% OUT = STACK(A,S)
% A is a 3 dimensional matrix
% OUT a 3d matrix with avg of S frames in A


if mod(size(a,3),s)
   error('STACK: Matrix size must be a multiple of bin size')
end
d = size(a,3)/s;

for i=1:d
    out(:,:,i) = double(a(:,:,i*s));
    for j=2:s
        out(:,:,i) = out(:,:,i) + double(a(:,:,i*s+j));
    end
end
out = out/s;

	  
  
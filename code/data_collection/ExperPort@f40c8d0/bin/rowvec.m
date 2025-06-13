%rowvec    [x] = rowvec(x)   Turn data in x into a row vector
%
%

function [x] = rowvec(x)
   
   a = size(x);
   
   x = reshape(x, 1, prod(a));
   
   

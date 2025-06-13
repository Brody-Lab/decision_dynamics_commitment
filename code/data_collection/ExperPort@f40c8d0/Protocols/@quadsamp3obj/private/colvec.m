%colvec    [x] = colvec(x)   Turn data in x into a column vector
%
%

function [x] = colvec(x)
   
   a = size(x);
   
   x = reshape(x, prod(a), 1);
   
   

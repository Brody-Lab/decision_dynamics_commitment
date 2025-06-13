%cell2num   [M] = cell2num(C)   Turn cell of nums into matrix
%
% Assumes each element of C is a single number, or
% empty. Transforms C into a matrix M containing those
% numbers. (NaN for empty).
%
% BUG: works only for up to 2-d cells at present.

function [M] = cell2num(C)

   M = zeros(size(C));
   
   for i=1:rows(C),
      for j=1:cols(C),
	 if isempty(C{i,j}), M(i,j) = NaN;
	 else M(i,j) = C{i,j}; end;
      end;
   end;
   
   
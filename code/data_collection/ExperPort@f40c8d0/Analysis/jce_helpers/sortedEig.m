% [E, D] = sortedEig(X)
%
% Calls matlab's "eig" function for computing
% eigenvalues/eigenvectors, but re-orders the solution to run from
% largest eigenvalue to smallest.

function  [E, D] = sortedEig(X)

[Eo, Do] = eig(X); 
Do = diag(Do);
[junk,Ind] = sort(Do);
D = diag( Do(Ind(length(Ind):-1:1)) );
E = Eo(:, Ind(length(Ind):-1:1));

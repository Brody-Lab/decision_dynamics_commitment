function [x fval] = fscanf_pbups_fit(filename)

% reads in a file of parameter values and the resultant functional values
%
% every row is taken to be an iteration of the fit
% the first three values are the parameters and the fourth is the fval

fid = fopen(filename, 'r');

A = fscanf(fid, '%e %e %e %e', [1e7 inf]);

A = reshape(A, 4, numel(A)/4);

x = A(1:3, :)';
fval = A(4, :)';

fclose(fid);
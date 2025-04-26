function [w, Phi] = fit_linear_basis_functions_model(spiketrains, varargin)
% Fit a linear model with radial basis functions to a neuron
%
% ARGUMENT
%
%   spiketrains
%       a neuron's spike train on each trial stored as a cell vector
%
% RETURN
%
%   w
%       encoding weights
%
%   Phi
%       a N-by-D matrix containing the values of the D basis functions at N values
%
% OPTIONAL ARGUMENT
%
%   compression
%       a scalar parameter indicating the degree the beginning is overreperesented.
%
%   D
%       number of basis functions
parser = inputParser;
addParameter(parser, 'compression', NaN,  ...
             @(x) validateattributes(x, {'numeric'}, {'scalar'}))
addParameter(parser, 'D', 5,  ...
             @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer'}))
parse(parser, varargin{:});
P = parser.Results; 


ntimesteps_each_trial = cellfun(@numel, spiketrains);
maxtimesteps = max(ntimesteps_each_trial);
y = cell2mat(cellfun(@(spiketrain) spiketrain(:), spiketrains, 'uni', 0));
Phi = FHMDDM.raisedcosines(P.D, maxtimesteps, 'compression', P.compression);
X = nan(length(y), P.D);
k = 0;
for i = 1:numel(spiketrains)
    indices = 1:ntimesteps_each_trial(i);
    X(k+indices,:) = Phi(indices,:);
    k = k + ntimesteps_each_trial(i);
end
w = X \ y;
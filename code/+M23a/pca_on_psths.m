function Coeff = pca_on_psths(PSTHs, varargin)
% Perform a principal component analysis (PCA) on the peri-stimulus time histograms (PSTH)
%
% ARGUMENT
%
%   PSTHs
%       a vector of structs whose each element corresponds to a neuron. Each field of the structu
%       corresponds to a particular group of trials that meets a certain condition, such as trials
%       ending in a left choice
%
% OUTPUT
%
%   Coeff
%       principal components coefficients, also known as loadings. Each field of this struct
%       corresponds to a trial condition and contains a $T$-by-$C*T$ matrix, where $T$ is the number
%       of time steps in the PSTH and %C% the number of conditions. Each column of this matrix
%       contains the coefficients for one principal component, and the columns are arranged in
%       descending order of the variance explained by each principal component
%
% OPTIONAL ARGUMENT
%
%   conditions
%       a string indicating the trial conditions on which PCA will be performed
validateattributes(PSTHs, {'cell'}, {'vector'})
parser = inputParser;
defaultconditions = ["leftchoice_weak_leftevidence", "leftchoice_strong_leftevidence", ...
    "rightchoice_weak_rightevidence", "rightchoice_strong_rightevidence"];
addParameter(parser, 'conditions', defaultconditions, @(x) isstring(x))
addParameter(parser, 'observed', true, @(x) islogical(x) && isscalar(x))
addParameter(parser, 'zscore', false, @(x) islogical(x) && isscalar(x))
parse(parser, varargin{:});
P = parser.Results; 
assert(all(contains(defaultconditions, string(fieldnames(PSTHs{1})))), ...
    'conditions are not instantiated in the PSTH')
nneurons = numel(PSTHs);
ntimesteps = numel(PSTHs{1}.unconditioned.observed);
X = [];
for condition = P.conditions
    baselinesubtracted = nan(ntimesteps, nneurons);
    for n = 1:nneurons
        if P.observed
            conditioned = PSTHs{n}.(condition).observed;
            unconditioned =  PSTHs{n}.unconditioned.observed;
        else
            conditioned = PSTHs{n}.(condition).predicted;
            unconditioned =  PSTHs{n}.unconditioned.predicted;
        end
        deltatimesteps = ntimesteps - numel(conditioned);
        if deltatimesteps > 0
            conditioned = [conditioned; nan(deltatimesteps,1)];
        end
        baselinesubtracted(:,n) = conditioned - unconditioned;
    end
    X = [X; baselinesubtracted];
end
X = X(:,~any(isnan(X)));
if P.zscore
    X = (X - mean(X))./std(X);
end
[coeff,~,latent] = pca(X');
if ~isempty(coeff)
    Coeff = struct;
    k = 0;
    for condition = P.conditions
        indices = k+1:k+ntimesteps;
        Coeff.(condition) = coeff(:,indices);
        k = k + ntimesteps;
    end
    % leftconditions = P.conditions(contains(P.conditions, 'left'));
    % rightconditions = P.conditions(contains(P.conditions, 'right'));
    % leftsum = sum(cell2mat(arrayfun(@(condition) sum(Coeff.(condition)), leftconditions, 'uni', 0)'));
    % rightsum = sum(cell2mat(arrayfun(@(condition) sum(Coeff.(condition)), rightconditions, 'uni', 0)'));
    % wrongsign = leftsum > 0 & rightsum < 0;
    % for condition = P.conditions
    %     Coeff.(condition)(:,wrongsign) = Coeff.(condition)(:,wrongsign)*-1;
    % end
else
    Coeff = [];
end
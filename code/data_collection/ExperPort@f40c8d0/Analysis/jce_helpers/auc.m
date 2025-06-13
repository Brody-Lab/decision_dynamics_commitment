function [y]=auc(stim,nostim)

labels=[ones(numel(stim),1); zeros(numel(nostim),1)];
values=[stim(:);nostim(:)];

% Count observations by class
nTarget     = numel(stim);
nBackground = numel(nostim);

% Rank data
R = tiedrank(values);  % 'tiedrank' from Statistics Toolbox

% Calculate AUC
y = (sum(R(labels == 1)) - (nTarget^2 + nTarget)/2) / (nTarget * nBackground);

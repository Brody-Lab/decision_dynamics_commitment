function [d,auc]=dprime(stim,nostim)

thres=mean([mean(stim) mean(nostim)]);
h=sum(stim>thres);
FA=sum(nostim>thres);
ph=h/(length(stim)+length(nostim));
pFA=FA/(length(stim)+length(nostim));

d=abs(norminv(ph)-norminv(pFA));

labels=[ones(numel(stim),1); zeros(numel(nostim),1)];
values=[stim(:);nostim(:)];

% Count observations by class
nTarget     = numel(stim);
nBackground = numel(nostim);

% Rank data
R = tiedrank(values);  % 'tiedrank' from Statistics Toolbox

% Calculate AUC
auc = (sum(R(labels == 1)) - (nTarget^2 + nTarget)/2) / (nTarget * nBackground);

if auc<0.5
	auc=1-auc;
end
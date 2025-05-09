original_path = path; % so that original search path can be restored
scriptpath = fileparts(matlab.desktop.editor.getActiveFilename);
repo_root = fileparts(fileparts(scriptpath));
addpath(genpath(repo_root))
%%
nTc = struct;
nTc.obsv = readtable(fullfile(common.locatedata, 'processed_data', 'common', 'nTc'), 'Delimiter',',');
nTc.pred = readtable(fullfile(common.locatedata, 'processed_data', 'common', 'nTc_simulated'), ...
    'Delimiter',',');
indices = ismember(nTc.obsv.recording_id, nTc.pred.recording_id);
nTc.obsv = nTc.obsv(indices,:);
nTc.pred.choice = logical(nTc.pred.choice);
nTc.obsv.recording_id = string(nTc.obsv.recording_id);
recording_ids = unique(nTc.obsv.recording_id);
nrecordings = numel(recording_ids);
[choice,absnormdiff] = deal(cell(nrecordings,1));
for i = 1:nrecordings
    S = load(fullfile(common.locatedata, 'processed_data', 'recordings', [recording_ids{i} '.mat']));
    choice{i} = cellfun(@(trial) trial.choice, S.trials);
    absnormdiff{i} = cellfun(@(trial) abs(numel(trial.clicktimes.R) - numel(trial.clicktimes.L))/...
        (numel(trial.clicktimes.R) + numel(trial.clicktimes.L)), S.trials);
    i
end
nTc.obsv.choice = vertcat(choice{:});
absnormdiff = cell2mat(absnormdiff);
%%
nbins = 14;
G = discretize(absnormdiff, nbins);
x = splitapply(@mean, absnormdiff,G);
Y = struct;
for cond = ["obsv", "pred"]
    Y.(cond) = nan(nrecordings,nbins);
    for i = 1:nrecordings
        indices = nTc.(cond).recording_id == recording_ids(i);
        has_nTc = ~isnan(nTc.(cond).commitment_timestep(indices));
        G = discretize(absnormdiff(indices), nbins);
        Y.(cond)(i,:) = splitapply(@mean,has_nTc, G)/mean(has_nTc);
    end
end
%
close all
figure('pos', [100 100 300 275])
common.stylizeaxes
set(gca, 'fontsize', 18)


ci = bootci(1e3,@mean,Y.pred);
common.shadeplot(x,ci(1,:),ci(2,:), 'facecolor', colors.pred)
plot(x,mean(Y.pred), '-', 'color', colors.pred, 'linewidth', 1)

plot(x,mean(Y.obsv), 'o', 'color', colors.obsv, 'linewidth', 1, 'markersize', 8)
ci = bootci(1e3,@mean,Y.obsv);
for i = 1:nbins
    plot(x(i)*[1,1], ci(:,i), '-', 'color', colors.obsv, 'linewidth', 1.5)
end

ylim([0.45, 1.7])
yticks([0.5 1 1.5])
xlim([-0.05 1])
xticks([0 1])

xlabel('hard trials <--> easy')
ylabel(sprintf('fraction with \\color[rgb]{%f,%f,%f}nTc', colors.nTc))

[analysispath, scriptname] = fileparts(matlab.desktop.editor.getActiveFilename);
saveas(gcf, fullfile(analysispath, [scriptname '.svg']))
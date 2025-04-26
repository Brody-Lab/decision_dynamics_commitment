original_path = path; % so that original search path can be restored
scriptpath = fileparts(matlab.desktop.editor.getActiveFilename);
repo_root = fileparts(fileparts(scriptpath));
addpath(genpath(repo_root))

files = dir(fullfile(common.locatedata, 'processed_data', 'recordings'));
files = files(arrayfun(@(x) ~x.isdir, files));
figure('pos', [100 100 300 300])
common.stylizeaxes
fileindex = 1;
S = load(fullfile(files(1).folder, files(1).name));
choices = cellfun(@(trial) trial.choice, S.trials);
Deltaclicks = cellfun(@(trial) numel(trial.clicktimes.R) - numel(trial.clicktimes.L), S.trials);        
groupindices = discretize(Deltaclicks, 8);
groupDeltaclicks = splitapply(@mean, Deltaclicks, groupindices);
[obsv, obsvci] = splitapply(@(x) binofit(sum(x), numel(x)), choices, groupindices);
xlim([-40 40])
xticks([-40, 0, 40])
ylim([0 1])
plot(xlim, 0.5*[1,1], 'k--', 'linewidth', 0.5)
plot([0 0], ylim, 'k--', 'linewidth', 0.5)
plot(groupDeltaclicks, obsv, 'k-', 'linewidth', 2);

yticks(ylim)
xlabel('#R-#L clicks')
ylabel('fraction chose right')


path(original_path) % restore search path
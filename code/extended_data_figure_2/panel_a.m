original_path = path; % so that original search path can be restored
scriptpath = fileparts(matlab.desktop.editor.getActiveFilename);
repo_root = fileparts(fileparts(scriptpath));
addpath(genpath(repo_root))

files = dir(fullfile(common.locatedata, 'processed_data', 'recordings'));
files = files(arrayfun(@(x) ~x.isdir, files));
ratname = arrayfun(@(x) string(x.name(1:4)), files);
ratlist = unique(ratname);
figure('pos', [100 100 2400 1200])
bins = [-inf, -30:10:30, inf];
for i = 1:numel(ratlist)
    fileindices = find(ratlist(i)==ratname);
    subplot(3,4,i)
    common.stylizeaxes
    title(char(ratlist(i)))
    [choices, Deltaclicks] = deal(cell(numel(fileindices),1));
    for j = 1:numel(fileindices)
        k = fileindices(j);
        S = load(fullfile(files(k).folder, files(k).name));
        choices{j} = cellfun(@(trial) trial.choice, S.trials);
        Deltaclicks{j} = cellfun(@(trial) numel(trial.clicktimes.R) - numel(trial.clicktimes.L), S.trials);        
    end
    Deltaclicks= vertcat(Deltaclicks{:});
    choices = vertcat(choices{:});
    groupindices = discretize(Deltaclicks, bins);
    groupDeltaclicks = splitapply(@mean, Deltaclicks, groupindices);
    [obsv, obsvci] = splitapply(@(x) binofit(sum(x), numel(x)), choices, groupindices);
    common.shadeplot(groupDeltaclicks, obsvci(:,1), obsvci(:,2));
    xlim([-40 40])
    xticks([-40, 0, 40])
    ylim([0 1])
    yticks(ylim)
    if i == 1
        xlabel('#R-#L clicks')
    else
        xlabel(' ')
    end
end

path(original_path) % restore search path
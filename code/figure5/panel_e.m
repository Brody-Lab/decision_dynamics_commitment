original_path = path; % so that original search path can be restored
scriptpath = fileparts(matlab.desktop.editor.getActiveFilename);
repo_root = fileparts(fileparts(scriptpath));
addpath(genpath(repo_root))
%%
nTc = readtable(fullfile(common.locatedata, 'processed_data', 'common', 'nTc'), 'Delimiter',',');
nTc_simulated = readtable(fullfile(common.locatedata, 'processed_data', 'common', 'nTc_simulated'), ...
    'Delimiter',',');
% indices = ismember(nTc.stereoclick_time_s, nTc_simulated.stereoclick_time_s);
% nTc = nTc(indices,:);
nTc_simulated.choice = logical(nTc_simulated.choice);
nTc.recording_id = string(nTc.recording_id);
recording_ids = unique(nTc.recording_id);
nrecordings = numel(recording_ids);
[choice,Deltaclicks] = deal(cell(nrecordings,1));
for i = 1:nrecordings
    S = load(fullfile(common.locatedata, 'processed_data', 'recordings', [recording_ids{i} '.mat']));
    choice{i} = cellfun(@(trial) trial.choice, S.trials);
    Deltaclicks{i} = cellfun(@(trial) numel(trial.clicktimes.R) - numel(trial.clicktimes.L), S.trials);
    i
end
choice = cell2mat(choice);
Deltaclicks = cell2mat(Deltaclicks);
%%
close all
figure('pos', [100 100 550 275])
subplot(1,2,1)
common.stylizeaxes
title('data')
set(gca, 'fontsize', 18)
binedges = [-inf, -30:10:30, inf];
ngroups = numel(binedges)-1;
G = discretize(Deltaclicks, binedges);
x = splitapply(@mean, Deltaclicks, G);
has_nTc = ~isnan(nTc.commitment_timestep);
colors = common.colors;
plot([-40,40], 0.5*[1,1], '--', 'linewidth', 1,'color', 0.5*ones(1,3))
plot([0,0], [0,1], '--', 'linewidth', 1,'color', 0.5*ones(1,3))

y = nan(ngroups,1);
for i = 1:ngroups
    indices = ~has_nTc & G==i;
    [y(i), ci] = binofit(sum(choice(indices)), sum(indices));
end
plot(x,y,'o-', 'markersize',6, 'linewidth', 1,'color', 'k', 'MarkerFaceColor', 'k', ...
    'markeredgecolor','none')

for i = 1:ngroups
    indices = has_nTc & G==i;
    [y(i), ci] = binofit(sum(choice(indices)), sum(indices));
end
plot(x,y,'o-', 'markersize',6, 'linewidth', 1,'color', colors.nTc,'MarkerFaceColor',colors.nTc, ...
    'markeredgecolor','none')
text(-40, 0.9, 'trials with nTc', 'color', colors.nTc, 'fontsize', get(gca, 'fontsize'))
text(0, 0.2, 'trials without nTc', 'color', 'k', 'fontsize', get(gca, 'fontsize'))

xlim([-42 40])
ylim([-0.05 1])
xticks([-40 0 40])
yticks([0 0.5 1])
ylabel(sprintf('fraction chose {\\color[rgb]{%f,%f,%f}right}', colors.rightchoice))
xlabel(sprintf('{\\color[rgb]{%f,%f,%f}#right} - {\\color[rgb]{%f,%f,%f}#left} clicks', ...
    colors.rightchoice, colors.leftchoice))

subplot(1,2,2)
title('predicted', 'color', '#0d8944')
common.stylizeaxes
set(gca, 'fontsize', 18)
binedges = [-inf, -30:10:30, inf];
ngroups = numel(binedges)-1;
G = discretize(nTc_simulated.Deltaclicks, binedges);
x = splitapply(@mean, nTc_simulated.Deltaclicks, G);
has_nTc = ~isnan(nTc_simulated.commitment_timestep);
colors = common.colors;
plot([-40,40], 0.5*[1,1], '--', 'linewidth', 1,'color', 0.5*ones(1,3))
plot([0,0], [0,1], '--', 'linewidth', 1,'color', 0.5*ones(1,3))

y = nan(ngroups,1);
for i = 1:ngroups
    indices = ~has_nTc & G==i;
    [y(i), ci] = binofit(sum(nTc_simulated.choice(indices)), sum(indices));
end
plot(x,y,'o-', 'markersize',6, 'linewidth', 1,'color', 'k', 'MarkerFaceColor', 'k', ...
    'markeredgecolor','none')
y = nan(ngroups,1);
for i = 1:ngroups
    indices = has_nTc & G==i;
    [y(i), ci] = binofit(sum(nTc_simulated.choice(indices)), sum(indices));
end
plot(x,y,'o-', 'markersize',6, 'linewidth', 1,'color', colors.nTc,'MarkerFaceColor',colors.nTc, ...
    'markeredgecolor','none')

xlim([-42 40])
ylim([-0.05 1])
xticks([-40 0 40])
yticks([0 0.5 1])
ylabel(sprintf('fraction chose {\\color[rgb]{%f,%f,%f}right}', colors.rightchoice))
xlabel(sprintf('{\\color[rgb]{%f,%f,%f}#right} - {\\color[rgb]{%f,%f,%f}#left} clicks', ...
    colors.rightchoice, colors.leftchoice))

[analysispath, scriptname] = fileparts(matlab.desktop.editor.getActiveFilename);
saveas(gcf, fullfile(analysispath, [scriptname '.svg']))
%%
rmpath(genpath(repo_root)) % restore search path
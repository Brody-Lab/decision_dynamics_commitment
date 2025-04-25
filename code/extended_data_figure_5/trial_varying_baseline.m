[analysispath, panelname] = fileparts(matlab.desktop.editor.getActiveFilename)
[~,figurename] = fileparts(analysispath)
%%
filepath = 'X:\tzluo\analysis_data\analysis_2023_05_26b_recovery\T176_2018_05_03_dynamic\results\modelsummary.mat';
load(filepath)
datapath = 'X:\tzluo\analysis_data\analysis_2023_05_26b_recovery\T176_2018_05_03_dynamic\trialsets.mat';
load(datapath)
%%
n = 10;
firingrates = cellfun(@(trial) sum(double(trial.spiketrains{n}))/double(trial.ntimesteps), ...
    trialsets{1}.trials)*100;
trialtimes_s = cellfun(@(trial) trial.stereoclick_time_s, trialsets{1}.trials);
trialtimes_s = trialtimes_s - min(trialtimes_s);
trialtimes_min = trialtimes_s/60;
close all
figure('pos', [1e2,1e2,800,400])
M23a.stylizeaxes
colors = M23a.colors;
h = nan(2,1);
h(1) = plot(trialtimes_min, firingrates, 'k.', 'markersize', 10);
ylabel('spikes/s', 'rotation', 0)
ylimleft = ylim;
xlim([0 210])
yticks(ylim)
yyaxis right
h(2) = plot(trialtimes_min, temporal_basis_vectors_gain{1}{n}, '-', ...
    'linewidth', 2);
ylim(ylimleft)
yticks(ylim)
ylabel('weight', 'rotation', 0)
xlabel('minutes')
% legend(h, {'observed', 'baseline'}, 'location', 'northeast')
saveas(gcf, fullfile(fullfile(M23a.locateassets, figurename),panelname), 'svg')
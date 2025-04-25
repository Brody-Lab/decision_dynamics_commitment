[analysispath, scriptname] = fileparts(matlab.desktop.editor.getActiveFilename);
[~,analysisname] = fileparts(analysispath);
%%
filepath = 'X:\tzluo\analysis_data\analysis_2023_05_26b_recovery\T176_2018_05_03_dynamic\results\modelsummary.mat';
load(filepath)
datapath = 'X:\tzluo\analysis_data\analysis_2023_05_26b_recovery\T176_2018_05_03_dynamic\trialsets.mat';
load(datapath)
%%
n = 5;
firingrates = cellfun(@(trial) sum(double(trial.spiketrains{n}))/double(trial.ntimesteps), ...
    trialsets{1}.trials)*100;
trialtimes_s = cellfun(@(trial) trial.stereoclick_time_s, trialsets{1}.trials);
trialtimes_s = trialtimes_s - min(trialtimes_s);
trialtimes_min = trialtimes_s/60;
close all
figure('pos', [1e2,1e2,550,400])
M23a.stylizeaxes
colors = M23a.colors;
h = nan(2,1);
h(1) = plot(trialtimes_min, firingrates, 'k.', 'markersize', 10);
h(2) = plot(trialtimes_min, temporal_basis_vectors_gain{1}{n}, '-', ...
    'color', colors.rightchoice, 'linewidth', 2);
xlabel('minutes')
ylabel('spikes/s')
legend(h, {'observed', 'baseline'}, 'location', 'northeast')
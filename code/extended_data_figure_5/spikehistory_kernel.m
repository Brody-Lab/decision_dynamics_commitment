[analysispath, panelname] = fileparts(matlab.desktop.editor.getActiveFilename)
[~,figurename] = fileparts(analysispath)
%%
filepath = 'X:\tzluo\analysis_data\analysis_2023_05_26b_recovery\T176_2018_05_03_dynamic\results\modelsummary.mat';
load(filepath)
datapath = 'X:\tzluo\analysis_data\analysis_2023_05_26b_recovery\T176_2018_05_03_dynamic\trialsets.mat';
load(datapath)
%%
n = 10;
k = temporal_basis_vectors_postspike{1}*thetaglm{1}{n}.u_postspike;
close all
figure('pos', [1e2,1e2,500,300])
M23a.stylizeaxes
plot(0.01:0.01:0.25, k, 'k-', 'linewidth', 2)
xlim([0 0.25])
xticks([0 0.2])
ylabel('weight')
xlabel('time after spike (s)')
ylim([-6, 1])
yticks([-5 0])
saveas(gcf, fullfile(fullfile(M23a.locateassets, figurename),panelname), 'svg')
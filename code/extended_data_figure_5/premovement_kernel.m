[analysispath, panelname] = fileparts(matlab.desktop.editor.getActiveFilename)
[~,figurename] = fileparts(analysispath)
%%
filepath = 'X:\tzluo\analysis_data\analysis_2023_05_26b_recovery\T176_2018_05_03_dynamic\results\modelsummary.mat';
load(filepath)
datapath = 'X:\tzluo\analysis_data\analysis_2023_05_26b_recovery\T176_2018_05_03_dynamic\trialsets.mat';
load(datapath)
%%
n = 10;
k = temporal_basis_vectors_premovement{1}*thetaglm{1}{n}.u_premovement;
close all
figure('pos', [1e2,1e2,500,300])
M23a.stylizeaxes
plot(-0.6:0.01:-0.01, k, 'k-', 'linewidth', 2)
xlim([-0.6 0])
xticks(xlim)
ylabel('weight')
xlabel('time before movement (s)')
saveas(gcf, fullfile(fullfile(M23a.locateassets, figurename),panelname), 'svg')
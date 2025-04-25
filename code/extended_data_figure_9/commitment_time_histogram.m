clc
clear
[analysispath, panelname] = fileparts(matlab.desktop.editor.getActiveFilename);
[~, figurename] = fileparts(analysispath);
load('X:\tzluo\analysis_data\analysis_2023_06_30b_pericommitment\commitment_timesteps.mat')
%%
close all
committime_s = double(commitment_timesteps(commitment_timesteps>0))*0.01
figure('pos', [100 100 430 350])
M23a.stylizeaxes
h = histogram(committime_s, 0:0.05:1, 'normalization', 'probability')
set(h, 'facecolor', 'k', 'facealpha',0.2)
ylabel('fraction of trials')
yticks(ylim)
xlim([0 1])
xticks(xlim)
title('times')
xlabel('time(s)')
folderpath = fullfile(fileparts(fileparts(fileparts(analysispath))), 'assets', figurename);
saveas(gcf, fullfile(folderpath, [panelname '.svg']))
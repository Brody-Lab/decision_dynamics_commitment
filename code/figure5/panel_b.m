original_path = path; % so that original search path can be restored
scriptpath = fileparts(matlab.desktop.editor.getActiveFilename);
repo_root = fileparts(fileparts(scriptpath));
addpath(genpath(repo_root))
%%
[analysispath, scriptname] = fileparts(matlab.desktop.editor.getActiveFilename);
[~, analysisname] = fileparts(analysispath);
%%
figure_position = [100 100 500 300];
binsize_s = 1/21;
colors = common.colors;
T = readtable(fullfile(repo_root, 'data', 'processed_data', 'common', 'nTc.csv'));
figure('Position', figure_position)
common.stylizeaxes
tdelta_s = T.commitment_time_s - T.stereoclick_time_s;
tdelta_s(tdelta_s==1) = 1-eps;
h = histogram(tdelta_s, 0:binsize_s:1, 'linewidth', 0.5);
set(h, 'facecolor', colors.nTc, 'facealpha', 0.2)
xlabel('time from first click (s)')
xlim([0 1])
xticks([0 1])
ylabel('trials')
saveas(gcf, fullfile(analysispath, [scriptname '.svg']))
%% restore search path
rmpath(genpath(repo_root))
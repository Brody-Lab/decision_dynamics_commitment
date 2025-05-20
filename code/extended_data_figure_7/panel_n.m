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
figure('Position',figure_position)
common.stylizeaxes
tdelta_s = T.commitment_time_s - T.cpoke_in - 1.500;
tdelta_s(tdelta_s >= 0.5) = 0.5-eps;
tdelta_s(tdelta_s<-1) = -1;
h = histogram(tdelta_s, -1:0.1:0.5, 'linewidth', 1);
set(h, 'facecolor', colors.nTc, 'facealpha', 0.2)
xlabel('time from stimulus offset (s)')
xlim([-1 0.5])
xticks(-1:0.5:0.5)
ylabel('trials')
saveas(gcf, fullfile(analysispath, [scriptname '.svg']))
%% restore search path
rmpath(genpath(repo_root))
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
common.stylizeaxes
tdelta_s = T.commitment_time_s - T.movementtime_s;
tdelta_s(tdelta_s<-1) = -1-binsize_s/2;
h = histogram(tdelta_s, (-1-binsize_s):binsize_s:0, 'linewidth', 0.5);
set(h, 'facecolor', colors.nTc, 'facealpha', 0.2)
xlabel('time from movement onset (s)')
xlim([-1-binsize_s 0])
xticks([-1 0])
xticklabels({'-1', '0'})
ylabel('trials')
saveas(gcf, fullfile(analysispath, [scriptname '.svg']))
%% restore search path
rmpath(genpath(repo_root))
original_path = path; % so that original search path can be restored
scriptpath = fileparts(matlab.desktop.editor.getActiveFilename);
repo_root = fileparts(fileparts(scriptpath));
addpath(genpath(repo_root))
%%
[analysispath, scriptname] = fileparts(matlab.desktop.editor.getActiveFilename);
[~, analysisname] = fileparts(analysispath)
%%
T = readtable(fullfile(analysispath,["panel_d.csv"]));
close all
common.stylizeaxes
colors = common.colors;
h(1) = plot(T.times_s, T.predicted, '-', 'linewidth', 5, 'color', colors.choicemaintenance);
h(2) = plot(T.times_s, T.observed, 'k-', 'linewidth', 2);
h(3) = plot(T.times_s, T.shuffled, 'k--', 'linewidth', 1);
xticks([-0.2, 0, 0.2])
yticks(-0.2:0.2:0.4)

plot(xlim, [0,0], '-', 'linewidth', 0.5, 'color', 0.5*[1,1,1])
legend(h, {'predicted', 'observed', 'shuffled'}, 'location', 'northeast')
ylabel('weight')
xlabel('time relative to each trial''s nTc (s)')
saveas(gcf, fullfile(analysispath, [scriptname '.svg']))
%% restore search path
rmpath(genpath(repo_root))
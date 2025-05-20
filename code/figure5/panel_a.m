original_path = path; % so that original search path can be restored
scriptpath = fileparts(matlab.desktop.editor.getActiveFilename);
repo_root = fileparts(fileparts(scriptpath));
addpath(genpath(repo_root))
%%
[analysispath, scriptname] = fileparts(matlab.desktop.editor.getActiveFilename);
[~,figurename] = fileparts(analysispath);
load(fullfile(repo_root, 'data', 'processed_data', figurename, [scriptname '.mat']))
%%
nTc = 0.01*find(pcommit_choicespikes > 0.8, 1);
d_pcommit_choicespikes = diff(pcommit_choicespikes)
d_pcommit_choice = diff(pcommit_choice)
times_s = 0.01 + 0.01*(1:numel(d_pcommit_choicespikes));
common.stylizeaxes
ax =gca;
colors = common.colors;
plot(times_s, d_pcommit_choicespikes, 'color', colors.nTc, 'linewidth', 3)
ylabel('p(commit | choice, spikes)')
ylim(ylim.*[0 1])
yticks(ylim)
plot(nTc, 1, 'kv', 'markerfacecolor', 'k', 'markersize', 15)
yyaxis right
set(gca, 'colororder',0.5*ones(1,3))
plot(times_s, d_pcommit_choice, ':', 'color', 0.5*ones(1,3), 'linewidth', 2)
ylabel('p(commit | choice)')
ylim(ylim.*[0 1])
ax.YAxis(1).Color = colors.nTc;
ax.YAxis(2).Color = 0.5*ones(1,3);
xlabel('time from first click (s)')
yticks(ylim)
saveas(gcf, fullfile(analysispath, [scriptname '.svg']))
%% restore search path
rmpath(genpath(repo_root))
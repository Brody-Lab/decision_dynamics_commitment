original_path = path; % so that original search path can be restored
scriptpath = fileparts(matlab.desktop.editor.getActiveFilename);
repo_root = fileparts(fileparts(scriptpath));
addpath(genpath(repo_root))

[analysispath, scriptname] = fileparts(matlab.desktop.editor.getActiveFilename);
[~,figurename] = fileparts(analysispath);

%{
To reproduce plots directly from the Multi-Mode Drift-Diffusion Model
(MMDDM) outputs:

1. Download the required files from this Google Drive folder:

https://drive.google.com/drive/folders/1jD_hj9qfBm0Whw6KWi_7k0WjaCwRNyTF

2. Place them in the following local directory: `data/MMDDM/`.

Note: If these files are not present, the scripts will default to using the
smaller, highly processed files located in `data/processed_data/`.
%}
MMDDM_output = fullfile(repo_root, 'data', 'MMDDM', 'analysis_2023_05_26a_cv', ...
    'T176_2018_05_03_dynamic', 'crossvalidation');
if isfolder(MMDDM_output)
    load(fullfile(MMDDM_output, 'paccumulator_choicespikes.mat'));
    load(fullfile(MMDDM_output, 'paccumulator_choice.mat'));
    trial_index = 8;
    pcommit_choicespikes = cellfun(@(x) x(1) + x(end), paccumulator_choicespikes{1}{trial_index});
    pcommit_choice = cellfun(@(x) x(1) + x(end), paccumulator_choice{1}{trial_index});
    fprintf('\nCreating plot using files in `data/MMDDM/`')
else
    load(fullfile(repo_root, 'data', 'processed_data', figurename, [scriptname '.mat']))
    fprintf('\nCreating plot using files in `data/processed_data/`')
end

nTc = 0.01*find(pcommit_choicespikes > 0.8, 1);
d_pcommit_choicespikes = diff(pcommit_choicespikes);
d_pcommit_choice = diff(pcommit_choice);
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
svgpath = fullfile(analysispath, [scriptname '.svg']);
if ~isfile(svgpath)
    saveas(gcf, fullfile(analysispath, [scriptname '.svg']))
end
% restore search path
rmpath(genpath(repo_root))
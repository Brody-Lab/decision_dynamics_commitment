original_path = path; % so that original search path can be restored
scriptpath = fileparts(matlab.desktop.editor.getActiveFilename);
repo_root = fileparts(fileparts(scriptpath));
addpath(genpath(repo_root))

T = readtable(fullfile(common.locatedata, 'processed_data', 'figure5', ...
    'analysis_2023_05_26b_recovery.csv'));
wEA = T.fit_wEA;
wDC = T.fit_wDC;
T.EI = (abs(wEA) - abs(wDC))./(abs(wEA) + abs(wDC));
T.brainarea = string(T.brainarea);
brainareas = ["mPFC", "dStr", "dmFC", "M1", "vStr", "FOF"];
figure('pos', [100 100 2000 300])
colors = common.colors;
for i = 1:numel(brainareas)
    subplot(1,numel(brainareas),i)
    common.stylizeaxes
    x = T.EI(T.brainarea==brainareas(i));
    histogram(x, -1:(2/11):1, ...
        'facealpha', 0.2, ...
        'facecolor', colors.(brainareas(i)), 'Normalization', 'probability');
    xlim([-1.1 1.1])
    ylim([0 0.2])
    if i == 1
        xlabel('engagement index')
        ylabel('fraction of neurons')
    else
        xlabel(' ')
        ylabel(' ')
    end
    yticks(ylim)
    set(gca, 'fontsize', 18)
    plot(median(x), max(ylim), 'v', 'markersize', 10, ...
        'markeredgecolor', 'none', 'MarkerFaceColor', colors.(brainareas(i)))
end

rmpath(genpath(repo_root)) % restore search path
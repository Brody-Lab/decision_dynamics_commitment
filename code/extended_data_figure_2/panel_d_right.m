original_path = path; % so that original search path can be restored
scriptpath = fileparts(matlab.desktop.editor.getActiveFilename);
repo_root = fileparts(fileparts(scriptpath));
addpath(genpath(repo_root))
load(fullfile(common.locatedata, 'processed_data', 'extended_data_figure2', 'Trials.mat'))

figure('position', [100,100, 1200, 300])
k = 0;
for rat_name = {'K214', 'K215', 'K216'}; rat_name = rat_name{:};
    k = k + 1;
    subplot(1,3,k);
    common.stylizeaxes
    Res = PB_plot_correct_rate_of_Sessions(Trials.(rat_name), ...
                                            'ax', gca, ...
                                            'one_line', true, ...
                                            'line_prop', {'MarkerSize', 3, 'linewidth', 1}, ...
                                             'axes_prop', {'YLim', [50, 100]});
end

path(original_path) % restore search path
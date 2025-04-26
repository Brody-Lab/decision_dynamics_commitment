original_path = path; % so that original search path can be restored
scriptpath = fileparts(matlab.desktop.editor.getActiveFilename);
repo_root = fileparts(fileparts(scriptpath));
addpath(genpath(repo_root))

load(fullfile(common.locatedata, 'processed_data', 'figure2', 'panel_b.mat'))
figure('position', [100 100 550 275])
s = common.spikeRasterPlot(seconds(spiketimes), neurons);
s.ColorOrder(1,:) = zeros(1,3);
s.XLimits = seconds([0 0.85]);
s.XLabelText = 'time from stimulus onset (s)';
xticks(seconds([0 0.8]))
yticks(s,[])
s.YLabelText = 'neurons';

path(original_path) % restore search path
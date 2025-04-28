original_path = path; % so that original search path can be restored
scriptpath = fileparts(matlab.desktop.editor.getActiveFilename);
repo_root = fileparts(fileparts(scriptpath));
addpath(genpath(repo_root))

filepath = fullfile(common.locatedata, 'processed_data', 'figure5', 'analysis_2023_09_17a_cv.mat');
load(filepath)

DeltaLL = struct;
for brainarea = common.brainareas
    DeltaLL.(brainarea) = [];
    k = 0;
    for i = 1:size(sessions,1)
        sessionindices = T.brainarea == brainarea & T.recording_id == sessions.recording_id(i);
        MMDDMindex = sessionindices & T.fit_beta;
        DDMindex = sessionindices & ~T.fit_beta;
        if sum(MMDDMindex)==1 || sum(DDMindex) == 1
            k = k + 1;
            DeltaLL.(brainarea)(k,1) = T.LL(MMDDMindex) - T.LL(DDMindex);
        end
    end
    brainarea
end

DeltaLLmedian = structfun(@median, DeltaLL, 'uni', 0);
DeltaLLmedianCI = struct;
for brainarea = common.brainareas
    DeltaLLmedianCI.(brainarea) = bootci(1e3, @median, DeltaLL.(brainarea));
end

close all
figure('pos', [1e2, 1e2, 1000, 400])
common.stylizeaxes
colors = common.colors;
sigma = 0.5;
k = 0;
for brainarea = common.brainareas
    k = k + 1;
    x = DeltaLL.(brainarea);
    plot(k + [-0.4 0.4], median(x)*[1,1], 'k', 'linewidth', 2)
    swarmchart(k*ones(numel(x),1),x,[],colors.(brainarea),'filled','MarkerFaceAlpha',0.5,'MarkerEdgeAlpha',0.5)
end
set(gca, 'position', [0.5, 0.3, 0.4, 0.5])
plot(xlim, zeros(1,2), 'k-')
xlim([0.5, k+0.5])
xticks(1:k)
xticklabels(arrayfun(@(x) string(sprintf('\\color[rgb]{%f,%f,%f}%s', colors.(x), x)), common.brainareas))
set(gca, 'xticklabelrotation', 30)
ylabel('Deltabits/(neurons*trials)')
title('MMDDM - DDM')
% saveas(gcf, fullfile(analysispath, 'DeltaLL.svg'))
ylabel('Delta bits/(neurons*trials)')

rmpath(genpath(repo_root)) % restore search path
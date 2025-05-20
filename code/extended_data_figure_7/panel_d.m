original_path = path; % so that original search path can be restored
scriptpath = fileparts(matlab.desktop.editor.getActiveFilename);
repo_root = fileparts(fileparts(scriptpath));
addpath(genpath(repo_root))
%-------------
[analysispath, scriptname] = fileparts(matlab.desktop.editor.getActiveFilename);
[~,figurename] = fileparts(analysispath)
output_subfolder = fullfile(repo_root, 'data', 'processed_data', figurename, scriptname)
%-------------
nresamples = 10;
fluctuationweights = cell(nresamples,1);
for i = 1:nresamples
    filepath = fullfile(output_subfolder, sprintf('aggregate%i.mat', i));
    S = load(filepath);
    Y = cell2mat(cellfun(@transpose, S.fluctuationsweight, 'uni', 0));
    fluctuationweights{i} = mean(Y);
end
%-------------
nresamples = 10;
fluctuationweights_shuffled = cell(nresamples,1);
for i = 1:nresamples
    filepath = fullfile(output_subfolder, sprintf('aggregate_shuffled%i.mat', i));
    S = load(filepath);
    Y = cell2mat(cellfun(@transpose, S.fluctuationsweight, 'uni', 0));
    fluctuationweights_shuffled{i} = mean(Y);
end
%-------------
Y = cell2mat(fluctuationweights);
Y_shuffled = cell2mat(fluctuationweights_shuffled);
close all
common.stylizeaxes
ci = bootci(1e3, @mean, Y);
common.shadeplot(S.times_s, ci(1,:), ci(2,:))

h(1) = plot(S.times_s, mean(Y), 'k-', 'linewidth', 2);
h(2) = plot(S.times_s, mean(Y_shuffled), 'k--', 'linewidth', 1);

legend(h, {'observed', 'shuffled'}, 'location', 'northeast')

ylabel('weight of excess click input')
xlabel('time from commitment (s)')
yticks([0, 0.5])

saveas(gcf, fullfile(analysispath, [scriptname '.svg']))
%-------------
% restore search path
rmpath(genpath(repo_root))
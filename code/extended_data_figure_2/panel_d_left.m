original_path = path; % so that original search path can be restored
scriptpath = fileparts(matlab.desktop.editor.getActiveFilename);
repo_root = fileparts(fileparts(scriptpath));
addpath(genpath(repo_root))

load(fullfile(common.locatedata, 'processed_data', 'extended_data_figure2', 'Trials.mat'))
figure
common.stylizeaxes
ratnames = string(fieldnames(Trials));
nbins = 8;
for condition = ["saline", "bilateral"]
    [choice, evidence] = deal(cell(numel(ratnames),1));
    for i = 1:numel(ratnames)
        indices = Trials.(ratnames(i)).pharma.manip == condition;
        evidence{i} = Trials.(ratnames(i)).click_diff_norm(indices);
        choice{i} = Trials.(ratnames(i)).pokedR(indices);
    end
    evidence = cell2mat(evidence);
    choice = cell2mat(choice);
    group = discretize(evidence,nbins);
    x = splitapply(@mean, evidence, group);
    [y, yci] = splitapply(@(x) binofit(sum(x), numel(x)), choice, group);
    if condition == "saline"
        color = 'k';
    else
        color = [0 100, 200]/255;
    end
    for i = 1:nbins
        plot(x(i)*[1,1], yci(i,:), '-', 'color', color, 'linewidth', 1)
    end
    plot(x, y, 'o', 'color', color)
    b = glmfit(evidence,choice,'binomial');
    yhat = glmval(b,-1:0.01:1, 'logit');
    plot(-1:0.01:1, yhat, 'color', color)
end
xlabel('normalized evidence favoring right')
ylabel('fraction chose right')

path(original_path) % restore search path
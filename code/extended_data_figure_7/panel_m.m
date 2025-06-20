original_path = path; % so that original search path can be restored
[scriptpath, scriptname] = fileparts(matlab.desktop.editor.getActiveFilename);
repo_root = fileparts(fileparts(scriptpath));
addpath(genpath(repo_root))

[~, figurename] = fileparts(scriptpath);
filepath = fullfile(common.locatedata, 'processed_data', figurename, [scriptname '.mat']);
load(filepath)
%%
T = Tcommit;
for i = 1:size(T,1)
    T{i}.recording_id = string(T{i}.recording_id);
    if ~ismember("M1", T{i}.Properties.VariableNames)
        T{i}.M1 = nan(size(T{i},1),1);
    end
end
T = vertcat(T{:})
%%
pairs={};
i =0;
i=i+1;
pairs{i} = ["dmFC", "mPFC"];
i=i+1;
pairs{i} = ["M1", "dStr"];
i=i+1;
pairs{i} = ["M1", "vStr"];
i=i+1;
pairs{i} = ["dStr", "vStr"];
i=i+1;
pairs{i} = ["dStr", "FOF"];
i=i+1;
pairs{i} = ["vStr", "FOF"];
lag_s = nan(numel(pairs),1);
ci_s = nan(numel(pairs),2);
pval = nan(numel(pairs),1);
for i = 1:numel(pairs)
    indices = ~isnan(T.(pairs{i}(1))) & ~isnan(T.(pairs{i}(2)));
    x = T.(pairs{i}(1))(indices) - T.(pairs{i}(2))(indices);
    fprintf('\n%s vs. %s: N = %i trials', pairs{i}{1}, pairs{i}{2}, sum(~isnan(x)))
    lag_s(i) = mean(x, 'omitnan');
    ci(i,:) = bootci(1e4, @mean, x);
    i
end
%%
figure('position', [100 100 1100 530])
common.stylizeaxes
for i = 1:numel(lag_s)
    h = plot(i*[1,1], ci(i,:), 'k-', 'linewidth', 1);
    plot(i,lag_s(i), 'ko', 'linewidth', 1)
end
ylabel('  \Deltatime of\newlinecommitment\newline       (s)', 'rotation', 0)
xlim([0.5 numel(lag_s)+0.5])
xticks(1:numel(lag_s))
xticklabels(cellfun(@(x) string([char(x(1)) '-' char(x(2))]), pairs))
plot(xlim, [0,0], 'k--')
legend(h, '95%CI of mean', 'location', 'best')
saveas(gcf, fullfile(scriptpath, [scriptname '.svg']))

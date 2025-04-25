[analysispath, panelname] = fileparts(matlab.desktop.editor.getActiveFilename)
[~,figurename] = fileparts(analysispath)
%%
T = FHMDDM.tabulateoptions('V:\Documents\tzluo\analyses\analysis_2023_05_26a_cv');
T = T(contains(T.fitpath, 'dynamic'),:);
%%
binedges = [-inf, -30:10:30, inf];
R2 = nan(size(T,1));
ntrials = nan(size(T,1));
for i = 111:size(T,1)
    clear trialsets expectedemissions
    load(fullfile(T.fitpath{i}, 'trialsets.mat'));
    load(fullfile(T.fitpath{i}, 'crossvalidation\expectedemissions.mat'));
    choices = cellfun(@(trial) trial.choice, trialsets{1}.trials);
    Deltaclicks = cellfun(@(trial) ...
        numel(trial.clicktimes.R) - numel(trial.clicktimes.L), trialsets{1}.trials);
    Echoices = cellfun(@(trial) trial.rightchoice, expectedemissions{1});
    groupindices = discretize(Deltaclicks, binedges);
    obsv = splitapply(@(x) binofit(sum(x), numel(x)), choices, groupindices);
    pred = splitapply(@(x) binofit(sum(x), numel(x)), Echoices, groupindices);
    SStotal = sum(obsv.^2);
    SSresidual = sum((pred-obsv).^2);
    R2(i) = 1 - SSresidual/SStotal;
    ntrials(i) = numel(trialsets{1}.trials);
    disp(i)
end
%%
figure('pos', [1e2,1e2,300 260])
M23a.stylizeaxes
h = histogram(R2);
set(h, 'facecolor', 'k', 'facealpha', 0.2)
xlim([0.9, 1])
xticks(xlim)
yticks(ylim)
xlabel('out-of-sample R2 of psychometric')
ylabel('sessions')
saveas(gcf, fullfile(fullfile(M23a.locateassets, figurename), panelname), 'svg')
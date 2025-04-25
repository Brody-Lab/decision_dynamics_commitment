[analysispath, panelname] = fileparts(matlab.desktop.editor.getActiveFilename)
[~, figurename] = fileparts(analysispath)
%%
settingsname = '2023_05_26a';
settings = M23a.get_data_settings(settingsname);
sessions = M23a.tabulate_recording_sessions;
sessions.rat = cellfun(@(x) string(x(1:4)), sessions.recording_id);
ratlist = unique(sessions.rat);
figure('pos', [100 100 2400 1200])
bins = [-inf, -30:10:30, inf];
for i = 1:numel(ratlist)
    sessionindices = find(ratlist(i)==sessions.rat);
    subplot(3,4,i)
    M23a.stylizeaxes
    title(char(ratlist(i)))
    [choices, Deltaclicks] = deal(cell(numel(sessionindices),1));
    for j = 1:numel(sessionindices)
        recording_id = sessions.recording_id{sessionindices(j)};
        S = load(fullfile(settings.folderpath, [recording_id '.mat']));
        choices{j} = cellfun(@(trial) trial.choice, S.trials);
        Deltaclicks{j} = cellfun(@(trial) numel(trial.clicktimes.R) - numel(trial.clicktimes.L), S.trials);        
    end
    Deltaclicks= vertcat(Deltaclicks{:});
    choices = vertcat(choices{:});
    groupindices = discretize(Deltaclicks, bins);
    groupDeltaclicks = splitapply(@mean, Deltaclicks, groupindices);
    [obsv, obsvci] = splitapply(@(x) binofit(sum(x), numel(x)), choices, groupindices);
    M23a.shadeplot(groupDeltaclicks, obsvci(:,1), obsvci(:,2));
    xlim([-40 40])
    xticks([-40, 0, 40])
    ylim([0 1])
    yticks(ylim)
    if i == 1
        xlabel('#R-#L clicks')
    else
        xlabel(' ')
    end
    disp
end
outputpath = fullfile(M23a.locateassets, figurename, [panelname '.svg']);
saveas(gcf, outputpath)
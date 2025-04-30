settingsname = '2023_04_12';
settings = M23a.get_data_settings(settingsname);
sessions = M23a.tabulate_recording_sessions;
nsessions = size(sessions,1);
PSTHs = cell(nsessions,1);
brainareas = cell(nsessions,1);
for i = 1:nsessions
    i
    filepath = fullfile(settings.folderpath, sessions.recording_id{i});
    S = load(filepath);
    PSTHs{i} = cellfun(@(x) x.psth, S.neurons);
    brainareas{i} = cellfun(@(x) string(x.brainarea), S.neurons);
end
PSTHs = vertcat(PSTHs{:});
brainareas = vertcat(brainareas{:});
%%
choiceselectivity = arrayfun(@(x) x.rightchoice.observed - x.leftchoice.observed, PSTHs, ...
    'UniformOutput',false);
choiceselectivity= cell2mat(choiceselectivity);
for n = 1:size(choiceselectivity,1)
    if mean(choiceselectivity(n,:)) < 0
        choiceselectivity(n,:) = choiceselectivity(n,:)* -1;
    end
end
choiceselectivity = choiceselectivity ./ max(choiceselectivity,[],2);
%%
arealist = ["mPFC", "dmFC", "dStr", "M1", "vStr", "FOF"];
nareas = numel(arealist);
meanselectivity = nan(nareas, size(choiceselectivity,2));
for i = 1:nareas
    neuronindices = brainareas == arealist(i);
    meanselectivity(i,:) = mean(choiceselectivity(neuronindices,:));
end
colors = M23a.colors;
figure
set(gca, 'position', [0.14, 0.16, 0.4, 0.5])
M23a.stylizeaxes
ylim([0 0.8])
time_s = 0.01:0.01:1
for i = 1:nareas
    plot(time_s, meanselectivity(i,:), 'color', colors.(arealist(i)), 'linewidth', 2)
    [~,tmax] = max(meanselectivity(i,:));
    plot(time_s(tmax), max(ylim), 'v', 'markersize', 10, ...
        'color', colors.(arealist(i)), ...
        'markerfacecolor', colors.(arealist(i)))
end
xlim([0,1])
xticks(xlim)
yticks(ylim)
xlabel('time (s)')
ylabel('choice selectivity')
x = 0.2;
for area = ["mPFC", "dmFC", "vStr", "M1", "FOF"]
    x = x + 0.15;
    handle = text(x, max(ylim)*1.1, char(area), 'fontsize', get(gca, 'fontsize'), ...
    'color', colors.(area));
    set(handle, 'rotation', 60)
    if area == "vStr"
        handle = text(x+0.12, max(ylim)*1.35, 'dStr', 'fontsize', get(gca, 'fontsize'), ...
            'color', colors.dStr);
        set(handle, 'rotation', 60)
    end
end
scriptpath = matlab.desktop.editor.getActiveFilename;
[folderpath, graphicname] = fileparts(scriptpath);
[~, foldername] = fileparts(folderpath);
M23a.savegraphic(graphicname, foldername);

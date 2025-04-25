settingsname = '2023_03_29';
settings = M23a.get_data_settings(settingsname);
sessions = M23a.tabulate_recording_sessions;
sessionindices = [find(sessions.recording_id=="T176_2018_05_03"), ...
                  find(sessions.recording_id=="T264_2021_01_15")];
nsessions = numel(sessionindices);
PSTHs = cell(nsessions,1);
for i = 1:nsessions
    sessiondindex = sessionindices(i);
    filepath = fullfile(settings.folderpath, sessions.recording_id{sessiondindex});
    S = load(filepath);
    PSTHs{i} = cellfun(@(x) x.psth, S.neurons);
end
%%
sessionindices = [nan, 1,1,1,2];
neuronindices = [nan, 47,7,29,9];
close all
figure('pos', [100 100, 1400, 250]);
titles = ["simulation", "classic ramp", "decay", "delay", "flip"];
subplot(1,5,1)
M23a.stylizeaxes
psth = M23a.simulate_choice_dynamics;
for condition = ["leftchoice", "rightchoice"]
    M23a.shadeplot(psth.(condition).time_s, ...
         psth.(condition).lowerconfidencelimit, ...
         psth.(condition).upperconfidencelimit, ...
         'facecolor', colors.(condition));
end
text(0.1, 18, 'left choice', 'FontSize', get(gca, 'fontsize'), 'color', colors.leftchoice)
text(0.1, 3, 'right choice', 'FontSize', get(gca, 'fontsize'), 'color', colors.rightchoice)
title(titles{1})
yticks(ylim)
xlabel('time (s)')
ylabel('spikes/s')
xticks(0:1)
for i = 2:5
    subplot(1,5,i)
    M23a.stylizeaxes;
    colors = M23a.colors;
    sessionindex = sessionindices(i);
    neuronindex = neuronindices(i);
    for condition = ["leftchoice", "rightchoice"]
        M23a.shadeplot(PSTHs{sessionindex}(neuronindex).(condition).time_s, ...
             PSTHs{sessionindex}(neuronindex).(condition).lowerconfidencelimit, ...
             PSTHs{sessionindex}(neuronindex).(condition).upperconfidencelimit, ...
             'facecolor', colors.(condition));
    end
    title(titles{i})
    xlabel(' ')
    if i == 5
        ylim([0 15])
    end
    yticks(ylim)
    ylabel(' ')
    xticks(0:1)
end
scriptpath = matlab.desktop.editor.getActiveFilename;
[folderpath, graphicname] = fileparts(scriptpath);
[~, foldername] = fileparts(folderpath);
M23a.savegraphic(graphicname, foldername);
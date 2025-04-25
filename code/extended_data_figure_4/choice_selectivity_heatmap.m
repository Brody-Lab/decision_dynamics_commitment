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
    brainareas{i} = cellfun(@(x) x.brainarea, S.neurons);
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
arealist = ["mPFC", "dmFC", "dStr", "M1", "vStr", "FOF"];
nareas = numel(arealist);
C1 = cell(nareas,1);
centerofmass = cell(nareas,1);
time_s = PSTHs(1).leftchoice.time_s';
nneurons_per_area = zeros(nareas,1);
for i = 1:nareas
    neuronindices = brainareas==arealist(i);
    C1{i} = choiceselectivity(neuronindices,:);
    weight = abs(C1{i});
    weight = weight./sum(weight,2);
    centerofmass{i} = weight*time_s;
    [~, sortindices] = sort(centerofmass{i});
    C1{i} = C1{i}(sortindices,:);
    C1{i}(C1{i}<-1) = -1;
    nneurons_per_area(i) = sum(neuronindices);
end
%%
colors = M23a.colors
axesoffset = 0.05;
axeswidth = 0.08;
axesspacing = 0.01;
figure('pos', [100 100 2000 400])
for i = 1:nareas
    subplot(1,nareas,i)
    M23a.stylizeaxes
    imagesc(C1{i})
    colormap('gray')
    ylim([0, size(C1{i},1)+0.5])
    % yticks(size(C1{i},1))
    yticks([])
    xlim([0 100])
    title(arealist{i}, 'color', colors.(arealist{i}))
    if i == 1
        xlabel('time (s)')
        xticks(xlim)
    else
        xlabel(' ')
        xticks([])
    end
    x = axesoffset+ (axesspacing+axeswidth)*(i-1);
    if i == nareas
        h = colorbar;
        set(h, 'ticks', -1:1, 'fontsize', get(gca, 'fontsize'))
        h.Label.String = 'choice selectivity';
    end
    set(gca, 'xticklabels', [0 1], 'position', [x, 0.17, axeswidth, 0.75])
end
scriptpath = matlab.desktop.editor.getActiveFilename;
[folderpath, graphicname] = fileparts(scriptpath);
[~, foldername] = fileparts(folderpath);
M23a.savegraphic(graphicname, foldername);
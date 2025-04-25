% Goal
%   plot the neuron-average peri-stimulus time histogram across neurons in each brain region
settingsname = '2023_03_24';
settings = M23a.get_data_settings(settingsname);
sessions = M23a.tabulate_recording_sessions;
nsessions = size(sessions,1);
brainareas = cell(nsessions,1);
PSTHs = cell(nsessions,1);
for i = 1:nsessions
    filepath = fullfile(settings.folderpath, sessions.recording_id{i});
    S = load(filepath);
    nneurons = numel(S.neurons);
    brainareas{i} = cellfun(@(x) x.brainarea, S.neurons);
    ratname = sessions.recording_id{i}(1:4);
    PSTHs{i} = M23a.peristimulus_time_histograms(S.trials, settings.timestep_s, ...
        'excludeopto', (ratname=="T219" || ratname == "T223"));
    fprintf('\n%i\n',i)
end
brainareas = vertcat(brainareas{:});
PSTHs = vertcat(PSTHs{:});
%%
figure('pos', [100 100 1800 250])
subplot(1,7,1)
M23a.stylizeaxes
duration_s = 1;
dt = 0.01;
ntimesteps = ceil(duration_s/dt);
ntrials = 1e3;
dv = zeros(ntrials,ntimesteps);
sigma2 = 0.01;
bound = 12;
noise = randn(ntrials,ntimesteps)*sqrt(sigma2);
inputs = zeros(ntrials,ntimesteps);
gammaset = [-4; -0.8; 0.8; 4];
totalhz = 40;
gammas = gammaset(randi(numel(gammaset), ntrials,1));
timebinedges = 0:dt:duration_s;
latency_s = 0.05;
rng(2)
for i = 1:ntrials
    righthz = totalhz*exp(gammas(i))./(1+exp(gammas(i)));
    lefthz = totalhz-righthz;
    lefttimes = cumsum(exprnd(1/lefthz, 2*ceil(lefthz), 1));
    lefttimes = lefttimes(lefttimes >= latency_s & lefttimes<=duration_s);
    righttimes = cumsum(exprnd(1/righthz, 2*ceil(righthz), 1));
    righttimes = righttimes(righttimes >= latency_s & righttimes<=duration_s);
    inputs = histcounts(righttimes, timebinedges) - histcounts(lefttimes, timebinedges);
    for t = 2:ntimesteps
        if abs(dv(i,t-1)) < bound
            dv(i,t) = dv(i,t-1) + noise(t) + inputs(t);
            dv(i,t) = sign(dv(i,t))*min(abs(dv(i,t)), bound);
        else
            dv(i,t:end) = sign(dv(i,t-1))*bound;
            break
        end
    end
end
dvmean = nan(numel(gammaset), ntimesteps);
for i = 1:numel(gammaset)
    dvmean(i,:) = mean(dv(gammas==gammaset(i),:));
end
colors = M23a.colors;
plot(timebinedges(2:end), dvmean(1,:), 'color', colors.leftchoice_strong_leftevidence, 'linewidth', 2.5)
plot(timebinedges(2:end), dvmean(2,:), 'color', colors.leftchoice_weak_leftevidence, 'linewidth', 2.5)
plot(timebinedges(2:end), dvmean(3,:), 'color', colors.rightchoice_weak_rightevidence, 'linewidth', 2.5)
plot(timebinedges(2:end), dvmean(4,:), 'color', colors.rightchoice_strong_rightevidence, 'linewidth', 2.5)
xlabel('time (s)')
ylabel('accum. evidence')
ylim([-bound,bound]*1.5)
yticks(0)
xticks(0:1)
title('simulation')
% ------------------
conditions = ["leftchoice_weak_leftevidence", ...
              "leftchoice_strong_leftevidence", ...
              "rightchoice_weak_rightevidence", ...
              "rightchoice_strong_rightevidence"];
psthsettings = M23a.psthsettings;
maxtimesteps = ceil(psthsettings.duration_s/settings.timestep_s);
timesteps_s = (1:maxtimesteps)*settings.timestep_s;
prefersright = cellfun(@(x) mean(x.rightchoice) > mean(x.leftchoice), PSTHs);
colors = M23a.colors;
k = 1;
for brainarea = ["dmFC", "mPFC", "dStr", "vStr", "M1", "FOF"]
    k = k + 1;
    ax(k) = subplot(1,7,k);
    M23a.stylizeaxes
    neuronindices = find(brainareas == brainarea);
    nneurons = numel(neuronindices);
    aggregate = struct;
    for condition = conditions
        aggregate.(condition) = zeros(nneurons,maxtimesteps);
        for n = 1:nneurons
            neuronindex = neuronindices(n);
            if prefersright(neuronindex)
                neuroncondition = condition;
            else
                if contains(condition, "left")
                    neuroncondition = strrep(condition, 'left', 'right');
                else
                    neuroncondition = strrep(condition, 'right', 'left');
                end
            end
            aggregate.(condition)(n,:) = PSTHs{neuronindex}.(neuroncondition) ./ ...
                    mean(PSTHs{neuronindex}.unconditioned, 'omitnan');
        end
        plot(timesteps_s, mean(aggregate.(condition), 'omitnan'), 'linewidth', 2, ...
            'color', colors.(condition))
    end
    title(char(brainarea), 'color', colors.(brainarea))
    ylim([0.6, 1.5])
    xticks([0 1])
    if k == 2
        ylabel('normalized response')
        xlabel(' ')
    else
        xlabel(' ')
        ylabel(' ')
    end
    fprintf('\n%s: N=%i\n', brainarea, nneurons)
end
scriptpath = matlab.desktop.editor.getActiveFilename;
[folderpath, graphicname] = fileparts(scriptpath);
[~, foldername] = fileparts(folderpath);
M23a.savegraphic(graphicname, foldername);
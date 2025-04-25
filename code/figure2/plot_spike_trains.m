clc
clear
[analysispath, scriptname] = fileparts(matlab.desktop.editor.getActiveFilename);
[~,figurename] = fileparts(analysispath);
%%
sessions = M23a.tabulate_recording_sessions;
load(sessions.Cellspath{1})
load(sessions.Trialspath{1})
%%
trialindices = find(~Trials.violated);
trialindex = trialindices(2);
t1 = Trials.stateTimes.clicks_on(trialindex);
t2 = Trials.stateTimes.cpoke_out(trialindex);
t2-t1
%%
% neuronindices = find(cellfun(@numel, Cells.raw_spike_time_s)/Cells.meta.ap_meta.fileTimeSecs > 2);
neuronindices = 1:32;%numel(Cells.raw_spike_time_s)
%%
clc
[spiketimes, neurons] = deal(cell(numel(neuronindices),1));
for n = 1:numel(neuronindices)
    neuronindex = neuronindices(n);
    timeindices = Cells.raw_spike_time_s{neuronindex} >= t1 & ...
                    Cells.raw_spike_time_s{neuronindex} < t2;
    spiketimes{n} = Cells.raw_spike_time_s{neuronindex}(timeindices);
    neurons{n} = repmat(n, numel(spiketimes{n}),1);
end
spiketimes = cell2mat(spiketimes);
spiketimes = spiketimes-t1;
neurons = cell2mat(neurons);
close all
figure('position', [100 100 550 275])
s = M23a.spikeRasterPlot(seconds(spiketimes), neurons);
s.ColorOrder(1,:) = zeros(1,3);
s.XLimits = seconds([0 0.85]);
s.XLabelText = 'time from stimulus onset (s)';
xticks(seconds([0 0.8]))
yticks(s,[])
s.YLabelText = 'neurons';
%%
saveas(gcf, fullfile(M23a.locateassets, figurename, [scriptname '.svg']))
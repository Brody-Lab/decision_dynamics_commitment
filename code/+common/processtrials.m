function trials = processtrials(Cells, neuronindices, settings, Trials, trialindices)
% select trials and neurons and extract information including the spike trains
%
%=ARGUMENT
%
%   Cells
%       a struct containing spike times and information about the electrophysiological recording5
%
%   neuronindices
%       a vector of integers indicating the index of each neuron to be included
%
%   settings
%       a structure indicating the settings of the processing
%
%   Trials
%       a struct containing information about the task settings and behavioral events
%
%   trialindices
%       linear indices of trials to be used
%
% RETURN
%
%   trials
%       a cell array whose element is a selected trial
validateattributes(Cells, {'struct'},{})
validateattributes(neuronindices, {'numeric'},{'integer','positive'})
validateattributes(settings, {'struct'},{'scalar'})
validateattributes(Trials, {'struct'},{})
validateattributes(trialindices, {'numeric'}, {'vector', 'positive', 'integer'})
timestep_s = settings.timestep_s;
maxtimesteps = floor(settings.maxduration_s/timestep_s);
stereoclick_times_s = M23a.get_stereo_click_time(Trials);
ntrials = numel(trialindices);
trials = cell(ntrials,1);
previousanswer = M23a.previousanswer(Trials);
nneurons = numel(neuronindices);
for i = 1:ntrials
    j = trialindices(i);
    trials{i}.index = j;
    trials{i}.choice = Trials.pokedR(j);
    t0 = stereoclick_times_s(j) - settings.time_before_stereoclick_s;
    assert(Trials.leftBups{j}(1) == Trials.rightBups{j}(1))
    timefromclickson = min([Trials.leftBups{j}, Trials.rightBups{j}]);
    trials{i}.clicktimes.L = Trials.leftBups{j} - timefromclickson + settings.time_before_stereoclick_s;
    trials{i}.clicktimes.R = Trials.rightBups{j} - timefromclickson + settings.time_before_stereoclick_s;
    trials{i}.gamma = Trials.gamma(j);              
    trials{i}.movementtime_s = Trials.stateTimes.cpoke_out(j);
    trials{i}.movementtime_step = ceil((Trials.stateTimes.cpoke_out(j) - t0)/timestep_s) + 1;
    trials{i}.previousanswer = previousanswer(j);
    trials{i}.stereoclick_time_s = stereoclick_times_s(j);
    trials{i}.stereoclick_time_step = ceil((stereoclick_times_s(j) - t0)/timestep_s) + 1;
    if settings.include_spikes_after_movement
        ntimesteps = maxtimesteps;
    else
        ntimesteps = floor((trials{i}.movementtime_s - t0) / timestep_s);
        ntimesteps = min(ntimesteps, maxtimesteps);
    end
    trials{i}.ntimesteps = ntimesteps;
    trials{i}.photostimulus_incline_on_s = Trials.stateTimes.laser_on(j) - t0;
    trials{i}.photostimulus_decline_on_s = Trials.stateTimes.laser_off(j) - t0;
    timebins_s = t0 + (0:timestep_s:(timestep_s*ntimesteps));
    if settings.baseline_dur_s > 0
        trials{i}.baseline_hz = nan(nneurons,1);
        for n = 1:nneurons
            neuronindex = neuronindices(n);
            t1 = Trials.stateTimes.cpoke_in(j) + 1 - settings.baseline_dur_s/2;
            t2 = Trials.stateTimes.cpoke_in(j) + 1 + settings.baseline_dur_s/2;
            trials{i}.baseline_hz(n) = sum(Cells.raw_spike_time_s{neuronindex} >= t1 & ...
                                           Cells.raw_spike_time_s{neuronindex} <  t2);
        end
        trials{i}.baseline_hz = trials{i}.baseline_hz / settings.baseline_dur_s;
    end
    trials{i}.spiketrains = cell(nneurons,1);
    for n = 1:nneurons
        neuronindex = neuronindices(n);
        if settings.include_spikes_after_movement
            t_end = t0 + settings.maxduration_s;
        else
            t_end = trials{i}.movementtime_s;
        end
        indices = Cells.raw_spike_time_s{neuronindex} >= t0 & ...
                  Cells.raw_spike_time_s{neuronindex} <  t_end;
        spiketimes = Cells.raw_spike_time_s{neuronindex}(indices);
        trials{i}.spiketrains{n} = histcounts(spiketimes, timebins_s);
    end
end
function T = tabulate_neuron_selection_criteria()
% create a table of the parameters for selecting neurons with the following variables:
%
%   neuron_selection_id
%       ID of the selection configuration
%
%   referenceevent
%       event in the trial in reference to which spikes are counted
%
%   latencies_s
%       the latencies, in seconds, in reference to the event above for spike counting
%
%   duration_s
%       duration, in seconds, of the counting window
%
%   maskmovement
%       whether movement is masked when counting spikes
%
%   min_firingrate
%       minimum trial averaged firing rate
%
%   maxneurons
%      maximum number of neurons selected
%
%   brainareas
%       select neurons only from these brain areas
%
%   neuronindex
%       select only the neuron with this index in the recording
    filepath = fullfile(M23a.locateassets, 'neuron_selection_criteria.csv');
    opts = detectImportOptions(filepath);
    opts = setvartype(opts,'string');
    T = readtable(filepath, opts);
    for variable = ["duration_s", "min_choiceselectivity", "min_firingrate", "maxneurons", ...
            "neuronindex", "maxDeltaLL"]
        T.(variable) = str2double(T.(variable));
    end
    T.latencies_s = cellstr(T.latencies_s);
    for variable = ["maskmovement"]
        T.(variable) = cellfun(@logical, T.(variable));
    end
    T.latencies_s = cellfun(@str2num, T.latencies_s, 'uni', 0);
end
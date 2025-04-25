function selected = selectneurons(Cells, Trials, settings)
% Select neurons according to a registered scheme
%
%=INPUT
%
%   Cells
%       A structure made by NP_make_Cells.m
%
%   Trials
%       A structure made by PB_process_data.m
%
%   neuron_selection_id
%       A positive integer scalar specifying the criterion for selecting neurons
%
%=OUTPUT
%
%   selected
%       A linear index indicating the selected neurons
validateattributes(Cells, {'struct'}, {'scalar'})
validateattributes(Trials, {'struct'}, {'scalar'})
validateattributes(settings, {'struct'},{'scalar'})
criteriatable = M23a.tabulate_neuron_selection_criteria;
criteria = criteriatable(criteriatable.neuron_selection_id==settings.neuron_selection_id,:);
criteria = table2struct(criteria);
trialindices = M23a.select_trials_for_neuron_selection(Trials, settings);
choices = Trials.pokedR(trialindices) == 1;
selected = true(numel(Cells.raw_spike_time_s), numel(criteria.latencies_s));
load([char(criteria.DeltaLLfolder) filesep Cells.recording_id '.mat'], 'Deltaell_per_trial')
selected(Deltaell_per_trial>criteria.maxDeltaLL,:) = false;
for i = 1:numel(criteria.latencies_s)
    if isnan(criteria.latencies_s(i))
        selected(:,i) = false;
        continue
    end
    FR = M23a.firingrates(Cells, Trials, ...
                    'reference_event', criteria.referenceevent, ...
                    'time_s_from', criteria.latencies_s(i), ...
                    'time_s_to', criteria.latencies_s(i)+criteria.duration_s, ...
                    'maskmovement', criteria.maskmovement, ...
                    'trialindices', trialindices);
    selected(cellfun(@mean, FR) < criteria.min_firingrate, i) = false;
    choiceselectivities = cellfun(@(fr) M23a.choiceselectivity(choices,fr), FR);
    selected(choiceselectivities < criteria.min_choiceselectivity,i) = false;
end
selected = any(selected,2);
if ~ismissing(criteria.brainareas)
    selected(~arrayfun(@(x) contains(criteria.brainareas,x), Cells.cell_area)) = false;
end
if ~isnan(criteria.neuronindex)
    selected(1:numel(selected) ~= criteria.neuronindex) = false;
end
selected = find(selected);
if numel(selected) > criteria.maxneurons
    indices = randperm(numel(selected), criteria.maxneurons);
    indices = sort(indices);
    selected = selected(indices);
end
function process_data_for_SPGLM(Cells,folderpath,neuronindices,Trials,trialindices)
%
%   Prepare data for the `SPGLM` package, which fits Poisson generalized linear models (GLM) to the
%   spike times of individual neurons
%
%=ARGUMENT
%
%   Cells
%       a struct containing spike times and information about the electrophysiological recording5
%
%   folderpath
%       a char row vector specifying the absolute path of the folder where data are stored.
%
%   neuronindices
%       a vector of integers indicating the index of each neuron to be included
%
%   recording_id
%       a string identifying the recording
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
%=RETURN
%
%   nothing
validateattributes(Cells, {'struct'},{})
validateattributes(folderpath, {'char'},{'row'})
validateattributes(neuronindices, {'numeric'},{'integer','positive'})
validateattributes(Trials, {'struct'},{})
validateattributes(trialindices, {'numeric'}, {'vector', 'positive', 'integer'})
Trials = M23a.remove_unindexed_trials(Trials, trialindices);
baseline_pretrial_spikecounts = M23a.baseline_pretrial_spikecounts(Cells, Trials);
if ischar(Cells.sess_date)
    Cells.sess_date = string(Cells.sess_date);
end
nneurons = numel(neuronindices);
recording_id = char(Cells.recording_id);
probe_serial = Cells.meta.ap_meta.imDatPrb_sn;
for n = 1:nneurons
    neuronindex = neuronindices(n);
    Cell = struct;
    Cell.recording_id = recording_id;
    Cell.imDatPrb_sn = probe_serial;
    Cell.index_within_probe = neuronindex;
    Cell.cell_area = Cells.cell_area(neuronindex);
    Cell.cell_hemi = Cells.cell_hemi(neuronindex);
    Cell.fileTimeSecs = Cells.meta.ap_meta.fileTimeSecs;
    Cell.rat = Cells.rat(neuronindex);
    Cell.spiketimes_s = Cells.raw_spike_time_s{neuronindex};
    Cell.sess_date = Cells.sess_date(neuronindex);
    Cell.sessid = Cells.sessid(neuronindex);
    filepath = fullfile(folderpath,sprintf('%s_%i_%03i.mat', recording_id, ...
        probe_serial, neuronindex));
    save(filepath, 'Cell', 'Trials', 'baseline_pretrial_spikecounts')
end

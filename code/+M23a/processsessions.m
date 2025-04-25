function processsessions(settingsname)
% Extract and save data from recording sessions
%
% ARGUMENT
%
%   settingsid
%       a positive integer providing the ID of the settings for data processing
%
% EXAMPLE
%
%   Process the data under settings ID '20230324'
%   >> M23a.processsesions(20230324)
validateattributes(settingsname, {'char'}, {'row'})
settings = M23a.get_data_settings(settingsname);
if isempty(settings)
    error('No settings corresponding to the name: "%s"', settingsname)
end
sessions = M23a.tabulate_recording_sessions;
if ~isfolder(settings.folderpath)
    mkdir(settings.folderpath)
end
for i = 1:size(sessions,1)
    fprintf('\n%i) %s\n', i, sessions.recording_id{i})
    clear Cells Trials
    load(sessions.Cellspath{i}, 'Cells');
    load(sessions.Trialspath{i}, 'Trials');
    trialindices = M23a.select_trials_for_model(Trials, settings);
    if isempty(trialindices)
        warning('   No trial')
        continue
    end 
    neuronindices = M23a.selectneurons(Cells, Trials, settings);
    if numel(neuronindices) == 0
        warning('   No neuron')
        continue
    end
    neurons = arrayfun(@(x) struct('brainarea', Cells.cell_area(x), 'neuronindex', x), ...
        neuronindices, 'UniformOutput',false);
    for n = 1:numel(neurons)
        if neurons{n}.brainarea == "MO" || neurons{n}.brainarea == "PrL"
            neurons{n}.brainarea = "mPFC";
        elseif neurons{n}.brainarea == "M2" || neurons{n}.brainarea == "Cg1"
            neurons{n}.brainarea = "dmFC";
        end
        neurons{n}.brainarea = char(neurons{n}.brainarea);
    end
    folderpath = fullfile(settings.folderpath, sessions.recording_id{i});
    if ~isfolder(folderpath)
        assert(mkdir(folderpath))
    end
    M23a.process_data_for_SPGLM(Cells,char(folderpath),neuronindices,Trials,trialindices)
    trials = M23a.processtrials(Cells, neuronindices, settings, Trials, trialindices);
    filepath = fullfile(settings.folderpath, [sessions.recording_id{i}, '.mat']);
    save(filepath, 'trials', 'neurons');
end
function selectionindices(settingsname)
%{
Document the indices used to select neurons and trials

ARGUMENT

-`settingsname`: A `char` row vector identifying the settings used to select neurons and trials
%}
settings = M23a.get_data_settings(settingsname);
assert(~isempty(settings))
sessions = M23a.tabulate_recording_sessions;
filelist = dir(settings.folderpath);
filelist = filelist(~[filelist.isdir]);
for i = 1:numel(filelist)
    [~, filename, extension] = fileparts(filelist(i).name);
    assert(extension == ".mat")
    assert(sum(sessions.recording_id==filename)==1)
end
outputfolder = fullfile(M23a.locateassets, 'selectionindices',  settingsname);
if ~isfolder(outputfolder)
    mkdir(outputfolder)
end
assert(isfolder(outputfolder))
for i = 1:numel(filelist)
    [~, filename] = fileparts(filelist(i).name);
    sessionindex = filename == sessions.recording_id;
    clear Cells Trials neurons trials
    S = struct;
    S.settingsname = settingsname;
    S.recording_id = sessions.recording_id{sessionindex};
    S.Cells_filepath_windows = sessions.Cellspath{sessionindex};
    S.Cells_filepath_unix = M23a.windows2cup(S.Cells_filepath_windows);
    S.Trials_filepath_windows = sessions.Trialspath{sessionindex};
    S.Trials_filepath_unix = M23a.windows2cup(S.Trials_filepath_windows);
    load(S.Cells_filepath_windows);
    load(S.Trials_filepath_windows);
    load(fullfile(filelist(i).folder, filelist(i).name));
    nneurons = numel(Cells.raw_spike_time_s);
    S.neuronindices = false(nneurons,1);
    S.neuronindices(cellfun(@(neuron) neuron.neuronindex, neurons)) = true;
    cpoke_out_s = cellfun(@(trial) trial.movementtime_s, trials);
    ntrials = numel(trials);
    trialindices = nan(ntrials,1);
    for m = 1:ntrials
        trialindices(m) = find(Trials.stateTimes.cpoke_out == cpoke_out_s(m));
    end
    assert(all(~isnan(cpoke_out_s)))
    S.trialindices = false(numel(Trials.gamma),1);
    S.trialindices(trialindices) = true;
    encoded = jsonencode(S);
    jsonpath = fullfile(outputfolder, [S.recording_id '.json']);
    fid = fopen(jsonpath,'w');
    fprintf(fid,'%s',encoded);
    fclose(fid);
    i
end


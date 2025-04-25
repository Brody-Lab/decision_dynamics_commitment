T = M23a.tabulate_recording_sessions;
for i = 1:size(T,1)
    ratname = T.recording_id{i}(1:4);
    if ratname(1) =='T'
        folderpath = ['X:\RATTER\PhysData\NP_sorted\Thomas\' ratname filesep T.recording_id{i}];
        list = dir(folderpath);
        list = list(3:end);
        if isempty(list)
            warning('no sorted spikes file!')
            continue
        end
        datesmodified = arrayfun(@(x) datetime(x.date), list);
        [~, lastmodified] = max(datesmodified);
        T.sorted_spikes_path{i} = fullfile(list(lastmodified).folder, list(lastmodified).name);
    elseif ratname(1) =='X'
        % the absolute path of Diksha's file were found manually
    end
end
T.sorted_spikes_path = string(T.sorted_spikes_path);
writetable(T, fullfile(M23a.locateassets, 'recordingsessions.csv'));
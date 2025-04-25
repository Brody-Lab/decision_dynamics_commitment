sessions = M23a.tabulate_recording_sessions;
settings = M23a.get_data_settings('2023_05_06');
fracselective = nan(size(sessions,1),1);
for i= 1:size(sessions,1)
    S = load(fullfile(settings.folderpath, sessions.recording_id{i}));
    fprintf('\n%i',i)
    fracselective(i) = numel(S.neurons)/sessions.neurons(i);
end
fprintf('\nmedian=%0.2f, min=%0.2f, max=%0.f', median(fracselective), min(fracselective), ...
    max(fracselective))
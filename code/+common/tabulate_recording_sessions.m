function T = tabulate_recording_sessions()
% Create a table with information on the 
csvpath = fullfile(common.locatedata, 'recordingsessions.csv');
T = readtable(csvpath);
T.recording_id = string(T.recording_id);
T.perturbationtype = string(T.perturbationtype);
T.Cellspath = string(T.Cellspath);
T.Trialspath = string(T.Trialspath);
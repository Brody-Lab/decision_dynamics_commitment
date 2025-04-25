function T = tabulate_data_settings()
% Create a table whose columns are parameters for processing data
filepath = fullfile(M23a.locateassets, 'datasettings.csv');
T = readtable(filepath, 'delimiter', ',');
opts = detectImportOptions(filepath);
opts = setvartype(opts,'string');
T2 = readtable(filepath, opts);
T.neuron_selection_id = T2.neuron_selection_id;
T.settingsname = string(T.settingsname);
T.folderpath = string(T.folderpath);
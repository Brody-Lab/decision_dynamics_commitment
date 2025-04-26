function T = tabulaterats()
T = readtable(fullfile(M23a.locateassets, 'rats.csv'), 'delimiter', ',');
T.ratname = string(T.ratname);
T.expressesopsin = logical(T.expressesopsin);
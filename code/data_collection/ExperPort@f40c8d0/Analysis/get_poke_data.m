function [] = get_poke_data(rat, task, date, f_ver)
% Runner script
% For the given rat/task/date/file version combination, gets the list of 
% both short and valid pokes across all trials.
% Writes data to the SoloData/Poke_Data directory
% e.g. For rat=Sado, task= @pitchsampobj, date = 051117 file version 'a',
% the script call is:
% get_poke_data('Sado', '@pitchsampobj', '051117', 'a')
% and output data is in:
% SoloData/Poke_Data/Sado_@pitchsampobj_051117a.mat


global Solo_datadir;
outfile = [Solo_datadir filesep 'Poke_Data' filesep rat '_' task '_' date f_ver '.txt'];

p_cell = get_short_poke_trials(rat, task, date, f_ver);
fwrite_cell(p_cell, '%4.4f', outfile);


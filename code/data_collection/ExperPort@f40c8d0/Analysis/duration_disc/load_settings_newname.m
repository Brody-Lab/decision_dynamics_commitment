function [] = load_settings(ratname, indate)

global Solo_datadir;

param_setDir = [Solo_datadir filesep 'Settings' filesep 'Shraddha' filesep];
param_ratrow = rat_task_table(ratname);
param_task = param_ratrow{1,2};

param_sfile = [ 'settings_@' param_task '_Shraddha_' ratname '_' indate '.mat'];

load([param_setDir ratname filesep param_sfile]);

2;
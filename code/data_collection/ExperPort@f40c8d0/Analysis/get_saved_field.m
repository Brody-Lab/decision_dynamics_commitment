function [x] = get_saved_field(ratname, task, date, f_ver, fieldowner, fieldname);

% General purpose utility: Gets contents of the desired field for the
% specified datafile
% Datafile is specified by the rat name, task, date, and file version.
%
% Note: This script only accesses the "saved" variable and not
% "saved_history". 

Solo_datadir=[pwd filesep '..' filesep 'SoloData' filesep 'Data' filesep];
load([Solo_datadir 'data_' task '_' ratname '_' date f_ver '.mat']);

x = eval(['saved.' fieldowner '_' fieldname]);


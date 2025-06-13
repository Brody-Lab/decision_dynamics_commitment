function [] = lesion_fileload_sandbox()

global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;

ratname ='Beryl';
filename = 'psych_before';

indir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep ratname filesep];

infile = [indir filename];

load(infile);

2;
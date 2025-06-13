function [] = lesion_filecheck

tissue_name='mPFC';

% opens desired lesion coverage file so you can examine its contents
global Solo_datadir;
histodir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Histo' filesep tissue_name filesep];

ratname = 'Evenstar';
% rat's coordinates as read in from AI
% ratfile = [histodir ratname filesep ratname '_coords.mat'];
% load(ratfile);

% rat's coordinates after running lesion_interpolate on ratname_coords.mat
% ratfile = [histodir ratname filesep ratname '_interpolcoords.mat'];
% load(ratfile);

% lesion coverage file (interpolated using averageshapes)
outfile = [histodir 'lesion_coverage_calc__interpol.mat'];
load(outfile)
2;

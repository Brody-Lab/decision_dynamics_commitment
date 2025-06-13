function [] = lesion_loadroicoords(roiname)

tissue_name='ACx2';
histodir = ['..' filesep 'Histo' filesep tissue_name filesep 'polymark' filesep];
%histodir =[histodir 'intermediate_file' filesep];

load([histodir 'polygon_coords__' roiname '_reordered.mat']);

2;

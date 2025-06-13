function [] = lesion_loadroipoints

roiname = 'A1';
hem='L';

tissue_name='ACx2';

global Solo_datadir;
histodir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep];
  %histodir = ['..' filesep];
histodir=[histodir 'Histo' filesep tissue_name filesep];
%histodir =[histodir 'intermediate_file' filesep];
load([histodir 'lesion_coverage_calc']);

rat1 ='S025';
rat2='S050';
rat3='S036';

x1 = eval([rat1 '_lesioncvg.' roiname '.areapts__' hem]);
x2 = eval([rat2 '_lesioncvg.' roiname '.areapts__' hem]);
x3 = eval([rat2 '_lesioncvg.' roiname '.areapts__' hem]);

figure;
plot(x1,'.b'); hold on;
plot(x2,'-r');
plot(x3,'*g');
legend({rat1, rat2,rat3});
xl=get(gca,'XLim');
set(gca,'XTick', xl(1):1:xl(2));
title(sprintf('%s %s', roiname, hem));
2;

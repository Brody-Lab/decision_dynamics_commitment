function [] = psychauto(d)
  
  % Automatically gets the psychometric curve data for the date provided
  % (d) and saves the figure in the corresponding data folder.
  %
  % Sample usage: psychauto('060522a');

psychometric_curve('ghazni','duration_discobj', d, 'binmin', 300, 'binmax', 800);
savefig(gcf,['psycho_' d], 'ghazni');

psychometric_curve('timur_lang', 'duration_discobj',d, 'binmin', 300, ...
                   'binmax', 800);
savefig(gcf,['psycho_' d], 'timur_lang');

psychometric_curve('attila', 'dual_discobj', d, 'binmin', 1, 'binmax', 15, ...
                   'pitches', 1);
savefig(gcf, ['psycho_' d], 'attila');
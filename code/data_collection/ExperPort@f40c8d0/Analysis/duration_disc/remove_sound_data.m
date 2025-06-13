
function [] = remove_sound_data

global Solo_datadir;

pdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep];

ratlist = {'Jabber','Shadowfax','Aragorn','Eaglet','Watson','Grimesby','Lascar', 'Legolas','Gryphon','Blaze','Pips',...
    'Boromir','Treebeard','Celeborn'};
for r = 1:length(ratlist)
pratname = ratlist{r};
fprintf(1,'%s\n', pratname);
pindir = [pdir pratname filesep];
% u = dir([pindir 'data_*_' 'Shraddha' '_' pratname '*.mat']);
 u = dir([pindir 'data_*_' pratname '*.mat']);
   
      [filenames{1:length(u)}] = deal(u.name); 
      filenames = sort(filenames'); %#ok<UDIM> (can't use dimension argument with cell sort)
      for i=length(u):-1:1, %     search from the end back
          fprintf(1,'\t%s\n', u(i).name);
          
          load([pindir u(i).name]);
          saved.ChordSection_sound_data = [];
          saved.make_and_upload_state_matrix_badboy_sound = [];
          saved.make_and_upload_state_matrix_white_noise_sound = [];
          saved.ChordSection_error_sound = [];
          saved.make_and_upload_state_matrix_harsher_badboy_sound = [];
          
          outfile = [pindir u(i).name];
     %     fprintf(1,'Saving to: %s\n', outfile);
          save(outfile, 'saved','saved_autoset','saved_history','fig_position');
      end;
end;
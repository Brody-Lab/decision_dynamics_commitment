function [] = sandbox5()

global Solo_datadir;
p_datadir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep];
p_indate = '080930a';
p_ratname = 'S018';

p_ratrow = rat_task_table(p_ratname);
p_task =p_ratrow{1,2};

p_sfile = [ 'data_@' p_task '_Shraddha_' p_ratname '_' p_indate '.mat'];
load([p_datadir p_ratname filesep p_sfile]);

% 
% p_outfile = 'slimmer_A';
% save(p_outfile, 'saved_autoset','saved','saved_history','fig_position');

  saved.ChordSection_sound_data = [];
  saved.make_and_upload_state_matrix_white_noise_sound = [];
  saved.make_and_upload_state_matrix_badboy_sound = [];
  saved.make_and_upload_state_matrix_iti_badboy_sound = [];
  saved.make_and_upload_state_matrix_grace_drink_sound = [];
%   
  p_outfile = 'slimmer_B.mat';
 save(p_outfile, 'saved_autoset','saved','saved_history','fig_position');

%  p_outfile3 = 'slimmer_C.mat';
%  save(p_outfile3, 'saved_autoset','saved_history','fig_position');
% 
%  clear saved saved_autoset saved_history fig_position;
% 
% load(p_outfile);

2;

% % white noise test
% gclen = 2;
% srate = get_generic('sampling_rate');
% 
% gc = MakeWNRamp(gclen*1000, srate, 0.01, 0.3);
% 
% bb = Make_badboy_sound('generic', 0, 0, 'volume', 'LOUDEST'); 
% 
% 
% sound([gc [bb; bb]], srate);
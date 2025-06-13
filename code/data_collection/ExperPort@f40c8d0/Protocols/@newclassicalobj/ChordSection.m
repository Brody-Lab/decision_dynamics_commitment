function [x, y, chord_sound_len] = ChordSection(obj, action, x, y)
 
GetSoloFunctionArgs;
amp = 0.05;

switch action
 case 'init'    % ------------- CASE 'INIT' ------------
   % Save the figure and the position in the figure where we are
   % going to start adding GUI elements:
   SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);
   
   
   SoundManager(obj, 'init');
   SoundManager(obj, 'declare_new_sound', 'relevant_plus_chord');
   SoundManager(obj, 'declare_new_sound', 'twosec_white_noise');
   SoundManager(obj, 'declare_new_sound', 'blip');
   

   NumeditParam(obj, 'Light_Duration', 0, x, y, 'position', [x y 100 20], ...
     'labelfraction', 0.65, 'TooltipString', 'Duration of LED stimulus');
   NumeditParam(obj, 'Light_F1_SOA', 0.8, x, y, 'position', [x+100 y 100 20], ...
     'labelfraction', 0.65, 'TooltipString', 'Difference (in secs) b/w onset of light and onset of F1 sound'); next_row(y);
   ToggleParam(obj, 'Light_Polarity', 0, x, y, ...
     'OnString', 'Light turns ON for stim', 'OffString', 'Light turns OFF for stim'); next_row(y);
   SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', ...
     {'Light_Duration', 'Light_F1_SOA', 'Light_Polarity'});
   
   next_row(y, 0.5);
   NumeditParam(obj, 'Right_F1', 0, x, y, 'position', [x y 100 20], ...
     'labelfraction', 0.65, 'TooltipString', 'F1 for Right stim');
   NumeditParam(obj, 'Right_F2', 0.8, x, y, 'position', [x+100 y 100 20], ...
     'labelfraction', 0.65, 'TooltipString', 'F2 for Right stim'); next_row(y);
   NumeditParam(obj, 'Left_F1',  0, x, y, 'position', [x y 100 20], ...
     'labelfraction', 0.65, 'TooltipString', 'F1 for Left stim');
   NumeditParam(obj, 'Left_F2',  0.8, x, y, 'position', [x+100 y 100 20], ...
     'labelfraction', 0.65, 'TooltipString', 'F2 for Left stim'); next_row(y);
   
   next_row(y, 0.5);
   NumeditParam(obj, 'F1_Duration',  0, x, y, 'position', [x y 100 20], ...
     'labelfraction', 0.65, 'TooltipString', 'length (in secs) of F1');
   NumeditParam(obj, 'F1_volume_factor',  0.8, x, y, 'position', [x+100 y 100 20], ...
     'labelfraction', 0.65, 'TooltipString', 'multiplicative factor on amplitude of F1 (range [0, 1])'); next_row(y);

   NumeditParam(obj, 'F1_F2_Gap',   0,   x, y, 'TooltipString', 'pause (in ms) b/w F1 and F2'); next_row(y);
   NumeditParam(obj, 'Tau',         1,   x, y, 'TooltipString', ['Tau ' ...
                       'of F1 to F2 transition sigmoid, in ms']); 
   ToggleParam(obj, 'PokeElicitsSound', 0, x, y, ...
               'position', [x+160 y 20 20], 'OnString', '', 'OffString', ...
               '', 'TooltipString', sprintf(['\nIf this button is brown, ' ...
                       'sound follows light according to\nLight_F1_SOA; ' ...
                       'but if it is black, it is poking that\n' ...
                       'elicit the sound (and water follows). Light' ...
                       '_F1_SOA\nis then ignored.'])); next_row(y);
   SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', ...
                       'PokeElicitsSound');
   NumeditParam(obj, 'F2_Duration',  0, x, y, 'position', [x y 100 20], ...
     'labelfraction', 0.65, 'TooltipString', 'length (in secs) of F2');
   NumeditParam(obj, 'F2_volume_factor',  0.8, x, y, 'position', [x+100 y 100 20], ...
     'labelfraction', 0.65, 'TooltipString', 'multiplicative factor on amplitude of F2 (range [0, 1])'); next_row(y);
   
   next_row(y, 0.5);
   NumeditParam(obj, 'RelevantSPL', 60,  x, y); next_row(y);
   MenuParam(obj, 'RelevantLoc', {'localized', 'surround'}, 1, x, y); ...
     next_row(y); 
   MenuParam(obj, 'RelevantType', {'pure tones', 'bups'}, 1, x, y); ...
     next_row(y); 
   
   next_row(y,0.5);
   NumeditParam(obj, 'F2_Go_Gap',   0,   x, y, 'TooltipString', 'pause (in ms) b/w F2 and Go'); next_row(y);

   next_row(y, 0.5);
   NumeditParam(obj, 'NTones', 0, x, y, 'position', [x y 100 20], ...
     'labelfraction', 0.65, 'TooltipString', '# of tones on GO chord');
   NumeditParam(obj, 'BaseFreq', 0.8, x, y, 'position', [x+100 y 100 20], ...
     'labelfraction', 0.65, 'TooltipString', 'Freq of lowest tone in GO chord'); next_row(y);
   NumeditParam(obj, 'GOspl', 0, x, y, 'position', [x y 100 20], ...
     'labelfraction', 0.65, 'TooltipString', 'sound pressure level for GO chord');
   NumeditParam(obj, 'GOdur', 0.8, x, y, 'position', [x+100 y 100 20], ...
     'labelfraction', 0.65, 'TooltipString', 'Duration (in secs) of GO chord'); next_row(y);
   MenuParam(obj, 'GOLoc', {'localized', 'surround'}, 1, x, y); ...
     next_row(y); 
   SoloParamHandle(obj, 'chord_sound_len');
   
   next_row(y,0.5);

   SubheaderParam(obj, 'cd_sbh', 'Stimuli', x, y);next_row(y);
   
   feval(mfilename, obj, 'make');
   SoundManager(obj, 'send_not_yet_uploaded_sounds');
   
   
 case 'reinit',    % ------------- CASE 'REINIT' ------------
   currfig = gcf; 
   
   % Get the original GUI position and figure:
   x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
   
   % Delete all SoloParamHandles who belong to this object and whose
   % fullname starts with the name of this mfile:
   delete_sphandle('owner', ['^@' class(obj) '$'], ...
                   'fullname', ['^' mfilename]);
   
   % Reinitialise at the original GUI position and figure:
   [x, y] = feval(mfilename, obj, 'init', x, y);
   
   % Restore the current figure:
   figure(currfig);      

   
 case 'make'   % ------------- CASE 'MAKE' ------------
   srate = SoundManager(obj, 'get_sample_rate');
   ramp  = 3; 

   if side_list(n_done_trials+1)==1, F1=value(Left_F1);  F2=value(Left_F2); 
   else                              F1=value(Right_F1); F2=value(Right_F2);
   end;

   switch value(RelevantType)
    case 'pure tones',
      relevant = MakeSigmoidSwoop3(srate, 70-RelevantSPL, F1*1000, F2*1000,...
                               F1_Duration*1000, F2_Duration*1000, ...
                               F1_F2_Gap*1000, value(Tau), 3, ...
                               'F1_volume_factor',value(F1_volume_factor), ...
                               'F2_volume_factor',value(F2_volume_factor));
      
    case 'bups',
      relevant = MakeBupperSwoop(srate,   70-RelevantSPL, F1, F2,...
                               F1_Duration*1000, F2_Duration*1000, ...
                               F1_F2_Gap*1000, value(Tau), ...
                               'F1_volume_factor',value(F1_volume_factor), ...
                               'F2_volume_factor',value(F2_volume_factor));
   otherwise
      error('What kind of rtelevant tone???');
   end;
      
   rel_go_gap  = zeros(1, round(F2_Go_Gap*srate));
   go_chord    = MakeChord( srate, 70-GOspl, value(BaseFreq*1000), ...
                            value(NTones), GOdur*1000,3); 
   

   switch value(RelevantLoc),
    case 'surround',     relevant = [relevant' relevant'];   
    case 'localized', 
      if side_list(n_done_trials+1) == 1, relevant = [relevant' zeros(length(relevant),1)];
      else                                relevant = [zeros(length(relevant),1) relevant'];
      end;      
    otherwise, error('huh???');
   end;
   
   switch value(GOLoc),
    case 'surround',     go_chord = [go_chord'  go_chord'];
    case 'localized',
      if side_list(n_done_trials+1) == 1, go_chord = [go_chord'  zeros(length(go_chord),1)];
      else                                go_chord = [zeros(length(go_chord),1)  go_chord'];
      end;
    otherwise, error('huh??');
   end;

   rel_go_gap = [rel_go_gap' rel_go_gap'];
   
   SoundManager(obj, 'set_sound', 'relevant_plus_chord', amp*[relevant ; rel_go_gap ; go_chord]);
   SoundManager(obj, 'set_sound', 'blip', amp*0.0001*randn(round(0.01*srate),1)); %10 ms v soft blip -- hack to
                                        % stop sounds in upstairs RM1 rigs;
   SoundManager(obj, 'set_sound', 'twosec_white_noise', amp*0.12* (rand(round(srate*2),1)-0.5));

   chord_sound_len.value = SoundManager(obj, 'get_sound_duration', 'relevant_plus_chord');
      
      
 otherwise
   error('Unknown action!');
end;



return;

function [sounds] = MakeSounds
   
   AboDur   =GetParam(me,'AbortDur');
   ptlist   =GetParam(me,'PortList' );
   NT       =GetParam(me,'Trials') + 1;
   port     =ptlist(NT);

   NTones   =GetParam(me,'NTones');
   BaseFreq =GetParam(me,'BaseFreq') * 1000;
   SPL      =GetParam(me,'SoundSPL');
   GoDur    =GetParam(me,'GoDur');
   RampDur  =GetParam(me,'RampDur');

   Left_F1  = GetParam(me, 'Left_F1');
   Left_F2  = GetParam(me, 'Left_F2');
   Right_F1 = GetParam(me, 'Right_F1');
   Right_F2 = GetParam(me, 'Right_F2');

   F1_F2_Gap = GetParam(me, 'F1_F2_Gap');
   F1_F2_Dur = GetParam(me, 'F1_F2_Duration');
   F2_Go_Gap = GetParam(me, 'F2_Go_Gap');
   Go_Loc    = GetParam(me, 'Go_Loc');
   Relevant_Loc = GetParam(me, 'Relevant_Loc');
   RelevantSPL  = GetParam(me,'RelevantSPL');
   
   FullSoundDur = GetParam(me, 'FullSoundDur');
   
   global fake_rp_box;
   if fake_rp_box==2, srate = GetSampleRate(rpbox('getsoundmachine'));
   else               srate = 50e6/1024;
   end;
   sounds   = cell(3,1);

   if port==1, F1 = Left_F1;  F2 = Left_F2; 
   else        F1 = Right_F1; F2 = Right_F2; 
   end;
   relevant = MakeSigmoidSwoop2(srate, 70-RelevantSPL, F1*1000, F2*1000,...
                                F1_F2_Dur*1000, 1, F1_F2_Gap*1000, 3);
   gap      = zeros(1, round(F2_Go_Gap*srate));
   chord    = MakeChord( srate, 70-SPL, BaseFreq, NTones, GoDur*1000, 3); 
   

   if Relevant_Loc == 1, relevant = [relevant' relevant'];
   elseif port ==1,      relevant = [relevant' zeros(length(relevant),1)];
   else                  relevant = [zeros(length(relevant),1) relevant'];
   end;

   if Go_Loc == 1, chord = [chord'  chord'];
   elseif port==1, chord = [chord'  zeros(length(chord),1)];
   else            chord = [zeros(length(chord),1)  chord'];
   end;

   gap = [gap' gap'];
   
   sounds{1} = [relevant ; gap ; chord];

   
   %wn = 0.15*rand(1,GoDur*srate)-0.5;
   %sounds{1} = [wn; zeros(1,length(wn))];
   sounds{2} = zeros(floor(FullSoundDur*srate), 1);
   sounds{3} = 0.12* (rand(floor(AboDur*srate),1)-0.5);
   
   2;
   
   return;
   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%         SendSounds
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = SendSounds(sounds)
global fake_rp_box;
if fake_rp_box~=2,
    rpbox('LoadRP3StereoSound', sounds);
else
    LoadSound(rpbox('getsoundmachine'), 1, sounds{1}', 'both', 3, 0);
    LoadSound(rpbox('getsoundmachine'), 2, sounds{2}, 'both', 3, 0);
    LoadSound(rpbox('getsoundmachine'), 4, sounds{3}, 'both', 3, 0);
end;


   
   
      
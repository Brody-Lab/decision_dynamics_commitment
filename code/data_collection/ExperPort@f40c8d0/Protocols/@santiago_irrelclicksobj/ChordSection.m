function [x, y, chord_sound_len] = ChordSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
 case 'init'    % ------------- CASE 'INIT' ------------
   % Save the figure and the position in the figure where we are
   % going to start adding GUI elements:
   SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);
   
   
   rpbox('InitRP3StereoSound');
   NumeditParam(obj, 'NTones', 16, x, y); next_row(y);
   NumeditParam(obj, 'BaseFreq', 1, x, y); next_row(y);
   NumeditParam(obj, 'GOvolume', 0.01, x, y); next_row(y);
   NumeditParam(obj, 'GOdur', 0.1, x, y); next_row(y);
   MenuParam(obj, 'GOLoc', {'localized', 'surround'}, 1, x, y); ...
     next_row(y); 
   NumeditParam(obj, 'ClicksVolume', 0.005, x, y); next_row(y);
   SoloParamHandle(obj, 'chord_sound_len');
   
   if(~1)  %%% DELETE %%%
   next_row(y,0.5);
   NumeditParam(obj, 'Right_F1', 2, x, y); next_row(y);
   NumeditParam(obj, 'Right_F2', 4, x, y); next_row(y, 1.25);
   NumeditParam(obj, 'Left_F1',  4, x, y); next_row(y);
   NumeditParam(obj, 'Left_F2',  2, x, y); next_row(y, 1.25);
   
   NumeditParam(obj, 'F1_Duration', 0, x, y); next_row(y);
   NumeditParam(obj, 'F1_volume_factor', 1, x, y, 'TooltipString', ...
                'multiplicative factor on amplitude of F1. Max 1, Min 0'); ...
     next_row(y);
   NumeditParam(obj, 'F1_F2_Gap',   0,   x, y); next_row(y);
   NumeditParam(obj, 'Tau',         1,   x, y, 'TooltipString', ['Tau ' ...
                       'of F1 to F2 transition sigmoid, in ms']); next_row(y);
   NumeditParam(obj, 'F2_Duration', 0, x, y); next_row(y);
   NumeditParam(obj, 'F2_volume_factor', 1, x, y, 'TooltipString', ...
                'multiplicative factor on amplitude of F2. Max 1, Min 0'); ...
     next_row(y);
   NumeditParam(obj, 'F2_Go_Gap',   0,   x, y); next_row(y);
   NumeditParam(obj, 'RelevantSPL', 0,  x, y); next_row(y);
   MenuParam(obj, 'RelevantLoc', {'localized', 'surround'}, 1, x, y); ...
     next_row(y); 
   MenuParam(obj, 'RelevantType', {'pure tones', 'bups'}, 1, x, y); ...
     next_row(y); 
   end
   
   next_row(y,0.5);
   SubheaderParam(obj, 'cd_sbh', 'Sounds', x, y);next_row(y);
   
   SoloParamHandle(obj, 'sounds', 'value', cell(3,1));
   SoloParamHandle(obj, 'sounds_uploaded', 'value', 0);
   
   feval(mfilename, obj, 'make');
   feval(mfilename, obj, 'upload_sounds');
   
   
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
   srate = get_generic('sampling_rate');
   ramp  = 3; 

   if(~1)  %%% DELETE %%%
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
   end     %%% DELETE %%%

   % --- Define GO signal ---
%   go_chord    = MakeChord( srate, 70-GOspl, value(BaseFreq*1000), ...
%                            value(NTones), GOdur*1000,3); 
%   go_chord    = MakeChord( srate, 70-GOspl, value(BaseFreq*1000), value(NTones), GOdur*1000,10); 
%   go_chord = MakeClick('power',0.5);
    % Create a time vector.


% --- Create the chord ---
t=[0:(1/(srate)):value(GOdur)];
t=t(1:(end-1));
finterv = sqrt(sqrt(2)); %this stepping yields a diminished minor chord + 13
freq = value(BaseFreq)*1000;
snd = zeros(1,length(t));
for k=1:value(NTones)
    snd = snd + sin( 2*pi*freq.*t )/value(NTones);
    freq = freq * finterv;
end
go_chord = GOvolume*snd;


   if(~1)  %%% DELETE %%%
   switch value(RelevantLoc),
    case 'surround',     relevant = [relevant' relevant'];   
    case 'localized', 
      if side_list(n_done_trials+1) == 1, relevant = [relevant' zeros(length(relevant),1)];
      else                                relevant = [zeros(length(relevant),1) relevant'];
      end;      
    otherwise, error('huh???');
   end;
   end  %%% DELETE %%%
   
   
   switch value(GOLoc),
    case 'surround',     go_chord = [go_chord'  go_chord'];
    case 'localized',
      if side_list(n_done_trials+1) == 1, go_chord = [go_chord'  zeros(length(go_chord),1)];
      else                                go_chord = [zeros(length(go_chord),1)  go_chord'];
      end;
    otherwise, error('huh??');
   end;

   %%%rel_go_gap = [rel_go_gap' rel_go_gap'];
   
   %%%sounds{1} = [relevant ; rel_go_gap ; go_chord];
   sounds{1} = [go_chord];
   sounds{2} = 0.0001*randn(round(0.01*srate),1); %10 ms v soft blip -- hack to
                                        % stop sounds in upstairs RM1 rigs;
   sounds{3} = 0.12* (rand(round(srate*2),1)-0.5);

   
   % --- Make train of clicks ---
   NClicks = 10;
   TrainFreq = 5;                          % Clicks / sec
   ClickDuration = 0.005;                  % sec
   ClickWave = 2*rand(round(srate*ClickDuration),1) - 1;
   SilenceWave = zeros(round(srate/TrainFreq)-length(ClickWave),1);
   TrainOfClicks = repmat([SilenceWave(1:floor(end/2));ClickWave;SilenceWave(ceil(end/2):end)],NClicks,1);
   sounds{4} = value(ClicksVolume)*TrainOfClicks;
   
   chord_sound_len.value = rows(sounds{1})/srate;
   
   sounds_uploaded.value = 0;
   
   
 case 'upload_sounds'   % ------------- CASE 'UPLOAD_SOUNDS' ------------
   if sounds_uploaded==0,
      LoadSound(rpbox('getsoundmachine'), 1, sounds{1}', 'both', 3, 0);
      %LoadSound(rpbox('getsoundmachine'), 2, sounds{2}',  'both', 3, 0);
      %LoadSound(rpbox('getsoundmachine'), 4, sounds{3}', 'both', 3, 0);      
      LoadSound(rpbox('getsoundmachine'), 4, sounds{4}', 'both', 3, 0);      
      sounds_uploaded.value = 1;
   end;

   
 otherwise
   error('Unknown action!');
end;



return;

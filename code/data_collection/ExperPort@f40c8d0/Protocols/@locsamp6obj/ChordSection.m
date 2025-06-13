function  [x,  y,  chord_sound_len]  =  ChordSection(obj,   action, x,  y)

GetSoloFunctionArgs;
% SoloFunction('ChordSection', 'ro_args', {'side_list', 'n_done_trials'});
% Deals with chord generation and uploading for a protocol.
% Note: This function does not generate the sounds for white-noise (ITI,
% Timeout, etc.,) 
% init: Initialises UI parameters specifying types of sound; calls 'make' and 'upload'
% make: Generates chord for the upcoming trial
% upload: The chord is set to be sound type "1" in the RPBox


switch action,
 case 'init'
  fig = gcf; rpbox('InitRP3StereoSound'); figure(fig);
  
  oldx = x; oldy = y;  x = 5; y = 5;
  SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable', 0);
  
  EditParam(obj, 'SoundSPL',        60,    x, y);   next_row(y);
  EditParam(obj, 'SoundDur',        0.2,   x, y);   next_row(y);
  EditParam(obj, 'BaseFreq',        1,     x, y);   next_row(y);
  EditParam(obj, 'NTones',          16,    x, y);   next_row(y);
  EditParam(obj, 'RampDur',         0.005, x, y);   next_row(y, 1.5);
  EditParam(obj, 'ValidSoundTime',  0.03,  x, y);   next_row(y);
  set(value(myfig), ...
      'Visible', 'off', 'MenuBar', 'none', 'Name', 'Chord Parameters', ...
      'NumberTitle', 'off', 'CloseRequestFcn', ...
      ['ChordSection(' class(obj) '(''empty''), ''chord_param_hide'')']);
  set_size(value(myfig), [210 141]);
  x = oldx; y = oldy; figure(fig);
  MenuParam(obj, 'ChordParameters', {'hidden', 'view'}, 1, x, y); next_row(y);
  set_callback({ChordParameters}, {'ChordSection', 'chord_param_view'});
  
  SoloParamHandle(obj, 'chord_sound_data');
  SoloParamHandle(obj, 'chord_sound_len');
  SoloParamHandle(obj, 'chord_uploaded', 'value', 0);
  
  set_callback({SoundSPL, SoundDur, BaseFreq, NTones, RampDur, ...
                ValidSoundTime}, {'ChordSection', 'make'});
  
  ChordSection(obj, 'make');
  ChordSection(obj, 'upload');

 case 'make'                 % ----------- case MAKE ----------------
  chord = MakeChord(50e6/1024,  70-SoundSPL, ...
                    BaseFreq*1000, value(NTones), SoundDur*1000, RampDur*1000);
  if side_list(n_done_trials+1) == 0,
     chord_sound_data.value = [zeros(length(chord), 1), chord'];
  else
     chord_sound_data.value = [chord', zeros(length(chord), 1)];
  end;
  chord_sound_len.value = value(SoundDur);            
  chord_uploaded.value = 0;
  
 case 'upload'              % ---------- case UPLOAD ----------
  if value(chord_uploaded)==1, return; end;
  rpbox('loadrp3stereosound1', {value(chord_sound_data)});
  chord_uploaded.value = 1;
  
 
 case 'get_ValidSoundTime', % ----- case GET_VALIDSOUNDTIME
  x = value(ValidSoundTime);
  
  
 case 'delete'            , % ------------ case DELETE ----------
  delete(value(myfig));
  
  
 case 'chord_param_view',   % ------- case CHORD_PARAM_VIEW
  switch value(ChordParameters)
   case 'hidden',
    set(value(myfig), 'Visible', 'off');
    
   case 'view',
    set(value(myfig), 'Visible', 'on');
  end;

 case 'chord_param_hide',
  ChordParameters.value = 'hidden';
  set(value(myfig), 'Visible', 'off');
 
    
 otherwise
  error(['Don''t know how to handle action ' action]);
end;


return;
    

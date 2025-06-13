% [x, y] = SoundSection(obj, action, x, y)
%
% Section that takes care of defining and uploading sounds
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'      To initialise the section and set up the GUI
%                        for it
%
%            'reinit'    Delete all of this section's GUIs and data,
%                        and reinit, at the same position on the same
%                        figure as the original section GUI was placed.
%
%           'make_sounds'   Use the current GUI params to make the
%                        sounds. Does not upload sounds.
%
%           'upload_sounds' If new sounds have been made since last
%                        upload, uploads them to the sounds machine.
%
%           'get_tone_duration'  Returns length, in milliseconds, of
%                        the sounds the rat should discriminate
%
%           'get_sound_ids'      Returns a structure with two
%                        fieldnames, 'right' and 'left'; the values of
%                        these fieldnames will be the sound numbers of
%                        the tone loaded as the Right sound and of the
%                        tone loaded as the Left sound, respectively.
%           
% x, y     Relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI. 
%
% x        When action == 'get_tone_duration', x is length, in
%          milliseconds, of the sounds the rat should discriminate.
%
% x        When action == 'get_sound_ids', x is a structure with two
%          fieldnames, 'right' and 'left'; the values of these fieldnames
%          will be the sound numbers of the tone loaded as the Right sound
%          and of the tone loaded as the Left sound, respectively.
%           


function [x, y] = SoundSection(obj, action, x, y)
   
   GetSoloFunctionArgs;
   
   switch action
    case 'init',   % ---------- CASE INIT -------------
      
      % Save the figure and the position in the figure where we are
      % going to start adding GUI elements:
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);
      % Old call to initialise sound system:
      rpbox('InitRP3StereoSound');
      
      NumeditParam(obj, 'Rtone', 2, x, y, 'label', 'Rtone (kHz)', ...
                   'TooltipString', 'sound for correct right response');
      next_row(y);
      NumeditParam(obj, 'LVol_Rtone', 0, x, y, 'position', [x y 100 20], ...
                   'labelfraction', 0.65, 'TooltipString', ['Rtone''s ' ...
                          'volume on left speaker']);
      NumeditParam(obj, 'RVol_Rtone', 0.8, x, y, 'position', ...
                   [x+100 y 100 20], 'labelfraction', 0.65, ...
                   'TooltipString', 'Rtone''s volume on right speaker');
      next_row(y, 1.5);
      
      NumeditParam(obj, 'Ltone', 8, x, y, 'label', 'Ltone (kHz)', ...
                   'TooltipString', 'sound for correct left response');
      next_row(y);
      NumeditParam(obj, 'LVol_Ltone', 0.8, x, y, 'position', [x y 100 20], ...
                   'labelfraction', 0.65, ...
                   'TooltipString', 'Ltone''s volume on left speaker');
      NumeditParam(obj, 'RVol_Ltone', 0, x, y, 'position', ...
                   [x+100 y 100 20], 'labelfraction', 0.65, ...
                   'TooltipString', 'Ltone''s volume on right speaker');
      next_row(y, 1.5);
      
      NumeditParam(obj, 'ToneDuration', 500, x, y, 'label', ...
                   'ToneDuration (ms)');
      next_row(y, 1.5);
      
      SubheaderParam(obj, 'title', 'Sound Definition', x, y);
      next_row(y, 1.5);

      % Store sounds for loading during intertrial interval, not during
      % trial:
      SoloParamHandle(obj, 'left_sound');
      SoloParamHandle(obj, 'rght_sound');
      SoloParamHandle(obj, 'sound_uploaded', 'value', 0);
      
      set_callback({Rtone, LVol_Rtone, RVol_Rtone, Ltone, LVol_Ltone, ...
                    RVol_Ltone, ToneDuration}, {mfilename, 'make_sounds'});

      SoundSection(obj, 'make_sounds');
      SoundSection(obj, 'upload_sounds');

      % Sounds for Right will always be stored as sound #1, for Left as
      % #2:
      SoloParamHandle(obj, 'sound_ids', 'value',struct('right', 1, 'left', 2));



      
    case 'make_sounds',   % ---------- CASE MAKE_SOUNDS -------------
      global sound_sample_rate;
      t = 0:1./sound_sample_rate:ToneDuration/1000;
      left = sin(2*pi*Ltone*1000*t);
      rght = sin(2*pi*Rtone*1000*t);

      % We'll give it 10 ms cosyne rise and fall
      start = sin(2*pi*25*(0:1./sound_sample_rate:0.01));
      stop  = start(end:-1:1);
      
      left(1:length(start))        = left(1:length(start)).*start;
      left(end-length(stop)+1:end) = left(end-length(stop)+1:end).*stop;

      rght(1:length(start))        = rght(1:length(start)).*start;
      rght(end-length(stop)+1:end) = rght(end-length(stop)+1:end).*stop;

      % Now make it stereo:
      left_sound.value = [left'*LVol_Ltone left'*RVol_Ltone];
      rght_sound.value = [rght'*LVol_Rtone rght'*RVol_Rtone];
      
      % Mark the fact that the latest soudns haven't been uploaded yet
      sound_uploaded.value = 0;
      return;

      
    case 'upload_sounds',      % ---------- CASE UPLOAD_SOUNDS -------------
      if sound_uploaded==0,
         rpbox('loadrp3stereosound1', {value(rght_sound)});
         rpbox('loadrp3stereosound2', {[] ; value(left_sound)'});
         sound_uploaded.value = 1;
      end;
      return;

      
    case 'get_tone_duration',   % ---------- CASE GET_TONE_DURATION ----------
      x = value(ToneDuration);
      return;

      
    case 'get_sound_ids',       % ---------- CASE GET_SOUND_IDS ----------
      x = value(sound_ids);

      
      
      
    case 'reinit',       % ---------- CASE REINIT -------------
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
   end;
   
   
      
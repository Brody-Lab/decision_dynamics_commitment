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


      set_callback({Rtone, LVol_Rtone, RVol_Rtone, Ltone, LVol_Ltone, ...
        RVol_Ltone, ToneDuration}, {mfilename, 'make_sounds'});

      SoundManager(obj, 'declare_new_sound', 'right');
      SoundManager(obj, 'declare_new_sound', 'left');
                  
      SoundSection(obj, 'make_sounds');
      SoundManager(obj, 'send_not_yet_uploaded_sounds');
      


      
    case 'make_sounds',   % ---------- CASE MAKE_SOUNDS -------------
      sound_sample_rate = SoundManager(obj, 'get_sample_rate');

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
      SoundManager(obj, 'set_sound', 'left',  [left'*LVol_Ltone left'*RVol_Ltone]');
      SoundManager(obj, 'set_sound', 'right', [rght'*LVol_Rtone rght'*RVol_Rtone]');
            
      return;

      
      
    case 'get_tone_duration',   % ---------- CASE GET_TONE_DURATION ----------
      x = value(ToneDuration);
      return;

            
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
   
   
      
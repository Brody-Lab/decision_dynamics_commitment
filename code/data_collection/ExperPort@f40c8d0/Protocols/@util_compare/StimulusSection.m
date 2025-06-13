% Typical section code-- this file may be used as a template to be added 
% on to. The code below stores the current figure and initial position when
% the action is 'init'; and, upon 'reinit', deletes all SoloParamHandles 
% belonging to this section, then calls 'init' at the proper GUI position 
% again.


% [x, y] = YOUR_SECTION_NAME(obj, action, x, y)
%
% Section that takes care of YOUR HELP DESCRIPTION
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
% x, y     Relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI. 
%

function [x, y] = StimulusSection(obj, action, x, y)
   
GetSoloFunctionArgs;
amp = 0.05;

% note: rat hearing: 200Hz -- 80/90kHz (Fay 1988, Kelly and Masterson 1977,
% Warfield 1973); human hearing to 20kHz

MIN_PITCH = 1000;
MAX_PITCH = 20000;

% too many sounds -- max 32 in sound emulator
% PITCH_RATIO = 6/5; % minor 3rd
PITCH_RATIO = 5/4; % perfect 4th; gives 13 different pitches, x2 for 2 sides

tone_freq = log(MIN_PITCH):log(PITCH_RATIO):log(MAX_PITCH); % pitch stimulus
tone_freq = exp(tone_freq);
tone_freqs = length(tone_freq);

MIN_BUP_RATE = 3;
MAX_BUP_RATE = 60;

BUP_RATIO = 5/4;

std_duration = 10; % seconds? maximum duration (I think), can otherwise
                   % actively turn off a sound

% more parameters
std_freq = 25; % temporary
tone_volume_factor = 3;
bups_volume_factor = 2;
badboy_volume_factor = 2;

bup_freq = log(MIN_BUP_RATE):log(BUP_RATIO):log(MAX_BUP_RATE); % bup stimulus
bup_freq = exp(bup_freq);
bup_freqs = length(bup_freq);

SoloParamHandle(obj, 'num_stims', 'value', 10); % max 10 per stim type
SoloParamHandle(obj, 'stim_probs', 'value', [0.1:0.1:1]); %%%%% make gui
SoloFunctionAddVars('SidesSection', 'ro_args', {'num_stims', 'stim_probs'});

% one entry per stimulus, symmetric left/right

switch action
 case 'init',
  % Save the figure and the position in the figure where we are going to start
  % adding GUI elements:
  SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);
  
  % Number of center pokes -- omit?
  %  MenuParam(obj, 'n_center_pokes', {'0', '1', '2'}, 1, x, y, 'TooltipString', ...
  %            'Number of center pokes');
  %  set_callback(n_center_pokes, {mfilename, 'n_center_pokes'});
  
  

  % sound types
  next_row(y, 1.5);
  MenuParam(obj, 'left_soundtype', {'bups', 'tones'}, 'bups', x, y, ...
            'TooltipString', 'left stimulus sound type');
  next_row(y, 1.5);
  MenuParam(obj, 'right_soundtype', {'bups', 'tones'}, 'tones', x, y, ...
            'TooltipString', 'right stimulus sound type');
  next_row(y, 1.5);
  
  % set_callback('right_soundtype', {mfilename, 'right_soundtype'});
  %%% skipped buttons section...

  % now generate sounds
  % sound range
  % added without callbacks, etc.d

  % left sounds first
  if strcmp(left_soundtype, 'bups')
    for ss = 1:value(num_stims)
      sound_id_left = ['left_sound' int2str(ss)]; % this appears ok
      SoundManagerSection(obj, 'declare_new_sound', sound_id_left);
      sound = make_sound(obj, value(left_soundtype), std_duration, ...
                         bup_freq(ss), 60, 1);
      sound_on_left = [sound(:)'; zeros(1, length(sound))];
      SoundManagerSection(obj, 'set_sound', sound_id_left, amp* ...
                          sound_on_left*bups_volume_factor);
    end
  else
    for ss = 1:value(num_stims)
      sound_id_left = ['left_sound' int2str(ss)]; % this appears ok
      SoundManagerSection(obj, 'declare_new_sound', sound_id_left);
      sound = make_sound(obj, value(left_soundtype), std_duration, ...
                         tone_freq(ss), 60, 1);
      sound_on_left = [sound(:)'; zeros(1, length(sound))];
      SoundManagerSection(obj, 'set_sound', sound_id_left, amp* ...
                          sound_on_left*tone_volume_factor);
    end
  end

  % then right
  if strcmp(right_soundtype, 'bups')
    for ss = 1:value(num_stims)
      sound_id_right = ['right_sound' int2str(ss)]; % this appears ok
                                                  % (left_sound1 resolution error)
      SoundManagerSection(obj, 'declare_new_sound', sound_id_right);
      sound = make_sound(obj, value(right_soundtype), std_duration, ...
                         bup_freq(ss), 60, 1);
      sound_on_right = [zeros(1, length(sound)); sound(:)'];
      SoundManagerSection(obj, 'set_sound', sound_id_right, amp* ...
                          sound_on_right*bups_volume_factor);
    end
  else
    for ss = 1:value(num_stims)
      sound_id_right = ['right_sound' int2str(ss)]; % this appears ok
                                                  % (right_sound1 resolution error)
      SoundManagerSection(obj, 'declare_new_sound', sound_id_right);
      sound = make_sound(obj, value(right_soundtype), std_duration, ...
                         tone_freq(ss), 60, 1);
      sound_on_right = [zeros(1, length(sound)); sound(:)'];
      SoundManagerSection(obj, 'set_sound', sound_id_right, amp* ...
                          sound_on_right*tone_volume_factor);
    end
  end

  % go sound?
  % reward sound? or just the left/right sounds?
  % bridge sound?
  
  % error sound (white noise)
  
  sound_id = ['badboy_both'];
  SoundManagerSection(obj, 'declare_new_sound', sound_id);
  sound = make_sound(obj, 'badboy', std_duration, std_freq, 60, 1);
  sound_on_both = [sound(:)'; sound(:)'];
  
  SoundManagerSection(obj, 'set_sound', sound_id, amp* sound_on_right* ...
                      badboy_volume_factor);

  % feval(mfilename, obj, 'make_all_sounds'); % include this later, perhaps
  SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
  
 case 'reinit',
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

function [sound] = make_sound(obj, soundtype, duration, frequency, spl, volume_factor)
  srate = SoundManagerSection(obj, 'get_sample_rate');
  switch soundtype,
   case 'tones',
%    sound = MakeSigmoidSwoop3(srate, 70-spl, frequency*1000, frequency*1000, ...
    sound = MakeSigmoidSwoop3(srate, 70-spl, frequency, frequency, ...
                              duration*1000, 0, 0, 0.1, 3, 'F1_volume_factor', ...
                              volume_factor);
    
   case 'bups',
    sound = MakeBupperSwoop(srate, 70-spl, frequency, frequency, duration*1000, ...
                            0, 0, 0.1, 'F1_volume_factor', volume_factor);
    
   case 'badboy', % hack; fill in other variables with random stuff
    sound = Make_badboy_sound(2, 0.5, 5);
    
   otherwise
    error('which sound type??');
  end
  
  return
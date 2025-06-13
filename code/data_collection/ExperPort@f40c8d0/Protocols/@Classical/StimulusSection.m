% Typical section code-- this file may be used as a template to be added 
% on to. The code below stores the current figure and initial position when
% the action is 'init'; and, upon 'reinit', deletes all SoloParamHandles 
% belonging to this section, then calls 'init' at the proper GUI position 
% again.
%
%
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
%            'get_stimulus'   Returns a structure with fields 'type',
%                       'duration', and 'loc', with the contents
%                        of 'type' being either 'lights' or 'sounds' and
%                        the contents of 'duration' the  maximum duration,
%                        in secs, of the stimulus, and 'loc' being one of
%                        'surround', 'pro-loc', or 'anti-loc'. If the type
%                        is 'sounds', the structure will also have a field
%                        'id', with contents the integer sound_id for
%                        playing the sound.
%
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
%
% x        When action == 'get_current_side', returns either the string 'l'
%          or the string 'r', for Left and Right, respectively.
%


function [x, y] = StimulusSection(obj, action, x, y)
   
GetSoloFunctionArgs(obj);

switch action
  case 'init',
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);
    
    % 

    MenuParam(obj, 'StimulusType', {'lights', 'sounds'}, 'lights', x, y, ...
      'TooltipString', sprintf('\nSelect type of CS')); next_row(y);
    MenuParam(obj, 'StimulusLoc', {'surround', 'pro-loc', 'anti-loc'}, 'pro-loc', x, y, ...
      'TooltipString', sprintf(['\npro-loc means same side as reward; anti-loc means opposite side\n', ...
      'as reward; surround means both speakers for sound, all three ports for lights'])); next_row(y);
    
    set_callback(StimulusType, {mfilename, 'StimulusType'});
    
    
    next_row(y, 0.5);
    current_y = y;
    
    % ----  CONTROLS FOR STIM = LIGHTS
    
    y = current_y;
    
    NumeditParam(obj, 'Light_Duration', 6, x, y); next_row(y);
    SoloParamHandle(obj, 'all_light_params', 'value', {Light_Duration}, 'saveable', 0);

    
    % ---- CONTROLS FOR STIM = SOUND
    %y = current_y;
    DispParam(obj, 'ThisSound', 0, x, y, ...
        'TooltipString', sprintf('Sdound played in this trial'));
    next_row(y);
    SoloParamHandle(obj, 'all_sound_params', 'value', {ThisSound}, 'saveable', 0);
    [x, y] = SoundTableSection(obj, 'init', x, y);
    next_row(y, 0.5);
    
    % ------- The post-answer controls
	
	NumeditParam(obj, 'Reward_Delay', 0, x, y, ...
		'TooltipString', sprintf(['\n' ...
		'This delay only operates in the "on correctly timed poke" mode. \n' ...
		'If >0, this is the time (in sec) after the correct poke that \n' ...
		'the water reward is actually delivered'])); next_row(y);
    ToggleParam(obj, 'PostAnswerLightSwitch', 0, x, y, ...
		'OnString', 'Post Answer Light ON', ...
		'OffString', 'Post Answer Light OFF', ...
		'TooltipString', sprintf(['\n' ...
		'This control only operates in the "on correctly timed poke" mode. \n' ...
		'If ON, poking in the correct poke causes the light in that poke to turn on \n' ...
		'and the water is only delivered at the offset of the light \n' ...
		'If OFF, there is no extra light and delay in reward'])); next_row(y);
    ToggleParam(obj, 'PostAnswerSoundSwitch', 0, x, y, 'OnString', 'Post Answer Sound ON', ...
      'OffString', 'Post Answer Sound OFF', 'TooltipString', sprintf(['\n' ...
      'This control only operates in the "on correctly timed poke" mode.\n' ...
      'If ON, poking in the correct poke produces a sound, and only after that sound''s\n' ...
      'duration is over does the water get delivered. If OFF, no such delay or sound\n' ...
      'occurs. If not in "corectly timed poke" mode, this control has no effect and no\n' ...
      'extra sound is played.'])); next_row(y);
    ToggleParam(obj, 'PASfig_show_hide', 0, x, y, 'OffString', 'PostAnswerSound Hidden', ...
      'OnString', 'PostAnswerSound showing', 'TooltipString', sprintf(['\n' ...
      'Show or Hide the window with controls for the PostAnswerSound'])); next_row(y);
    NumeditParam(obj, 'PostAnswerSoundDelay', 0, x, y, 'labelfraction', 0.65, ...
		'TooltipString', sprintf(['\n' ...
		'Delay in secs before the PostAnswerSound comes on.\n' ...
		'Only relevant if PostAnswerSound is ON'])); next_row(y);

    set_callback(PASfig_show_hide,      {mfilename, 'PASfig_show_hide'}); %#ok<NODEF>
    set_callback(PostAnswerSoundSwitch, {mfilename, 'PostAnswerSoundSwitch'}); 
    
    currfig = gcf; currx = x; curry = y;
       SoloParamHandle(obj, 'PASfig', 'saveable', 0, 'value', figure('Position', [ 268   269   222   159]));
    
       set(value(PASfig), 'MenuBar', 'none', 'NumberTitle', 'on', ...
         'Name', 'Post Answer Sound Controls', ...
         'UserData', obj, ...
         'CloseRequestFcn', [mfilename '(' class(obj) ', ''PASfig_hide'')']);

       SoundInterface(obj, 'add', 'PASound', 10,  10);
       SoundInterface(obj, 'set', 'PASound', 'Vol',   0.008, 'Dur1',  1, 'Loop',  0, 'Freq1', 4000, 'Style', 'Tone');
       SoundInterface(obj, 'disable', 'PASound', 'Loop');

       set(value(PASfig), 'Visible', 'off');
       next_row(y, 0.5);
    figure(currfig); x = currx; y = curry;
    
    % -------
    
    SubheaderParam(obj, 'title', 'Stimulus Section', x, y);
    next_row(y, 2);
    feval(mfilename, obj, 'StimulusType');

    SoloFunctionAddVars(obj, 'SMASection', 'ro_args', ...
		{'PostAnswerSoundSwitch'; 'PostAnswerLightSwitch'; 'PostAnswerSoundDelay' ; 'Reward_Delay'});
    
    
    
    %%  PAS_enable
  case 'PAS_enable'
    set([get_ghandle(PASfig_show_hide) ; get_ghandle(PostAnswerSoundSwitch); ...
		get_ghandle(PostAnswerLightSwitch)  ; get_ghandle(Reward_Delay) ; ...
        get_ghandle(PostAnswerSoundDelay)], 'Enable', 'on'); %#ok<NODEF>    
    
    
    %%  PAS_disable
  case 'PAS_disable'
    feval(mfilename, obj, 'PASfig_hide');
    set([get_ghandle(PASfig_show_hide) ; get_ghandle(PostAnswerSoundSwitch); ...
		get_ghandle(PostAnswerLightSwitch)  ; get_ghandle(Reward_Delay) ; ...
        get_ghandle(PostAnswerSoundDelay)], 'Enable', 'off'); %#ok<NODEF>
    
    
    %%  PASfig_show_hide
  case 'PASfig_show_hide'

    if PASfig_show_hide == 1, set(value(PASfig), 'Visible', 'on'); %#ok<NODEF>
    else                      set(value(PASfig), 'Visible', 'off');
    end;

    
    %%  PASfig_hide
  case 'PASfig_hide'

    PASfig_show_hide.value = 0;
    set(value(PASfig), 'Visible', 'off');
    
    
    %%  PostAnswerSoundSwitch
  case 'PostAnswerSoundSwitch'

    if PostAnswerSoundSwitch == 1, enable(PostAnswerSoundDelay);  %#ok<NODEF>
    else                           disable(PostAnswerSoundDelay); %#ok<NODEF>
    end;
    
    %% get_stimulus
    % ---------------------------------------------------------------------
    % 
    %   CASE GET_STIMULUS 
    % 
    % ---------------------------------------------------------------------

  case 'get_stimulus', 
    switch value(StimulusType),
      case 'lights',
        x = struct('type', 'lights', 'duration', value(Light_Duration), 'loc', value(StimulusLoc));

      case 'sounds',
        side = x;
        if ThisSound == 0,
            x = struct('type', 'sounds', ...
                'duration', 0.01, 'id', 0, 'loc', value(StimulusLoc));
        else,
            sound_stimulus = sprintf('Sound%d', value(ThisSound));
            x = struct('type', 'sounds', ... 
                'duration', SoundManagerSection(obj, 'get_sound_duration', sound_stimulus), ...
                'id', SoundManagerSection(obj, 'get_sound_id', sound_stimulus), 'loc', value(StimulusLoc));
        end;
      otherwise,
        error('Don''t know this stim type! "%s"\n', value(StimulusType));
        
    end;

 %% get_last_stimulus_loc   
    % ---------------------------------------------------------------------
    % 
    %   CASE GET_LAST_STIMULUS_LOC 
    % 
    % ---------------------------------------------------------------------

  case 'get_last_stimulus_loc',
    x = get_history(StimulusLoc);
    if ~isempty(x), x = x{end}; end;
    
    % ---------------------------------------------------------------------
    % 
    %   CASES LEFT_TRIAL   RIGHT_TRIAL
    % 
    % ---------------------------------------------------------------------
  
  case {'left_trial', 'right_trial'}
    if strcmp(value(StimulusType), 'sounds'),
      if strcmp(action, 'left_trial'), side = 'l';
      else                             side = 'r';
      end;
      ThisSound.value = SoundTableSection(obj, 'next_trial_sound', side);
      
      if ThisSound == 0,
          1;
      elseif strcmp(StimulusLoc, 'surround'),
        % remake the sound to make sure it's in stereo
        SoundTableSection(obj, 'make_sounds', value(ThisSound));
        
      elseif (strcmp(action, 'left_trial')  && strcmp(StimulusLoc, 'pro-loc' ))  ||  ...
             (strcmp(action, 'right_trial') && strcmp(StimulusLoc, 'anti-loc')),
           SoundTableSection(obj, 'make_sounds', value(ThisSound));
           snd = SoundManagerSection(obj, 'get_sound', sprintf('Sound%d', value(ThisSound)));
           newsnd = [snd(1,:); zeros(1, cols(snd))];
           SoundManagerSection(obj, 'set_sound', sprintf('Sound%d', value(ThisSound)), newsnd);

      elseif (strcmp(action, 'left_trial')  && strcmp(StimulusLoc, 'anti-loc'))  ||  ...
             (strcmp(action, 'right_trial') && strcmp(StimulusLoc, 'pro-loc')),
           SoundTableSection(obj, 'make_sounds', value(ThisSound));
           snd = SoundManagerSection(obj, 'get_sound', sprintf('Sound%d', value(ThisSound)));
           newsnd = [zeros(1, cols(snd)); snd(1,:)];
           SoundManagerSection(obj, 'set_sound', sprintf('Sound%d', value(ThisSound)), newsnd);
      end;
    end;
    
    
    % ---------------------------------------------------------------------
    % 
    %   CASE STIMULUSTYPE 
    % 
    % ---------------------------------------------------------------------
  
  case 'StimulusType',
    switch value(StimulusType),
      case 'lights', 
        make_visible(value(all_light_params)); make_invisible(value(all_sound_params));
        
      case {'sounds'},
        make_invisible(value(all_light_params)); make_visible(value(all_sound_params));
    end;

    % ---------------------------------------------------------------------
    % 
    %   CASE CLOSE 
    % 
    % ---------------------------------------------------------------------
  
  case 'close',
    SoundTableSection(obj, 'close');
    SoundInterface(obj, 'close', 'PASound');
    delete(value(PASfig));
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);
    
    % ---------------------------------------------------------------------
    % 
    %   CASE REINIT
    % 
    % ---------------------------------------------------------------------
    
    
  case 'reinit',
    currfig = gcf;

    % Get the original GUI position and figure:
    x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    SoundTableSection(obj, 'close');
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);
    

    % Reinitialise at the original GUI position and figure:
    [x, y] = feval(mfilename, obj, 'init', x, y);

    % Restore the current figure:
    figure(currfig);
end;



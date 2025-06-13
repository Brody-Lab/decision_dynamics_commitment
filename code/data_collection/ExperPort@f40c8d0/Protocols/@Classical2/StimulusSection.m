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
        'TooltipString', sprintf('Sound played in this trial'));
    next_row(y);
    SoloParamHandle(obj, 'all_sound_params', 'value', {ThisSound}, 'saveable', 0);
    [x, y] = PBupsSection(obj, 'init', x, y);
    next_row(y, 0.5);
    
    % -------
    
    SubheaderParam(obj, 'title', 'Stimulus Section', x, y);
    next_row(y, 2);
    feval(mfilename, obj, 'StimulusType');
    
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
        if ThisSound == 0, %#ok<NODEF>
            x = struct('type', 'sounds', ...
                'duration', 0.01, 'id', 0, 'loc', value(StimulusLoc));
        else
            sound_stimulus = 'PBupsSound';
            x = struct('type', 'sounds', ... 
                'duration', SoundManagerSection(obj, 'get_sound_duration', sound_stimulus), ...
                'id', SoundManagerSection(obj, 'get_sound_id', sound_stimulus), 'loc', value(StimulusLoc));
        end;
      otherwise,
        error('Don''t know this stim type! "%s"\n', value(StimulusType));
        
    end;

    
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
      [this_sound] = PBupsSection(obj, 'next_trial', side);
      ThisSound.value = this_sound;
      snd = SoundManagerSection(obj, 'get_sound', 'PBupsSound');
      
      if ThisSound == 0,
          1;
      elseif (strcmp(action, 'left_trial')  && strcmp(StimulusLoc, 'pro-loc' ))  ||  ...
             (strcmp(action, 'right_trial') && strcmp(StimulusLoc, 'anti-loc')),
           newsnd = [snd(1,:); zeros(1, cols(snd))];
           SoundManagerSection(obj, 'set_sound', 'PBupsSound', newsnd);

      elseif (strcmp(action, 'left_trial')  && strcmp(StimulusLoc, 'anti-loc'))  ||  ...
             (strcmp(action, 'right_trial') && strcmp(StimulusLoc, 'pro-loc')),
           newsnd = [zeros(1, cols(snd)); snd(2,:)];
           SoundManagerSection(obj, 'set_sound', 'PBupsSound', newsnd);
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
    PBupsSection(obj, 'close');
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
    feval(mfilename, obj, 'close')
    

    % Reinitialise at the original GUI position and figure:
    [x, y] = feval(mfilename, obj, 'init', x, y);

    % Restore the current figure:
    figure(currfig);
end;



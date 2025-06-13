% [x, y] = PunishInterface(obj, action, punish_name, x, y)
%
% Puts up a GUI for making a set of states for making a punishment sound.
% The GUI lets you define various aspects of this punishment, and then you
% can make a simple call to add the punishment section to a
% @StateMachineAssembler you are constructing.
%
% QUICKSTART USAGE:
% -----------------
%
% To create a punishment GUI, call
%
%   [x, y] = PunishInterface(obj, 'add', punish_name, x, y)
%
% where punish_name is a string that will identify this punishment section,
% and x and y are the pixel position in the current figure on which a
% the GUI for this punishment section appears. By using different
% punish_name strings, you can have separate, different punishment
% sections.
%
% Then, to use the punishment section, when constructing your StateMachine
% Assembler, call
%
%   sma = PunishInterface(obj, 'add_sma_states', punish_name, sma, ...
%        'exitstate', exit_state_name);
%
% where sma is a @StateMachineAssembler object, punish_name is the string
% identifying this punishment section, and exit_state_name is a string
% identifying the state to jump to after the punishment is over. The call
% above will add the necessary states to implement the punishment. To start
% the punishment, have the state machine jump to the state named
% punish_name. All of these states that form part of this punishment will
% be associated with the name punish_name.
%
%
% PUNISHMENT CHARACTERISTICS:
% ---------------------------
%
% The "punishment" is defined by an initial sound ("init sound," typically
% very loud and not very long, say 0.5 s or 1 s, used to indicate to the
% animal that it's done something wrong), followed by another sound
% ("ongoing" sound) that loops for a longish time (e.g., 5 s). At the end
% of that longish sound, a jump to exit_state_name is made. 
%    You can use the Reinit button on the GUI to set the punishment so that
% if the animal pokes in any poke, the initial sound plays again, and the
% punishment reinits. Using ReinitGrace, you can also set it so that poking
% again immediately after a reinit doesn't reinit yet again. You can also
% set a "ReinitPenalty", an extra time that the ongoing sound plays if the
% animal poked during the punishment. Finally, you can use the Reinit
% button to set the punishment so that poking doesn't reinit, the
% punishment runs for as long as you indicate regardless of what the animal
% does.
% 
% The "init" sound and the "ongoing" sound are defined using @soundui; a
% figure with their GUI parameters is created. NOTE that how long the
% ongoing sound lasts depends on "Duration" in the punishment GUI, since
% the ongoing sound is forcibly set to loop. The duration in the @soundui
% GUI for this sound defines only how long one of the loop cycles lasts. 
%
%
%
% PARAMETERS:
% -----------
%
% The first parameter, action, should be one of:
%
%  'add'     Make a GUI for a new punsihment. This action requires three
%            more PARAMETERS:
%
%              punish_name    A string defining the name of the punishment
%            
%              x, y            x and y position, in pixels from bottom
%                              left of current figure, at which to start
%                              putting in the GUI elements.
%         
%            This action, 'add', also takes a number of OPTIONAL PARAMETERS:
%
%              'new_sounds'    By default 0. If 1, a GUI for the punishment
%                         sounds is not created; instead, two text entry
%                         fields are made. It is then your responsibility
%                         to type in the name of two sounds (names as known
%                         to @soundmanager) that can serve as InitSound and
%                         OngoingSound. NOTE that InitSound *must not
%                         Loop*; and that OngoingSound *must* Loop.
%              'TooltipString'   Default is ''; Tooltip string for title of
%                         GUI.
%
%            This action, 'add', RETURNS:  x, y  next open position on
%                         current figure.
%
% 'set' punish_name 'Duration'|'Reinit'|'ReinitGrace'|'ReinitPenalty'  value
%        
%               The 'set' action allows setting the parameters for any of
%               the punishments that have been created. The next argument
%               after 'set' must be a string, the name of the punishment
%               that was created with 'add'; the next argument must also be
%               a string, as listed above; and the last argument should be
%               the value the corresponding setting will be changed to.
%               Example calls:
%                     PunishInterface(obj, 'set', 'mypunish', 'Duration', 5);
%                 or
%                     DistribInterface(obj, 'set', 'mypunish', 'Reinit',   0);
%
%
% 'get' punish_name 'Duration'|'Reinit'|'ReinitGrace'|'ReinitPenalty'  
%
%               The 'get' action returns the setting of the parameters for any of
%               the punishments that have been created. The next argument
%               after 'get' must be a string, the name of the punishment
%               that was created with 'add'; the next argument must also be
%               a string, as listed above.
%               Example call:
%                     myvarstyle = PunishInterface(obj, 'get', 'mypun', 'Duration')
%
%
% 'disable punish_name   Disable all the GUI graphic elements for this punishment
%
% 'enable' punish_name   Enable all the GUI graphic elements for this punishment
%


% Written by Carlos Brody Aug 2007


function [varargout] = PunishInterface(obj, action, pname, x,y , varargin)

GetSoloFunctionArgs(obj, 'name',pname);
% adding the 'name', pname option above means that only the SPHs that
% match the name of this punishui will get instantiated.

switch action,


%% add  
    % ------------------------------------------------------------------------
    %
    %   CASE ADD
    %
    % ------------------------------------------------------------------------

  
  case 'add'  
    if nargin < 5, error('Action ''add'' also requires pname, x, y, as parameters'); end;
    pairs = { ...
      'new_sounds'   1   ; ...
      'TooltipString' '' ; ...
      'exitstate_gui' 0 ; ...
    }; parseargs(varargin, pairs);
    
    if new_sounds==1,
      ToggleParam(obj, [pname '_SoundsPanel'], 1, x, y, 'OnString', [pname ' snds show'], 'OffString', [pname ' snds hide'], 'position', [x+120 y 80 20]);
      set_callback(eval([pname '_SoundsPanel']), {mfilename, 'SoundsPanel', pname});
    
      oldx = x; oldy = y; oldfigure = double(gcf);
      SoloParamHandle(obj, [pname '_SoundsPanelFigure'], 'saveable', 0, 'value', double(figure('Position', [100 100 430 156])));
      sfig = value(eval([pname '_SoundsPanelFigure']));
      set(sfig, 'MenuBar', 'none', 'NumberTitle', 'off', ...
        'Name', sprintf('Sounds for "%s" punishment', pname), ...
        'UserData', obj, ...
        'CloseRequestFcn', ['PunishInterface(punishui, ''closeSoundsPanel'', ''' pname ''')']);

    
      SoundInterface(obj, 'add', [pname '_InitSnd'],     10,  10);
      SoundInterface(obj, 'set', [pname '_InitSnd'], ...
        'Style', 'WhiteNoise', 'Vol', 0.01,  'Dur1', 0.3, 'Loop', 0);
      SoundInterface(obj, 'disable', [pname '_InitSnd'], 'Loop'); % prevent user from accidentally changing this!

      SoundInterface(obj, 'add', [pname '_OngoingSnd'],      215, 10);
      SoundInterface(obj, 'set', [pname '_OngoingSnd'], ...
        'Style', 'WhiteNoise', 'Vol', 0.003, 'Dur1', 1,  'Loop', 1);
      SoundInterface(obj, 'disable', [pname '_OngoingSnd'], 'Loop'); % prevent user from accidentally changing this!

      
      
      x = oldx; y = oldy; figure(oldfigure);
    else
      EditParam(obj, [pname '_InitSnd'],     '', x, y, 'label', 'InitSnd',         'labelfraction', 0.45, 'TooltipString', 'name of loud punishment init sound'); next_row(y);
      EditParam(obj, [pname '_OngoingSnd'],  '', x, y, 'label', 'OngoingSnd',      'labelfraction', 0.45, 'TooltipString', 'name of softer ongoing punish sound'); next_row(y);      
    end;
    NumeditParam(obj, [pname '_Duration'],      5, x, y, 'label', 'Duration',      'labelfraction', 0.7, 'TooltipString', sprintf('\nTotal duration of penalty state, in secs'), 'position', [x y 120 20]); next_row(y);
    ToggleParam(obj,  [pname '_Reinit'],        1, x, y, 'OnString', 'R', 'OffString', '', 'TooltipString', sprintf('\nIf brown, don''t reinit on poke; If black, reinit on poke'), 'position', [x y+2 16 16]); 
    NumeditParam(obj, [pname '_ReinitGrace'],   1, x, y, 'label', 'ReinitGrace',   'labelfraction', 0.7, 'TooltipString', sprintf('\nSeconds after punishment init during which poking incurs no extra penalty\nMUST always be equal or greater than InitSound''s duration'), 'position', [x+17 y 90 20]); 
    NumeditParam(obj, [pname '_ReinitPenalty'], 0, x, y, 'label', 'ReinitPenalty', 'labelfraction', 0.7, 'TooltipString', sprintf('\nExtra seconds of ongoing sound punishment if reinit'), 'position', [x+107 y 90 20]); next_row(y);
    if exitstate_gui,
      EditParam(obj,    [pname, '_ExitState'], '', x, y,   'label', 'ExitState',      'labelfraction', 0.45, 'TooltipString', sprintf('\nName of state to go to when punishment is over')); next_row(y);
    else
      SoloParamHandle(obj, [pname '_ExitState'], 'value', '');
    end;
    SubheaderParam(obj, [pname '_Title'], ['Punish: ' pname], x, y, 'TooltipString', TooltipString); next_row(y);
    
    set_callback(eval([pname '_Reinit']), {mfilename, 'Reinit', pname});
    set_callback(eval([pname '_ReinitGrace']), {mfilename, 'ReinitGrace', pname});
    
    varargout{1} = x;
    varargout{2} = y;

%% Reinit
    % ------------------------------------------------------------------------
    %
    %   CASE REINIT
    %
    % ------------------------------------------------------------------------

  case 'Reinit',
    Reinit = eval([pname '_Reinit']);

    if Reinit == 1, 
      enable(eval([pname  '_ReinitGrace'])); 
      enable(eval([pname  '_ReinitPenalty']));
      
      ReinitGrace = eval([pname '_ReinitGrace']);
      InitDur     = SoundInterface(obj, 'get', [pname '_InitSnd'], 'Dur1');
      if ReinitGrace < InitDur
        ReinitGrace.value = InitDur;
      end;
    else
      disable(eval([pname '_ReinitGrace'])); 
      disable(eval([pname '_ReinitPenalty']));
    end;


    
%% ReinitGrace
    % ------------------------------------------------------------------------
    %
    %   CASE REINITGRACE
    %
    % ------------------------------------------------------------------------

  case 'ReinitGrace',
    ReinitGrace = eval([pname '_ReinitGrace']);
    InitDur     = SoundInterface(obj, 'get', [pname '_InitSnd'], 'Dur1');
    if ReinitGrace < InitDur
      ReinitGrace.value = InitDur;
    end;

    
%% closeSoundsPanel    
    % ------------------------------------------------------------------------
    %
    %   CASE CLOSESOUNDSPANEL
    %
    % ------------------------------------------------------------------------

  case 'closeSoundsPanel',
    obj = get(gcf, 'UserData'); GetSoloFunctionArgs(obj);
    try
      t = eval([pname '_SoundsPanel']);
      t.value = 1;
      callback(t);
    catch
      fprintf(1, 'PUNISHUI WARNING: %s_SoundsPanel not found, not hiding figure\n', pname);
    end;

    
%% SoundsPanel    
    % ------------------------------------------------------------------------
    %
    %   CASE SOUNDSPANEL
    %
    % ------------------------------------------------------------------------

  case 'SoundsPanel'
    t = eval([pname '_SoundsPanel']); myfig = value(eval([pname '_SoundsPanelFigure']));
    if t==0, set(myfig, 'Visible', 'off');
    else     set(myfig, 'Visible', 'on');
    end;

    
    
%% add_sma_states    
    % ------------------------------------------------------------------------
    %
    %   CASE ADD_SMA_STATES
    %
    % ------------------------------------------------------------------------
    
  case 'add_sma_states'
    
    if nargin < 4, error('PUNISHUI:nargin', 'action=add_states requires pname and sma as next arguments'); end;
    sma = x;
    if ~isa(sma, 'StateMachineAssembler'), error('PUNISHUI:badargs', 'action=add_states requires the 4th arg to be a @StateMachineAssembler object'); end;

    if     nargin == 5, varargin = {y};
    elseif nargin > 5,  varargin = [{y} varargin];
    end;
    pairs = { ...
      'name'        pname ; ...
      'exitstate'   value(eval([pname '_ExitState'])) ; ...
    }; parseargs(varargin, pairs);
    
    if exist([pname '_SoundsPanel'], 'var'),
      init_snd  = [pname '_InitSnd'];
      ongn_snd  = [pname '_OngoingSnd'];      
    else
      init_snd  = value(eval([pname '_InitSnd']));
      ongn_snd  = value(eval([pname '_OngoingSnd']));
    end;
    reinit    = value(eval([pname '_Reinit']));
    reinitGr  = value(eval([pname '_ReinitGrace']));
    reinitPn  = value(eval([pname '_ReinitPenalty']));
    duration  = value(eval([pname '_Duration']));
    
    % double-check that ReinitGrace is not less than InitSnd duration:
    if reinit == 1, 
      InitDur     = SoundInterface(obj, 'get', [pname '_InitSnd'], 'Dur1');
      if reinitGr < InitDur
        reinitGr.value = InitDur;
      end;
    end;
    
    if isempty(exitstate)        %#ok<NODEF>
      warning('PUNISHUI:missingExitState', 'No ExitState specified for punishment "%s"!!!\nAssuming immediately previous!', pname); 
      exitstate = 'immediately_previous';
    end;
    if strcmp('immediately_previous', exitstate), 
      exitstate=num2str(get_current_state(sma)-1);
    end;

    
    init_dur = SoundManagerSection(obj, 'get_sound_duration', value(init_snd));
    init_id  = SoundManagerSection(obj, 'get_sound_id',       value(init_snd));
    ongn_id  = SoundManagerSection(obj, 'get_sound_id',       value(ongn_snd));

    if duration < init_dur,
      warning('PUNISHUI:ranges', 'total duration (%g secs) less than init sound duration (%g secs)? Ignoring you, using duration=init_sound_duration', duration, init_dur);
      duration = init_dur;
    end;
    ongn_dur = duration - init_dur;

    [sma, backjump] = add_penalty_states(sma, name, reinit, reinitGr, init_dur, ongn_dur, init_id, ongn_id);
        
    % What to do if you poke:
    if reinitPn <= 0, reinitstate = ['current_state-' num2str(backjump)];
    else              reinitstate = 'current_state+2';   ongn_dur = ongn_dur + reinitPn;
    end;
    
    % Oops! You poked! Turn sounds off and start again...
    sma = add_state(sma, 'self_timer', 1e-4, 'output_actions', {'SoundOut', -init_id}, ...
      'input_to_statechange', {'Tup', 'current_state+1'});
    sma = add_state(sma, 'self_timer', 1e-4, 'output_actions', {'SoundOut', -ongn_id}, ...
      'input_to_statechange', {'Tup', reinitstate});
    
    % We're done, turn ongoing sound off and go to exit state
    sma = add_state(sma, 'self_timer', 1e-4, 'output_actions', {'SoundOut', -ongn_id}, ...
      'input_to_statechange', {'Tup', exitstate});
          
    % Now the whole darn thing again, with the longer ongoing sound
    % duration...
    
    [sma, backjump] = add_penalty_states(sma, '', reinit, reinitGr, init_dur, ongn_dur, init_id, ongn_id);
    
    % Oops! You poked! Turn sounds off and start again...
    sma = add_state(sma, 'self_timer', 1e-4, 'output_actions', {'SoundOut', -init_id}, ...
      'input_to_statechange', {'Tup', 'current_state+1'});
    sma = add_state(sma, 'self_timer', 1e-4, 'output_actions', {'SoundOut', -ongn_id}, ...
      'input_to_statechange', {'Tup', ['current_state-' num2str(backjump)]});
    
    % We're done, turn ongoing sound off and go to exit state
    sma = add_state(sma, 'self_timer', 1e-4, 'output_actions', {'SoundOut', -ongn_id}, ...
      'input_to_statechange', {'Tup', exitstate});
    
    varargout{1} = sma;
    
    
    % ---------  CASE SET ------

%% set    
  case 'set',
    varargin = [{x y} varargin];
    while ~isempty(varargin),
      param = varargin{1}; newvalue = varargin{2};

      try
        sph = eval([pname '_' param]);
      catch
        warning('PUNISHUI:Not_found', 'Couldn''t find parameter named %s, nothing changed', [pname '_' param]);
        return;
      end;
      sph.value = newvalue;
    
      % A callback on a ToggleParam is like clicking it, so we avoid it for
      % the special case of the toggle param, otherwise we call it.
      if ~ismember(param, {'Reinit', 'SoundsPanel'}), callback(sph);
      else                                            feval(mfilename, obj, param, pname);
      end;
      
      varargin = varargin(3:end);
    end;

    % ---------  CASE GET ------

%% get    
  case 'get',
    param = x; 

    try
      sph = eval([pname '_' param]);
      varargout{1} = value(sph);
    catch
      warning('PUNISHUI:Not_found', 'Couldn''t find parameter named %s, returning NaN', [pname '_' param]);
      varargout{1} = NaN;
    end;
    
    
%% disable    
    % ------------------------------------------------------------------------
    %
    %   CASE DISABLE
    %
    % ------------------------------------------------------------------------

      
  case 'disable'
    PunishInterface(obj, 'set', pname, 'SoundsPanel', 0);
    disable(eval([pname '_SoundsPanel']));
    disable(eval([pname '_Duration']));
    disable(eval([pname '_Reinit']));
    disable(eval([pname '_ReinitGrace']));
    disable(eval([pname '_ReinitPenalty']));
    
    
%% enable    
    % ------------------------------------------------------------------------
    %
    %   CASE ENABLE
    %
    % ------------------------------------------------------------------------

      
  case 'enable'
    enable(eval([pname '_SoundsPanel']));
    enable(eval([pname '_Duration']));
    enable(eval([pname '_Reinit']));
    enable(eval([pname '_ReinitGrace']));
    enable(eval([pname '_ReinitPenalty']));

      
%% reinit      
  case 'reinit',       % ---------- CASE REINIT -------------
    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);
    
    % feval(mfilename, obj, 'init');


  otherwise,
    warning('PunishInterface:Invalid', 'Don''t know action "%s", doing nothing', action);
   


end;







%% function add_penalty_states
% ------------------------------------------------------------------------
%
%   FUNCTION ADD_PENALTY_STATES
%
%   Assumes that next states after this will be two "I've poked, turn
%   sounds off" states; and the next one after that will be "I'm done."
%
% ------------------------------------------------------------------------




function [sma, backjump] = add_penalty_states(sma, pname, reinit, reinitGr, init_dur, ongn_dur, init_id, ongn_id)



   % <~> Typo in line below fixed, 2008.Sep.23 (curent_state+4 TO current_state+4)
   if ongn_dur<=0, postinit = 'current_state+4'; else postinit = 'current_state+1'; end;
   
   if reinit==0
     sma = add_state(sma, 'name', pname, 'self_timer', init_dur, ...
       'output_actions', {'SoundOut', init_id}, ...
       'input_to_statechange', {'Tup', postinit});
     sma = add_state(sma, 'self_timer', ongn_dur, ...
       'output_actions', {'SoundOut', ongn_id}, ...
       'input_to_statechange', {'Tup', 'current_state+3'});
     backjump = 3;
   else
     if reinitGr <= 0,
       sma = add_state(sma, 'name', pname, 'self_timer', init_dur, ...
         'output_actions', {'SoundOut', init_id}, ...
         'input_to_statechange', {'Tup', postinit, 'Cin', 'current_state+2', 'Rin', 'current_state+2', 'Lin', 'current_state+2'});
       sma = add_state(sma, 'self_timer', ongn_dur, ...
         'output_actions', {'SoundOut', ongn_id}, ...
         'input_to_statechange', {'Tup', 'current_state+3', 'Cin', 'current_state+1', 'Rin', 'current_state+1', 'Lin', 'current_state+1'});
       backjump = 3;
     elseif reinitGr < init_dur,
       sma = add_state(sma, 'name', pname, 'self_timer', reinitGr, ...
         'output_actions', {'SoundOut', init_id}, ...
         'input_to_statechange', {'Tup', 'current_state+1'});
       sma = add_state(sma, 'name', pname, 'self_timer', init_dur - reinitGr, ...
         'input_to_statechange', {'Tup', postinit, 'Cin', 'current_state+2', 'Rin', 'current_state+2', 'Lin', 'current_state+2'});
       sma = add_state(sma, 'self_timer', ongn_dur, ...
         'output_actions', {'SoundOut', ongn_id}, ...
         'input_to_statechange', {'Tup', 'current_state+3', 'Cin', 'current_state+1', 'Rin', 'current_state+1', 'Lin', 'current_state+1'});
       backjump = 4;
     elseif reinitGr == init_dur,
       sma = add_state(sma, 'name', pname, 'self_timer', init_dur, ...
         'output_actions', {'SoundOut', init_id}, ...
         'input_to_statechange', {'Tup', postinit});
       sma = add_state(sma, 'self_timer', ongn_dur, ...
         'output_actions', {'SoundOut', ongn_id}, ...
         'input_to_statechange', {'Tup', 'current_state+3', 'Cin', 'current_state+1', 'Rin', 'current_state+1', 'Lin', 'current_state+1'});
       backjump = 3;
     elseif reinitGr > init_dur  && reinitGr < init_dur+ongn_dur,
       sma = add_state(sma, 'name', pname, 'self_timer', init_dur, ...
         'output_actions', {'SoundOut', init_id}, ...
         'input_to_statechange', {'Tup', 'current_state+1'});
       sma = add_state(sma, 'self_timer', reinitGr-init_dur, ...
         'output_actions', {'SoundOut', ongn_id}, ...
         'input_to_statechange', {'Tup', 'current_state+1'});
       sma = add_state(sma, 'self_timer', ongn_dur - (reinitGr-init_dur), ...
         'input_to_statechange', {'Tup', 'current_state+3', 'Cin', 'current_state+1', 'Rin', 'current_state+1', 'Lin', 'current_state+1'});
       backjump = 4;
     elseif reinitGr >= init_dur + ongn_dur,  % added a >= here -JCE
       sma = add_state(sma, 'name', pname, 'self_timer', init_dur, ...
         'output_actions', {'SoundOut', init_id}, ...
         'input_to_statechange', {'Tup', postinit});
       sma = add_state(sma, 'self_timer', ongn_dur, ...
         'output_actions', {'SoundOut', ongn_id}, ...
         'input_to_statechange', {'Tup', 'current_state+3'});
       backjump = 3;
     end;
   end; % end  if reinit==0




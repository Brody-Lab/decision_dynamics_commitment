% [x, y] = WarnDangerInterface(obj, action, wd_name, x, y)
%
% Puts up a GUI for making a set of states for making a warning sound
% followed by a "danger" sound-- if the animal pokes during the danger
% sound, a jump to a state you name ensues. (Typically, this is a poke to a
% punishment state, but it's whatever you define.) The GUI lets you define
% various aspects of this warning/danger combo, and then you can make a
% simple call to add the necessary states to a @StateMachineAssembler you
% are constructing.
%
% QUICKSTART USAGE:
% -----------------
%
% To create a warn/danger GUI, call
%
%   [x, y] = WarnDangerInterface(obj, 'add', wd_name, x, y)
%
% where wd_name is a string that will identify this warn/danger section,
% and x and y are the pixel position in the current figure on which a
% the GUI for this warn/danger section appears. By using different
% wd_name strings, you can have separate, different warn/danger
% sections.
%
% Then, to use the warn/danger section, when constructing your StateMachine
% Assembler, call
%
%   sma = WarnDangerInterface(obj, 'add_sma_states', sma, wd_name, ...
%        'exitstate', exit_state_name, 'on_poke_when_danger_state', onpoke_state_name);
%
% where sma is a @StateMachineAssembler object, wd_name is the string
% identifying this warn/danger section; exit_state_name is a string
% identifying the state to jump to after the warn/danger is over; and
% onpoke_state_name is the name of the state to jump to if the animal pokes
% during the danger states. The call above will add the necessary states to
% implement the warn/danger. To start the warn/danger, have the state
% machine jump to the state named wd_name. The states that form part of the
% warning will be called [wd_name '_warning']; the states that form part of 
% the danger will be called [wd_name '_danger']. Thus, if you wish to jump
% straight to the danger section and ignore the warning, jump to [wd_name
% '_danger']. 
%    All three of a state called wd_name, a state called [wd_name '_warning'],
% and a state called [wd_name '_danger'] are always guaranteed to exist,
% you can always jump to them even if some durations have been set to 0.
%
%
% warn/danger CHARACTERISTICS:
% ---------------------------
%
% The "warn/danger" is defined by an initial sound ("warning" sound, e.g.
% a ramp of increadingly loud white noise), followed by another sound
% ("danger" sound) that loops for some desired time (e.g., white noise that
% loops until 10 s have elapsed). At the end of the danger sound, a jump to 
% exit_state_name is made. If the animal pokes during the danger sound, a
% jump to onpoke_state_name is made.
%    The "warning" sound and the "danger" sound are defined using @soundui;
% a figure with their GUI parameters is created. NOTE that how long the
% danger sound lasts depends on "DangerDur" in the warn/danger GUI, since
% the ongoing sound is forcibly set to loop. The duration in the @soundui
% GUI for this sound defines only how long one of the loop cycles lasts. 
%
% ** NOTE ** Currently only warning sounds with a single duration (Dur1)
% are supported. ToneSweeps and BupsSweeps are not yet supported. Bug
% Carlos if you want them added.
%
%
% PARAMETERS:
% -----------
%
% The first parameter, action, should be one of:
%
%  'add'     Make a GUI for a new warn/danger. This action requires three
%            more PARAMETERS:
%
%              wd_name    A string defining the name of the warn/danger
%            
%              x, y            x and y position, in pixels from bottom
%                              left of current figure, at which to start
%                              putting in the GUI elements.
%         
%            This action, 'add', also takes a number of OPTIONAL PARAMETERS:
%
%              'TooltipString'   Default is ''; Tooltip string for title of
%                         GUI.
%
%            This action, 'add', RETURNS:  x, y  next open position on
%                         current figure.
%
% 'set' wd_name 'WarnDur'|'DangerDur'  value
%        
%               The 'set' action allows setting the parameters for any of
%               the warn/dangers that have been created. The next argument
%               after 'set' must be a string, the name of the warn/danger
%               that was created with 'add'; the next argument must also be
%               a string, as listed above; and the last argument should be
%               the value the corresponding setting will be changed to.
%               Example calls:
%                     WarnDangerInterface(obj, 'set', 'mywd', 'WarnDur', 5);
%                 or
%                     DistribInterface(obj, 'set', 'mywd', 'DangerDur',   0);
%
%               It is allowable for either or both of WarnDur or DangerDur
%               to be zero. The code is robust to that.
%
%
% 'get' wd_name 'WarnDur'|'DangerDur'  
%
%               The 'get' action returns the setting of the parameters for any of
%               the warn/dangers that have been created. The next argument
%               after 'get' must be a string, the name of the warn/danger
%               that was created with 'add'; the next argument must also be
%               a string, as listed above.
%               Example call:
%                     myvarstyle = WarnDangerInterface(obj, 'get', 'mywd', 'WarnDur')
%
% 'disable' wd_name    Disables all of the GUI elements of wd_name
%
% 'enable'  wd_name    Enables all of the GUI elements of wd_name
% 


% Written by Carlos Brody Nov 2007


function [varargout] = WarnDangerInterface(obj, action, pname, x,y , varargin)

GetSoloFunctionArgs(obj);

switch action,


    % ------------------------------------------------------------------------
    %
    %   CASE ADD
    %
    % ------------------------------------------------------------------------

  
  case 'add'  
    if nargin < 5, error('Action ''add'' also requires pname, x, y, as parameters'); end;
    pairs = { ...
      'TooltipString' '' ; ...
    }; parseargs(varargin, pairs);
    
  ToggleParam(obj, [pname '_SoundsPanel'], 0, x, y, 'OnString', [pname ' snds show'], 'OffString', [pname ' snds hide'], 'position', [x y 80 20]);
  set_callback(eval([pname '_SoundsPanel']), {mfilename, 'SoundsPanel', pname});
      % start subpanel
      oldx = x; oldy = y; oldfigure = double(gcf);
      SoloParamHandle(obj, [pname '_SoundsPanelFigure'], 'saveable', 0, 'value', double(figure('Position', [120 120 430 156])));
      sfig = value(eval([pname '_SoundsPanelFigure']));
      set(sfig, 'MenuBar', 'none', 'NumberTitle', 'on', ...
        'Name', [pname ' Warning/Danger sounds'], ...
        'UserData', obj, ...
        'CloseRequestFcn', [mfilename '(warnDanger, ''closeSoundsPanel'', ''' pname ''')']);
      SoundInterface(obj, 'add', [pname '_WarningSound'], 10,  10);
      SoundInterface(obj, 'set', [pname '_WarningSound'], ...
        'Vol',   0.0002, 'Vol2',  0.003, 'Dur1',  4, 'Loop',  0, 'Style', 'WhiteNoiseRamp');
      SoundInterface(obj, 'disable', [pname '_WarningSound'], 'Loop');
      SoundInterface(obj, 'disable', [pname '_WarningSound'], 'Dur1');
      
      SoundInterface(obj, 'add', [pname '_DangerSound'],  215,  10);
      SoundInterface(obj, 'set', [pname '_DangerSound'], ...
        'Vol',   0.003, 'Dur1',  1, 'Loop',  1, 'Style', 'WhiteNoise');
      SoundInterface(obj, 'disable', [pname '_DangerSound'], 'Loop');
      set(sfig, 'Visible', 'off');
      
      x = oldx; y = oldy; figure(oldfigure);
      % end subpanel
      
    
  NumeditParam(obj, [pname '_WarnDur'],   4, x, y, 'labelfraction', 0.6, ...
    'label', ['WarnDur ' pname], ...
    'TooltipString', 'Warning sound duration in secs (zero means no warning)', ...
    'position', [x+80 y 60 20]);
  set_callback(eval([pname '_WarnDur']), {mfilename, 'WarnDur', pname});
  NumeditParam(obj, [pname '_DangerDur'], 5, x, y, 'labelfraction', 0.6, ...
    'label', ['DangerDur ' pname], ...
    'TooltipString', sprintf('\nDuration of post-drink period where poking is punished (zero means no danger)'), ...
    'position', [x+140 y 60 20]); next_row(y);
  
  varargout{1} = x;
  varargout{2} = y;
    
    
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
      warning('WARNDANGER:NotFound', '"%s"_SoundsPanel not found, not hiding figure', pname);
    end;

    % ------------------------------------------------------------------------
    %
    %   CASE WARNDUR
    %
    % ------------------------------------------------------------------------

  case 'WarnDur'
    t = eval([pname '_WarnDur']); 
    SoundInterface(obj, 'set', [pname '_WarningSound'], 'Dur1',  value(t));


    
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

    
    % ------------------------------------------------------------------------
    %
    %   CASE ADD_SMA_STATES
    %
    % ------------------------------------------------------------------------
    
  case 'add_sma_states'
    if nargin < 4, error('WARNDANGER:nargin', 'action=add_sma_states requires pname and sma as next arguments'); end;
    sma = x;
    if ~isa(sma, 'StateMachineAssembler'), error('WARNDANGER:badargs', 'action=add_sma_states requires the 4th arg to be a @StateMachineAssembler object'); end;
    
    if     nargin == 5, varargin = {y};
    elseif nargin > 5,  varargin = [{y} varargin];
    end;
    pairs = { ...
      'name'                        pname ; ...
      'exitstate'                   []    ; ...
      'on_poke_when_danger_state'   []    ; ...
      'triggertime'                0.0001 ; ...
    }; parseargs(varargin, pairs);
  
    if isempty(exitstate) || isempty(on_poke_when_danger_state), %#ok<NODEF>
      error('WARNDANGER:Invalid', 'Need both exitstate and on_poke_when_danger_state strings');
    end;
    
    WarnDur   = value(eval([pname '_WarnDur']));
    DangerDur = value(eval([pname '_DangerDur']));
    warn_id   = SoundManagerSection(obj, 'get_sound_id', [pname '_WarningSound']);
    danger_id = SoundManagerSection(obj, 'get_sound_id', [pname '_DangerSound']);
    onpoke    = on_poke_when_danger_state;

    sma = add_state(sma, 'name', pname, 'self_timer', triggertime, ...
      'input_to_statechange', {'Tup', 'current_state+1'});
    
    if WarnDur==0 && DangerDur==0,
      sma = add_state(sma, 'name', [pname '_warning'], 'self_timer', triggertime, ...
        'input_to_statechange', {'Tup', exitstate});
      sma = add_state(sma, 'name', [pname '_danger'], 'self_timer', triggertime, ...
        'input_to_statechange', {'Tup', exitstate});

    elseif WarnDur > 0 && DangerDur==0,
      sma = add_state(sma, 'name', [pname '_warning'], 'self_timer', WarnDur, ...
        'output_actions', {'SoundOut', warn_id}, ...
        'input_to_statechange', {'Tup', exitstate});
      sma = add_state(sma, 'name', [pname '_danger'], 'self_timer', triggertime, ...
        'input_to_statechange', {'Tup', exitstate});

    elseif WarnDur==0 && DangerDur > 0,
      sma = add_state(sma, 'name', [pname '_warning'], 'self_timer', triggertime, ...
        'input_to_statechange', {'Tup', 'current_state+1'});
      sma = add_state(sma, 'name', [pname '_danger'], 'self_timer', DangerDur, ...
        'output_actions', {'SoundOut', danger_id}, ...
        'input_to_statechange', {'Tup', 'current_state+1', 'Lin', 'current_state+2', 'Rin', 'current_state+2', 'Cin', 'current_state+2'});      
      sma = add_state(sma, 'self_timer', triggertime, ...
        'output_actions', {'SoundOut', -danger_id}, 'input_to_statechange', {'Tup', exitstate});
      sma = add_state(sma, 'self_timer', triggertime, ...
        'output_actions', {'SoundOut', -danger_id}, 'input_to_statechange', {'Tup', onpoke});

    elseif WarnDur > 0 && DangerDur > 0,
      sma = add_state(sma, 'name', [pname '_warning'], 'self_timer', WarnDur, ...
        'output_actions', {'SoundOut', warn_id}, ...
        'input_to_statechange', {'Tup', 'current_state+1'});
      sma = add_state(sma, 'name', [pname '_danger'], 'self_timer', DangerDur, ...
        'output_actions', {'SoundOut', danger_id}, ...
        'input_to_statechange', {'Tup', 'current_state+1', 'Lin', 'current_state+2', 'Rin', 'current_state+2', 'Cin', 'current_state+2'});      
      sma = add_state(sma, 'self_timer', triggertime, ...
        'output_actions', {'SoundOut', -danger_id}, 'input_to_statechange', {'Tup', exitstate});
      sma = add_state(sma, 'self_timer', triggertime, ...
        'output_actions', {'SoundOut', -danger_id}, 'input_to_statechange', {'Tup', onpoke});
    else
      error('WarnDanger:Invalid', 'One of WarnDur or DangerDur < 0 ?');
    end;
    varargout{1} = sma;
    
    
    % ------------------------------------------------------------------------
    %
    %   CASE SET
    %
    % ------------------------------------------------------------------------

  case 'set',
    param = x; newvalue = y;

    try
      sph = eval([pname '_' param]);
    catch
      warning('WARNDANGER:Not_found', 'Couldn''t find parameter named %s, nothing changed', [pname '_' param]);
      return;
    end;
    sph.value = newvalue;
    
    % A callback on a ToggleParam is like clicking it, so we avoid it for
    % the special case of the toggle param, otherwise we call it.
    if ~ismember(param, {'SoundsPanel'}), callback(sph);
    else                                  feval(mfilename, obj, param, pname);
    end;
    

    % ------------------------------------------------------------------------
    %
    %   CASE GET
    %
    % ------------------------------------------------------------------------


  case 'get',
    param = x; 

    try
      sph = eval([pname '_' param]);
      varargout{1} = value(sph);
    catch
      warning('WARNDANGER:Not_found', 'Couldn''t find parameter named %s, returning NaN', [pname '_' param]);
      varargout{1} = NaN;
    end;
    
    
    % ------------------------------------------------------------------------
    %
    %   CASE DISABLE
    %
    % ------------------------------------------------------------------------

      
  case 'disable'
    WarnDangerInterface(obj, 'set', pname, 'SoundsPanel', 0);
    disable(eval([pname '_SoundsPanel']));
    disable(eval([pname '_WarnDur']));
    disable(eval([pname '_DangerDur']));
    
    
    % ------------------------------------------------------------------------
    %
    %   CASE ENABLE
    %
    % ------------------------------------------------------------------------

      
  case 'enable'
    enable(eval([pname '_SoundsPanel']));
    enable(eval([pname '_WarnDur']));
    enable(eval([pname '_DangerDur']));

    
    
      
  case 'reinit',       % ---------- CASE REINIT -------------
    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);
    
    % feval(mfilename, obj, 'init');


  otherwise,
    warning('WarnDangerInterface:Invalid', 'Don''t know action "%s", doing nothing', action);
   


end;






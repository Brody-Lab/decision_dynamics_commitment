function [obj] = Simplest(varargin)

% Default object is of our own class (mfilename); in this simplest of
% protocols, we will not inherit any elements from Plugins/

obj = class(struct, mfilename);

% If creating an empty object, return without further ado:
if nargin==0 || (nargin==1 && ischar(varargin{1}) && strcmp(varargin{1}, 'empty')), 
   return; 
end;

if isa(varargin{1}, mfilename), % Most likely responding to a callback from 
                                % a SoloParamHandle defined in this mfile.
  if length(varargin) < 2, 
    error(['If called with a "%s" object as first arg, a second arg, a ' ...
      'string specifying the action, is required\n']);
  else action = varargin{2}; varargin = varargin(3:end);
  end;
else % Ok, regular call with first param being the action string.
       action = varargin{1}; varargin = varargin(2:end);
end;

GetSoloFunctionArgs(obj);

switch action,

  %---------------------------------------------------------------
  %          CASE INIT
  %---------------------------------------------------------------
  
  case 'init'

    % Make default figure. We remember to make it non-saveable; on next run
    % the handle to this figure might be different, and we don't want to
    % overwrite it when someone does load_data and some old value of the
    % fig handle was stored as SoloParamHandle "myfig"
    SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = figure;

    % Make the title of the figure be the protocol name, and if someone tries
    % to close this figure, call dispatcher's close_protocol function, so it'll know
    % to take it off the list of open protocols.
    name = mfilename;
    set(value(myfig), 'Name', name, 'Tag', name, ...
      'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');


    % Ok, gotta figure out what this hack variable is doing here, why we need
    % it, and how to do without it. For now, though, if you want to use
    % SessionModel...
    hackvar = 10; SoloFunctionAddVars('SessionModel', 'ro_args', 'hackvar');

    % At this point we have one SoloParamHandle, myfig
    % Let's put the figure where we want it and give it a reasonable size:
    set(value(myfig), 'Position', [485   144   200   20]);

    % ----------

    x = 5; y = 5;             % Initial position on main GUI window

    [x, y] = SavingSection(obj, 'init', x, y);

    [x, y] = SidesSection(obj, 'init', x, y);
    
    [x, y] = RewardsSection(obj, 'init',x, y);
    
    % Make the main figure window as wide as it needs to be and as tall as it
    % needs to be; that way, no matter what each plugin requires in terms of
    % space, we always have enough space for it.
    pos = get(value(myfig), 'Position');
    set(value(myfig), 'Position', [pos(1:2) x+220 y+25]);

    
    % The SoundManager and StateMatrix Sections have no GUI elements:
    SoundManagerSection(obj, 'init');
    StateMatrixSection(obj, 'init');
    

    
  %---------------------------------------------------------------
  %          CASE STATE35
  %---------------------------------------------------------------
  case 'state35'
    RewardsSection(obj, 'update');
    
    SidesSection(obj, 'next_trial');
    
    StateMatrixSection(obj, 'next_trial');
    
  %---------------------------------------------------------------
  %          CASE STATE0
  %---------------------------------------------------------------
  case 'state0'
    fprintf(1, ['\nFrom the beginning of this trial #%d to the\n' ...
      'start of the next, %g seconds elapsed.\n\n'], n_done_trials, ...
      parsed_events.(parsed_events.ending_state)(end,1) - parsed_events.(parsed_events.starting_state)(1,2));
    
    
  %---------------------------------------------------------------
  %          CASE UPDATE
  %---------------------------------------------------------------
  case 'update'
    if ~isempty(latest_parsed_events.starting_state),
      fprintf(1, 'Somep''n happened! Since the last update, we''ve moved from state "%s" to state "%s"\n', ...
        latest_parsed_events.starting_state, latest_parsed_events.ending_state);
    end;
      

  %---------------------------------------------------------------
  %          CASE CLOSE
  %---------------------------------------------------------------
  case 'close'
    delete(value(myfig));

  otherwise,
    warning('Unknown action! "%s"\n', action);
end;

return;



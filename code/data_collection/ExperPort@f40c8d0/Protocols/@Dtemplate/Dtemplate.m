function [obj] = Dtemplate(varargin)

% Default object is of our own class (mfilename); also inherit from
% a variety of objects in Plugins/ . Can inherit from as many objects
% in Plugins/ as you like.
obj = class(struct, mfilename, saveload, water, antibias, pokesplot, soundmanager);

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

    % Let's declare some globals that everybody is likely to want to know about.
    % History of hit/miss:
    SoloParamHandle(obj, 'hit_history',      'value', []);

    % Every function will be able to read these, but only those explicitly
    % given r/w access will be able to modify them:
    DeclareGlobals(obj, 'ro_args', 'hit_history');

    % Let RewardsSection, the part that parses what happened at the end of
    % a trial, write to hit_history:
    SoloFunctionAddVars('RewardsSection', 'rw_args', 'hit_history');

    % ----------

    x = 5; y = 5; maxy=5;             % Initial position on main GUI window

    % From Plugins/@saveload:
    [x, y] = SavingSection(obj, 'init', x, y);

    % From Plugins/@water:
    [x, y] = WaterValvesSection(obj, 'init', x, y);

    maxy = max(y, maxy); next_column(x); y=5;

    [x, y] = SidesSection(obj, 'init', x, y);
    
    % From Plugins/@antibias:
    [x, y] = AntibiasSection(obj, 'init', x, y, SidesSection(obj, 'get_left_prob'));

    
    maxy = max(y, maxy); next_column(x); y=5;

    [x, y] = RewardsSection(obj, 'init',x, y);
    
    % From Plugins/@soundmanager:
    SoundManagerSection(obj, 'init');

    StateMatrixSection(obj, 'init');
    
    % Finally, make the main figure window as wide as it needs to be and as tall as it
    % needs to be; that way, no matter what each plugin requires in terms of
    % space, we always have enough space for it.
    maxy = max(y, maxy);
    pos = get(value(myfig), 'Position');
    set(value(myfig), 'Position', [pos(1:2) x+220 maxy+25]);

    
  %---------------------------------------------------------------
  %          CASE STATE35
  %---------------------------------------------------------------
  case 'state35'
    % First trial is just the test trial.
    if n_done_trials == 1,
      StateMatrixSection(obj, 'next_trial');
      return;
    end;

    % Ok, a REAL trial just happened-- we should update all our stuff.
    RewardsSection(obj, 'update');
    
    prevs = SidesSection(obj, 'get_previous_sides');
    lprob = SidesSection(obj, 'get_left_prob');
    AntibiasSection(obj, 'update', lprob, value(hit_history), prevs);

    SidesSection(obj, 'next_trial');
    
    StateMatrixSection(obj, 'next_trial');
    
  %---------------------------------------------------------------
  %          CASE STATE0
  %---------------------------------------------------------------
  case 'state0'

    
    
  %---------------------------------------------------------------
  %          CASE UPDATE
  %---------------------------------------------------------------
  case 'update'


  %---------------------------------------------------------------
  %          CASE CLOSE
  %---------------------------------------------------------------
  case 'close'
    delete(value(myfig));

  otherwise,
    warning('Unknown action! "%s"\n', action);
end;

return;



function [obj] = util_compare(varargin)

%---------------------------------------------------------------
%   function [obj] = util_compare(varargin)
%---------------------------------------------------------------

% Stephanie Chow 
% Time-stamp: <2007-09-06 00:25:44 chow>
%
% Protocol for a 2afc comparison task in which the stimulus predicts the
% reward probability
%
% variant of the Romo task with same time structure, but where expected
% reward is a function of a stimulus parameter, likely pitch
% 
% to run:
% newstartup
% dispatcher('init')
%
% based in part on the protocols Multipokes3 and Minimal

obj = class(struct, mfilename, saveload, water, antibias, ...
    pokesplot, sessionmodel, soundmanager);

%---------------------------------------------------------------
%   BEGIN SECTION COMMON TO ALL PROTOCOLS, DO NOT MODIFY
%---------------------------------------------------------------

% If creating an empty object, return without further ado:
if nargin==0 || (nargin==1 && ischar(varargin{1}) && strcmp(varargin{1}, 'empty')), 
  return; 
end;

if isa(varargin{1}, mfilename), % If first arg is an object of this class
                                % itself, we are most likely responding to a
                                % callback from a SoloParamHandle defined in
                                % this mfile.
  if length(varargin) < 2 || ~isstr(varargin{2}), 
    error(['If called with a "%s" object as first arg, a second arg, a ' ...
           'string specifying the action, is required\n']);
  else action = varargin{2}; varargin = varargin(3:end);
  end;
else % Ok, regular call with first param being the action string.
  action = varargin{1}; varargin = varargin(2:end);
end;
if ~isstr(action), error('The action parameter must be a string'); end;

GetSoloFunctionArgs(obj); %%% or leave out the "obj"?

%---------------------------------------------------------------
%   END OF SECTION COMMON TO ALL PROTOCOLS, MODIFY AFTER THIS LINE
%---------------------------------------------------------------

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
  set(value(myfig), 'Name', name, 'Tag', name, 'closerequestfcn', ...
                    'dispatcher(''close_protocol'')', 'MenuBar', 'none');
  
  % Ok, gotta figure out what this hack variable is doing here, why we need
  % it, and how to do without it. For now, though, if you want to use
  % SessionModel...
  hackvar = 10; SoloFunctionAddVars('SessionModel', 'ro_args', 'hackvar');
  
  % At this point we have one SoloParamHandle, myfig
  % Let's put the figure where we want it and give it a reasonable size:
  set(value(myfig), 'Position', [485   144   600   600]);
  
  % ---------- new stuff, lifted from Bing's Multipokes3
  
  % Let's declare some globals that everybody is likely to want to know about.
  % History of hit/miss:
  SoloParamHandle(obj, 'hit_history', 'value', []);
  SoloParamHandle(obj, 'nTrials','value',0); % variable for us to locally store number of done trials
  
  % Every function will be able to read these, but only those explicitly given
  % r/w access will be able to modify them:
  DeclareGlobals(obj, 'ro_args', 'hit_history');
  
  % Let RewardsSection, the part that parses what happened at the end of
  % a trial, write to hit_history:
  SoloFunctionAddVars('RewardsSection', 'rw_args', 'hit_history');

  % ---------- from Plugins/@soundmanager via Multipokes3
  SoundManagerSection(obj, 'init');

  x = 5; y = 5; maxy = 5;            % Initial position on main GUI window
  
  % Make the main figure window as wide as it needs to be and as tall as it
  % needs to be; that way, no matter what each plugin requires in terms of
  % space, we always have enough space for it.
  
  %%% need all these?

  % plugins
  
  [x, y] = SavingSection(obj, 'init', x, y);
  [x, y] = WaterValvesSection(obj, 'init', x, y);
  maxy = max(y, maxy); y=5; next_column(x);
  [x, y] = SidesSection(obj, 'init', x, y);
  [x, y] = AntibiasSection(obj, 'init', x, y, 0.5);
%  maxy = max(y, maxy); y=5; next_row(y);
  maxy = max(y, maxy); next_column(x); y = 5;
  % maxy = max(y, maxy); y = 5; next_column(x);
  [x, y] = StimulusSection(obj, 'init', x, y);
  % maxy = max(y, maxy); y=5; next_row(y); next_column(x);
  %   maxy = max(y, maxy); y=5;
  % [x, y] = TimesSection(obj, 'init', x, y);
  % [x, y] = RewardsSection(obj, 'init',x, y);
  
  % next_row(y);

  % makes more sense for this to be in statematrix section but don't know
  % how.
  % hmmm... colours: ignore 1s/2s wrt pokes? wait_for_lpoke/prefer_lpoke?
  % colour by best poke side, also brighter if water, duller if not?
  my_state_colours = struct( ...
    'start_trial' ,      [1   1   1  ], ...     % white
    'leftbest_trial' ,   [255 25   63 ]/255, ... % bluish red
    'rightbest_trial' ,  [63  25   255]/255, ... % reddish blue
    'leftonly_trial' ,   [255 25   25  ]/255, ... % red
    'rightonly_trial' ,  [25   25   255]/255, ... % blue
    'wait_for_cpoke' ,   [0   200 0  ]/255, ... % dark green
    'wait_for_spoke',    [127 255 127]/255, ... % light green
    'lpoke_1s_ltrial',   [255 0   0  ]/255, ... % red = left
    'lpoke_1s_rtrial',   [255 0   0  ]/255, ... % red
    'lpoke_2s_ltrial',   [255 0   0  ]/255, ... % red
    'lpoke_2s_rtrial',   [255 0   0  ]/255, ... % red
    'rpoke_1s_ltrial',   [0   0   255]/255, ... % blue = right
    'rpoke_1s_rtrial',   [0   0   255]/255, ... % blue
    'rpoke_2s_ltrial',   [0   0   255]/255, ... % blue
    'rpoke_2s_rtrial',   [0   0   255]/255, ... % blue
    'off_lwater',        [1   1   1  ]*0.5, ... % medium grey
    'off_rwater',        [1   1   1  ]*0.5, ... % medium grey
    'no_water',          [245 245 220]/255, ... % beige
    'error_state',       [255 255 0  ]/255, ... % yellow
    'state_0',           [1   1   1  ],  ...
    'check_next_trial_ready',     [0.7 0.7 0.7]);

  my_poke_colours = struct('L', 0.9*[0.1 0.1 0.9],    ...
                          'C',     [0 0 0],       ...
                          'R', 0.9*[0.9 0.1 0.1]);
  
  [x, y] = PokesPlotSection(obj, 'init', x, y, struct('states', my_state_colours, ...
                                                    'pokes', my_poke_colours));
  
  %%% fix -- set to first state (x,y) refers to line/trial x and
  % beginning (y = 1) or end (y = 2)
  
  PokesPlotSection(obj, 'set_alignon', 'wait_for_cpoke1(1,1)');
  
  SessionDefinition(obj, 'init', x, y, value(myfig));
  
  %     maxy = 700;
  %     
  %     % Make the main figure window as wide as it needs to be and as tall as
  %     % it needs to be; that way, no matter what each plugin requires in terms of
  %     % space, we always have enough space for it.
  %     pos = get(value(myfig), 'Position');
  %     set(value(myfig), 'Position', [pos(1:2) x+240 maxy+25]);
  
  %  pos = get(value(myfig), 'Position');
  %  set(value(myfig), 'Position', [pos(1:2) x+250 maxy+150]);

  figpos = get(gcf, 'Position');
  HeaderParam(obj, 'prot_title', 'util_compare', x, y, 'position', [10 ...
                      figpos(4)-25, 200 20]);
  
  StateMatrixSection(obj, 'init');
  % The SoundManager and StateMatrix Sections have no GUI elements:

  % ----------  end of lifting
    
  %---------------------------------------------------------------
  %          CASE PREPARE_NEXT_TRIAL
  %---------------------------------------------------------------
  
 case 'prepare_next_trial'
  %  feval(mfilename, 'update');
  
  nTrials.value = n_done_trials;
  fprintf(1, 'Got to a prepare_next_trial state -- making the next state matrix\n');
  
  % ---------- new stuff, lifted from Bing's Multipokes3
  
  % RewardsSection(obj, 'update');
  
  if value(nTrials) < 1,
      SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
      StateMatrixSection(obj, 'next_trial');
      return;
  else    
      % evaluates the training string to prepare for the next trial
      SessionDefinition(obj, 'next_trial');

      AntibiasSection(obj, 'update', LeftProb, hit_history, previous_best_sides);
      % TimesSection(obj, 'compute_iti');
      StimulusSection(obj, 'update');

      % choose next side after antibias has computed posterior prob
      SidesSection(obj, 'next_trial');
      SidesSection(obj, 'update_plot');

      SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');

      % make next state matrix
      StateMatrixSection(obj, 'next_trial');
  end;
  
  % ---------- end of lifting
  
  %---------------------------------------------------------------
  %          CASE TRIAL_COMPLETED
  %---------------------------------------------------------------
 case 'trial_completed'
  % Do any updates in the protocol that need doing:
  % feval(mfilename, 'update');
  % And PokesPlot needs completing the trial:
  PokesPlotSection(obj, 'trial_completed');
  
  %---------------------------------------------------------------

  %          CASE UPDATE
  %---------------------------------------------------------------
 case 'update'
  PokesPlotSection(obj, 'update');
  
  
  %---------------------------------------------------------------
  %          CASE CLOSE
  %---------------------------------------------------------------
 case 'close'
  PokesPlotSection(obj, 'close');
  if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),
    delete(value(myfig));
  end;
  delete_sphandle('owner', ['^@' class(obj) '$']);
  
 otherwise,
  warning('Unknown action! "%s"\n', action);
end;

return;


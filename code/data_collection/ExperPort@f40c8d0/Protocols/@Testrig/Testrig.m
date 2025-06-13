
% Make sure you ran newstartup, then dispatcher('init'), and you're good to
% go!
%

function [obj] = Testrig(varargin)

% Default object is of our own class (mfilename); in this simplest of
% protocols, we inherit only from Plugins/@pokesplot

obj = class(struct, mfilename, pokesplot, saveload, soundmanager, soundui);

%---------------------------------------------------------------
%   BEGIN SECTION COMMON TO ALL PROTOCOLS, DO NOT MODIFY
%---------------------------------------------------------------

% If creating an empty object, return without further ado:
if nargin==0 || (nargin==1 && ischar(varargin{1}) && strcmp(varargin{1}, 'empty')), 
   return; 
end;

if isa(varargin{1}, mfilename), % If first arg is an object of this class itself, we are 
                                % Most likely responding to a callback from  
                                % a SoloParamHandle defined in this mfile.
  if length(varargin) < 2 || ~ischar(varargin{2}), 
    error(['If called with a "%s" object as first arg, a second arg, a ' ...
      'string specifying the action, is required\n']);
  else action = varargin{2}; varargin = varargin(3:end);
  end;
else % Ok, regular call with first param being the action string.
       action = varargin{1}; varargin = varargin(2:end);
end;
if ~isstr(action), error('The action parameter must be a string'); end;

GetSoloFunctionArgs(obj);

%---------------------------------------------------------------
%   END OF SECTION COMMON TO ALL PROTOCOLS, MODIFY AFTER THIS LINE
%---------------------------------------------------------------


% ---- From here on is where you can put the code you like.
%
% Your protocol will be called, at the appropriate times, with the
% following possible actions:
%
%   'init'     To initialize -- make figure windows, variables, etc.
%
%   'update'   Called periodically within a trial
%
%   'prepare_next_trial'  Called when a trial has ended and your protocol
%              is expected to produce the StateMachine diagram for the next
%              trial; i.e., somewhere in your protocol's response to this
%              call, it should call "dispatcher('send_assembler', sma,
%              prepare_next_trial_set);" where sma is the
%              StateMachineAssembler object that you have prepared and
%              prepare_next_trial_set is either a single string or a cell
%              with elements that are all strings. These strings should
%              correspond to names of states in sma.
%                 Note that after the 'prepare_next_trial' call, further
%              events may still occur in the RTLSM while your protocol is thinking,
%              before the new StateMachine diagram gets sent. These events
%              will be available to you when 'trial_completed' is called on your
%              protocol (see below).
%
%   'trial_completed'   Called when 'state_0' is reached in the RTLSM,
%              marking final completion of a trial (and the start of 
%              the next).
%
%   'close'    Called when the protocol is to be closed.
%
%
% VARIABLES THAT DISPATCHER WILL ALWAYS INSTANTIATE FOR YOU IN YOUR 
% PROTOCOL:
%
% (These variables will be instantiated as regular Matlab variables, 
% not SoloParamHandles. For any method in your protocol (i.e., an m-file
% within the @your_protocol directory) that takes "obj" as its first argument,
% calling "GetSoloFunctionArgs(obj)" will instantiate all the variables below.)
%
%
% n_done_trials     How many trials have been finished; when a trial reaches
%                   one of the prepare_next_trial states for the first
%                   time, this variable is incremented by 1.
%
% n_started trials  How many trials have been started. This variable gets
%                   incremented by 1 every time the state machine goes
%                   through state 0.
%
% parsed_events     The result of running disassemble.m, with the
%                   parsed_structure flag set to 1, on all events from the
%                   start of the current trial to now.
%
% latest_events     The result of running disassemble.m, with the
%                   parsed_structure flag set to 1, on all new events from
%                   the last time 'update' was called to now.
%
% raw_events        All the events obtained in the current trial, not parsed
%                   or disassembled, but raw as gotten from the State
%                   Machine object.
%
% current_assembler The StateMachineAssembler object that was used to
%                   generate the State Machine diagram in effect in the
%                   current trial.
%
% Trial-by-trial history of parsed_events, raw_events, and
% current_assembler, are automatically stored for you in your protocol by
% dispatcher.m. See the wiki documentation for information on how to access
% those histories from within your protocol and for information.
%
% 


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



    % At this point we have one SoloParamHandle, myfig
    % Let's put the figure where we want it and give it a reasonable size:
    set(value(myfig), 'Position', [485   144   300   300]);

    % ----------

    x = 5; y = 5;             % Initial position on main GUI window

    SoundManagerSection(obj, 'init');
    [x, y] = SavingSection(obj, 'init', x, y);
    
    next_row(y);
    
    DispParam(obj, 'nTrials', 0, x, y); next_row(y);
    % For plotting with the pokesplot plugin, we need to tell it what
    % colors to plot with:
    my_state_colors = struct( ...
      'wait_for_left',    [0.2 0.5 0.2], ...
      'in_left',          [0.5 0.5 1],   ...
      'in_center',        [0.5 1 0.5],   ...
      'in_right',         [1 0.5 0.5],   ...
      'state_0',                [1 1 1],       ...
      'final_state',            [0.5 0 0],     ...
      'check_next_trial_ready', [0.7 0.7 0.7]);
    % In pokesplot, the poke colors have a default value, so we don't need
    % to specify them, but here they are so you know how to change them.
    my_poke_colors = struct( ...
      'L',                  0.6*[1 0.66 0],    ...
      'C',                      [0 0 0],       ...
      'R',                  0.9*[1 0.66 0]);
    
    [x, y] = PokesPlotSection(obj, 'init', x, y, ...
      struct('states',  my_state_colors, 'pokes', my_poke_colors));

    next_row(y);
    SubheaderParam(obj, 'title', 'Poke in lights', x, y); next_row(y);
    
    [x,y] = SoundInterface(obj, 'add', 'mysound', x, y, ...
        'Volume', 0.1, 'Style', 'Bups', 'Freq', 100, 'Loop', 1); next_row(y);
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
   
    
    % Make the main figure window as wide as it needs to be and as tall as
    % it needs to be; that way, no matter what each plugin requires in terms of
    % space, we always have enough space for it.
    pos = get(value(myfig), 'Position');
    set(value(myfig), 'Position', [pos(1:2) x+240 y+25]);

    
    Testrig(obj, 'prepare_next_trial');
    
    
    
  %---------------------------------------------------------------
  %          CASE PREPARE_NEXT_TRIAL
  %---------------------------------------------------------------
  case 'prepare_next_trial'
    % feval(mfilename, 'update');

    nTrials.value = n_done_trials;

    sma = StateMachineAssembler('full_trial_structure');
    sma = add_state(sma, 'name', 'wait_for_left', ...
        'input_to_statechange', {'Lin', 'in_left'}, ...
        'output_actions', { ...
        'DOut', bSettings('get', 'DIOLINES', 'left1led'), ...
        'SoundOut', -SoundManagerSection(obj, 'get_sound_id', 'mysound')});
    sma = add_state(sma, 'name', 'in_left', ...
        'input_to_statechange', {'Lout', 'wait_for_center'}, ...
        'output_actions', {'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'mysound')});

    sma = add_state(sma, 'name', 'wait_for_center', ...
        'input_to_statechange', {'Cin', 'in_center'}, ...
        'output_actions', { ...
        'DOut', bSettings('get', 'DIOLINES', 'center1led'), ...
        'SoundOut', -SoundManagerSection(obj, 'get_sound_id', 'mysound')});
    sma = add_state(sma, 'name', 'in_center', ...
        'input_to_statechange', {'Cout', 'wait_for_right'}, ...
        'output_actions', {'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'mysound')});

    sma = add_state(sma, 'name', 'wait_for_right', ...
        'input_to_statechange', {'Rin', 'in_right'}, ...
        'output_actions', { ...
        'DOut', bSettings('get', 'DIOLINES', 'right1led'), ...
        'SoundOut', -SoundManagerSection(obj, 'get_sound_id', 'mysound')});
    sma = add_state(sma, 'name', 'in_right', ...
        'input_to_statechange', {'Rout', 'final_state'}, ...
        'output_actions', {'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'mysound')});

    sma = add_state(sma, 'name', 'final_state', ...
      'self_timer', 1, 'input_to_statechange', {'Tup', 'check_next_trial_ready'}, ...
      'output_actions', {'SoundOut', -SoundManagerSection(obj, 'get_sound_id', 'mysound')});
    dispatcher('send_assembler', sma, 'final_state');

    % Defaul behavior of following call is that every 20 trials, the data
    % gets saved, not interactive, no commit to CVS.
    SavingSection(obj, 'autosave_data');
    
  %---------------------------------------------------------------
  %          CASE TRIAL_COMPLETED
  %---------------------------------------------------------------
  case 'trial_completed'
    % Do any updates in the protocol that need doing:
    feval(mfilename, 'update');
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
    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), %#ok<NODEF>
      delete(value(myfig));
    end;
    delete_sphandle('owner', ['^@' class(obj) '$']);

  otherwise,
    warning('Unknown action! "%s"\n', action); %#ok<WNTAG>
end;

return;


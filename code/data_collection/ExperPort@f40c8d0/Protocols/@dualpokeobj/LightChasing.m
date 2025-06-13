

function [obj] = LightChasing(varargin)

obj = class(struct, mfilename, saveload, water, antibias3way, pokesplot, ...
  soundmanager, soundui ,sessionmodel, distribui, punishui, warnDanger, ...
  comments, softpokestay);

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
  else action = varargin{2}; varargin = varargin(3:end); %#ok<NASGU>
  end;
else % Ok, regular call with first param being the action string.
       action = varargin{1}; varargin = varargin(2:end); %#ok<NASGU>
end;
if ~ischar(action), error('The action parameter must be a string'); end;

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
    
    hackvar = 10; SoloFunctionAddVars('SessionModel', 'ro_args', 'hackvar'); %#ok<NASGU>
    
    SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = figure;

    % Make the title of the figure be the protocol name, and if someone tries
    % to close this figure, call dispatcher's close_protocol function, so it'll know
    % to take it off the list of open protocols.
    name = mfilename;
    set(value(myfig), 'Name', name, 'Tag', name, ...
      'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');

    % At this point we have one SoloParamHandle, myfig
    % Let's put the figure where we want it and give it a reasonable size:
    set(value(myfig), 'Position', [400   50   800   600]);

    % ----------
    
    SoloParamHandle(obj, 'hit_history',   'value', []);
    SoloParamHandle(obj, 'sides_history', 'value', '');
    DeclareGlobals(obj, 'ro_args', {'hit_history', 'sides_history'});
    SoloFunctionAddVars('RewardsSection', 'rw_args', 'hit_history');
    SoloFunctionAddVars('Sides3waySection',   'rw_args', 'sides_history');

    % We use the following to generate a call that will occur after
    % any loading of data. We can use that to do any updates we may want.
    SoloParamHandle(obj, 'after_load_callbacks', 'value', []);
    set_callback(after_load_callbacks, {mfilename, 'after_load_callbacks'});
    set_callback_on_load(after_load_callbacks, 1);

    SoundManagerSection(obj, 'init');
    
    x = 5; y = 5;             % Initial position on main GUI window

    [x, y] = SavingSection(obj,       'init', x, y); 
    [x, y] = WaterValvesSection(obj,  'init', x, y);
        
    [x, y] = PokesPlotSection(obj,    'init', x, y, ...
      struct('states',  SMASection(obj, 'get_state_colors')));
    next_row(y);
    
    [x, y] = CommentsSection(obj, 'init', x, y);
    
    SessionDefinition(obj,   'init', x, y, value(myfig)); next_row(y, 2); %#ok<NASGU>
    next_row(y, 1.5);
        
    figpos = get(gcf, 'Position');
    [expmtr, rname]=SavingSection(obj, 'get_info');
    HeaderParam(obj, 'prot_title', [mfilename ': ' expmtr ', ' rname], ...
      x, y, 'position', [10 figpos(4)-25, 800 20]);
    
    next_column(x); y=5;
  

    [x, y] = DistribInterface(obj, 'add', 'var_gap', x, y);
    next_row(y, 0.5);
    
    [x, y] = DistribInterface(obj, 'add', 'light_time', x, y);
    next_row(y, 0.5);
    MenuParam(obj, 'n_center_pokes', {'0', '1', '2'}, 0, x, y); next_row(y, 1.5);
    SoloFunctionAddVars('SMASection', 'ro_args', 'n_center_pokes');
    
    ToggleParam(obj, 'center_side', 1, x, y, 'TooltipString', ...
      sprintf('\nIf ON, center can be a side choice, but if OFF, center only as a poke before a side.'), ...
      'OnString', 'center choice ON', 'OffString', 'center choice OFF'); next_row(y);
    SoloFunctionAddVars('SMASection', 'ro_args', 'center_side');
    next_row(y, 0.5);
       
    ToggleParam(obj, 'centerlight', 0, x, y, 'TooltipString', ...
      sprintf('\nIf ON, then center is automatically set to probability 0 and the center light will also be lit'), ...
      'OnString', 'Anti Center ON', 'OffString', 'Anti Center OFF'); next_row(y);
    SoloFunctionAddVars('SMASection', 'ro_args', 'centerlight');

    ToggleParam(obj, 'anti', 0, x, y, 'TooltipString', ...
      sprintf('\nIf ON, then center is automatically set to probability 0 and the opposite light is lit'), ...
      'OnString', 'Anti (Anti ON)', 'OffString', 'Pro (Anti OFF)'); next_row(y);
    SoloFunctionAddVars('SMASection', 'ro_args', 'anti');
    next_row(y, 0.5);
    



    
    next_column(x); y = 5;
    
    
    %Warn Danger At End of Trial
    %SubheaderParam(obj, [pname '_Title'], ['Trial End Warn Danger'], x, y, 'TooltipString', TooltipString); next_row(y);
    [x, y] = WarnDangerInterface(obj, 'add', 'warndanger', x, y);
    WarnDangerInterface(obj, 'set', 'warndanger', 'WarnDur',   6);
    WarnDangerInterface(obj, 'set', 'warndanger', 'DangerDur', 0);
    next_row(y, 1);    
    
    %Reward Controls
    NumeditParam(obj, 'center_time', 2, x, y, ...
      'TooltipString', sprintf('\nExtra time given after center poke before going to the next trial.'));
    SoloFunctionAddVars('SMASection', 'ro_args', 'center_time');
    next_row(y, 0.1);    
    [x, y] = SoftPokeStayInterface(obj, 'add', 'reward', x, y);
    SoftPokeStayInterface(obj, 'set', 'reward', 'Duration', 20, 'Grace', 2.5);
    next_row(y, 1);
    
    %Late Punish Controls
    ToggleParam(obj, 'nolate', 0, x, y, 'TooltipString', ...
      sprintf('\nIf ON, then center is automatically set to probability 0 and the center light will also be lit'), ...
      'OnString', 'No Late Punish', 'OffString', 'Late Punish ON'); next_row(y);
    SoloFunctionAddVars('SMASection', 'ro_args', 'nolate');
    next_row(y, 0.1);        
    [x, y] = PunishInterface(obj, 'add', 'late_punish', x, y);
    PunishInterface(obj, 'set', 'late_punish', 'SoundsPanel', 0);
    next_row(y, 1);
    
    %Wrong Punish Controls
    ToggleParam(obj, 'nowrong', 0, x, y, 'TooltipString', ...
      sprintf('\nIf ON, then center is automatically set to probability 0 and the center light will also be lit'), ...
      'OnString', 'No Wrong Punish', 'OffString', 'Wrong Punish ON'); next_row(y);
    SoloFunctionAddVars('SMASection', 'ro_args', 'nowrong');
    next_row(y, 0.1);
    [x, y] = PunishInterface(obj, 'add', 'wrong_punish', x, y);
    PunishInterface(obj, 'set', 'wrong_punish', 'SoundsPanel', 0);
    next_row(y, 1);
    
    %Early Punish Controls
    [x, y] = WarnDangerInterface(obj, 'add', 'early_punish', x, y);
    WarnDangerInterface(obj, 'set', 'early_punish', 'WarnDur',   6);
    WarnDangerInterface(obj, 'set', 'early_punish', 'DangerDur', 0);
    next_row(y, 0.1); 
    ToggleParam(obj, 'noearly', 0, x, y, 'TooltipString', ...
      sprintf(['\nIf OFF, early poke causes warndanger state which then transitions' ...
      '\nback to the wait time before light turns on. If ON, early poke is punished.']), ...
      'OnString', 'Punish Early OFF', 'OffString', 'Punish Early ON'); next_row(y);
    SoloFunctionAddVars('SMASection', 'ro_args', 'noearly');
    next_row(y, 0.1);
    [x, y] = PunishInterface(obj, 'add', 'early_punish', x, y);
    PunishInterface(obj, 'set', 'early_punish', 'SoundsPanel', 0);
    next_row(y, 0.1);    
    
    
    
    next_column(x); y = 5;
    [x, y] = Antibias3waySection(obj, 'init', x, y);
    next_row(y, 0.5);
    
    [x, y] = Sides3waySection(obj, 'init', x, y);
    next_row(y);
    
    RewardsSection(obj,'init',x,y);
    
    feval(mfilename, obj, 'prepare_next_trial');

%% prepare_next_trial    
  %---------------------------------------------------------------
  %          CASE PREPARE_NEXT_TRIAL
  %---------------------------------------------------------------
  case 'prepare_next_trial'
    % feval(mfilename, 'update');

    SessionDefinition(obj, 'next_trial');

    RewardsSection(obj,  'prepare_next_trial');
    
    if (center_side == 0 || anti==1),
        TargetProbs = Antibias3waySection(obj, 'get', 'TargetProbs');
        LProb = TargetProbs(2) + 0.5*TargetProbs(1);
        Antibias3waySection(obj, 'set_target_probs', 0, LProb);
    end;
    
    Antibias3waySection(obj, 'update', hit_history, sides_history);
    Sides3waySection(obj,    'prepare_next_trial');
    
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds'); %What does this do?
    
    DistribInterface(obj, 'get_new_sample', 'var_gap');
    DistribInterface(obj, 'get_new_sample', 'light_time');
    
    [sma, prepare_next_trial_states] = SMASection(obj, 'prepare_next_trial');
    
    dispatcher('send_assembler', sma, prepare_next_trial_states);

    Sides3waySection(obj, 'update_plot');
    
    % Default behavior of following call is that every 20 trials, the data
    % gets saved, not interactive, no commit to CVS.
    SavingSection(obj, 'autosave_data');
    
    CommentsSection(obj, 'clear_history'); % Make sure we're not storing unnecessary history
    if n_done_trials==1,  % Auto-append date for convenience.
      CommentsSection(obj, 'append_date'); CommentsSection(obj, 'append_line', '');
    end;

    if n_done_trials==1
      [expmtr, rname]=SavingSection(obj, 'get_info');
      prot_title.value=[mfilename ' on rig ' get_hostname ' : ' expmtr ', ' rname  '.  Started at ' datestr(now, 'HH:MM')];
    end

    if n_done_trials >= 1, feval(mfilename, obj, 'update'); end;

    
%% trial_completed    
  %---------------------------------------------------------------
  %          CASE TRIAL_COMPLETED
  %---------------------------------------------------------------
  case 'trial_completed'
    % Do any updates in the protocol that need doing:
    feval(mfilename, 'update');
    % And PokesPlot needs completing the trial:
    PokesPlotSection(obj, 'trial_completed');
  
%% update    
  %---------------------------------------------------------------
  %          CASE UPDATE
  %---------------------------------------------------------------
  case 'update'
    PokesPlotSection(obj, 'update');
    

%% end_session    
  %---------------------------------------------------------------
  %          CASE END_SESSION
  %---------------------------------------------------------------
  case 'end_session'
     prot_title.value = [value(prot_title) ', Ended at ' datestr(now, 'HH:MM')]; %#ok<NODEF>
    
    
%% pre_saving_settings
  %---------------------------------------------------------------
  %          CASE PRE_SAVING_SETTINGS
  %---------------------------------------------------------------
  case 'pre_saving_settings'

    
    
%% after_load_callbacks
  %---------------------------------------------------------------
  %          CASE AFTER_LOAD_CALLBACKS
  %---------------------------------------------------------------
  case 'after_load_callbacks'
    AntibiasSection(obj, 'update', hit_history, sides_history);

    

%% close    
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


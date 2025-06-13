

function [obj] = LightChasing(varargin)

obj = class(struct, mfilename, saveload, water, antibias3way, pokesplot, ...
  soundmanager, soundui ,sessionmodel, punishui, warnDanger, comments,sqlsummary);

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
    set(value(myfig), 'Position', [200   50   1000   800]);

    % ----------
    
    %Create SoloParamHandles
    SoloParamHandle(obj, 'hit_history',   'value', []);
    SoloParamHandle(obj, 'wrong_history', 'value', []);
    SoloParamHandle(obj, 'late_history',  'value', []);
    SoloParamHandle(obj, 'sides_history', 'value', '');
    SoloParamHandle(obj, 'types_history', 'value', '');
    
    
    DeclareGlobals(obj, 'ro_args', {'hit_history', 'wrong_history', 'late_history', 'sides_history', 'types_history'});
    
    SoloFunctionAddVars('RewardsSection',   'rw_args', 'hit_history'  );
    SoloFunctionAddVars('RewardsSection',   'rw_args', 'wrong_history');
    SoloFunctionAddVars('RewardsSection',   'rw_args', 'late_history' );    
    SoloFunctionAddVars('Sides3waySection', 'rw_args', 'sides_history');

    % We use the following to generate a call that will occur after
    % any loading of data. We can use that to do any updates we may want.
    SoloParamHandle(obj, 'after_load_callbacks', 'value', []);
    set_callback(after_load_callbacks, {mfilename, 'after_load_callbacks'});
    set_callback_on_load(after_load_callbacks, 1);

    SoundManagerSection(obj, 'init');

    x = 15; y = 15;             % Initial position on main GUI window
    
    RewardsSection(obj,'init',x,y);
    
    %Leftmost column
    
%Saving
    [x, y] = SavingSection(obj, 'init', x, y); next_row(y, 0.5);
    
%WaterValveSection
    [x, y] = WaterValvesSection(obj, 'init', x, y); next_row(y, 0.5);
    
%PokesplotSection
    [x, y] = PokesPlotSection(obj, 'init', x, y, struct('states',  SMASection(obj, 'get_state_colors'))); next_row(y, 0.5);
    %CommentsSection
    [x, y] = CommentsSection(obj, 'init', x, y); next_row(y, 0.5);
    
%SessionControlSection
    SessionDefinition(obj,   'init', x, y, value(myfig));
    next_row(y, 2.5); %#ok<NASGU>
    y = y+30;
    
    figpos = get(gcf, 'Position');
    [expmtr, rname] = SavingSection(obj, 'get_info');
    HeaderParam(obj, 'prot_title', [mfilename ': ' expmtr ', ' rname], x, y, 'position', [10 figpos(4)-25, 800 20]);

  
    
    next_column(x); y=15; x = x+10;
    
    
    
%Left Middle Column (2nd Column)
    width = 150;
    height = 20;
    boostfactor = 9;
    
%Stimulus Controls
    NumeditParam(obj, 'stim_time',    10, x, y, 'position', [x y width height]); next_row(y);
    SoloFunctionAddVars('SMASection', 'ro_args', 'stim_time');
    ToggleParam(obj, 'lightstim', 1, x, y, 'position', [x y width height], 'TooltipString', ...
        sprintf('\If ON, lights will cue the correct location, if OFF, no light cue will be given.'), ...
        'OnString', 'LightStim ON', 'OffString', 'LightStim OFF'); next_row(y);
    ToggleParam(obj, 'soundstim', 1, x, y, 'position', [x y width height], 'TooltipString', ...
        sprintf('\If ON, sound will cue the correct location, if OFF, no sound cue will be given.'), ...
        'OnString', 'SoundStim ON', 'OffString', 'SoundStim OFF'); next_row(y);
    SoloFunctionAddVars('SMASection', 'ro_args', 'lightstim');
    SoloFunctionAddVars('SMASection', 'ro_args', 'soundstim');
    SubheaderParam(obj, 'LightTitle', 'Stimulus Controls', x, y, 'position', [x y width height]);
    next_row(y, 1.2); y = y + boostfactor;
    
%Delay Controls
    ToggleParam(obj, 'delay_light', 0, x, y, 'position', [x y width height], 'TooltipString', ...
      sprintf('\nIf ON, then all lights will be lit duting delay'), ...
      'OnString', 'Delay Lights ON', 'OffString', 'Delay Lights OFF'); next_row(y);
    NumeditParam(obj, 'delay_time',          1, x, y, 'position', [x y width height]); next_row(y);    
    SoloFunctionAddVars('SMASection', 'ro_args', 'delay_time');
    SoloFunctionAddVars('SMASection', 'ro_args', 'delay_light');
    SubheaderParam(obj, 'DelayLTitle', 'Delay Controls', x, y, 'position', [x y width height]);
    next_row(y); y = y + boostfactor;

%Center Pokes Before Trial
    NumeditParam(obj, 'flash_time', 0.3, x, y, 'position', [x y width height],...
      'TooltipString', sprintf('\nOn off time of light flash during center poke')); next_row(y);
    SoloFunctionAddVars('SMASection', 'ro_args', 'flash_time');
    MenuParam(obj, 'n_center_pokes', {'0', '1', '2'}, 0, x, y, 'position', [x y width height]); next_row(y);
    SubheaderParam(obj, 'CPokeTitle', 'CPoke Trial Init', x, y, 'position', [x y width height]);
    SoloFunctionAddVars('SMASection', 'ro_args', 'n_center_pokes');
    next_row(y, 1.2); y = y + boostfactor;
    
%Center Controls
    ToggleParam(obj, 'centerlight', 0, x, y, 'position', [x, y, width, height], 'TooltipString', ...
      sprintf('\nIf ON, the center light will be lit throughout the trial (starting during delay, through reward \nIf off, only stimulus lights will be lit.'), ...
      'OnString', 'Center Light ON', 'OffString', 'Center Light OFF'); next_row(y);
    SoloFunctionAddVars('SMASection', 'ro_args', 'centerlight');    
    ToggleParam(obj, 'center_punish', 0, x, y, 'position', [x y width height], 'TooltipString', ...
      sprintf('\nIf ON, then center pokes will be punished as wrong pokes, \nIf OFF, center pokes will be ignored (except to init trial).'), ...
      'OnString', 'Punish Center ON', 'OffString', 'Punish Center OFF'); next_row(y);
    SoloFunctionAddVars('SMASection', 'ro_args', 'center_punish');
    SubheaderParam(obj, 'CPTitle', 'Center Controls', x, y, 'position', [x y width height]);
    next_row(y, 1.2); y = y + boostfactor;
    
%Block Controls
    NumeditParam  (obj, 'block',     0, x, y, 'position', [x y width height]); next_row(y);
    NumeditParam  (obj, 'anti_easy', 0, x, y, 'position', [x y width height]); next_row(y);
    NumeditParam  (obj, 'pro_easy',  0, x, y, 'position', [x y width height]); next_row(y);    
    SubheaderParam(obj, 'BlocksTitle', 'Block Controls', x, y, 'position', [x y width height]);
    next_row(y, 1.2); y = y + boostfactor; %#ok<NASGU>
    
    %LeftSound
    [x, y] = SoundControls2Section(obj, 'init', 'LeftSnd', x, y, 'width', width, 'SSide', 1, 'SFreq', 1, 'SVol', 1, 'SLoop', 1, 'setside', 'Left', 'setloop', 1 );
    next_row(y); y = y + boostfactor; %#ok<NASGU>
    
    next_column(x); y = 15; x = x-40;
    

    
%Right Middle Column (Column 3)
    boostfactor = -5;

%Warn Danger At End of Trial
    [x, y] = WarnDangerInterface(obj, 'add', 'warndanger', x, y);
    WarnDangerInterface(obj, 'set', 'warndanger', 'WarnDur',   6);
    WarnDangerInterface(obj, 'set', 'warndanger', 'DangerDur', 0);
    SubheaderParam(obj, 'TEndTitle', 'Trial End Warn Danger', x, y);
    next_row(y, 2); y = y + boostfactor;   
    
%Reward Controls
    NumeditParam(obj, 'sroverlap', 0, x, y,...
      'TooltipString', sprintf('\nTime overlap of Stimulus and Reward'));
    SoloFunctionAddVars('SMASection', 'ro_args', 'sroverlap');
    next_row(y, 1);
    [x, y] = SoftPokeStayInterface(obj, 'add', 'reward', x, y);
    SoftPokeStayInterface(obj, 'set', 'reward', 'Duration', 20, 'Grace', 2.5);
    next_row(y, 0.3);
    [x, y] = SoftPokeStayInterface(obj, 'add', 'reward2', x, y);
    SoftPokeStayInterface(obj, 'set', 'reward2', 'Duration', 20, 'Grace', 2.5);
    next_row(y, 1); y = y + boostfactor;
    
%Late Punish Controls
    ToggleParam(obj, 'nolate', 0, x, y, 'TooltipString', ...
      sprintf('\nIf ON, then center is automatically set to probability 0 and the center light will also be lit'), ...
      'OnString', 'No Late Punish', 'OffString', 'Late Punish ON'); next_row(y);
    SoloFunctionAddVars('SMASection', 'ro_args', 'nolate');
    next_row(y, 0.1);        
    [x, y] = PunishInterface(obj, 'add', 'late_punish', x, y);
    PunishInterface(obj, 'set', 'late_punish', 'SoundsPanel', 0);
    next_row(y, 1); y = y + boostfactor;
    
%Wrong Punish Controls
    ToggleParam(obj, 'nowrong', 0, x, y, 'TooltipString', ...
      sprintf('\nIf ON, then center is automatically set to probability 0 and the center light will also be lit'), ...
      'OnString', 'No Wrong Punish', 'OffString', 'Wrong Punish ON'); next_row(y);
    SoloFunctionAddVars('SMASection', 'ro_args', 'nowrong');
    next_row(y, 0.1);
    [x, y] = PunishInterface(obj, 'add', 'wrong_punish', x, y);
    PunishInterface(obj, 'set', 'wrong_punish', 'SoundsPanel', 0);
    next_row(y, 1); y = y + boostfactor;
    
%Early Punish Controls
    [x, y] = WarnDangerInterface(obj, 'add', 'early_punish', x, y);
    WarnDangerInterface(obj, 'set', 'early_punish', 'WarnDur',   6);
    WarnDangerInterface(obj, 'set', 'early_punish', 'DangerDur', 0);
    next_row(y, 0.1); 
    ToggleParam(obj, 'noearly', 0, x, y, 'TooltipString', ...
      sprintf(['\nIf OFF, early poke causes warndanger state which then transitions' ...
      '\nback to the wait time before light turns on. If ON, early poke is punished.']), ...
      'OnString', 'No Early Punish', 'OffString', 'Early Punish ON'); next_row(y);
    SoloFunctionAddVars('SMASection', 'ro_args', 'noearly');
    next_row(y, 0.1);
    [x, y] = PunishInterface(obj, 'add', 'early_punish', x, y);
    PunishInterface(obj, 'set', 'early_punish', 'SoundsPanel', 0);
    next_row(y, 0.1);    
    
    next_column(x); y = 15; x = x+10;    
    
    
    
%Right Column (Column 4)
    width = 140;
    
%Antibias Section
    [x, y] = Antibias3waySection(obj, 'init', x, y);
    
    ysave = y;
    
%Sides Section
    [x, y] = Sides3waySection(obj, 'init', x, y, width);
    
%Anti Controls
    ToggleParam(obj, 'anti', 0, x, y, 'position', [x y width height], 'TooltipString', ...
      sprintf('\nIf ON, then center is automatically set to probability 0 and the opposite light is lit'), ...
      'OnString', 'Anti (Anti ON)', 'OffString', 'Pro (Anti OFF)'); next_row(y);
    SoloFunctionAddVars('SMASection', 'ro_args', 'anti');
    SubheaderParam(obj, 'AntiTitle', 'Anti Controls', x, y, 'position', [x y width height]); y = y+30; %#ok<NASGU>

%RightSound
    [x, y] = SoundControls3Section(obj, 'init', 'RightSnd', x, y, 'width', width, 'SSide', 1, 'SFreq', 1, 'SVol', 1, 'SLoop', 1, 'setside', 'Right', 'setloop', 1);
    next_row(y);
    y = ysave; x = x+150;
    
%Trial Type Sound Cue Controls
    NumeditParam(obj, 'ROverlap', 0, x, y, 'position', [x y width height], ...
      'TooltipString', sprintf('\nTime overlap of Sound Cue and Reward'));
    SoloFunctionAddVars('SMASection', 'ro_args', 'ROverlap');
    next_row(y, 1);    
    ToggleParam(obj, 'soundcue', 0, x, y, 'position', [x y width height], 'TooltipString', ...
      sprintf('\nIf ON, then a sound cue will play starting during the delay period through the reward period \nIf off, no sound will play.'), ...
      'OnString', 'Sound Cue ON', 'OffString', 'Sound Cue OFF');
    next_row(y);
    SoloFunctionAddVars('SMASection', 'ro_args', 'soundcue');
    [x, y] = SoundControlsSection(obj, 'init', 'CueSound', x, y, 'width', width, 'SVol', 1, 'SFreq', 1, 'SLoop', 1);
    next_row(y);

%Wrong Sound instead of Wrong Punish
    [x, y] = SoundControls4Section(obj, 'init', 'WrongSound', x, y, 'width', width, 'SVol', 1, 'SDur', 1);
    next_row(y);    
    
    feval(mfilename, obj, 'prepare_next_trial');

%% prepare_next_trial    
  %---------------------------------------------------------------
  %          CASE PREPARE_NEXT_TRIAL
  %---------------------------------------------------------------
  case 'prepare_next_trial'
    % feval(mfilename, 'update');

    SessionDefinition(obj, 'next_trial');

    RewardsSection(obj,  'prepare_next_trial');
    
    if (anti==1),
        Sides3waySection (obj, 'no_center');
    end;
    
    Antibias3waySection(obj, 'update');
    Sides3waySection(obj,    'prepare_next_trial');
    
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds'); %What does this do?
    
    [sma, prepare_next_trial_states] = SMASection(obj, 'prepare_next_trial');

    oldtypes = value(types_history); %#ok<NODEF>
    if ~dispatcher('is_running'), ...
      % We're not running, last side wasn't used, lop it off:
      oldtypes = oldtypes(1:end-1); 
    end;

    %Add this trial's side choice to sides_history
    if anti, types_history.value = [oldtypes 'a']; %#ok<NODEF>
    else     types_history.value = [oldtypes 'p']; %#ok<NODEF>
    end;
    
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

%% get_state_colors
	case 'get_state_colors',
		obj=SMASection(obj, 'get_state_colors');

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
     getSessID(obj);
    
%% pre_saving_settings
  %---------------------------------------------------------------
  %          CASE PRE_SAVING_SETTINGS
  %---------------------------------------------------------------
  case 'pre_saving_settings'

        SessionDefinition(obj, 'run_eod_logic_without_saving');
		
		% added by jerlich 080808
		
    pd.hit_history=value(hit_history);
    pd.wrong_history=value(wrong_history);
    pd.late_history=value(late_history);
    pd.sides_history=value(sides_history);
    pd.types_history=value(types_history);
	sendsummary(obj,'sides',pd.sides_history,'protocol_data',pd);
	sendtrial(obj);
        
        
%% after_load_callbacks
  %---------------------------------------------------------------
  %          CASE AFTER_LOAD_CALLBACKS
  %---------------------------------------------------------------
  case 'after_load_callbacks'
      if ~exist('late_history', 'var'), SoloParamHandle(obj, 'late_history',  'value', []); end;
      if ~exist('types_history', 'var'), SoloParamHandle(obj, 'types_history', 'value', ''); end;
      if length(late_history) ~= n_done_trials, late_history.value = []; end; %#ok<NODEF>
      while length(types_history) ~= length(value(sides_history)), %#ok<NODEF>
          newtypes = ('n' + value(types_history));
          types_history.value = newtypes;
      end;

    Antibias3waySection(obj, 'update');
    Sides3waySection(obj, 'update_plot');


    

%% close    
  %---------------------------------------------------------------
  %          CASE CLOSE
  %---------------------------------------------------------------
  case 'close'
    PokesPlotSection(obj, 'close');
    SessionDefinition(obj, 'delete');
    SoundControlsSection(obj, 'close');
    CommentsSection(obj, 'close');

    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), %#ok<NODEF>
      delete(value(myfig));
    end;
    delete_sphandle('owner', ['^@' class(obj) '$']);

  otherwise,
    warning('Unknown action! "%s"\n', action); %#ok<WNTAG>
end;

return;


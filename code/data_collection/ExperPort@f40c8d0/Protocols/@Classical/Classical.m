

function [obj] = Classical(varargin)

% Default object is of our own class (mfilename);

obj = class(struct, mfilename, pokesplot, saveload, sessionmodel, soundmanager, soundui, antibias, ...
  water, distribui, punishui, comments, soundtable, sqlsummary);

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
    set(value(myfig), 'Position', [485   144   850   550]);

    % ----------

    SoloParamHandle(obj, 'nsessions_healthy_number_of_pokes', 'value', 0, 'save_with_settings', 1);
    SoloParamHandle(obj, 'post_classical_protocol', 'value', '', 'save_with_settings', 1);
    SoloParamHandle(obj, 'post_classical_settings_filename', 'value', '', 'save_with_settings', 1);

    
    SoloParamHandle(obj, 'hit_history', 'value', []);
    DeclareGlobals(obj, 'ro_args', {'hit_history'});
    SoloFunctionAddVars('RewardsSection', 'rw_args', 'hit_history');
    
    
    SoundManagerSection(obj, 'init');
    
    x = 5; y = 5;             % Initial position on main GUI window

    [x, y] = SavingSection(obj,       'init', x, y); 
    [x, y] = WaterValvesSection(obj,  'init', x, y);
    
    
    
    [x, y] = PokesPlotSection(obj,    'init', x, y); next_row(y);

    [x, y] = CommentsSection(obj, 'init', x, y);
    SessionDefinition(obj,   'init', x, y, value(myfig)); next_row(y, 2); %#ok<NASGU>
    
    
    next_column(x); y = 5;
    [x, y] = StimulusSection(obj,     'init', x, y); %#ok<NASGU>
    [x, y] = DistribInterface(obj, 'add', 'PostCSTime', x, y, ...
      'Style', 'gaussian', 'Min', 10, 'Max', 50, 'Mu', 30, 'Sd', 15); %#ok<NASGU>
    SoloFunctionAddVars('SMASection', 'ro_args', 'PostCSTime');

    next_row(y, 0.7);
    [x, y] = PunishmentSection(obj, 'init', x, y); %#ok<NASGU>
    next_column(x); y=5;
    [x, y] = SidesSection(obj,        'init', x, y); %#ok<NASGU>
    
    next_column(x); y =5;
    [x, y] = RewardsSection(obj,      'init', x, y); %#ok<NASGU>
    
    figpos = get(gcf, 'Position');
    [expmtr, rname]=SavingSection(obj, 'get_info');
    HeaderParam(obj, 'prot_title', [mfilename ': ' expmtr ', ' rname], ...
      x, y, 'position', [10 figpos(4)-25, 800 20]);

    
    feval(mfilename, obj, 'prepare_next_trial');

    
  %---------------------------------------------------------------
  %          CASE PREPARE_NEXT_TRIAL
  %---------------------------------------------------------------
  case 'prepare_next_trial'
    % feval(mfilename, 'update');

    RewardsSection(obj, 'prepare_next_trial');
    SessionDefinition(obj, 'next_trial');
    DistribInterface(obj, 'get_new_sample', 'PostCSTime');
    SidesSection(obj, 'prepare_next_trial');
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
    
    nTrials.value = n_done_trials;

    [sma, prepare_next_trial_states] = SMASection(obj, 'prepare_next_trial');
    
    dispatcher('send_assembler', sma, prepare_next_trial_states);

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
  %          CASE END_SESSION
  %---------------------------------------------------------------
  case 'end_session'
     prot_title.value = [value(prot_title) ', Ended at ' datestr(now, 'HH:MM')]; %#ok<NODEF>
     
    
  %---------------------------------------------------------------
  %          CASE PRE_SAVING_SETTINGS
  %---------------------------------------------------------------
  case 'pre_saving_settings'
    if RewardsSection(obj, 'get_poked_trials') >= 60,
      nsessions_healthy_number_of_pokes.value = nsessions_healthy_number_of_pokes+1; %#ok<NODEF>
    end;

    SessionDefinition(obj, 'run_eod_logic_without_saving');
    SessionDefinition(obj, 'jump_to_stage', 1);
    
    if nsessions_healthy_number_of_pokes >= 4 && ~isempty(post_classical_protocol),
      code_dir = bSettings('get', 'GENERAL', 'Main_Code_Directory');
      data_dir = bSettings('get', 'GENERAL', 'Main_Data_Directory');

       [expname, ratname] = SavingSection(obj, 'get_info'); 
       settingsfile = [data_dir filesep 'Settings' filesep expname filesep ratname filesep,...
         value(post_classical_settings_filename)];
         
       if exist(settingsfile,'file') == 0
         settingsfile = [code_dir filesep 'Protocols' filesep '@' value(post_classical_protocol) ...
           filesep value(post_classical_settings_filename)];
       end
       
       targetfile = [data_dir filesep 'Settings' filesep expname filesep ratname filesep ...
         'settings_@' value(post_classical_protocol) '_' expname '_' ratname '_' yearmonthday(now+1) 'a.mat'];
       
       [success, message] = copyfile(settingsfile, targetfile);
       if ~success,
         CommentsSection(obj, 'append_line', ...
           sprintf('Making %s settings failed-- message was %s', ...
           value(post_classical_protocol), message));
       else
         [errid, errmsg] = add_and_commit(targetfile);
         if errid~=0,
           CommentsSection(obj, 'append_line', ...
             sprintf('Adding and committing %s settings failed-- message was %s', ...
             value(post_classical_protocol), errmsg));
         end;
       end;
    
    end;
    
    sendsummary(obj);
    
    
  %---------------------------------------------------------------
  %          CASE CLOSE
  %---------------------------------------------------------------
  case 'close'
    PokesPlotSection(obj, 'close');
    PunishmentSection(obj, 'close');
    StimulusSection(obj, 'close');
    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), %#ok<NODEF>
      delete(value(myfig));
    end;
    delete_sphandle('owner', ['^@' class(obj) '$']);

  otherwise,
    warning('Unknown action! "%s"\n', action); %#ok<WNTAG>
end;

return;


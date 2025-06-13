function [obj] = DelayedOrientation(varargin)

% Default object is of our own class (mfilename); 
% we inherit only from Plugins

obj = class(struct, mfilename, saveload, water, wateradaptor, tagger,...
    pokesplot, sessionmodel, soundmanager, soundui, punishui, ...
    distribui, clickstable, comments, sqlsummary);

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
%   'prepare_next_trial'  Called when a trial has ended and your protocol is expected
%              to produce the StateMachine diagram for the next trial;
%              i.e., somewhere in your protocol's response to this call, it
%              should call "dispatcher('send_assembler', sma,
%              prepare_next_trial_set);" where sma is the
%              StateMachineAssembler object that you have prepared and
%              prepare_next_trial_set is either a single string or a cell
%              with elements that are all strings. These strings should
%              correspond to names of states in sma.
%                 Note that after the prepare_next_trial call, further
%              events may still occur while your protocol is thinking,
%              before the new StateMachine diagram gets sent. These events
%              will be available to you when 'state0' is called on your
%              protocol (see below).
%
%   'trial_completed'   Called when the any of the prepare_next_trial set
%              of states is reached.
%
%   'close'    Called when the protocol is to be closed.
%
%
% VARIABLES THAT DISPATCHER WILL ALWAYS INSTANTIATE FOR YOU AS READ_ONLY
% GLOBALS IN YOUR PROTOCOL:
%
% n_done_trials     How many trials have been finished; when a trial reaches
%                   one of the prepare_next_trial states for the first
%                   time, this variable is incremented by 1.
%
% n_started_trials  How many trials have been started. This variable gets
%                   incremented by 1 every time the state machine goes
%                   through state 0.
%
% parsed_events     The result of running disassemble.m, with the
%                   parsed_structure flag set to 1, on all events from the
%                   start of the current trial to now.
%
% latest_parsed_events     The result of running disassemble.m, with the
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
% dispatcher.m. 
%
% 


switch action,

%% init
   case 'init'
      getSessID(obj);
      dispatcher('set_trialnum_indicator_flag');
      %   Make default figure. We remember to make it non-saveable; on next run
      %   the handle to this figure might be different, and we don't want to
      %   overwrite it when someone does load_data and some old value of the
      %   fig handle was stored as SoloParamHandle "myfig"
      SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = double(figure);

      %   Make the title of the figure be the protocol name, and if someone tries
      %   to close this figure, call dispatcher's close_protocol function, so
      %   it'll know to take it off the list of open protocols.
      set(value(myfig), 'Name', mfilename, 'Tag', mfilename, ...
         'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');

      % Ok, gotta figure out what this hack variable is doing here, why we need
      % it, and how to do without it. For now, though, if you want to use
      % SessionModel...
      hackvar = 10; SoloFunctionAddVars('SessionModel', 'ro_args', 'hackvar'); %#ok<NASGU>
      

      %   ----------------------
      %   Let's declare some globals that everybody is likely to want to know about.
      %   ----------------------
      
      %   Scalar with last trial's class
      SoloParamHandle(obj, 'trialclass',         'value', []);
      %   vector with history of trial classes:
      SoloParamHandle(obj, 'trialclass_history', 'value', []);
      %   vector with history of instructed sides:
      SoloParamHandle(obj, 'sides_history',      'value', []);
      %   vector with history of motor acts:
      SoloParamHandle(obj, 'motor_history',      'value', []);
      %   Scalar with last trial's hit or miss value
      SoloParamHandle(obj, 'hit',                'value', []);
      %   vector with jistory of hit/miss:      
      SoloParamHandle(obj, 'hit_history',        'value', []);
      %   Scalar with last trial's cpoke1 states:
      SoloParamHandle(obj, 'n_cpokes',           'value', []);
      %   Vector with history of number of cpoke states:
      SoloParamHandle(obj, 'n_cpokes_history',   'value', []);
      %   Rejected trials are those where the rat made a cviolation after at least target1 started playing   
      SoloParamHandle(obj, 'rejected_trials',    'value', []);
    
      DeclareGlobals(obj, 'ro_args', ...
         {'trialclass', 'trialclass_history', 'sides_history', 'motor_history', ...
         'hit', 'hit_history', 'n_cpokes', 'n_cpokes_history', 'rejected_trials'});

      %   Let SidesSection, the part that decides which side to run and
      %   what happened at the end of a trial, write to hit_history:
      SoloFunctionAddVars('ParseResponseSection', 'rw_args', ...
         {'trialclass', 'trialclass_history', 'sides_history', 'motor_history', ...
         'hit', 'hit_history', 'n_cpokes', 'n_cpokes_history', 'rejected_trials'});

      % From Plugins/@soundmanager:
      SoundManagerSection(obj, 'init');
    
      %   ----------------------
      %   Set up the main GUI window
      %   ----------------------
      
      %% COLUMN 1
      x = 5; y = 5; maxy=5;     % Initial position on main GUI window    
      set(value(myfig), 'Position', [75 75 916 652]);

      [x, y] = SavingSection(obj, 'init', x, y); next_row(y);
      
      [x, y] = WaterValvesSection(obj, 'init', x, y, 'streak_gui', 1); 
      
      [x, y] = WaterAdaptorSection(obj, 'init', x, y); 
      
      [x, y] = SidesSection(obj, 'init', x, y);
      
      %% COLUMN 2
      next_column(x); y = 5;
      [x, y] = NicSection(obj, 'init', x, y);

      [x, y] = ClicksTableSection(obj, 'init', x, y);
      set(ClicksTableSection(obj, 'get', 'fignum'), 'Position', [640 5 410 400]);
      ClicksTableSection(obj, 'hide');
      
      [x, y] = TrialsSection(obj, 'init', x, y);
      set(TrialsSection(obj, 'get', 'fignum'), 'Position', [1060 5 760 400]);
      TrialsSection(obj, 'hide');
      
      %% COLUMN 3
      next_column(x); y=5;
      [x, y] = PostResponseSection(obj, 'init', x, y);
      PostResponseSection(obj, 'hide');
      next_row(y);
            
      SessionDefinition(obj, 'init', x, y, gcf);
      SessionDefinition(obj, 'set_old_style_parsing_flag', 0);
      
      next_row(y); 
      [x, y] = CommentsSection(obj, 'init', x, y);
      [x, y] = PokesPlotSection(obj, 'init', x, y, ...
         struct('states',  SMASection(obj, 'state_colors')));      
      PokesPlotSection(obj, 'set_alignon', 'wait_for_cpoke1(1,2)');
      next_row(y);     

        
      %% TITLE and wrap up init:
      figpos = get(gcf, 'Position');
      [expmtr, rname]=SavingSection(obj, 'get_info');
      HeaderParam(obj, 'prot_title', [mfilename ': ' expmtr ', ' rname], ...
         x, y, 'position', [10 figpos(4)-25, 800 20]);

      
      
      SMASection(obj, 'prepare_next_trial');
      
      return;
    
    
%% prepare next trial
  case 'prepare_next_trial'     
    
     softtry(@ParseResponseSection, obj, 'parse_just_finished_trial');
     softtry(@SessionDefinition, obj, 'next_trial');
     softtry(@SidesSection, obj, 'plot_just_finished_trial'); 
     softtry(@TrialsSection, obj, 'update_posterior');
     
     softtry(@NicSection, obj, 'next_nic');
     
     push_history(trialclass); push_history(hit); push_history(n_cpokes); 
     SMASection(obj, 'prepare_next_trial');

     SavingSection(obj, 'autosave_data');

     return;

     % try
     %   push_helper_vars_tosql(obj, n_done_trials);
     % catch
     %   warning('SameDifferent:tosql', 'unable to add helper vars to sql for trial %d', n_done_trials);
     % end;

     
%% trial_completed
  case 'trial_completed'  
    feval(mfilename, 'update'); 
    PokesPlotSection(obj, 'trial_completed');

    if n_done_trials==1,
       WaterAdaptorSection(obj, 'set_first_trial_time_stamp');
       CommentsSection(obj, 'append_date');
       CommentsSection(obj, 'append_line', '');
       % We're actually running, set the protocol title to reflect the session
       [expmtr, rname]=SavingSection(obj, 'get_info');
       prot_title.value=[mfilename ' on rig ' get_hostname ' : ' expmtr ', ' rname  '.  Started at ' datestr(now, 'HH:MM')];
    end;
    CommentsSection(obj, 'clear_history'); % Make sure we're not storing unnecessary history

    
%% update
  case 'update'
    PokesPlotSection(obj, 'update');

    
%% close
  case 'close'

     SavingSection(      obj, 'close');
     WaterValvesSection( obj, 'close');
     WaterAdaptorSection(obj, 'close');
     NicSection(         obj, 'close');
     ClicksTableSection( obj, 'close');
     TrialsSection(      obj, 'close');
     PostResponseSection(obj, 'close');
     SoundManagerSection(obj, 'close');
     PokesPlotSection(   obj, 'close');
     SessionDefinition(  obj, 'delete');
     CommentsSection(    obj, 'close');

    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),  %#ok<NODEF>
      delete(value(myfig));
    end;

    try
        delete_sphandle('owner', ['^@' class(obj) '$']);
    catch ME %#ok<NASGU>
        warning('DelayedOrientation:BadClose', 'Some SoloParams were not properly cleaned up');
    end
    return;
    
    
%% end_session
  case 'end_session'
     prot_title.value = [value(prot_title) ', Ended at ' datestr(now, 'HH:MM')];  %#ok<NODEF>
     WaterAdaptorSection(obj, 'end_session_report');
     
%% pre_saving_settings
  case 'pre_saving_settings'
    SessionDefinition(obj, 'run_eod_logic_without_saving');
    sendsummary(obj, 'hits', hit_history(:)', 'sides', sides_history(:)'); %#ok<NODEF>

%% otherwise
    
  otherwise,
    warning('DelayedOrientation:BadAction', 'Unknown action! "%s"\n', action);
end;

return;



%% ------ function softtry

function [] = softtry(fhandle, obj, action)
     try fhandle(obj, action); 
     catch ME, 
        warning(ME.identifier, ['Couldn''t run %s(%s, ''%s'') -- ' ...
           'got error "%s" in file "%s", line %d\n'], ...
           char(fhandle), class(obj), action, ME.message, ME.stack(1).file, ME.stack(1).line);
        if isa(obj, 'comments')
           CommentsSection(obj, 'append_line', sprintf(['Couldn''t run %s(%s, ''%s'') -- ' ...
              'got error "%s" in file "%s", line %d\n'], ...
              char(fhandle), class(obj), action, ME.message, ME.stack(1).file, ME.stack(1).line));
           CommentsSection(obj, 'clean_lines');
        end;
     end; 


% A template protocol that does almost nothing-- each trial 
% just waits a second and then ends.
%

function [obj] = ProAntiHessam(varargin)

obj = class(struct, mfilename, pokesplot, saveload, water, ...
    soundmanager, soundui, sessionmodel, comments, sqlsummary);

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
  if length(varargin) < 2 || ~isstr(varargin{2}), 
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
%   'prepare_next_trial'  Called when a trial has ended and your protocol is expected
%              to produce the StateMachine diagram for the next trial;
%              i.e., somewhere in your protocol's response to this call, it
%              should call "dispatcher('send_assembler', sma,
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
      
    getSessID(obj);
          % Make default figure. We remember to make it non-saveable; on next run
    % the handle to this figure might be different, and we don't want to
    % overwrite it when someone does load_data and some old value of the
    % fig handle was stored as SoloParamHandle "myfig"
    SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = double(figure);

    % Make the title of the figure be the protocol name, and if someone tries
    % to close this figure, call dispatcher's close_protocol function, so it'll know
    % to take it off the list of open protocols.
    name = mfilename;
    set(value(myfig), 'Name', name, 'Tag', name, ...
      'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');


    % Ok, gotta figure out what this hack variable is doing here, why we need
    % it, and how to do without it. For now, though, if you want to use
    % SessionModel...
    hackvar = 10; SoloFunctionAddVars('SessionModel', 'ro_args', 'hackvar'); %#ok<NASGU>
    

    % At this point we have one SoloParamHandle, myfig
    % Let's put the figure where we want it and give it a reasonable size:
    set(value(myfig), 'Position', [75 75 700 450]);
    
    % ----------
    
    x = 5; y = 5;             % Initial position on main GUI window
    maxy = 5;
    
    DispParam(obj, 'nTrials', 0, x, y);
    
    next_row(y);
    
    [x, y] = PokesPlotSection(obj, 'init', x, y, ...
        struct('states',  SMASection(obj, 'state_colors'), ...
        'pokes', SMASection(obj, 'poke_colors')));
    
    [x, y] = SavingSection(obj, 'init', x, y);
    
    next_row(y);
    
    [x, y] = TimeVarsSection(obj, 'init', x, y);
    
    next_row(y);
    
    [x, y] = WaterValvesSection(obj, 'init', x, y);
    
    maxy = max(maxy, y);
    next_column(x); y = 5;
    
    SoundManagerSection(obj, 'init');
    
    [x, y] = SoundInterface(obj, 'add', 'WarningSound', x,  y);
    SoundInterface(obj, 'set', 'WarningSound', 'Vol',   0.0002);
    SoundInterface(obj, 'set', 'WarningSound', 'Vol2',  0.004);
    SoundInterface(obj, 'set', 'WarningSound', 'Dur1',  10);
    SoundInterface(obj, 'set', 'WarningSound', 'Loop',  0);
    SoundInterface(obj, 'set', 'WarningSound', 'Style', 'WhiteNoiseRamp');
    
    next_row(y);
    
    [x, y] = SoundInterface(obj, 'add', 'DangerSound',  x,  y);
    SoundInterface(obj, 'set', 'DangerSound', 'Vol',   0.004);
    SoundInterface(obj, 'set', 'DangerSound', 'Dur1',  1);
    SoundInterface(obj, 'set', 'DangerSound', 'Loop',  1);
    SoundInterface(obj, 'set', 'DangerSound', 'Style', 'WhiteNoise');
    
    next_row(y);
    
    [x, y] = TrialSection(obj, 'init', x, y);
    
    maxy = max(maxy, y);
    next_column(x); y = 5;
    
    [x, y] = SoundInterface(obj, 'add', 'LeftClicks', x,  y);
    SoundInterface(obj, 'set', 'LeftClicks', 'Vol',   0.08);
    SoundInterface(obj, 'set', 'LeftClicks', 'Dur1',  2);
    SoundInterface(obj, 'set', 'LeftClicks', 'Freq1',  10);
    SoundInterface(obj, 'set', 'LeftClicks', 'Bal',  -1);
    SoundInterface(obj, 'set', 'LeftClicks', 'Loop',  0);
    SoundInterface(obj, 'set', 'LeftClicks', 'Style', 'Bups');
    
    next_row(y);
    
    [x, y] = SoundInterface(obj, 'add', 'RightClicks', x,  y);
    SoundInterface(obj, 'set', 'RightClicks', 'Vol',   0.08);
    SoundInterface(obj, 'set', 'RightClicks', 'Dur1',  2);
    SoundInterface(obj, 'set', 'RightClicks', 'Freq1',  10);
    SoundInterface(obj, 'set', 'RightClicks', 'Bal',  1);
    SoundInterface(obj, 'set', 'RightClicks', 'Loop',  0);
    SoundInterface(obj, 'set', 'RightClicks', 'Style', 'Bups');
    
    next_row(y);
        
    [x, y] = CommentsSection(obj, 'init', x, y);
    SessionDefinition(obj, 'init', x, y, value(myfig));

    next_row(y);
    
    maxy = max(maxy, y);
    
    % Make the main figure window as wide as it needs to be and as tall as
    % it needs to be; that way, no matter what each plugin requires in terms of
    % space, we always have enough space for it.
    pos = get(value(myfig), 'Position');
    set(value(myfig), 'Position', [pos(1:2) x+240 maxy+25]);
    
    figpos = get(gcf, 'Position');
    [expmtr, rname]=SavingSection(obj, 'get_info');
    HeaderParam(obj, 'prot_title', [mfilename ': ' expmtr ', ' rname], ...
        x, y, 'position', [10 figpos(4)-25, 400 20]);
    
    SoloParamHandle(obj, 'completed_cfix', 'value', 0);
    SoloParamHandle(obj, 'cfix_history', 'value', []);
    SoloParamHandle(obj, 'prev_correct', 'value', 0);
    SoloParamHandle(obj, 'correct_history', 'value', []);
    SoloParamHandle(obj, 'prev_side', 'value', 0);
    SoloParamHandle(obj, 'side_history', 'value', []);

    
    DeclareGlobals(obj, 'ro_args', {'completed_cfix', 'cfix_history', 'prev_correct', ...
        'correct_history', 'prev_side', 'side_history'});
    
    %   Let SidesSection, the part that decides which side to run and
    %   what happened at the end of a trial, write to correct_history:
    SoloFunctionAddVars('ParseResponseSection', 'rw_args', {'completed_cfix', 'cfix_history', 'prev_correct', ...
        'correct_history', 'prev_side', 'side_history'});
    
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
    SMASection(obj, 'prepare_next_trial');
    
  %---------------------------------------------------------------
  %          CASE PREPARE_NEXT_TRIAL
  %---------------------------------------------------------------
  case 'prepare_next_trial'
    % Do any updates in the protocol that need doing:
    feval(mfilename, 'update');
    
    ParseResponseSection(obj, 'parse_just_finished_trial');
	SessionDefinition(obj, 'next_trial');
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
    TrialSection(obj, 'prepare_next_trial');
    SMASection(obj, 'prepare_next_trial');

  %---------------------------------------------------------------
  %          CASE TRIAL_COMPLETED
  %---------------------------------------------------------------
  case 'trial_completed'
    % Do any updates in the protocol that need doing:
    feval(mfilename, 'update');
    % And PokesPlot needs completing the trial:
    PokesPlotSection(obj, 'trial_completed');

    [expmtr, rname]=SavingSection(obj, 'get_info');
    prot_title.value=[mfilename ' on rig ' get_hostname ' : ' expmtr ', ' rname  '.  Started at ' datestr(now, 'HH:MM')];
  
    
  %---------------------------------------------------------------
  %          CASE UPDATE
  %---------------------------------------------------------------
  case 'update'
    if(n_done_trials > 0)
        PokesPlotSection(obj, 'update');
    end
    
    
  %---------------------------------------------------------------
  %          CASE CLOSE
  %---------------------------------------------------------------
  case 'close'
    SavingSection(obj, 'close');
    WaterValvesSection(obj, 'close');
    SoundManagerSection(obj, 'close');
    PokesPlotSection(obj, 'close');
    SessionDefinition(obj, 'delete');
    CommentsSection(obj, 'close');
    
    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),
      delete(value(myfig));
    end;
    
    delete_sphandle('owner', ['^@' class(obj) '$']);
    
    %% end_session
    case 'end_session'
        prot_title.value = [value(prot_title) ', Ended at ' datestr(now, 'HH:MM')];
        
    
    %% pre_saving_settings
    case 'pre_saving_settings'
        SessionDefinition(obj, 'run_eod_logic_without_saving');
        sendsummary(obj, 'hits', correct_history(:)', 'sides', side_history(:)');

  otherwise,
    warning('Unknown action! "%s"\n', action);
end;

return;

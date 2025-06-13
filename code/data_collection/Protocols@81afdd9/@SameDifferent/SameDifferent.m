% SameDifferent
% BWB, May 2008

function [obj] = SameDifferent(varargin)

% Default object is of our own class (mfilename); 
% we inherit only from Plugins

obj = class(struct, mfilename, saveload, water, tagger,...
    pokesplot2, sessionmodel, soundmanager, soundui, punishui, ...
    distribui, soundtable2, poissonbups, comments, sqlsummary,reinforcement);

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
    name = mfilename;
    set(value(myfig), 'Name', name, 'Tag', name, ...
      'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');


    % Ok, gotta figure out what this hack variable is doing here, why we need
    % it, and how to do without it. For now, though, if you want to use
    % SessionModel...
    hackvar = 10; SoloFunctionAddVars('SessionModel', 'ro_args', 'hackvar'); %#ok<NASGU>

    %   Put the figure where we want it and give it a reasonable size
    set(value(myfig), 'Position', [400 100   850 590]);

    %   ----------------------
    %   Let's declare some globals that everybody is likely to want to know about.
    %   ----------------------    
    
    %   History of hit/miss:
    SoloParamHandle(obj, 'hit_history',      'value', []);
    %   Scalar with last trial's cpoke1 states:
    SoloParamHandle(obj, 'n_cpoke1s',      'value', []);
    %   Vector with history of number of cpoke1 states:
    SoloParamHandle(obj, 'cpoke1_history',      'value', []);
    
    DeclareGlobals(obj, 'ro_args', {'hit_history', 'n_cpoke1s', 'cpoke1_history'});

    %   Let RewardsSection, the part that parses what happened at the end of
    %   a trial, write to hit_history:
    SoloFunctionAddVars('RewardsSection', 'rw_args', {'hit_history' 'n_cpoke1s' 'cpoke1_history'});

    % From Plugins/@soundmanager:
    SoundManagerSection(obj, 'init');
    
    
    %   ----------------------
    %   Set up the main GUI window
    %   ----------------------
    x = 5; y = 5; maxy=5;     % Initial position on main GUI window
    
    % COLUMN 1
    %   From Plugins/@saveload:
    [x, y] = SavingSection(obj, 'init', x, y);
%	SavingSection(obj,'set','save_all_data_to_sql',1);

    %   From Plugins/@water:
    [x, y] = WaterValvesSection(obj, 'init', x, y, 'streak_gui', 1);
    
    [x, y] = SidesSection(obj, 'init', x, y);
    
    maxy = max(y, maxy); next_column(x); y=5;
    
    % COLUMN 2
    [x, y] = RewardsSection(obj, 'init', x, y);
    
    maxy = max(y, maxy); next_column(x); y=5;

    % COLUMN 3 (and a little of 4, sorry) jce ~ 090507
    [x, y] = StimulusSection(obj, 'init', x, y);
    
    
    maxy = max(y, maxy); 
	
      
    % COLUMN 4
    [x, y] = PenaltySection(obj, 'init', x, y);
    
    SC = state_colors(obj);
    [x, y] = PokesPlotSection(obj, 'init', x, y, ...
      struct('states',  SC));
    PokesPlotSection(obj, 'set_alignon', 'wait_for_cpoke1(1,2)');
      
     %Make button to put this in its own window
    next_row(y);
    [nx, ny] = StimulatorSection(obj, 'init', x, y); next_row(y); 
    [nx, ny] =       MaskSection(obj, 'init', x, y); next_row(y);
    
    [x, y] = CommentsSection(obj, 'init', x, y);
    [x, y] = ReinforcementSection(obj,'init',x,y);
  
   % next_row(y);
    SessionDefinition(obj, 'init', x, y, value(myfig));
    % make the default be new style parsing:
    SessionDefinition(obj, 'set_old_style_parsing_flag', 0);
    
    %Make button to put this in its own window
    %[x, y] = StimulatorSection(obj, 'init', x, y); 

    figpos = get(gcf, 'Position');
    [expmtr, rname]=SavingSection(obj, 'get_info');
    HeaderParam(obj, 'prot_title', ['SameDifferent: ' expmtr ', ' rname], ...
            x, y, 'position', [10 figpos(4)-25, 800 20]);
    
    CpokeEODSection(obj, 'init');
    
    StateMatrixSection(obj, 'init');
    
    
%% prepare next trial
  case 'prepare_next_trial'
    nTrials.value = n_done_trials;
    
    % counting trials and hits
    violation_flg = RewardsSection(obj, 'next_trial');
	try
		push_helper_vars_tosql(obj, n_done_trials);
	catch
		warning('SameDifferent:tosql', 'unable to add helper vars to sql for trial %d', n_done_trials);
	end;

    if violation_flg,
        SidesSection(obj, 'update_trial_info');
        SidesSection(obj, 'update_plot');
		StimulusSection(obj, 'push_history');
        dispatcher('repeat_trial');
	else
		SessionDefinition(obj, 'next_trial');
    	StimulusSection(obj, 'compute_NIC');  
     	PenaltySection(obj, 'compute_ITI');
	    SidesSection(obj, 'next_trial', violation_flg);
        SidesSection(obj, 'update_plot');
        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
        StimulatorSection(obj, 'update_values');
        ReinforcementSection(obj,'prepare_next_trial');
        StateMatrixSection(obj, 'next_trial');
    end;

    % invoke autosave
    SavingSection(obj, 'autosave_data');
    % Ok, we're done calculating anything we can push the current value of
    % n_cpoke1s into its history:
    if n_done_trials > 0, push_history(n_cpoke1s); end;
    
    if n_done_trials==1
        [expmtr, rname]=SavingSection(obj, 'get_info');
        prot_title.value=['SameDifferent on rig ' get_hostname ' : ' expmtr ', ' rname  '.  Started at ' datestr(now, 'HH:MM')];
    end
    
    try send_n_done_trials(obj); end

%% trial_completed
  case 'trial_completed'  
    feval(mfilename, 'update'); 
    prev_sides=SidesSection(SameDifferent,'get_previous_sides');
    ReinforcementSection(obj,'trial_completed',prev_sides(n_done_trials),hit_history(n_done_trials));
 
    % And PokesPlot needs completing the trial:
    PokesPlotSection(obj, 'trial_completed');
   

    if n_done_trials==1,
      CommentsSection(obj, 'append_date');
      CommentsSection(obj, 'append_line', '');
    end;
    CommentsSection(obj, 'clear_history'); % Make sure we're not storing unnecessary history
    
%% update
  case 'update'
    PokesPlotSection(obj, 'update');
    RewardsSection(obj, 'update');

    
%% close
  case 'close'
    PenaltySection(obj, 'close');
    StimulusSection(obj, 'close');
    PokesPlotSection(obj, 'close');
    SessionDefinition(obj, 'delete');
    
    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), 
      delete(value(myfig));
    end;
    
    try
        delete_sphandle('owner', ['^@' class(obj) '$']);
    catch
        warning('Some SoloParams were not properly cleaned up');
    end

%% end_session
  case 'end_session'
     prot_title.value = [value(prot_title) ', Ended at ' datestr(now, 'HH:MM')]; 
     StimulusSection(obj, 'end_session');  
          
     
     
%% pre_saving_settings
  case 'pre_saving_settings'
    SessionDefinition(obj, 'run_eod_logic_without_saving');
    SidesSection(obj, 'make_and_send_summary');
    sendtrial(obj);
    
     
%% otherwise
    
  otherwise,
    warning('Unknown action! "%s"\n', action);
end;

return;



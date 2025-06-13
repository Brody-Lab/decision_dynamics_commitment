% proanti is a designed to do the proanti-task with maximum flexibility
% I'm going to go for a clean interface, with most options hidden in panels
% JCE, June 17, 2007

function [obj] = ProAnti(varargin)

% Default object is of our own class (mfilename); 
% we inherit only from Plugins

obj = class(struct, mfilename, saveload, water, antibias, pokesplot, soundmanager, soundui,sessionmodel);

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
% dispatcher.m. 
%
% 


switch action,

%%           CASE INIT    
%***********************************

  case 'init'
    
    dispatcher('set_trialnum_indicator_flag');
	  % Set the random seed to be random.  otherwise rand will generate the same sequence each time.
  
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
    hackvar = 1; SoloFunctionAddVars('SessionModel', 'ro_args', 'hackvar');

    % At this point we have one SoloParamHandle, myfig
    % Let's put the figure where we want it and give it a reasonable size:
    set(value(myfig), 'Position', [150 550   910  440 ]);

   
    % From Plugins/@soundmanager:
    SoundManagerSection(obj, 'init');
    
    x = 5; y = 5; maxy=5;             % Initial position on main GUI window

    
    % From Plugins/@saveload:
    [x, y] = SavingSection(obj, 'init', x, y);
	y=y+5;
    [x,y] = WaterValvesSection(obj, 'init', x, y, 'streak_gui',1);
      next_column(x); y=maxy;

    SessionDefinition(obj,'init',x,y, value(myfig));
	next_row(y);

    
    %next_row(y);
    SC=state_colors(obj);
    [x, y] = PokesPlotSection(obj, 'init', x, y, struct('states',  SC));

	
	[x,y]=SettingsSection(obj,'init',x,y);
   	[x,y]=PerformanceSection(obj, 'init' ,x,y);
 
    PokesPlotSection(obj, 'set_alignon', 'wait_for_poke1(1,1)');
    PokesPlotSection(obj, 'hide');
  
    
%     maxy = 700;
%     
%     % Make the main figure window as wide as it needs to be and as tall as
%     % it needs to be; that way, no matter what each plugin requires in terms of
%     % space, we always have enough space for it.
%     pos = get(value(myfig), 'Position');
%     set(value(myfig), 'Position', [pos(1:2) x+240 maxy+25]);

    figpos = get(gcf, 'Position');
    [expmtr, rname]=SavingSection(obj, 'get_info');
    HeaderParam(obj, 'prot_title', ['ProAnti: ' expmtr ', ' rname] , ...
            x, y, 'position', [10 figpos(4)-25, 600 20]);
    
    StateMatrixSection(obj, 'init');
    
    
  %---------------------------------------------------------------
%%  %          CASE PREPARE_NEXT_TRIAL
  %---------------------------------------------------------------
  case 'prepare_next_trial'
   % feval(mfilename, 'update');
   if n_done_trials==1
	   rand('twister',sum(100*clock));
    [expmtr, rname]=SavingSection(obj, 'get_info');
    prot_title.value=['ProAnti: ' expmtr ', ' rname  '.  Started at ' datestr(now, 'HH:MM')];
    
   end
    
   
   if n_done_trials>=1
    
    repeat_flag=PerformanceSection(obj, 'response_made');
	PerformanceSection(obj,'update_plot');
   else
   repeat_flag=0;
   end

	
	
	  if repeat_flag
		  dispatcher('repeat_trial')
	  else
		  
		  PerformanceSection(obj, 'next_trial');
		  SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
		  SessionDefinition(obj,'next_trial');
		  StateMatrixSection(obj, 'next_trial');
	  end
   
	   
    
  %---------------------------------------------------------------
%%  %          CASE TRIAL_COMPLETED
  %---------------------------------------------------------------
  case 'trial_completed'  
    feval(mfilename, 'update');
    
     
    % And PokesPlot needs completing the trial:
    PokesPlotSection(obj, 'trial_completed');
    PerformanceSection(obj, 'trial_completed');
    
  %---------------------------------------------------------------
%%  %          CASE UPDATE
  %---------------------------------------------------------------
  case 'update'
    PokesPlotSection(obj, 'update');
    PerformanceSection(obj, 'update');

    
%% CASE END_SESSION
	case 'end_session',
		PerformanceSection(obj, 'make_and_send_summary');
  
  
%%  %          CASE CLOSE
  case 'close'
      SettingsSection(obj,'close');
      PokesPlotSection(obj, 'close');
	  SessionDefinition(obj,'delete');
    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),
      delete(value(myfig));
    end;
    try
		
    delete_sphandle('owner', ['^@' class(obj) '$']);
    catch
        warning('Some SoloParams were not properly cleaned up');
    end
    
%---------------------------------------------------------------
%%            CASE ?????
%---------------------------------------------------------------
    
  otherwise,
    warning('Unknown action! "%s"\n', action);
end;

return;



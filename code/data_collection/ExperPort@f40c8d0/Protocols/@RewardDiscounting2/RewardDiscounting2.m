

function [obj] = RewardDiscounting2(varargin)

obj = class(struct, mfilename, saveload, water, antibias, pokesplot, ...
  soundmanager, soundui ,sessionmodel, distribui, punishui, warnDanger, ...
  comments, softpokestay2, sqlsummary);

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
%% INIT 
  case 'init'
    
    disp('Setting rand seed to sum(1e3*clock)');  
    rand('twister',sum(1e3*clock));
    
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
    set(value(myfig), 'Position', [485   144   800   625]);

    % ----------
    
    SoloParamHandle(obj, 'hit_history',       'value', []);
    SoloParamHandle(obj, 'sides_history',     'value', '');
    SoloParamHandle(obj, 'choice_history',    'value', '');
    SoloParamHandle(obj, 'nonreward_history', 'value', '');
    DeclareGlobals(obj, 'ro_args', {'hit_history', 'sides_history', 'choice_history', 'nonreward_history'});
    SoloFunctionAddVars('RewardsSection', 'rw_args', {'hit_history', 'choice_history', 'nonreward_history'});
    SoloFunctionAddVars('SidesSection',   'rw_args', {'sides_history', 'nonreward_history'});

    % We use the following to generate a call that will occur after
    % any loading of data. We can use that to do any updates we may want.
%     SoloParamHandle(obj, 'after_load_callbacks', 'value', []);
%     set_callback(after_load_callbacks, {mfilename, 'after_load_callbacks'});
%     set_callback_on_load(after_load_callbacks, 1);

    
    SoundManagerSection(obj, 'init');
    
    x = 5; y = 5;             % Initial position on main GUI window

    [x, y] = SavingSection(obj,       'init', x, y); 
    [x, y] = WaterValvesSection(obj,  'init', x, y);
    
    
    [x, y] = PokesPlotSection(obj,    'init', x, y, ...
      struct('states',  SMASection(obj, 'get_state_colors')));
    PokesPlotSection(obj,    'set_alignon','wait_for_cin1(1,2)');
    next_row(y);
    
    [x, y] = CommentsSection(obj, 'init', x, y);

    SessionDefinition(obj,   'init', x, y, value(myfig)); next_row(y, 2); %#ok<NASGU>
    next_row(y, 1.5);
        
    
    figpos = get(gcf, 'Position');
    [expmtr, rname]=SavingSection(obj, 'get_info');
    HeaderParam(obj, 'prot_title', [mfilename ': ' expmtr ', ' rname], ...
      x, y, 'position', [10 figpos(4)-25, 800 20]);


    next_column(x); y=5;
    MenuParam(obj, 'n_center_pokes', {'0', '1'}, 2, x, y, 'labelfraction', 0.7, 'position', [x y 140 20]); next_row(y, 1.5);
    
    ToggleParam(obj, 'Start_on_Left', 0, x,y, 'OnString','Start_With_Left_Poke',...
        'OffString','No_Initial_Left_Poke','position', [x y 140 20]); next_row(y, 1.5);
    
    [x, y] = DistribInterface(obj, 'add', 'left_gap', x, y);  next_row(y, 0.5);
    [x, y] = DistribInterface(obj, 'add', 'right_gap', x, y); next_row(y, 0.5);
    
    NumeditParam(obj, 'Inter_Trial_Interval', 0, x, y, 'position', [x y 140 20], 'labelfraction', 0.75); next_row(y, 1.5);
    
    ToggleParam(obj, 'Fix_Trial_Length', 0, x,y, 'OnString','Trial_Length_Fixed',...
        'OffString','Trial_Length_Variable','position', [x y 140 20]); next_row(y);
    
    ToggleParam(obj, 'Decision_Time', 0, x,y, 'OnString','First_Choice_Fix',...
        'OffString','Free_to_Change','position',[x y 140 20]);
    
    next_column(x); y = 5; x=x-50;
    
    [x, y] = SoftPokeStayInterface2(obj, 'add', 'soft_drink_left', x, y);
    SoftPokeStayInterface2(obj, 'set', 'soft_drink_left', 'Duration', 10, 'Grace', 2);
    next_row(y, 0.5);
    
    [x, y] = SoftPokeStayInterface2(obj, 'add', 'soft_drink_right', x, y);
    SoftPokeStayInterface2(obj, 'set', 'soft_drink_right', 'Duration', 10, 'Grace', 2);
    next_row(y, 0.5);
    
    [x, y] = WarnDangerInterface(obj, 'add', 'warndanger', x, y);
    WarnDangerInterface(obj, 'set', 'warndanger', 'WarnDur',   3);
    WarnDangerInterface(obj, 'set', 'warndanger', 'DangerDur', 0);
    next_row(y, 0.5);
    
    [x, y] = PunishInterface(obj, 'add', 'error_state', x, y);
    PunishInterface(obj, 'set', 'error_state', 'SoundsPanel', 0);
    next_row(y, 0.5);
    
    [x, y] = SidesSection(obj, 'init', x, y); next_row(y);
    
    NumeditParam(obj, 'No_Reward_Wait',      15, x, y, 'labelfraction', 0.7); next_row(y);
    NumeditParam(obj, 'L_Reward_Probability', 1, x, y, 'labelfraction', 0.7); next_row(y);
    NumeditParam(obj, 'R_Reward_Probability', 1, x, y, 'labelfraction', 0.7); next_row(y);
    
    RewardsSection(obj,'init',x,y);
    
    next_column(x); y=5;
    [x, y] = AnalysisSection(obj, 'init', x, y); next_row(y,1);
    
    NumeditParam(obj, 'L_Reward_Multiply', 1, x, y, 'labelfraction', 0.7); next_row(y);
    NumeditParam(obj, 'R_Reward_Multiply', 1, x, y, 'labelfraction', 0.7);
    
    SoloFunctionAddVars('SMASection',  'ro_args', {'Inter_Trial_Interval',...
                                                   'Start_on_Left',...
                                                   'n_center_pokes',...
                                                   'Fix_Trial_Length',...
                                                   'No_Reward_Wait',...
                                                   'L_Reward_Probability',...
                                                   'R_Reward_Probability',...
                                                   'Decision_Time',...
                                                   'L_Reward_Multiply',...
                                                   'R_Reward_Multiply'});
                                              
    SoloFunctionAddVars('AnalysisSection','ro_args',{'L_Reward_Multiply','R_Reward_Multiply'});
       
    feval(mfilename, obj, 'prepare_next_trial');
    

    
%% prepare_next_trial    
  %---------------------------------------------------------------
  %          CASE PREPARE_NEXT_TRIAL
  %---------------------------------------------------------------
  case 'prepare_next_trial'
    % feval(mfilename, 'update');
    
    if n_done_trials > 0; AnalysisSection(obj, 'update_trial_count'); end
    AnalysisSection(    obj, 'update_values');
    RewardsSection(     obj, 'prepare_next_trial');
    SessionDefinition(  obj, 'next_trial');
    
    SidesSection(       obj, 'prepare_next_trial');
    AnalysisSection(    obj, 'update_values');
    
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
    
    DistribInterface(obj, 'get_new_sample', 'left_gap');
    DistribInterface(obj, 'get_new_sample', 'right_gap');
    
    [sma, prepare_next_trial_states] = SMASection(obj, 'prepare_next_trial');
    
    dispatcher('send_assembler', sma, prepare_next_trial_states);

    SidesSection(obj, 'update_plot');
    
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

 		pd.sides  = value(sides_history);
        pd.choice = value(choice_history);
        pd.hit    = value(hit_history);
        
        choose_left     = get_sphandle('name','Choose_Left');
        choose_right    = get_sphandle('name','Choose_Right');
        
        free_trials     = get_sphandle('name','Free_Trials');
        forced_trials   = get_sphandle('name','Forced_Trials');
        
        multiday_free   = get_sphandle('name','MultiDay_Free');
        multiday_forced = get_sphandle('name','MultiDay_Forced');
        
        duration_ratio  = get_sphandle('name','Duration_Ratio');
        reward_ratio    = get_sphandle('name','Reward_Ratio');
        
        pd.choose_left     = cell2mat(get_history(choose_left{1}));
        pd.choose_right    = cell2mat(get_history(choose_right{1}));
        pd.free_trials     = cell2mat(get_history(free_trials{1}));
        pd.forced_trials   = cell2mat(get_history(forced_trials{1}));
        pd.multiday_free   = cell2mat(get_history(multiday_free{1}));
        pd.multiday_forced = cell2mat(get_history(multiday_forced{1}));
        pd.duration_ratio  = cell2mat(get_history(duration_ratio{1}));
        pd.reward_ratio    = cell2mat(get_history(reward_ratio{1}));
		
		fds=fieldnames(pd);
		for fi=1:numel(fds),
			pd.(fds{fi})=pd.(fds{fi})(1:n_done_trials);
        end
        
		%sendsummary(obj,'sides',sides_history(1:n_done_trials),'protocol_data',pd);
        
        SessionDefinition(obj, 'run_eod_logic_without_saving'); 
        
    
%% after_load_callbacks
  %---------------------------------------------------------------
  %          CASE AFTER_LOAD_CALLBACKS
  %---------------------------------------------------------------
  case 'after_load_callbacks'
    disp('hello');
    

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


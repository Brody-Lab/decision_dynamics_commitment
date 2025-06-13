% This protocol runs a 2AC task with the possibility of defining
% which features/side of the stim are predictive of reward.
%
% Based on PokesplotDemo.
%
% Santiago Jaramillo - August 2007

% To run it:
%  newstartup
%  dispatcher('init')
% and select this protocol.
%
% dispatcher('close_protocol'); dispatcher('set_protocol','saja_twocontexts');
%
%%% CVS version control block - do not edit manually
%%%  $Revision$
%%%  $Date$
%%%  $Source$

function [obj] = saja_twocontexts(varargin)

% Default object is of our own class (mfilename);
% We inherit from Plugins/@pokesplot and @soundmanager

%obj = class(struct, mfilename, pokesplot,soundmanager,soundui,water,saveload,sidesplot,antibias);
%obj = class(struct, mfilename, pokesplot,soundmanager,soundui,water,saveload,sidesplot);
obj = class(struct, mfilename, pokesplot,soundmanager,soundui,water,saveload,sidesplot,sessionmodel);
%obj = class(struct, mfilename, sidesplot);


USE_POKESPLOT = 1;
USE_SESSIONMODEL = 0;
SHOW_ELAPSED_TIME = 1;


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

% -- Define globals for hardware --
global sound_machine_server;
%global sound_sample_rate;

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
    set(value(myfig), 'Position', [500   400   832   620]);

    x = 5; y = 5; maxy=5;            % Initial position on main GUI window

    %%% DispParam(obj, 'nTrials', 0, x, y); next_row(y);
    
    % ----------------------  Other Sections -----------------------

    % From Plugins/@saveload:
    [x, y] = SavingSection(obj, 'init', x, y); %next_row(y);
    SavingSection(obj,'set_autosave_frequency',10);
    
    % From Plugins/@water:
    [x, y] = WaterValvesSection(obj, 'init', x, y); %next_row(y);
   
    % ----------------  Parameters for Pokesplot --------------------
    % For plotting with the pokesplot plugin, we need to tell it what
    % colors to plot with:
    if(USE_POKESPLOT)
    my_state_colors = struct( ...
        'wait_for_cpoke',        [0.5 0.5 1],   ...
        'play_cue',              [1 1 0],   ...
        'wait_for_apoke',        [0.75 0.75 1],   ...
        'reward',                [0,1,0], ...
        'extratime',                [1,0,0], ...
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
      struct('states',  my_state_colors, 'pokes', my_poke_colors));next_row(y);
    %trial_limits = 'last n';
    %ntrials = '40';
    %wait_for_apoke(1,1)',    t0.value = -4;   t1.value = 6;
    %PokesPlotSection(obj, 'hide');
    %h1=get_sphandle('owner', 'PokesPlotSection','name','ntrials')
    ThisSPH=get_sphandle('owner', mfilename, 'name','trial_limits'); ThisSPH{1}.value = 'last n'; 
    ThisSPH=get_sphandle('owner', mfilename, 'name','alignon'); ThisSPH{1}.value = 'wait_for_apoke(1,1)';
    ThisSPH=get_sphandle('owner', mfilename, 'name','t0'); ThisSPH{1}.value = -2;
    ThisSPH=get_sphandle('owner', mfilename, 'name','t1'); ThisSPH{1}.value = 3;
    end %%% if(USE_POKESPLOT)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%% COMMENTED OUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if(~1)
    end
    %%%%%%%%%%%%%%%%%%%% COMMENTED OUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    maxy = max(y, maxy); next_column(x); y = 5;

    % ------------------ Times Section ------------------
    NumeditParam(obj, 'PunishExtraTime', 4, x, y, 'TooltipString',...
                 'ITI after error trial [sec].'); next_row(y);
    NumeditParam(obj, 'PreStimMean', 0.01, x, y, 'TooltipString',...
                 'Delay before stimulus. Mean value in seconds.'); next_row(y);
    NumeditParam(obj, 'PreStimRange', 0.001, x, y, 'TooltipString',...
                 'Delay before stimulus. Max-Min value.'); next_row(y);
    NumeditParam(obj, 'RewardAvail', 3, x, y, 'TooltipString',...
                 'Time available for reward.'); next_row(y);
    SubheaderParam(obj, 'title', 'Times Section', x, y); next_row(y);
    next_row(y, 0.5);

    % ----------------------- SidesSection ----------------------
    SoloParamHandle(obj, 'MaxTrials','value',2000);
    SoloParamHandle(obj, 'RewardSideList','value',[]);
    SoloParamHandle(obj, 'DistractorList','value',[]);
    SoloFunctionAddVars('SidesSection', 'rw_args', {'MaxTrials','RewardSideList','DistractorList'});
    %%%SoloParamHandle(obj, 'WaterDelivery','value',[]);
    %%%SoloParamHandle(obj, 'RelevantSide','value',[]);
    %%% , RelevantSide, IncongruentProb
    [x, y, WaterDelivery, RelevantSide, CueEveryNtrials] = ...
        SidesSection(obj, 'init', x, y); next_row(y);

    % --- CueTrialsList: 0-NoCue  1-Cue ---
    SoloParamHandle(obj, 'CueTrialsList','value',zeros(value(MaxTrials),1));

    
    maxy = max(y, maxy); next_column(x); y = maxy-80;

    % ----------------- Early withdrawal -----------------
    MenuParam(obj, 'EarlyWithdrawal', {'do nothing' 'punish'}, 'punish', x, y,...
              'label','EarlyWithdrawal');
    next_row(y,1.5);

    
    % ------------------ Report changes ------------------
    [x, y] = ReportChangesSection(obj,'init',x,y);


    % ------------------ Sounds Section ------------------
    y = 5;
    SoloFunctionAddVars('SoundsSection', 'rw_args',...
                        {'RelevantSide'});
    [x, y] = SoundsSection(obj, 'init', x, y); next_row(y);
   
    
    % ---------------- From Plugins/@sessionmodel --------------------
    if(USE_SESSIONMODEL)
        hackvar = 10; SoloFunctionAddVars('SessionModel', 'ro_args', 'hackvar');
        SessionDefinition(obj, 'init', x,y,value(myfig));
        thisbutton = get_ghandle(get_sphandle('name','savetom'));
        set(thisbutton,'Position',get(thisbutton,'Position')+[0,-20,0,0])
    end
    
    % -------------------- From AutomationSection ------------------------
    %AutomationSession
    SoloParamHandle(obj, 'AutomationCommands', 'value', '');
    SoloFunctionAddVars('AutomationSection', 'rw_args', {'AutomationCommands'});
    [x, y] = AutomationSection(obj,'init',x,y);
    
    
    % ------------------ From Plugins/@sidesplot ------------------
    % -- Irrelevant stim (1:left 0:right) --
    IncongruentTrials = xor(value(RewardSideList)=='l',value(DistractorList));
    [x, y] = SidesPlotSection(obj, 'init', x, y, value(RewardSideList),...
                              IncongruentTrials); next_row(y);

    SoloParamHandle(obj, 'HitHistory','value', nan(value(MaxTrials),1));

    
    % ------------------ From PerformancePlotSection ------------------
    PerformancePlotSection(obj, 'init', x, y, value(MaxTrials));


    
    
    % ---------------------  Get ready for first trial ---------------------
    SoloFunctionAddVars('StateMatrixSection', 'rw_args',...
                        {'PunishExtraTime','PreStimMean','PreStimRange',...
                        'RewardAvail','WaterDelivery','RelevantSide',...
                        'EarlyWithdrawal','CueEveryNtrials','CueTrialsList',...
                        'RewardSideList','DistractorList'});

    %% Trying to execute any of these gives an error
    %% Error using ==> subsref
    %% Subscript indices must either be real positive integers or logicals.
    %feval(mfilename, 'prepare_next_trial');
    %feval(mfilename, 'update');    
    sma = StateMachineAssembler('full_trial_structure');
    sma = add_state(sma, 'name', 'final_state', ...
      'self_timer', 2, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
    dispatcher('send_assembler', sma, 'final_state');
    
    
    % Make the main figure window as wide as it needs to be and as tall as
    % it needs to be; that way, no matter what each plugin requires in terms of
    % space, we always have enough space for it.
    maxy = max(y, maxy);
    pos = get(value(myfig), 'Position');
    %set(value(myfig), 'Position', [pos(1:2) x+205 maxy+25]);

    
    
  %---------------------------------------------------------------
  %          CASE PREPARE_NEXT_TRIAL
  %---------------------------------------------------------------
  case 'prepare_next_trial'
    tic;
    feval(mfilename, 'update');

    nTrials.value = n_done_trials;
    %fprintf('n_done_trials = %d\n',n_done_trials); %%%DEBUG%%%
    %fprintf('n_started_trials = %d\n',n_started_trials); %%%DEBUG%%%

    
    % -- Automating some parameters --    
    try,
        eval(value(AutomationCommands));
    catch,
        fprintf('\n\n *** WARNING: there was an error in the automatic commands. ***\n');
        disp(lasterr); fprintf('\n\n'); %%% Using disp because sometimes lasterr is a struct        
    end
    
    
    % -- Create and send state matrix for next trial --
    StateMatrixSection(obj,'update');

    EndTimeCount = toc;
    if(SHOW_ELAPSED_TIME)
        fprintf('Elapsed Time [prepare_next_trial]: %0.6f sec\n',EndTimeCount);
    end
    
  %---------------------------------------------------------------
  %          CASE TRIAL_COMPLETED
  %---------------------------------------------------------------
  case 'trial_completed'
    tic;

    % Do any updates in the protocol that need doing:
    feval(mfilename, 'update');
    % --  PokesPlot needs completing the trial --
    if(USE_POKESPLOT)
        PokesPlotSection(obj, 'trial_completed');
    end
    
    % -- Analyze results from this trial --
    %%% Weird hack since n_done_trials starts at 0+1  (sjara 2007.08.14)
    %%% NOTE: this numbers should be in a structure explaining
    %         their meaning.
    if(value(n_done_trials)>1)
        if(~isempty(parsed_events.states.correcttrial))
            HitHistory(n_done_trials-1) = 1;   % Correct
        elseif(~isempty(parsed_events.states.errortrial)) 
            HitHistory(n_done_trials-1) = 0;   % Error
        elseif(~isempty(parsed_events.states.misstrial)) 
            HitHistory(n_done_trials-1) = -1;   % Miss
        elseif(~isempty(parsed_events.states.hittrial)) 
            HitHistory(n_done_trials-1) = 2;   % Hit
        elseif(~isempty(parsed_events.states.directtrial)) 
            HitHistory(n_done_trials-1) = 2;   % Direct    
        elseif(~isempty(parsed_events.states.timeouttrial)) 
            HitHistory(n_done_trials-1) = -1;   % TimeOut    
        else
            HitHistory(n_done_trials-1) = -1;   % Otherwise
        end        
    end
    
    %IncongruentTrials = xor(RewardSideList(1:n_done_trials)=='l',DistractorList(1:n_done_trials));
    IncongruentTrials = xor(value(RewardSideList)=='l',value(DistractorList));
    SidesPlotSection(obj, 'update', n_done_trials, value(RewardSideList),...
                     value(HitHistory),IncongruentTrials);

    % -- Performance plot. Irrelevant stim (1:left 0:right) --
    PerformancePlotSection(obj, 'update', n_done_trials-1,value(HitHistory)>0,IncongruentTrials);
    
    %fprintf('n_done_trials = %d\n',n_done_trials); %%%DEBUG%%%
    %fprintf('n_started_trials = %d\n',n_started_trials); %%%DEBUG%%%
    EndTimeCount = toc;
    if(SHOW_ELAPSED_TIME)
        fprintf('Elapsed Time [trial_completed]: %0.6f sec\n',EndTimeCount);
        fprintf('---------------- Ready for Trial #%d ----------------\n',n_done_trials);
    end

    SavingSection(obj,'autosave_data');

    % --- Show raw events from last trial ---
    %disp(raw_events);
    
    
  %---------------------------------------------------------------
  %          CASE UPDATE
  %---------------------------------------------------------------
  case 'update'
        if(USE_POKESPLOT)
            PokesPlotSection(obj, 'update');
        end
    
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


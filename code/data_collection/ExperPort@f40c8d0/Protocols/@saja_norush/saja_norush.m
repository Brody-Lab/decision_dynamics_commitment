% This protocol presents a target immersed in distractors and requires the
% animal to detect and discriminate the target.
%
% Santiago Jaramillo - 2008.04.08

% To run it:
%  flush; newstartup; dispatcher('init')
%
%  dispatcher('close_protocol'); dispatcher('set_protocol','saja_norush');
%
%%% CVS version control block - do not edit manually
%%%  $Revision$
%%%  $Date$
%%%  $Source$



%%%%%%%%%%  TO DO %%%%%%%%%%%%%
%
% - Use no-dead-time (but then you can't use sync output to recording hardware)
% - Use SYNC signal:
%   http://brodylab.princeton.edu/bcontrol/index.php/Dispatcher#Synchronizing_behavior_and_electrophysiological_recording
% - Careful with n_done_trials and trial#1 !
% - Add parameter: Time penalty early withdrawal
%
% - Move things from 'trial_completed' to 'prepare_next_trial'
% - Define reward and punish states as "prepare_next_trial states"

%%%% BUGS %%%%%
% Punish noise sound is created in SoundsSection 'init', so it won't be updated


function [obj] = saja_norush(varargin)

% Default object is of our own class (mfilename);
% We inherit from Plugins/@pluginname


%obj = class(struct, mfilename, sidesplot);
%obj = class(struct, mfilename ,soundmanager,soundui,water,saveload,sidesplot,sessionmodel);
obj = class(struct, mfilename, pokesplot,soundmanager,soundui,water,saveload,sidesplot,sessionmodel);


% -------- For DEBUG purposes ---------
USE_POKESPLOT = 1;
USE_EVENTSPLOT = 0;
SHOW_ELAPSED_TIME = 1;
% -------------------------------------


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
%global sound_machine_server;
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
    set(value(myfig), 'Position', [500   400   832   700]);

    xpos = 5; ypos = 5; maxypos=5;            % Initial position on main GUI window

    
    % --------------  Initialize Save/Load and Water ----------------

    % From Plugins/@saveload:
    [xpos, ypos] = SavingSection(obj, 'init', xpos, ypos);
    SavingSection(obj,'set_autosave_frequency',10);
    
    % From Plugins/@water:
    [xpos, ypos] = WaterValvesSection(obj, 'init', xpos, ypos);
   
    % ------------------  EventsPlotSection ----------------------
    if(USE_EVENTSPLOT)
    my_state_colors = struct( ...
        'wait_for_cpoke',         [0.5 0.5 1],   ...
        'play_target',            [1 1 0],   ...
        'play_distractors',       0.75*[1 1 0],   ...
        'show_cue',               [1 1 1],   ...
        'continue_distractors',   0.75*[1 1 0],   ...
        'posttarget_distractors', 0.75*[1 1 0],   ...
        'wait_for_apoke',         [0.75 0.75 1],   ...
        'reward',                 [0,1,0], ...
        'punish',                 [1,0,0], ...
        'state_0',                0.5*[1 1 1],       ...
        'final_state',            [0.5 0 0],     ...
        'check_next_trial_ready', [0.7 0.7 0.7]);
    my_poke_colors = struct( ...
      'L',                  0.6*[1 0.66 0],    ...
      'C',                      [0 0 0],       ...
      'R',                  0.9*[1 0.66 0]);

    SoloFunctionAddVars('EventsPlotSection', 'rw_args', ...
                        {'myfig'});    
    [xpos, ypos] = EventsPlotSection(obj, 'init', xpos, ypos, ...
      my_state_colors, my_poke_colors); next_row(ypos);
    end %%% if(USE_EVENTSPLOT)
    

    
    
    % ------------------  Initialize Pokesplot ----------------------
    % For plotting with the pokesplot plugin, we need to tell it what
    % colors to plot with:
    if(USE_POKESPLOT)
    my_state_colors = struct( ...
        'wait_for_cpoke',        [0.5 0.5 1],   ...
        'play_target',              [1 1 0],   ...
        'play_distractors',            0.75*[1 1 0],   ...
        'show_cue',              [1 1 1],   ...
        'continue_distractors',            0.75*[1 1 0],   ...
        'posttarget_distractors',      0.75*[1 1 0],   ...
        'wait_for_apoke',        [0.75 0.75 1],   ...
        'reward',                [0,1,0], ...
        'punish',                [1,0,0], ...
        'state_0',                0.5*[1 1 1],       ...
        'final_state',            [0.5 0 0],     ...
        'check_next_trial_ready', [0.7 0.7 0.7]);
    % In pokesplot, the poke colors have a default value, so we don't need
    % to specify them, but here they are so you know how to change them.
    my_poke_colors = struct( ...
      'L',                  0.6*[1 0.66 0],    ...
      'C',                      [0 0 0],       ...
      'R',                  0.9*[1 0.66 0]);
    
    [xpos, ypos] = PokesPlotSection(obj, 'init', xpos, ypos, ...
      struct('states',  my_state_colors, 'pokes', my_poke_colors));next_row(ypos);
 
    ThisSPH=get_sphandle('owner', mfilename, 'name','trial_limits'); ThisSPH{1}.value_callback = 'last n';
    ThisSPH=get_sphandle('owner', mfilename, 'name','alignon'); ThisSPH{1}.value_callback = 'play_distractors(1,1)';
    ThisSPH=get_sphandle('owner', mfilename, 'name','t0'); ThisSPH{1}.value_callback = -1.5;
    ThisSPH=get_sphandle('owner', mfilename, 'name','t1'); ThisSPH{1}.value_callback = 3.5;
    end %%% if(USE_POKESPLOT)

    maxypos = max(ypos, maxypos); next_column(xpos); ypos = 5;
        

    % ----------------- Initialize SidesSection ------------------
    SoloParamHandle(obj, 'MaxTrials','value',2000);
    SoloParamHandle(obj, 'RewardSideList','value',[]);
    RewardSideList.labels.left  = 1;
    RewardSideList.labels.right = 2;
    RewardSideList.values = nan(value(MaxTrials),1);
    SoloParamHandle(obj, 'CatchTrialsList','value',nan(value(MaxTrials),1));
    SoloParamHandle(obj, 'HitHistory','value', nan(value(MaxTrials),1));
    SoloFunctionAddVars('SidesSection', 'rw_args', ...
                        {'MaxTrials','RewardSideList','CatchTrialsList'});
    [xpos, ypos, WaterDelivery, CurrentBlock] = ...
        SidesSection(obj, 'init', xpos, ypos); next_row(ypos);
    
    % --- Spatial source modes ---
    %%% See instead CurrentBlock %%%
    %MenuParam(obj, 'SpatialSourceMode', {'none','TargetLeft','TargetRight'},...
    %          'none', xpos, ypos,...
    %          'label','SpatialSourceMode'); next_row(ypos,1.0);
    
    % --- Cue trials ---
    NumeditParam(obj, 'CueProb', 0, xpos, ypos, 'TooltipString',...
                 'Probability of presenting cue.'); next_row(ypos,1.0);
    SoloParamHandle(obj, 'CuedTrialsList','value',nan(value(MaxTrials),1));
    %MenuParam(obj, 'CueMode', {'off' 'on' 'interleaved'}, 'off', xpos, ypos,...
    %          'label','Cue Mode'); next_row(ypos,1.0);
    %set(get_ghandle(CueMode),'Enable','off');
    MenuParam(obj, 'RecMode', {'off','tuning','fix first three'}, 'off', xpos, ypos,...
              'label','Rec Mode'); next_row(ypos,1.0);

    % --- Simulate pokes ---
    MenuParam(obj, 'SimulationMode', {'off' 'on'}, 'off', xpos, ypos,...
              'label','Simulation Mode'); next_row(ypos,1.0);
    set(get_ghandle(SimulationMode),'Enable','off');

    % --- Psychometric test ---
    MenuParam(obj, 'PsychCurveMode', {'off' 'on'}, 'off', xpos, ypos,...
              'label','Psych Curve'); next_row(ypos,1.0);
    %set(get_ghandle(PsychCurveMode),'Enable','off');
   
    % ----------------- General Modes -----------------    
    SubheaderParam(obj, 'title', 'General Modes', xpos, ypos);
    next_row(ypos, 1.0);


    maxypos = max(ypos, maxypos); next_column(xpos); ypos = 5;

    % ------------------ Report changes ------------------
    [xpos, ypos] = ReportChangesSection(obj,'init', xpos, ypos);
    

    % ----------------- Initialize Times Section -----------------
    SoloParamHandle(obj, 'PreStimTime','value', nan(value(MaxTrials),1));
    NumeditParam(obj, 'RewardAvail', 3, xpos, ypos, 'TooltipString',...
                 'Time available for reward.'); next_row(ypos,1.5);
    NumeditParam(obj, 'CueToTargetDelay', 0.150, xpos, ypos, 'TooltipString',...
                 'Delay between cue and target [sec].'); next_row(ypos);
    NumeditParam(obj, 'CueDuration', 0.010, xpos, ypos, 'TooltipString',...
                 'Delay between cue and target [sec].'); next_row(ypos,1.5);
    NumeditParam(obj, 'PreStimHalfRange', 0.05, xpos, ypos, 'TooltipString',...
                 'Maximum delay before stimulus [sec].'); next_row(ypos);
    NumeditParam(obj, 'PreStimMean', 0.3, xpos, ypos, 'TooltipString',...
                 'Minimum delay before stimulus [sec].'); next_row(ypos);
    NumeditParam(obj, 'DelayToTarget', 0.150, xpos, ypos, 'TooltipString',...
                 'Time of target onset w.r.t. stimulus onset [sec].'); next_row(ypos);
    SubheaderParam(obj, 'title', 'Times Section', xpos, ypos); next_row(ypos, 1.5);

    
    % ----------------- Punishment Section -----------------
    % --- Early withdrawal ---
    %MenuParam(obj, 'EarlyWithdrawal', {'do nothing' 'punish'}, 'punish', xpos, ypos,...
    %          'label','EarlyWithdrawal'); next_row(ypos);
    NumeditParam(obj, 'ExtraTimeForEarlyWithdrawal', 1, xpos, ypos, 'TooltipString',...
                 'Punishment extra time after early withdrawal [sec].',...
                 'label','ExtraTime Early'); next_row(ypos);
    % --- Discrimination error ---   
    NumeditParam(obj, 'ExtraTimeForError', 4, xpos, ypos, 'TooltipString',...
                 'Punishment extra time after wrong port [sec].',...
                 'label','ExtraTime Error'); next_row(ypos);
    SubheaderParam(obj, 'title', 'Punishment Section', xpos, ypos); next_row(ypos, 1.5);
    
    % -------------------- From AutomationSection ------------------------
    SoloParamHandle(obj, 'AutomationCommands', 'value', '');
    SoloFunctionAddVars('AutomationSection', 'rw_args', {'AutomationCommands'});
    [xpos, ypos] = AutomationSection(obj,'init',  xpos, ypos);
    
    maxypos = max(ypos, maxypos); next_column(xpos); ypos = 5;

    
    % ------------------ Sounds Section ------------------
    y = 5;
    % --- Graphical interface ---
    NumeditParam(obj, 'PunishSoundDuration', 0.5, xpos, ypos, 'TooltipString',...
                 'Duration of punishment sound [sec].',...
                 'label','PunishSoundD'); next_row(ypos);
    set(get_ghandle(PunishSoundDuration),'Enable','off');
    NumeditParam(obj, 'StimulusDuration', 2.050, xpos, ypos, 'TooltipString',...
                 'Total duration of stimulus [sec].'); next_row(ypos);
    %set(get_ghandle(StimulusDuration),'Enable','off');
    next_row(ypos,0.5);
    MenuParam(obj, 'DistractorType', {'TonesTrain','ChordsTrain'}, 'ChordsTrain', xpos, ypos); next_row(ypos);
    MenuParam(obj, 'DistractorSource', {'binaural','monaural-random'}, 'monaural-random', xpos, ypos,...
              'label','DistractorSource'); next_row(ypos);
    NumeditParam(obj, 'DistractorVolume', 70, xpos, ypos, 'label','dB-SPL',...
                 'TooltipString',' volume [dB-SPL]','position',[xpos,ypos,100,20]);
    NumeditParam(obj, 'DistractorAttenuation', 0, xpos,ypos, 'label','Attenu',...
                 'TooltipString','Attenuation [0-1]',...
                 'position',[xpos+100,ypos,100,20]); next_row(ypos);
    set(get_ghandle(DistractorAttenuation),'Enable','off');
    NumeditParam(obj, 'DistractorGap', 0.050, xpos, ypos, 'TooltipString',...
                 'Duration of silence between distractors [sec].'); next_row(ypos);
    set(get_ghandle(DistractorGap),'Enable','off');
    NumeditParam(obj, 'DistractorDuration', 0.1, xpos, ypos, 'TooltipString',...
                 'Duration of one distractor [sec].'); next_row(ypos);
    set(get_ghandle(DistractorDuration),'Enable','off');
    next_row(ypos,0.5);
    
    MenuParam(obj, 'TargetType', {'FM','FMchord'}, 'FMchord', xpos, ypos); next_row(ypos);
    MenuParam(obj, 'TargetSource', {'binaural','left','right'}, 'binaural', xpos, ypos,...
              'label','TargetSource'); next_row(ypos);
    NumeditParam(obj, 'TargetModIndex', 0.01, xpos, ypos, 'TooltipString',...
                 'Frequency modulation index [0-1].'); next_row(ypos);
    NumeditParam(obj, 'TargetFreqR', 14000, xpos, ypos, 'TooltipString',...
                 'Center frequency of target for left reward [Hz].'); next_row(ypos);
    set(get_ghandle(TargetFreqR),'Enable','off');
    NumeditParam(obj, 'TargetFreqL', 8000, xpos, ypos, 'TooltipString',...
                 'Center frequency of target for left reward [Hz].'); next_row(ypos);
    set(get_ghandle(TargetFreqL),'Enable','off');
    NumeditParam(obj, 'TargetVolume', 70, xpos, ypos, 'label','dB-SPL',...
                 'TooltipString',' volume [dB-SPL]','position',[xpos,ypos,100,20]);
    NumeditParam(obj, 'TargetAttenuation', 0, xpos,ypos, 'label','Attenu',...
                 'TooltipString','Attenuation [0-1]',...
                 'position',[xpos+100,ypos,100,20]); next_row(ypos);
    set(get_ghandle(TargetAttenuation),'Enable','off');
    NumeditParam(obj, 'TargetDuration', 0.3, xpos, ypos, 'TooltipString',...
                 'Duration of target [sec].'); next_row(ypos);
    % --- Initialize sounds ---
    SoloFunctionAddVars('SoundsSection', 'rw_args',...
                        {'CurrentBlock','MaxTrials','PsychCurveMode',...
                        'TargetDuration','TargetVolume','TargetModIndex',...
                        'TargetFreqL','TargetFreqR','StimulusDuration',...
                        'DistractorDuration','DistractorGap','DistractorVolume',... 
                        'PunishSoundDuration','DelayToTarget','RecMode',...
                        'TargetSource','TargetType','DistractorSource','DistractorType'});
    [xpos, ypos] = SoundsSection(obj, 'init', xpos, ypos); next_row(ypos);

    
    % ------------------ From Plugins/@sidesplot ------------------
    RewardSideListLabels = 'lr';
    [xpos, ypos] = SidesPlotSection(obj, 'init', xpos, ypos, ...
                                    RewardSideListLabels(RewardSideList.values),...
                                    value(CatchTrialsList));
    next_row(ypos);
    
    
    %%%%%% TEST THIS %%%%%%%%%
    
    
    % ------------------ From PerformancePlotSection ------------------
    PerformancePlotSection(obj, 'init', xpos, ypos, value(MaxTrials),{'left','right'});

    
    % ----------------------  Prepare first trial ---------------------
    SoloFunctionAddVars('StateMatrixSection', 'rw_args',...
                        {'ExtraTimeForError','PreStimTime','PreStimMean','PreStimHalfRange',...
                        'RewardAvail','WaterDelivery','CurrentBlock',...
                        'ExtraTimeForEarlyWithdrawal',...
                        'CatchTrialsList','RewardSideList','SimulationMode',...
                        'DelayToTarget','TargetDuration','StimulusDuration',...
                        'CueToTargetDelay','CueDuration','CueProb',...
                        'TargetModIndex','CuedTrialsList','PsychCurveMode',...
                        'RecMode','TargetSource'});
    
    if(1)
    sma = StateMachineAssembler('full_trial_structure');
    sma = add_state(sma, 'name', 'final_state', ...
      'self_timer', 2, 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
    %dispatcher('send_assembler', sma, 'final_state');
    dispatcher('send_assembler', sma, 'check_next_trial_ready');
    end
    
    % Make the main figure window as wide as it needs to be and as tall as
    % it needs to be; that way, no matter what each plugin requires in terms of
    % space, we always have enough space for it.
    maxypos = max(ypos, maxypos);
    pos = get(value(myfig), 'Position');

    
  %---------------------------------------------------------------
  %          CASE PREPARE_NEXT_TRIAL
  %---------------------------------------------------------------
  case 'prepare_next_trial'
    %nTrials.value = n_done_trials;
    %fprintf('n_done_trials (prepare_next_trial) = %d\n',n_done_trials); %%%DEBUG%%%
    %fprintf('n_started_trials (prepare_next_trial) = %d\n',n_started_trials); %%%DEBUG%%%
    tic;
        
    % -- Apply anti-bias method is any --
    if(value(n_done_trials)>1)
        SidesSection(obj,'apply_antibias');
    end
    
    % -- Automating some parameters --    
    AutomationSection(obj, 'run_autocommands');
    
    % -- Create and send state matrix for next trial (includes generating sound) --
    StateMatrixSection(obj,'update');

    EndTimeCount = toc;
    if(SHOW_ELAPSED_TIME)
        fprintf('Elapsed Time [prepare_next_trial]: %0.6f sec\n',EndTimeCount);
        %fprintf('--------------- Done preparing trial #%d ---------------\n',n_done_trials+1);
    end
    
    
  %---------------------------------------------------------------
  %          CASE TRIAL_COMPLETED
  %---------------------------------------------------------------
  case 'trial_completed'
    tic;

     %fprintf('n_done_trials (trial_completed) = %d\n',n_done_trials); %%%DEBUG%%%
     %fprintf('n_started_trials (trial_completed) = %d\n',n_started_trials); %%%DEBUG%%%
    
    % --  PokesPlot needs completing the trial --
    if(USE_POKESPLOT)
        PokesPlotSection(obj, 'trial_completed');
    end
    
    if(USE_EVENTSPLOT)
        EventsPlotSection(obj,'plot_one_trial');
    end
    
    % -*-*-*-*-*-*-*-*-* THIS CAN GO ON PREPARE NEXT TRIAL -*-*-*-*-*-*-*-*%
    % -- Analyze results from this trial --
    %%% NOTE: this numbers should be in a structure explaining
    %         their meaning.
    if(n_done_trials>1)
        if(~isempty(parsed_events.states.correct_trial))
            HitHistory(n_done_trials) = 1;   % Correct
        elseif(~isempty(parsed_events.states.error_trial)) 
            HitHistory(n_done_trials) = 0;   % Error
        elseif(~isempty(parsed_events.states.error_trial_nextcorr)) 
            HitHistory(n_done_trials) = -1;   % Miss
        elseif(~isempty(parsed_events.states.correct_trial_nextcorr)) 
            HitHistory(n_done_trials) = 2;   % Hit
        elseif(~isempty(parsed_events.states.direct_trial)) 
            HitHistory(n_done_trials) = 2;   % Direct    
        elseif(~isempty(parsed_events.states.timeout_trial)) 
            HitHistory(n_done_trials) = -1;   % TimeOut    
        else
            HitHistory(n_done_trials) = -1;   % Otherwise
        end        
    end
    RewardSideListLabels = 'lr';
    SidesPlotSection(obj, 'update', n_done_trials+1, ...
                     RewardSideListLabels(RewardSideList.values),...
                     value(HitHistory),value(CatchTrialsList));

    
    %%%%%%%%%%%% CHECK n_done_trials %%%%%%%%%%%
    
    
    % -- Performance plot --
    PerformancePlotSection(obj, 'update', n_done_trials,...
                           value(HitHistory)>0,RewardSideList.values==1);
    % -*-*-*-*-*-*-*-*-* THIS CAN GO ON PREPARE NEXT TRIAL -*-*-*-*-*-*-*-*%
    
    EndTimeCount = toc;
    if(SHOW_ELAPSED_TIME)
        fprintf('Elapsed Time [trial_completed]: %0.6f sec\n',EndTimeCount);
        fprintf('------------------ Ready for trial #%d -----------------\n',n_done_trials+1);
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
    if(USE_POKESPLOT)
        PokesPlotSection(obj, 'close');
    end
    if(USE_EVENTSPLOT)
        EventsPlotSection(obj, 'close');
    end

    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),
      delete(value(myfig));
    end;
    delete_sphandle('owner', ['^@' class(obj) '$']);

  otherwise,
    warning('Unknown action! "%s"\n', action);
end;

return;

    

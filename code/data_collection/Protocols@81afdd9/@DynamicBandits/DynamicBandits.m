% Dynamic two-armed bandit task.
% KJM 6/2012


function [obj] = DynamicBandits(varargin)

obj = class(struct, mfilename, saveload, water, ...
    pokesplot2, sessionmodel, soundmanager, soundui, punishui, ...
    distribui, poissonbups2, comments, sqlsummary,warnDanger);

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
    
    %---------------------------------------------------------------
    %          CASE INIT
    %---------------------------------------------------------------
    
    case 'init'
        
        getSessID(obj); % Assigns this session an ID in the sql database so we have a place to put our data ~kjm
        dispatcher('set_trialnum_indicator_flag'); % Tells dispatcher to tell the SMA to tag each trial's states with a trial number, instead of letting them all run together ~kjm
        
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
        %   Put the figure where we want it and give it a reasonable size
        set(value(myfig), 'Position', [100 100 1050 750]);
        
        % This line is in all the old protocols 'init' sections.  I don't know
        % what it does.  I really should find out. ~kjm
        hackvar = 10; SoloFunctionAddVars('SessionModel', 'ro_args', 'hackvar'); %#ok<NASGU>
        
        
        %   ----------------------
        %   This is the part where you can declare some globals if you want to
        %   ----------------------
        SoloParamHandle(obj, 'hit_history',   'value', []);
        SoloParamHandle(obj,'firstTrial', 'value', 1);
        %   ----------------------
        %   This is the part where you initialize all the sections
        %   ----------------------
        
        % From Plugins/@soundmanager:
        SoundManagerSection(obj, 'init'); % Plays sounds - doesn't have a GUI
        
        % The rest of the sections have a GUI
        x = 5; y = 5; maxy=5;     % Initial position on main GUI window
        
        % COLUMN 1
        %   From Plugins/@saveload:
        [x, y] = SavingSection(obj, 'init', x, y);
        
        SC = state_colors(obj);
        [x, y] = PokesPlotSection(obj, 'init', x, y,  struct('states',  SC));
        PokesPlotSection(obj, 'set_alignon', 'nose_in_center(1,2)');
        next_row(y);
        [x, y] = CommentsSection(obj, 'init', x, y);
        SessionDefinition(obj, 'init', x, y, value(myfig));
        
        maxy = max(y, maxy); next_column(x); y=5;
        
        % COLUMN 2
        [x, y] = PenaltySection(obj, 'init', x,y);
        [x,y] = ParamsSection(obj,'init',x,y);
        %   From Plugins/@water:
        [x, y] = WaterValvesSection(obj, 'init', x, y);
        
        maxy = max(y, maxy); next_column(x); y=5;
        
        % COLUMN 3
        [x, y] = BanditsSection(obj, 'init', x, y);
        
        maxy = max(y, maxy); next_column(x); y=5;
        
        % COLUMN 4
        [x,y] = DriftSection(obj,'init',x,y);
        [x,y] = PerformanceSection(obj,'init',x,y);
        
        % Set up the state machine and prepare the first trial
        SmaSection(obj,'init');
        
        
        
        %---------------------------------------------------------------
        %          CASE PREPARE_NEXT_TRIAL
        %---------------------------------------------------------------
    case 'prepare_next_trial'
        
        if value(firstTrial) == 1
            BanditsSection(obj,'first_trial');
            firstTrial.value = 0;
        else
            BanditsSection(obj,'update_histories');
        end
        
      
        
        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
        
        BanditsSection(obj,'prepare_next_trial');
        SmaSection(obj,'next_trial');
        
        % This code sends nTrials and hit_history for real(ish)-time
        % monitoring using GCS
        try
            send_n_done_trials(obj);
        end
        %---------------------------------------------------------------
        %          CASE TRIAL_COMPLETED
        %---------------------------------------------------------------
    case 'trial_completed'
        
        
        PerformanceSection(obj,'next_trial');
        
        SessionDefinition(obj, 'next_trial');
        % And PokesPlot needs completing the trial:
        PokesPlotSection(obj, 'trial_completed');
        
        perf = PerformanceSection(obj,'get_all');
        hit_history.value = perf.better_choices_history;
        
        %---------------------------------------------------------------
        %          CASE UPDATE
        %---------------------------------------------------------------
    case 'update'
        PokesPlotSection(obj, 'update'); 
        
        %---------------------------------------------------------------
        %          CASE CLOSE
        %---------------------------------------------------------------
    case 'close'
        
        PenaltySection(obj, 'close');
        PokesPlotSection(obj, 'close');
        
        % Close the main figure window
        if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),
            delete(value(myfig));
        end;
        
        % Close out all the solo params, throw a warning if it doesn't work
        try
            delete_sphandle('owner', ['^@' class(obj) '$']);
        catch
            warning('Some SoloParams were not properly cleaned up');
        end
        
        %% pre_saving_settings
  case 'pre_saving_settings'
    SessionDefinition(obj, 'run_eod_logic_without_saving');
    perf_hist = PerformanceSection(obj,'get_all');
    trial_hist = BanditsSection(obj,'get_histories');
    
    M = [fieldnames(perf_hist)' fieldnames(trial_hist)'; struct2cell(perf_hist)' struct2cell(trial_hist)'];
    all_hists = struct(M{:});
    sendsummary(obj,'hits',perf_hist.reward_history,'sides',perf_hist.sides_history,'protocol_data',all_hists);
    
    sendtrial(obj);
    
  otherwise,
        warning('Unknown action! "%s"\n', action);
end;

return;


      
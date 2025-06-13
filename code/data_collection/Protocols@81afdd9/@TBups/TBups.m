% TBups protocol
% Based off PBups protocol 
function [obj] = TBups(varargin)

% Default object is of our own class (mfilename); 
% we inherit only from Plugins

obj = class(struct, mfilename, saveload, water, ...
    psychometric,  soundmanager, soundui, punishui, ...
    distribui,timebups, comments, sqlsummary, AdLibGUI);

%---------------------------------------------------------------
%   BEGIN SECTION COMMON TO ALL PROTOCOLS, DO NOT MODIFY
%---------------------------------------------------------------

% If creating an empty object, return without further ado:
if nargin==0 || (nargin==1 && ischar(varargin{1}) && strcmp(varargin{1}, 'empty'))
   return; 
end

if isa(varargin{1}, mfilename) % If first arg is an object of this class itself, we are 
                                % Most likely responding to a callback from  
                                % a SoloParamHandle defined in this mfile.
  if length(varargin) < 2 || ~ischar(varargin{2})
    error(['If called with a "%s" object as first arg, a second arg, a ' ...
      'string specifying the action, is required\n']);
  else
      action = varargin{2}; varargin = varargin(3:end); %#ok<NASGU>
  end
else % Ok, regular call with first param being the action string.
       action = varargin{1}; varargin = varargin(2:end); %#ok<NASGU>
end

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


switch action

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

    %   Put the figure where we want it and give it a reasonable size
    set(value(myfig), 'Position', [400 100 850 680]);

    %   ----------------------
    %   Let's declare some globals that everybody is likely to want to know about.
    %   ----------------------    
    SoloParamHandle(obj, 'active_curricula', 'value',...
      {'fixtorule','fixtorule_cont_stim_wean','fulltrain_v1'});
    DeclareGlobals(obj, 'ro_args', {'active_curricula'});

    %   History of hit/miss:
    SoloParamHandle(obj, 'hit_history',      'value', []);
    DeclareGlobals(obj, 'ro_args', 'hit_history');

    SoloParamHandle(obj, 'no_give_hit_history',      'value', []);
    DeclareGlobals(obj, 'ro_args', 'no_give_hit_history');	
    %   History of nose_in_center violations:
    SoloParamHandle(obj, 'violation_history', 'value', []);
    DeclareGlobals(obj, 'ro_args', 'violation_history');
      
    %   History of probe trials, 1 for probe, 0 for normal trial. Probe trials are not rewarded
    SoloParamHandle(obj, 'probe_history',      'value', []);
    DeclareGlobals(obj, 'ro_args', 'probe_history');

    % Keep a separate history of whether a trial is/should be rewarded, bc probe trials can be rewarded or not
    SoloParamHandle(obj, 'reward_history', 'value', []);
    DeclareGlobals(obj, 'ro_args', 'reward_history');

    %   History of timeouts, 1 for timeout, 0 for no timeout
    SoloParamHandle(obj, 'tup_history',      'value', []);
    DeclareGlobals(obj, 'ro_args', 'tup_history');
    %   History of timeouts, 1 for timeout, 0 for no timeout
    SoloParamHandle(obj, 'temp_err_history',      'value', []);
    DeclareGlobals(obj, 'ro_args', 'temp_err_history');
    %   Let RewardsSection, the part that parses what happened at the end of
    %   a trial, write to hit_history:
    SoloFunctionAddVars('RewardsSection', 'rw_args', {'no_give_hit_history';'hit_history'; 'violation_history'; ...
                                                      'probe_history'; 'reward_history'; 'tup_history'; 'temp_err_history'});

    % From Plugins/@soundmanager:
    SoundManagerSection(obj, 'init');
    
    %Some local variables
    SoloParamHandle(obj, 'SMA',                    'value', []);
    SoloParamHandle(obj, 'PrepareNextTrialStates', 'value', cell(0));
    SoloParamHandle(obj, 'n_prepped_trials',       'value', 0);
    
    
    %   ----------------------
    %   Set up the main GUI window
    %   ----------------------
    x = 5; y = 5; maxy=5;     % Initial position on main GUI window
    
    % COLUMN 1
    %   From Plugins/@saveload:
    [x, y] = SavingSection(obj, 'init', x, y);
    
    %   From Plugins/@water:
    [x, y] = WaterValvesSection(obj, 'init', x, y);
    
    %   From Plugins/@wateradaptor -- adapt water/hit to maximize trialnum
    [x, y] = AdLibGUISection(obj, 'init', x, y);
      
    [x, y] = SidesSection(obj, 'init', x, y);
    
    maxy = max(y, maxy); next_column(x); y=5;
    
    % COLUMN 2
    [x, y] = RewardsSection(obj, 'init', x, y);
    
    maxy = max(y, maxy); next_column(x); y=5;

    % COLUMN 3
    [x, y] = StimulusSection(obj, 'init', x, y);
    next_row(y);
    [x, y] = PenaltySection(obj, 'init', x, y);
 
    [x,y] = PsychometricSection(obj,'init',x,y);   
    
    next_row(y);
    
    [x, y] = CommentsSection(obj, 'init', x, y);
    
    maxy = max(y, maxy); next_column(x); y=5;
    
    [x, y] = TrainingSection(obj, 'init', x, y);

    figpos = get(gcf, 'Position');
    [expmtr, rname]=SavingSection(obj, 'get_info');
    HeaderParam(obj, 'prot_title', ['TBups: ' expmtr ', ' rname], ...
            x, y, 'position', [10 figpos(4)-25, 800 20]);
    
    StateMatrixSection(obj, 'init');
    
    next_row(y);      
    
    max_state_dur = MaxStateDur(obj);
    dispatcher('send_max_state_dur',max_state_dur);   
    
%% prepare next trial
  case 'prepare_next_trial'
      
    if isempty(varargin) || ~strcmp(varargin{1},'crashed')
        %We have not crashed, prepare things as normal 
        %disp(['Trial ',num2str(value(n_prepped_trials)+1),' not yet prepped. Computing new SMA...']);
        if n_done_trials==1
            AdLibGUISection(obj, 'set_first_trial_time_stamp');
        end

        % counting trials, hits, and violations
        RewardsSection(obj, 'next_trial');


        if n_done_trials>0    
            [sides, sounds] = SidesSection(obj,'get_previous_sides_and_sounds'); 
            rews = value(reward_history); 
            %send rewarded history to adlibgui, not hits
            if sides(end)=='f' 
                % AdLibGui doesn't know about 'f' trials. 
                %So for now, kludgy solution is to randomly assign last trial as r or l to iterate water volume.
                if rand(1)>0.5
                    AdLibGUISection(obj, 'update_water_volume', 'r', rews(end));
                else
                    AdLibGUISection(obj, 'update_water_volume', 'l', rews(end));
                end                
            else
                AdLibGUISection(obj, 'update_water_volume', sides(end), rews(end));
            end   
        end

        TrainingSection(obj, 'prepare_next_trial');
        SidesSection(obj, 'next_trial');
        SidesSection(obj, 'update_plot');
        PsychometricSection(obj,'update');    
        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');

        [sma, prepare_next_trial_states] = StateMatrixSection(obj, 'next_trial');

        SMA.value = sma;
        PrepareNextTrialStates.value = prepare_next_trial_states;
        n_prepped_trials.value = value(n_prepped_trials) + 1;
    elseif strcmp(varargin{1},'crashed')
        %We're here because dispatcher caught an error and crashed
        
        if value(n_prepped_trials) < value(n_started_trials)
            %Likely we have not yet prepared the next trial during this
            %trial so let's append all the variables that grow on each
            %trial and then we'll resend the same state matrix we're
            %currently running
            hit_history.value          = [hit_history(:)         ; nan];
            probe_history.value        = [probe_history(:)  ; nan];
            reward_history.value       = [reward_history(:)       ; nan];
            violation_history.value    = [violation_history(:)   ; 1];
            previous_sides.value       = [previous_sides(:)      ; 'l']; 
            previous_sounds.value      = [previous_sounds(:)     ; nan];
            previous_stims.value       = [previous_stims(:)      ; nan];

            %disp(['Trial ',num2str(value(n_prepped_trials)),' already prepped. Loading previously computed SMA...']);
            n_prepped_trials.value = value(n_prepped_trials) + 1;
            nTrials.value          = nTrials                 + 1;
        end
    end
    
    dispatcher('send_assembler', value(SMA), value(PrepareNextTrialStates));

    % invoke autosave
    SavingSection(obj, 'autosave_data');

    if n_done_trials==1
        [expmtr, rname]=SavingSection(obj, 'get_info');
        prot_title.value=['TBups - on rig ' get_hostname ' : ' expmtr ', ' rname  '.  Started at ' datestr(now, 'HH:MM')];
    end
    
    try send_n_done_trials(obj); end

%% trial_completed
  case 'trial_completed'  
    feval(mfilename, 'update'); 
      
    % And PokesPlot needs completing the trial:

    %update how much water the mouse has had
    %MouseSection(obj,'trial_completed');

    %If there's no cerebro this will do nothing but we want it to happen
    %now as the trial is ending so we don't try to push a new waveform
    %while an opto stimulus is currently happening (doing so doesn't break
    %things but the new waveform does not go through)
    %PBupsSection(obj,'send_specs_to_cerebro')
    % CerebroSection(obj,'update');

    if n_done_trials==1,
      CommentsSection(obj, 'append_date');
      CommentsSection(obj, 'append_line', '');
    end
    CommentsSection(obj, 'clear_history'); % Make sure we're not storing unnecessary history
    
%% update
  case 'update'
    RewardsSection(obj, 'update');
    
    %start crash hack
    %disp(['UPDATE:  Prepped ',   num2str(value(n_prepped_trials)),...
    %      '   Started ',num2str(value(n_started_trials)),...
    %      '   Done ',   num2str(value(n_done_trials)),...
    %      '   History ',num2str(numel(value(hit_history)))]);
    %temp = rand(1);
    %if temp < 0.02 && n_done_trials > 2 
    %if ~isempty(parsed_events.states.warning) && n_done_trials > 2 && value(last_crashed_on) < value(n_done_trials) && temp < 0.1
    %   keyboard
    %    last_crashed_on.value = value(n_started_trials);
    %    crash_state = value(CrashState);
    %    crash_state{end+1} = dispatcher(dispatcher,'get_currentstate');
    %    CrashState.value = crash_state;
    %    disp('FORCING CRASH')
    %    x=1; 
    %    disp(x(2)); 
    %end; 
    %end crash hack

%% close
  case 'close'
    AdLibGUISection(obj,'close');
    PenaltySection(obj, 'close');
    StimulusSection(obj, 'close');
    PsychometricSection(obj ,'close');
    RewardsSection(obj, 'close');
    CommentsSection(obj, 'close');
    
    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), 
      delete(value(myfig));
    end
    
    try
        delete_sphandle('owner', ['^@' class(obj) '$']);
    catch
        warning('Some SoloParams were not properly cleaned up');
    end

%% end_session
  case 'end_session'
     prot_title.value = [value(prot_title) ', Ended at ' datestr(now, 'HH:MM')]; 
     StimulusSection(obj, 'end_session');  

     TrainingSection(obj, 'end_session');
          
     
     
%% pre_saving_settings
  case 'pre_saving_settings'
    AdLibGUISection(obj,'evaluate_outcome');      
    SidesSection(obj, 'make_and_send_summary');
    sendtrial(obj);

     
%% otherwise
    
  otherwise
    warning('Unknown action! "%s"\n', action);
end

return;



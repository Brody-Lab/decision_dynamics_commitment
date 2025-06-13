% Delayed Match to Sample (DMS) protocol
%
% Copied from PWM2 (written by Jess Breda & Jorge Yanar
% in June 2022. Modifications for DMS stimuli made by Jess Breda

function [obj] = DMS(varargin)

% Default object is of our own class (mfilename);
% we inherit only from Plugins

obj = class(struct, mfilename, saveload, sessionmodel, soundmanager, soundui,...
                               antibias, water, distribui, comments,...
                               soundtable, sqlsummary, AdLibGUI, reinforcement);
%                               pokesplot2, cerebro2, multibias, f1f2plot);

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


switch action

    %---------------------------------------------------------------%
    %          init                                                 %
    %---------------------------------------------------------------%
    case 'init'

        getSessID(obj);
        dispatcher('set_trialnum_indicator_flag');

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

        hackvar = 10; SoloFunctionAddVars('SessionModel', 'ro_args', 'hackvar'); %#ok<NASGU>

        % At this point we have one SoloParamHandle, 'myfig'. Let's position the
        % figure on the screen and specify size: (x, y, width, height)
        set(value(myfig), 'Position', [400 40 850 700]);

        %----------------------------%
        % Set up the main GUI window %
        %----------------------------%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%% LEFT COLUMN %%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        x = 5; y = 5; % Initial position on main GUI window (bottom left)

        % Place Saving, Comments, and Water plugins
        [x, y] = SavingSection(obj, 'init', x, y);
        [x, y] = WaterValvesSection(obj, 'init', x, y);
        [x, y] = CommentsSection(obj, 'init', x, y);
        [x, y] = AdLibGUISection(obj, 'init', x, y);

        SessionDefinition(obj, 'init', x, y, value(myfig)); next_row(y, 2); 
        next_row(y, 1.5);

%         % Pokes Plot- commented out august 2022 because multiple SMAs
%         causing issues
%         SC = state_colors(obj);
%         [x, y] = PokesPlotSection(obj, 'init', x, y, struct('states', SC));
%         PokesPlotSection(obj, 'set_alignon', 'cpoke(1,1)');
%         PokesPlotSection(obj, 'hide');
%         next_row(y);
        
        % Section for handling information about previous trial(s)
        [x, y] = HistorySection(obj, 'init', x, y); next_row(y, 0.6);
        
        % Section for choosing if trial is L/R given antibias
        [x, y] = SideSection(obj, 'init', x, y);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%% MIDDLE COLUMN %%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        next_column(x); y = 5; % middle bottom
        % Section for manging variable growth, reward type, penalties, and fixation
        [x, y] = ShapingSection(obj, 'init', x, y); next_row(y, 1.0);

        % Section for generation of Sa and Sb stimuli 
        [x, y] = StimulusSection(obj, 'init', x, y); next_row(y, 1.1);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%% RIGHT COLUMN %%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        next_column(x); next_column(x); y = 15; % right bottom
        % Section for balancing motor & sound bias
        [x, y] = AntibiasSection(obj, 'init', x, y); next_row(y, 1.1);
        
        % Section for managing training stage & curriculum (inplace of SessionDefinition)
        [x, y] = TrainingSection(obj, 'init', x, y);
        
        [expmtr, rname] = SavingSection(obj, 'get_info'); 
        HeaderParam(obj, 'prot_title', ['DMS: ' expmtr ', ' rname], 0, 683);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% SETUP INTERNAL VARS %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%

        % tracking prepared trial in case of crash
        SoloParamHandle(obj, 'SMA_persists',                    'value', []);
        SoloParamHandle(obj, 'PrepareNextTrialStates_persists', 'value', cell(0));
        SoloParamHandle(obj, 'n_prepped_trials',                'value', 0);
        SoloParamHandle(obj, 'n_crashed_trials',                'value', 0);
        
        % Prepare the first trial
        DMS(obj, 'prepare_next_trial');
    
    %---------------------------------------------------------------%
    %          prepare_next_trial                                   %
    %---------------------------------------------------------------%
    case 'prepare_next_trial'
        
        % no crash detected, prepare trial as normal
        if isempty(varargin) || ~strcmp(varargin{1},'crashed')
            
            % Update History - what just happened?
            HistorySection(obj, 'prepare_next_trial');
            GetSoloFunctionArgs(obj); % for global history variables
            
            % Update Training - are we moving to a new stage?
            TrainingSection(obj, 'prepare_next_trial');
            
            % Update Shaping - is anything growing or changing?
            ShapingSection(obj, 'prepare_next_trial');

            % Update Adlib - how much water has animal had?
            if n_done_trials > 0
                AdLibGUISection(obj, 'update_water_volume', side_history(end), water_history(end));
            end        

            % Update Sides - is next trial a L or R?
            AntibiasSection(obj, 'update',...
                    SideSection(obj, 'get_left_prob'),...
                    hit_history,...
                    side_history);

            SideSection(obj, 'prepare_next_trial');
            GetSoloFunctionArgs(obj); % for gloabl shaping variables
        
            % Update Stimulus - given sides, what is sa/sb?
            StimulusSection(obj, 'prepare_next_trial');
            
            % Send Sounds
            SoundManagerSection(obj, 'set_not_yet_uploaded_sounds');

            % Prepare state matrix
            if strcmp(value(init_poke_type), 'cpoke_fix') || strcmp(value(init_poke_type), 'cpoke_nofix')
                [sma, prepare_next_trial_states] = SMA(obj, 'prepare_next_trial');
            elseif strcmp(value(init_poke_type), 'spoke')
                [sma, prepare_next_trial_states] = SMA_spoke(obj, 'prepare_next_trial');
            end

            % Save out prepared trial in case of a crash
            SMA_persists.value = sma;
            PrepareNextTrialStates_persists.value = prepare_next_trial_states;
            n_prepped_trials.value = value(n_prepped_trials) + 1;
            
            % Updates the "training room" webpage on Zut
            try send_n_done_trials(obj); end
       
        % catch if dispatcher/bpod crashed & clean up trial history
        elseif strcmp(varargin{1},'crashed')
            % if we crashed on a trial before preparing the next trial,
            % pack the history w/ NaNs and then resend the same SMA
            n_crashed_trials.value = value(n_crashed_trials) + 1;

            if value(n_prepped_trials) < value(n_started_trials)
                HistorySection(obj, 'crash_cleanup'); 
                n_prepped_trials.value = value(n_prepped_trials) + 1;
            end
        end

        % Send SMA
        dispatcher('send_assembler', value(SMA_persists), value(PrepareNextTrialStates_persists));

        % Autosaving & Adlib GUI stamp
        SavingSection(obj, 'autosave_data');
        if n_done_trials == 1
            [expmtr, rname]=SavingSection(obj, 'get_info');
            prot_title.value = ['DMS - on rig ' get_hostname ' : ' expmtr ', ' rname  '.  Started at ' datestr(now, 'HH:MM')];
            
            AdLibGUISection(obj, 'set_first_trial_time_stamp');
        end

    %---------------------------------------------------------------%
    %          trial_completed                                      %
    %---------------------------------------------------------------%
    case 'trial_completed'

        feval(mfilename, 'update');

% %         % And PokesPlot needs completing the trial:
%         PokesPlotSection(obj, 'trial_completed');

         % Make sure we're not storing unnecessary history
        if n_done_trials==1
            CommentsSection(obj, 'append_date');
            CommentsSection(obj, 'append_line', '');
        end
        CommentsSection(obj, 'clear_history');
    %---------------------------------------------------------------%
    %          update                                               %
    %---------------------------------------------------------------%
    case 'update'
%         % Update Pokes plot
%         PokesPlotSection(obj, 'update');
%         
    %---------------------------------------------------------------%
    %          close                                                %
    %---------------------------------------------------------------%
    case 'close'
        try AdLibGUISection(obj, 'close');
        catch warning('adlib gui didnt close');
        end
%         PokesPlotSection(obj, 'close');
        CommentsSection(obj, 'close');

        % TODO check if these fig numbers match/make sense
        if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),
            delete(value(myfig));
        end;

        if exist('myfig2', 'var') && isa(myfig2, 'SoloParamHandle') && ishandle(value(myfig2)),
            delete(value(myfig2));
        end;

        if exist('myfig3', 'var') && isa(myfig3, 'SoloParamHandle') && ishandle(value(myfig3)),
            delete(value(myfig3));
        end;

        try
            delete_sphandle('owner', ['^@' class(obj) '$']);
        catch
            warning('Some SoloParams were not properly cleaned up');
        end

    %---------------------------------------------------------------%
    %          end_session                                          %
    %---------------------------------------------------------------%
    case 'end_session'
        
        % upate stage counters and check for EOD stage transition
        TrainingSection(obj, 'end_session');
        
        % upload all variables to comments section
        HistorySection(obj, 'end_session');

        % save the EOD values for warm up growth
        ShapingSection(obj, 'end_session'); 
        
        % update title
        prot_title.value = [value(prot_title) ', Ended at ' datestr(now, 'HH:MM')];

    %---------------------------------------------------------------%
    %          pre_saving_settings                                  %
    %---------------------------------------------------------------%
    case 'pre_saving_settings'
        % save info to protocol data (pd) blob for bdata upload
        HistorySection(obj, 'make_and_send_summary');

        % save water consumption info to determine pub amount
        AdLibGUISection(obj, 'evaluate_outcome');

    %---------------------------------------------------------------%
    %          get                                                  %
    %---------------------------------------------------------------%
    case 'get'
        val=varargin{1};
        
        eval(['x=value(' val ');']);

    %---------------------------------------------------------------%
    %          otherwise                                            %
    %---------------------------------------------------------------%
    otherwise
        warning('Unknown action! "%s"\n', action);
end;

return;


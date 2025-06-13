% Delayed Match to Sample (DMS) protocol
%
% Copied from PWM2 (written by Jess Breda & Jorge Yanar
% in June 2022. Modifications for DMS stimuli made by Jess Breda

function [obj] = FixationGrower(varargin)

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
        
        % State your active curricula files. Needs to be done here so the
        % global is available during init for all the sections
        SoloParamHandle(obj, 'active_curricula', 'value',...
            {'JB_r_spoke_starter';'JB_V1_SL_GT_VE';'JB_V2_SH_GO_VL';...
            'JB_alpha_fix_experiment';'JB_cpoke_test';});
        DeclareGlobals(obj, 'ro_args', {'active_curricula'});

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

        next_column(x); next_column(x); y = 5; % right bottom

        % Debugging & Crash 
        PushbuttonParam(obj, 'clear_breakpoints', x, y, 'position', [x y 200 20], ...
            'label', 'Clear All Breakpoints');
        next_row(y,1.0);

        NumeditParam(obj, 'debug_line',115, x, y,'labelfraction',0.65,...
            'TooltipString', 'what line of file to pause in debugger',...
            'label', 'db line','position', [x y 100 20]);
        PushbuttonParam(obj, 'crash_catch_breakpoint', x, y, 'position', [x+100 y 100 20], ...
            'label', 'Crash Catch BP',...
            'TooltipString', sprintf(['\nIf BP should be set in',...
                                      '\nDispatcher/RunningSection crash handling code']));

        set_callback(clear_breakpoints, {mfilename, 'clear_breakpoints_callback'});
        set_callback(crash_catch_breakpoint, {mfilename, 'crash_catch_breakpoint_callback'});
        next_row(y,1.0);


        files = {'FixationGrower.m','@FixationGrower\HistorySection.m','@FixationGrower\ShapingSection.m',...
                  '@FixationGrower\StimulusSection.m','@FixationGrower\TrainingSection.m',...
                  'RunningSection.m','RunRats.m'}; 
        MenuParam(obj, 'debug_file', files,...
            1, x, y, 'label', 'db file','labelfraction',0.55,'position', [x y 100 20],...
            'TooltipString', 'Which file to put debug breakpoint in');
        NumeditParam(obj, 'crash_frac',0.02, x, y,'labelfraction',0.65,...
            'TooltipString', 'what fraction of trials to crash on',...
            'label', 'crash frac','position', [x+100 y 100 20]);
        next_row(y,1.0);

        %%% enter modes
        PushbuttonParam(obj, 'set_debug_breakpoint',x, y, 'position', [x y 100 20], ...
            'label', 'Set Debug BP',...
            'TooltipString', 'Set bp in specificed file & line');
        disable(set_debug_breakpoint);
        ToggleParam(obj, 'crash_mode',0, x, y, 'position', [x+100 y 100 20], ...
            'OnString', 'CRASH MODE', 'OffString', 'CRASH OFF',...
            'TooltipString', 'If on, will cause crash during update case');
        disable(crash_mode);
        next_row(y, 1.0);

        %%% toggles (don't accidently want it turned on)
        ToggleParam(obj, 'debug_toggle', 0, x, y, 'position', [x y 100 20], ...
            'OnString', 'DB ENABLED', 'OffString', 'DB DISABLED',...
            'TooltipString', 'extra protection to not accidently turn on debug');
        ToggleParam(obj, 'crash_toggle', 0, x, y, 'position', [x+100 y 100 20], ...
            'OnString', 'CR ENABLED', 'OffString', 'CR DISABLED',...
            'TooltipString', 'extra protection to not accidently turn on crash');
        next_row(y, 1.0);

        set_callback(debug_toggle, {mfilename, 'debug_toggle_callback'});
        set_callback(set_debug_breakpoint, {mfilename, 'set_debug_breakpoint_callback'});
        set_callback(crash_toggle, {mfilename, 'crash_toggle_callback'});

        %%% header
        SubheaderParam(obj,'lab1', 'Debug & Crash',x,y,'position', [x+10 y 180 20]);
        next_row(y, 1.2);

        % Section for balancing motor & sound bias
        [x, y] = AntibiasSection(obj, 'init', x, y); next_row(y, 1.1);
        
        % Section for managing training stage & curriculum (inplace of SessionDefinition)
        [x, y] = TrainingSection(obj, 'init', x, y);
        
        [expmtr, rname] = SavingSection(obj, 'get_info'); 
        HeaderParam(obj, 'prot_title', ['FixationGrower v1.0: ' expmtr ', ' rname], 0, 683);

        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% SETUP INTERNAL VARS %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%

        % tracking prepared trial in case of crash
        SoloParamHandle(obj, 'SMA_persists',                    'value', []);
        SoloParamHandle(obj, 'PrepareNextTrialStates_persists', 'value', cell(0));
        SoloParamHandle(obj, 'n_prepped_trials',                'value', 0);
        SoloParamHandle(obj, 'n_crashed_trials',                'value', 0);
        SoloParamHandle(obj, 'length_log_file_path',            'value', ' ');
        
        % Send out max state information to catch bpod freezes
        max_state_dur = MaxStateDur(obj);
        dispatcher('send_max_state_dur', max_state_dur);

        % Prepare the first trial
        FixationGrower(obj, 'prepare_next_trial');
    
    %---------------------------------------------------------------%
    %          prepare_next_trial                                   %
    %---------------------------------------------------------------%
    case 'prepare_next_trial'

        % create txt file for tracking
        if n_done_trials == 0
            FixationGrower(obj, 'create_length_log');
        end

        % no crash detected, prepare trial as normal
        if isempty(varargin) || ~strcmp(varargin{1},'crashed')
            
            % Update History - what just happened?
            HistorySection(obj, 'prepare_next_trial');
            GetSoloFunctionArgs(obj); % for global history variables
            

            % Update Adlib - how much water has animal had?
            if n_done_trials > 0
                % TODO- remove this try/catch once experport merge is 
                % completed and verified across the training room.
                try
                    AdLibGUISection(...
                        obj, 'update_water_volume_manual', side_history(end),...
                        'water_vol_uL', value(water_delivered_history(end)));
                catch ME;
                    warning('using old ablibgui update becuase of error %s', ME.message);
                    AdLibGUISection(obj, 'update_water_volume', side_history(end), water_history(end));
                end
            end        

            % Update Sides - is next trial a L or R?
            AntibiasSection(obj, 'update',...
                    SideSection(obj, 'get_left_prob'),...
                    hit_history,...
                    side_history);
            SideSection(obj, 'prepare_next_trial');
            
            % Update Shaping - is anything growing or changing?
            ShapingSection(obj, 'prepare_next_trial');
            GetSoloFunctionArgs(obj); % for gloabl shaping variables
        
            % Update Stimulus - given sides, what is sa/sb?
            StimulusSection(obj, 'prepare_next_trial');
            
            % Send Sounds
            SoundManagerSection(obj, 'set_not_yet_uploaded_sounds');
            
            % Update Training - stage switch will lag one trial, but need
            % access to sound pairs & performance
            TrainingSection(obj, 'prepare_next_trial');

            % Prepare state matrix
            if contains(value(SMA_set), 'cpoke')
                [sma, prepare_next_trial_states] = SMA_cpoke(obj, 'prepare_next_trial');
            elseif contains(value(SMA_set), 'spoke')
                [sma, prepare_next_trial_states] = SMA_spoke(obj, 'prepare_next_trial');
            elseif contains(value(SMA_set), 'habituation')
                [sma, prepare_next_trial_states] = SMA_habituation(obj, 'prepare_next_trial');
            end

            % Save out prepared trial in case of a crash
            SMA_persists.value = sma;
            PrepareNextTrialStates_persists.value = prepare_next_trial_states;
            n_prepped_trials.value = value(n_prepped_trials) + 1;
            
            % Updates the "training room" webpage on Zut
            try send_n_done_trials(obj); end
       
        % catch if dispatcher/bpod crashed & clean up trial history
        elseif strcmp(varargin{1},'crashed')

            n_crashed_trials.value = value(n_crashed_trials) + 1;

            % if we crashed on a trial before preparing the next trial,
            % we will send the same exact SMA/variables for the next trial.
            %
            % if the crash happened before HistorySection was hit, the 
            % internal variables will lag one behind the GUI variables
            % that were auto appended in the deeper code, so we need to 
            % pack them with nans and document the crash
            %
            % there are rare cases (e.g. two crashes in a row) where the
            % internal variables were already appended, so we will not
            % add to them because then they would be 1 too long.
            %
            % note an 'internal' variable here refers to a history variable
            % you track manually in your protocol, like hit_history. In this
            % protocol, that is all done in HistorySection.m. A 'GUI'
            % variable is what is displayed on each trial in your GUI and 
            % autotracked by the protocol under var_name_history and saved 
            % out as data.saved_history.

            % Here, hit_history is the internal variable reference and 
            % current_sa_history (freqeuncy of first stimulus) is the GUI
            % variable reference. this will change from protocol to protocol

            if value(n_prepped_trials) < value(n_started_trials) && ...
                    n_done_trials > 0 

                % first check to make sure that the internal variables
                % are shorter than the GUI vars and need appending. 
                                % internal                           % GUI
                if length(value(hit_history)) >= length(value(current_sa_history)) && ...
                        sum(crashed_history(end-1:end)) == 2
                    disp('crash detected, but no appending needed')
                else
                    % appened all internal non-gui history vars 
                    % note: you could do this in whatever script holds
                    % your variables, see the case for more information.
                    HistorySection(obj, 'crash_cleanup'); 
                end

                n_prepped_trials.value = value(n_prepped_trials) + 1;

            else
                % crash happened after a trial had been prepped but
                % before the start of it. The GUI variables will be
                % 1 too long here, let's fix that.
                dispatcher('pop_history'); 
            end
        end

        % make sure counters start in sync for crash handling 
        % note: this is likely not necessary given updated code above
        % and the rarity of first trial crashes
        if n_done_trials == 0
            n_prepped_trials.value = 1;
        end

        % length tracking print to terminal 
        GetSoloFunctionArgs(obj); % get the most recent history variables
        message = ['PNT:  Prepped   ',   num2str(value(n_prepped_trials)),...
        '   Started   ',num2str(value(n_started_trials)),...
        '   Done   ',   num2str(value(n_done_trials)),...
        '   Internal History   ', num2str(length(value(hit_history))),...
        '   GUI History   ' num2str(length(value(current_sa_history))),...
        '   NCrashed   ' num2str(value(n_crashed_trials)),...
        ];
        disp(message);

        % length tracking write to text file created in init
        if ispc
            f = fopen(value(length_log_file_path), 'a'); % open for writing and append to end
            fprintf(f, ['\n' message], 'char');
            fclose(f);
        end

        % Send SMA
        dispatcher('send_assembler', value(SMA_persists), value(PrepareNextTrialStates_persists));
        
        % Autosaving & Adlib GUI stamp
        SavingSection(obj, 'autosave_data');
        if n_done_trials == 1
            [expmtr, rname]=SavingSection(obj, 'get_info');
            prot_title.value = ['FixationGrower v1.0 - on rig ' get_hostname ' : ' expmtr ', ' rname  '.  Started at ' datestr(now, 'HH:MM')];
            
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

        % if crash mode, potentially cause one. Crash frac around 0.02 seems
        % to be a good starting point
        if value(crash_mode)
            if rand(1)<value(crash_frac); x=1; disp(x(2)); end
        end

    %---------------------------------------------------------------%
    %          create_length_log                                    %
    %---------------------------------------------------------------%

     case 'create_length_log'

        if ispc
            % write text file to the SoloData/Data/Experimenter/RatName folder
            solo_data_dir = bSettings('get','GENERAL','Main_Data_Directory');
            owner = ['@' class(obj)]; % e.g. @FixationGrower
    
            % fetch experimenter and rat name info
            if ~isempty(get_sphandle('name', 'LetMenu', 'owner', '@runrats'))
                % we're running in run rats get info from RR menu
                first_letter = get_sphandle('name', 'LetMenu', 'owner', '@runrats');
                rat_number = get_sphandle('name', 'NumMenu', 'owner', '@runrats');
                experimenter = get_sphandle('name', 'ExpName', 'owner', '@runrats');
    
                expmtr = value(experimenter{1});
                rname = [value(first_letter{1}), sprintf('%03i',value(rat_number{1}))];
    
            else
                % we're  running in dispatcher get info from SavingSection
                experimenter = get_sphandle('name', 'experimenter', 'owner', owner);
                rat_name = get_sphandle('name', 'ratname', 'owner', owner);
    
                expmtr = value(experimenter{1});
                rname = value(rat_name{1});
    
            end
    
            data_path = [...
                solo_data_dir filesep 'Data' filesep expmtr filesep rname filesep...
                ];
    
            % if this is a new animal, create the folder
            if ~exist(data_path, 'dir'); mkdir(data_path); end
    
            % lenlog_@protocol_experimenter_ratname_yymmdd_a.txt    
            fname = ['lenlog_' owner '_' expmtr '_' rname '_' yearmonthday 'a.txt'];
    
           % determine if 'a' is the correct suffix, and increment down the
           % alphabet as needed
            matching_files = dir(fullfile(data_path, [fname(1:end-5) '*']));
            if ~isempty(matching_files)
                new_suffix = char('a' + length(matching_files)); % e.g. a + 2 = c
                fname = [fname(1:end-5) new_suffix '.txt'];
            end
    
            % now path and names are set, open any empty txt file for this init
            file_path = [data_path fname];
            length_log_file_path.value = file_path; % need as SPH to access in PNT
            f = fopen(value(length_log_file_path), 'w');
            fprintf(f,['New File Generated ',datestr(now,'yyyy-mm-dd HH:MM:SS'),...
                ' with Internal = hit_history and GUI = current_sa_history']);
            fclose(f);
        end
    
    %---------------------------------------------------------------%
    %          debug & crash callbacks                              %
    %---------------------------------------------------------------%
    case 'debug_toggle_callback'
        if value(debug_toggle) == true
            enable(set_debug_breakpoint)
        else
            disable(set_debug_breakpoint)
        end

    case 'crash_toggle_callback'
        if value(crash_toggle) == true
            enable(crash_mode)
        else
            disable(crash_mode)
        end

    case 'set_debug_breakpoint_callback'
        dbstop(value(debug_file), num2str(value(debug_line)));
        
    case 'crash_catch_breakpoint_callback'
        % add a bp to the dispatcher trial crash catch so you can
        % step through crash steps from there (crash could be spontaneous
        % or caused by you)
        dbstop("RunningSection.m", "391");

    case 'clear_breakpoints_callback'
        dbclear all


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
        
        % upload all variables to comments section
        HistorySection(obj, 'end_session');

        % save the EOD values for warm up growth
        ShapingSection(obj, 'end_session');
        
        % upate stage counters, check for EOD stage transition and
        % implement any EOD cases (e.g. determine_tomorrows_fixation)
        TrainingSection(obj, 'end_session');
        
        % copy the length log to bucket/cup
        usebucket = bSettings('get','RIGS','use_bucket');
        if usebucket
            try 
                bucket_file_path = value(length_log_file_path);
                bucket_file_path(1) = 'X'; % replace C -> X
                copyfile(value(length_log_file_path), bucket_file_path)
            catch
                disp("Unable to copy length log to bucket, find it on C:");
            end
        end
        
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


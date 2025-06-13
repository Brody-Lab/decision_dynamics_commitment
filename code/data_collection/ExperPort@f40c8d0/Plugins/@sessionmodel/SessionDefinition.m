function [varargout] = SessionDefinition(obj, action, varargin)
% Creates the interface that allows an individual protocol to automate its
% progression. Its role is to allow the experimenter to load/save training
% and to view or edit these in a separate window that shows up as part of the
% training protocol.
% This file (SessionDefinition) in turn communicates with SessionModel, the
% engine
% which contains the logic for session automation. SessionModel stores the
% sequence of training stages, executes the active training stage at the
% end of every trial, and proceeds to the next training stage if the
% current one tests true for completion.
%
% For general documentation and use, see the Brody lab wiki page on "SessionModel".
% @SessionModel is a class located at ExperPort/HandleParam/@SessionModel/
%
% Main calls that an end-user would make:
% 
% 'init' -- SessionDefinition(obj, 'init', x, y, protocol_fig
%      Used to initialize a SessionModel object for the invoking protocol.
%      Input params are: protocol object, (action 'init'), x and y
%      coordinates for placement of GUI elements from SessionDefinition, and a
%      handle for the figure on which these GUI elements are to be placed
% 
% 
% 'run_stage_algorithm'   OR   'next_trial' -- (both strings are equivalent)
%         SessionDefinition(obj, 'run_training_stage')  OR   SessionDefinition(obj, 'next_trial')
%      Used to evaluate the stage algorithm got the currently active
%      stage, and then the completion test for the currently active stage. 
%      If completion test evaluates to true,
%      the next training stage in the sequence will be set as the active one.
%
% 'run_eod_logic'   OR   'run_eod_logic_without_saving' -- (both strings are equivalent)
%         SessionDefinition(obj, 'run_eod_logic')  OR   SessionDefinition(obj, 'run_eod_logic_without_saving')
%      Used to evaluate the EOD logic for the current training stage.
%
% 'get_current_training_stage'    Returns the number of the training stage
%            that is currently active.
%
% 'nongui_change_active_stage'   Changes the current active stage to be
%       stage number N
%          SessionDefinition(obj, 'nongui_change_active_stage', N)
%
%
% THE FOLLOWING ARE OLD, NOT MUCH USED:
% set_info -- SessionDefinition(obj,'set_info', ratname, experimenter)
%   Needed only if EOD logic is used. Provides SessionDefinition with the
%   name of the animal and experimenter for which data/settings files are
%   to be saved. Determines where these files will be saved.
%   Example: if ratname = "LittleBear", experimenter = "Goldilocks",
%   Data directory: <DISPATCHER_ROOTDIR> / SoloData / Data / Goldilocks / LittleBear/
%   Settings directory: <DISPATCHER_ROOTDIR> / SoloData / Settings / Goldilocks / LittleBear /
% eod_save -- SessionDefinition(obj,'eod_save')
%   Will execute EOD logic of the currently active stage and save the
%   resulting settings as the settings file for the **next day**. Will also
%   save the data file from the current session under the ** same day ** as
%   the session.
%   If the current stage does not have 'EOD logic' code associated with it,
%   the settings saved will be a snapshot of those when the eod_save call
%   was made (ie there will be no changes).
%   If using this option, be sure to set the ratname and experimenter using
%   the 'set_info' call (see above).
% eod_save_settinsg_only  -- SessionDefinition(obj,'eod_save_settings_only')
%    Will execute EOD logic of the currently active stage and save the
%   resulting settings as the settings file for the **next day**. Unlike
%   eod_save, will NOT save data file.

GetSoloFunctionArgs(obj);

if nargin == 5
    myfig = varargin{3};
elseif nargin > 5
    error('Maximum size of varargin is 3: x,y,fig_handle OR ratname, experimenter');
end;

switch action
    % creates the 'Session Automator window' and an instance of
    % @SessionModel for the protocol object which makes this call.
    case 'init'   % ------- CASE 'INIT' ----------
        figure(myfig);
        x=varargin{1};
        y=varargin{2};

        parentfig_x = x; parentfig_y =  y;
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);

        % We put two GUI elements in the parent protocol window:

        % 1 - A pushbutton  enabling showing/hiding of the separate 'Session Automator'
        % window.
        ToggleParam(obj, 'session_show', 0, x, y, 'label', 'Session Ctrl.','OnString','Session Ctrl Showing','OffString','Session Ctrl Hidden', 'TooltipString', 'Define training stages to be automated'); next_row(y);
        set_callback(session_show, {'SessionDefinition','hide_show'});

        % 2 - A big red button which executes EOD logic and saves
        % data/settings files
        next_row(y);
        PushbuttonParam(obj,'savetom', x, y,'label','SAVE DATA & SETTINGS'); next_row(y);
        set(get_ghandle(savetom),'BackgroundColor', 'r','FontSize',14);
        set_callback(savetom, {'SessionDefinition','eod_save'});

        % store the ratname and experimenter to be able to correctly save
        % settings/datafiles
        SoloParamHandle(obj, 'ratname',   'value', 'ratname');
        SoloParamHandle(obj, 'experimenter',   'value', 'experimenter');


        % counters that were put here before training stages had capacity
        % to have temporary variables.
        SoloParamHandle(obj, 'nopoke_trials',   'value', 0);
        SoloParamHandle(obj, 'poke_trials',     'value', 0);
        SoloParamHandle(obj, 'good_streak',     'value', 0);
        SoloParamHandle(obj, 'reminder_starts', 'value', []);

        % Create 'Session Automator' window
        SoloParamHandle(obj, 'sessionfig', 'value', double(figure), 'saveable', 0);
        x = 5; y = 5;   % coordinates for popup window
        set(value(sessionfig), 'Position', [3 100 670 420], 'closerequestfcn', [mfilename '(' class(obj) ', ''hide'');'], 'Menubar', 'none', 'Toolbar', 'none','Name', 'Session Automator');

        % buttons to reinitialize the GUI and to save/load using files
        PushbuttonParam(obj, 'reinit', 200, 3, 'position', [570 10 60 20]);
        set_callback(reinit, {'SessionDefinition', 'reinit'});

        % buttons to test the current training string and to save/load using files
        PushbuttonParam(obj, 'Test', 200, 3, 'position', [570 35 60 20]);
        set_tooltipstring(Test,sprintf(['Use this button to test your ACTIVE stage algorithm.\n'...
            'This button is the equivalent of typing: SessionDefinition(@protobj, ''next_trial'').  \n'...
            'If you have multiple Stages, make each one active and then press '...
            'this button and look for errors on the command line.\n'...
            'NOTE: This will not test code in "if" statements that are not \n'...
            'evaluated based on the current variables.  Also, this will not work unless\n'...
            'n_done_trials>1']));
        set_callback(Test, {'SessionDefinition', 'next_trial'});

        % Top Left-hand side:
        % Show all SoloParamHandles (SPH) belonging to the protocol object
        % to which SessionDefinition has access. This access is important because
        % SessionDefinition (and SessionModel) will change the values for SPHs during session
        % progress. This dialog box is present for easy reference during inline editing.
        % The format of variable names is funcname_varname.
        % e.g. To refer to "GODur", a variable of the .m file "ChordSection.m", you would
        % type "ChordSection_GODur"

        SubheaderParam(obj,'paramblock','',0,0);
        set(get_ghandle(paramblock), 'Position',[9 250 255 165],'BackgroundColor',[153/255 153/255 155/255]);

        SubheaderParam(obj, 'var_hdr', 'Parameters', 0, 0);
        set(get_ghandle(var_hdr), 'Position', [25 390 200 20],'BackgroundColor',[176/255 217/255 230/255]);
        ListboxParam(obj, 'var_names', GetSoloFunctionArgList(['@' class(obj)], 'SessionModel'), 1, x, y, ...
            'position', [12 260 248 120]);
        set(get_ghandle(var_names), 'BackgroundColor', 'w');

        % Top Right-hand side:
        % Display sequence of training stages
        SubheaderParam(obj,'listblock','',0,0);
        set(get_ghandle(listblock), 'Position',[275 225 380 190],'BackgroundColor',[153/255 153/255 155/255]);
        SubheaderParam(obj, 'list_hdr', 'Training Stages', 0, 0);
        set(get_ghandle(list_hdr), 'Position', [290 390 350 20], 'FontSize', 9,'BackgroundColor',[176/255 217/255 230/255]);

        % Load/Save training stages defined in files
        PushbuttonParam(obj, 'Load', 350, 10, 'position', ...
            [330, 365, 100, 20], 'label', 'LOAD from file');
        set_callback(Load, {mfilename, 'insert_from_file'});
        PushbuttonParam(obj, 'Save', 480, 10, 'position', ...
            [470, 365, 100, 20], 'label', 'SAVE to file');
        set_callback(Save, {mfilename, 'save_to_file'});
        next_row(y, 0.5);

        % Listbox of training stages
        ListboxParam(obj, 'train_list', {'#1', '#2', '#3'}, 1, 0, 0);
        set(get_ghandle(train_list), 'Position', [290 260 350 100], ...
            'FontSize', 9);
        set_callback(train_list, {mfilename, 'train_list'});


        % Buttons allowing addition/removal/update/flushing of training
        % stages
        btnX = 280; btnY = 230;
        PushbuttonParam(obj, 'add_string', 0, 0, 'label', '+');
        set(get_ghandle(add_string), 'Position', [btnX btnY 40 20], 'FontSize', 10); %, 'BackgroundColor', [0.8 0 0], 'ForegroundColor', 'k');
        set_callback(add_string, {'SessionDefinition', 'add'}); btnX = btnX+50;

        PushbuttonParam(obj, 'update_string', 0, 0, 'label', 'U');
        set(get_ghandle(update_string), 'Position', [btnX btnY 40 20], 'FontSize', 10); %, 'BackgroundColor', [0.8 0 0.2], 'ForegroundColor', 'w');
        set_callback(update_string, {'SessionDefinition', 'test_update'}); btnX = btnX+50;

        PushbuttonParam(obj, 'delete_string', 0, 0, 'label', '-');
        set(get_ghandle(delete_string), 'Position', [btnX btnY 40 20], 'FontSize', 10); %, 'BackgroundColor', [0.8 0 0.2], 'ForegroundColor', 'w');
        set_callback(delete_string, {'SessionDefinition', 'delete_stage'});btnX = btnX+50;

        PushbuttonParam(obj, 'flush_string', 0, 0, 'label', 'FLUSH');
        set(get_ghandle(flush_string), 'Position', [btnX btnY 60 20], 'FontSize', 10); % 'BackgroundColor', [0.8 0 0.2], 'ForegroundColor', 'w');
        set_callback(flush_string, {'SessionDefinition', 'flush_all'}); btnX = btnX+70;

        PushbuttonParam(obj, 'change_active_stage', 0, 0, 'label', ...
            'Change Active Stage');
        set(get_ghandle(change_active_stage), 'Position', [btnX btnY 140 20],...
            'FontSize', 10);
        set_callback(change_active_stage, ...
            {'SessionDefinition', 'change_active_stage'});


        % Center left:
        % Textbox which tells you which training stage and which aspect of
        % it is currently being shown in the textbox below
        % e.g. Showing: Stage #29: Stage algorithm
        TextBoxParam(obj, 'train_string_display', '', 20, 10, 'labelpos', 'top', 'nlines', 20, 'label', '***');
        set(get_ghandle(train_string_display), 'Position', [10 70 600 150], 'HorizontalAlignment', 'left');
        set(get_lhandle(train_string_display), 'Position', [10 220 200 20],'FontSize',10);


        %        set_callback(train_string_display,{'SessionDefinition','text_changed'});
        % Bottom panel: Buttons which allow view/edit of specific component
        % of a stage selected in top-right corner

        % light-blue header
        SubheaderParam(obj, 'btnbk_hdr','', 0,0);
        set(get_ghandle(btnbk_hdr), 'Position', [30 5 500 60],'BackgroundColor',[153/255 153/255 155/255]);
        SubheaderParam(obj, 'subparam_hdr', sprintf('Stage-specific\nComponents'), 0, 0);
        set(get_ghandle(subparam_hdr), 'Position', [35 30 100 30],'FontSize',10,'BackgroundColor',[176/255 217/255 230/255]);

        ToggleParam(obj, 'old_style_parsing_flag', 1, 0, 0, 'position', [35 7 100 20], ...
          'OnString', 'old-style parsing', 'OffString', 'new-style parsing', ...
          'TooltipString', sprintf(['\nnew-style parsing is aware that each line in the Stage Algorithm, Completion Test, and ' ...
          '\nEnd-of-Day Logic strings is a separate line. Lines whose first non-space' ...
          '\ncharacter is the per cent sign are taken to be comments and are ignored. To complete a ' ...
          '\nstatement across more than one line, use ellipses "..." as in Matlab syntax.' ...
          '\n.     In contrast, old-style parsing, which is the default and is kept here for backwards ' ...
          '\ncompatibility, turns the Stage Algorithm, Completion Test, and End-of-Day Logic strings ' ...
          '\ninto a single line, ignoring any original line information. Comment lines and ellipses ' ...
          '\n"..." are not allowed and will cause failed string execution.']));
        
        % Button for stage algorithm
        btnX = 155;
        ToggleParam(obj, 'show_train', 0, 0, 0, 'label', 'Stage Algorithm', ...
			'TooltipString', sprintf(['\nMatlab expression evaluated on every trial', ...
			'usually when the protocol''s prepare_next_trial action calls "SessionDefinition(obj, ''next_trial'').\n', ...
			'All the protocol''s SoloParamHandles are available rw, as mfilename_spname. Globals don''t need the mfilename_ part.']));
        set(get_ghandle(show_train), 'Position', [btnX 40 100 20], 'FontSize', 9, 'FontWeight','bold');
        set_callback(show_train, {'SessionDefinition', 'show_train_string'}); btnX=btnX+110;

        % Button for completion test
        ToggleParam(obj, 'show_complete', 0, 0, 0, 'label', 'Completion Test', ...
			'TooltipString', sprintf(['\nMatlab boolean expression that gets evaluated immediately after the Stage Algorithm.\n', ...
			'Syntax as in Stage Algorithm. If it evaluates to true, the training stage moves up by 1.']));
        set(get_ghandle(show_complete), 'Position', [btnX 40 100 20],'FontSize', 9, 'FontWeight', 'bold');
        set_callback(show_complete, {'SessionDefinition', 'show_complete_string'}); btnX = btnX+110;
        % Button for end-of-day logic
        ToggleParam(obj','show_eod', 0,0,0,'label','End-of-Day Logic', ...
			'TooltipString', sprintf(['\nMatlab expression evaluated at the end of the session', ...
			'usually when the protocol''s pre_saving_settings action calls "SessionDefinition(obj, ''run_eod_logic_without_saving'')\n', ...
			'All the protocol''s SoloParamHandles are available rw, as mfilename_spname. Globals don''t need the mfilename_ part.']));
        set(get_ghandle(show_eod), 'Position', [btnX 40 100 20],'FontSize', 9, 'FontWeight', 'bold');
        set_callback(show_eod, {'SessionDefinition', 'show_eod'});
        % Button for name
        btnX = 175;
        ToggleParam(obj, 'show_name', 0, 0, 0, 'label', 'Name');
        set(get_ghandle(show_name), 'Position', [btnX 17 55 20],'FontSize', 9, 'FontWeight', 'bold');
        set_callback(show_name, {'SessionDefinition', 'show_name'}); btnX=btnX+135;
        % Button for helper variables
        ToggleParam(obj, 'show_vars', 0, 0, 0, 'label', 'Helper Vars');
        set(get_ghandle(show_vars), 'Position', [btnX 17 85 20],'FontSize', 9, 'FontWeight', 'bold');
        set_callback(show_vars, {'SessionDefinition', 'show_vars'});
           % Button to instantiate helper vars in base workspace
           PushbuttonParam(obj, 'instantiate_vars', 0, 0, 'label', '', 'position', [btnX+90 17 12 12], ...
             'TooltipString', sprintf(['\nInstantiates the Helper vars of the current stage as' ...
                                       '\nSoloParamHandles in the base workspace, with the same names.']));
           set_callback(instantiate_vars, {mfilename, 'base_instantiate_helper_vars'});
           % Button to reinitialize helper vars
           PushbuttonParam(obj, 'reinitialize_vars', 0, 0, 'label', '', 'position', [btnX+106 17 12 12], ...
             'TooltipString', sprintf(['\nReinitializes all the Helper vars of the current stage,' ...
                                       '\ndeleting them, recreating them, setting their value to 0.']));
           set_callback(reinitialize_vars, {mfilename, 'reinitialize_helper_vars'});
        

        % Non GUI variables that store different aspects of training stages
        % and current position in the training session

        % ID which tells SessionDefinition which component of a training
        % stage is currently being shown in the big white textbox

        % 1: Stage algorithm
        % 2: Completion test
        % 4: Name
        % 5: Vars
        % 6: End-of-day Logic
        SoloParamHandle(obj, 'display_type', 'value', 0);
        SoloParamHandle(obj, 'training_stages', 'value', {}, 'type', 'saveable_nonui');
        set_callback(training_stages, {'SessionDefinition', 'define_train_stages'});

        % variable keeping track of which stage is currently the active one
        SoloParamHandle(obj, 'active_stage', 'value', 0, 'type','saveable_nonui');
        set_callback(active_stage, {'SessionDefinition', 'set_active_stage'});

        % variable whose value determines which stage gets set to the
        % active stage.
        % Value set/examined only during End-of-Day logic execution
        % (whenever data is saved)
        SoloParamHandle(obj, 'eod_jumper', 'value', 0, 'type','saveable_nonui');
        set_callback(eod_jumper, {'SessionDefinition', 'nongui_change_active_stage'});

        % The instance of SessionModel being used to automate the protocol
        sm = SessionModel('param_owner', obj);
        SoloParamHandle(obj, 'my_session_model', 'value', sm, 'saveable', 0);

        % Name of file which was last used to load training stages for this
        % protocol. Used to allow inline editing and subsequent saving to
        % this same file (ie overwriting)
        SoloParamHandle(obj, 'last_file_loaded', 'value', '', 'type', ...
            'saveable_nonui');

        % a tracker variable which can be used in any way, but the sole
        % purpose of which is to be a counter and track how many trials
        % have elapsed since the last automated change was made
        SoloParamHandle(obj, 'last_change', 'value', [0]);                   % not saved in data files
        % An array that stores the value of last_change at the end of each
        % session. Allows troubleshooting of session automation
        % (e.g. Has last_change been incremented and reset appropriately?)
        SoloParamHandle(obj, 'last_change_tracker', 'value', zeros(1000,1)); % saved in data files

        
        % A SoloParamHandle that is just a place holder for a callback to
        % be called after the other SoloParamHandles have loaded
        SoloParamHandle(obj, 'last_callback_placeholder', 'value', 0, 'save_with_settings', 1);
        set_callback(last_callback_placeholder, ...
          {mfilename, 'reapply_active_stage'; ...
           mfilename, 'reinitialize_helper_vars_without_dialog'; ...
           mfilename, 'rescan_during_load'});
        set_callback_on_load(last_callback_placeholder, 1);
        
        
        
        x = parentfig_x; y = parentfig_y;
        set(0,'CurrentFigure', value(myfig));

        SessionDefinition(obj,'define_train_stages');
        SessionDefinition(obj,'hide_show');


        ch=get(value(sessionfig),'Children');
        set(ch,'Units','normalized');

        % END INIT

        % --------- CASE SET_INFO  ------------------------------------
        % Set ratname and experimenter (for EOD logic)

    case 'set_info'
        tmp_ratname = varargin{1};
        tmp_experimenter = varargin{2};
        if ~isstr(tmp_ratname) || ~isstr(tmp_experimenter), error('ratname and experimenter should both be strings.'); end;
        ratname.value = tmp_ratname;
        experimenter.value = tmp_experimenter;


%% define_train_stages        
        % --------- CASE DEFINE_TRAIN_STAGES  ------------------------------------
        % Set up training stages in SessionModel.
        % This should occur only when a file of training stages is loaded
        % or a SessionDefinition is first initialized. Calls mark_complete
        % when done.

    case 'define_train_stages',
        ts = value(training_stages);
        sm = value(my_session_model);
        my_session_model.value = remove_all_training_stages(sm);
        sm = value(my_session_model);

        if ~isempty(ts)
            my_session_model.value = add_training_stage_many(sm, value(training_stages));
          
        end;
        SessionDefinition(obj,'mark_complete');

%% get_current_training_stage		
	case 'get_current_training_stage',
		varargout{1} = get_current_training_stage(value(my_session_model));

%% mark_complete        
        % --------- CASE MARK_COMPLETE  ------------------------------------
        % Updates the display of training stages, suffixing
        % the training name with the status of completion
        % either "(Completed)" or "(Active)" or nothing
        % in the case where the training stage has not
        % yet been encountered

    case 'mark_complete'
        sm = value(my_session_model);
        ts = get_training_stages(sm);


        if ~isempty(ts)
            curr = get_current_training_stage(sm);
            if value(active_stage) > 0 && (curr ~= value(active_stage))
                  sm = set_current_training_stage(sm, value(active_stage));
                  my_session_model.value = sm;
                  curr=value(active_stage);
            elseif curr==0, curr=1;
            end;
            str = cell(0,0);

            for r = 1:rows(ts)
                if r < curr, ts{r,3} = 1; end;
                str{r,1} = ['#' num2str(r) ': ' ts{r,4}];
                if ts{r,3} > 0, str{r,1} = [str{r,1} '   (Complete)'];end;
            end;
            if curr <= rows(ts)
                str{curr,1} = ['#' num2str(curr) ': ' ts{curr,4} '  (ACTIVE)'];
            end;
        else
            str = {'#1','-- No training stages currently specified --'};
        end;

        if get(get_ghandle(train_list), 'Value') > rows(str)    % last value deleted
            set(get_ghandle(train_list), 'Value', rows(str));
        end;
        set(get_ghandle(train_list),'String', str);
        val = get(get_ghandle(train_list), 'Value');

        % Now set the string in the center-left label
        % (train_string_display) to reflect which component of the training
        % stage is currently being viewed
        if value(display_type) == 1
            set(get_lhandle(train_string_display), 'String', ['Showing: Stage #' num2str(val) ': Stage Algorithm']);
            if ~isempty(ts),
                set(get_ghandle(train_string_display), 'String', ts{val, 1});
            end;
        elseif value(display_type) == 2
            set(get_lhandle(train_string_display), 'String', ...
                ['Showing: Stage #' num2str(val) ': Completion string']);
            if ~isempty(ts),
                set(get_ghandle(train_string_display), 'String', ts{val, 2});
            end;
        end;



        % --------- CASE NEXT_TRIAL  ------------------------------------
        % Called at the end of each trial.
        % Using SessionModel, executes code of current training stage's "Stage
        % Algorithm" and also the "Completion Test". This is what
        % ultimately automates a session.

    case {'next_trial', 'run_stage_algorithm'}

        if n_done_trials > 0,
            sm = compute_next_trial(value(my_session_model), ...
              'old_style_parsing_flag', value(old_style_parsing_flag));
            my_session_model.value = sm;
            training_stages.value = get_training_stages(sm);
            active_stage.value = get_current_training_stage(sm);

            % update trackers
            temp = value(last_change_tracker);
            temp(n_done_trials) = value(last_change);
            last_change_tracker.value = temp;

            SessionDefinition(obj, 'mark_complete');
            clear_history(training_stages);
            clear_history(train_string_display);
        else
            display([mfilename ': n_done_trials < 1 !! Won''t take any action yet.']); %#ok<WNTAG>
        end;

        % --------- CASE TRAIN_LIST  ------------------------------------
        % Calls 'get' method of SessionModel to get the specified component
        % of the current training stage, given
        % the display_type.

    case 'train_list',
        switch value(display_type),
            case 1,
                feval(mfilename, obj, 'show_train_string');

            case 2,
                feval(mfilename, obj, 'show_complete_string');

            case 4,
                feval(mfilename, obj, 'show_name');
            case 5,
                feval(mfilename, obj, 'show_vars');
            case 6,
                feval(mfilename, obj, 'show_eod');

            otherwise,
                fprintf(1,'\n\nSessionDefinition: don''t know display type %g!!!\n\n',...
                    value(display_type));
        end;


%% show_train_string
        % --------- CASE SHOW_TRAIN_STRING  ------------------------------------
        % Displays Stage Algorithm of current training stage in white
        % textbox


    case 'show_train_string'
        v = get(get_ghandle(train_list),'Value');
        val = value(my_session_model); ts = get_training_stages(val);
        if ~isempty(ts), train_string_display.value = ts{v,1}; end;
        display_type.value = 1;
        set(get_lhandle(train_string_display), 'String', ...
            ['Showing: Stage #' num2str(v) ': Stage Algorithm']);
        show_train.value = 1;
        show_complete.value = 0;
        show_name.value = 0;
        show_eod.value = 0;
        show_vars.value     = 0;
        %		set_callback(train_string_display,'callb
        %

        % --------- CASE SHOW_COMPLETE_STRING  ---------------------------------
        % Displays Completion Test of current training stage in white
        % textbox

    case 'show_complete_string'
        v = get(get_ghandle(train_list),'Value');
        val = value(my_session_model); ts = get_training_stages(val);
        if ~isempty(ts), train_string_display.value = ts{v,2}; end;
        display_type.value = 2;
        set(get_lhandle(train_string_display), 'String', ...
            ['Showing: Stage #' num2str(v) ': Completion string']);
        show_train.value = 0;
        show_complete.value = 1;
        show_name.value = 0;
        show_eod.value = 0;
        show_vars.value     = 0;


        % --------- CASE SHOW_NAME ---------------------------------
        % Displays Name of current training stage in white
        % textbox
    case 'show_name'
        v = get(get_ghandle(train_list),'Value');
        val = value(my_session_model); ts = get_training_stages(val);
        if ~isempty(ts), train_string_display.value = ts{v,4}; end;
        display_type.value = 4;
        set(get_lhandle(train_string_display), 'String', ...
            ['Showing: Stage #' num2str(v) ': Name']);
        show_train.value = 0; show_complete.value = 0; show_name.value = 1;
        show_eod.value = 0;
        show_vars.value     = 0;

        % --------- CASE SHOW_VARS ---------------------------------
        % Displays helper variables of current training stage in white
        % textbox
    case 'show_vars'
        v = get(get_ghandle(train_list),'Value');
        val = value(my_session_model); ts = get_training_stages(val);
        if ~isempty(ts), train_string_display.value = ts{v,5}; end;
        display_type.value = 5;
        set(get_lhandle(train_string_display), 'String', ...
            ['Showing: Stage #' num2str(v) ': Vars']);
        show_train.value = 0; show_complete.value = 0;
        show_name.value  = 0; show_vars.value     = 1;
        show_eod.value = 0;


        % --------- CASE SHOW_EOD ---------------------------------
        % Displays End-of-day logic of current training stage in white
        % textbox
    case 'show_eod'
        v = get(get_ghandle(train_list),'Value');
        val = value(my_session_model); ts = get_training_stages(val);
        if ~isempty(ts), train_string_display.value = ts{v,6}; end;
        display_type.value = 6;
        set(get_lhandle(train_string_display), 'String', ...
            ['Showing: Stage #' num2str(v) ': Name']);
        show_train.value = 0; show_complete.value = 0; show_name.value = 0;
        show_eod.value = 1;show_vars.value     = 0;



        % --------- CASE ADD ---------------------------------
        % Adds a training stage to the end of the sequence of training
        % stages already existing.

    case 'add'
        sm = value(my_session_model);
        ts = get_training_stages(sm);
        new_num = rows(ts) + 1;
        answ = questdlg(['Are you SURE you wish to add training string #' num2str(new_num) '?'], ...
            ['Adding training string #' num2str(new_num)], 'Yes', 'No', 'Yes');

        if strcmpi(answ, 'yes')
            sm = value(my_session_model);
            my_session_model.value = add_training_stage(sm, 'train_string', value(train_string_display));
            SessionDefinition(obj, 'mark_complete');
            msgbox({'Addition successful!', '', 'To add a completion string:', ...
                '1. Click ''Completion Test''.',...
                '2. Type a statement that evaluates to TRUE when the training stage is complete.', ...
                '3. Click the ''UPDATE'' button. Do NOT click ''add''!'}, 'To add a Completion Test');
            training_stages.value = get_training_stages(value(my_session_model));
            active_stage.value = get_current_training_stage(value(my_session_model));
        end;


        % --------- CASE TEST_UPDATE ---------------------------------
        % Callback for 'U' (update) button.
        % Updates the current component (e.g. Stage algorithm/completion test/
        % end-of-day logic) of selected training string.
        % Checks to see if update of string is justified and if it is, does
        % it.

    case 'test_update'
        lnum = get(get_ghandle(train_list),'Value');
        if value(display_type) == 0,
            errordlg('Nothing to update!', 'Not a recognised training/completion string');
            return;
        elseif value(display_type) == 1,
            update_type = 'training string';
            utype = 'train_string';
        elseif value(display_type) == 2,
            update_type = 'completion string';
            utype = 'completion_string';
        elseif value(display_type) == 4,
            update_type = 'the name for';
            utype = 'name';
        elseif value(display_type) == 5,
            update_type = 'the vars for';
            utype = 'vars';
        elseif value(display_type) == 6,
            update_type = 'the end-of-day logic for';
            utype = 'eod';
        end;

        answ = questdlg(['Are you SURE you wish to update ' update_type ' #' num2str(lnum) '?'], ...
            ['Updating ' update_type ' #' num2str(lnum)], 'Yes', 'No', 'Yes');

        if strcmpi(answ, 'yes')
            my_session_model.value = ...
                update_training_stage(value(my_session_model), lnum, ...
                value(train_string_display), 'utype', utype);
            msgbox('Update successful!', 'Confirmation');
            training_stages.value = get_training_stages(value(my_session_model));
            active_stage.value = get_current_training_stage(value(my_session_model));
            if strcmpi(utype,'name'),
                SessionDefinition(obj,'mark_complete');
            end;
        end;



        % --------- CASE DELETE_STAGE ---------------------------------
        % Callback for "-" button
        % Deletes the selected training stage completely, moving all stages
        % after it up by one.


    case 'delete_stage'
        lnum = get(get_ghandle(train_list),'Value');
        answ = questdlg(['Are you SURE you wish to delete stage #' num2str(lnum) '?'], ...
            ['DELETE stage #' num2str(lnum)], 'Yes', 'No', 'No');

        if strcmpi(answ, 'yes')
            sm = value(my_session_model);
            my_session_model.value = remove_training_stage(sm, lnum);
            SessionDefinition(obj, 'mark_complete');
            msgbox({'Deletion successful!', '', ['The active stage is now: #' num2str(get_current_training_stage(sm))]}, ...
                'Deletion successful');
            training_stages.value = get_training_stages(value(my_session_model));
            active_stage.value = get_current_training_stage(value(my_session_model));
        end;



        % --------- CASE FLUSH_ALL ---------------------------------
        % USE WITH CAUTION: Deletes all training stages leaving nothing but
        % a satisfactory blank slate or mild regret.
        % (Hopefully you have a backup and think about the confirmatory
        % dialog box before you respond)

    case 'flush_all'
        answ = questdlg({'Are you SURE you wish to DELETE ALL training stages??', ...
            'This action cannot be undone!'}, ...
            ['DELETE ALL STAGES'], 'Yes', 'No', 'No');

        if strcmpi(answ, 'yes')
            sm = value(my_session_model);
            my_session_model.value = remove_all_training_stages(sm);
            SessionDefinition(obj, 'mark_complete');
            msgbox('All training stages have been successfully deleted.', ...
                'Deletion successful');
            training_stages.value = get_training_stages(value(my_session_model));
            active_stage.value = get_current_training_stage(value(my_session_model));
        end;

%% change_active_stage
        % --------- CASE CHANGE_ACTIVE_STAGE ---------------------------------
        % Callback to 'Change Active Stage' button.
        % Changes the active stage both here and in SessionModel after
        % confirming with the user via a dialog box.
        % Updates the GUI to reflect the new active stage

    case 'change_active_stage'


        v = get(get_ghandle(train_list),'Value');

        answ = questdlg({['Are you SURE you wish to make STAGE #' num2str(v) ...
            ' the ACTIVE stage?'], ...
            'This action cannot be undone!'}, ...
            ['CHANGE ACTIVE STAGE'], 'Yes', 'No', 'No');

        if strcmpi(answ, 'yes')
            sm = value(my_session_model);
            my_session_model.value = jump(sm, 'to', v);
            training_stages.value =get_training_stages(value(my_session_model));
            active_stage.value = ...
                get_current_training_stage(value(my_session_model));
            SessionDefinition(obj, 'mark_complete');
        end;

        
% ---------------------------------------------------------------------
%
%                  CASE REAPPLY_ACTIVE_STAGE 
%
% ---------------------------------------------------------------------
% Make the current active stage current again. Has no functional effect,
% used here only to be called in an automatic callback after loading data
% or solouiparamvalues to ensure that GUI accurately reflects current stage
  
  case 'reapply_active_stage'
    if size(get_training_stages(value(my_session_model)),1) >= 1,
        v = value(active_stage); %#ok<NODEF>
        my_session_model.value = jump(value(my_session_model), 'to', v'); %#ok<NODEF>
        training_stages.value =get_training_stages(value(my_session_model));
        active_stage.value = ...
        get_current_training_stage(value(my_session_model));
        SessionDefinition(obj, 'mark_complete');
    end;



        % --------- CASE CHANGE_ACTIVE_STAGE ---------------------------------
        % Changes active stage, but based on value of the variable
        % "eod_jumper". This is done only when EOD logic runs.

    case 'nongui_change_active_stage'
        if nargin > 2,
            v = varargin{1};
        else
            v = value(eod_jumper);
        end;
        if v == 0, return; end;


        sm = value(my_session_model);
        my_session_model.value = jump(sm, 'to', v);
        training_stages.value =get_training_stages(value(my_session_model));
        active_stage.value = ...
            get_current_training_stage(value(my_session_model));
        SessionDefinition(obj, 'mark_complete');
        eod_jumper.value = 0; % reset - added by SP: 071113

%% set_active_stage
        % --------- CASE SET_ACTIVE_STAGE ---------------------------------
        % Quiet changer of active stage. Callback to 'active_stage' SPH.
        % Called whenever active_stage is updated.
        % Sets active stage in SessionModel. Calls 'mark_complete' at end.

    case 'set_active_stage',
        pairs = { ...
          'hvar_names_and_values'     []  ; ...
        }; parseargs(varargin, pairs);
      
        sm = value(my_session_model); %#ok<NODEF>
        sm = set_current_training_stage(sm, value(active_stage), 'hvar_names_and_values', hvar_names_and_values); %#ok<NODEF>
        my_session_model.value = sm;

        SessionDefinition(obj, 'mark_complete');


%% hide_show
        % --------- CASE HIDE_SHOW ---------------------------------
        % hide/show 'Session Automator' window

    case 'hide'
        session_show.value = 0';
        set(value(sessionfig), 'Visible', 'off');

    case 'hide_show'
        if value(session_show)==0
            set(value(sessionfig), 'Visible', 'off');
        elseif value(session_show)==1
            set(value(sessionfig),'Visible','on');
        end;


        % --------- CASE REINIT ---------------------------------
        % reinitialize SessionDefinition without having to reinit the
        % protocol.

    case 'reinit',
        x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
        ofig = my_gui_info(3);
        sfig = value(sessionfig);
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
          'fullname', ['^' mfilename]);
        delete(sfig);  
        [x, y, ofig],
        feval(mfilename, obj, 'init', x, y, ofig);


%% insert_from_file
% --------- CASE INSERT_FROM_FILE ---------------------------------
        % Callback to "load from file" Button
        % Loads training stage definitions from a .m file.

    case 'insert_from_file',
        if nargin==4
            pname=varargin{1};
            fname=varargin{2};
        elseif isempty(value(last_file_loaded)), %#ok<NODEF>
            [fname, pname] = uigetfile({'*.m'}, 'Insert from file');
        else
            [fname, pname] = uigetfile({'*.m'}, 'Insert from file', ...
                value(last_file_loaded));
        end;
        drawnow;
        if fname,
            
            % first record current training stage number and helper vars
            sm = value(my_session_model); %#ok<NODEF>
            current_active_stage = value(active_stage); %#ok<NODEF>
            try
              current_helper_vars = get_current_helper_var_handles(sm);
            catch %#ok<CTCH>
              current_helper_vars = {};
              lerr = lasterror;
              fprintf(1, 'Couldn''t get current helper vars, they won''t survive load file. Error was "%s"\n', ...
                lerr.message);
            end;
            nvars = numel(current_helper_vars);
            hvar_names_and_values = struct('name', cell(nvars,1), 'value', cell(nvars,1));
            for j=1:nvars,
              hvar_names_and_values(j).name  = get_name(current_helper_vars{j});
              hvar_names_and_values(j).value = value(current_helper_vars{j});
            end;
              
            % then remove all existing training stages
            my_session_model.value = remove_all_training_stages(sm);
            SessionDefinition(obj, 'mark_complete');
            
            try
                sm = load_from_file(value(my_session_model), [pname fname]);
                last_file_loaded.value = [pname fname];
            catch  %#ok<CTCH>
                lasterr, %#ok<LERR>
                return;
            end;
            training_stages.value = get_training_stages(sm);
            val = current_active_stage;
            if isempty(val) || val < 1,
                val = 1;
            elseif val > rows(value(training_stages))
                val = rows(value(training_stages));
            end;
            active_stage.value = val;
            sm = jump(sm, 'to', val);
            my_session_model.value = sm;

            feval(mfilename, obj, 'set_active_stage', 'hvar_names_and_values', hvar_names_and_values);

            feval(mfilename, obj, 'show_train_string');
        end;

        
%% save_to_file
        % --------- CASE SAVE_TO_FILE ---------------------------------
        % Callback to "save to file" Button
        % Saves all training stages in a .m file

    case 'save_to_file',
        if isempty(value(last_file_loaded)),
            [fname, pname] = uiputfile({'*.m'}, 'Save to file');
        else
            [fname, pname] = uiputfile({'*.m'}, 'Save to file', ...
                value(last_file_loaded));
        end;
        if fname,
            try,
                write_to_file(value(my_session_model), [pname fname]);
                last_file_loaded.value = [pname fname];
            catch,
                lasterr,
                return;
            end;
        end;
        
       


        % --------- CASE EOD_SAVE ---------------------------------
        % Background routine which executes EOD logic and saves
        % data/settings file. The data file is saved for 'today' (ie the
        % date on which this code executes, ideally at the end of a
        % session) and the settings file is saved for 'tomorrow', (ie the
        % day after 'today')
        % Note: The save is non-interactive
    case 'eod_save'
        h=double(figure);
        set(h,'Position',[300 300 500 75],'Color',[1 1 0],'Menubar','none','Toolbar','none');
        uicontrol('Style','text', 'Position',[80 10 300 50],'BackgroundColor',[1 1 0], ...
            'Fontsize', 14, 'FontWeight','bold', 'String', sprintf('Currently saving settings/data.\nPlease wait...'));


        sm = compute_next_trial(value(my_session_model),'eval_EOD',1, ...
          'old_style_parsing_flag', value(old_style_parsing_flag));
        my_session_model.value = sm;
        tmp_ratname = value(ratname); tmp_experim=value(experimenter);
        if strcmpi(tmp_ratname,'') || strcmpi(tmp_experim,''), warning('Plugins:@sessionmodel:SessionDefinition: Ratname and experimenter are blank'); end;
        save_soloparamvalues(value(ratname), 'owner', class(obj), 'commit', 1,'interactive',0,'experimenter',value(experimenter));
        save_solouiparamvalues(value(ratname), 'owner', class(obj), 'commit', 1,'interactive', 0,'tomorrow',1,'experimenter',value(experimenter));

        close(h);
        h=msgbox(sprintf('Data saved for today.\nSettings saved for tomorrow\n'),'Data & Settings Saved');
        set(h,'Position',[300 300 500 75],'Color',[0 1 0]);
        c = get(h,'Children');  b = get(c(1),'Children'); set(b,'FontSize', 14, 'FontWeight','bold');
        for k = 1:length(c),set(c(k),'FontSize',14);end;
        refresh;

    case 'eod_save_settings_only'
        h=double(figure);
        set(h,'Position',[300 300 500 75],'Color',[1 1 0],'Menubar','none','Toolbar','none');
        uicontrol('Style','text', 'Position',[80 10 300 50],'BackgroundColor',[1 1 0], ...
            'Fontsize', 14, 'FontWeight','bold', 'String', sprintf('Currently saving settings.\nPlease wait...'));

        sm = compute_next_trial(value(my_session_model),'eval_EOD',1, ...
          'old_style_parsing_flag', value(old_style_parsing_flag));
        my_session_model.value = sm;
        tmp_ratname = value(ratname); tmp_experim=value(experimenter);
        if strcmpi(tmp_ratname,'') || strcmpi(tmp_experim,''), warning('Plugins:@sessionmodel:SessionDefinition: Ratname and experimenter are blank'); end;
        %  save_soloparamvalues(value(ratname), 'owner', class(obj), 'commit', 1,'interactive',0,'experimenter',value(experimenter));
        save_solouiparamvalues(value(ratname), 'owner', class(obj), 'commit', 1,'interactive', 0,'tomorrow',1,'experimenter',value(experimenter));

        close(h);
        h=msgbox(sprintf('Settings saved for tomorrow.\n Data not saved.\n'),'Settings Saved');
        set(h,'Position',[300 300 500 75],'Color',[0 1 0]);
        c = get(h,'Children');  b = get(c(1),'Children'); set(b,'FontSize', 14, 'FontWeight','bold');
        for k = 1:length(c),set(c(k),'FontSize',14);end;
        refresh;
        
%% rescan_during_load

  case 'rescan_during_load'
        rescan_sphandles_during_load(value(my_session_model));
        
%% reinitialize_helper_vars

  case 'reinitialize_helper_vars'
        answ = questdlg('Are you SURE you wish to reinitialize all current stage helper vars to their training string value (default 0) ?', ...
            'Reinitializing Current Helper Vars', 'Yes', 'No', 'Yes');

        if strcmpi(answ, 'yes'),
          reinitialize_current_helper_vars(value(my_session_model));
        end;
        
%% reinitialize_helper_vars_without_dialog
  case 'reinitialize_helper_vars_without_dialog'
    reinitialize_current_helper_vars(value(my_session_model));


%% base_instantiate_helper_vars        
  case 'base_instantiate_helper_vars'
        base_instantiate_current_helper_vars(value(my_session_model), 'doprint', 1);
        
        
%% set_old_style_parsing_flag

  case 'set_old_style_parsing_flag'
    old_style_parsing_flag.value = varargin{1};
    
    
        
%% get_helper_vars
  case 'get_helper_vars'
	  try
		  helper_var_handles = get_current_helper_var_handles(value(my_session_model));
		  varargout{1} = helper_var_handles;
	  catch
		  varargout{1} = {};
	  end;


      
%% run_eod_logic_without_saving      
% --------------------------------------------------------
%
%         CASE RUN_EOD_LOGIC_WITHOUT_SAVING
%
% --------------------------------------------------------
        
    case {'run_eod_logic_without_saving', 'run_eod_logic'}
        sm = compute_next_trial(value(my_session_model),'eval_EOD',1, ...
          'old_style_parsing_flag', value(old_style_parsing_flag)); %#ok<NODEF>
        my_session_model.value = sm;
        active_stage.value = get_current_training_stage(sm);
        SessionDefinition(obj, 'mark_complete');

        
        % --------- CASE DELETE ---------------------------------
        % cleanup

    case 'delete'
        try,
            delete(value(sessionfig));
        catch
        end

    otherwise
        error('Unknown action');
end;

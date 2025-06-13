function [varargout] = SessionDefinition(obj, action, varargin)
%SESSIONDEFINITION Function to automate training stages
%   Creates the interface that allows an individual protocol to automate
%   its progression. Its role is to allow the experimenter to load/save
%   training stages in an executable M file and to view or edit these in a
%   separate window that shows up as part of the training protocol.
%
%   The sessionmodel2 plugin uses the SessionModel class defined in
%   ExperPort/HandleParam/@SessionModel. Inspired by the original
%   sessionmodel plugin, it has been rewritten to allow training stages to
%   be stored in an executable M file, and to have helper vars store a
%   trial-by-trial history whose size is equal to n_done_trials.
%
%   A more complete documentation will be located at:
%   http://brodylab.princeton.edu/bcontrol/index.php/Plugins:sessionmodel2
%
%   Syntax: VARARGOUT = SESSIONDEFINITION(OBJ, ACTION, VARARGIN)
%
%   OBJ - The protocol object
%
%   ACTION - Action string, which can take one of many values, as described
%   in the examples section
%
%   Common Example calls for end users
%
%   SessionDefinition(obj, 'init', x, y, figure_handle): This creates the
%   'Session Ctrl' and the 'SAVE DATA AND SETTINGS' buttons on the figure
%   specified by figure_handle, at the x and y coordinates passed. It also
%   initializes the GUI for the Session Automator Window and loads the most
%   recent training stage file available in the Main_Data_Directory (e.g.
%   /ratter/SoloData/Settings/<Experimenter>/<ratname>) that is not meant
%   for later than the current day, and adds the containing directory to
%   the MATLAB path. The entry will be removed from the path when the
%   plugin is closed. If no training stage file is available, the plugin
%   does not load a training stage file at this stage.
%
%   SessionDefinition(obj, 'next_trial'): This call normally goes into the
%   prepare_next_trial section of the protocol. Everytime this call is
%   executed, a push_history command is executed on all existing helper
%   vars, and the HELPER_VARS section and STAGE_ALGORITHM section of the
%   active stage in the loaded training stage file are executed, provided
%   that training stage has not been marked as deactivated. If it has been
%   marked as deactivated, the call will make the next non-deactivated training
%   stage active and execute it. After this execution, the COMPLETION_TEST
%   section of the active stage in the loaded training stage file is
%   evaluated. If the completion test evaluates to true, the next stage
%   that is not marked as deactivated in the session automator window is
%   activated, and will be called when SessionDefintion(obj, 'next_trial')
%   is called again.
%
%   SessionDefinition(obj, 'eod_save'): Runs the EOD Logic of the active
%   training stage, provided it has not been marked as deactivated. After
%   executing the EOD Logic (if available), this section saves the settings
%   file and training stage file for the **following day**, and the data for
%   the **current day**, and commits these files to the CVS respository.
%
%   SessionDefinition(obj, 'run_eod_logic_without_saving'): Runs the EOD
%   logic of the active training stage, provided it has not been marked as
%   deactivated. Unlike the eod_save action, this action will not save any
%   data, settings, or training stage files.
%
%   SessionDefinition(obj, 'load_stagefile', absolute_file_path): This call loads
%   the training stage file pointed to by absolute_file_path. If the file does not
%   exist, the function throws an error. In order to be loaded, the file
%   need not have access to the protocol object. This property can be
%   utilized if the only reason for calling this function is editing the
%   training stage file. However, if the training stage file loaded does
%   not have access to the protocol object, a call to
%   SessionDefinition(obj,
%   ['next_trial'/'eod_save'/'run_eod_logic_without_saving']) will throw an
%   error.
%
%   SessionDefinition(obj, 'jump_to_stage', <stage_name/stage_number>):
%   Activates the stage specified by stage_name/stage_number.
%
%   filepath = SessionDefinition(obj, 'save_current_training_stage_file',
%   <absolute_file_path>): Saves the current training stage file. If
%   absolute_file_path is specified (which has to be an M file), the
%   currently loaded training stage file is saved to absolute_file_path. If
%   it is not specified, it is saved with today's date to
%   <Main_Data_Directory>/Settings/<experimenter>/<ratname>/pipeline_<Proto
%   colName>_<experimenter>_<ratname>_<yymmdd>*.m. The function also
%   returns a string to the file path to which the file was saved. It
%   returns an empty string if the file wasn't saved.
%
%   SessionDefinition(obj, 'mark_deactivated', stagelist): In case the user
%   would like to skip selected training stages. stagelist can be a cell
%   array containing both numbers and strings, or it can be a numeric
%   vector containing only numbers. If an element of stagelist is a string,
%   it will be interpreted as stage name, otherwise it will be interpreted
%   as stage number.
%
%   SessionDefinition(obj, 'mark_not_deactivated', stagelist): Works just like
%   SessionDefinition(obj, 'mark_deactivated', stagelist), but forces
%   execution of the specified stage(s) if they are in the sequence.
%
%   helper_vars = SessionDefinition(obj, 'get_helper_var_details'): Returns
%   a structure containing the fields 'var_name', 'stage_name',
%   'initial_value', 'current_value', and 'history' for every helper var
%   available. If no helper vars exist, the function returns an empty structure.
%
%	helper_vars_cell = SessionDefinition(obj, 'get_helper_vars'): Returns a
%	cell array containing all available helper vars. If no helper vars exist,
%	the function returns an empty cell array.
%
%   OTHER EXAMPLES
%   SessionDefinition(obj, 'reinit_helper_vars'): Reinitializes all helper
%   vars, but preserves their histories.
%
%   SessionDefinition(obj, 'reinit_helper_vars', helper_var_name_list):
%   helper_var_name_list is either a string, or a cell array of strings.
%   This call reinitializes all helper vars in helper_var_name_list, but
%   preserves their histories.
%
%   SessionDefinition(obj, 'caller_instantiate_helper_vars'): Instantiates
%   all helper vars as SoloParamHandles in the workspace of the caller of
%   SessionDefinition.
%
%   SessionDefinition(obj, 'caller_instantiate_helper_vars',
%   helper_var_name_list): helper_var_name_list is either a string, or a
%   cell array of strings. This call instantiates all helper vars in
%   helper_var_name_list in the workspace of the caller of
%   SessionDefinition.
%
%   SessionDefinition(obj, 'refresh_lbxTrainingStages'): Refreshes the
%   listbox displaying training stages in the session automator window.
%
%   SessionDefinition(obj, 'refresh_lbxParameters'): Refreshes the
%   parameters listbox, using the string in the editParameterSearchString
%   field as a regular expression filter.
%
%   stagelist = SessionDefinition(obj, 'get_stagelist'): Returns the names
%   of all training stages in the currently loaded training stage file as a
%   cell array. If no training stage file has been loaded, the call returns
%   an empty cell array.
%
%   loadtime_datenum = SessionDefinition(obj,
%   'get_current_stagefile_load_time'): Returns the date and time of
%   loading the currently loaded training stage file in the datenum format.
%   If no training stage file is loaded, the function returns NaN.
%
%   parameterlist = SessionDefinition(obj, 'get_parameter_list): Returns a
%   sorted cell array containing a list of parameter names available to the
%   protocol.
%
%   active_stage = SessionDefinition(obj, 'get_active_stage_details'):
%   Returns the stage name and stage number of the currently active stage
%   as structure with fields 'name' and 'number'. If no training stages
%   exist, the function call returns the value NaN for stage number and an
%   empty string for stage name.
%
%   stage_file_path = SessionDefinition(obj, 'get_current_stagefile'):
%   Returns the path to the currently loaded training stage file. If no
%   file has been loaded, the function returns an empty string.
%
%   SessionDefinition(obj, 'save_settings_only', {'commit', false}): Saves
%   only the settings file for the **NEXT DAY**.
%
%   SessionDefinition(obj, 'save_data_only', {'commit', false}): Saves only
%   the data file for the **CURRENT DAY**.
%
%   SessionDefinition(obj, 'get_previous_active_stage_details'): Returns a
%   structure with fields 'name' and 'number' for the previously active
%   stage.
%
%   Author: Sundeep Tuteja
%           sundeeptuteja@gmail.com


%--------------------------------------------------------------------------
%                     ***FOR DEVELOPERS***
%--------------------------------------------------------------------------
%PLEASE FOLLOW THE CONVENTION OF HAVING TAG NAME FOR ANY
%GUI SOLOPARAMHANDLE EQUAL TO THE SOLOPARAMHANDLE VARIABLE NAME AT ALL
%TIMES.
%--------------------------------------------------------------------------

try
    %Nothing that happens in SessionDefinition should cause a training
    %session to abort. Hence, the whole function is wrapped in a try-catch
    
    
    GetSoloFunctionArgs(obj);
    
    switch action
        %% init
        case 'init'
            %e.g SessionDefinition(obj, 'init', x, y, figure_handle)
            %e.g. SessionDefinition(obj, 'init', 'reuse') (internal use only).
            if nargin~=5 && nargin~=2 && nargin~=3
                error('Invalid number of arguments. The number of arguments has 5 or 3 or 2.');
            elseif nargin==5
                if ~isscalar(varargin{1})
                    error('x has to be a scalar.');
                elseif ~isscalar(varargin{2})
                    error('y has to be a scalar.');
                elseif ~ishandle(varargin{3})
                    error('figure_handle has to be a valid handle.');
                end
            end
            
            if nargin==3 && ischar(varargin{1}) && strcmp(varargin{1}, 'flush')
                should_flush = true;
            else
                should_flush = false;
            end
            
            
            
            if nargin==5
                x = varargin{1};
                y = varargin{2};
                myfig = varargin{3};
                figure(myfig);
                ToggleParam(obj, 'session_show', false, x, y, 'label', 'Session Ctrl.', 'OnString', 'Session Ctrl Showing', 'OffString', 'Session Ctrl Hidden', 'TooltipString', 'Define training stages to be automated'); next_row(y);
                set_callback(session_show, {mfilename, 'hide_show'});
                % 2 - A big red button which executes EOD logic and saves
                % data/settings files
                next_row(y);
                PushbuttonParam(obj,'savetom', x, y, 'label', 'SAVE DATA & SETTINGS'); next_row(y);
                set(get_ghandle(savetom),'BackgroundColor', 'r', 'FontSize', 14);
                set_callback(savetom, {mfilename, 'eod_save'});
            end
            
            SoloParamHandle(obj, 'CURRENT_ACTIVE_STAGE', 'value', NaN);
            SoloParamHandle(obj, 'CURRENT_DEACTIVATED_STAGES', 'value', []);
            if ~exist('STARTING_ACTIVE_STAGE', 'var') || ~isa(STARTING_ACTIVE_STAGE, 'SoloParamHandle') || should_flush
                SoloParamHandle(obj, 'STARTING_ACTIVE_STAGE', 'value', 1);
                set_saveable(STARTING_ACTIVE_STAGE, true);
                set_save_with_settings(STARTING_ACTIVE_STAGE, true);
            end
            if ~exist('STARTING_DEACTIVATED_STAGES', 'var') || ~isa(STARTING_DEACTIVATED_STAGES, 'SoloParamHandle') || should_flush
                SoloParamHandle(obj, 'STARTING_DEACTIVATED_STAGES', 'value', []);
                set_saveable(STARTING_DEACTIVATED_STAGES, true);
                set_save_with_settings(STARTING_DEACTIVATED_STAGES, true);
            end
            if ~exist('PREVIOUS_ACTIVE_STAGE', 'var') || ~isa(PREVIOUS_ACTIVE_STAGE, 'SoloParamHandle') || should_flush
                SoloParamHandle(obj, 'PREVIOUS_ACTIVE_STAGE', 'value', []);
                set_saveable(PREVIOUS_ACTIVE_STAGE, true);
                set_save_with_settings(PREVIOUS_ACTIVE_STAGE, true);
            end
            if ~exist('lbxParameters_String', 'var') || ~isa(lbxParameters_String, 'SoloParamHandle') || should_flush
                SoloParamHandle(obj, 'lbxParameters_String', 'value', '');
                set_saveable(lbxParameters_String, true);
                set_save_with_settings(lbxParameters_String, true);
            end
            if ~exist('lbxTrainingStages_String', 'var') || ~isa(lbxTrainingStages_String, 'SoloParamHandle') || should_flush
                SoloParamHandle(obj, 'lbxTrainingStages_String', 'value', '');
                set_saveable(lbxTrainingStages_String, true);
                set_save_with_settings(lbxTrainingStages_String, true);
            end
            
            
            
            SoloParamHandle(obj, 'CURRENT_TRAINING_STAGES_FILE_PATH', 'value', '');
            SoloParamHandle(obj, 'CURRENT_TRAINING_STAGES_FILE_NAME', 'value', '');
            SoloParamHandle(obj, 'CURRENT_TRAINING_STAGES_FILE_LOADTIME', 'value', NaN);
            SoloParamHandle(obj, 'CURRENT_TRAINING_STAGE_LIST', 'value', {});
            SoloParamHandle(obj, 'CURRENT_STAGE_ALGORITHM_LIST', 'value', {});
            SoloParamHandle(obj, 'CURRENT_EOD_LOGIC_LIST', 'value', {});
            SoloParamHandle(obj, 'CURRENT_COMPLETION_TEST_LIST', 'value', {});
            SoloParamHandle(obj, 'CURRENT_HELPER_FUNCTION_LIST', 'value', {});
            SoloParamHandle(obj, 'CURRENT_HELPER_VAR_LIST', 'value', {});
            SoloParamHandle(obj, 'SESSION_INFO', 'value', struct('experimenter', 'experimenter', 'ratname', 'ratname', 'settings_file', '', 'protocol', class(obj)));
            SoloParamHandle(obj, 'MAIN_DATA_DIRECTORY', 'value', bSettings('get', 'GENERAL', 'Main_Data_Directory'));
            if ~exist('DELETE_THESE_FILES', 'var') || ~isa(DELETE_THESE_FILES, 'SoloParamHandle')
                SoloParamHandle(obj, 'DELETE_THESE_FILES', 'value', {});
            end
            SoloParamHandle(obj, 'TEMPORARY_SETTINGS_FILE_PATH', 'value', '');
            SoloParamHandle(obj, 'TEMPORARY_SETTINGS_FILE_LOAD_TIME', 'value', []);
            if ~exist('REMOVE_THESE_PATHS', 'var') || ~isa(REMOVE_THESE_PATHS, 'SoloParamHandle')
                SoloParamHandle(obj, 'REMOVE_THESE_PATHS', 'value', {});
            end
            if any(isnan(value(MAIN_DATA_DIRECTORY))) || isempty(value(MAIN_DATA_DIRECTORY))
                MAIN_DATA_DIRECTORY.value = fullfile(filesep, 'ratter', 'SoloData');
            end
            SoloParamHandle(obj, 'MAIN_CODE_DIRECTORY', 'value', bSettings('get', 'GENERAL', 'Main_Code_Directory'));
            if any(isnan(value(MAIN_CODE_DIRECTORY))) || isempty(value(MAIN_CODE_DIRECTORY))
                MAIN_CODE_DIRECTORY.value = fullfile(filesep, 'ratter', 'ExperPort');
            end
            if ~exist('GLOBAL_HELPER_VAR_NAME_LIST', 'var') || ~isa(GLOBAL_HELPER_VAR_NAME_LIST, 'SoloParamHandle') || should_flush
                SoloParamHandle(obj, 'GLOBAL_HELPER_VAR_NAME_LIST', 'value', struct([]));
                set_saveable(GLOBAL_HELPER_VAR_NAME_LIST, true);
                set_save_with_settings(GLOBAL_HELPER_VAR_NAME_LIST, true);
                DeclareGlobals(obj, 'ro_args', {'GLOBAL_HELPER_VAR_NAME_LIST'});
                SoloFunctionAddVars(obj, 'CreateHelperVar', 'rw_args', {'GLOBAL_HELPER_VAR_NAME_LIST'});
            end
            
            %In this section, we create the session automator figure window
            
            session_automator_window_position = [0.563542 0.150833 0.418229 0.462500];
            if exist('session_automator_window', 'var') && isa(session_automator_window, 'SoloParamHandle')
                session_automator_window_position = get(value(session_automator_window), 'Position');
                clf(value(session_automator_window));
            else
                booleanstr = {'off', 'on'};
                SoloParamHandle(obj, 'session_automator_window', ...
                    'value', double(figure('WindowStyle', 'normal', 'Units', 'normalized', 'Name', mfilename, 'MenuBar', 'None', ...
                    'Visible', booleanstr{double(value(session_show))+1})), ...
                    'saveable', false);
            end
            
            
            edit_window_font = 'Monospaced';
            
            
            
            
            hndl = value(session_automator_window);
            
            set(hndl, 'Position', session_automator_window_position);
            set(hndl, 'CloseRequestFcn', ['feval(''' mfilename ''', ' class(obj) ', ''hide'');']);
            
            temp = SavingSection(obj, 'get_all_info');
            SESSION_INFO.experimenter = temp.experimenter;
            SESSION_INFO.ratname = temp.ratname;
            SESSION_INFO.settings_file = temp.settings_file;
            filename = SESSION_INFO.settings_file(find(SESSION_INFO.settings_file==filesep, 1, 'last')+1:end);
            if exist(SESSION_INFO.settings_file, 'file')
                copyfile(SESSION_INFO.settings_file, fullfile(pwd, filename), 'f');
                TEMPORARY_SETTINGS_FILE_PATH.value = fullfile(pwd, filename);
                TEMPORARY_SETTINGS_FILE_LOAD_TIME.value = SavingSection(obj, 'get_settings_file_load_time');
                DELETE_THESE_FILES{end+1} = fullfile(pwd, filename); %#ok<NASGU>
            end
            
            %% GUI ELEMENTS SECTION
            
            %An invisible button whose callback automatically gets executed
            %when a settings file or a data file is loaded.
            PushbuttonParam(obj, 'btnRedraw', 1, 1);
            set(get_ghandle(btnRedraw), ...
                'Visible', 'off', ...
                'Units', 'normalized', ...
                'Tag', 'btnRedraw');
            set_callback(btnRedraw, {mfilename, 'btnRedrawCallback'});
            set_callback_on_load(btnRedraw, true);
            
            HeaderParam(obj, 'textHeader', ['SESSION AUTOMATOR WINDOW: ' SESSION_INFO.experimenter ', ' SESSION_INFO.ratname], 1, 1);
            set(get_ghandle(textHeader), ...
                'Parent', hndl, ...
                'Units', 'normalized', ...
                'Style', 'text', ...
                'BackgroundColor', 'yellow', ...
                'Tag', 'textHeader', ...
                'FontSize', 13.0, ...
                'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center', ...
                'Position', [0.061021 0.918924 0.872976 0.046847]);
            
            uipanel('Parent', hndl, ...
                'Units', 'normalized', ...
                'Tag', 'uipanelParameters', ...
                'FontSize', 13.0, ...
                'FontWeight', 'bold', ...
                'Position', [0.061021 0.538739 0.374844 0.362173], ...
                'Title', 'PARAMETERS', ...
                'TitlePosition', 'centertop');
            
            uipanel('Parent', hndl, ...
                'Units', 'normalized', ...
                'Tag', 'uipanelTrainingStages', ...
                'FontSize', 13.0, ...
                'FontWeight', 'bold', ...
                'Position', [0.457036 0.538739 0.476961 0.362173], ...
                'Title', 'TRAINING STAGES', ...
                'TitlePosition', 'centertop');
            
            uipanel('Parent', hndl, ...
                'Units', 'normalized', ...
                'Tag', 'uipanelTrainingStageFileComponents', ...
                'FontSize', 13.0, ...
                'FontWeight', 'bold', ...
                'Position', [0.033624 0.021620 0.930262 0.481070], ...
                'Title', 'TRAINING STAGE FILE COMPONENTS', ...
                'TitlePosition', 'centertop');
            
            handles = guihandles(hndl);
            
            ListboxParam(obj, 'lbxParameters', 1, 1, 1, 1);
            set(get_ghandle(lbxParameters), ...
                'Parent', handles.uipanelParameters, ...
                'Units', 'normalized', ...
                'Position', [0.074074 0.096102 0.865320 0.745774], ...
                'Tag', 'lbxParameters', ...
                'String', '', ...
                'Style', 'listbox', ...
                'TooltipString', 'Parameter List', ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''lbxParametersCallback'');'], ...
                'FontSize', 8.0);
            
            PushbuttonParam(obj, 'btnSearch', 1, 1);
            set(get_ghandle(btnSearch), ...
                'Parent', handles.uipanelParameters, ...
                'Units', 'normalized', ...
                'Position', [0.478114 0.841876 0.232323 0.124271], ...
                'Style', 'pushbutton', ...
                'Tag', 'btnSearch', ...
                'TooltipString', 'Regular expression search', ...
                'String', 'SEARCH', ...
                'HorizontalAlignment', 'center', ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''btnSearchCallback'');']);
            
            PushbuttonParam(obj, 'btnReset', 1, 1);
            set(get_ghandle(btnReset), ...
                'Parent', handles.uipanelParameters, ...
                'Units', 'normalized', ...
                'Position', [0.707071 0.841876 0.232323 0.124271], ...
                'Style', 'pushbutton', ...
                'Tag', 'btnReset', ...
                'TooltipString', 'Reset search field', ...
                'String', 'RESET', ...
                'HorizontalAlignment', 'center', ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''btnResetCallback'');']);
            
            EditParam(obj, 'editParameterSearchString', '', 1, 1);
            set(get_lhandle(editParameterSearchString), 'Visible', 'off');
            set(get_ghandle(editParameterSearchString), ...
                'Parent', handles.uipanelParameters, ...
                'Units', 'normalized', ...
                'Position', [0.074074 0.847458 0.404040 0.112960], ...
                'BackgroundColor', 'white', ...
                'Style', 'edit', ...
                'Tag', 'editParameterSearchString', ...
                'TooltipString', 'Enter the search string, as a regular expression', ...
                'HorizontalAlignment', 'center');
            
            load('sessionmodel2_cdata.mat');
            PushbuttonParam(obj, 'btnUpArrow', 1, 1);
            set(get_ghandle(btnUpArrow), ...
                'Parent', handles.uipanelTrainingStages, ...
                'Units', 'normalized', ...
                'Position', [0.659631 0.694983 0.108179 0.237305], ...
                'CData', uparrow_cdata, ...
                'Tag', 'btnUpArrow', ...
                'Style', 'pushbutton', ...
                'TooltipString', 'Move selected stage up', ...
                'String', '', ...
                'HorizontalAlignment', 'center', ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''btnUpArrowCallback'');']);
            
            PushbuttonParam(obj, 'btnDownArrow', 1, 1);
            set(get_ghandle(btnDownArrow), ...
                'Parent', handles.uipanelTrainingStages, ...
                'Units', 'normalized', ...
                'Position', [0.659631 0.457898 0.108179 0.237305], ...
                'CData', downarrow_cdata, ...
                'Tag', 'btnDownArrow', ...
                'Style', 'pushbutton', ...
                'TooltipString', 'Move selected stage down', ...
                'String', '', ...
                'HorizontalAlignment', 'center', ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''btnDownArrowCallback'');']);
            
            ToggleParam(obj, 'btnToggleDeactivationStatus', false, 1, 1, 'OnString', '', 'OffString', '');
            set(get_ghandle(btnToggleDeactivationStatus), ...
                'Parent', handles.uipanelTrainingStages, ...
                'Units', 'normalized', ...
                'Position', [0.659631 0.220814 0.108179 0.237305], ...
                'CData', crossmark_cdata, ...
                'Tag', 'btnToggleDeactivationStatus', ...
                'Style', 'togglebutton', ...
                'TooltipString', 'Toggle deactivation status', ...
                'String', '', ...
                'HorizontalAlignment', 'center', ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''btnToggleDeactivationStatusCallback'');']);
            
            PushbuttonParam(obj, 'btnAdd', 1, 1);
            set(get_ghandle(btnAdd), ...
                'Parent', handles.uipanelTrainingStages, ...
                'Units', 'normalized', ...
                'Position', [0.775726 0.807944 0.182058 0.124271], ...
                'String', 'ADD', ...
                'Style', 'pushbutton', ...
                'Tag', 'btnAdd', ...
                'TooltipString', 'Add training stage', ...
                'HorizontalAlignment', 'center', ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''btnAddCallback'');']);
            
            PushbuttonParam(obj, 'btnDelete', 1, 1);
            set(get_ghandle(btnDelete), ...
                'Parent', handles.uipanelTrainingStages, ...
                'Units', 'normalized', ...
                'Position', [0.775726 0.683672 0.182058 0.124271], ...
                'String', 'DELETE', ...
                'Style', 'pushbutton', ...
                'Tag', 'btnDelete', ...
                'TooltipString', 'Delete selected training stage', ...
                'HorizontalAlignment', 'center', ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''btnDeleteCallback'');']);
            
            %         PushbuttonParam(obj, 'btnFlush', 1, 1);
            %         set(get_ghandle(btnFlush), ...
            %             'Parent', handles.uipanelTrainingStages, ...
            %             'Units', 'normalized', ...
            %             'Position', [58.8 7.616 13.8 1.692], ...
            %             'String', 'FLUSH', ...
            %             'Style', 'pushbutton', ...
            %             'Tag', 'btnFlush', ...
            %             'TooltipString', 'Delete all training stages from the session automator window', ...
            %             'HorizontalAlignment', 'center', ...
            %             'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''btnFlushCallback'');']);
            
            PushbuttonParam(obj, 'btnActivate', 1, 1);
            set(get_ghandle(btnActivate), ...
                'Parent', handles.uipanelTrainingStages, ...
                'Units', 'normalized', ...
                'Position', [0.775726 0.559401 0.182058 0.124271], ...
                'String', 'ACTIVATE', ...
                'Style', 'pushbutton', ...
                'Tag', 'btnActivate', ...
                'TooltipString', 'Activate selected training stage', ...
                'HorizontalAlignment', 'center', ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''btnActivateCallback'');']);
            
            PushbuttonParam(obj, 'btnLoad', 1, 1);
            set(get_ghandle(btnLoad), ...
                'Parent', handles.uipanelTrainingStages, ...
                'Units', 'normalized', ...
                'Position', [0.775726 0.435130 0.182058 0.124271], ...
                'String', 'LOAD', ...
                'Style', 'pushbutton', ...
                'Tag', 'btnLoad', ...
                'TooltipString', 'Load training stages from M file', ...
                'HorizontalAlignment', 'center', ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''btnLoadCallback'');']);
            
            PushbuttonParam(obj, 'btnExport', 1, 1);
            set(get_ghandle(btnExport), ...
                'Parent', handles.uipanelTrainingStages, ...
                'Units', 'normalized', ...
                'Position', [0.775726 0.310859 0.182058 0.124271], ...
                'String', 'EXPORT', ...
                'Style', 'pushbutton', ...
                'Tag', 'btnExport', ...
                'TooltipString', 'Export training stages to M file', ...
                'HorizontalAlignment', 'center', ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''btnExportCallback'');']);
            
            filename = feval(mfilename, obj, 'generate_training_stage_file_name');
            filepath = fullfile(value(MAIN_DATA_DIRECTORY), 'Settings', SESSION_INFO.experimenter, SESSION_INFO.ratname, [filename '.m']);
            PushbuttonParam(obj, 'btnSave', 1, 1);
            set(get_ghandle(btnSave), ...
                'Parent', handles.uipanelTrainingStages, ...
                'Units', 'normalized', ...
                'Position', [0.775726 0.186588 0.182058 0.124271], ...
                'String', 'SAVE', ...
                'Style', 'pushbutton', ...
                'Tag', 'btnSave', ...
                'TooltipString', ['Save training stage file to ' filepath ' with today''s date, and add it to the repository.'], ...
                'HorizontalAlignment', 'center', ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''btnSaveCallback'');']);
            
            ListboxParam(obj, 'lbxTrainingStages', 1, 1, 1, 1);
            set(get_ghandle(lbxTrainingStages), ...
                'Parent', handles.uipanelTrainingStages, ...
                'Units', 'normalized', ...
                'BackgroundColor', 'white', ...
                'Position', [0.055409 0.101757 0.604222 0.830531], ...
                'Style', 'listbox', ...
                'Tag', 'lbxTrainingStages', ...
                'TooltipString', 'Training Stages', ...
                'String', '', ...
                'FontSize', 8.0, ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''lbxTrainingStagesCallback'');']);
            
            %Multiple overlapping edit windows
            EditParam(obj, 'editName', '', 1, 1);
            set(get_lhandle(editName), 'Visible', 'off');
            set(get_ghandle(editName), ...
                'Parent', handles.uipanelTrainingStageFileComponents, ...
                'Units', 'normalized', ...
                'Position', [0.028264 0.222206 0.674293 0.724255], ...
                'Style', 'edit', ...
                'BackgroundColor', 'white', ...
                'FontName', edit_window_font, ...
                'FontSize', 10, ...
                'Tag', 'editName', ...
                'String', '', ...
                'HorizontalAlignment', 'center', ...
                'Max', 1.0, ...
                'Visible', 'on');
            
            EditParam(obj, 'editCompletionTest', '', 1, 1);
            set(get_lhandle(editCompletionTest), 'Visible', 'off');
            set(get_ghandle(editCompletionTest), ...
                'Parent', handles.uipanelTrainingStageFileComponents, ...
                'Units', 'normalized', ...
                'Position', [0.028264 0.222206 0.674293 0.724255], ...
                'Style', 'edit', ...
                'BackgroundColor', 'white', ...
                'FontName', edit_window_font, ...
                'FontSize', 10, ...
                'Tag', 'editCompletionTest', ...
                'String', '', ...
                'HorizontalAlignment', 'left', ...
                'Max', 9999999.0, ...
                'Visible', 'off');
            
            EditParam(obj, 'editStageAlgorithm', '', 1, 1);
            set(get_lhandle(editStageAlgorithm), 'Visible', 'off');
            set(get_ghandle(editStageAlgorithm), ...
                'Parent', handles.uipanelTrainingStageFileComponents, ...
                'Units', 'normalized', ...
                'Position', [0.028264 0.222206 0.674293 0.724255], ...
                'Style', 'edit', ...
                'BackgroundColor', 'white', ...
                'FontName', edit_window_font, ...
                'FontSize', 10, ...
                'Tag', 'editStageAlgorithm', ...
                'String', '', ...
                'HorizontalAlignment', 'left', ...
                'Max', 9999999.0, ...
                'Visible', 'off');
            
            EditParam(obj, 'editHelperVars', '', 1, 1);
            set(get_lhandle(editHelperVars), 'Visible', 'off');
            set(get_ghandle(editHelperVars), ...
                'Parent', handles.uipanelTrainingStageFileComponents, ...
                'Units', 'normalized', ...
                'Position', [0.028264 0.222206 0.674293 0.724255], ...
                'Style', 'edit', ...
                'BackgroundColor', 'white', ...
                'FontName', edit_window_font, ...
                'FontSize', 10, ...
                'Tag', 'editHelperVars', ...
                'String', '', ...
                'HorizontalAlignment', 'left', ...
                'Max', 9999999.0, ...
                'Visible', 'off');
            
            EditParam(obj, 'editEODLogic', '', 1, 1);
            set(get_lhandle(editEODLogic), 'Visible', 'off');
            set(get_ghandle(editEODLogic), ...
                'Parent', handles.uipanelTrainingStageFileComponents, ...
                'Units', 'normalized', ...
                'Position', [0.028264 0.222206 0.674293 0.724255], ...
                'Style', 'edit', ...
                'BackgroundColor', 'white', ...
                'FontName', edit_window_font, ...
                'FontSize', 10, ...
                'Tag', 'editEODLogic', ...
                'String', '', ...
                'HorizontalAlignment', 'left', ...
                'Max', 9999999.0, ...
                'Visible', 'off');
            
            EditParam(obj, 'editHelperFunctions', '', 1, 1);
            set(get_lhandle(editHelperFunctions), 'Visible', 'off');
            set(get_ghandle(editHelperFunctions), ...
                'Parent', handles.uipanelTrainingStageFileComponents, ...
                'Units', 'normalized', ...
                'Position', [0.028264 0.222206 0.674293 0.724255], ...
                'Style', 'edit', ...
                'BackgroundColor', 'white', ...
                'FontName', edit_window_font, ...
                'FontSize', 10, ...
                'Tag', 'editHelperFunctions', ...
                'String', '', ...
                'HorizontalAlignment', 'left', ...
                'Max', 9999999.0, ...
                'Visible', 'off');
            
            HeaderParam(obj, 'textTrainingStageFile', 'Training Stage File', 1, 1);
            set(get_ghandle(textTrainingStageFile), ...
                'Parent', handles.uipanelTrainingStageFileComponents, ...
                'Units', 'normalized', ...
                'Position', [0.028264 0.148111 0.674293 0.069975], ...
                'Style', 'text', ...
                'Tag', 'textTrainingStageFile', ...
                'String', 'Training Stage File', ...
                'TooltipString', 'Training Stage File', ...
                'HorizontalAlignment', 'center', ...
                'FontSize', 8.0, ...
                'FontWeight', 'normal', ...
                'BackgroundColor', 'green');
            
            uicontrol('Parent', handles.uipanelTrainingStageFileComponents, ...
                'Units', 'normalized', ...
                'Position', [0.718708 0.851823 0.253028 0.094638], ...
                'Style', 'radiobutton', ...
                'String', 'Name', ...
                'Tag', 'radioName', ...
                'Value', true, ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''radioNameCallback'');']);
            
            uicontrol('Parent', handles.uipanelTrainingStageFileComponents, ...
                'Units', 'normalized', ...
                'Position', [0.718708 0.761305 0.253028 0.094638], ...
                'Style', 'radiobutton', ...
                'String', 'Completion Test', ...
                'Tag', 'radioCompletionTest', ...
                'Value', false, ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''radioCompletionTestCallback'');']);
            
            uicontrol('Parent', handles.uipanelTrainingStageFileComponents, ...
                'Units', 'normalized', ...
                'Position', [0.718708 0.670733 0.253028 0.094638], ...
                'Style', 'radiobutton', ...
                'String', 'End-of-day logic', ...
                'Tag', 'radioEODLogic', ...
                'Value', false, ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''radioEODLogicCallback'');']);
            
            uicontrol('Parent', handles.uipanelTrainingStageFileComponents, ...
                'Units', 'normalized', ...
                'Position', [0.718708 0.580214 0.253028 0.094638], ...
                'Style', 'radiobutton', ...
                'String', 'Stage Algorithm', ...
                'Tag', 'radioStageAlgorithm', ...
                'Value', false, ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''radioStageAlgorithmCallback'');']);
            
            uicontrol('Parent', handles.uipanelTrainingStageFileComponents, ...
                'Units', 'normalized', ...
                'Position', [0.718708 0.489695 0.253028 0.094638], ...
                'Style', 'radiobutton', ...
                'String', 'Helper Vars', ...
                'Tag', 'radioHelperVars', ...
                'Value', false, ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''radioHelperVarsCallback'');']);
            
            uicontrol('Parent', handles.uipanelTrainingStageFileComponents, ...
                'Units', 'normalized', ...
                'Position', [0.718708 0.399177 0.253028 0.094638], ...
                'Style', 'radiobutton', ...
                'String', 'Helper Functions', ...
                'Tag', 'radioHelperFunctions', ...
                'TooltipString', 'Helper Functions (common to all stages)', ...
                'Value', false, ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''radioHelperFunctionsCallback'');']);
            
            PushbuttonParam(obj, 'btnReinitializeHelperVars', 1, 1);
            set(get_ghandle(btnReinitializeHelperVars), ...
                'Parent', handles.uipanelTrainingStageFileComponents, ...
                'Units', 'normalized', ...
                'Position', [0.028264 0.057593 0.235532 0.094638], ...
                'Style', 'pushbutton', ...
                'String', 'REINITIALIZE HELPER VARS', ...
                'Tag', 'btnReinitializeHelperVars', ...
                'TooltipString', 'Reinitialize all helper vars for the current active stage', ...
                'HorizontalAlignment', 'center', ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''btnReinitializeHelperVarsCallback'');']);
            
            PushbuttonParam(obj, 'btnInstantiateHelperVars', 1, 1);
            set(get_ghandle(btnInstantiateHelperVars), ...
                'Parent', handles.uipanelTrainingStageFileComponents, ...
                'Units', 'normalized', ...
                'Position', [0.262450 0.057593 0.235532 0.094638], ...
                'Style', 'pushbutton', ...
                'String', 'INSTANTIATE HELPER VARS', ...
                'Tag', 'btnInstantiateHelperVars', ...
                'TooltipString', 'Instantiate all helper vars for the current active stage in the base workspace', ...
                'HorizontalAlignment', 'center', ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''btnInstantiateHelperVarsCallback'');']);
            
            PushbuttonParam(obj, 'btnCompletionTest', 1, 1);
            set(get_ghandle(btnCompletionTest), ...
                'Parent', handles.uipanelTrainingStageFileComponents, ...
                'Units', 'normalized', ...
                'Position', [0.496635 0.057593 0.205922 0.094638], ...
                'Style', 'pushbutton', ...
                'String', 'COMPLETION TEST', ...
                'Tag', 'btnCompletionTest', ...
                'TooltipString', 'Run completion test for the active stage', ...
                'HorizontalAlignment', 'center', ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''btnCompletionTestCallback'');']);
            
            PushbuttonParam(obj, 'btnUpdate', 1, 1);
            set(get_ghandle(btnUpdate), ...
                'Parent', handles.uipanelTrainingStageFileComponents, ...
                'Units', 'normalized', ...
                'Position', [0.718708 0.267465 0.092867 0.090519], ...
                'Style', 'pushbutton', ...
                'String', 'UPDATE', ...
                'Tag', 'btnUpdate', ...
                'TooltipString', 'Update selected training stage', ...
                'HorizontalAlignment', 'center', ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''btnUpdateCallback'');']);
            
            PushbuttonParam(obj, 'btnOpenFile', 1, 1);
            set(get_ghandle(btnOpenFile), ...
                'Parent', handles.uipanelTrainingStageFileComponents, ...
                'Units', 'normalized', ...
                'Position', [0.810229 0.267465 0.092867 0.090519], ...
                'Style', 'pushbutton', ...
                'String', 'OPEN FILE', ...
                'Tag', 'btnOpenFile', ...
                'TooltipString', 'Open the current training stage file in the editor', ...
                'HorizontalAlignment', 'center', ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''btnOpenFileCallback'');']);
            
            PushbuttonParam(obj, 'btnReload', 1, 1);
            set(get_ghandle(btnReload), ...
                'Parent', handles.uipanelTrainingStageFileComponents, ...
                'Units', 'normalized', ...
                'Position', [0.901750 0.267465 0.092867 0.090519], ...
                'Style', 'pushbutton', ...
                'String', 'RELOAD', ...
                'Tag', 'btnReload', ...
                'TooltipString', 'Reload the current training stage file', ...
                'HorizontalAlignment', 'center', ...
                'Callback', ['feval(''' mfilename ''', ' class(obj) ', ''btnReloadCallback'');']);
            
            %%
            
            handles = guihandles(hndl);
            
            %Populate parameter list
            set(handles.lbxParameters, 'String', sort(GetSoloFunctionArgList(['@' class(obj)], 'SessionModel')));
            lbxParameters_String.value = sort(GetSoloFunctionArgList(['@' class(obj)], 'SessionModel'));
            
            if exist('myfig', 'var')
                figure(myfig);
            end
            
            %If a training stage file exists for the given ratname and
            %experimenter, get the most recent training stage file which is not
            %meant for later than the current date.
            %The training stage file name is to have the following format:
            %pipeline_<Protocol_Name>_<Experimenter>_<ratname>_<yearmonthday>
            %.m
            
            if ~should_flush
                feval(mfilename, obj, 'autoload_latest_training_stage_file');
            end
            
            %% autoload_latest_training_stage_file
        case 'autoload_latest_training_stage_file'
            training_stage_file_path = get_latest_training_stage_file_path(SESSION_INFO.experimenter, SESSION_INFO.ratname, SESSION_INFO.protocol);
            if exist(training_stage_file_path, 'file') && ~isdir(training_stage_file_path)
                training_stage_file_dir = fileparts(training_stage_file_path);
                currpath = path;
                if training_stage_file_dir(end)==filesep
                    training_stage_file_dir = training_stage_file_dir(1:end-1);
                end
                if isempty(strfind(currpath, training_stage_file_dir))
                    addpath(training_stage_file_dir);
                    REMOVE_THESE_PATHS{end+1} = training_stage_file_dir; %#ok<NASGU>
                end
                feval(mfilename, obj, 'load_stagefile', training_stage_file_path);
            end
            
            
            %% get_training_stages_file_name
        case 'get_training_stages_file_name'
            %SessionDefinition(obj, 'get_training_stages_file_name');
            if nargin>2
                error('Too many arguments. The number of arguments has to be 2.');
            end
            varargout{1} = value(CURRENT_TRAINING_STAGES_FILE_NAME);
            
            %% reinit_helper_vars
        case 'reinit_helper_vars'
            %SessionDefinition(obj, 'reinit_helper_vars', <helper_var_name_list>)
            if nargin~=2 && nargin~=3
                error('Invalid number of arguments. The number of arguments has to be either 2 or 3.');
            elseif nargin==3
                if ~ischar(varargin{1}) && ~iscellstr(varargin{1})
                    error('helper_var_name_list has to be either a string or a cell array of strings.');
                end
            end
            
            if ~isempty(value(GLOBAL_HELPER_VAR_NAME_LIST))
                if nargin==2
                    helper_var_name_list = struct2cell(GLOBAL_HELPER_VAR_NAME_LIST(:));
                    if ~isempty(helper_var_name_list)
                        helper_var_name_list = helper_var_name_list(1,:);
                    end
                elseif nargin==3
                    if ischar(varargin{1})
                        varargin{1} = {varargin{1}};
                    end
                    helper_var_name_list = unique(varargin{1});
                end
                
                for ctr = 1:length(GLOBAL_HELPER_VAR_NAME_LIST)
                    if ismember(GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name, helper_var_name_list) && ...
                            exist(GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name, 'var') && ...
                            isa(eval(GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name), 'SoloParamHandle')
                        eval([GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name '.value = GLOBAL_HELPER_VAR_NAME_LIST(ctr).initial_value;']);
                        set_userprop(eval(GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name), 'initial_value', GLOBAL_HELPER_VAR_NAME_LIST(ctr).initial_value);
                    end
                end
            end
            
            %% base_instantiate_helper_vars
        case 'base_instantiate_helper_vars'
            %SessionDefinition(obj, 'base_instantiate_helper_vars', <helper_var_name_list>);
            if nargin~=2 && nargin~=3
                error('Invalid number of arguments. The number of arguments has to be 2 or 3.');
            elseif nargin==3
                if ~ischar(varargin{1}) && ~iscellstr(varargin{1})
                    error('helper_var_name_list has to be either a string or a cell array of strings.');
                end
            end
            
            if ~isempty(value(GLOBAL_HELPER_VAR_NAME_LIST))
                if nargin==2
                    helper_var_name_list = struct2cell(GLOBAL_HELPER_VAR_NAME_LIST(:));
                    if ~isempty(helper_var_name_list)
                        helper_var_name_list = helper_var_name_list(1,:);
                    end
                elseif nargin==3
                    if ischar(varargin{1})
                        varargin{1} = {varargin{1}};
                    end
                    helper_var_name_list = unique(varargin{1});
                end
                
                for ctr = 1:length(GLOBAL_HELPER_VAR_NAME_LIST)
                    if ismember(GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name, helper_var_name_list) && ...
                            exist(GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name, 'var') && ...
                            isa(eval(GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name), 'SoloParamHandle')
                        try
                            assignin('base', GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name, eval(GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name));
                        catch
                            warning(['@' class(obj) ':' mfilename ':base_instantiate_helper_vars'], ['Unable to instantiate ' GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name]);
                        end
                    end
                end
            end
            
            %% caller_instantiate_helper_vars
        case 'caller_instantiate_helper_vars'
            %SessionDefinition(obj, 'caller_instantiate_helper_vars', <helper_var_name_list>)
            if nargin~=2 && nargin~=3
                error('Invalid number of arguments. The number of arguments has to be 2 or 3.');
            elseif nargin==3
                if ~ischar(varargin{1}) && ~iscellstr(varargin{1})
                    error('helper_var_name_list has to be either a string or a cell array of strings.');
                end
            end
            
            if ~isempty(value(GLOBAL_HELPER_VAR_NAME_LIST))
                if nargin==2
                    helper_var_name_list = struct2cell(GLOBAL_HELPER_VAR_NAME_LIST(:));
                    if ~isempty(helper_var_name_list)
                        helper_var_name_list = helper_var_name_list(1,:);
                    end
                elseif nargin==3
                    if ischar(varargin{1})
                        varargin{1} = {varargin{1}};
                    end
                    helper_var_name_list = unique(varargin{1});
                end
                
                for ctr = 1:length(GLOBAL_HELPER_VAR_NAME_LIST)
                    if ismember(GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name, helper_var_name_list) && ...
                            exist(GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name, 'var') && ...
                            isa(eval(GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name), 'SoloParamHandle')
                        try
                            assignin('caller', GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name, eval(GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name));
                        catch
                            warning(['@' class(obj) ':' mfilename ':caller_instantiate_helper_vars'], ['Unable to instantiate ' GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name]);
                        end
                    end
                end
            end
            
            %% btnSearchCallback
        case 'btnSearchCallback'
            %SessionDefinition(obj, 'btnSearchCallback'): Callback for
            %btnSearch
            feval(mfilename, obj, 'refresh_lbxParameters');
            
            %% btnResetCallback
        case 'btnResetCallback'
            %SessionDefinition(obj, 'btnResetCallback'): Callback for btnReset
            editParameterSearchString.value = '';
            feval(mfilename, obj, 'refresh_lbxParameters');
            
            %% hide_show
        case 'hide_show'
            %SessionDefinition(obj, 'hide_show')
            is_visible = get(value(session_automator_window), 'Visible');
            if strcmpi(is_visible, 'on')
                set(value(session_automator_window), 'Visible', 'off');
            else
                set(value(session_automator_window), 'Visible', 'on');
            end
            
            %% delete
        case 'delete'
            %SessionDefinition(obj, 'delete'): Called automatically when the
            %protocol is closed.
            try
                delete(value(session_automator_window));
            catch
                warning(['@' class(obj) ':' mfilename ':DeleteSessionAutomatorWindowFailed'], 'Unable to delete the session automator window.');
            end
            
            for ctr = 1:length(DELETE_THESE_FILES)
                if exist(DELETE_THESE_FILES{ctr}, 'file')
                    %Hack: On windows, the drive name has to be specified
                    if ispc && ~strcmpi(strtok(DELETE_THESE_FILES{ctr}, filesep), getenv('HOMEDRIVE'))
                        DELETE_THESE_FILES{ctr} = fullfile(getenv('HOMEDRIVE'), DELETE_THESE_FILES{ctr}); %#ok<AGROW>
                    end
                    delete(DELETE_THESE_FILES{ctr});
                end
            end
            for ctr = 1:length(REMOVE_THESE_PATHS)
                rmpath(REMOVE_THESE_PATHS{ctr});
            end
            
            
            %% hide
        case 'hide'
            set(value(session_automator_window), 'Visible', 'off');
            session_show.value = false;
            
            %% btnUpArrowCallback
        case 'btnUpArrowCallback'
            %SessionDefinition(obj, 'btnUpArrowCallback'): Callback for
            %btnUpArrow.
            if ~isempty(value(CURRENT_TRAINING_STAGE_LIST))
                hndl = value(session_automator_window);
                handles = guihandles(hndl);
                selectedindex = get(handles.lbxTrainingStages, 'Value');
                %If the selected stage is not the topmost stage, then proceed
                if ~isequal(selectedindex, 1)
                    %Swap elements in CURRENT_TRAINING_STAGE_LIST
                    temp = CURRENT_TRAINING_STAGE_LIST(selectedindex);
                    CURRENT_TRAINING_STAGE_LIST(selectedindex) = CURRENT_TRAINING_STAGE_LIST(selectedindex - 1);
                    CURRENT_TRAINING_STAGE_LIST(selectedindex - 1) = temp;
                    
                    %Swap elements in CURRENT_STAGE_ALGORITHM_LIST
                    temp = CURRENT_STAGE_ALGORITHM_LIST{selectedindex};
                    CURRENT_STAGE_ALGORITHM_LIST{selectedindex} = CURRENT_STAGE_ALGORITHM_LIST{selectedindex - 1};
                    CURRENT_STAGE_ALGORITHM_LIST{selectedindex - 1} = temp;
                    
                    %Swap elements in CURRENT_EOD_LOGIC_LIST
                    temp = CURRENT_EOD_LOGIC_LIST{selectedindex};
                    CURRENT_EOD_LOGIC_LIST{selectedindex} = CURRENT_EOD_LOGIC_LIST{selectedindex - 1};
                    CURRENT_EOD_LOGIC_LIST{selectedindex - 1} = temp;
                    
                    %Swap elements in CURRENT_COMPLETION_TEST_LIST
                    temp = CURRENT_COMPLETION_TEST_LIST{selectedindex};
                    CURRENT_COMPLETION_TEST_LIST{selectedindex} = CURRENT_COMPLETION_TEST_LIST{selectedindex - 1};
                    CURRENT_COMPLETION_TEST_LIST{selectedindex - 1} = temp;
                    
                    %Swap elements in CURRENT_HELPER_VAR_LIST
                    temp = CURRENT_HELPER_VAR_LIST{selectedindex};
                    CURRENT_HELPER_VAR_LIST{selectedindex} = CURRENT_HELPER_VAR_LIST{selectedindex - 1};
                    CURRENT_HELPER_VAR_LIST{selectedindex - 1} = temp;
                    
                    %If the selected stage was the active stage, this must not
                    %change
                    if isequal(selectedindex, value(CURRENT_ACTIVE_STAGE))
                        CURRENT_ACTIVE_STAGE.value = selectedindex - 1;
                    elseif isequal(selectedindex - 1, value(CURRENT_ACTIVE_STAGE))
                        CURRENT_ACTIVE_STAGE.value = selectedindex;
                    end
                    
                    %If the selected stage was a previously active stage, this
                    %must not change
                    if isequal(selectedindex, value(PREVIOUS_ACTIVE_STAGE))
                        PREVIOUS_ACTIVE_STAGE.value = selectedindex - 1;
                    elseif isequal(selectedindex - 1, value(PREVIOUS_ACTIVE_STAGE))
                        PREVIOUS_ACTIVE_STAGE.value = selectedindex;
                    end
                    
                    %If the selected stage was a deactivated stage, this must not
                    %change
                    if ismember(selectedindex, value(CURRENT_DEACTIVATED_STAGES)) && ~ismember(selectedindex-1, value(CURRENT_DEACTIVATED_STAGES))
                        CURRENT_DEACTIVATED_STAGES.value = setdiff(value(CURRENT_DEACTIVATED_STAGES), selectedindex);
                        CURRENT_DEACTIVATED_STAGES(end+1) = selectedindex - 1;
                        CURRENT_DEACTIVATED_STAGES.value = sort(value(CURRENT_DEACTIVATED_STAGES));
                    elseif ismember(selectedindex-1, value(CURRENT_DEACTIVATED_STAGES)) && ~ismember(selectedindex, value(CURRENT_DEACTIVATED_STAGES))
                        CURRENT_DEACTIVATED_STAGES.value = setdiff(value(CURRENT_DEACTIVATED_STAGES), selectedindex-1);
                        CURRENT_DEACTIVATED_STAGES(end+1) = selectedindex;
                        CURRENT_DEACTIVATED_STAGES.value = sort(value(CURRENT_DEACTIVATED_STAGES));
                    end
                    
                    STARTING_ACTIVE_STAGE.value = value(CURRENT_ACTIVE_STAGE);
                    STARTING_DEACTIVATED_STAGES.value = value(CURRENT_DEACTIVATED_STAGES);
                    
                    set(handles.lbxTrainingStages, 'Value', selectedindex - 1);
                    
                    write_data_to_training_stage_file(value(CURRENT_TRAINING_STAGE_LIST), ...
                        value(CURRENT_STAGE_ALGORITHM_LIST), ...
                        value(CURRENT_COMPLETION_TEST_LIST), ...
                        value(CURRENT_EOD_LOGIC_LIST), ...
                        value(CURRENT_HELPER_VAR_LIST), ...
                        value(CURRENT_HELPER_FUNCTION_LIST), ...
                        value(CURRENT_TRAINING_STAGES_FILE_PATH));
                    
                    feval(mfilename, obj, 'refresh_lbxTrainingStages');
                end
            end
            
            %% btnDownArrowCallback
        case 'btnDownArrowCallback'
            %SessionDefinition(obj, 'btnDownArrowCallback'): Callback for
            %btnDownArrow
            if ~isempty(value(CURRENT_TRAINING_STAGE_LIST))
                hndl = value(session_automator_window);
                handles = guihandles(hndl);
                selectedindex = get(handles.lbxTrainingStages, 'Value');
                %If the selected stage is not the topmost stage, then proceed
                if ~isequal(selectedindex, length(value(CURRENT_TRAINING_STAGE_LIST)))
                    %Swap elements in CURRENT_TRAINING_STAGE_LIST
                    temp = CURRENT_TRAINING_STAGE_LIST(selectedindex);
                    CURRENT_TRAINING_STAGE_LIST(selectedindex) = CURRENT_TRAINING_STAGE_LIST(selectedindex + 1);
                    CURRENT_TRAINING_STAGE_LIST(selectedindex + 1) = temp;
                    
                    %Swap elements in CURRENT_STAGE_ALGORITHM_LIST
                    temp = CURRENT_STAGE_ALGORITHM_LIST{selectedindex};
                    CURRENT_STAGE_ALGORITHM_LIST{selectedindex} = CURRENT_STAGE_ALGORITHM_LIST{selectedindex + 1};
                    CURRENT_STAGE_ALGORITHM_LIST{selectedindex + 1} = temp;
                    
                    %Swap elements in CURRENT_EOD_LOGIC_LIST
                    temp = CURRENT_EOD_LOGIC_LIST{selectedindex};
                    CURRENT_EOD_LOGIC_LIST{selectedindex} = CURRENT_EOD_LOGIC_LIST{selectedindex + 1};
                    CURRENT_EOD_LOGIC_LIST{selectedindex + 1} = temp;
                    
                    %Swap elements in CURRENT_COMPLETION_TEST_LIST
                    temp = CURRENT_COMPLETION_TEST_LIST{selectedindex};
                    CURRENT_COMPLETION_TEST_LIST{selectedindex} = CURRENT_COMPLETION_TEST_LIST{selectedindex + 1};
                    CURRENT_COMPLETION_TEST_LIST{selectedindex + 1} = temp;
                    
                    %Swap elements in CURRENT_HELPER_VAR_LIST
                    temp = CURRENT_HELPER_VAR_LIST{selectedindex};
                    CURRENT_HELPER_VAR_LIST{selectedindex} = CURRENT_HELPER_VAR_LIST{selectedindex + 1};
                    CURRENT_HELPER_VAR_LIST{selectedindex + 1} = temp;
                    
                    %If the selected stage was the active stage, this must not
                    %change
                    if isequal(selectedindex, value(CURRENT_ACTIVE_STAGE))
                        CURRENT_ACTIVE_STAGE.value = selectedindex + 1;
                    elseif isequal(selectedindex + 1, value(CURRENT_ACTIVE_STAGE))
                        CURRENT_ACTIVE_STAGE.value = selectedindex;
                    end
                    
                    %If the selected stage was a previously active stage, this
                    %must not change
                    if isequal(selectedindex, value(PREVIOUS_ACTIVE_STAGE))
                        PREVIOUS_ACTIVE_STAGE.value = selectedindex + 1;
                    elseif isequal(selectedindex + 1, value(PREVIOUS_ACTIVE_STAGE))
                        PREVIOUS_ACTIVE_STAGE.value = selectedindex;
                    end
                    
                    %If the selected stage was a deactivated stage, this must not
                    %change
                    if ismember(selectedindex, value(CURRENT_DEACTIVATED_STAGES)) && ~ismember(selectedindex+1, value(CURRENT_DEACTIVATED_STAGES))
                        CURRENT_DEACTIVATED_STAGES.value = setdiff(value(CURRENT_DEACTIVATED_STAGES), selectedindex);
                        CURRENT_DEACTIVATED_STAGES(end+1) = selectedindex + 1;
                        CURRENT_DEACTIVATED_STAGES.value = sort(value(CURRENT_DEACTIVATED_STAGES));
                    elseif ismember(selectedindex+1, value(CURRENT_DEACTIVATED_STAGES)) && ~ismember(selectedindex, value(CURRENT_DEACTIVATED_STAGES))
                        CURRENT_DEACTIVATED_STAGES.value = setdiff(value(CURRENT_DEACTIVATED_STAGES), selectedindex+1);
                        CURRENT_DEACTIVATED_STAGES(end+1) = selectedindex;
                        CURRENT_DEACTIVATED_STAGES.value = sort(value(CURRENT_DEACTIVATED_STAGES));
                    end
                    
                    STARTING_ACTIVE_STAGE.value = value(CURRENT_ACTIVE_STAGE);
                    STARTING_DEACTIVATED_STAGES.value = value(CURRENT_DEACTIVATED_STAGES);
                    
                    set(handles.lbxTrainingStages, 'Value', selectedindex + 1);
                    
                    write_data_to_training_stage_file(value(CURRENT_TRAINING_STAGE_LIST), ...
                        value(CURRENT_STAGE_ALGORITHM_LIST), ...
                        value(CURRENT_COMPLETION_TEST_LIST), ...
                        value(CURRENT_EOD_LOGIC_LIST), ...
                        value(CURRENT_HELPER_VAR_LIST), ...
                        value(CURRENT_HELPER_FUNCTION_LIST), ...
                        value(CURRENT_TRAINING_STAGES_FILE_PATH));
                    
                    feval(mfilename, obj, 'refresh_lbxTrainingStages');
                end
            end
            
            %% lbxTrainingStagesCallback
        case 'lbxTrainingStagesCallback'
            %SessionDefinition(obj, 'lbxTrainingStagesCallback'): Callback for
            %lbxTrainingStages
            hndl = value(session_automator_window);
            handles = guihandles(hndl);
            if ~isempty(value(CURRENT_TRAINING_STAGE_LIST))
                selectedindex = get(handles.lbxTrainingStages, 'Value');
                editStageAlgorithm.value = value(CURRENT_STAGE_ALGORITHM_LIST{selectedindex});
                editCompletionTest.value = value(CURRENT_COMPLETION_TEST_LIST{selectedindex});
                editName.value = value(CURRENT_TRAINING_STAGE_LIST{selectedindex});
                editEODLogic.value = value(CURRENT_EOD_LOGIC_LIST{selectedindex});
                editHelperVars.value = value(CURRENT_HELPER_VAR_LIST{selectedindex});
                
                if ismember(selectedindex, value(CURRENT_DEACTIVATED_STAGES))
                    set(handles.btnToggleDeactivationStatus, 'Value', true);
                else
                    set(handles.btnToggleDeactivationStatus, 'Value', false);
                end
            end
            
            %% lbxParametersCallback
        case 'lbxParametersCallback'
            if strcmp(get(value(session_automator_window), 'SelectionType'), 'open')
                %A double click event was encountered
                
                %Get the handle of the visible edit window
                handles = guihandles(value(session_automator_window));
                hndl = findobj(findall(value(session_automator_window)), 'Style', 'edit', 'Visible', 'on', 'Parent', handles.uipanelTrainingStageFileComponents);
                
                if ~isempty(hndl)
                    hndlstr = getascell(hndl(1), 'String');
                    if isempty(hndlstr)
                        hndlstr = {''};
                    end
                    if length(hndlstr)<get(hndl(1), 'Max') && ~isempty(hndlstr{end})
                        hndlstr{end+1} = '';
                    end
                    
                    %Get the selected parameter
                    lbxParameters_str = get(handles.lbxParameters, 'String');
                    selected_index = get(handles.lbxParameters, 'Value');
                    if ~isempty(lbxParameters_str{selected_index})
                        hndlstr{end} = [hndlstr{end} lbxParameters_str{selected_index} '.value = '];
                        
                        %Set the new value
                        if length(hndlstr)==1
                            eval([get(hndl(1), 'Tag') '.value = hndlstr{1};']); %Convention: Tag name is the same as sph name
                        else
                            eval([get(hndl(1), 'Tag') '.value = hndlstr;']);
                        end
                        uicontrol(hndl(1));
                    end
                end
            end
            
            %% btnAddCallback
        case 'btnAddCallback'
            %SessionDefinition(obj, 'btnAddCallback'): Callback for btnAdd
            hndl = value(session_automator_window);
            handles = guihandles(hndl);
            CURRENT_TRAINING_STAGES_FILE_PATH.value = strrep(get(handles.textTrainingStageFile, 'String'), 'Training Stage File', '');
            file_name = CURRENT_TRAINING_STAGES_FILE_PATH(find(value(CURRENT_TRAINING_STAGES_FILE_PATH)==filesep, 1, 'last')+1:end);
            CURRENT_TRAINING_STAGES_FILE_NAME.value = file_name(1:end-2);
            if isempty(strtrim(strrep(char(get(handles.editName, 'String')), '''', '')))
                msgbox('Unable to add. The training stage name is empty.', ...
                    'Unable to add', 'modal');
            else
                %If a training stage file is not already loaded, prompt the
                %user to save
                should_continue_adding = true;
                if isempty(value(CURRENT_TRAINING_STAGES_FILE_PATH))
                    generated_file_name = feval(mfilename, obj, 'generate_training_stage_file_name');
                    [filename, pathname] = uiputfile({'*.m', 'M-file (*.m)'}, 'Save Training Stage File As', ...
                        fullfile(value(MAIN_DATA_DIRECTORY), 'Settings', SESSION_INFO.experimenter, SESSION_INFO.ratname, [generated_file_name '.m']));
                    if isequal(filename, 0) || isequal(pathname, 0)
                        should_continue_adding = false;
                    else
                        absolute_file_path = fullfile(pathname, filename);
                        CURRENT_TRAINING_STAGES_FILE_PATH.value = absolute_file_path;
                        textTrainingStageFile.value = absolute_file_path;
                        %set(handles.textTrainingStageFile, 'String', absolute_file_path);
                        set(handles.textTrainingStageFile, 'TooltipString', absolute_file_path);
                        [dummy, CURRENT_TRAINING_STAGES_FILE_NAME.value] = fileparts(absolute_file_path); clear('dummy'); %#ok<NASGU>
                    end
                end
                %Check to ensure that the name being added is not already in
                %use
                if should_continue_adding
                    if ismember(strtrim(strrep(char(get(handles.editName, 'String')), '''', '')), value(CURRENT_TRAINING_STAGE_LIST))
                        msgbox(['The training stage name ''' strtrim(strrep(char(get(handles.editName, 'String')), '''', '')) ''' is already in use. Please choose another.'], ...
                            'Name in use', 'modal');
                        should_continue_adding = false;
                    end
                end
                
                if should_continue_adding
                    if isnan(value(CURRENT_ACTIVE_STAGE))
                        CURRENT_ACTIVE_STAGE.value = 1;
                    end
                    CURRENT_TRAINING_STAGE_LIST{end+1} = strtrim(strrep(char(get(handles.editName, 'String')), '''', ''));
                    CURRENT_STAGE_ALGORITHM_LIST{end+1} = regexprep(getascell(handles.editStageAlgorithm, 'String'), '\s+$', '');
                    CURRENT_EOD_LOGIC_LIST{end+1} = regexprep(getascell(handles.editEODLogic, 'String'), '\s+$', '');
                    CURRENT_COMPLETION_TEST_LIST{end+1} = regexprep(getascell(handles.editCompletionTest, 'String'), '\s+$', '');
                    CURRENT_HELPER_FUNCTION_LIST.value = regexprep(getascell(handles.editHelperFunctions, 'String'), '\s+$', '');
                    CURRENT_HELPER_VAR_LIST{end+1} = regexprep(getascell(handles.editHelperVars, 'String'), '\s+$', '');
                    
                    write_data_to_training_stage_file(value(CURRENT_TRAINING_STAGE_LIST), ...
                        value(CURRENT_STAGE_ALGORITHM_LIST), ...
                        value(CURRENT_COMPLETION_TEST_LIST), ...
                        value(CURRENT_EOD_LOGIC_LIST), ...
                        value(CURRENT_HELPER_VAR_LIST), ...
                        value(CURRENT_HELPER_FUNCTION_LIST), ...
                        value(CURRENT_TRAINING_STAGES_FILE_PATH));
                    
                    currpath = path;
                    pathname = fileparts(value(CURRENT_TRAINING_STAGES_FILE_PATH));
                    if pathname(end)==filesep
                        pathname = pathname(1:end-1);
                    end
                    if isempty(strfind(currpath, pathname))
                        addpath(pathname);
                        REMOVE_THESE_PATHS{end+1} = pathname; %#ok<NASGU>
                    end
                    
                    feval(mfilename, obj, 'refresh_lbxTrainingStages');
                    %Addition successful, now change the selected stage to the
                    %latest stage.
                    selectionindex = find(strcmp(value(CURRENT_TRAINING_STAGE_LIST), strtrim(strrep(char(get(handles.editName, 'String')), '''', ''))), 1, 'first');
                    set(handles.lbxTrainingStages, 'Value', selectionindex);
                end
            end
            
            
            %% btnDeleteCallback
        case 'btnDeleteCallback'
            %SessionDefinition(obj, 'btnDeleteCallback'): Callback for
            %btnDelete
            if ~isempty(value(CURRENT_TRAINING_STAGE_LIST))
                if length(CURRENT_TRAINING_STAGE_LIST)>1
                    answer = questdlg('Are you sure? The selected training stage and all associated helper vars will be irrecoverably deleted.', ...
                        'Are you sure?', 'YES', 'NO', 'NO');
                elseif length(CURRENT_TRAINING_STAGE_LIST)==1
                    answer = questdlg(['Are you sure? The selected training stage and all associated helper vars will be irrecoverably deleted. Also, since this is the last training stage in the file, deleting this training stage will result in the deletion of file ' value(CURRENT_TRAINING_STAGES_FILE_PATH) '.'], ...
                        'Are you sure?', 'YES', 'NO', 'NO');
                end
                if strcmp(answer, 'YES')
                    %Plenty of things to do here.
                    %1. The SoloParamHandles initialized in 'init' need to be adjusted
                    %2. The data has to be rewritten to the training stage file
                    %3. If an active stage or a deactivated stage was deleted, the
                    %   variables STARTING_DEACTIVATED_STAGES and
                    %   STARTING_ACTIVE_STAGE have to be adjusted accordingly.
                    %4. lbxTrainingStages and the various edit windows have to
                    %   have to be adjusted, along with lbxParameters.
                    %5. If the stage being deleted is the only stage, the
                    %   training stage file itself is deleted, because the
                    %   program cannot permit a training stage file with no
                    %   stages. This is identical to the flush section,
                    %   except the training stage file is deleted as well.
                    %6. Helper vars created for the training stage being
                    %   deleted must also be deleted
                    
                    if length(value(CURRENT_TRAINING_STAGE_LIST)) > 1
                        hndl = value(session_automator_window);
                        handles = guihandles(hndl);
                        oldindices = 1:length(value(CURRENT_TRAINING_STAGE_LIST));
                        selected_index = get(handles.lbxTrainingStages, 'Value');
                        if selected_index == length(value(CURRENT_TRAINING_STAGE_LIST))
                            set(handles.lbxTrainingStages, 'Value', selected_index-1);
                        end
                        remaining_indices = setdiff(oldindices, selected_index);
                        
                        %Step 1: Adjusting SoloParamHandles
                        deleted_training_stage_name = CURRENT_TRAINING_STAGE_LIST(selected_index);
                        
                        new_TRAINING_STAGE_LIST = CURRENT_TRAINING_STAGE_LIST(remaining_indices);
                        new_STAGE_ALGORITHM_LIST = CURRENT_STAGE_ALGORITHM_LIST(remaining_indices);
                        new_EOD_LOGIC_LIST = CURRENT_EOD_LOGIC_LIST(remaining_indices);
                        new_COMPLETION_TEST_LIST = CURRENT_COMPLETION_TEST_LIST(remaining_indices);
                        new_HELPER_VAR_LIST = CURRENT_HELPER_VAR_LIST(remaining_indices);
                        new_HELPER_FUNCTION_LIST = value(CURRENT_HELPER_FUNCTION_LIST);
                        
                        if selected_index < value(CURRENT_ACTIVE_STAGE) || ...
                                selected_index == value(CURRENT_ACTIVE_STAGE) && value(CURRENT_ACTIVE_STAGE) == length(value(CURRENT_TRAINING_STAGE_LIST))
                            new_ACTIVE_STAGE = value(CURRENT_ACTIVE_STAGE) - 1;
                        else
                            new_ACTIVE_STAGE = value(CURRENT_ACTIVE_STAGE);
                        end
                        
                        %If the selected index is equal to
                        %value(PREVIOUS_ACTIVE_STAGE), nullify it
                        if selected_index == value(PREVIOUS_ACTIVE_STAGE)
                            new_PREVIOUS_ACTIVE_STAGE = [];
                        elseif selected_index < value(PREVIOUS_ACTIVE_STAGE)
                            new_PREVIOUS_ACTIVE_STAGE = value(PREVIOUS_ACTIVE_STAGE) - 1;
                        else
                            new_PREVIOUS_ACTIVE_STAGE = value(PREVIOUS_ACTIVE_STAGE);
                        end
                        
                        new_DEACTIVATED_STAGES = value(CURRENT_DEACTIVATED_STAGES);
                        new_DEACTIVATED_STAGES(new_DEACTIVATED_STAGES == selected_index) = [];
                        new_DEACTIVATED_STAGES(new_DEACTIVATED_STAGES > selected_index) = new_DEACTIVATED_STAGES(new_DEACTIVATED_STAGES > selected_index) - 1;
                        
                        %Helper vars corresponding to deleted_training_stage_name
                        %must be deleted
                        for ctr = 1:length(GLOBAL_HELPER_VAR_NAME_LIST)
                            if strcmp(GLOBAL_HELPER_VAR_NAME_LIST(ctr).stage_name, deleted_training_stage_name)
                                if exist(GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name, 'var') && isa(eval(GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name), 'SoloParamHandle')
                                    delete(eval(GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name));
                                    clear(GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name);
                                end
                                GLOBAL_HELPER_VAR_NAME_LIST(ctr) = []; %#ok<AGROW>
                            end
                        end
                        %GLOBAL_HELPER_VAR_NAME_LIST = GLOBAL_HELPER_VAR_NAME_LIST(setdiff(oldindices, remove_indices));
                        
                        CURRENT_TRAINING_STAGE_LIST.value = new_TRAINING_STAGE_LIST;
                        CURRENT_STAGE_ALGORITHM_LIST.value = new_STAGE_ALGORITHM_LIST;
                        CURRENT_EOD_LOGIC_LIST.value = new_EOD_LOGIC_LIST;
                        CURRENT_COMPLETION_TEST_LIST.value = new_COMPLETION_TEST_LIST;
                        CURRENT_HELPER_VAR_LIST.value = new_HELPER_VAR_LIST;
                        CURRENT_HELPER_FUNCTION_LIST.value = new_HELPER_FUNCTION_LIST;
                        CURRENT_ACTIVE_STAGE.value = new_ACTIVE_STAGE;
                        PREVIOUS_ACTIVE_STAGE.value = new_PREVIOUS_ACTIVE_STAGE;
                        CURRENT_DEACTIVATED_STAGES.value = new_DEACTIVATED_STAGES;
                        STARTING_ACTIVE_STAGE.value = value(CURRENT_ACTIVE_STAGE);
                        STARTING_DEACTIVATED_STAGES.value = value(CURRENT_DEACTIVATED_STAGES);
                        
                        write_data_to_training_stage_file(value(CURRENT_TRAINING_STAGE_LIST), ...
                            value(CURRENT_STAGE_ALGORITHM_LIST), ...
                            value(CURRENT_COMPLETION_TEST_LIST), ...
                            value(CURRENT_EOD_LOGIC_LIST), ...
                            value(CURRENT_HELPER_VAR_LIST), ...
                            value(CURRENT_HELPER_FUNCTION_LIST), ...
                            value(CURRENT_TRAINING_STAGES_FILE_PATH));
                        
                        feval(mfilename, obj, 'refresh_lbxTrainingStages');
                        feval(mfilename, obj, 'refresh_lbxParameters');
                        feval(mfilename, obj, 'lbxTrainingStagesCallback');
                    elseif length(value(CURRENT_TRAINING_STAGE_LIST)) == 1
                        delete(value(CURRENT_TRAINING_STAGES_FILE_PATH));
                        old_file_path = value(CURRENT_TRAINING_STAGES_FILE_PATH);
                        old_file_name = value(CURRENT_TRAINING_STAGES_FILE_NAME);
                        selected_radiobutton_hndl = findobj(value(session_automator_window), 'Style', 'radiobutton', 'Value', true);
                        selected_radiobutton_Callback = get(selected_radiobutton_hndl(1), 'Callback');
                        feval(mfilename, obj, 'init', 'flush');
                        GetSoloFunctionArgs(obj);
                        CURRENT_TRAINING_STAGES_FILE_PATH.value = old_file_path;
                        CURRENT_TRAINING_STAGES_FILE_NAME.value = old_file_name;
                        handles = guihandles(value(session_automator_window));
                        textTrainingStageFile.value = value(CURRENT_TRAINING_STAGES_FILE_PATH);
                        %set(handles.textTrainingStageFile, 'String', value(CURRENT_TRAINING_STAGES_FILE_PATH));
                        set(handles.textTrainingStageFile, 'TooltipString', value(CURRENT_TRAINING_STAGES_FILE_PATH));
                        eval(selected_radiobutton_Callback);
                    end
                end
            end
            
            %% set_info
        case 'set_info'
            %SessionDefinition(obj, 'set_info', experimenter, ratname)
            if nargin~=4
                error('Invalid number of arguments. The number arguments has to be 4.');
            else
                if ~ischar(varargin{1})
                    error('experimenter has to be a string');
                elseif ~ischar(varargin{2})
                    error('ratname has to be a string');
                end
            end
            
            experimenter = varargin{1};
            ratname = varargin{2};
            SavingSection(obj, 'set_info', experimenter, ratname);
            feval(mfilename, obj, 'init');
            
            %% btnFlushCallback
        case 'btnFlushCallback'
            %SessionDefinition(obj, 'btnFlushCallback'): Callback for btnFlush
            msgbox('btnFlushCallback');
            
            
            %% btnActivateCallback
        case 'btnActivateCallback'
            %SessionDefinition(obj, 'btnActivateCallback'): Callback for
            %btnActivate
            hndl = value(session_automator_window);
            handles = guihandles(hndl);
            if ~isempty(get(handles.lbxTrainingStages, 'String')) && ...
                    ~isequal(get(handles.lbxTrainingStages, 'Value'), value(CURRENT_ACTIVE_STAGE))
                PREVIOUS_ACTIVE_STAGE.value = value(CURRENT_ACTIVE_STAGE);
                CURRENT_ACTIVE_STAGE.value = get(handles.lbxTrainingStages, 'Value');
                STARTING_ACTIVE_STAGE.value = value(CURRENT_ACTIVE_STAGE);
                feval(mfilename, obj, 'refresh_lbxTrainingStages');
            end
            
            %% btnLoadCallback
        case 'btnLoadCallback'
            %SessionDefinition(obj, 'btnLoadCallback'): Callback for btnLoad
            [filename, pathname] = uigetfile(...
                {['pipeline_' class(obj) '_' SESSION_INFO.experimenter '_' SESSION_INFO.ratname '_*.m'], ['pipeline_' class(obj) '_' SESSION_INFO.experimenter '_' SESSION_INFO.ratname '_*.m file']; ...
                ['pipeline_' class(obj) '_' SESSION_INFO.experimenter '_*.m'], ['pipeline_' class(obj) '_' SESSION_INFO.experimenter '_*.m file']; ...
                ['pipeline_' class(obj) '_*.m'], ['pipeline_' class(obj) '_*.m file']; ...
                '*.m', 'M-file (*.m)'}, 'Pick an M-file', ...
                get_latest_training_stage_file_path(SESSION_INFO.experimenter, SESSION_INFO.ratname, SESSION_INFO.protocol));
            if ~isequal(filename, 0) && ~isequal(pathname, 0)
                absolute_file_path = fullfile(pathname, filename);
                currpath = path;
                if pathname(end)==filesep
                    pathname = pathname(1:end-1);
                end
                if isempty(strfind(currpath, pathname))
                    addpath(pathname);
                    REMOVE_THESE_PATHS{end+1} = pathname; %#ok<NASGU>
                end
                feval(mfilename, obj, 'load_stagefile', absolute_file_path);
            end
            
            %% btnToggleDeactivationStatusCallback
        case 'btnToggleDeactivationStatusCallback'
            %SessionDefinition(obj, 'btnToggleDeactivationStatusCallback'):
            %Callback for btnToggleDeactivationStatus
            hndl = value(session_automator_window);
            handles = guihandles(hndl);
            if ~isempty(get(handles.lbxTrainingStages, 'String'))
                selected_stage_number = get(handles.lbxTrainingStages, 'Value');
                if ismember(selected_stage_number, value(CURRENT_DEACTIVATED_STAGES))
                    feval(mfilename, obj, 'mark_not_deactivated', selected_stage_number);
                else
                    feval(mfilename, obj, 'mark_deactivated', selected_stage_number);
                end
            end
            
            %% refresh_lbxTrainingStages
        case 'refresh_lbxTrainingStages'
            %SessionDefinition(obj, 'refresh_lbxTrainingStages')
            if nargin~=2
                error('Invalid number of arguments. The number of arguments has to be 2.');
            end
            
            if ~isempty(value(CURRENT_TRAINING_STAGES_FILE_PATH)) && ~isnan(value(CURRENT_ACTIVE_STAGE))
                hndl = value(session_automator_window);
                handles = guihandles(hndl);
                training_stage_list = get_training_stages(value(CURRENT_TRAINING_STAGES_FILE_PATH)); %#ok<*NODEF>
                for ctr = 1:length(training_stage_list)
                    training_stage_list{ctr} = ['#' num2str(ctr) ': ' training_stage_list{ctr}];
                    if ismember(ctr, value(CURRENT_DEACTIVATED_STAGES))
                        training_stage_list{ctr} = [training_stage_list{ctr} ' <DEACTIVATED>'];
                    end
                end
                if ~ismember(value(CURRENT_ACTIVE_STAGE), value(CURRENT_DEACTIVATED_STAGES))
                    training_stage_list{value(CURRENT_ACTIVE_STAGE)} = [training_stage_list{value(CURRENT_ACTIVE_STAGE)} ' <ACTIVE>'];
                end
                set(handles.lbxTrainingStages, 'String', training_stage_list);
                lbxTrainingStages_String.value = training_stage_list;
                if ismember(get(handles.lbxTrainingStages, 'Value'), value(CURRENT_DEACTIVATED_STAGES))
                    set(handles.btnToggleDeactivationStatus, 'Value', true);
                else
                    set(handles.btnToggleDeactivationStatus, 'Value', false);
                end
            end
            
            %% refresh_lbxParameters
        case 'refresh_lbxParameters'
            %SessionDefinition(obj, 'refresh_lbxParameters')
            if nargin~=2
                error('Invalid number of arguments. The number of arguments has to be 2.');
            end
            
            hndl = value(session_automator_window);
            handles = guihandles(hndl);
            parameter_list = sort(GetSoloFunctionArgList(['@' class(obj)], 'SessionModel'));
            search_string_pattern = strtrim(get(handles.editParameterSearchString, 'String'));
            if ~isempty(search_string_pattern)
                result_vector = regexpi(parameter_list, search_string_pattern);
                non_empty_indices = [];
                for ctr = 1:length(result_vector)
                    if ~isempty(result_vector{ctr})
                        non_empty_indices(end+1) = ctr; %#ok<AGROW>
                    end
                end
                parameter_list = parameter_list(non_empty_indices);
            end
            if isempty(parameter_list)
                parameter_list = {''};
            end
            set(handles.lbxParameters, 'Value', 1);
            set(handles.lbxParameters, 'String', parameter_list);
            lbxParameters_String.value = parameter_list;
            
            %% btnExportCallback
        case 'btnExportCallback'
            %SessionDefinition(obj, 'btnExportCalback'): Callback for btnExport
            if isempty(value(CURRENT_TRAINING_STAGE_LIST))
                msgbox('There are no training stages loaded. Please add one or more training stages before attempting to export the training stage file', ...
                    'Unable to export', 'modal');
            else
                [filename, pathname] = uiputfile({'*.m', 'M-file (*.m)'}, 'Export Training Stage File As');
                if ~isequal(filename, 0) && ~isequal(pathname, 0)
                    absolute_file_path = fullfile(pathname, filename);
                    
                    feval(mfilename, obj, 'save_current_training_stage_file', absolute_file_path);
                end
            end
            
            %% btnSaveCallback
        case 'btnSaveCallback'
            if isempty(value(CURRENT_TRAINING_STAGE_LIST))
                msgbox('There are no training stages loaded. Please add one or more training stages before attempting to save the training stage file', ...
                    'Unable to save', 'modal');
            else
                h = waitbar(0, 'Saving training stage file, please wait...', 'CloseRequestFcn', '', 'Pointer', 'watch', 'WindowStyle', 'modal');
                absolute_file_path = feval(mfilename, obj, 'save_current_training_stage_file');
                waitbar(1/2, h);
                add_and_commit(absolute_file_path);
                waitbar(1, h, 'Saving complete'); pause(1.0);
                delete(h);
                
                feval(mfilename, obj, 'autoload_latest_training_stage_file');
                
                handles = guihandles(value(session_automator_window));
                filename = feval(mfilename, obj, 'generate_training_stage_file_name');
                filepath = fullfile(value(MAIN_DATA_DIRECTORY), 'Settings', SESSION_INFO.experimenter, SESSION_INFO.ratname, [filename '.m']);
                set(handles.btnSave, 'TooltipString', ['Save training stage file to ' filepath ' with today''s date, and add it to the repository.']);
            end
            
            %% btnReinitializeHelperVarsCallback
        case 'btnReinitializeHelperVarsCallback'
            %SessionDefinition(obj, 'btnReinitializeHelperVarsCallback'):
            %Callback for btnReinitializeHelperVars
            if ~isempty(value(GLOBAL_HELPER_VAR_NAME_LIST))
                answer = questdlg('Are you sure you want to reinitialize all helper vars for the current active stage?', 'Are you sure?', 'YES', 'NO', 'NO');
                if strcmp(answer, 'YES')
                    helper_var_name_list = {};
                    for ctr = 1:length(GLOBAL_HELPER_VAR_NAME_LIST)
                        if strcmp(GLOBAL_HELPER_VAR_NAME_LIST(ctr).stage_name, CURRENT_TRAINING_STAGE_LIST{value(CURRENT_ACTIVE_STAGE)})
                            helper_var_name_list{end+1} = GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name; %#ok<AGROW>
                        end
                    end
                    feval(mfilename, obj, 'reinit_helper_vars', helper_var_name_list);
                end
            end
            
            %% btnInstantiateHelperVarsCallback
        case 'btnInstantiateHelperVarsCallback'
            %SessionDefinition(obj, 'btnInstantiateHelperVarsCallback'):
            %Callback for btnInstantiateHelperVars
            if ~isempty(value(GLOBAL_HELPER_VAR_NAME_LIST))
                helper_var_name_list = {};
                for ctr = 1:length(GLOBAL_HELPER_VAR_NAME_LIST)
                    if strcmp(GLOBAL_HELPER_VAR_NAME_LIST(ctr).stage_name, CURRENT_TRAINING_STAGE_LIST{value(CURRENT_ACTIVE_STAGE)})
                        helper_var_name_list{end+1} = GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name; %#ok<AGROW>
                    end
                end
                feval(mfilename, obj, 'base_instantiate_helper_vars', helper_var_name_list);
            end
            
            %% btnCompletionTestCallback
        case 'btnCompletionTestCallback'
            %SessionDefinition(obj, 'btnCompletionTestCallback'): Callback for
            %btnCompletionTest
            if exist(value(CURRENT_TRAINING_STAGES_FILE_PATH), 'file')
                clear(value(CURRENT_TRAINING_STAGES_FILE_NAME));
                result = feval(value(CURRENT_TRAINING_STAGES_FILE_NAME), ...
                    obj, CURRENT_TRAINING_STAGE_LIST{value(CURRENT_ACTIVE_STAGE)}, ...
                    'helper_vars_eval', false, ...
                    'stage_algorithm_eval', false, ...
                    'completion_test_eval', true, ...
                    'eod_logic_eval', false);
                
                booleanstr = {'Completion test: fail', 'Completion test: pass'};
                
                msgbox(booleanstr{double(result)+1}, 'Completion test', 'modal');
            end
            
            %% btnUpdateCallback
        case 'btnUpdateCallback'
            %SessionDefinition(obj, 'btnUpdateCallback'): Callback for
            %btnUpdate
            hndl = value(session_automator_window);
            handles = guihandles(hndl);
            if isempty(value(CURRENT_TRAINING_STAGE_LIST))
                msgbox('There are no training stages loaded. Please add one or more training stages first.', ...
                    'Unable to update', 'modal');
            elseif isempty(strtrim(strrep(char(get(handles.editName, 'String')), '''', '')))
                msgbox('Unable to update. The training stage name is empty.', ...
                    'Unable to update', 'modal');
            else
                %If the stage name has been changed and the new stage name
                %already exists
                old_stage_name = CURRENT_TRAINING_STAGE_LIST{get(handles.lbxTrainingStages, 'Value')};
                new_stage_name = strtrim(strrep(char(get(handles.editName, 'String')), '''', ''));
                if ~strcmp(old_stage_name, new_stage_name) && ismember(new_stage_name, value(CURRENT_TRAINING_STAGE_LIST))
                    msgbox('Unable to update. The stage name you have chosen is already in use.', ...
                        'Unable to update', 'modal');
                else
                    selected_stage = get(handles.lbxTrainingStages, 'Value');
                    if ~strcmp(CURRENT_TRAINING_STAGE_LIST{selected_stage}, strtrim(strrep(char(get(handles.editName, 'String')), '''', '')))
                        for ctr = 1:length(GLOBAL_HELPER_VAR_NAME_LIST)
                            if strcmp(GLOBAL_HELPER_VAR_NAME_LIST(ctr).stage_name, CURRENT_TRAINING_STAGE_LIST{selected_stage})
                                GLOBAL_HELPER_VAR_NAME_LIST(ctr).stage_name = strtrim(strrep(char(get(handles.editName, 'String')), '''', '')); %#ok<AGROW>
                                set_userprop(eval(GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name), 'stage_name', GLOBAL_HELPER_VAR_NAME_LIST(ctr).stage_name);
                            end
                        end
                    end
                    CURRENT_TRAINING_STAGE_LIST{selected_stage} = strtrim(strrep(char(get(handles.editName, 'String')), '''', ''));
                    CURRENT_STAGE_ALGORITHM_LIST{selected_stage} = regexprep(getascell(handles.editStageAlgorithm, 'String'), '\s+$', '');
                    CURRENT_COMPLETION_TEST_LIST{selected_stage} = regexprep(getascell(handles.editCompletionTest, 'String'), '\s+$', '');
                    CURRENT_EOD_LOGIC_LIST{selected_stage} = regexprep(getascell(handles.editEODLogic, 'String'), '\s+$', '');
                    CURRENT_HELPER_VAR_LIST{selected_stage} = regexprep(getascell(handles.editHelperVars, 'String'), '\s+$', '');
                    CURRENT_HELPER_FUNCTION_LIST.value = regexprep(getascell(handles.editHelperFunctions, 'String'), '\s+$', '');
                    
                    %Now to write all these to the current training stages file
                    write_data_to_training_stage_file(value(CURRENT_TRAINING_STAGE_LIST), ...
                        value(CURRENT_STAGE_ALGORITHM_LIST), ...
                        value(CURRENT_COMPLETION_TEST_LIST), ...
                        value(CURRENT_EOD_LOGIC_LIST), ...
                        value(CURRENT_HELPER_VAR_LIST), ...
                        value(CURRENT_HELPER_FUNCTION_LIST), ...
                        value(CURRENT_TRAINING_STAGES_FILE_PATH));
                    
                    feval(mfilename, obj, 'refresh_lbxTrainingStages');
                end
            end
            
            %% btnOpenFileCallback
        case 'btnOpenFileCallback'
            %SessionDefinition(obj, 'btnOpenFileCallback'): Callback for
            %btnOpenFile
            if ~isempty(value(CURRENT_TRAINING_STAGES_FILE_PATH))
                edit(value(CURRENT_TRAINING_STAGES_FILE_PATH));
            end
            
            %% btnReloadCallback
        case 'btnReloadCallback'
            %SessionDefinition(obj, 'btnReloadCallback'): Callback for
            %btnReload
            if ~isempty(value(CURRENT_TRAINING_STAGES_FILE_PATH))
                %If the file does not exist, attempt to retrieve it from the
                %repository
                cvsroot_string = bSettings('get', 'CVS', 'CVSROOT_STRING');
                if ~exist(value(CURRENT_TRAINING_STAGES_FILE_PATH), 'file') && ~isempty(cvsroot_string) && ~any(isnan(cvsroot_string))
                    currdir = pwd;
                    
                    directory_name = value(MAIN_DATA_DIRECTORY);
                    if directory_name(end)==filesep
                        directory_name = directory_name(1:end-1);
                    end
                    [dummy, directory_name] = fileparts(directory_name); clear('dummy');
                    
                    start_index = strfind(value(CURRENT_TRAINING_STAGES_FILE_PATH), directory_name);
                    if ~isempty(start_index)
                        start_index = start_index(1);
                        checkout_string = strrep(CURRENT_TRAINING_STAGES_FILE_PATH(start_index:end), filesep, '/');
                        
                        cd(value(MAIN_DATA_DIRECTORY)); cd('..'); x = pwd;
                        if ~strcmp(x, value(MAIN_DATA_DIRECTORY))
                            h = waitbar(0, 'Attempting to retrieve file...', 'CloseRequestFcn', '', 'WindowStyle', 'modal', 'Pointer', 'watch');
                            system(['cvs -d ' cvsroot_string ' checkout ' checkout_string]);
                            if exist(value(CURRENT_TRAINING_STAGES_FILE_PATH), 'file')
                                waitbar(1, h, 'File retrieved'); pause(1.0);
                            else
                                waitbar(0, h, 'Could not retrieve file. Aborting...'); pause(1.0);
                            end
                            delete(h);
                        end
                        cd(currdir);
                    end
                end
                
                feval(mfilename, obj, 'load_stagefile', value(CURRENT_TRAINING_STAGES_FILE_PATH));
            end
            
            
            %% btnRedrawCallback
        case 'btnRedrawCallback'
            %SessionDefinition(obj, 'btnRedrawCallback'): Callback for
            %invisible button btnRedraw
            handles = guihandles(value(session_automator_window));
            set(handles.lbxParameters, 'String', value(lbxParameters_String));
            set(handles.lbxTrainingStages, 'String', value(lbxTrainingStages_String));
            set(handles.textTrainingStageFile, 'TooltipString', value(textTrainingStageFile));
            feval(mfilename, obj, 'lbxTrainingStagesCallback');
            %feval(mfilename, obj, 'init');
            
            
            %% radioStageAlgorithmCallback
        case 'radioStageAlgorithmCallback'
            %SessionDefinition(obj, 'radioStageAlgorithmCallback'): Callback
            %for radioStageAlgorithm
            hndl = value(session_automator_window);
            handles = guihandles(hndl);
            turnoff_all_radiobuttons(hndl);
            set(handles.radioStageAlgorithm, 'Value', true);
            make_edit_windows_invisible(hndl);
            set(handles.editStageAlgorithm, 'Visible', 'on');
            
            %% radioCompletionTestCallback
        case 'radioCompletionTestCallback'
            %SessionDefinition(obj, 'radioCompletionTestCallback'): Callback
            %for radioCompletionTest
            hndl = value(session_automator_window);
            handles = guihandles(hndl);
            turnoff_all_radiobuttons(hndl);
            set(handles.radioCompletionTest, 'Value', true);
            make_edit_windows_invisible(hndl);
            set(handles.editCompletionTest, 'Visible', 'on');
            
            %% radioEODLogicCallback
        case 'radioEODLogicCallback'
            %SessionDefinition(obj, 'radioEODLogicCallback'): Callback for
            %radioEODLogic
            hndl = value(session_automator_window);
            handles = guihandles(hndl);
            turnoff_all_radiobuttons(hndl);
            set(handles.radioEODLogic, 'Value', true);
            make_edit_windows_invisible(hndl);
            set(handles.editEODLogic, 'Visible', 'on');
            
            %% radioNameCallbacks
        case 'radioNameCallback'
            %SessionDefinition(obj, 'radioNameCallback'): Callback for
            %radioName
            hndl = value(session_automator_window);
            handles = guihandles(hndl);
            turnoff_all_radiobuttons(hndl);
            set(handles.radioName, 'Value', true);
            make_edit_windows_invisible(hndl);
            set(handles.editName, 'Visible', 'on');
            
            %% radioHelperFunctionsCallback
        case 'radioHelperFunctionsCallback'
            %SessionDefinition(obj, 'radioHelperFunctionsCallback'): Callback
            %for radioHelperFunctions
            hndl = value(session_automator_window);
            handles = guihandles(hndl);
            turnoff_all_radiobuttons(hndl);
            set(handles.radioHelperFunctions, 'Value', true);
            make_edit_windows_invisible(hndl);
            set(handles.editHelperFunctions, 'Visible', 'on');
            
            %% radioHelperVarsCallback
        case 'radioHelperVarsCallback'
            %SessionDefinition(obj, 'radioHelperVarsCallback'): Callback for
            %radioHelperVars.
            hndl = value(session_automator_window);
            handles = guihandles(hndl);
            turnoff_all_radiobuttons(hndl);
            set(handles.radioHelperVars, 'Value', true);
            make_edit_windows_invisible(hndl);
            set(handles.editHelperVars, 'Visible', 'on');
            
            %% load_stagefile
        case 'load_stagefile'
            %SessionDefinition(obj, 'load_stagefile', file_path)
            if nargin~=3
                error('Invalid number of arguments. The number of arguments should be 3.');
            end
            
            absolute_file_path = varargin{1};
            if exist(absolute_file_path, 'file')
                CURRENT_TRAINING_STAGES_FILE_PATH.value = absolute_file_path;
                filename = absolute_file_path(find(absolute_file_path==filesep, 1, 'last')+1:end);
                CURRENT_TRAINING_STAGES_FILE_NAME.value = filename(1:end-2);
                training_stage_list = strtrim(strrep(get_training_stages(absolute_file_path), '''', '')); CURRENT_TRAINING_STAGE_LIST.value = training_stage_list;
                if value(STARTING_ACTIVE_STAGE) <= length(CURRENT_TRAINING_STAGE_LIST)
                    CURRENT_ACTIVE_STAGE.value = value(STARTING_ACTIVE_STAGE);
                else
                    CURRENT_ACTIVE_STAGE.value = 1;
                    STARTING_ACTIVE_STAGE.value = 1;
                end
                if any(value(STARTING_DEACTIVATED_STAGES) > length(CURRENT_TRAINING_STAGE_LIST))
                    CURRENT_DEACTIVATED_STAGES.value = [];
                    STARTING_DEACTIVATED_STAGES.value = [];
                else
                    CURRENT_DEACTIVATED_STAGES.value = value(STARTING_DEACTIVATED_STAGES);
                end
                stage_algorithm_list = get_stage_algorithms(absolute_file_path); CURRENT_STAGE_ALGORITHM_LIST.value = stage_algorithm_list;
                completion_test_list = get_completion_tests(absolute_file_path); CURRENT_COMPLETION_TEST_LIST.value = completion_test_list;
                helper_function_list = get_helper_functions(absolute_file_path); CURRENT_HELPER_FUNCTION_LIST.value = helper_function_list;
                helper_var_list = get_helper_vars(absolute_file_path); CURRENT_HELPER_VAR_LIST.value = helper_var_list;
                eod_logic_list = get_eod_logic_list(absolute_file_path); CURRENT_EOD_LOGIC_LIST.value = eod_logic_list;
                
                hndl = value(session_automator_window);
                handles = guihandles(hndl);
                editStageAlgorithm.value = stage_algorithm_list{value(CURRENT_ACTIVE_STAGE)};
                editName.value = training_stage_list{value(CURRENT_ACTIVE_STAGE)};
                editCompletionTest.value = completion_test_list{value(CURRENT_ACTIVE_STAGE)};
                editHelperFunctions.value = helper_function_list;
                editHelperVars.value = helper_var_list{value(CURRENT_ACTIVE_STAGE)};
                editEODLogic.value = eod_logic_list{value(CURRENT_ACTIVE_STAGE)};
                textTrainingStageFile.value = value(CURRENT_TRAINING_STAGES_FILE_PATH);
                %set(handles.textTrainingStageFile, 'String', value(CURRENT_TRAINING_STAGES_FILE_PATH));
                set(handles.textTrainingStageFile, 'TooltipString', value(CURRENT_TRAINING_STAGES_FILE_PATH));
                feval(mfilename, obj, 'refresh_lbxTrainingStages');
                set(handles.lbxTrainingStages, 'Value', value(CURRENT_ACTIVE_STAGE));
                if ismember(get(handles.lbxTrainingStages, 'Value'), value(CURRENT_DEACTIVATED_STAGES))
                    set(handles.btnToggleDeactivationStatus, 'Value', true);
                    btnToggleDeactivationStatus.value = true;
                else
                    set(handles.btnToggleDeactivationStatus, 'Value', false);
                    btnToggleDeactivationStatus.value = false;
                end
                
                CURRENT_TRAINING_STAGES_FILE_LOADTIME.value = now;
            else
                error(['File ' absolute_file_path ' was not found.']);
            end
            
            %% get_stagelist
        case 'get_stagelist'
            %SessionDefinition(obj, 'get_stagelist')
            if nargin~=2
                error('Invalid number of arguments. The number of arguments must be 2.');
            end
            
            stagelist = value(CURRENT_TRAINING_STAGE_LIST);
            stagelist = stagelist(:);
            varargout{1} = stagelist;
            
            %% get_parameter_list
        case 'get_parameter_list'
            %SessionDefinition(obj, 'get_parameter_list')
            if nargin~=2
                error('Invalid number of arguments. The number of arguments must be 2.');
            end
            
            varargout{1} = sort(GetSoloFunctionArgList(['@' class(obj)], 'SessionModel'));
            
            
            %% get_active_stage_details
        case 'get_active_stage_details'
            %SessionDefinition(obj, 'get_active_stage_details')
            if nargin~=2
                error('Invalid number of arguments. The number of arguments must be 2.');
            end
            
            if isempty(value(CURRENT_TRAINING_STAGE_LIST))
                active_stage.number = NaN;
                active_stage.name = '';
            else
                active_stage.number = value(CURRENT_ACTIVE_STAGE);
                active_stage.name = CURRENT_TRAINING_STAGE_LIST{value(CURRENT_ACTIVE_STAGE)};
            end
            varargout{1} = active_stage;
            
            %% get_previous_active_stage_details
        case 'get_previous_active_stage_details'
            %SessionDefinition(obj, 'get_previous_active_stage_details')
            if nargin~=2
                error('Invalid number of arguments. The number of arguments has to be 2.');
            end
            
            if isempty(value(PREVIOUS_ACTIVE_STAGE))
                previous_active_stage.number = NaN;
                previous_active_stage.name = '';
            else
                previous_active_stage.number = value(PREVIOUS_ACTIVE_STAGE);
                previous_active_stage.name = CURRENT_TRAINING_STAGE_LIST(value(PREVIOUS_ACTIVE_STAGE));
            end
            varargout{1} = previous_active_stage;
            
            %% get_current_stagefile
        case 'get_current_stagefile'
            %SessionDefinition(obj, 'get_current_stagefile')
            if nargin~=2
                error('Invalid number of arguments. The number of arguments has to be 2.');
            end
            varargout{1} = value(CURRENT_TRAINING_STAGES_FILE_PATH);
            
            %% get_current_stagefile_load_time
        case 'get_current_stagefile_load_time'
            %SessionDefinition(obj, 'get_current_stagefile_load_time')
            if nargin~=2
                error('Invalid number of arguments. The number of arguments has to be 2.');
            end
            varargout{1} = value(CURRENT_TRAINING_STAGES_FILE_LOADTIME);
            
            %% get_helper_var_details
        case 'get_helper_var_details'
            %SessionDefinition(obj, 'get_helper_var_details')
            if nargin~=2
                error('Invalid number of arguments. The number of arguments has to be 2.');
            end
            
            return_structure = value(GLOBAL_HELPER_VAR_NAME_LIST);
            if ~isempty(return_structure)
                for ctr = 1:length(return_structure)
                    assert(logical(exist(return_structure(ctr).var_name, 'var')) && isa(eval(return_structure(ctr).var_name), 'SoloParamHandle'))
                    return_structure(ctr).current_value = value(eval(return_structure(ctr).var_name));
                    return_structure(ctr).history = get_history(eval(return_structure(ctr).var_name));
                end
            end
            varargout{1} = return_structure;
			
			%% get_helper_vars
		case 'get_helper_vars'
			%SessionDefinition(obj, 'get_helper_vars')
			if nargin~=2
				error('Invalid number of arguments. The number of arguments has to be 2.');
			end
			
			helper_vars_list_structure = feval(mfilename, obj, 'get_helper_var_details');
			helper_vars_cell = cell(length(helper_vars_list_structure), 1);
			for ctr = 1:numel(helper_vars_cell)
				assert(logical(exist(helper_vars_list_structure(ctr).var_name, 'var')) && isa(eval(helper_vars_list_structure(ctr).var_name), 'SoloParamHandle'))
				helper_vars_cell{ctr} = eval(helper_vars_list_structure(ctr).var_name);
			end
            
			varargout{1} = helper_vars_cell;
			
            %% jump_to_stage
        case 'jump_to_stage'
            %SessionDefinition(obj, 'jump_to_stage', stage_name/stage_number)
            if nargin~=3
                error('Invalid number of arguments. The number of arguments has to be 3.');
            else
                if ~ischar(varargin{1}) && ~isscalar(varargin{1})
                    error('The 3rd argument has to be either a string or a scalar numeric value.');
                end
            end
            
            if ischar(varargin{1}) %Meaning stage name was given
                stage_number = find(strcmp(value(CURRENT_TRAINING_STAGE_LIST), varargin{1}), 1, 'first');
            elseif isnumeric(varargin{1}) %Meaning stage number was given
                stage_number = varargin{1};
            end
            number_of_stages = length(value(CURRENT_TRAINING_STAGE_LIST));
            if ~isempty(stage_number) && stage_number <= number_of_stages
                if stage_number ~= value(CURRENT_ACTIVE_STAGE)
                    PREVIOUS_ACTIVE_STAGE.value = value(CURRENT_ACTIVE_STAGE);
                    CURRENT_ACTIVE_STAGE.value = stage_number;
                    feval(mfilename, obj, 'mark_not_deactivated', value(CURRENT_ACTIVE_STAGE));
                    STARTING_ACTIVE_STAGE.value = stage_number;
                end
            end
            feval(mfilename, obj, 'refresh_lbxTrainingStages');
            
            %% next_trial
        case 'next_trial'
            %SessionDefinition(obj, 'next_trial');
            
            if ~isequal(SavingSection(obj, 'get_settings_file_load_time'), value(TEMPORARY_SETTINGS_FILE_LOAD_TIME))
                feval(mfilename, obj, 'init');
            end
            
            
            if n_done_trials >= 1 && ~isempty(value(CURRENT_TRAINING_STAGES_FILE_NAME))
                
                for ctr = 1:length(GLOBAL_HELPER_VAR_NAME_LIST)
                    if exist(GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name, 'var') && isa(eval(GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name), 'SoloParamHandle')
                        push_history(eval(GLOBAL_HELPER_VAR_NAME_LIST(ctr).var_name));
                    end
                end
                %Evaluate the completion test for the currently active training
                %stage. If it evaluates to true, jump to the next training stage
                should_go_to_next_stage = true;
                if exist(value(CURRENT_TRAINING_STAGES_FILE_PATH), 'file') && ~ismember(value(CURRENT_ACTIVE_STAGE), value(CURRENT_DEACTIVATED_STAGES))
                    clear(value(CURRENT_TRAINING_STAGES_FILE_NAME));
                    feval(value(CURRENT_TRAINING_STAGES_FILE_NAME), ...
                        obj, CURRENT_TRAINING_STAGE_LIST{value(CURRENT_ACTIVE_STAGE)}, ...
                        'helper_vars_eval', true, ...
                        'completion_test_eval', false, ...
                        'stage_algorithm_eval', true, ...
                        'eod_logic_eval', false);
                    
                    should_go_to_next_stage = feval(value(CURRENT_TRAINING_STAGES_FILE_NAME), ...
                        obj, CURRENT_TRAINING_STAGE_LIST{value(CURRENT_ACTIVE_STAGE)}, ...
                        'helper_vars_eval', false, ...
                        'completion_test_eval', true, ...
                        'stage_algorithm_eval', false, ...
                        'eod_logic_eval', false);
                    
                    PREVIOUS_ACTIVE_STAGE.value = value(CURRENT_ACTIVE_STAGE);
                    
                    feval(mfilename, obj, 'refresh_lbxParameters');
                end
                GetSoloFunctionArgs(obj);
                if should_go_to_next_stage
                    %Jump to the next non-deactivated stage
                    for ctr = value(CURRENT_ACTIVE_STAGE)+1:length(value(CURRENT_TRAINING_STAGE_LIST))
                        if ismember(ctr, value(CURRENT_DEACTIVATED_STAGES))
                            feval(mfilename, obj, 'jump_to_stage', ctr);
                            break;
                        end
                    end
                end
            end
            
            %% eod_save
        case 'eod_save'
            %SessionDefinition(obj, 'eod_save');
            if ~isempty(value(CURRENT_TRAINING_STAGES_FILE_NAME))
                if exist(value(CURRENT_TRAINING_STAGES_FILE_PATH), 'file') && ~ismember(value(CURRENT_ACTIVE_STAGE), value(CURRENT_DEACTIVATED_STAGES))
                    clear(value(CURRENT_TRAINING_STAGES_FILE_NAME));
                    feval(value(CURRENT_TRAINING_STAGES_FILE_NAME), ...
                        obj, CURRENT_TRAINING_STAGE_LIST{value(CURRENT_ACTIVE_STAGE)}, ...
                        'helper_vars_eval', false, ...
                        'completion_test_eval', false, ...
                        'stage_algorithm_eval', false, ...
                        'eod_logic_eval', true);
                    feval(mfilename, obj, 'refresh_lbxParameters');
                end
                
                %Save training stage file to the appropriate folder
                file_name = feval(mfilename, obj, 'generate_training_stage_file_name', 'yymmdd', yearmonthday(now+1));
                absolute_file_path = fullfile(value(MAIN_DATA_DIRECTORY), 'Settings', SESSION_INFO.experimenter, SESSION_INFO.ratname, [file_name '.m']);
                
                h = waitbar(0, 'Saving data, please wait...', 'CloseRequestFcn', '', 'Pointer', 'watch', 'WindowStyle', 'modal');
                save_soloparamvalues(SESSION_INFO.ratname, 'owner', class(obj), 'commit', 1, 'interactive', 0, 'experimenter', SESSION_INFO.experimenter);
                waitbar(1/3, h, 'Saving settings, please wait...');
                save_solouiparamvalues(SESSION_INFO.ratname, 'owner', class(obj), 'commit', 1, 'interactive', 0, 'tomorrow', 1, 'experimenter', SESSION_INFO.experimenter);
                waitbar(2/3, h, 'Saving training stage file, please wait...');
                feval(mfilename, obj, 'save_current_training_stage_file', absolute_file_path);
                add_and_commit(absolute_file_path);
                waitbar(1, h, 'Saving complete');
                pause(1.0);
                delete(h);
            end
            
            %% generate_training_stage_file_name
        case 'generate_training_stage_file_name'
            pairs = {'yymmdd', yearmonthday; ...
                'directory', fullfile(value(MAIN_DATA_DIRECTORY), 'Settings', SESSION_INFO.experimenter, SESSION_INFO.ratname)};
            parseargs(varargin, pairs);
            
            absolute_file_path = fullfile(directory, ['pipeline_' class(obj) '_' SESSION_INFO.experimenter '_' SESSION_INFO.ratname '_' yymmdd]);
            absolute_file_path_cat = absolute_file_path;
            offset = 0;
            while logical(exist([absolute_file_path_cat '.m'], 'file'))
                offset = offset + 1;
                if mod(offset, 27)==0
                    power_term = floor(log(offset)/log(27));
                    offset = 26*sum((27*ones(1, power_term)).^(power_term:-1:1)) + 1;
                end
                offset_char = char(96 + dec2basen(offset, 27));
                absolute_file_path_cat = [absolute_file_path offset_char];
            end
            absolute_file_path = [absolute_file_path_cat '.m'];
            [dummy, varargout{1}] = fileparts(absolute_file_path);
            clear('dummy');
            
            %% save_settings_only
        case 'save_settings_only'
            %SessionDefinition(obj, 'save_settings_only', varargin)
            %Pairs: 'commit', true/false: Saves settings for tomorrow
            
            pairs = {'commit', false};
            parseargs(varargin, pairs);
            commit = logical(commit);
            
            h = waitbar(0, 'Saving settings, please wait...', 'CloseRequestFcn', '', 'Pointer', 'watch', 'WindowStyle', 'modal');
            save_solouiparamvalues(SESSION_INFO.ratname, 'owner', class(obj), 'commit', commit, 'interactive', 0, 'tomorrow', 1, 'experimenter', SESSION_INFO.experimenter);
            waitbar(1, h, 'Saving complete');
            pause(1.0);
            delete(h);
            
            %% save_data_only
        case 'save_data_only'
            %SessionDefinition(obj, 'save_data_only', varargin)
            %Pairs: 'commit', true/false: Saves data for today
            
            pairs = {'commit', false};
            parseargs(varargin, pairs);
            commit = logical(commit);
            
            h = waitbar(0, 'Saving data, please wait...', 'CloseRequestFcn', '', 'Pointer', 'watch', 'WindowStyle', 'modal');
            save_soloparamvalues(SESSION_INFO.ratname, 'owner', class(obj), 'commit', commit, 'interactive', 0, 'experimenter', SESSION_INFO.experimenter);
            waitbar(1, h, 'Saving complete');
            pause(1.0);
            delete(h);
            
            %% save_current_training_stage_file
        case 'save_current_training_stage_file'
            %filepath = SessionDefinition(obj, 'save_current_training_stage_file',
            %<absolute_file_path>);
            
            if nargin~=2 && nargin~=3
                error('Invalid number of arguments. The number of arguments has to be 2 or 3.');
            elseif nargin==3
                if ~ischar(varargin{1})
                    error('absolute_file_path has to be a string');
                end
            end
            
            varargout{1} = '';
            if ~isempty(value(CURRENT_TRAINING_STAGE_LIST))
                if nargin==2
                    file_name = feval(mfilename, obj, 'generate_training_stage_file_name');
                    absolute_file_path = fullfile(value(MAIN_DATA_DIRECTORY), 'Settings', SESSION_INFO.experimenter, SESSION_INFO.ratname, [file_name '.m']);
                elseif nargin==3
                    absolute_file_path = varargin{1};
                end
                
                
                write_data_to_training_stage_file(value(CURRENT_TRAINING_STAGE_LIST), ...
                    value(CURRENT_STAGE_ALGORITHM_LIST), ...
                    value(CURRENT_COMPLETION_TEST_LIST), ...
                    value(CURRENT_EOD_LOGIC_LIST), ...
                    value(CURRENT_HELPER_VAR_LIST), ...
                    value(CURRENT_HELPER_FUNCTION_LIST), ...
                    absolute_file_path);
                
                varargout{1} = absolute_file_path;
            end
            
            %% run_eod_logic_without_saving
        case 'run_eod_logic_without_saving'
            %SessionDefinition(obj, 'run_eod_logic_without_saving')
            if nargin~=2
                error('Invalid number of arguments. The number of arguments has to be 2.');
            end
            
            if exist(value(CURRENT_TRAINING_STAGES_FILE_PATH), 'file') && ~ismember(value(CURRENT_ACTIVE_STAGE), value(CURRENT_DEACTIVATED_STAGES))
                clear(value(CURRENT_TRAINING_STAGES_FILE_NAME));
                feval(value(CURRENT_TRAINING_STAGES_FILE_NAME), ...
                    obj, CURRENT_TRAINING_STAGE_LIST{value(CURRENT_ACTIVE_STAGE)}, ...
                    'helper_vars_eval', false, ...
                    'completion_test_eval', false, ...
                    'stage_algorithm_eval', false, ...
                    'eod_logic_eval', true);
                feval(mfilename, obj, 'refresh_lbxParameters');
            end
            
            %% mark_deactivated
        case 'mark_deactivated'
            %SessionDefinition(obj, 'mark_deactivated', stagelist)
            if nargin~=3
                error('Invalid number of arguments. The number of arguments should be 3.');
            end
            
            if ~isempty(value(CURRENT_TRAINING_STAGE_LIST))
                stagelist = varargin{1};
                for ctr = 1:length(stagelist)
                    if iscell(stagelist) && ischar(stagelist{ctr}) %Meaning stage name was given
                        stage_number = find(strcmp(value(CURRENT_TRAINING_STAGE_LIST), stagelist{ctr}), 1, 'first');
                    elseif isscalar(stagelist(ctr)) %Meaning stage number was given
                        stage_number = stagelist(ctr);
                    end
                    if stage_number <= length(value(CURRENT_TRAINING_STAGE_LIST))
                        CURRENT_DEACTIVATED_STAGES(end+1) = stage_number; %#ok<AGROW>
                    end
                end
                CURRENT_DEACTIVATED_STAGES.value = sort(value(CURRENT_DEACTIVATED_STAGES));
                STARTING_DEACTIVATED_STAGES.value = value(CURRENT_DEACTIVATED_STAGES);
                feval(mfilename, obj, 'refresh_lbxTrainingStages');
            end
            
            %% mark_not_deactivated
        case 'mark_not_deactivated'
            %SessionDefinition(obj, 'mark_not_deactivated', stagelist)
            if nargin~=3
                error('Invalid number of arguments. The number of arguments should be 3.');
            end
            
            if ~isempty(value(CURRENT_TRAINING_STAGE_LIST))
                stagelist = varargin{1};
                stages_to_mark_not_deactivated = [];
                for ctr = 1:length(stagelist)
                    if iscell(stagelist) && ischar(stagelist{ctr}) %Meaning stage name was given
                        stage_number = find(strcmp(value(CURRENT_TRAINING_STAGE_LIST), stagelist{ctr}), 1, 'first');
                    elseif isnumeric(stagelist(ctr)) %Meaning stage number was given
                        stage_number = stagelist(ctr);
                    end
                    if stage_number <= length(value(CURRENT_TRAINING_STAGE_LIST))
                        stages_to_mark_not_deactivated(end+1) = stage_number; %#ok<AGROW>
                    end
                end
                CURRENT_DEACTIVATED_STAGES.value = setdiff(value(CURRENT_DEACTIVATED_STAGES), stages_to_mark_not_deactivated);
                STARTING_DEACTIVATED_STAGES.value = value(CURRENT_DEACTIVATED_STAGES);
                feval(mfilename, obj, 'refresh_lbxTrainingStages');
            end
            
            
        otherwise
            
            error(['Unknown action ' action]);
            
    end
    
catch
    showerror;
end

end

%%
function base_n_vec = dec2basen(decval, n)

quotient = decval;
base_n_vec = zeros(1, floor(log(decval)/log(n))+1);
offset = 0;
while quotient >= n
    base_n_vec(end - offset) = mod(quotient, n);
    quotient = floor(quotient/n);
    offset = offset + 1;
end
base_n_vec(1) = quotient;

end

%%
function turnoff_all_radiobuttons(hndl)

handles = guihandles(hndl);
set(handles.radioStageAlgorithm, 'Value', false);
set(handles.radioCompletionTest, 'Value', false);
set(handles.radioEODLogic, 'Value', false);
set(handles.radioHelperVars, 'Value', false);
set(handles.radioName, 'Value', false);
set(handles.radioHelperFunctions, 'Value', false);

end

%%

function make_edit_windows_invisible(hndl)

handles = guihandles(hndl);
set(handles.editStageAlgorithm, 'Visible', 'off');
set(handles.editName, 'Visible', 'off');
set(handles.editHelperVars, 'Visible', 'off');
set(handles.editEODLogic, 'Visible', 'off');
set(handles.editCompletionTest, 'Visible', 'off');
set(handles.editHelperFunctions, 'Visible', 'off');

end

%%
function training_stage_list = get_training_stages(absolute_file_path)

fid = fopen(absolute_file_path, 'r');
if isequal(fid, -1)
    error(['ERROR: File ' absolute_file_path ' could not be opened. Please close all programs that may be using this file and try again.']);
else
    try
        number_of_training_stages = length(strfind(fscanf(fid, '%s'), '%<TRAINING_STAGE>'));
        frewind(fid);
        training_stage_list = cell(number_of_training_stages, 1);
        %PARSE M FILE TO OBTAIN ALL STAGE NAMES.
        ctr = 1;
        while ~feof(fid) && ctr<=number_of_training_stages
            str = fgetl(fid);
            if ~isempty(strfind(str, '%<TRAINING_STAGE>'))
                while isempty(strmatch('case ''', strtrim(str))) && ~feof(fid)
                    str = fgetl(fid);
                end
                str = strtrim(str);
                str = strrep(str, 'case ', '');
                str = strrep(str, '''', '');
                training_stage_list{ctr} = str;
                ctr = ctr + 1;
            end
        end
    catch
        fclose(fid);
        training_stage_list = {''};
        return;
    end
    fclose(fid);
end

end
%%
function stage_algorithm_list = get_stage_algorithms(absolute_file_path)

fid = fopen(absolute_file_path, 'r');
if isequal(fid, -1)
    error(['ERROR: File ' absolute_file_path ' could not be opened. Please close all programs that may be using this file and try again.']);
else
    try
        number_of_training_stages = length(strfind(fscanf(fid, '%s'), '%<TRAINING_STAGE>'));
        frewind(fid);
        stage_algorithm_list = cell(number_of_training_stages, 1);
        ctr = 1;
        while ~feof(fid) && ctr<=number_of_training_stages
            str = fgetl(fid);
            if ~isempty(strfind(str, '%<STAGE_ALGORITHM>'))
                stage_algorithm_single = cell(0,1);
                while isempty(strfind(str, '%</STAGE_ALGORITHM>')) && ~feof(fid)
                    str = fgetl(fid);
                    if isempty(strfind(str, '%</STAGE_ALGORITHM>'))
                        stage_algorithm_single{end+1} = str; %#ok<AGROW>
                    end
                end
                stage_algorithm_list{ctr} = stage_algorithm_single;
                ctr = ctr + 1;
            end
        end
    catch
        fclose(fid);
        stage_algorithm_list = {''};
        return;
    end
    fclose(fid);
end

end
%%
function completion_test_list = get_completion_tests(absolute_file_path)

fid = fopen(absolute_file_path, 'r');
if isequal(fid, -1)
    error(['ERROR: File ' absolute_file_path ' could not be opened. Please close all programs that may be using this file and try again.']);
else
    try
        number_of_training_stages = length(strfind(fscanf(fid, '%s'), '%<TRAINING_STAGE>'));
        frewind(fid);
        completion_test_list = cell(number_of_training_stages, 1);
        ctr = 1;
        while ~feof(fid) && ctr<=number_of_training_stages
            str = fgetl(fid);
            if ~isempty(strfind(str, '%<COMPLETION_TEST>'))
                completion_test_single = cell(0,1);
                while isempty(strfind(str, '%</COMPLETION_TEST>')) && ~feof(fid)
                    str = fgetl(fid);
                    if isempty(strfind(str, '%</COMPLETION_TEST>'))
                        completion_test_single{end+1} = str; %#ok<AGROW>
                    end
                end
                completion_test_list{ctr} = completion_test_single;
                ctr = ctr + 1;
            end
        end
    catch
        fclose(fid);
        completion_test_list = {''};
        return;
    end
    fclose(fid);
end

end
%%
function eod_logic_list = get_eod_logic_list(absolute_file_path)

fid = fopen(absolute_file_path, 'r');
if isequal(fid, -1)
    error(['ERROR: File ' absolute_file_path ' could not be opened. Please close all programs that may be using this file and try again.']);
else
    try
        number_of_training_stages = length(strfind(fscanf(fid, '%s'), '%<TRAINING_STAGE>'));
        frewind(fid);
        eod_logic_list = cell(number_of_training_stages, 1);
        ctr = 1;
        while ~feof(fid) && ctr<=number_of_training_stages
            str = fgetl(fid);
            if ~isempty(strfind(str, '%<END_OF_DAY_LOGIC>'))
                eod_logic_single = cell(0,1);
                while isempty(strfind(str, '%</END_OF_DAY_LOGIC>')) && ~feof(fid)
                    str = fgetl(fid);
                    if isempty(strfind(str, '%</END_OF_DAY_LOGIC>'))
                        eod_logic_single{end+1} = str; %#ok<AGROW>
                    end
                end
                eod_logic_list{ctr} = eod_logic_single;
                ctr = ctr + 1;
            end
        end
    catch
        fclose(fid);
        eod_logic_list = {''};
        return;
    end
    fclose(fid);
end

end

%%
function helper_function_list = get_helper_functions(absolute_file_path)

fid = fopen(absolute_file_path, 'r');
if isequal(fid, -1)
    error(['ERROR: File ' absolute_file_path ' could not be opened. Please close all programs that may be using this file and try again.']);
else
    try
        frewind(fid);
        helper_function_list = cell(1, 1);
        while ~feof(fid)
            str = fgetl(fid);
            if ~isempty(strfind(str, '%<HELPER_FUNCTIONS>'))
                helper_functions_single = cell(0,1);
                while isempty(strfind(str, '%</HELPER_FUNCTIONS>')) && ~feof(fid)
                    str = fgetl(fid);
                    if isempty(strfind(str, '%</HELPER_FUNCTIONS>'))
                        helper_functions_single{end+1} = str; %#ok<AGROW>
                    end
                end
                helper_function_list = helper_functions_single;
            end
        end
    catch
        fclose(fid);
        helper_function_list = '';
        return;
    end
    fclose(fid);
end

end

%%
function helper_var_list = get_helper_vars(absolute_file_path)

%This function looks for calls to the function
%CreateHelperVar(obj, varname, initval, force_init)
fid = fopen(absolute_file_path, 'r');
if isequal(fid, -1)
    error(['ERROR: File ' absolute_file_path ' could not be opened. Please close all programs that may be using this file and try again.']);
else
    try
        number_of_training_stages = length(strfind(fscanf(fid, '%s'), '%<TRAINING_STAGE>'));
        frewind(fid);
        helper_var_list = cell(number_of_training_stages, 1);
        ctr = 1;
        while ~feof(fid) && ctr<=number_of_training_stages
            str = fgetl(fid);
            if ~isempty(strfind(str, '%<HELPER_VARS>'))
                helper_vars_single = cell(0, 1);
                while isempty(strfind(str, '%</HELPER_VARS>')) && ~feof(fid)
                    str = fgetl(fid);
                    if isempty(strfind(str, '%</HELPER_VARS>'))
                        helper_vars_single{end+1} = str; %#ok<AGROW>
                    end
                end
                helper_var_list{ctr} = helper_vars_single;
                ctr = ctr + 1;
            end
        end
    catch %#ok<*CTCH>
        fclose(fid);
        helper_var_list = {''};
        return;
    end
    fclose(fid);
end

end


%%

function out = cell2str(cellarray, separator)
cellarray = cellarray(:);
cellarray = cellarray';
for ctr = 1:length(cellarray)
    if ctr<length(cellarray)
        cellarray{ctr} = [cellarray{ctr} separator];
    end
end
if ~isempty(cellarray)
    out = cell2mat(cellarray);
else
    out = '';
end
end

function out = formatstr(cellarray)
cellarray = strrep(cellarray, '\', '\\');
cellarray = strrep(cellarray, '%', '%%');
out = cellarray;
end

function out = getascell(hndl, property)
result = get(hndl, property);
if ~iscell(result)
    out = cell(size(result, 1), 1);
    for ctr = 1:size(result, 1)
        out{ctr} = result(ctr, :);
    end
else
    out = result;
end
end


%%

function training_stage_file_path = get_latest_training_stage_file_path(experimenter_name, rat_name, protocol_name)

Main_Data_Directory = bSettings('get', 'GENERAL', 'Main_Data_Directory');
if any(isnan(Main_Data_Directory)) || isempty(Main_Data_Directory)
    Main_Data_Directory = fullfile(filesep, 'ratter', 'SoloData');
end
currdir = pwd;
if ~exist(fullfile(Main_Data_Directory, 'Settings', experimenter_name, rat_name), 'dir')
    mkdir(fullfile(Main_Data_Directory, 'Settings', experimenter_name, rat_name));
end
cd(fullfile(Main_Data_Directory, 'Settings', experimenter_name, rat_name));
%The naming convention is to ensure that a simple sort operation on the
%file list returns the files in the order they are created
filelist = dir(['pipeline_' protocol_name '_' experimenter_name '_' rat_name '_*.m']);
for ctr = length(filelist):-1:1
    date_current_file = regexprep(filelist(ctr).name, '\D', '');
    date_current_file = date_current_file(end-5:end); %YYMMDD
    %if date_current_file > yearmonthday, pop file element
    if eval(date_current_file) > eval(yearmonthday)
        filelist(ctr) = [];
    end
end
filelist_name_cell = struct2cell(filelist(:));
filelist_name_cell = sort(filelist_name_cell(1,:));
training_stage_file_path = pwd;
if ~isempty(filelist_name_cell)
    training_stage_file_path = fullfile(training_stage_file_path, filelist_name_cell{end});
else
    training_stage_file_path = '';
end
cd(currdir);

end
%%

function write_data_to_training_stage_file(training_stage_list, ...
    stage_algorithm_list, ...
    completion_test_list, ...
    eod_logic_list, ...
    helper_var_list, ...
    helper_function_list, ...
    absolute_file_path)

file_directory = absolute_file_path(1:find(absolute_file_path==filesep, 1, 'last'));
file_name = absolute_file_path(find(absolute_file_path==filesep, 1, 'last')+1:end);
if ~strcmpi(file_name(end-1:end), '.m')
    error('The file extension has to be .m.');
end
if ~isvarname(file_name(1:end-2))
    error('The name of the M file is invalid.');
end

%Create directory if necessary
if ~exist(file_directory, 'dir')
    mkdir(file_directory);
end


%Step 1: Read the template file into a string
try
    fid = fopen('training_stage_file_template.txt', 'r');
    template_str = '';
    while ~feof(fid)
        template_str = [template_str fgets(fid)]; %#ok<AGROW>
    end
    template_str = strrep(template_str, '\', '\\');
    template_str = strrep(template_str, '%', '%%');
    fclose(fid);
catch
    try
        fclose(fid);
    catch
    end
end


%Step 2: Replace placeholders with appropriate data
file_name = absolute_file_path(find(absolute_file_path==filesep, 1, 'last')+1:end);
file_name = file_name(1:end-2); %For extension(.m)
template_str = strrep(template_str, '[TRAINING_STAGE_FILE_NAME]', file_name);


helper_function_list_str = cell2str(formatstr(helper_function_list), '\n');
template_str = strrep(template_str, '[HELPER_FUNCTIONS_AREA]', helper_function_list_str);


%Here, we need to build the data string that goes into
%[TRAINING_STAGES_AREA]
training_stages_str = '';
for ctr = 1:length(training_stage_list)
    %Removing trailing whitespace characters (especially the newline character seems
    %to give trouble
    helper_var_list{ctr} = regexprep(helper_var_list{ctr}, '\s+$', '');
    stage_algorithm_list{ctr} = regexprep(stage_algorithm_list{ctr}, '\s+$', '');
    completion_test_list{ctr} = regexprep(completion_test_list{ctr}, '\s+$', '');
    eod_logic_list{ctr} = regexprep(eod_logic_list{ctr}, '\s+$', '');
    
    training_stages_str = [training_stages_str ...
        '\n%%%% ' strtrim(strrep(training_stage_list{ctr}, '''', '')) '\n' ...
        '\n%%<TRAINING_STAGE>\n' ...
        'case ''' strtrim(strrep(training_stage_list{ctr}, '''', '')) '''\n' ...
        'if helper_vars_eval\n' ...
        'GetSoloFunctionArgs(obj);\n' ...
        'ClearHelperVarsNotOwned(obj);\n' ...
        '%%<HELPER_VARS>\n' ...
        cell2str(formatstr(helper_var_list{ctr}), '\n') '\n' ...
        '%%</HELPER_VARS>\n' ...
        'end\n' ...
        'if stage_algorithm_eval\n' ...
        'GetSoloFunctionArgs(obj);\n' ...
        'ClearHelperVarsNotOwned(obj);\n' ...
        '%%<STAGE_ALGORITHM>\n' ...
        cell2str(formatstr(stage_algorithm_list{ctr}), '\n') '\n' ...
        '%%</STAGE_ALGORITHM>\n' ...
        'end\n' ...
        'if completion_test_eval\n' ...
        'GetSoloFunctionArgs(obj);\n' ...
        'ClearHelperVarsNotOwned(obj);\n' ...
        'clear(''ans'');\n' ...
        '%%<COMPLETION_TEST>\n' ...
        cell2str(formatstr(completion_test_list{ctr}), '\n') '\n'...
        '%%</COMPLETION_TEST>\n' ...
        'if exist(''ans'', ''var'')\n' ...
        'varargout{1}=logical(ans); clear(''ans'');\n' ...
        'else\n' ...
        'varargout{1}=false;\n' ...
        'end\n' ...
        'end\n' ...
        'if eod_logic_eval\n' ...
        'GetSoloFunctionArgs(obj);\n' ...
        'ClearHelperVarsNotOwned(obj);\n' ...
        '%%<END_OF_DAY_LOGIC>\n' ...
        cell2str(formatstr(eod_logic_list{ctr}), '\n') '\n'...
        '%%</END_OF_DAY_LOGIC>\n' ...
        'end\n' ...
        '%%</TRAINING_STAGE>\n']; %#ok<AGROW>
end
template_str = strrep(template_str, '[TRAINING_STAGES_AREA]', training_stages_str);


%Step 3: Write data to training stage file
try
    fid = fopen(absolute_file_path, 'w');
    fprintf(fid, template_str);
    fclose(fid);
catch
    try
        fclose(fid);
    catch
    end
end

end
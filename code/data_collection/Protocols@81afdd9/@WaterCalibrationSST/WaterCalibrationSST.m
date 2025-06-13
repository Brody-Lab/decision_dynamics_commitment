%WaterCalibrationSST: Water Calibration Protocol addressing some of the
%issues with the earlier protocol.
% Sundeep Tuteja, 20th October,  2009

function [obj] = WaterCalibrationSST(varargin)

obj = class(struct, mfilename);

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

persistent currdir;
persistent newdir;
persistent isinitialized;

global CALIBRATION_HIGH_OR_LOW_CONST;
global PROTOCOL_NAME;
global LOW_TARGET_DATETIME;
global HIGH_TARGET_DATETIME;

PROTOCOL_NAME = mfilename;

% Temporary directory, permissions not an issue when the tempname command
% is used.
if isempty(newdir)
    newdir = tempname;
end
if isempty(isinitialized)
    isinitialized = false;
end

switch action
    
    %% init
    case 'init'
        isinitialized = false;
        errflag = true;
        cancel_pressed = false;
        while errflag == true
            errflag = false;
            options.WindowStyle = 'modal';
            initials_cell = inputdlg('Enter your initials:', 'Initials', 1, {''}, options);
            if isempty(initials_cell)
                cancel_pressed = true;
                break;
            end
            userinitials = upper(initials_cell{1});
            userinitials = regexprep(userinitials, '\s', '');
            if isempty(userinitials)
                errflag = true;
                waitfor(errordlg('ERROR: You must enter your initials.', 'ERROR', 'modal'));
                continue;
            end
        end
        if cancel_pressed
            
            dispatcher('set_protocol', '');
            
        else
        
            % Preserve the current directory for subsequent directory changes
            currdir = pwd;

            % Clear temporary directory to remove any remnants of old
            % calibration procedures, in case cleanup wasn't done correctly.
            cd(tempdir);
            filelist = dir;
            warning('off', 'MATLAB:DELETE:Permission');
            for ctr = 1:length(filelist)
                if ~strcmpi(filelist(ctr).name, '.') && ~strcmpi(filelist(ctr).name, '..')
                    if filelist(ctr).isdir
                        try
                            rmdir(filelist(ctr).name, 's');
                        catch %#ok<CTCH>
                        end
                    else
                        try
                            delete(filelist(ctr).name)
                        catch %#ok<CTCH>
                        end
                    end
                end
            end
            warning('on', 'MATLAB:DELETE:Permission');
            cd(currdir);

            % newdir is a temporary directory. If it exists, we would want to
            % remove it and replace it (highly unlikely). If not, we can simply
            % create the temporary directory. Added to allow use of MATLAB
            % GUIDE GUIs.
            if exist(newdir, 'dir')
                try
                    rmdir(newdir, 's');
                    mkdir(newdir);
                catch %#ok<CTCH>
                    warning(['Could not remove ', newdir]); %#ok<WNTAG>
                end
            else
                mkdir(newdir);
            end

            %If older than R2008b, don't run
            if verLessThan('matlab', '7.7')
                waitfor(errordlg('Error: This version of MATLAB is too old. Please use R2008b or later.', 'Error', 'modal'));
                dispatcher('close');
            end

            % Duplicating the protocol directory in the temporary directory
            Protocols_Directory = bSettings('get', 'GENERAL', 'Protocols_Directory');
            if isnan(Protocols_Directory)
                Protocols_Directory = fullfile(filesep, 'ratter', 'Protocols');
            end
            copyfile(fullfile(Protocols_Directory, ['@', mfilename]), ...
                fullfile(newdir, mfilename), ...
                'f');

            % Now we change directory to this new temporary directory, so that
            % we can seamlessly use the MATLAB GUI.
            cd(fullfile(newdir, mfilename));
            % We won't need the constructor file since we're no longer in a
            % class folder
            delete([mfilename, '.m']);


            % INITIALIZE!
            CALIBRATION_HIGH_OR_LOW_CONST = 'LOW';
            init;
            hndlWaterCalibrationGUI = findobj(findall(0), 'Name', 'WATER_CALIBRATION');
            % Setting it to invisible so that the user is forced to use it only
            % once the protocol starts running
            set(hndlWaterCalibrationGUI(1), 'Visible', 'off');
            handles = guihandles(hndlWaterCalibrationGUI(1));
            set(handles.editUserInitials, 'String', userinitials);
            
            setDefaultPulseTime('Warning', 'false');

            %Goto prepare_next_trial
            sma = StateMachineAssembler('full_trial_structure');
            sma = add_state(sma, ...
                'self_timer', 0.0001, ...
                'input_to_statechange', {'Tup', 'check_next_trial_ready'});

            dispatcher('send_assembler', sma, 'check_next_trial_ready');

            isinitialized = true;
        end
        
        %% prepare next trial
    case 'prepare_next_trial'
        
        if ~isinitialized
            feval(mfilename, 'init');
        end
        
        cd(fullfile(newdir, mfilename));
        
        fprintf(['\n', datestr(now), ' - ', mfilename, ' - PREPARE_NEXT_TRIAL\n']);
        
        hndlWaterCalibrationGUI = findobj(findall(0), 'Name', 'WATER_CALIBRATION');
        handles = guihandles(hndlWaterCalibrationGUI(1));
        
        % Set the GUI window to visible once the protocol is running.
        set(hndlWaterCalibrationGUI(1), 'Visible', 'on');
        
        if strcmpi(CALIBRATION_HIGH_OR_LOW_CONST, 'LOW_CALC') || strcmpi(CALIBRATION_HIGH_OR_LOW_CONST, 'HIGH_CALC') %Indicates a calibration procedure has just been completed
            feval(mfilename, 'validate_calibration');
        else
            if strcmpi(CALIBRATION_HIGH_OR_LOW_CONST, 'LOW')
                waitfor(handles.btnStartCalibrationLowTarget, 'Enable', 'off'); %Wait for btnStartCalibrationLowTarget to be pressed
            elseif strcmpi(CALIBRATION_HIGH_OR_LOW_CONST, 'HIGH')
                waitfor(handles.btnStartCalibrationHighTarget, 'Enable', 'off'); %Wait for btnStartCalibrationHighTarget to be pressed
            elseif strcmpi(CALIBRATION_HIGH_OR_LOW_CONST, 'EXIT')
                waitfor(hndlWaterCalibrationGUI(1)); %Wait for GUI window to be closed
            end
        end
        
        %% start_calibration
    case 'start_calibration'
        
        cd(fullfile(newdir, mfilename));
        
        fprintf(['\n', datestr(now), ' - ', mfilename, ' - START_CALIBRATION\n']);
        
        %Redundancy: to ensure that the correct values of
        %CALIBRATION_HIGH_OR_LOW_CONST are present
        if strcmpi(CALIBRATION_HIGH_OR_LOW_CONST, 'LOW') || strcmpi(CALIBRATION_HIGH_OR_LOW_CONST, 'HIGH')
            
            
            %Get data from GUI
            hndlWaterCalibrationGUI = findobj(findall(0), 'Name', 'WATER_CALIBRATION');
            handles = guihandles(hndlWaterCalibrationGUI(1));
            number_of_pulses = eval(get(handles.NUMBER_OF_PULSES, 'String'));
            inter_pulse_interval = eval(get(handles.INTER_PULSE_INTERVAL_SECONDS, 'String'));
            
            %Initialize state machine assembler object
            sma = StateMachineAssembler('full_trial_structure');
            
            %Get values for DIOLINES variables
            left1water = bSettings('get', 'DIOLINES', 'left1water');
            left1led = bSettings('get', 'DIOLINES', 'left1led');
            center1water = bSettings('get', 'DIOLINES', 'center1water');
            center1led = bSettings('get', 'DIOLINES', 'center1led');
            right1water = bSettings('get', 'DIOLINES', 'right1water');
            right1led = bSettings('get', 'DIOLINES', 'right1led');
            
            %Obtain number of valves available, which will be used to
            %compute inter_valve_pause
            number_of_valves = 0;
            if isnan(center1water)
                center_pulse_time = 0;
            else
                center_pulse_time = eval(get(handles.CENTER_PULSE_TIME_SECONDS, 'String'));
                number_of_valves = number_of_valves + 1;
            end
            if isnan(left1water)
                left_pulse_time = 0;
            else
                left_pulse_time = eval(get(handles.LEFT_PULSE_TIME_SECONDS, 'String'));
                number_of_valves = number_of_valves + 1;
            end
            if isnan(right1water)
                right_pulse_time = 0;
            else
                right_pulse_time = eval(get(handles.RIGHT_PULSE_TIME_SECONDS, 'String'));
                number_of_valves = number_of_valves + 1;
            end
            min_state_time = 0.0001;
            
            %By this time, setDefaultPulseTime should have taken care of
            %this, but just in case...
            try
                assert(inter_pulse_interval - left_pulse_time - center_pulse_time - right_pulse_time > 0);
            catch %#ok<CTCH>
            end
            
            %To prevent a divide by zero situation
            if ~isequal(number_of_valves, 0)
                inter_valve_pause = (inter_pulse_interval - left_pulse_time - center_pulse_time - right_pulse_time)/number_of_valves;
            else
                waitfor(errordlg('ERROR: No valves found, so calibration is not possible.', 'ERROR', 'modal'));
                dispatcher('close');
            end
            
            
            %Building state machine
            sma = add_state(sma, ...
                'self_timer', min_state_time, ...
                'default_statechange', 'current_state+1');
            
            %State: pulsing
            sma = add_state(sma, ...
                'name', 'pulsing', ...
                'self_timer', min_state_time, ...
                'default_statechange', 'current_state+1');
            
            %Pulse number_of_pulses times
            for ctr = 1:number_of_pulses
                if ~isequal(left_pulse_time, 0)
                    sma = add_state(sma, ...
                        'self_timer', left_pulse_time, ...
                        'input_to_statechange', {'Tup', 'current_state+1'}, ...
                        'output_actions', {'DOut', left1led + left1water});
                    
                    sma = add_state(sma, ...
                        'self_timer', inter_valve_pause, ...
                        'input_to_statechange', {'Tup', 'current_state+1'});
                end
                
                
                if ~isequal(center_pulse_time, 0)
                    sma = add_state(sma, ...
                        'self_timer', center_pulse_time, ...
                        'input_to_statechange', {'Tup', 'current_state+1'}, ...
                        'output_actions', {'DOut', center1led + center1water});
                    
                    sma = add_state(sma, ...
                        'self_timer', inter_valve_pause, ...
                        'input_to_statechange', {'Tup', 'current_state+1'});
                end
                
                if ~isequal(right_pulse_time, 0)
                    sma = add_state(sma, ...
                        'self_timer', right_pulse_time, ...
                        'input_to_statechange', {'Tup', 'current_state+1'}, ...
                        'output_actions', {'DOut', right1led + right1water});
                    
                    sma = add_state(sma, ...
                        'self_timer', inter_valve_pause, ...
                        'input_to_statechange', {'Tup', 'current_state+1'});
                end
            end
            
            %Dummy final state
            sma = add_state(sma, ...
                'name', 'calibrationcomplete', ...
                'self_timer', 0.1, ...
                'input_to_statechange', {'Tup', 'check_next_trial_ready'});
            
            %To move to validate calibration after prepare_next_trial
            CALIBRATION_HIGH_OR_LOW_CONST = [CALIBRATION_HIGH_OR_LOW_CONST, '_CALC'];
            
            dispatcher('send_assembler', sma, 'check_next_trial_ready');
            
        end
        
        
        
        
        %% validate_calibration
    case 'validate_calibration'
        
        cd(fullfile(newdir, mfilename));
        
        fprintf(['\n', datestr(now), ' - ', mfilename, ' - VALIDATE_CALIBRATION\n']);
        
        left1water = bSettings('get', 'DIOLINES', 'left1water');
        center1water = bSettings('get', 'DIOLINES', 'center1water');
        right1water = bSettings('get', 'DIOLINES', 'right1water');
        
        
        %Get data from GUI
        hndlWaterCalibrationGUI = findobj(findall(0), 'Name', 'WATER_CALIBRATION');
        handles = guihandles(hndlWaterCalibrationGUI(1));
        number_of_pulses = eval(get(handles.NUMBER_OF_PULSES, 'String'));
        if isnan(center1water)
            center_pulse_time = 0;
        else
            center_pulse_time = eval(get(handles.CENTER_PULSE_TIME_SECONDS, 'String'));
        end
        if isnan(left1water)
            left_pulse_time = 0;
        else
            left_pulse_time = eval(get(handles.LEFT_PULSE_TIME_SECONDS, 'String'));
        end
        if isnan(right1water)
            right_pulse_time = 0;
        else
            right_pulse_time = eval(get(handles.RIGHT_PULSE_TIME_SECONDS, 'String'));
        end
        if strcmpi(CALIBRATION_HIGH_OR_LOW_CONST, 'HIGH_CALC')
            target_dispense = eval(get(handles.HIGH_TARGET_MICROLITERS, 'String'));
        elseif strcmpi(CALIBRATION_HIGH_OR_LOW_CONST, 'LOW_CALC')
            target_dispense = eval(get(handles.LOW_TARGET_MICROLITERS, 'String'));
        end
        error_tolerance = eval(get(handles.ERROR_TOLERANCE_MICROLITERS, 'String'));
        %weight_of_cup = eval(get(handles.WEIGHT_OF_CUP_GRAMS, 'String'));
        weight_of_cup = 0;
        
        
        
        %Now weigh the cups
        prompt = cell(3,1);
        prompt{1} = 'Enter the weight obtained from the left cup (grams):';
        prompt{2} = 'Enter the weight obtained from the center cup (grams):';
        prompt{3} = 'Enter the weight obtained from the right cup (grams):';
        dlg_title = 'Enter Weights';
        numlines = 1;
        defAns = {'0.0', '0.0', '0.0'};
        options.WindowStyle = 'modal';
        %Data validation
        errflag = true;
        while errflag == true
            errflag = false;
            answer = inputdlg(prompt, dlg_title, numlines, defAns, options);
            if ~isempty(answer)
                for ctr = 1:length(answer)
                    try
                        answer{ctr} = regexprep(answer{ctr}, '\s', '');
                        answer_num = eval(answer{ctr});
                        if isempty(answer{ctr}) || ~isnumeric(answer_num) || ...
                                (ctr==1 && ~isnan(left1water) && answer_num - weight_of_cup < 0) || ...
                                (ctr==2 && ~isnan(center1water) && answer_num - weight_of_cup < 0) || ...
                                (ctr==3 && ~isnan(right1water) && answer_num - weight_of_cup < 0)
                            error(' ');
                        end
                        %Analyzing a range for the entered value, to detect
                        %unrealistic input.
                        if (answer_num < 1.0 || answer_num > 6.0) && answer_num ~= 0.0
                            cup_position = {'left', 'center', 'right'};
                            are_weights_correct = questdlg(['The value for the weight obtained from the ' cup_position{ctr} ' cup seems unrealistic. Are you sure you entered it correctly?'], ...
                                'Confirmation', 'YES', 'NO', 'NO');
                            if strcmp(are_weights_correct, 'NO')
                                errflag = true;
                                break;
                            end
                        end
                    catch %#ok<CTCH>
                        errflag = true;
                        waitfor(errordlg('ERROR: Invalid input.', 'ERROR', 'modal'));
                        break;
                    end
                end
            end
        end
        
        
        % From the weights entered, calculate actual dispense rate and
        % highlight appropriate fields in green or red
        
        if ~isempty(answer)
            
            %             errflag = true;
            %             while errflag == true
            %                 errflag = false;
            %                 options.WindowStyle = 'modal';
            %                 initials_cell = inputdlg('Enter your initials:', 'Initials', 1, {''}, options);
            %                 if isempty(initials_cell)
            %                     errflag = true;
            %                     waitfor(errordlg('ERROR: You must enter your initials.', 'ERROR', 'modal'));
            %                     continue;
            %                 end
            %                 initials = upper(initials_cell{1});
            %                 initials = regexprep(initials, '\s', '');
            %                 if isempty(initials)
            %                     errflag = true;
            %                     waitfor(errordlg('ERROR: You must enter your initials.', 'ERROR', 'modal'));
            %                     continue;
            %                 end
            %             end
            
            initials = get(handles.editUserInitials, 'String');
            
            left_weight = eval(answer{1}) - weight_of_cup;
            left_weight(left_weight < 0) = 0;
            center_weight = eval(answer{2}) - weight_of_cup;
            center_weight(center_weight < 0) = 0;
            right_weight = eval(answer{3}) - weight_of_cup;
            right_weight(right_weight < 0) = 0;
            
            %dispense rate = volume obtained in microliters / number of pulses
            %distilled water: 1000 microliters per gram
            density_inverse = 1000;
            left_dispense = (left_weight * density_inverse)/number_of_pulses;
            center_dispense = (center_weight * density_inverse)/number_of_pulses;
            right_dispense = (right_weight * density_inverse)/number_of_pulses;
            %Save latest calibration data
            [status, hostname] = system('hostname'); hostname = lower(hostname);
            hostname = regexprep(hostname, '\s', ''); hostname = regexprep(hostname, '\..*', '');
            Calibration_Data_Directory = bSettings('get', 'GENERAL', 'Calibration_Data_Directory');
            if isnan(Calibration_Data_Directory)
                Calibration_Data_Directory = '\ratter\CNMC\Calibration';
            end
            Calibration_Data_Directory = strrep(Calibration_Data_Directory, '\', filesep);
            if exist(fullfile(Calibration_Data_Directory, [hostname, '_watertable.mat']), 'file')
                load(fullfile(Calibration_Data_Directory, [hostname, '_watertable.mat']));
            else
                wt = struct([]);
            end
            current_datetime = now;
            if ~isnan(left1water)
                wt(end+1).initials = initials;
                wt(end).date = current_datetime;
                wt(end).valve = 'left1water';
                wt(end).time = left_pulse_time;
                wt(end).dispense = left_dispense;
                wt(end).isvalid = true;
            end
            if ~isnan(center1water)
                wt(end+1).initials = initials;
                wt(end).date = current_datetime;
                wt(end).valve = 'center1water';
                wt(end).time = center_pulse_time;
                wt(end).dispense = center_dispense;
                wt(end).isvalid = true;
            end
            if ~isnan(right1water)
                wt(end+1).initials = initials;
                wt(end).date = current_datetime;
                wt(end).valve = 'right1water';
                wt(end).time = right_pulse_time;
                wt(end).dispense = right_dispense;
                wt(end).isvalid = true; %#ok<NASGU>
            end
            if ~exist(Calibration_Data_Directory, 'dir')
                mkdir(Calibration_Data_Directory);
            end
            save(fullfile(Calibration_Data_Directory, [hostname, '_watertable.mat']), 'wt', '-v7');
            refreshWaterTable;
            sync_database;
            
            
            
            
            %Validate calibration
            iscalibrationvalid = true;
            if ~isnan(left1water)
                set(handles.LeftWeightMeasured, 'String', num2str(left_weight));
                set(handles.LeftActualDispense, 'String', num2str(left_dispense));
                set(handles.LeftTargetDispense, 'String', num2str(target_dispense));
                if abs(left_dispense - target_dispense) <= error_tolerance
                    set(handles.LeftActualDispense, 'BackgroundColor', 'green');
                else
                    set(handles.LeftActualDispense, 'BackgroundColor', 'red');
                    iscalibrationvalid = false;
                end
            end
            if ~isnan(center1water)
                set(handles.CenterWeightMeasured, 'String', num2str(center_weight));
                set(handles.CenterActualDispense, 'String', num2str(center_dispense));
                set(handles.CenterTargetDispense, 'String', num2str(target_dispense));
                if abs(center_dispense - target_dispense) <= error_tolerance
                    set(handles.CenterActualDispense, 'BackgroundColor', 'green');
                else
                    set(handles.CenterActualDispense, 'BackgroundColor', 'red');
                    iscalibrationvalid = false;
                end
            end
            if ~isnan(right1water)
                set(handles.RightWeightMeasured, 'String', num2str(right_weight));
                set(handles.RightActualDispense, 'String', num2str(right_dispense));
                set(handles.RightTargetDispense, 'String', num2str(target_dispense));
                if abs(right_dispense - target_dispense) <= error_tolerance
                    set(handles.RightActualDispense, 'BackgroundColor', 'green');
                else
                    set(handles.RightActualDispense, 'BackgroundColor', 'red');
                    iscalibrationvalid = false;
                end
            end
            
            
            
            if iscalibrationvalid
                
                
                waitfor(msgbox('CALIBRATION VALID!!!', 'modal'));
                
                
                if strcmpi(CALIBRATION_HIGH_OR_LOW_CONST, 'LOW_CALC')
                    LOW_TARGET_DATETIME = datestr(wt(end).date);
                    
                    %Set CALIBRATION_HIGH_OR_LOW_CONST flag
                    CALIBRATION_HIGH_OR_LOW_CONST = 'HIGH';
                    set(handles.btnStartCalibrationLowTarget, 'BackgroundColor', [212 208 200]./255);
                    set(handles.btnStartCalibrationLowTarget, 'Enable', 'off');
                    set(handles.btnStartCalibrationHighTarget, 'BackgroundColor', 'yellow');
                    set(handles.btnStartCalibrationHighTarget, 'Enable', 'on');
                    set(handles.btnExit, 'BackgroundColor', 'red');
                    set(handles.btnExit, 'Enable', 'on');
                    set(handles.btnHelp, 'BackgroundColor', 'green');
                    set(handles.btnHelp, 'Enable', 'on');
                    set(handles.btnSuggestPulseTimes, 'BackgroundColor', 'green');
                    set(handles.btnSuggestPulseTimes, 'Enable', 'on');
                    set(handles.btnCustomizeSettings, 'BackgroundColor', 'green');
                    set(handles.btnCustomizeSettings, 'Enable', 'on');
                    set(handles.btnDeleteSelectedEntries, 'BackgroundColor', 'green');
                    set(handles.btnDeleteSelectedEntries, 'Enable', 'on');
                    set(handles.btnRestartCalibrationProcess, 'BackgroundColor', 'green');
                    set(handles.btnRestartCalibrationProcess, 'Enable', 'on');
                    set(handles.btnIgnoreSelectedEntries, 'BackgroundColor', 'green');
                    set(handles.btnIgnoreSelectedEntries, 'Enable', 'on');
                    set(handles.btnAcceptSelectedEntries, 'BackgroundColor', 'green');
                    set(handles.btnAcceptSelectedEntries, 'Enable', 'on');
                    
                    setDefaultPulseTime;
                    
                elseif strcmpi(CALIBRATION_HIGH_OR_LOW_CONST, 'HIGH_CALC') %Implies calibration is complete
                    HIGH_TARGET_DATETIME = datestr(wt(end).date);
                    
                    %Set button properties
                    
                    CALIBRATION_HIGH_OR_LOW_CONST = 'EXIT';
                    
                    set(handles.btnStartCalibrationLowTarget, 'BackgroundColor', [212 208 200]./255);
                    set(handles.btnStartCalibrationLowTarget, 'Enable', 'off');
                    set(handles.btnStartCalibrationHighTarget, 'BackgroundColor', [212 208 200]./255);
                    set(handles.btnStartCalibrationHighTarget, 'Enable', 'off');
                    set(handles.btnExit, 'BackgroundColor', 'yellow');
                    set(handles.btnExit, 'Enable', 'on');
                    set(handles.btnHelp, 'BackgroundColor', 'green');
                    set(handles.btnHelp, 'Enable', 'on');
                    set(handles.btnSuggestPulseTimes, 'BackgroundColor', 'green');
                    set(handles.btnSuggestPulseTimes, 'Enable', 'on');
                    set(handles.btnCustomizeSettings, 'BackgroundColor', 'green');
                    set(handles.btnCustomizeSettings, 'Enable', 'on');
                    set(handles.btnDeleteSelectedEntries, 'BackgroundColor', 'green');
                    set(handles.btnDeleteSelectedEntries, 'Enable', 'on');
                    set(handles.btnRestartCalibrationProcess, 'BackgroundColor', 'green');
                    set(handles.btnRestartCalibrationProcess, 'Enable', 'on');
                    set(handles.btnIgnoreSelectedEntries, 'BackgroundColor', 'green');
                    set(handles.btnIgnoreSelectedEntries, 'Enable', 'on');
                    set(handles.btnAcceptSelectedEntries, 'BackgroundColor', 'green');
                    set(handles.btnAcceptSelectedEntries, 'Enable', 'on');
                    
                end
                
            else %if calibration is not valid
                
                waitfor(msgbox('Calibration is not valid!', 'modal'));
                
                if strcmpi(CALIBRATION_HIGH_OR_LOW_CONST, 'LOW_CALC')
                    CALIBRATION_HIGH_OR_LOW_CONST = 'LOW';
                    set(handles.btnStartCalibrationLowTarget, 'BackgroundColor', 'yellow');
                    set(handles.btnStartCalibrationLowTarget, 'Enable', 'on');
                    set(handles.btnStartCalibrationHighTarget, 'BackgroundColor', [212 208 200]./255);
                    set(handles.btnStartCalibrationHighTarget, 'Enable', 'off');
                    set(handles.btnExit, 'BackgroundColor', 'red');
                    set(handles.btnExit, 'Enable', 'on');
                    set(handles.btnHelp, 'BackgroundColor', 'green');
                    set(handles.btnHelp, 'Enable', 'on');
                    set(handles.btnSuggestPulseTimes, 'BackgroundColor', 'green');
                    set(handles.btnSuggestPulseTimes, 'Enable', 'on');
                    set(handles.btnCustomizeSettings, 'BackgroundColor', 'green');
                    set(handles.btnCustomizeSettings, 'Enable', 'on');
                    set(handles.btnDeleteSelectedEntries, 'BackgroundColor', 'green');
                    set(handles.btnDeleteSelectedEntries, 'Enable', 'on');
                    set(handles.btnRestartCalibrationProcess, 'BackgroundColor', 'green');
                    set(handles.btnRestartCalibrationProcess, 'Enable', 'on');
                    set(handles.btnIgnoreSelectedEntries, 'BackgroundColor', 'green');
                    set(handles.btnIgnoreSelectedEntries, 'Enable', 'on');
                    set(handles.btnAcceptSelectedEntries, 'BackgroundColor', 'green');
                    set(handles.btnAcceptSelectedEntries, 'Enable', 'on');
                elseif strcmpi(CALIBRATION_HIGH_OR_LOW_CONST, 'HIGH_CALC')
                    CALIBRATION_HIGH_OR_LOW_CONST = 'HIGH';
                    set(handles.btnStartCalibrationLowTarget, 'BackgroundColor', [212 208 200]./255);
                    set(handles.btnStartCalibrationLowTarget, 'Enable', 'off');
                    set(handles.btnStartCalibrationHighTarget, 'BackgroundColor', 'yellow');
                    set(handles.btnStartCalibrationHighTarget, 'Enable', 'on');
                    set(handles.btnExit, 'BackgroundColor', 'red');
                    set(handles.btnExit, 'Enable', 'on');
                    set(handles.btnHelp, 'BackgroundColor', 'green');
                    set(handles.btnHelp, 'Enable', 'on');
                    set(handles.btnSuggestPulseTimes, 'BackgroundColor', 'green');
                    set(handles.btnSuggestPulseTimes, 'Enable', 'on');
                    set(handles.btnCustomizeSettings, 'BackgroundColor', 'green');
                    set(handles.btnCustomizeSettings, 'Enable', 'on');
                    set(handles.btnDeleteSelectedEntries, 'BackgroundColor', 'green');
                    set(handles.btnDeleteSelectedEntries, 'Enable', 'on');
                    set(handles.btnRestartCalibrationProcess, 'BackgroundColor', 'green');
                    set(handles.btnRestartCalibrationProcess, 'Enable', 'on');
                    set(handles.btnIgnoreSelectedEntries, 'BackgroundColor', 'green');
                    set(handles.btnIgnoreSelectedEntries, 'Enable', 'on');
                    set(handles.btnAcceptSelectedEntries, 'BackgroundColor', 'green');
                    set(handles.btnAcceptSelectedEntries, 'Enable', 'on');
                end
                
                setDefaultPulseTime;
                
            end
            
        else
            
            if strcmpi(CALIBRATION_HIGH_OR_LOW_CONST, 'LOW_CALC')
                CALIBRATION_HIGH_OR_LOW_CONST = 'LOW';
                set(handles.btnStartCalibrationLowTarget, 'BackgroundColor', 'yellow');
                set(handles.btnStartCalibrationLowTarget, 'Enable', 'on');
                set(handles.btnStartCalibrationHighTarget, 'BackgroundColor', [212 208 200]./255);
                set(handles.btnStartCalibrationHighTarget, 'Enable', 'off');
            elseif strcmpi(CALIBRATION_HIGH_OR_LOW_CONST, 'HIGH_CALC');
                CALIBRATION_HIGH_OR_LOW_CONST = 'HIGH';
                set(handles.btnStartCalibrationLowTarget, 'BackgroundColor', [212 208 200]./255);
                set(handles.btnStartCalibrationLowTarget, 'Enable', 'off');
                set(handles.btnStartCalibrationHighTarget, 'BackgroundColor', 'yellow');
                set(handles.btnStartCalibrationHighTarget, 'Enable', 'on');
            end
            
            %Set button properties
            set(handles.btnExit, 'BackgroundColor', 'red');
            set(handles.btnExit, 'Enable', 'on');
            set(handles.btnHelp, 'BackgroundColor', 'green');
            set(handles.btnHelp, 'Enable', 'on');
            set(handles.btnSuggestPulseTimes, 'BackgroundColor', 'green');
            set(handles.btnSuggestPulseTimes, 'Enable', 'on');
            set(handles.btnCustomizeSettings, 'BackgroundColor', 'green');
            set(handles.btnCustomizeSettings, 'Enable', 'on');
            set(handles.btnDeleteSelectedEntries, 'BackgroundColor', 'green');
            set(handles.btnDeleteSelectedEntries, 'Enable', 'on');
            set(handles.btnRestartCalibrationProcess, 'BackgroundColor', 'green');
            set(handles.btnRestartCalibrationProcess, 'Enable', 'on');
            set(handles.btnIgnoreSelectedEntries, 'BackgroundColor', 'green');
            set(handles.btnIgnoreSelectedEntries, 'Enable', 'on');
            set(handles.btnAcceptSelectedEntries, 'BackgroundColor', 'green');
            set(handles.btnAcceptSelectedEntries, 'Enable', 'on');
            
        end
        
        sma = StateMachineAssembler('full_trial_structure');
        
        sma = add_state(sma, ...
            'self_timer', 0.001, ...
            'name', 'stop_state', ...
            'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        
        dispatcher('send_assembler', sma, 'check_next_trial_ready');
        
        
        
    case 'stop_calibration'
        sma = StateMachineAssembler('full_trial_structure');
        sma = add_state(sma, ...
            'name', 'looping_stop_state', ...
            'self_timer', 0.01, ...
            'input_to_statechange', {'Tup', 'looping_stop_state'});
        dispatcher('send_assembler', sma, 'check_next_trial_ready');
        isinitialized = false;
        
        %% trial_completed
    case 'trial_completed'
        
        
        
        
        
        %% update
    case 'update'
        
        % msgbox('UPDATE!!!');
        
        
        
        %% close
    case 'close'
        
        try
            fprintf(['\n', datestr(now), ' - ', mfilename, ' - CLOSE\n']);

            try
                mym('close');
            catch %#ok<CTCH>
            end

            cd(currdir);
            [status, hostname] = system('hostname'); hostname = lower(hostname);
            hostname = regexprep(hostname, '\s', ''); hostname = regexprep(hostname, '\..*', '');
            if exist(fullfile(newdir, mfilename, [hostname, '_watertable.mat']), 'file')
                delete(fullfile(newdir, mfilename, [hostname, '_watertable.mat']));
            end
            Protocols_Directory = bSettings('get', 'GENERAL', 'Protocols_Directory');
            if isnan(Protocols_Directory)
                Protocols_Directory = fullfile(filesep, 'ratter', 'Protocols');
            end                
            copyfile(fullfile(newdir, mfilename), ...
                fullfile(Protocols_Directory, ['@', mfilename]), ...
                'f');
            rmdir(newdir, 's');
            clear('currdir', 'newdir', 'isinitialized', 'CALIBRATION_HIGH_OR_LOW_CONST', 'PROTOCOL_NAME');
        catch
            %DO NOTHING
        end
        
        %% end_session
    case 'end_session'
        
        
        
        
        %% pre_saving_settings
    case 'pre_saving_settings'
        
        
        
        %% otherwise
        
    otherwise
        warning('Unknown action! "%s"\n', action); %#ok<WNTAG>
end

return



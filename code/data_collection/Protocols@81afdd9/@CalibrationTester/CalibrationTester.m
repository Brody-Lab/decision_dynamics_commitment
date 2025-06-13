

function [obj] = CalibrationTester(varargin)

%This protocol can be used to test the calibration of the water valves. It
%allows you to enter the desired volume per dispense, and number of pulses.
%Then, it pulses all valves for the input number of pulses and allows the
%experimenter to enter the weights obtained. Once the weights are entered,
%the protocol displays the estimated actual volume per dispense.

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
        if exist('SAVED_CALIBRATIONTESTER_RESULT.mat', 'file')
            delete('SAVED_CALIBRATIONTESTER_RESULT.mat');
        end
        SoloParamHandle(obj, 'myfig', 'value', ...
            figure('CloseRequestFcn', 'dispatcher(''close'')', 'MenuBar', 'none', 'Name', mfilename, 'Visible', 'off'), ...
            'saveable', false);
        
        SoloParamHandle(obj, 'last_action', 'value', 'init');
        
        x = 1; y = 1;
        NumeditParam(obj, 'desired_volume_per_dispense', 1.5, x, y); next_row(y);
        
        NumeditParam(obj, 'number_of_pulses', 1600, x, y); next_row(y);
        
        PushbuttonParam(obj, 'START', x, y); next_row(y);
        set_callback(START, {mfilename, 'START_Callback'});
        
        %Goto prepare_next_trial
        sma = StateMachineAssembler('full_trial_structure');
        sma = add_state(sma, ...
            'self_timer', 0.0001, ...
            'input_to_statechange', {'Tup', 'check_next_trial_ready'});

        dispatcher('send_assembler', sma, 'check_next_trial_ready');
        
    case 'update'
        
    case 'RunSMA'
        disable(desired_volume_per_dispense); disable(number_of_pulses);
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
            center_pulse_time = interpolate_value(WaterCalibrationTable, 'center1water', value(desired_volume_per_dispense));
            number_of_valves = number_of_valves + 1;
        end
        if isnan(left1water)
            left_pulse_time = 0;
        else
            left_pulse_time = interpolate_value(WaterCalibrationTable, 'left1water', value(desired_volume_per_dispense));
            number_of_valves = number_of_valves + 1;
        end
        if isnan(right1water)
            right_pulse_time = 0;
        else
            right_pulse_time = interpolate_value(WaterCalibrationTable, 'right1water', value(desired_volume_per_dispense));
            number_of_valves = number_of_valves + 1;
        end
        min_state_time = 0.0001;
        
        inter_pulse_interval = center_pulse_time + left_pulse_time + right_pulse_time + 0.1;
            
        %To prevent a divide by zero situation
        if ~isequal(number_of_valves, 0)
            inter_valve_pause = (inter_pulse_interval - left_pulse_time - center_pulse_time - right_pulse_time)/number_of_valves;
        else
            waitfor(errordlg('ERROR: No valves found, so calibration is not possible.', 'ERROR', 'modal'));
            dispatcher('close');
        end
            
            
        sma = StateMachineAssembler('full_trial_structure');
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
        for ctr = 1:value(number_of_pulses)
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
            
        
        last_action.value = 'RunSMA';
        
            
        dispatcher('send_assembler', sma, 'check_next_trial_ready');
        
        
    case 'START_Callback'
        set(get_ghandle(START), 'Enable', 'off');
        
        
    case 'prepare_next_trial'
        if strcmp(value(last_action), 'init') || strcmp(value(last_action), 'validate')
            last_action.value = 'prepare_next_trial';
            set(value(myfig), 'Visible', 'on');
            waitfor(get_ghandle(START), 'Enable', 'off');
            feval(mfilename, obj, 'RunSMA');
        elseif strcmp(value(last_action), 'RunSMA')
            last_action.value = 'prepare_next_trial';
            feval(mfilename, obj, 'validate');
        end
        
        
    case 'validate'
        left1water = bSettings('get', 'DIOLINES', 'left1water');
        center1water = bSettings('get', 'DIOLINES', 'center1water');
        right1water = bSettings('get', 'DIOLINES', 'right1water');
        %Enter weights obtained:
        prompt = cell(3,1);
        prompt{1} = 'Enter the weight obtained from the left cup (grams):';
        prompt{2} = 'Enter the weight obtained from the center cup (grams):';
        prompt{3} = 'Enter the weight obtained from the right cup (grams):';
        dlg_title = 'Enter Weights';
        numlines = 1;
        defAns = {'0.0', '0.0', '0.0'};
        options.WindowStyle = 'modal';
        weight_of_cup = 0;
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
                    catch %#ok<CTCH>
                        keyboard;
                        errflag = true;
                        waitfor(errordlg('ERROR: Invalid input.', 'ERROR', 'modal'));
                        break;
                    end
                end
            end
        end
        
        
        left_weight = answer{1}; left_dispense = eval(left_weight)*1000/value(number_of_pulses);
        center_weight = answer{2}; center_dispense = eval(center_weight)*1000/value(number_of_pulses);
        right_weight = answer{3}; right_dispense = eval(right_weight)*1000/value(number_of_pulses);
        
        msgbox(['RESULT: left_dispense = ' num2str(left_dispense) '; center_dispense = ' num2str(center_dispense) '; right_dispense = ' num2str(right_dispense)]);
        
        if exist('SAVED_CALIBRATIONTESTER_RESULT.mat', 'file')
            load('SAVED_CALIBRATIONTESTER_RESULT.mat');
            left_dispense_saved = [left_dispense_saved; left_dispense];
            center_dispense_saved = [center_dispense_saved; center_dispense];
            right_dispense_saved = [right_dispense_saved; right_dispense];
            num_pulses_saved = [num_pulses_saved; value(number_of_pulses)];
            desired_volume_saved = [desired_volume_saved; value(desired_volume_per_dispense)];
        else
            left_dispense_saved = left_dispense;
            center_dispense_saved = center_dispense;
            right_dispense_saved = right_dispense;
            num_pulses_saved = value(number_of_pulses);
            desired_volume_saved = value(desired_volume_per_dispense);
        end
        save('SAVED_CALIBRATIONTESTER_RESULT.mat', 'left_dispense_saved', 'center_dispense_saved', 'right_dispense_saved', 'num_pulses_saved', 'desired_volume_saved');
        
        enable(number_of_pulses);
        enable(desired_volume_per_dispense);
        enable(START);
        
        last_action.value = 'validate';
        
        feval(mfilename, obj, 'prepare_next_trial');
        
        
    case 'close'
        if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), %#ok<NODEF>
            delete(value(myfig));
        end;
        delete_sphandle('owner', ['^@' class(obj) '$']);
        
    case 'trial_completed'
        
    otherwise,
        warning('Unknown action! "%s"\n', action); %#ok<WNTAG>
end;

return;


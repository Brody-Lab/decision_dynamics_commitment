%
%     Protocols/@Calibration_WaterDelivery/Calibration_WaterDelivery.m
%     Constructor&Interface, water calibration protocol; BControl system
%
%     All protocols follow a general interface. See for example
%     Protocols/@Classical/Classical.m
%
%     Sebastien Awwad, 2007
%     originally modified from Solo_WaterValve2 protocol for RPBox
%
%
function [obj] = Calibration_WaterDelivery(varargin)

GetSoloFunctionArgs;

%---------------------------------------------------------------
%    Basic object creation, including MATLAB-requiredbehavior.
%---------------------------------------------------------------

% If creating an empty object, return without further ado:
if nargin==0 || (nargin==1 && ischar(varargin{1}) && strcmp(varargin{1}, 'empty')),
    obj = struct;
    obj = class(obj, mfilename);
    return;
elseif isa(varargin{1},mfilename),

    %    If the first argument is a calibration protocol object, then we
    %      use (a copy of) that object instead of creating our own.
    obj = varargin{1};

    if nargin < 2,
        %     If *all* we got was an object, we just return the copy we're
        %       required by MATLAB to return.
        return;

    else
        %     If we have more args, take the next one as the action to
        %       perform and continue.
        action = varargin{2};
    end;

else
    %     If we have some other argument set, it had better start with a
    %       string describing the action to take.
    action = varargin{1};
    if ~ischar(action), error('When provided, the first argument must be either: a string describing the action to perform, a Calibration_WaterDelivery object, or the string ''empty''.'); end;

    %     Create the object that this "constructor" is meant to create.
    %     For the time being, instantiations of each protocol object class
    %       lack identity or internal data - which is why it's technically
    %       OK that this "constructor" which is really the interface to a
    %       protocol is creating meaningless objects when called. Messy.
    obj = struct;
    obj = class(obj, mfilename);

end;

%     Should we delete all variables previously registered to an object of
%       this class?
% delete_sphandle('owner', mfilename); % Delete previous vars owned by this object


if ~exist('action','var'),
    error('Programming error - code has been changed and broken. Variable "action" DNE.');
end;


switch action,

    case 'empty'
        return;

    case 'init'
        %---------------------------------------------------------------
        %          CASE INIT
        %---------------------------------------------------------------

        % Make default figure. Remember to make it non-saveable; on next run
        % the handle to this figure might be different, and we don't want to
        % overwrite it when someone does load_data and some old value of the
        % fig handle was stored there...
        SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = figure;


        %     Name the protocol after this file.
        SoloParamHandle(obj, 'protocol_name', 'value', mfilename);

        %     Automatically pass the value of the myfig *handle* to the close method.
        SoloFunctionAddVars('close', 'ro_args', 'myfig');

        %     Set some simple gui parameters for the protocol window figure.
        set(value(myfig), ...
            'Name',             value(protocol_name), ...
            'Tag',              value(protocol_name), ...
            'closerequestfcn',  [value(protocol_name) '(''close'')'], ...
            'NumberTitle',      'off', ...
            'MenuBar', 'none');


        %     *
        fig_position = [485   244   500   360];
        set(value(myfig), 'Position', fig_position);

        %     These variables will be used to track the position of new
        %       elements being added to the protocol window. We start them
        %       at 1,1 - the bottom left corner of the protocol window.
        x = 1; y = 1;                     % Position on GUI

        %     This actually increases the value of y here (by a MATLAB hack
        %       called assignin which lets a function assign variables in
        %       its calling function's domain - a workaround for the lack
        %       of pass-by-reference).
        next_row(y);


        %     Here we create the gui elements for this simple protocol.
        %     These are Solo parameters.


        %     The water valves open in brief pulses. This parameter controls
        %       how many pulses to open the water valves for per calibration
        %       test.
        % <~> Changed default from 250 to 150 on 2008.11.20. There
        %       were some subtle problems with 250 pulses.
        NumeditParam(obj, 'num_pulses', 150, x, y, 'label', '# pulses'); next_row(y);

        %     And this parameter controls the time between pulses. It must be a
        %       certain length to avoid damage to the pumps (or so I hear);
        %       however, this length is, I think, much larger than that
        %       minimum.
        NumeditParam(obj, 'ipi', 1, x, y, 'label', 'Inter-pulse interval');

        next_row(y, 2);

        %     The time parameters control the length of the water delivery
        %      pulses. The calibrator fiddles with them until 100 pulses
        %      delivers a specified amount of water - for us, usually 2.4g.
        NumeditParam(obj, 'right_time', 0.15, x, y, 'label', 'Right Time', ...
            'position', [x, y, 100, 20], 'labelfraction', 0.55);

        %     After delivery, the water delivered is weighed and the weight
        %       entered here by the calibrator, and automatically compared to
        %       the expected/desired result.
        NumeditParam(obj, 'right_weight', 0, x, y, 'label', 'grams', ...
            'position', [x+110 y 80 20], 'labelfraction', 0.55);

        %     This value is calculated automatically from the weight entered by
        %       the calibrator to be the volume of water (in microliters)
        %       dispensed per pulse (simple division).
        DispParam(obj, 'right_dispense', 0, x, y, 'label', 'ul/dispense', ...
            'position', [x+200 y 90 20], 'labelfraction', 0.65);

        %     This is the value that we would like to be dispensed per pulse in
        %       microliters (for us, usually 24ul). It is compared to the value
        %       just above.
        NumeditParam(obj, 'right_target', 24, x, y, 'label', 'Rt target', ...
            'position', [x+300 y 95 20], 'labelfraction', 0.65);

        %     After the dispensed value is compared to the value we wanted to
        %       be dispensed, a suggestion for the appropriate pulse length to
        %       use to actually get the value we desire is produced. :P
        NumeditParam(obj, 'right_suggest', 0, x, y, 'label', 'suggestion', ...
            'position', [x+400 y 95 20], 'labelfraction', 0.6);

        %     See tooltip string.
        PushbuttonParam(obj, 'generate', x, y, 'position', [x+380 y-21 115 20], ...
            'TooltipString', sprintf(['Given the targets, generate ' ...
            'suggestions for\n ' ...
            'both left1water and right1water from the existing\n' ...
            'table entries (without any unentered current\n' ...
            'measurements) Press this button at the beginning of recalibration\n' ...
            ' to get a good first estimate and save some time.']), ...
            'FontWeight', 'normal', 'label', 'Generate Suggestions');


        next_row(y);

        %      And now the same set for the center poke.
        NumeditParam(obj, 'center_time', 0.15, x, y, 'label', 'Center Time', ...
            'position', [x, y, 100, 20], 'labelfraction', 0.55);
        NumeditParam(obj, 'center_weight', 0, x, y, 'label', 'grams', ...
            'position', [x+110 y 80 20], 'labelfraction', 0.55);
        DispParam(obj, 'center_dispense', 0, x, y, 'label', 'ul/dispense', ...
            'position', [x+200 y 90 20], 'labelfraction', 0.65);
        NumeditParam(obj, 'center_target', 24, x, y, 'label', 'Lt target', ...
            'position', [x+300 y 90 20], 'labelfraction', 0.65);
        NumeditParam(obj, 'center_suggest', 0, x, y, 'label', 'suggestion', ...
            'position', [x+400 y 95 20], 'labelfraction', 0.6);

        
        
        next_row(y);

        %      And now the same set for the left poke.
        NumeditParam(obj, 'left_time', 0.15, x, y, 'label', 'Left Time', ...
            'position', [x, y, 100, 20], 'labelfraction', 0.55);
        NumeditParam(obj, 'left_weight', 0, x, y, 'label', 'grams', ...
            'position', [x+110 y 80 20], 'labelfraction', 0.55);
        DispParam(obj, 'left_dispense', 0, x, y, 'label', 'ul/dispense', ...
            'position', [x+200 y 90 20], 'labelfraction', 0.65);
        NumeditParam(obj, 'left_target', 24, x, y, 'label', 'Lt target', ...
            'position', [x+300 y 90 20], 'labelfraction', 0.65);
        NumeditParam(obj, 'left_suggest', 0, x, y, 'label', 'suggestion', ...
            'position', [x+400 y 95 20], 'labelfraction', 0.6);
        next_row(y, 1.5);


        %     (not a gui element - references the tables)
        SoloParamHandle(obj, 'table', 'value', WaterCalibrationTable);


        % <~>TODO: Change check and font sizes to match settings.
        if ispc, fontsize = 8; else fontsize = 12; end;
        ListboxParam(obj, 'list_table', cellstr(value(table)), ...
            length(cellstr(value(table))), ...
            x, y, 'position', [x y 400 100], ...
            'FontName', 'Courier', 'FontSize', fontsize);


        next_column(x); y=1; next_row(y, 2); x = x+10;

        %     We musn't assume that a calibration measurement at any distance
        %       from the target dispense volume will allow us to reliably
        %       estimate the appropriate pulse time for the desired dispense
        %       volume. We need estimates that are near the target. This
        %       parameter controls the permitted distance of a measurement
        %       before calling it 'OK' (and turning the weight fields green).
        NumeditParam(obj, 'error_tol', 5, x, y, 'label', '% Error tolerance', ...
            'position', [x y 130 20], 'labelfraction', 0.7);
        EditParam(obj, 'initials', '', x, y, 'position', [x+150, y, 100, 20]);


        PushbuttonParam(obj, 'delete_entry', 420, 180, 'label', 'DELETE entry', ...
            'position', [410, 170 80, 30]);
        PushbuttonParam(obj, 'add_entry', 420, 180, 'label', 'ADD entry', ...
            'position', [410, 215 80, 30]);

        
        
        %     Start (continue) and Stop buttons.
        ToggleParam(obj, ...
            'flagStopping', ...
            false, ...
            x, y, ...
            'position', [225 270 200 50], ...
            'OffString', 'END calibration', ...
            'OnString', 'STOPPING CALIBRATION PROGRAM', ...
            'TooltipString', 'Press to indicate that calibration has been completed.', ...
            'BackgroundColor', [1 0 0], ...
            'ForegroundColor', [0 0 0]); %     Background and foreground colors are for the off position, and reverse for the on position.


        ToggleParam(obj, ...          	%the owner, this protocol object
            'flagCalibrating', ...			%the name of the variable/button
            false, ...                  %default value (off)
            x, y, ...                  	%positions in this figure of the button
            'position',[15 270 200 50],...	%positions and size (x pos, y pos, width, height)
            'OffString','CONTINUE calibration', ...
            'OnString', 'NOW CALIBRATING', ...
            'BackgroundColor', [0 1 0], ...
            'ForegroundColor', [0 0 0]); %     Background and foreground colors are for the off position, and reverse for the on position.

        set(get_ghandle(flagCalibrating),'Enable', 'off');
        set(get_ghandle(flagStopping),'Enable', 'off');

        PushbuttonParam(obj, ...
            'instructions', ...
            x, y, ...
            'position',[440 270 50 50], ...
            'label', 'HELP', ...
            'TooltipString', 'Press for instructions', ...
            'BackgroundColor', [0.2 0.5 0.2]);
        set_callback(instructions,{mfilename,'instructions'});
        
        next_row(y, 1.5);     %     (Move up 1.5 "rows")
        
        
        %     Protocol title banner
        HeaderParam(obj, 'prot_title', 'Calibration Protocol: Water Delivery', ...
            x, y, 'position', [4 fig_position(4)-30 fig_position(3) 20], ...
            'width', fig_position(3));

        
        
        %     Assignment of callbacks for GUI elements.
        set_callback({right_weight;right_target}, {'calculate', 'right'}); %#ok<NODEF>
        set_callback({center_weight;center_target}, {'calculate', 'center'}); %#ok<NODEF>
        set_callback({left_weight;left_target}, {'calculate', 'left'}); %#ok<NODEF>
        set_callback(error_tol, {'calculate', 'both'});
        set_callback(generate, {'calculate', 'generate'});

        
        %     Granting access to the Solo variables we've created to other
        %       functions (delete_entry, add_entry, calculate).
        SoloFunctionAddVars('delete_entry', 'rw_args', {'table', 'list_table'});
        SoloFunctionAddVars('add_entry', 'ro_args', {'right_time', 'center_time', 'left_time', ...
            'right_dispense', 'center_dispense', 'left_dispense', 'initials'}, ...
            'rw_args', {'table', 'list_table'});
        SoloFunctionAddVars('calculate', 'ro_args', {'num_pulses', 'right_time', ...
            'center_time', 'left_time', 'right_weight', 'center_weight', 'left_weight', ...
            'error_tol', 'table'}, ...
            'rw_args', {'right_dispense', 'center_dispense', 'left_dispense', ...
            'right_suggest', 'center_suggest', 'left_suggest', 'right_target', ...
            'center_target', 'left_target'});
        
        % ------------------------------------------------------------------
        % List of functions to call, in sequence, when a trial is finished:
        % If adding a function to this list,
        %    (a) Grant it access to the variables it needs using
        %          a SoloFunctionAddVars() call.
        %    (b) Add your function as a method of the current object.
        %    (c) As the first action of your method, call GetSoloFunctionArgs,
        %          which auto-loads the solo variables the function has been
        %          given access to.
        SoloParamHandle(obj, 'trial_finished_actions', 'value', { ...
            ... %     Removed.     [mfilename '(obj, ''stop_matrix'');']  ; ... %     load in the stop matrix
            'push_history(class(obj));'                            ; ... % no args
            });
        
        %     Load a matrix that contains nothing but a jump to
        %       check_next_trial_ready. This is ridiculous but necessary: I
        %       need a prepare_next_trial call to occur when the Run button
        %       is pressed in Dispatcher. I can't possibly know what matrix
        %       to load at this point....
        sma = StateMachineAssembler('full_trial_structure');
        sma = add_state(sma, ...
            'name', 'looping_stop_state', ...
            'self_timer', 0.1, ...
            'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        dispatcher('send_assembler', sma, 'check_next_trial_ready');

        %     end of case init


    case 'stop_matrix',
        %     This call might not be used.
        %     The purpose is to stop water delivery and cancel calibration.


        %     State Matrix specification (via state machine assembler)

        %     Dispatcher requires a certain kind of state machine assembler
        %       configuration. Full trial structure will allow for
        %       prepare_next_trial states and a check_next_trial_ready
        %       state. See below.
        sma = StateMachineAssembler('full_trial_structure');

        %     We have a meaningless first state that jumps to a special
        %       state called check_next_trial_ready, defined by dispatcher
        %       for us. It will loop until the next state matrix is sent
        %       in.
        sma = add_state(sma, ...
            'name', 'looping_stop_state', ...
            'self_timer', 0.01, ...
            'input_to_statechange', {'Tup', 'looping_stop_state'});

        %     Submit the completed state machine assembler, noting
        %       that when 'check_next_trial_ready' is entered, dispatcher
        %       should request that the state matrix for the next
        %       calibration round be sent in by calling prepare_next_trial
        %       for this protocol.
        dispatcher('send_assembler', sma, 'check_next_trial_ready');

        return;



    case 'start_matrix'
        %     The state matrix we assemble here has the simple behavior
        %       that it opens the water valves at the same time, leaving
        %       each open for the amount of time specified in left_time and
        %       right_time, then closes them, waits briefly to prevent
        %       damage to the pumps, opens them again, and so on.

        %     Left and right times specify the amount of time to keep the
        %       valve open on each pulse of water delivery.
        %     We find out which is the shorter and longer, along with the
        %       difference between them so that we can arrange states thus:
        %
        %            - both open state
        %            - only longer one still open state
        %            - inter-pulse pause
        %
        %            - both open state
        %            - only longer one still open state
        %            - inter-pulse pause
        %
        %            - ... etc.

        %     Here we'll use many temp variables for (I hope) clarity.
        %     Left valve identifies both left1water and left1led channels.
        %     When we turn on "left_valve", we'll be turning on both.
        %     ' similarly for the right.

%         %     Fetch the names and channel numbers for all digital outputs.
%         [all_outputs e m]            	= bSettings('get','DIOLINES','all');
%         if e, error(m); end; %    should be made friendlier
%         
%         %     Select out the outputs with names including 'water' (e.g.
%         %       'left1water').
%         %     The following line searches through the names (col 1) of the
%         %       outputs cell array, then returns the indices of non-empty
%         %       cells (i.e. row numbers in all_outputs corresponding to
%         %       channels including 'water' in their names). temp var.
%         water_channel_indices = ~cellfun('isempty', strfind(all_outputs(:,1),'water'));
%         
%         %     Now retrieve those rows.
%         %       (Col 1: ch.name, Col 2: ch.num. Col 3: setting group name 'DIOLINES') 
%         %     We only care about the channel numbers in this protocol, so
%         %       toss the rest!
%         water_channels = all_outputs(water_channel_indices,2);
%         
%         %     Remove those channels with channel number NaN (unspecified).
%         for i=1:rows(water_channels),
%             if ~isnumeric(water_channels{i}) || isnan(water_channels{i}),
%                 water_channels(i) = [];  %     Cut that row (1 cell now) out of the cell array.
%             end;
%         end;
%         
%         
%         %     Now we create the state matrix.
%         %     The state sequence:
%         %
%         %       %<~>TODO: add doc
%         %
%         
%         
        
        %     Output lines add (They're channels in a bitfield.).
        [left_valve   errL ]  = bSettings('get','DIOLINES','left1water');
        [left_led     errL2]  = bSettings('get','DIOLINES','left1led');
        [center_valve errC]   = bSettings('get','DIOLINES','center1water');
        [center_led   errC2]  = bSettings('get','DIOLINES','center1led');
        [right_valve  errR]   = bSettings('get','DIOLINES','right1water');
        [right_led    errR2]  = bSettings('get','DIOLINES','right1led');

        errL  = errL || isnan(left_valve);
        errC  = errC || isnan(center_valve);
        errR  = errR || isnan(right_valve);
        errL2 = errL2 || isnan(left_led);
        errC2 = errC2 || isnan(center_led);
        errR2 = errR2 || isnan(right_led);
        
        if ~errL2, left_valve   = left_valve   + left_led;   end;
        if ~errC2, center_valve = center_valve + center_led; end;
        if ~errR2, right_valve  = right_valve  + right_led;  end;

        
        %    Some values drawn from (Solo) gui elements.
        number_of_pulses                = value(num_pulses);

        left_valve_open_time            = value(left_time);
        center_valve_open_time          = value(center_time);
        right_valve_open_time           = value(right_time);

        valve_rest_period_length        = value(ipi);
        inter_valve_pause               = max(0.2, ...
            (valve_rest_period_length ...
            - (1-errL) * left_time ...
            - (1-errC) * center_time ...
            - (1-errR) * right_time ...
            ) / max(1, (3 - errL - errC - errR)) );
        





        %     State Matrix specification (via state machine assembler)

        %     Dispatcher requires a certain kind of state machine assembler
        %       configuration. Full trial structure will allow for
        %       prepare_next_trial states and a check_next_trial_ready
        %       state. See below.
        sma = StateMachineAssembler('full_trial_structure');

        %     Meaningless state that starts each "trial" / calibration run.
        sma = add_state(sma, 'name', 'null_state', ...
            'self_timer', 0.01, ...
            'input_to_statechange', {'Tup', 'current_state+1'});

        %     This state exists only to give the same name to all the
        %      following states in the loop, which cannot explicitly select
        %      a name already used because the State Machine Assembler will
        %      complain; however, if they do not specify a name, they all
        %      fall under the name of the previous state - this one.
        sma = add_state(sma, 'name', 'pulsing', ...
            'self_timer', 0.01, ...
            'input_to_statechange', {'Tup', 'current_state+1'});



        %     Iterate over pulses, creating 6 states per pulse cycle, as
        %       explained above.
        for i = 1:number_of_pulses,
            if ~errL,
                sma = add_state(sma, ...
                    'self_timer', left_valve_open_time, ...
                    'output_actions', {'DOut', left_valve}, ...
                    'input_to_statechange', {'Tup', 'current_state+1'});

                sma = add_state(sma, ...
                    'self_timer', inter_valve_pause, ...
                    'input_to_statechange', {'Tup', 'current_state+1'});
            end;
            if ~errC,
                sma = add_state(sma, ...
                    'self_timer', center_valve_open_time, ...
                    'output_actions', {'DOut', center_valve}, ...
                    'input_to_statechange', {'Tup', 'current_state+1'});

                sma = add_state(sma, ...
                    'self_timer', inter_valve_pause, ...
                    'input_to_statechange', {'Tup', 'current_state+1'});
            end;
            if ~errR,
                sma = add_state(sma, ...
                    'self_timer', right_valve_open_time, ...
                    'output_actions', {'DOut', right_valve}, ...
                    'input_to_statechange', {'Tup', 'current_state+1'});

                sma = add_state(sma, ...
                    'self_timer', inter_valve_pause, ...
                    'input_to_statechange', {'Tup', 'current_state+1'});
            end;
        end;  %end for num_pulses


        %     At the end, jump to the state check_next_trial_ready,
        %       which dispatcher creates and handles for us. That state
        %       should loop until a new state matrix is sent. When the
        %       state is first entered, dispatcher will also call
        %       prepare_next_trial on this protocol, which will eventually
        %       send a new state matrix. Then, the next calibration round
        %       will begin.
        sma = add_state(sma, 'name', 'CalibrationComplete', ...
            'self_timer', 0.5, ...
            'input_to_statechange', {'Tup', 'check_next_trial_ready'});


        %     Submit the completed state machine assembler, noting
        %       check_next_trial_ready as a "prepare_next_trial" state,
        %       which means that only when check_next_trial_ready is
        %       entered will prepare_next_trial be called in this protocol.
        dispatcher('send_assembler', sma, 'check_next_trial_ready');

        return;



    case 'prepare_next_trial'
        %---------------------------------------------------------------
        %          CASE PREPARE_NEXT_TRIAL
        %---------------------------------------------------------------
        %     When one round of pulsing is complete:
        %       - The flagCalibrating toggle is turned off.
        %       - A window pops up with instructions.
        %       - A loop (timer later) cycles, waiting for technician to:
        %         - retrieve and weigh dispensed water, and
        %         - enter weights into the weight GUI elements and HIT
        %             ENTER FOR EACH, which sets the flags for left and
        %             right weights to indicate that they have been entered
        %             for this round.
        %       - Loop sees flags and completes, then window pops up
        %           with NEXT
        %

        display([mfilename '-- PREPARE_NEXT_TRIAL called.']);
        linebreak = sprintf('\n');

        %     Set CALIBRATING toggle to off.
        flagCalibrating.value = false;

        if n_done_trials == 1,
            %     First round of pulses coming up. Try loading guess based
            %       on old values.
            %     We use a try/catch because an error would be generated if
            %       this is our first time calibrating or we're calibrating
            %       on an old or empty water calibration table.
            try
                calculate(obj,'generate');
                left_time.value = value(left_suggest);
                center_time.value = value(center_suggest);
                right_time.value = value(right_suggest);
            catch
                left_time.value = 0.15;
                center_time.value = 0;
                right_time.value = 0.15;
            end;
            
        else
            %     A round of pulses has just finished.

            weights = inputdlg({ ...
                ['Water delivery complete.' linebreak ...
                'Please weigh the water delivered and enter weights here (' linebreak ...
                '   IN GRAMS. (Subtract the weight of the container.)  ' linebreak linebreak ...
                'If one of the valves is not being used, or if there was a problem' linebreak ...
                '  this round with water delivery on that valve, leave the value' linebreak ...
                '  as 0.' linebreak linebreak ...
                'Left water weight (grams):'], ...  % prompt 1 (end of)
                'Center water weight (grams):', ... % prompt 2
                'Right water weight (grams):'}, ... % prompt 3
                'Weigh Water', ...  % window title
                1, ...              % number of lines for each entry field
                {'0.00', '0.00', '0.00'});      % default values

            %     Set the values of the Solo GUI elements left_weight and
            %       right_weight, and automatically call the callback for each.
            left_weight.value_callback	= str2double(weights{1});
            center_weight.value_callback = str2double(weights{2});
            right_weight.value_callback	= str2double(weights{3});

            %<~>TODO: more instructions here
            %                ' START CALIBRATION to begin the next
            %                round.']);

            while isempty(value(initials)),
                temp = inputdlg('Please enter your initials.', ...
                    'Enter Calibrator Initials', 1, {''});
                initials.value = temp{1};
            end;
            feval('add_entry',obj,'calibrating',1); %     add entries to table
            feval('calculate',obj,'generate'); %     After add_entry completes, generate new suggestions since it may have deleted old offsides entries.
            if left_suggest  >0, left_time.value   = value(left_suggest);   end; %     copy suggested
            if center_suggest>0, center_time.value = value(center_suggest); end; %     vals over to t
            if right_suggest >0, right_time.value  = value(right_suggest);  end; %     for next round

            %<~>TODO:
            %     Determine whether or not calibration has been
            %       satisfactorily completed and deliver an informative
            %       message and question dialog: click YES to end this
            %       program and NO to continue calibration. 
            

            % <~> Code below added to repository on 2009.January.29
            %     For the Brody lab only, check to see if the pulse
            %       times are very long. Pulse times longer than
            %       400ms probably indicate dirty valves or tubes,
            %       or a dirty syringe.
            if bSettings('compare','GENERAL','Lab','Brody'),
                if left_suggest > 0.4 || center_suggest > 0.4 || ...
                        right_suggest > 0.4,
                    msgbox(['One or more of the valve pulse times ' ...
                        'is longer than 0.4 seconds. This ' ...
                        'probably means that the tubes, syringe, ' ...
                        'or valve should be cleaned. Please ' ...
                        'clean the valve and replace the tubing ' ...
                        'and syringe. Then, start the calibration ' ...
                        'process again.']);
                end; %     end if suggested pulse times are > 0.4s
            end; %     end if in Brody lab
            
        end; %     end if-not-first-calibration-round

        
        %     Turn the continue and stop buttons on.
        set(get_ghandle(flagCalibrating),'Enable', 'on');
        set(get_ghandle(flagStopping),'Enable', 'on');

        %     Wait for input (continue or stop buttonpress).
        while ~value(flagCalibrating) && ~value(flagStopping), % while button is not down, wait
            pause(0.5);
        end;

        %     Turn the continue and stop buttons off.
        set(get_ghandle(flagCalibrating),'Enable', 'off');
        set(get_ghandle(flagStopping),'Enable', 'off');
        
        
        if value(flagCalibrating),
            %     And now we prepare and load the state matrix for the next
            %       calibration round.
            feval(mfilename, 'start_matrix');
            %     Assure that the toggles are in the correct position
            %       (since mltiple presses are possible).
            flagCalibrating.value = true; flagStopping.value = false;
        else
            %     If it was indicated instead that we're done calibrating,
            %       we load a stop matrix and stop execution.
            %     The reason we load a stop matrix first is to prevent the
            %       leaking of water if the state machine is resumed at
            %       another point in time before a new state matrix is
            %       loaded (happens; during initialization of system?).
            feval(mfilename, 'stop_matrix');
            Dispatcher('Stop');
            %     Assure that the toggles are in the correct position
            %       (since mltiple presses are possible).
            flagCalibrating.value = false; flagStopping.value = false;
        end;
        
        return;



    case 'trial_completed'
        %---------------------------------------------------------------
        %          CASE TRIAL_COMPLETED
        %---------------------------------------------------------------
        %     This list of actions to complete when the trial has ended is
        %       created in the initialization for this protocol (action
        %       'init').
        for i=1:length(trial_finished_actions), %#ok<USENS>
            eval(trial_finished_actions{i});
        end;


    case 'update'
        %---------------------------------------------------------------
        %          CASE UPDATE
        %---------------------------------------------------------------


    case 'close'
        %---------------------------------------------------------------
        %          CASE CLOSE
        %---------------------------------------------------------------

        % Delete everything owned by this object from the AutoSet register:
        RegisterAutoSetParam(['@' class(obj)]);

        % Delete everything owned by this object from the SoloFunction register:
        SoloFunction(['@' class(obj)]);

        %     Delete all of our solo variables.
        delete_sphandle('owner', ['^@' class(obj) '$']);

        %     If myfig is indeed a handle to the protocol window, kill it.
        if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), %#ok<NODEF>
            delete(value(myfig));
        end;


    case 'instructions'
        %     Deliver instructions.
        helpdlg([ ...
            '1:  Load dry, pre-weighed-and-marked water containers' 10 ...
            '      under each poke that dispenses water.' 10 ...
            '2:  IF THIS RIG HAS BEEN CALIBRATED IN THE PAST 30 DAYS,' 10 ...
            '      press  to get a good guess for the valve' 10 ...
            '      open time and copy that to the time fields on the left.' 10 ...
            '3:  Press START CALIBRATION and await further instruction.' 10 ...
            10 ' This is calibration round ' int2str(n_done_trials) '.' 10 ...
            10 ' When you have obtained good estimates for each valve ' 10 ...
            '   (i.e. when the target fields have been green for every' 10 ...
            '    valve and the values have been added to the table),' 10 ...
            '   you can quit this protocol.']);
        
    otherwise,
        %---------------------------------------------------------------
        %          UNKNOWN ACTION NAME
        %---------------------------------------------------------------
        error('Unknown action used in call to %s! Action: "%s"\n', mfilename, action);

end; %     end switch action

return;

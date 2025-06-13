%CalibrationMeister: Calibration Meister Protocol addressing a bunch of 
%issues with an earlier protocol named 'WaterCalibrationSST'. This is a
%SoloParamHandle version of the protocol.
% Copyright Praveen | Software Programmer | HHMI | Sept. 2011

function [obj] = CalibrationMeister(varargin)

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

switch action
    %% init
    case 'init'
        %If older than R2008b, don't run
        if verLessThan('matlab', '7.7')
            waitfor(errordlg('Error: This version of MATLAB is too old. Please use R2008b or later.', 'Error', 'modal'));
            dispatcher('close');
        end
        
        % Get the user initials: Start
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
            userinitials = regexprep(userinitials,{'[0-9]';'\s';'\W'},'');
            if isempty(userinitials) || length(userinitials)~=2 || ~isnan(str2double(userinitials))
                errflag = true;
                waitfor(errordlg('ERROR: You must enter your two-letter initials.', 'ERROR', 'modal'));
                continue;
            end
        end
        % Get the user initials: Stop
        
        if cancel_pressed
            dispatcher('set_protocol', '');
        else
            % Set non-GUI global SoloParamHandle variables: Start
            SoloParamHandle(obj,'min_state_time','value',0.0001);
            SoloParamHandle(obj,'weights_lower_limit','value',0.4);
            SoloParamHandle(obj,'weights_upper_limit','value',9.0);
            SoloParamHandle(obj,'CALIBRATION_HIGH_OR_LOW_CONST','value','LOW');
            SoloParamHandle(obj,'pulse_time_lower_threshold','value',0.001);
            SoloParamHandle(obj,'pulse_time_upper_threshold','value',0.4);
            SoloParamHandle(obj,'pulse_time_default','value',0.15);
            SoloParamHandle(obj,'error_tolerance_default','value',2);
            SoloParamHandle(obj,'error_tolerance_lower_threshold','value',0.1);
            SoloParamHandle(obj,'error_tolerance_upper_threshold','value',3);
            SoloParamHandle(obj,'target_dispense_lower_threshold','value',10);
            SoloParamHandle(obj,'target_dispense_upper_threshold','value',30);
            SoloParamHandle(obj,'low_target_dispense_default','value',21);
            SoloParamHandle(obj,'high_target_dispense_default','value',27);
            SoloParamHandle(obj,'num_pulses_default','value',150);
            SoloParamHandle(obj,'num_pulses_upper_threshold','value',2000);
            SoloParamHandle(obj,'num_pulses_lower_threshold','value',5);
            SoloParamHandle(obj,'valves_dionames','value',{'left1water','center1water','right1water'});
            SoloParamHandle(obj,'valves_names','value',{'LEFT','CENTER','RIGHT'});
            SoloParamHandle(obj,'valves_used','value',[1,1,1]);
            SoloParamHandle(obj,'left1water', 'value', bSettings('get', 'DIOLINES', 'left1water'));
            SoloParamHandle(obj,'left1led', 'value', bSettings('get', 'DIOLINES', 'left1led'));
            SoloParamHandle(obj,'center1water', 'value', bSettings('get', 'DIOLINES', 'center1water'));
            SoloParamHandle(obj,'center1led', 'value', bSettings('get', 'DIOLINES', 'center1led'));
            SoloParamHandle(obj,'right1water', 'value', bSettings('get', 'DIOLINES', 'right1water'));
            SoloParamHandle(obj,'right1led', 'value', bSettings('get', 'DIOLINES', 'right1led'));
            SoloParamHandle(obj,'rig_id', 'value', bSettings('get', 'RIGS', 'Rig_ID'));
            SoloParamHandle(obj,'inter_valve_pause_default', 'value',0.01);
            SoloParamHandle(obj,'inter_valve_pause_upper_threshold', 'value',1);
            SoloParamHandle(obj,'inter_valve_pause_lower_threshold', 'value',0.001);
            SoloParamHandle(obj,'calib_data_history', 'value',10);
            % Set non-GUI global SoloParamHandle variables: Stop
            
            % Do some error checking before proceeding: Start
            if(any(isnan(value(left1water)))); valves_used(1)=0; end
            if(any(isnan(value(center1water)))); valves_used(2)=0; end
            if(any(isnan(value(right1water)))); valves_used(3)=0; end
            if sum(value(valves_used))==0 || isempty(isnan(value(rig_id))) || isempty(value(rig_id))
                waitfor(errordlg('No valves found or invalid/no rig id, so calibration is not possible. See you later!!!', 'ERROR', 'modal'));
                dispatcher('set_protocol', '');
                feval(mfilename,'close');
                return;
            else
                if isnumeric(value(rig_id)); rig_id.value=num2str(value(rig_id)); end
            end
            % Do some error checking before proceeding: Stop

            % Set some local variables useful for building the GUI: Start
            fig_pos=[10 400];
            fig_width_height=[510 400];
            fig_name='CALIBRATION MEISTER';
            fig_bgcolor=[51 155 106]/255;
            
            user_initials_font_size=10;
            user_initials_bgcolor=[108 185 74]/255;
%             user_initials_bgcolor=[1 1 1];
            user_initials_label_bg_color=[219 148 74]/255;
            
            btnCalibLowTarget_pos=[50 280];
            btnCalibLowTarget_size=[200 40];
            btnCalibLowTarget_font_size=15;
            btnCalibLowTarget_bgcolor=[146 180 73]/255;
            btnCalibLowTarget_fgcolor=[0 0 0];
            btnCalibLowTarget_string='Calibrate Low Target';
            
            btnCalibHighTarget_pos=[270 280];
            btnCalibHighTarget_size=[210 40];
            btnCalibHighTarget_font_size=15;
            btnCalibHighTarget_bgcolor=[146 180 73]/255;
            btnCalibHighTarget_fgcolor=[0 0 0];
            btnCalibHighTarget_string='Calibrate High Target';
            
            main_header_string='CALIBRATION MEISTER';
            main_header_pos=[120 355];
            main_header_size=[320 30];
            main_header_font_size=20;
            main_header_fgcolor=[0 0 0];
            main_header_bgcolor=[96 149 77]/255;
            
            sub_header_1_string='';
            sub_header_1_pos=[5 325];
            sub_header_1_size=[500 2];
            sub_header_1_font_size=5;
            sub_header_1_fgcolor=[0 0 0];
            sub_header_1_bgcolor=[0 0 0];
            
            sub_header_2_string='';
            sub_header_2_pos=[5 272];
            sub_header_2_size=[500 2];
            sub_header_2_font_size=5;
            sub_header_2_fgcolor=[0 0 0];
            sub_header_2_bgcolor=[0 0 0];
            
            sub_header_3_string='SETTINGS';
            sub_header_3_pos=[10 245];
            sub_header_3_size=[78 17];
            sub_header_3_font_size=12;
            sub_header_3_fgcolor=[60 230 29]/255;
            sub_header_3_bgcolor=[84 88 88]/255;
            
            sub_header_4_string='(Change them only if extremely necessary)';
            sub_header_4_pos=[10 230];
            sub_header_4_size=[250 15];
            sub_header_4_font_size=10;
            sub_header_4_fgcolor=[219 230 145]/255;
            sub_header_4_bgcolor=[84 88 88]/255;
            
            sub_header_5_string='ESTIMATED PULSE TIMES';
            sub_header_5_pos=[300 180];
            sub_header_5_size=[200 22];
            sub_header_5_font_size=12;
            sub_header_5_fgcolor=[0 0 0];
            sub_header_5_bgcolor=[48 184 215]/255;
            
            sub_header_6_string='';
            sub_header_6_pos=[300 217];
            sub_header_6_size=[200 45];
            sub_header_6_font_size=15;
            sub_header_6_font_wieght='bold';
            sub_header_6_fgcolor=[0 0 0];
            sub_header_6_bgcolor=[48 184 215]/255;

            universal_label_color=[141 127 255]/255;
            universal_label_font_size=10;
            universal_label_fraction=0.75;
            est_pulse_time_font_size=10;
            est_pulse_time_bgcolor=[188 202 37]/255;
            
            rig_id_label_pos=[10 360];
            rig_id_label_size=[50 20];

            ERROR_TOLERANCE_LABEL=['ERROR TOLERANCE (',char(hex2dec('B5')), 'L/dispense)'];
            HIGH_TARGET_LABEL=['HIGH TARGET (',char(hex2dec('B5')), 'L/dispense)'];
            LOW_TARGET_LABEL=['LOW TARGET (',char(hex2dec('B5')), 'L/dispense)'];
            RIGHT_PULSE_TIME_LABEL='RIGHT PULSE TIME (seconds)';
            LEFT_PULSE_TIME_LABEL='LEFT PULSE TIME (seconds)';
            CENTER_PULSE_TIME_LABEL='CENTER PULSE TIME (seconds)';
            NUM_PULSES_LABEL='NUMBER OF PULSES';
            INTER_VALVE_PAUSE_LABEL='INTER VALVE PAUSE (seconds)';
            % Set some local variables useful for building the GUI: Start
            
            % Delete any old figure if it exists: Start
            if exist('myfig', 'var'),
                if isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), delete(value(myfig)); end;
            end;
            % Delete any old figure if it exists: Stop
            
            % Create a new figure: Start
            SoloParamHandle(obj, 'myfig', 'saveable', 0, 'value', figure('Position',[fig_pos fig_width_height],'MenuBar','none','Name',fig_name,'Resize','off', ...
                'Color', fig_bgcolor, 'closerequestfcn', 'dispatcher(''close_protocol'')'));
            % Create a new figure: Stop
            
            % Headers/Subheaders/Footers: Start
            HeaderParam(obj, 'main_header',main_header_string,20,20);
            mh=get_ghandle(main_header);
            set(mh,'Position', [main_header_pos main_header_size],'FontSize', main_header_font_size,...
                'BackgroundColor', main_header_bgcolor,'ForegroundColor',main_header_fgcolor);
            
            SubHeaderParam(obj, 'sub_header_3',sub_header_3_string,20,20,'TooltipString','Change them at your own risk!!!');
            mh=get_ghandle(sub_header_3);
            set(mh,'Position', [sub_header_3_pos sub_header_3_size],'FontSize', sub_header_3_font_size,...
                'BackgroundColor', sub_header_3_bgcolor,'ForegroundColor',sub_header_3_fgcolor);
            
            SubHeaderParam(obj, 'sub_header_2',sub_header_2_string,20,20);
            mh=get_ghandle(sub_header_2);
            set(mh,'Position', [sub_header_2_pos sub_header_2_size],'FontSize', sub_header_2_font_size,...
                'BackgroundColor', sub_header_2_bgcolor,'ForegroundColor',sub_header_2_fgcolor);
            
            SubHeaderParam(obj, 'sub_header_1',sub_header_1_string,20,20);
            mh=get_ghandle(sub_header_1);
            set(mh,'Position', [sub_header_1_pos sub_header_1_size],'FontSize', sub_header_1_font_size,...
                'BackgroundColor', sub_header_1_bgcolor,'ForegroundColor',sub_header_1_fgcolor);
            
            SubHeaderParam(obj, 'sub_header_4',sub_header_4_string,20,20);
            mh=get_ghandle(sub_header_4);
            set(mh,'Position', [sub_header_4_pos sub_header_4_size],'FontSize', sub_header_4_font_size,...
                'BackgroundColor', sub_header_4_bgcolor,'ForegroundColor',sub_header_4_fgcolor);
            
            SubHeaderParam(obj, 'sub_header_5',sub_header_5_string,20,20,'TooltipString','These are the estimates of pulse times which will be used to achieve the next target under consideration');
            mh=get_ghandle(sub_header_5);
            set(mh,'Position', [sub_header_5_pos sub_header_5_size],'FontSize', sub_header_5_font_size,...
                'BackgroundColor', sub_header_5_bgcolor,'ForegroundColor',sub_header_5_fgcolor);
            
            SubHeaderParam(obj, 'sub_header_6',sub_header_6_string,20,20,'TooltipString','Tells the current status of calibration for this rig');
            mh=get_ghandle(sub_header_6);
            set(mh,'Position', [sub_header_6_pos sub_header_6_size],'FontSize', sub_header_6_font_size,'FontWeight',sub_header_6_font_wieght,...
                'BackgroundColor', sub_header_6_bgcolor,'ForegroundColor',sub_header_6_fgcolor);
            
            DispParam(obj, 'rig_id_disp', value(rig_id), 10,360, 'label','RIG ID','labelfraction',0.65,'TooltipString', 'Rig ID');
            mh=get_ghandle(rig_id_disp);
            lh=get_glhandle(rig_id_disp);
            set(mh, 'FontSize', user_initials_font_size, 'BackgroundColor', user_initials_bgcolor);
            set(lh(2),'Position',[rig_id_label_pos rig_id_label_size],'FontSize', universal_label_font_size, 'BackgroundColor', universal_label_color);
            
            DispParam(obj, 'username', userinitials, 10,20, 'label','CURRENT USER','labelfraction',universal_label_fraction,'TooltipString', 'User Initials');
            mh=get_ghandle(username);
            lh=get_glhandle(username);
            set(mh, 'FontSize', user_initials_font_size, 'BackgroundColor', user_initials_bgcolor);
            set(lh(2),'FontSize', universal_label_font_size, 'BackgroundColor', universal_label_color);
            % Headers/Subheaders/Footers: Stop
            
            % Display estimated pulse times: Start
            DispParam(obj, 'est_left_pulse_time', 0.15, 300,160, 'label','Est. Left Pulse Time','labelfraction',...
                universal_label_fraction,'TooltipString', 'Estimated Pulse Time');
            mh=get_ghandle(est_left_pulse_time);
            set(mh, 'FontSize', est_pulse_time_font_size, 'BackgroundColor', est_pulse_time_bgcolor);
            if ~valves_used(1); disable(est_left_pulse_time); end;
            
            DispParam(obj, 'est_center_pulse_time', '', 300,140, 'label','Est. Center Pulse Time','labelfraction',...
                universal_label_fraction,'TooltipString', 'Estimated Pulse Time');
            mh=get_ghandle(est_center_pulse_time);
            set(mh, 'FontSize', est_pulse_time_font_size, 'BackgroundColor', est_pulse_time_bgcolor);
            if ~valves_used(2); disable(est_center_pulse_time); end;
            
            DispParam(obj, 'est_right_pulse_time', '', 300,120, 'label','Est. Right Pulse Time','labelfraction',...
                universal_label_fraction,'TooltipString', 'Estimated Pulse Time');
            mh=get_ghandle(est_right_pulse_time);
            set(mh, 'FontSize', est_pulse_time_font_size, 'BackgroundColor', est_pulse_time_bgcolor);
            if ~valves_used(3); disable(est_right_pulse_time); end;
            % Display estimated pulse times: Stop
            
            % Buttons and their callbacks: Start
            PushbuttonParam(obj, 'btnCalibLowTarget', 150, 250, 'TooltipString', 'Pushing this button will start the calibration procedure to achieve low target');
            mh=get_ghandle(btnCalibLowTarget);
            set(mh,'ButtonDownFcn','','Position', [btnCalibLowTarget_pos btnCalibLowTarget_size],'FontSize', btnCalibLowTarget_font_size,...
                'String', btnCalibLowTarget_string,'BackgroundColor', btnCalibLowTarget_bgcolor,'ForegroundColor',btnCalibLowTarget_fgcolor);
            set_callback(btnCalibLowTarget,{mfilename,'set_low_calibration_const';mfilename,'start_calibration'});
            
            PushbuttonParam(obj, 'btnCalibHighTarget', 150, 250, 'TooltipString', 'Pushing this button will start the calibration procedure to achieve high target');
            mh=get_ghandle(btnCalibHighTarget);
            set(mh,'ButtonDownFcn','','Position', [btnCalibHighTarget_pos btnCalibHighTarget_size],'FontSize', btnCalibHighTarget_font_size,...
                'String', btnCalibHighTarget_string,'BackgroundColor', btnCalibHighTarget_bgcolor,'ForegroundColor',btnCalibHighTarget_fgcolor);
            set_callback(btnCalibHighTarget,{mfilename,'set_high_calibration_const';mfilename,'start_calibration'});
            disable(btnCalibHighTarget);
            % Buttons and their callbacks: Start
            
            % Settings: Start
            NumEditParam(obj, 'inter_valve_pause',value(inter_valve_pause_default),10,200,'label',INTER_VALVE_PAUSE_LABEL,'labelfraction',universal_label_fraction);
            lh=get_glhandle(inter_valve_pause);
            set(lh(2),'FontSize', universal_label_font_size, 'BackgroundColor', universal_label_color,'Position',[60 200 220 20]);
            set_callback(inter_valve_pause,{mfilename,'verify_inter_valve_pause'});
            
            NumEditParam(obj, 'num_pulses',value(num_pulses_default),10,180,'label',NUM_PULSES_LABEL,'labelfraction',universal_label_fraction);
            lh=get_glhandle(num_pulses);
            set(lh(2),'FontSize', universal_label_font_size, 'BackgroundColor', universal_label_color,'Position',[60 180 220 20]);
            set_callback(num_pulses,{mfilename,'verify_num_pulses'});
            
            NumEditParam(obj, 'left_pulse_time',value(pulse_time_default),10,160,'label',LEFT_PULSE_TIME_LABEL,'labelfraction',universal_label_fraction);
            lh=get_glhandle(left_pulse_time);
            set(lh(2),'FontSize', universal_label_font_size, 'BackgroundColor', universal_label_color,'Position',[60 160 220 20]);
            set_callback(left_pulse_time,{mfilename,'verify_pulse_times'});
            if ~valves_used(1); disable(left_pulse_time); end;
            
            NumEditParam(obj, 'center_pulse_time',value(pulse_time_default),10,140,'label',CENTER_PULSE_TIME_LABEL,'labelfraction',universal_label_fraction);
            lh=get_glhandle(center_pulse_time);
            set(lh(2),'FontSize', universal_label_font_size, 'BackgroundColor', universal_label_color,'Position',[60 140 220 20]);
            set_callback(center_pulse_time,{mfilename,'verify_pulse_times'});
            if ~valves_used(2); disable(center_pulse_time); end;
            
            NumEditParam(obj, 'right_pulse_time',value(pulse_time_default),10,120,'label',RIGHT_PULSE_TIME_LABEL,'labelfraction',universal_label_fraction);
            lh=get_glhandle(right_pulse_time);
            set(lh(2),'FontSize', universal_label_font_size, 'BackgroundColor', universal_label_color,'Position',[60 120 220 20]);
            set_callback(right_pulse_time,{mfilename,'verify_pulse_times'});
            if ~valves_used(3); disable(right_pulse_time); end;
            
            NumEditParam(obj, 'low_target_dispense',value(low_target_dispense_default),10,100,'label',LOW_TARGET_LABEL,'labelfraction',universal_label_fraction);
            lh=get_glhandle(low_target_dispense);
            set(lh(2),'FontSize', universal_label_font_size, 'BackgroundColor', universal_label_color,'Position',[60 100 220 20]);
            set_callback(low_target_dispense,{mfilename,'verify_target_dispense'});
            
            NumEditParam(obj, 'high_target_dispense',value(high_target_dispense_default),10,80,'label',HIGH_TARGET_LABEL,'labelfraction',universal_label_fraction);
            lh=get_glhandle(high_target_dispense);
            set(lh(2),'FontSize', universal_label_font_size, 'BackgroundColor', universal_label_color,'Position',[60 80 220 20]);
            set_callback(high_target_dispense,{mfilename,'verify_target_dispense'});
            
            NumEditParam(obj, 'error_tolerance',value(error_tolerance_default),10,60,'label',ERROR_TOLERANCE_LABEL,'labelfraction',universal_label_fraction);
            lh=get_glhandle(error_tolerance);
            set(lh(2),'FontSize', universal_label_font_size, 'BackgroundColor', universal_label_color,'Position',[60 60 220 20]);
            set_callback(error_tolerance,{mfilename,'verify_error_tolerance'});
            % Settings: Stop
            
            % Share sphs with other functions (after all sharing is caring): Start
            SoloFunctionAddVars('calcValvestoCalibrate','ro_args',{'valves_dionames';'valves_used';'CALIBRATION_HIGH_OR_LOW_CONST';'rig_id'});
            SoloFunctionAddVars('setDefaultPulseTime','ro_args',{'valves_dionames';'valves_used';'valves_names';'CALIBRATION_HIGH_OR_LOW_CONST';'rig_id';...
                'high_target_dispense';'low_target_dispense';'pulse_time_lower_threshold';'pulse_time_upper_threshold';'pulse_time_default'});
            SoloFunctionAddVars('setDefaultPulseTime','rw_args',{'est_left_pulse_time';'est_center_pulse_time';'est_right_pulse_time'});
            SoloFunctionAddVars('TableSection','ro_args',{'rig_id';'calib_data_history'});
            SoloFunctionAddVars('TableSection','rw_args',{'btnCalibHighTarget';'btnCalibLowTarget'});
            SoloFunctionAddVars('updateCalibrationStatusLabel','rw_args',{'sub_header_6'});
            % Share sphs with other functions (after all sharing is caring): Stop
            
            updateCalibrationStatusLabel(obj);
            setDefaultPulseTime(obj);
            TableSection(obj,'init');
            
%             set(value(myfig),'Visible','on');
            
            % Goto prepare_next_trial
            sma = StateMachineAssembler('full_trial_structure');
            sma = add_state(sma, ...
                'self_timer', 0.0001, ...
                'input_to_statechange', {'Tup', 'check_next_trial_ready'});

            dispatcher('send_assembler', sma, 'check_next_trial_ready');
            dispatcher('Run');
        end
        
    case 'verify_inter_valve_pause'
        if value(inter_valve_pause)<value(inter_valve_pause_lower_threshold) || value(inter_valve_pause)>value(inter_valve_pause_upper_threshold)
            inter_valve_pause.value=value(inter_valve_pause_default);
        end
    case 'verify_target_dispense'
        if value(low_target_dispense)<value(target_dispense_lower_threshold) || value(low_target_dispense)>value(target_dispense_upper_threshold)
            low_target_dispense.value=value(low_target_dispense_default);
        end
        if value(high_target_dispense)<value(target_dispense_lower_threshold) || value(high_target_dispense)>value(target_dispense_upper_threshold)
            high_target_dispense.value=value(high_target_dispense_default);
        end
        
    case 'verify_error_tolerance'
        if abs(value(error_tolerance))<value(error_tolerance_lower_threshold) || abs(value(error_tolerance))>value(error_tolerance_upper_threshold)
            error_tolerance.value=value(error_tolerance_default);
        end
        
    case 'verify_pulse_times'
        if value(left_pulse_time)<value(pulse_time_lower_threshold) || value(left_pulse_time)>value(pulse_time_upper_threshold)
            left_pulse_time.value=value(pulse_time_default);
        end
        if value(center_pulse_time)<value(pulse_time_lower_threshold) || value(center_pulse_time)>value(pulse_time_upper_threshold)
            center_pulse_time.value=value(pulse_time_default);
        end
        if value(right_pulse_time)<value(pulse_time_lower_threshold) || value(right_pulse_time)>value(pulse_time_upper_threshold)
            right_pulse_time.value=value(pulse_time_default);
        end

    case 'verify_num_pulses'
        if value(num_pulses)<value(num_pulses_lower_threshold) || value(num_pulses)>value(num_pulses_upper_threshold)
            num_pulses.value=value(num_pulses_default);
        end
        
    case 'set_low_calibration_const'
        CALIBRATION_HIGH_OR_LOW_CONST.value='LOW';
    
    case 'set_high_calibration_const'
        CALIBRATION_HIGH_OR_LOW_CONST.value='HIGH';

    %% prepare next trial
    case 'prepare_next_trial'
        %In general, this part of the protocol is supposed to have a bunch
        %of states wrapped into an 'sma' object to send to the dispatcher. But, in this case, the 'prepare_next_trial' is exploited to
        %end the water valve opening/closing and get started with
        %validating the water dispensed in the cup.
        if strcmpi(value(CALIBRATION_HIGH_OR_LOW_CONST), 'LOW_CALC') || strcmpi(value(CALIBRATION_HIGH_OR_LOW_CONST), 'HIGH_CALC') %Indicates a calibration procedure has just been completed
            feval(mfilename, 'validate_calibration');
        end

    case 'EnableGUIelements'
        if valves_used(1); enable(left_pulse_time); end;
        if valves_used(2); enable(center_pulse_time); end;
        if valves_used(3); enable(right_pulse_time); end;
        enable(inter_valve_pause);
        enable(num_pulses);
        enable(low_target_dispense);
        enable(high_target_dispense);
        enable(error_tolerance);
        enable(btnWaterTable);
    
    case 'DisableGUIelements'
        disable(left_pulse_time);
        disable(center_pulse_time);
        disable(right_pulse_time);
        disable(inter_valve_pause);
        disable(num_pulses);
        disable(low_target_dispense);
        disable(high_target_dispense);
        disable(error_tolerance);
        disable(btnWaterTable);
        TableSection(obj,'hide');
    
    %% start_calibration
    case 'start_calibration'
        % Let's do some calibration validity check: Start
        valves_to_calibrate_array=calcValvestoCalibrate(obj);
        valves_to_calibrate=sum(valves_to_calibrate_array);
        
        if valves_to_calibrate==0
            error_msg=sprintf('CALIBRATION MEISTER FOUND THAT %s TARGET CALIBRATION FOR ALL VALVES AVAILABLE IS ALREADY COMPLETE WITH VALID PULSE TIMES.\n\n BEFORE YOU WISH TO RE-CALIBRATE THE %s TARGET, DO ONE OF THE FOLLOWING:\n1.) ERASE ALL PULSE TIMES BY USING THE SINGLE-CLICK "ERASE ALL" BUTTON.\n    (OR)\n2.) INVALIDATE THE PERMANENT ENTRIES OF VALVE(S) BELONGING TO %s TARGET THAT YOU WISH TO RECALIBRATE.',value(CALIBRATION_HIGH_OR_LOW_CONST),value(CALIBRATION_HIGH_OR_LOW_CONST),value(CALIBRATION_HIGH_OR_LOW_CONST));
            waitfor(errordlg(error_msg, 'ERROR', 'modal'));
            if strcmpi(value(CALIBRATION_HIGH_OR_LOW_CONST), 'LOW')
                %Set CALIBRATION_HIGH_OR_LOW_CONST flag to HIGH
                CALIBRATION_HIGH_OR_LOW_CONST.value = 'HIGH';
                disable(btnCalibLowTarget);
                enable(btnCalibHighTarget);
            elseif strcmpi(value(CALIBRATION_HIGH_OR_LOW_CONST), 'HIGH')
                %Set CALIBRATION_HIGH_OR_LOW_CONST flag to HIGH
                CALIBRATION_HIGH_OR_LOW_CONST.value = 'LOW';
                enable(btnCalibLowTarget);
                disable(btnCalibHighTarget);
            end
            setDefaultPulseTime(obj);
        else
            disable(btnCalibLowTarget);
            disable(btnCalibHighTarget);
            feval(mfilename,'DisableGUIelements');
            
            %Initialize state machine assembler object
            sma = StateMachineAssembler('full_trial_structure');
            
            %Add State: Just a starting state
            sma = add_state(sma, ...
                'self_timer', value(min_state_time), ...
                'default_statechange', 'current_state+1');
            %Add State: pulsing
            sma = add_state(sma, ...
                'name', 'pulsing', ...
                'self_timer', value(min_state_time), ...
                'default_statechange', 'current_state+1');
            
            %Pulse each valve for 'number_of_pulses' times: Start
            for ctr = 1:value(num_pulses)
                if valves_used(1)
                    LPT=value(est_left_pulse_time);
                    
                    %Add State: Open Left Valve for LEFT_PULSE_TIME seconds
                    sma = add_state(sma, ...
                        'self_timer', LPT, ...
                        'input_to_statechange', {'Tup', 'current_state+1'}, ...
                        'output_actions', {'DOut', value(left1led) + value(left1water)});
                    
                    %Add State: Pause for INTER_VALVE_PAUSE seconds
                    sma = add_state(sma, ...
                        'self_timer', value(inter_valve_pause), ...
                        'input_to_statechange', {'Tup', 'current_state+1'});
                end
                
                if valves_used(2)
                    CPT=value(est_center_pulse_time);
                    
                    %Add State: Open Center Valve for CENTER_PULSE_TIME seconds
                    sma = add_state(sma, ...
                        'self_timer', CPT, ...
                        'input_to_statechange', {'Tup', 'current_state+1'}, ...
                        'output_actions', {'DOut', value(center1led) + value(center1water)});
                    
                    %Add State: Pause for INTER_VALVE_PAUSE seconds
                    sma = add_state(sma, ...
                        'self_timer', value(inter_valve_pause), ...
                        'input_to_statechange', {'Tup', 'current_state+1'});
                end
                
                if valves_used(3)
                    RPT=value(est_right_pulse_time);
                    
                    %Add State: Open Right Valve for RIGHT_PULSE_TIME seconds
                    sma = add_state(sma, ...
                        'self_timer', RPT, ...
                        'input_to_statechange', {'Tup', 'current_state+1'}, ...
                        'output_actions', {'DOut', value(right1led) + value(right1water)});
                    
                    %Add State: Pause for INTER_VALVE_PAUSE seconds
                    sma = add_state(sma, ...
                        'self_timer', value(inter_valve_pause), ...
                        'input_to_statechange', {'Tup', 'current_state+1'});
                end
            end
            %Pulse each valve for number_of_pulses times: Stop
            
            %Add State: Dummy final state
            sma = add_state(sma, ...
                'self_timer', 0.1, ...
                'input_to_statechange', {'Tup', 'check_next_trial_ready'});
            dispatcher('send_assembler', sma, 'check_next_trial_ready');
        
            %To move to validate calibration after prepare_next_trial
            CALIBRATION_HIGH_OR_LOW_CONST.value = [value(CALIBRATION_HIGH_OR_LOW_CONST), '_CALC'];
        end
    
    %% validate_calibration
    case 'validate_calibration'
        % Set some variables useful for validation: Start
        if strcmpi(value(CALIBRATION_HIGH_OR_LOW_CONST), 'HIGH_CALC')
            target_dispense=value(high_target_dispense);
            target_to_be_achieved='HIGH';
        elseif strcmpi(value(CALIBRATION_HIGH_OR_LOW_CONST), 'LOW_CALC')
            target_dispense=value(low_target_dispense);
            target_to_be_achieved='LOW';
        end
        valves_pulse_times=[value(est_left_pulse_time),value(est_center_pulse_time),value(est_right_pulse_time)];
        valves_to_calibrate_array=calcValvestoCalibrate(obj,target_to_be_achieved);
        % Set some variables useful for validation: Stop
        
        % Prepare pain-the-butt cell parameters for inputdlg box: Start
        dlg_title='Enter Weights';
        numlines=1;
        num_inputs=0;
        for i=1:3
            if valves_used(i) && valves_to_calibrate_array(i)
                num_inputs=num_inputs+1;
                prompt{num_inputs}=sprintf('Enter the weight obtained from %s cup (in grams):',valves_names{i});
                defAns{num_inputs}='0.0';
                required_valves_names{num_inputs}=valves_names{i};
                required_valves_dionames{num_inputs}=valves_dionames{i};
                required_valves_pulse_times(num_inputs)=valves_pulse_times(i);
            end
        end
        % Prepare pain-the-butt cell parameters for inputdlg box: Stop
        
        % Get weights from user with a built-in validation scheme: Start
        weight_of_cup=0;
        errflag = true;
        while errflag==true
            errflag=false;
            answer=inputdlg(prompt, dlg_title, numlines, defAns);
            if ~isempty(answer)
                for ctr = 1:length(answer)
                    try
                        answer{ctr}=regexprep(answer{ctr}, '\s', '');
                        answer_num=str2double(answer{ctr});
                        if isempty(answer{ctr}) || ~isnumeric(answer_num) || (answer_num - weight_of_cup) < 0 || isnan(answer_num) || answer_num < value(weights_lower_limit) || answer_num > value(weights_upper_limit)
                            error(' ');
                        end
                    catch %#ok<CTCH>
                        errflag = true;
                        waitfor(errordlg('Invalid input or Weights out of range. Please re-enter carefully', 'ERROR', 'modal'));
                        break;
                    end
                end
            end
        end
        % Get weights from user with a built-in validation scheme: Stop

        % Calculate dispense rate, validate calibration and save data if available with appropriate flags to sql table: Start
        if ~isempty(answer) % Data available
            iscalibrationvalid=true;
            density_inverse=1000;
            calibration_failed_valves_string='';
            for i=1:length(answer)
                validity='PERM';
                water_dispensed_grams=str2double(answer{i})-weight_of_cup;
                water_dispensed_miclitrs=(water_dispensed_grams*density_inverse)/value(num_pulses);
                if abs(water_dispensed_miclitrs-target_dispense)>value(error_tolerance)
                    validity='TEMP';
                    iscalibrationvalid=false;
                    calibration_failed_valves_string=strtrim(sprintf('%s %s',calibration_failed_valves_string,required_valves_names{i}));
                end
                sqlstr=sprintf('call bdata.update_calib_info("%s","%s","%s",%.3f,%.3f,1,"%s","%s")',value(rig_id),value(username),required_valves_dionames{i},required_valves_pulse_times(i),water_dispensed_miclitrs,target_to_be_achieved,validity);
                bdata(sqlstr);
                if strcmpi(validity,'PERM') 
                    sqlstr=sprintf('call bdata.invalidate_temp_values("%s","HIGH","%s")',value(rig_id),required_valves_dionames{i});
                    % This ensures all high temps are invalidated as soon as
                    % we achieve high/low perm
                    bdata(sqlstr);
                    if strcmpi(value(CALIBRATION_HIGH_OR_LOW_CONST), 'HIGH_CALC')
                        % The line below serves low temp invalidation in case high
                        % perm is achieved in the first attempt itself.
                        % Remember this is not true when low perm is achieved
                        % because low temps are still retained as valid
                        % although low perm is achieved to make sure they
                        % assist in high perm calculation
                        sqlstr=sprintf('call bdata.invalidate_temp_values("%s","LOW","%s")',value(rig_id),required_valves_dionames{i});
                        bdata(sqlstr);
                    end
                end
            end
            
            if iscalibrationvalid
                calib_valid_string=sprintf('CONGRATULATIONS!! %s TARGET CALIBRATION IS VALID!!!',target_to_be_achieved);
                waitfor(msgbox(calib_valid_string, 'modal'));
                if strcmpi(value(CALIBRATION_HIGH_OR_LOW_CONST), 'LOW_CALC')
                    %Set CALIBRATION_HIGH_OR_LOW_CONST flag to HIGH
                    CALIBRATION_HIGH_OR_LOW_CONST.value='HIGH';
                    disable(btnCalibLowTarget);
                    enable(btnCalibHighTarget);
                elseif strcmpi(value(CALIBRATION_HIGH_OR_LOW_CONST), 'HIGH_CALC')
                    %Set CALIBRATION_HIGH_OR_LOW_CONST flag to EXIT
                    CALIBRATION_HIGH_OR_LOW_CONST.value='LOW';
                    enable(btnCalibLowTarget);
                    disable(btnCalibHighTarget);
                end
            else %if calibration is not valid
                calib_invalid_string=sprintf('SORRY! %s TARGET CALIBRATION IS NOT VALID FOR THE FOLLOWING VALVE(S): %s.\nTRY CALIBRATING AGAIN.', target_to_be_achieved,calibration_failed_valves_string);
                waitfor(msgbox(calib_invalid_string, 'modal'));
                if strcmpi(value(CALIBRATION_HIGH_OR_LOW_CONST),'LOW_CALC')
                    CALIBRATION_HIGH_OR_LOW_CONST.value='LOW';
                    enable(btnCalibLowTarget);
                    disable(btnCalibHighTarget);
                elseif strcmpi(value(CALIBRATION_HIGH_OR_LOW_CONST),'HIGH_CALC')
                    CALIBRATION_HIGH_OR_LOW_CONST.value='HIGH';
                    disable(btnCalibLowTarget);
                    enable(btnCalibHighTarget);
                end
            end
            TableSection(obj,'refreshTable');
            setDefaultPulseTime(obj);
            updateCalibrationStatusLabel(obj);
        else % Data not available
            if strcmpi(value(CALIBRATION_HIGH_OR_LOW_CONST),'LOW_CALC')
                CALIBRATION_HIGH_OR_LOW_CONST.value='LOW';
                enable(btnCalibLowTarget);
                disable(btnCalibHighTarget);
            elseif strcmpi(value(CALIBRATION_HIGH_OR_LOW_CONST),'HIGH_CALC')
                CALIBRATION_HIGH_OR_LOW_CONST.value='HIGH';
                disable(btnCalibLowTarget);
                enable(btnCalibHighTarget);
            end
        end
        % Calculate dispense rate, validate calibration and save data if available with appropriate flags to sql table: Stop
        
        %Enable all the GUI elements
        feval(mfilename,'EnableGUIelements');
        
        % Create a dummy state that will trick the dispatcher to jump to 'prepare_next_trial'
%         sma = StateMachineAssembler('full_trial_structure');
%         sma = add_state(sma, ...
%             'self_timer', 0.001, ...
%             'name', 'stop_state', ...
%             'input_to_statechange', {'Tup', 'check_next_trial_ready'});
%         
%         dispatcher('send_assembler', sma, 'check_next_trial_ready');
    
    case 'stop_calibration'
        sma = StateMachineAssembler('full_trial_structure');
        sma = add_state(sma, ...
            'name', 'looping_stop_state', ...
            'self_timer', 0.01, ...
            'input_to_statechange', {'Tup', 'looping_stop_state'});
        dispatcher('send_assembler', sma, 'check_next_trial_ready');
        
    %% trial_completed
    case 'trial_completed'
        
    %% update
    case 'update'
        
    %% close
    case 'close'
        dispatcher('Stop');
        if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), %#ok<NODEF>
            delete(value(myfig));
        end;
        delete_sphandle('owner', ['^@' class(obj) '$']);
        return;
        
    %% end_session
    case 'end_session'
        
    %% pre_saving_settings
    case 'pre_saving_settings'
        
    %% otherwise 
    otherwise
        warning('Unknown action! "%s"\n', action); %#ok<WNTAG>
end

return
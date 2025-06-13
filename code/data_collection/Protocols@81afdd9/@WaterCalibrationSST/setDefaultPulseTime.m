%Arguments:
% 'Warning', 'true'
% 'Warning', 'false'
%Default: warning on

function setDefaultPulseTime(varargin)

global CALIBRATION_HIGH_OR_LOW_CONST;
global LOW_TARGET_DATETIME;
global HIGH_TARGET_DATETIME;

is_warning_on = true;
if any(ismember(varargin, 'Warning'))
    is_warning_on = eval(varargin{find(ismember(varargin, 'Warning'), 1, 'last')+1});
end

pulse_time_lower_threshold = 0.0001; %seconds
pulse_time_upper_threshold = 0.4; %seconds
if bSettings('compare', 'RIGS', 'Rig_ID', 30)
    %Mouse Rig
    pulse_time_default = 0.01; %seconds
else
    pulse_time_default = 0.15; %seconds
end

%Get a handle on the calibration figure window
hndlWaterCalibrationGUI = findobj(findall(0), 'Name', 'WATER_CALIBRATION');

%Handles structure containing all GUI handles
handles = guihandles(hndlWaterCalibrationGUI(1));


%Set settings from Water Calibration Table, if necessary
[status, hostname] = system('hostname'); hostname = lower(hostname);
hostname = regexprep(hostname, '\s', ''); hostname = regexprep(hostname, '\..*', '');
Calibration_Data_Directory = bSettings('get', 'GENERAL', 'Calibration_Data_Directory');
if isnan(Calibration_Data_Directory)
    Calibration_Data_Directory = '\ratter\CNMC\Calibration';
end
Calibration_Data_Directory = strrep(Calibration_Data_Directory, '\', filesep);

rig_id = bSettings('get', 'RIGS', 'Rig_ID');
if isnumeric(rig_id)
    rig_id = num2str(rig_id);
end

if exist(fullfile(Calibration_Data_Directory, [hostname, '_watertable.mat']), 'file')
    load(fullfile(Calibration_Data_Directory, [hostname, '_watertable.mat'])); %Load wt
    %Here, calculate CENTER_PULSE_TIME_SECONDS, LEFT_PULSE_TIME_SECONDS,
    %RIGHT_PULSE_TIME_SECONDS from wt
    %The algorithm works somewhat like this:
    %If no reading is available, the initial LEFT_PULSE_TIME_SECONDS is
    %taken from the file WaterCalibrationSettings.mat
    %If only one reading is available, a line is drawn from that reading to
    %the origin
    %If two or more readings are available, a line is drawn through those
    %two points
    
    if bSettings('compare', 'RIGS', 'Rig_ID', 30)
        load('WaterCalibrationSettings_MouseRig.mat');
    else
        load('WaterCalibrationSettings.mat');
    end
    
    if strcmpi(CALIBRATION_HIGH_OR_LOW_CONST, 'LOW') || strcmpi(CALIBRATION_HIGH_OR_LOW_CONST, 'LOW_CALC')
        target_dispense = eval(get(handles.LOW_TARGET_MICROLITERS, 'String'));
    elseif strcmpi(CALIBRATION_HIGH_OR_LOW_CONST, 'HIGH') || strcmpi(CALIBRATION_HIGH_OR_LOW_CONST, 'HIGH_CALC')
        target_dispense = eval(get(handles.HIGH_TARGET_MICROLITERS, 'String'));
    end
    
    
    %% SECTION FOR LEFT_PULSE_TIME_SECONDS
    slopewarning = true;
    while slopewarning
        slopewarning = false;
        numreadings = 0;
        readingindex = zeros(2,1);
        ctr2 = 1;
        for ctr = length(wt):-1:1 %Giving preference to the most recent readings
            if strcmpi(wt(ctr).valve, 'left1water') && wt(ctr).isvalid
                numreadings = numreadings+1;
                readingindex(ctr2) = ctr;
                ctr2 = ctr2 + 1;
                if numreadings==2
                    break;
                end
            end
        end
        if numreadings==0
            LEFT_PULSE_TIME_SECONDS = (LEFT_PULSE_TIME_SECONDS * target_dispense)/LOW_TARGET_MICROLITERS;
        elseif numreadings==1
            LEFT_PULSE_TIME_SECONDS = wt(readingindex(1)).time * target_dispense/wt(readingindex(1)).dispense;
        elseif numreadings==2
            %Points: (wt(readingindex(1)).dispense, wt(readingindex(1)).time),
            %(wt(readingindex(2)).dispense, wt(readingindex(2)).time)
            slope = (wt(readingindex(2)).time - wt(readingindex(1)).time)/(wt(readingindex(2)).dispense - wt(readingindex(1)).dispense);
            if slope>0 && isfinite(slope) %Data can be trusted if slope is in this range, otherwise it cannot
                LEFT_PULSE_TIME_SECONDS = wt(readingindex(2)).time - slope*(wt(readingindex(2)).dispense - target_dispense);
            else
                slopewarning = true;
                %LEFT_PULSE_TIME_SECONDS = (LEFT_PULSE_TIME_SECONDS * target_dispense)/LOW_TARGET_MICROLITERS; %#ok<NODEF>
                wt(readingindex(2)).isvalid = false; %#ok<AGROW>
                save(fullfile(Calibration_Data_Directory, [hostname, '_watertable.mat']), 'wt', '-v7');
                refreshWaterTable;
                sqlstr = 'CALL bdata.update_calibration_info_tbl(';
                sqlstr = [sqlstr, '"', rig_id '", ', '"', datestr(wt(readingindex(2)).date, 31), '", ', '"', wt(readingindex(2)).valve, '", FALSE)']; %#ok<AGROW>
                mym(bdata, sqlstr);
            end
        end
    end
    
    %% SECTION FOR CENTER_PULSE_TIME_SECONDS
    slopewarning = true;
    while slopewarning
        slopewarning = false;
        numreadings = 0;
        readingindex = zeros(2,1);
        ctr2 = 1;
        for ctr = length(wt):-1:1 %Giving preference to the most recent readings
            if strcmpi(wt(ctr).valve, 'center1water') && wt(ctr).isvalid
                numreadings = numreadings+1;
                readingindex(ctr2) = ctr;
                ctr2 = ctr2 + 1;
                if numreadings==2
                    break;
                end
            end
        end
        if numreadings==0
            CENTER_PULSE_TIME_SECONDS = (CENTER_PULSE_TIME_SECONDS * target_dispense)/LOW_TARGET_MICROLITERS;
        elseif numreadings==1
            CENTER_PULSE_TIME_SECONDS = wt(readingindex(1)).time * target_dispense/wt(readingindex(1)).dispense;
        elseif numreadings==2
            %Points: (wt(readingindex(1)).dispense, wt(readingindex(1)).time),
            %(wt(readingindex(2)).dispense, wt(readingindex(2)).time)
            slope = (wt(readingindex(2)).time - wt(readingindex(1)).time)/(wt(readingindex(2)).dispense - wt(readingindex(1)).dispense);
            if slope>0 && isfinite(slope) %Data can be trusted if slope is greater than zero, otherwise it cannot
                CENTER_PULSE_TIME_SECONDS = wt(readingindex(2)).time - slope*(wt(readingindex(2)).dispense - target_dispense);
            else
                slopewarning = true;
                %CENTER_PULSE_TIME_SECONDS = (CENTER_PULSE_TIME_SECONDS * target_dispense)/LOW_TARGET_MICROLITERS; %#ok<NODEF>
                wt(readingindex(2)).isvalid = false; %#ok<AGROW>
                save(fullfile(Calibration_Data_Directory, [hostname, '_watertable.mat']), 'wt', '-v7');
                refreshWaterTable;
                sqlstr = 'CALL bdata.update_calibration_info_tbl(';
                sqlstr = [sqlstr, '"', rig_id '", ', '"', datestr(wt(readingindex(2)).date, 31), '", ', '"', wt(readingindex(2)).valve, '", FALSE)']; %#ok<AGROW>
                mym(bdata, sqlstr);
            end
        end
    end
    
    
    
    
    %% SECTION FOR RIGHT_PULSE_TIME_SECONDS
    slopewarning = true;
    while slopewarning
        slopewarning = false;
        numreadings = 0;
        readingindex = zeros(2,1);
        ctr2 = 1;
        for ctr = length(wt):-1:1 %Giving preference to the most recent readings
            if strcmpi(wt(ctr).valve, 'right1water') && wt(ctr).isvalid
                numreadings = numreadings+1;
                readingindex(ctr2) = ctr;
                ctr2 = ctr2 + 1;
                if numreadings==2
                    break;
                end
            end
        end
        if numreadings==0
            RIGHT_PULSE_TIME_SECONDS = (RIGHT_PULSE_TIME_SECONDS * target_dispense)/LOW_TARGET_MICROLITERS;
        elseif numreadings==1
            RIGHT_PULSE_TIME_SECONDS = wt(readingindex(1)).time * target_dispense/wt(readingindex(1)).dispense;
        elseif numreadings==2
            %Points: (wt(readingindex(1)).dispense, wt(readingindex(1)).time),
            %(wt(readingindex(2)).dispense, wt(readingindex(2)).time)
            slope = (wt(readingindex(2)).time - wt(readingindex(1)).time)/(wt(readingindex(2)).dispense - wt(readingindex(1)).dispense);
            if slope>0 && isfinite(slope) %Data can be trusted if slope is greater than zero, otherwise it cannot
                RIGHT_PULSE_TIME_SECONDS = wt(readingindex(2)).time - slope*(wt(readingindex(2)).dispense - target_dispense);
            else
                slopewarning = true;
                %RIGHT_PULSE_TIME_SECONDS = (RIGHT_PULSE_TIME_SECONDS * target_dispense)/LOW_TARGET_MICROLITERS; %#ok<NODEF>
                wt(readingindex(2)).isvalid = false; %#ok<AGROW>
                save(fullfile(Calibration_Data_Directory, [hostname, '_watertable.mat']), 'wt', '-v7');
                refreshWaterTable;
                sqlstr = 'CALL bdata.update_calibration_info_tbl(';
                sqlstr = [sqlstr, '"', rig_id '", ', '"', datestr(wt(readingindex(2)).date, 31), '", ', '"', wt(readingindex(2)).valve, '", FALSE)']; %#ok<AGROW>
                mym(bdata, sqlstr);
            end
        end
    end
    
    
    %% POTENTIAL SITUATION: IF WE ARE IN THE HIGH CALIBRATION STAGE, AND
    %% SOMEHOW THE LOW CALIBRATION TARGET VALUE PREVIOUSLY ACHIEVED GETS
    %% INVALIDATED, IT INDICATES THAT EITHER THE VALVE IS SERIOUSLY OUT OF
    %% ORDER, OR READINGS WERE GROSSLY INCORRECT. IF THIS HAPPENS, ALL
    %% CALIBRATION DATA MUST BE INVALIDATED, AND THE CALIBRATION PROCESS
    %% NEEDS TO BE RESTARTED.
    %wt still exists
    validation_low_target_check_warning = false;
    if strcmpi(CALIBRATION_HIGH_OR_LOW_CONST, 'HIGH') || strcmpi(CALIBRATION_HIGH_OR_LOW_CONST, 'HIGH_CALC')
        for ctr = length(wt):-1:1
            if strcmp(datestr(wt(ctr).date), datestr(LOW_TARGET_DATETIME)) && ...
                    ~wt(ctr).isvalid
                validation_low_target_check_warning = true;
                break;
            end
        end
    end
            
    
    
    
    %% IF WE GET SOME IMPOSSIBLE VALUES, WE SATURATE THEM, WHILE ISSUING WARNINGS
    lsatwarning = false;
    usatwarning = false;
    if LEFT_PULSE_TIME_SECONDS < pulse_time_lower_threshold
        lsatwarning = true;
        LEFT_PULSE_TIME_SECONDS = pulse_time_lower_threshold;
    elseif LEFT_PULSE_TIME_SECONDS > pulse_time_upper_threshold;
        usatwarning = true;
        %LEFT_PULSE_TIME_SECONDS = pulse_time_default;
    end
    if CENTER_PULSE_TIME_SECONDS < pulse_time_lower_threshold
        lsatwarning = true;
        CENTER_PULSE_TIME_SECONDS = pulse_time_lower_threshold;
    elseif CENTER_PULSE_TIME_SECONDS > pulse_time_upper_threshold;
        usatwarning = true;
        %CENTER_PULSE_TIME_SECONDS = pulse_time_default;
    end
    if RIGHT_PULSE_TIME_SECONDS < pulse_time_lower_threshold
        lsatwarning = true;
        RIGHT_PULSE_TIME_SECONDS = pulse_time_lower_threshold;
    elseif RIGHT_PULSE_TIME_SECONDS > pulse_time_upper_threshold;
        usatwarning = true;
        %RIGHT_PULSE_TIME_SECONDS = pulse_time_default;
    end
    if lsatwarning || usatwarning || validation_low_target_check_warning
        load(fullfile(Calibration_Data_Directory, [hostname, '_watertable.mat']));
        for ctr = 1:length(wt)
            wt(ctr).isvalid = false; %#ok<AGROW>
            sqlstr = 'CALL bdata.update_calibration_info_tbl(';
            sqlstr = [sqlstr, '"', rig_id '", ', '"', datestr(wt(ctr).date, 31), '", ', '"', wt(ctr).valve, '", FALSE)']; %#ok<AGROW>
            mym(bdata, sqlstr);
        end
        save(fullfile(Calibration_Data_Directory, [hostname, '_watertable.mat']), 'wt', '-v7');
        refreshWaterTable;
        LEFT_PULSE_TIME_SECONDS = pulse_time_default;
        CENTER_PULSE_TIME_SECONDS = pulse_time_default;
        RIGHT_PULSE_TIME_SECONDS = pulse_time_default;
        if usatwarning && is_warning_on
            waitfor(warndlg(['WARNING: One or more computed values of pulse time are far too high. They are being reset to ', num2str(pulse_time_default), ' seconds. The calibration process needs to be restarted. Please clean the valves before proceeding. If the problem persists, contact a developer.'], ...
                'Warning', 'modal'));
        elseif lsatwarning && is_warning_on
            waitfor(warndlg(['WARNING: One or more computed values of pulse time are unreasonably low. They are being set to ', num2str(pulse_time_default), ' seconds. The calibration process needs to be restarted. If the problem persists, contact a developer.'], ...
                'Warning', 'modal'));
        elseif validation_low_target_check_warning && is_warning_on
            waitfor(warndlg(['WARNING: It looks like a negative slope was encountered while fitting a line with today''s low calibration data. All pulse times are being set to ' num2str(pulse_time_default) ' seconds. The calibration process needs to be restarted. If the problem persists, contact a developer.'], ...
                'Warning', 'modal'));
        end
        set(handles.btnStartCalibrationHighTarget, 'Enable', 'off');
        set(handles.btnStartCalibrationHighTarget, 'BackgroundColor', [212 208 200]./255);
        set(handles.btnStartCalibrationLowTarget, 'Enable', 'on');
        set(handles.btnStartCalibrationLowTarget, 'BackgroundColor', 'yellow');
    end
    %     if slopewarning && is_warning_on
    %         waitfor(warndlg('WARNING: While attempting to compute pulse time, a negative or non-finite slope was encountered. The default value is being used for the corresponding valve pulse time. Please delete old errant data and restart the calibration process. If the problem persists, contact a developer.', ...
    %             'Warning', 'modal'));
    %     end
    
    %% FINALLY WE SET THE NEW VALUES
    set(handles.LEFT_PULSE_TIME_SECONDS, 'String', num2str(LEFT_PULSE_TIME_SECONDS));
    set(handles.CENTER_PULSE_TIME_SECONDS, 'String', num2str(CENTER_PULSE_TIME_SECONDS));
    set(handles.RIGHT_PULSE_TIME_SECONDS, 'String', num2str(RIGHT_PULSE_TIME_SECONDS));
    
    left1water = bSettings('get', 'DIOLINES', 'left1water');
    center1water = bSettings('get', 'DIOLINES', 'center1water');
    right1water = bSettings('get', 'DIOLINES', 'right1water');
    epsilon = 0.1;
    sum_of_valve_open_times = 0;
    if ~isnan(left1water)
        sum_of_valve_open_times = sum_of_valve_open_times + LEFT_PULSE_TIME_SECONDS;
    end
    if ~isnan(center1water)
        sum_of_valve_open_times = sum_of_valve_open_times + CENTER_PULSE_TIME_SECONDS;
    end
    if ~isnan(right1water)
        sum_of_valve_open_times = sum_of_valve_open_times + RIGHT_PULSE_TIME_SECONDS;
    end
    inter_pulse_interval = sum_of_valve_open_times + epsilon;
    set(handles.INTER_PULSE_INTERVAL_SECONDS, 'String', num2str(inter_pulse_interval));
    
end
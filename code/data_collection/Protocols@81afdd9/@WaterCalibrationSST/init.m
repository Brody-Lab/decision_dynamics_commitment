%INIT: Initializes the Water Calibration GUI

function init

global CALIBRATION_HIGH_OR_LOW_CONST;

%Open the figure, preserve the handle. If figure is already open, don't
%bother.
hndlWaterCalibrationGUI = openfig('WATER_CALIBRATION.fig', 'reuse');
set(hndlWaterCalibrationGUI(1), 'Visible', 'on');

%Load default settings, which will eventually be replaced by better
%settings if old calibration data is available.
if bSettings('compare', 'RIGS', 'Rig_ID', 30)
    load('WaterCalibrationSettings_MouseRig.mat');
else
    load('WaterCalibrationSettings.mat');
end

%Handles structure for all GUI elements
handles = guihandles(hndlWaterCalibrationGUI(1));

%Setting the symbol for microliter (for pretty print)
set(handles.lblLeftActualReading, 'String', [char(hex2dec('B5')), 'L/dispense']);
set(handles.lblCenterActualReading, 'String', [char(hex2dec('B5')), 'L/dispense']);
set(handles.lblRightActualReading, 'String', [char(hex2dec('B5')), 'L/dispense']);

set(handles.lblLeftTargetReading, 'String', ['Target ', char(hex2dec('B5')), 'L/dispense']);
set(handles.lblCenterTargetReading, 'String', ['Target ', char(hex2dec('B5')), 'L/dispense']);
set(handles.lblRightTargetReading, 'String', ['Target ', char(hex2dec('B5')), 'L/dispense']);

set(handles.lblErrorTolerance, 'String', ['Error Tolerance (', char(hex2dec('B5')), 'L)']);
set(handles.lblHighTarget, 'String', ['High Target (', char(hex2dec('B5')), 'L)']);
set(handles.lblLowTarget, 'String', ['Low Target (', char(hex2dec('B5')), 'L)']);

%Disable relevant fields if valve does not exist (NaN)
left1water = bSettings('get', 'DIOLINES', 'left1water');
center1water = bSettings('get', 'DIOLINES', 'center1water');
right1water = bSettings('get', 'DIOLINES', 'right1water');
if isnan(left1water)
    set(handles.LeftWeightMeasured, 'Enable', 'off');
    set(handles.LeftActualDispense, 'Enable', 'off');
    set(handles.LeftTargetDispense, 'Enable', 'off');
    set(handles.LEFT_PULSE_TIME_SECONDS, 'Enable', 'off');
end
if isnan(center1water)
    set(handles.CenterWeightMeasured, 'Enable', 'off');
    set(handles.CenterActualDispense, 'Enable', 'off');
    set(handles.CenterTargetDispense, 'Enable', 'off');
    set(handles.CENTER_PULSE_TIME_SECONDS, 'Enable', 'off');
end
if isnan(right1water)
    set(handles.RightWeightMeasured, 'Enable', 'off');
    set(handles.RightActualDispense, 'Enable', 'off');
    set(handles.RightTargetDispense, 'Enable', 'off');
    set(handles.RIGHT_PULSE_TIME_SECONDS, 'Enable', 'off');
end

%Set font to monospaced by default
set(handles.WaterCalibrationTable, 'FontName', 'Monospaced');

%Set all settings
SettingsVariableList = who('-file', 'WaterCalibrationSettings.mat');
for ctr = 1:length(SettingsVariableList)
    hndl = eval(['handles.', SettingsVariableList{ctr}]);
    value = eval(SettingsVariableList{ctr});
    set(hndl, 'String', value);
end

%Load current water calibration data, if available
sync_database;
refreshWaterTable;


%Set button properties
if strcmpi(CALIBRATION_HIGH_OR_LOW_CONST, 'LOW')
    set(handles.btnStartCalibrationLowTarget, 'BackgroundColor', 'yellow');
    set(handles.btnStartCalibrationLowTarget, 'Enable', 'on');
    set(handles.btnStartCalibrationHighTarget, 'BackgroundColor', [212 208 200]./255);
    set(handles.btnStartCalibrationHighTarget, 'Enable', 'off');
elseif strcmpi(CALIBRATION_HIGH_OR_LOW_CONST, 'HIGH')
    set(handles.btnStartCalibrationLowTarget, 'BackgroundColor', [212 208 200]./255);
    set(handles.btnStartCalibrationLowTarget, 'Enable', 'off');
    set(handles.btnStartCalibrationHighTarget, 'BackgroundColor', 'yellow');
    set(handles.btnStartCalibrationHighTarget, 'Enable', 'on');
end
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



%Set default settings for pulse time
setDefaultPulseTime('Warning', 'false');
    


%SET CALLBACKS
%btnHelpCallback
set(handles.btnHelp, 'Callback', 'btnHelpCallback');

%btnExitWithoutSaving
set(handles.btnExit, 'Callback', 'btnExitCallback');

%btnCustomizeSettings
set(handles.btnCustomizeSettings, 'Callback', 'btnCustomizeSettingsCallback');

%btnSuggestPulseTimes
set(handles.btnSuggestPulseTimes, 'Callback', 'btnSuggestPulseTimesCallback');

%btnStartCalibrationLowTarget
set(handles.btnStartCalibrationLowTarget, 'Callback', 'btnStartCalibrationLowTargetCallback');

%btnStartCalibrationHighTarget
set(handles.btnStartCalibrationHighTarget, 'Callback', 'btnStartCalibrationHighTargetCallback');

%btnDeleteSelectedEntries
set(handles.btnDeleteSelectedEntries, 'Callback', 'btnDeleteSelectedEntriesCallback');

%btnRestartCalibrationProcess
set(handles.btnRestartCalibrationProcess, 'Callback', 'btnRestartCalibrationProcessCallback');

%btnIgnoreSelectedEntries
set(handles.btnIgnoreSelectedEntries, 'Callback', 'btnIgnoreSelectedEntriesCallback');

%btnAcceptSelectedEntries
set(handles.btnAcceptSelectedEntries, 'Callback', 'btnAcceptSelectedEntriesCallback');



end


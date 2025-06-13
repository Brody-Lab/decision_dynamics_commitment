function btnStartCalibrationHighTargetCallback

%Step 1: Set variable indicating which calibration procedure is to be run.
%This is a global CONSTANT.
global CALIBRATION_HIGH_OR_LOW_CONST;
global PROTOCOL_NAME;
CALIBRATION_HIGH_OR_LOW_CONST = 'HIGH';

hndlWaterCalibrationGUI = findobj(findall(0), 'Name', 'WATER_CALIBRATION');
handles = guihandles(hndlWaterCalibrationGUI(1));

%Set button properties
set(handles.btnStartCalibrationLowTarget, 'BackgroundColor', [212 208 200]./255);
set(handles.btnStartCalibrationLowTarget, 'Enable', 'off');
set(handles.btnStartCalibrationHighTarget, 'BackgroundColor', 'yellow');
set(handles.btnStartCalibrationHighTarget, 'Enable', 'off');
set(handles.btnExit, 'BackgroundColor', 'red');
set(handles.btnExit, 'Enable', 'off');
set(handles.btnHelp, 'BackgroundColor', 'green');
set(handles.btnHelp, 'Enable', 'on');
set(handles.btnSuggestPulseTimes, 'BackgroundColor', 'green');
set(handles.btnSuggestPulseTimes, 'Enable', 'off');
set(handles.btnCustomizeSettings, 'BackgroundColor', 'green');
set(handles.btnCustomizeSettings, 'Enable', 'off');
set(handles.btnDeleteSelectedEntries, 'BackgroundColor', 'green');
set(handles.btnDeleteSelectedEntries, 'Enable', 'off');
set(handles.btnRestartCalibrationProcess, 'BackgroundColor', 'green');
set(handles.btnRestartCalibrationProcess, 'Enable', 'off');
set(handles.btnIgnoreSelectedEntries, 'BackgroundColor', 'green');
set(handles.btnIgnoreSelectedEntries, 'Enable', 'off');
set(handles.btnAcceptSelectedEntries, 'BackgroundColor', 'green');
set(handles.btnAcceptSelectedEntries, 'Enable', 'off');


feval(PROTOCOL_NAME, 'start_calibration');

end
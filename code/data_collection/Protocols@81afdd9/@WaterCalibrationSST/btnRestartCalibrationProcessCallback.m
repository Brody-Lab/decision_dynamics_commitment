function btnRestartCalibrationProcessCallback

global PROTOCOL_NAME;
global CALIBRATION_HIGH_OR_LOW_CONST;

answer = questdlg('Are you sure you want to restart?', 'Confirmation', 'YES', 'NO', 'NO');

if strcmpi(answer, 'YES')

    CALIBRATION_HIGH_OR_LOW_CONST = 'LOW';

    hndlWaterCalibrationGUI = findobj(findall(0), 'Name', 'WATER_CALIBRATION');
    handles = guihandles(hndlWaterCalibrationGUI(1));

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

    setDefaultPulseTime('Warning', 'false');

    feval(PROTOCOL_NAME, 'prepare_next_trial');

end

end

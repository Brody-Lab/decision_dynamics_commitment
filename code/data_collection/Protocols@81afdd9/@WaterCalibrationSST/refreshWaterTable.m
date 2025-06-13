%REFRESHWATERTABLE Refreshes the water calibration table using the
%calibration data MAT file. If the file doesn't exist, the function takes
%care of that.

function refreshWaterTable

%Get a handle on the calibration figure window
hndlWaterCalibrationGUI = findobj(findall(0), 'Name', 'WATER_CALIBRATION');

%Handles structure containing all GUI handles
handles = guihandles(hndlWaterCalibrationGUI(1));

booleanstr = {'no', 'yes'};

%Convention for the calibration data file is to have the name
%<hostname>_watertable.mat. We ensure it is in the -v7 format for backward
%compatibility whenever we save the table. This is where the water
%calibration table in the GUI gets populated with the current data.
[status, hostname] = system('hostname'); hostname = lower(hostname);
hostname = regexprep(hostname, '\s', ''); hostname = regexprep(hostname, '\..*', '');
formatstring = '%10s |%25s |%15s |%20s |%15s | %10s';
Calibration_Data_Directory = bSettings('get', 'GENERAL', 'Calibration_Data_Directory');
if isnan(Calibration_Data_Directory)
    Calibration_Data_Directory = '\ratter\CNMC\Calibration';
end
Calibration_Data_Directory = strrep(Calibration_Data_Directory, '\', filesep);
if exist(fullfile(Calibration_Data_Directory, [hostname, '_watertable.mat']), 'file')
    load(fullfile(Calibration_Data_Directory, [hostname, '_watertable.mat'])); %Loads variable wt
    WaterCalibrationTableStr = cell(1, length(wt)+1);
    WaterCalibrationTableStr{1} = sprintf(formatstring, 'Initials', 'Date', 'Valve', 'Time (seconds)', [char(hex2dec('B5')), 'L/Dispense'], 'Considered?');
    for ctr = 1:length(wt)
        %Would like to display table with most recent readings at the top.
        WaterCalibrationTableStr{ctr+1} = sprintf(formatstring, upper(wt(length(wt)+1-ctr).initials), datestr(wt(length(wt)+1-ctr).date), wt(length(wt)+1-ctr).valve, num2str(wt(length(wt)+1-ctr).time), num2str(wt(length(wt)+1-ctr).dispense), booleanstr{double(wt(length(wt)+1-ctr).isvalid)+1});
    end
else
    WaterCalibrationTableStr = cell(1,1);
    WaterCalibrationTableStr{1} = sprintf(formatstring, 'Initials', 'Date', 'Valve', 'Time (seconds)', [char(hex2dec('B5')), 'L/Dispense'], 'Considered?');
end
set(handles.WaterCalibrationTable, 'String', WaterCalibrationTableStr);

end
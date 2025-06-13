function btnAcceptSelectedEntriesCallback

hndlWaterCalibrationGUI = findobj(findall(0), 'Name', 'WATER_CALIBRATION');

handles = guihandles(hndlWaterCalibrationGUI(1));

%Load MAT file
[status, hostname] = system('hostname'); hostname = lower(hostname);
hostname = regexprep(hostname, '\s', ''); hostname = regexprep(hostname, '\..*', '');
Calibration_Data_Directory = bSettings('get', 'GENERAL', 'Calibration_Data_Directory');
if isnan(Calibration_Data_Directory)
    Calibration_Data_Directory = '\ratter\CNMC\Calibration';
end
rig_id = bSettings('get', 'RIGS', 'Rig_ID');
if isnumeric(rig_id)
    rig_id = num2str(rig_id);
end
Calibration_Data_Directory = strrep(Calibration_Data_Directory, '\', filesep);
if exist(fullfile(Calibration_Data_Directory, [hostname, '_watertable.mat']), 'file')
    load(fullfile(Calibration_Data_Directory, [hostname, '_watertable.mat'])); %Loads variable wt
    
    %Identify selected entry
    SelectedIndices = get(handles.WaterCalibrationTable, 'Value');
    
    %We need to ignore selected index 1, since it consists of the headers
    SelectedIndices(SelectedIndices == 1.0) = [];
    
    if ~isempty(SelectedIndices)
        SelectedIndices = SelectedIndices - 1.0;
        
        %Transforming SelectedIndices so that it takes into account
        %reversal of the table
        SelectedIndices = length(wt)+1-SelectedIndices; %#ok<NODEF>
        
        for ctr = 1:length(SelectedIndices)
            wt(SelectedIndices(ctr)).isvalid = true; %#ok<AGROW>
            
            sqlstr = 'CALL bdata.update_calibration_info_tbl(';
            sqlstr = [sqlstr, '"', rig_id '", ', '"', datestr(wt(SelectedIndices(ctr)).date, 31), '", ', '"', wt(SelectedIndices(ctr)).valve, '", TRUE)']; %#ok<AGROW>
            mym(bdata, sqlstr);
        end
        
        save(fullfile(Calibration_Data_Directory, [hostname, '_watertable.mat']), 'wt', '-v7');
        
        refreshWaterTable;
    end
    
end
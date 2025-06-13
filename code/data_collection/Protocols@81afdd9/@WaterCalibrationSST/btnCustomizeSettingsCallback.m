function btnCustomizeSettingsCallback

hndlWaterCalibrationGUI = findobj(findall(0), 'Name', 'WATER_CALIBRATION');

handles = guihandles(hndlWaterCalibrationGUI(1)); %#ok<NASGU>

SettingsVariableList = who('-file', 'WaterCalibrationSettings.mat');

prompt = cell(length(SettingsVariableList), 1);
defAns = prompt;
for ctr = 1:length(SettingsVariableList)
    prompt{ctr} = ['Enter ', SettingsVariableList{ctr}, ':'];
    hndl = eval(['handles.', SettingsVariableList{ctr}]);
    defAns{ctr} = get(hndl, 'String');
end
dlg_title = 'Customize Settings';
numlines = 1;
options.WindowStyle = 'modal';

errflag = true;
while errflag == true
    
    errflag = false;
    answer = inputdlg(prompt, dlg_title, numlines, defAns, options);
    if ~isempty(answer)
        for ctr = 1:length(answer)
            try
                answer{ctr} = regexprep(answer{ctr}, '\s', '');
                answer_num = eval(answer{ctr});
                if isempty(answer{ctr}) || ~isnumeric(answer_num) || answer_num<0
                    error(' ');
                end
                
            catch %#ok<CTCH>
                errflag = true;
                waitfor(errordlg('ERROR: Invalid input.', 'ERROR', 'modal'));
                break;
            end
        end
    end
    
end

%If we could get this far, the answer is valid.
if ~isempty(answer)
    for ctr = 1:length(SettingsVariableList)
        hndl = eval(['handles.', SettingsVariableList{ctr}]);
        value = eval(answer{ctr});
        set(hndl, 'String', value);
    end
end


end


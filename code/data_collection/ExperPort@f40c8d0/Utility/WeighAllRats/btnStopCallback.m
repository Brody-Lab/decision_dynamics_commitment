function btnStopCallback

global FIGURE_NAME;
global IS_STOPPED;

hndlMassMeister = findobj(findall(0), 'Name', FIGURE_NAME);
handles = guihandles(hndlMassMeister(1));

%Check to see if all rats in the list have been weighed
lbxlist = get(handles.lbxRatInfo, 'String');
mass_str = regexprep(lbxlist, '\s', '');
mass_str = regexprep(mass_str, '[^\|]*\|', '');
foundempty = false;
for ctr = 1:length(mass_str)
    if isempty(mass_str{ctr})
        foundempty = true;
        break;
    end
end
if foundempty
    
    set(handles.btnStart, 'Enable', 'on');
    set(handles.btnStop, 'Enable', 'off');
    set(handles.btnSetScaleToZero, 'Enable', 'on');
    set(handles.btnSaveAndExit, 'Enable', 'on');
    set(handles.btnSave, 'Enable', 'on');
    set(handles.btnExitWithoutSaving, 'Enable', 'on');
    % set(handles.btnSubmitWeight, 'Enable', 'off');
    set(handles.editWeight, 'String', '');
    set(handles.popupSession, 'Enable', 'on');
    set(handles.btnEditSelectedEntry, 'Enable', 'on');
    set(handles.lbxRatInfo, 'Enable', 'on');
    set(handles.btnClearSelectedEntry, 'Enable', 'on');
    set(handles.checkboxUseCustomSettings, 'Enable', 'on');
    set(handles.textInstructions, 'String', {''; 'Stopped.'});
    set(handles.btnEditCustomSettings, 'Enable', 'on');
    set(handles.editWeight, 'Enable', 'off');
    %cla(handles.axesScalePlot);
    %waitfor(handles.btnStart, 'Enable', 'off');
    
    IS_STOPPED = true;
    
else
    
    set(handles.btnEditSelectedEntry, 'Enable', 'on');
    set(handles.checkboxUseCustomSettings, 'Enable', 'on');
    set(handles.textInstructions, 'String', {''; 'Stopped.'});
    set(handles.popupSession, 'Enable', 'on');
    set(handles.btnStop, 'Enable', 'off');
    set(handles.btnStart, 'Enable', 'on');
    set(handles.textInstructions, 'String', {''; 'Press START, or exit the application'});
    set(handles.lbxRatInfo, 'Enable', 'on');
    set(handles.btnClearSelectedEntry, 'Enable', 'on');
    set(handles.btnEditCustomSettings, 'Enable', 'on');
    set(handles.btnSaveAndExit, 'Enable', 'on');
    set(handles.btnSave, 'Enable', 'on');
    set(handles.btnExitWithoutSaving, 'Enable', 'on');
    set(handles.btnSetScaleToZero, 'Enable', 'on');
    set(handles.editWeight, 'Enable', 'off');
    
    IS_STOPPED = true;
    
end

end
function popupSessionCallback

global FIGURE_NAME;
global POPUP_SESSION_CALLBACK;

iscomplete = refreshLbxRatInfo;

hndlMassMeister = findobj(findall(0), 'Name', FIGURE_NAME);
handles = guihandles(hndlMassMeister(1));
set(handles.lbxRatInfo, 'Value', 1);

if ~iscomplete
    set(handles.btnStart, 'Enable', 'on');
end
set(handles.btnSetScaleToZero, 'Enable', 'on');
set(handles.btnSaveAndExit, 'Enable', 'on');
set(handles.btnSave, 'Enable', 'on');
set(handles.btnExitWithoutSaving, 'Enable', 'on');
set(handles.btnEditCustomSettings, 'Enable', 'on');
set(handles.editWeight, 'Enable', 'off');

POPUP_SESSION_CALLBACK = true;

pause(0.05);

end
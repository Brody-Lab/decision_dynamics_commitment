function btnStartCallback_update

global IS_STOPPED;
global LBX_RATINFO_CALLBACK;
global EDIT_SELECTED_ENTRY_CALLBACK;
global CLEAR_SELECTED_ENTRY_CALLBACK;
global POPUP_SESSION_CALLBACK;
global FIGURE_NAME;

IS_STOPPED = false;
LBX_RATINFO_CALLBACK = false;
EDIT_SELECTED_ENTRY_CALLBACK = false;
CLEAR_SELECTED_ENTRY_CALLBACK = false;
POPUP_SESSION_CALLBACK = false;

hndlMassMeister = findobj(findall(0), 'Name', FIGURE_NAME);
handles = guihandles(hndlMassMeister(1));

set(handles.btnStop, 'Enable', 'on');
set(handles.btnStart, 'Enable', 'off');
set(handles.textInstructions, 'String', {''; 'Started, select the rat'});

end
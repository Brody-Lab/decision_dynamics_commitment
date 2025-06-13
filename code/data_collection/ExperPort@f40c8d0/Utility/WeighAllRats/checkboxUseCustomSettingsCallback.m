function checkboxUseCustomSettingsCallback

global FIGURE_NAME;

refreshLbxRatInfo;
hndlMassMeister = findobj(findall(0), 'Name', FIGURE_NAME);
handles = guihandles(hndlMassMeister(1));
set(handles.lbxRatInfo, 'Value', 1);
lbxRatInfoCallback;

end
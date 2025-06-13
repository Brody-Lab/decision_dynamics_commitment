function lbxRatInfoCallback

global LBX_RATINFO_CALLBACK;
global FIGURE_NAME;
global IS_STOPPED;

hndlMassMeister = findobj(findall(0), 'Name', FIGURE_NAME);
handles = guihandles(hndlMassMeister(1));

if ~IS_STOPPED
    set(handles.editWeight, 'Enable', 'on');
    setfocus(handles.editWeight);
    
    lbxlist = get(handles.lbxRatInfo, 'String');
    if get(handles.lbxRatInfo, 'Value')==1 && length(lbxlist)>1
        set(handles.lbxRatInfo, 'Value', 2);
    end
end

LBX_RATINFO_CALLBACK = true;

end
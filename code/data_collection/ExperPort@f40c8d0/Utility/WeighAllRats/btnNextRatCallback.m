function btnNextRatCallback

global FIGURE_NAME;

hndlMassMeister = findobj(findall(0), 'Name', FIGURE_NAME);
handles = guihandles(hndlMassMeister(1));

currRatValue = get(handles.lbxRatInfo, 'Value');

lbxlist = get(handles.lbxRatInfo, 'String');
if currRatValue <= length(lbxlist)-1
    set(handles.lbxRatInfo, 'Value', currRatValue + 1);
end

if strcmp(get(handles.btnStart, 'Enable'), 'off') %Meaning the program is monitoring weights
    btnStartCallback;
end

end
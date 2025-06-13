function btnPreviousRatCallback

global FIGURE_NAME;

hndlMassMeister = findobj(findall(0), 'Name', FIGURE_NAME);
handles = guihandles(hndlMassMeister(1));

currRatValue = get(handles.lbxRatInfo, 'Value');

if currRatValue >= 3
    set(handles.lbxRatInfo, 'Value', currRatValue - 1);
end

if strcmp(get(handles.btnStart, 'Enable'), 'off') %Meaning the program is monitoring weights
    %Keep going back until a rat whose mass is yet to be measured is
    %reached
    lbxlist = get(handles.lbxRatInfo, 'String');
    currval = get(handles.lbxRatInfo, 'Value');
    mass_str = regexprep(lbxlist{currval}, '\s', '');
    mass_str = regexprep(mass_str, '[^\|]*\|', '');
    while ~isempty(mass_str) && currval>=3
        set(handles.lbxRatInfo, 'Value', currval - 1);
        currval = get(handles.lbxRatInfo, 'Value');
        mass_str = regexprep(lbxlist{currval}, '\s', '');
        mass_str = regexprep(mass_str, '[^\|]*\|', '');
    end
    btnStartCallback;
end
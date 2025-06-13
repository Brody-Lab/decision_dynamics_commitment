function btnEditCustomSettingsCallback

global FIGURE_NAME;
global EDIT_CUSTOM_SETTINGS_CALLBACK;

EDIT_CUSTOM_SETTINGS_CALLBACK = false;

hndlMassMeister = findobj(findall(0), 'Name', FIGURE_NAME);
handles = guihandles(hndlMassMeister(1));

userinitials = get(handles.editUserInitials, 'String');
if exist([userinitials '_settings.mat'], 'file')
    load([userinitials '_settings.mat']); %Loads RIGORDER_VECTOR
    
    defaultAnswer = num2str(RIGORDER_VECTOR); %#ok<NODEF>
    defaultAnswer = {regexprep(defaultAnswer, '\s+', ',')};
else
    sqlstr = ['SELECT MAX(rig) AS maxrig FROM ratinfo.schedule WHERE date="' datestr(now, 29) '";'];
    data = bdata(sqlstr);
    defaultAnswer = {num2str(1:data.maxrig)};
end

promptstr = 'Enter the rig order for weighing rats, separated by commas (e.g. 1,2,3,4...)';
titlestr = 'Rig Order';
numlines = 1;
options.WindowStyle = 'modal';
isanswervalid = false;
while ~isanswervalid
    isanswervalid = true;
    answer = inputdlg(promptstr, titlestr, numlines, defaultAnswer, options);
    if isempty(answer)
        return;
    else
        answer{1} = regexprep(answer{1}, '\s', '');
        try
            RIGORDER_VECTOR_NEW = eval(['[' answer{1} ']']);
        catch %#ok<CTCH>
            isanswervalid = false;
            waitfor(errordlg('ERROR: Invalid input.', 'Error', 'modal'));
            continue;
        end
    end
end
if ~isequal(RIGORDER_VECTOR_NEW, RIGORDER_VECTOR)
    RIGORDER_VECTOR = RIGORDER_VECTOR_NEW; %#ok<NASGU>
    save([userinitials '_settings.mat'], 'RIGORDER_VECTOR', '-v7');
    refreshLbxRatInfo;
    EDIT_CUSTOM_SETTINGS_CALLBACK = true;
end

end


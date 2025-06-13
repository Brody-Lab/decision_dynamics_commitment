function btnSubmitWeightCallback

global FIGURE_NAME;

%Get the current rat being weighed
hndlMassMeister = findobj(findall(0), 'Name', FIGURE_NAME);
handles = guihandles(hndlMassMeister(1));

lbxlist = get(handles.lbxRatInfo, 'String');
currval = get(handles.lbxRatInfo, 'Value');
rat_str = regexprep(lbxlist{currval}, '\s', '');
rat_str = regexprep(rat_str, '\|.*', '');
mass_str = regexprep(lbxlist{currval}, '\s', '');
mass_str = regexprep(mass_str, '[^\|]*\|', '');


weight_input = str2double(get(handles.editWeight, 'String'));
if isnan(weight_input)
    errordlg('ERROR: Invalid input.', 'Error', 'modal');
elseif currval>=2
    load('ratinfo_temp.mat');
    for ctr = 1:length(ratlist) %#ok<USENS>
        if strcmp(ratlist{ctr}, rat_str) && isempty(mass_str)
            masslist{ctr} = get(handles.editWeight, 'String'); %#ok<AGROW,NASGU>
            save('ratinfo_temp.mat', 'ratlist', 'masslist', 'timeslotlist');
            set(handles.editWeight, 'String', '');
            refreshLbxRatInfo;
            break;
        end
    end
end

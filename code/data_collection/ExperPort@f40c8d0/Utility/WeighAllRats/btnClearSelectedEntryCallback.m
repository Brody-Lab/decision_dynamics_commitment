function btnClearSelectedEntryCallback

global FIGURE_NAME;
global CLEAR_SELECTED_ENTRY_CALLBACK;

CLEAR_SELECTED_ENTRY_CALLBACK = false;

hndlMassMeister = findobj(findall(0), 'Name', FIGURE_NAME);
handles = guihandles(hndlMassMeister(1));

%Get selected rat and mass
lbxlist = get(handles.lbxRatInfo, 'String');
lbxval = get(handles.lbxRatInfo, 'Value');

if lbxval>=2
    lbxlist{lbxval} = regexprep(lbxlist{lbxval}, '\s', '');
    rat_name_str = regexprep(lbxlist{lbxval}, '\|.*', '');
    mass_str = regexprep(lbxlist{lbxval}, '[^\|]*\|', '');
    
    if ~isempty(mass_str)
        mass_str = '';
        load('ratinfo_temp.mat'); %Loads 'RATLIST' 'CAGEMATELIST' 'MASSLIST' 'TIMESLOTLIST' 'ISRECOVERINGLIST' 'ISNEWLIST' 'ISTRAININGLIST'
        for ctr = 1:length(RATLIST) %#ok<USENS>
            if strcmp(RATLIST{ctr}, rat_name_str)
                CLEAR_SELECTED_ENTRY_CALLBACK = true;
                MASSLIST{ctr} = mass_str; %#ok<AGROW,NASGU>
                ISNEWLIST(ctr) = true; %#ok<AGROW,NASGU>
                save('ratinfo_temp.mat', ...
                    'RATLIST', ...
                    'CAGEMATELIST', ...
                    'MASSLIST', ...
                    'TIMESLOTLIST', ...
                    'ISRECOVERINGLIST', ...
                    'ISNEWLIST', ...
                    'ISTRAININGLIST', ...
                    'ISFORCEFREEWATERLIST', ...
                    'ISFORCEDEPWATERLIST', ...
                    '-v7');
                refreshLbxRatInfo;
                break;
            end
        end
    end
end


end
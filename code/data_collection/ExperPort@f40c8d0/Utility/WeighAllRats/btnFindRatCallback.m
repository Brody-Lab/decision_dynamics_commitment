function btnFindRatCallback

%Function to search for the rat entered in the editRatName field, and
%select the appropriate rat.

global FIGURE_NAME;
global IS_STOPPED;
global EXTRA_LIST_ITEMS

hndlMassMeister = findobj(findall(0), 'Name', FIGURE_NAME);
handles = guihandles(hndlMassMeister(1));

ratname_input = get(handles.editRatName, 'String');
set(handles.editRatName, 'String', '');

load('ratinfo_temp.mat'); %Loads RATLIST, MASSLIST, TIMESLOTLIST, ISRECOVERINGLIST, ISNEWLIST

foundrat = false;
for ctr = 1:length(RATLIST) %#ok<USENS>
    
    if strcmpi(ratname_input, RATLIST{ctr})
        foundrat = true;
        if ~isempty(TIMESLOTLIST{ctr}) %#ok<USENS>
            sessionfound = TIMESLOTLIST{ctr}(1);
            set(handles.popupSession, 'Value', sessionfound);
        elseif ~ISTRAININGLIST(ctr) && ISFORCEDEPWATERLIST(ctr)
            sessionfound = []; %#ok<*NASGU>
            set(handles.popupSession, 'Value', find(strcmpi(EXTRA_LIST_ITEMS{1}, get(handles.popupSession, 'String')), 1));
        elseif ISRECOVERINGLIST(ctr) && ISFORCEFREEWATERLIST(ctr)
            sessionfound = [];
            set(handles.popupSession, 'Value', find(strcmpi(EXTRA_LIST_ITEMS{2}, get(handles.popupSession, 'String')), 1));
        elseif ISRECOVERINGLIST(ctr)
            sessionfound = []; %#ok<NASGU>
            set(handles.popupSession, 'Value', find(strcmpi(EXTRA_LIST_ITEMS{3}, get(handles.popupSession, 'String')), 1)); %Recovering rats
        else
            sessionfound = []; %#ok<NASGU>
            set(handles.popupSession, 'Value', find(strcmpi(EXTRA_LIST_ITEMS{4}, get(handles.popupSession, 'String')), 1)); %Unassigned rats
        end
        
        iscomplete = refreshLbxRatInfo; %#ok<NASGU>
        
        %Select the appropriate rat
        lbxList = get(handles.lbxRatInfo, 'String');
        subratlist = lbxList(2:end);
        subratlist = regexprep(subratlist, '\s', '');
        subratlist = regexprep(subratlist, '\|.*', '');
        for ctr2 = 1:length(subratlist)
            if strcmpi(ratname_input, subratlist{ctr2})
                set(handles.lbxRatInfo, 'Value', ctr2+1);
                break;
            end
        end
        
        %Call function callbacks
        if ~IS_STOPPED
            lbxRatInfoCallback;
        end
        
        break;
    end
    
end

if ~foundrat
    msgbox(['Rat ' ratname_input ' not found.'], 'Rat Not Found', 'modal');
end



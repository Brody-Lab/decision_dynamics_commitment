function iscomplete = refreshLbxRatInfo

global FIGURE_NAME;
global IS_STOPPED;

hndlMassMeister = findobj(findall(0), 'Name', FIGURE_NAME);
handles = guihandles(hndlMassMeister(1));

curr_rat_val = get(handles.lbxRatInfo, 'Value');
set(handles.lbxRatInfo, 'Value', 1);

sessionValue = get(handles.popupSession, 'Value');

%get_sublists is the function that populates the listbox
[subratlist, submasslist] = get_sublists(sessionValue);

% Display subratlist and submasslist in lbxRatInfo
formatstring = '%10s | %10s';
lbxRatInfo_str = cell(length(subratlist)+1, 1);
lbxRatInfo_str{1} = sprintf(formatstring, 'Rat Name', 'Mass (grams)');
for ctr = 1:length(subratlist)
    lbxRatInfo_str{ctr+1} = sprintf(formatstring, subratlist{ctr}, submasslist{ctr});
end

%Finally, set the table
set(handles.lbxRatInfo, 'String', lbxRatInfo_str);

if curr_rat_val <= length(lbxRatInfo_str)
    set(handles.lbxRatInfo, 'Value', curr_rat_val);
end
     

%If all rats in the list have been weighed, notify the user:
lbxlist = get(handles.lbxRatInfo, 'String');
mass_str = regexprep(lbxlist, '\s', '');
mass_str = regexprep(mass_str, '[^\|]*\|', '');
foundempty = false;
for ctr = 1:length(mass_str)
    if isempty(mass_str{ctr})
        foundempty = true;
        break;
    end
end
if ~foundempty
    set(handles.textInstructions, 'String', {'All rats in this list'; 'have been weighed.'; 'Try a different session or exit.'});
    set(handles.textInstructions, 'BackgroundColor', 'yellow');
    set(handles.btnStart, 'Enable', 'off');
    set(handles.btnSaveAndExit, 'Enable', 'on');
    set(handles.btnSave, 'Enable', 'on');
    set(handles.btnExitWithoutSaving, 'Enable', 'on');
    %msgbox('All rats in this list have been weighed!', 'Weighing Complete', 'modal');
    iscomplete = true;
else
    if IS_STOPPED
        set(handles.btnStart, 'Enable', 'on');
        set(handles.textInstructions, 'String', {''; 'Select a session and press START, or EXIT'});
        set(handles.textInstructions, 'BackgroundColor', 'yellow');
        set(handles.editWeight, 'Enable', 'off');
    end
    set(handles.btnSaveAndExit, 'Enable', 'on');
    set(handles.btnSave, 'Enable', 'on');
    set(handles.btnExitWithoutSaving, 'Enable', 'on');
    iscomplete = false;
end

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [subratlist, submasslist] = get_sublists(sessionValue)
%This function returns subratlist and submasslist, based on the value
%of sessionValue.
global EXTRA_LIST_ITEMS;
global FIGURE_NAME;

hndl = findobj(findall(0), 'Name', FIGURE_NAME);
handles = guihandles(hndl(1));
sessionlist = get(handles.popupSession, 'String');

maxtimeslot = length(sessionlist) - length(EXTRA_LIST_ITEMS);
load('ratinfo_temp.mat'); %Loads 'RATLIST' 'CAGEMATELIST' 'MASSLIST' 'TIMESLOTLIST' 'ISRECOVERINGLIST' 'ISNEWLIST' 'ISTRAININGLIST'
%RATLIST is distinct
if sessionValue <= maxtimeslot
    
    subratlist = cell(0, 1);
    submasslist = cell(0, 1);
    sublist_ctr = 1;
    for ctr = 1:length(TIMESLOTLIST) %#ok<*USENS>
        if any(TIMESLOTLIST{ctr}==sessionValue)
            %The rat should be added to this list only if it does not
            %already exist in subratlist. This is needed to avoid duplicate
            %entries
            if ~any(strcmp(RATLIST{ctr}, subratlist))
                subratlist{sublist_ctr} = RATLIST{ctr};
                submasslist{sublist_ctr} = MASSLIST{ctr}; %#ok<USENS>
                sublist_ctr = sublist_ctr + 1;
                index = find(strcmp(CAGEMATELIST{ctr}, RATLIST), 1, 'first');
                if ~isempty(CAGEMATELIST{ctr}) && ~strcmp(CAGEMATELIST{ctr}, '') && ~isempty(index) && ~ISTRAININGLIST(index) && ismember(CAGEMATELIST{ctr}, RATLIST)
                    if ~any(strcmp(CAGEMATELIST{ctr}, subratlist))
                        subratlist{sublist_ctr} = CAGEMATELIST{ctr};
                        submasslist{sublist_ctr} = MASSLIST{index};
                        sublist_ctr = sublist_ctr + 1;
                    end
                end
            end
        end
    end
    
    if length(subratlist) >= 1
        [subratlist, indices] = sort(subratlist);
        submasslist = submasslist(indices);
    end
    
    %If a custom settings file is available and the 'Use Custom Settings
    %checkbox is checked, get RIGORDER_VECTOR from the custom settings file
    %and arrange subratlist and submasslist according to that order
    userinitials = get(handles.editUserInitials, 'String');
    checkboxUseCustomSettingsValue = logical(get(handles.checkboxUseCustomSettings, 'Value'));
    if exist([userinitials '_settings.mat'], 'file') && checkboxUseCustomSettingsValue == true
        load([userinitials '_settings.mat']); %Loads RIGORDER_VECTOR
        
        custom_subratlist = cell(length(subratlist), 1);
        custom_submasslist = cell(length(subratlist), 1);
        ctr_skip = 1;
        ctr_custom_subratlist = 1;
        ctr = 1;
        while ctr<=length(RIGORDER_VECTOR)
            sqlstr = ['SELECT DISTINCT ratname FROM ratinfo.schedule ' ...
                'WHERE date="' datestr(now, 29) '" ' ...
                'AND timeslot=' num2str(sessionValue) ' ' ...
                'AND rig=' num2str(RIGORDER_VECTOR(ctr)) ';'];
            data = bdata(sqlstr);
            if ~isempty(data.ratname) && ~isempty(strtrim(data.ratname{1})) && ismember(strtrim(data.ratname{1}), RATLIST)
                custom_subratlist{ctr_custom_subratlist} = data.ratname{1};
                x = find(strcmp(custom_subratlist{ctr_custom_subratlist}, subratlist));
                if ~isempty(x)
                    indices_to_skip(ctr_skip) = x; %#ok<*AGROW>
                    ctr_skip = ctr_skip + 1;
                end
                ratlist_index = find(strcmp(custom_subratlist{ctr_custom_subratlist}, RATLIST), 1);
                custom_submasslist{ctr_custom_subratlist} = MASSLIST{ratlist_index};
                ctr_custom_subratlist = ctr_custom_subratlist + 1;
            end
            ctr = ctr + 1;
        end
        
        for ctr = 1:length(subratlist)
            %if ctr is not in indices_to_skip
            %then custom_subratlist{ctr_custom_subratlist} =
            %subratlist{ctr}, custom_submasslist{ctr_custom_subratlist}
            %= submasslist{ctr}
            if ~ismember(ctr, indices_to_skip)
                custom_subratlist{ctr_custom_subratlist} = subratlist{ctr};
                custom_submasslist{ctr_custom_subratlist} = submasslist{ctr};
                ctr_custom_subratlist = ctr_custom_subratlist + 1;
            end
        end
        subratlist = custom_subratlist;
        submasslist = custom_submasslist;
    end
    
elseif sessionValue == maxtimeslot + find(strcmpi('Non-training, water deprived rats', EXTRA_LIST_ITEMS))
    
    indices = find(~ISTRAININGLIST & ISFORCEDEPWATERLIST);
    if length(indices) >= 1
        subratlist = RATLIST(indices);
        submasslist = MASSLIST(indices);
    else
        subratlist = cell(0, 1);
        submasslist = cell(0, 1);
    end
    
    
elseif sessionValue == maxtimeslot + find(strcmpi('Recovering, free water rats', EXTRA_LIST_ITEMS))
    
    indices = find(ISRECOVERINGLIST & ISFORCEFREEWATERLIST);
    if length(indices) >= 1
        subratlist = RATLIST(indices);
        submasslist = MASSLIST(indices);
    else
        subratlist = cell(0, 1);
        submasslist = cell(0, 1);
    end
    
elseif sessionValue == maxtimeslot + find(strcmpi('Recovering rats', EXTRA_LIST_ITEMS))
    
    sublist_count = length(ISRECOVERINGLIST(ISRECOVERINGLIST == true));
    
    if sublist_count >= 1
        indices = find(ISRECOVERINGLIST==true);
        subratlist = RATLIST(indices);
        submasslist = MASSLIST(indices);
    else
        subratlist = cell(0, 1);
        submasslist = cell(0, 1);
    end
    
    %Sundeep Tuteja, 2010-04-07: If a rat in this list is also present in
    %one of the training session lists, it should not be present in this
    %list
    if ~isempty(subratlist)
        training_session_subratlist = {};
        for ctr = 1:maxtimeslot
            training_session_subratlist = [training_session_subratlist; get_sublists(ctr)];
        end
        training_session_subratlist = unique(training_session_subratlist);

        [dummy, randstring] = fileparts(tempname); clear('dummy');
        for ctr = 1:length(subratlist)
            if ismember(subratlist{ctr}, training_session_subratlist)
                subratlist{ctr} = randstring;
                submasslist{ctr} = randstring;
            end
        end
        subratlist(strcmp(randstring, subratlist)) = [];
        submasslist(strcmp(randstring, submasslist)) = [];
    end
    
    
elseif sessionValue == maxtimeslot + find(strcmpi('Unassigned rats', EXTRA_LIST_ITEMS)) %Rats which did not belong to any particular session for the day
    
    sublist_count = 0;
    for ctr = 1:length(TIMESLOTLIST);
        if isempty(TIMESLOTLIST{ctr})
            sublist_count = sublist_count + 1;
        end
    end
    
    if sublist_count >= 1
        subratlist = cell(sublist_count, 1);
        submasslist = cell(sublist_count, 1);
        sublist_ctr = 1;
        for ctr = 1:length(TIMESLOTLIST)
            if isempty(TIMESLOTLIST{ctr})
                subratlist{sublist_ctr} = RATLIST{ctr};
                submasslist{sublist_ctr} = MASSLIST{ctr};
                sublist_ctr = sublist_ctr + 1;
            end
        end
    else
        subratlist = cell(0, 1);
        submasslist = cell(0, 1);
    end
    
    
elseif sessionValue == maxtimeslot + find(strcmpi('All rats', EXTRA_LIST_ITEMS)) %All rats
    
    subratlist = RATLIST;
    submasslist = MASSLIST;
    
end

subratlist = subratlist(:);
submasslist = submasslist(:);

end

%btnStartCallback: Initial callback function for the start button. After
%the first call, the callback gets replaced by btnStartCallback_update.

function btnStartCallback

%GLOBALS
global FIGURE_NAME;
global SERIAL_OBJ_BALANCE;
global AXIS_HANDLE;
global LAST_KEY_EVENT;
global IS_STOPPED;
global LBX_RATINFO_CALLBACK;
global EDIT_SELECTED_ENTRY_CALLBACK;
global CLEAR_SELECTED_ENTRY_CALLBACK;
global POPUP_SESSION_CALLBACK;
global EDIT_CUSTOM_SETTINGS_CALLBACK;

%Initial values
IS_STOPPED = false;
LBX_RATINFO_CALLBACK = false;
EDIT_SELECTED_ENTRY_CALLBACK = false;
CLEAR_SELECTED_ENTRY_CALLBACK = false;
POPUP_SESSION_CALLBACK = false;
EDIT_CUSTOM_SETTINGS_CALLBACK = false;

%%

try
    
    pause(0.05);
    
    hndlMassMeister = findobj(findall(0), 'Name', FIGURE_NAME);
    handles = guihandles(hndlMassMeister(1));
    
    is_weighing_complete = refreshLbxRatInfo;
    
    function_settasks(handles);
    
    
    
    pause_time = 0.1; %seconds
    settling_time = 0.8; %seconds
    number_of_readings = round(settling_time/pause_time);
    accuracy_threshold = 0.02;
    upper_weight_threshold = 15; %grams
    lower_weight_threshold = 10; %grams
    
    %     refreshLbxRatInfo;
    %     set(handles.btnStart, 'Enable', 'off');
    
    
    %% Step 1: Obtain rat list
    lbxlist = get(handles.lbxRatInfo, 'String');
    subratlist = lbxlist(2:end);
    subratlist = regexprep(subratlist, '\s', '');
    subratlist = regexprep(subratlist, '\|.*', '');
    submasslist = lbxlist(2:end);
    submasslist = regexprep(submasslist, '\s', '');
    submasslist = regexprep(submasslist, '[^\|]*\|', '');
    
    
    %% Step 2: Start Listening for rats
    
    
    
    ctr = get(handles.lbxRatInfo, 'Value') - 1;
    if ctr==0
        ctr=1;
    end
    while ctr <= length(subratlist) && exist('SERIAL_OBJ_BALANCE', 'var')
        
        end_of_list_reached = false; %#ok<NASGU>
        
        if ~IS_STOPPED
            set(handles.lbxRatInfo, 'Value', ctr+1);
            set(handles.textInstructions, 'String', {''; ['Place ' subratlist{ctr} ' on the scale...']});
            set(handles.textInstructions, 'BackgroundColor', 'yellow');
        end
        
        
        %Analyse LAST_KEY_EVENT
        %If LAST_KEY_EVENT is the ENTER KEY: submit the weight and
        %increment the counter
        %If LAST_KEY_EVENT is the up arrow key, decrement the counter
        %If LAST_KEY_EVENT is the down arrow key, increment the counter
        
        
        if isempty(submasslist{ctr}) || LBX_RATINFO_CALLBACK || POPUP_SESSION_CALLBACK || EDIT_CUSTOM_SETTINGS_CALLBACK
            
            LBX_RATINFO_CALLBACK(LBX_RATINFO_CALLBACK == true) = false;
            POPUP_SESSION_CALLBACK(POPUP_SESSION_CALLBACK == true) = false;
            EDIT_CUSTOM_SETTINGS_CALLBACK(EDIT_CUSTOM_SETTINGS_CALLBACK == true) = false;
            
            %             if POPUP_SESSION_CALLBACK
            %                 set(handles.textInstructions, 'String', {''; 'Make sure the scale'; 'is set to zero'; 'and press START'});
            %                 POPUP_SESSION_CALLBACK = false;
            %             elseif ~IS_STOPPED
            %                 set(handles.textInstructions, 'String', {''; ['Place ' subratlist{ctr} ' on the scale...']});
            %                 set(handles.textInstructions, 'BackgroundColor', 'yellow');
            %                 setfocus(handles.editWeight);
            %                 set(handles.lbxRatInfo, 'Value', ctr+1);
            %             end
            
            
            is_weight_obtained = false;
            weight_index = 1;
            weight = zeros(30, 1);
            try
                assert(number_of_readings < length(weight));
            catch %#ok<CTCH>
            end
            offset = 0;
            while ~is_weight_obtained
                
                while IS_STOPPED
                    pause(0.05);
                    %fprintf('\nWait state 1');
                    
                    set(handles.editWeight, 'Enable', 'off');
                    
                    if EDIT_SELECTED_ENTRY_CALLBACK || CLEAR_SELECTED_ENTRY_CALLBACK || POPUP_SESSION_CALLBACK || EDIT_CUSTOM_SETTINGS_CALLBACK
                        lbxlist = get(handles.lbxRatInfo, 'String');
                        subratlist = lbxlist(2:end);
                        subratlist = regexprep(subratlist, '\s', '');
                        subratlist = regexprep(subratlist, '\|.*', '');
                        submasslist = lbxlist(2:end);
                        submasslist = regexprep(submasslist, '\s', '');
                        submasslist = regexprep(submasslist, '[^\|]*\|', '');
                        
                        EDIT_SELECTED_ENTRY_CALLBACK(EDIT_SELECTED_ENTRY_CALLBACK == true) = false;
                        CLEAR_SELECTED_ENTRY_CALLBACK(CLEAR_SELECTED_ENTRY_CALLBACK == true) = false;
                        
                        %                         if POPUP_SESSION_CALLBACK
                        %                             ctr = get(handles.lbxRatInfo, 'Value') - 1;
                        %                             if ctr==0
                        %                                 ctr=1;
                        %                             end
                        %                         end
                    end
                    
                    if POPUP_SESSION_CALLBACK || EDIT_CUSTOM_SETTINGS_CALLBACK
                        %                         lbxlist = get(handles.lbxRatInfo, 'String');
                        %                         subratlist = lbxlist(2:end);
                        %                         subratlist = regexprep(subratlist, '\s', '');
                        %                         subratlist = regexprep(subratlist, '\|.*', '');
                        %                         submasslist = lbxlist(2:end);
                        %                         submasslist = regexprep(submasslist, '\s', '');
                        %                         submasslist = regexprep(submasslist, '[^\|]*\|', '');
                        %                         ctr = get(handles.lbxRatInfo, 'Value') - 1;
                        %                         if ctr==0
                        %                             ctr=1;
                        %                         end
                        break;
                    end
                    
                    if LBX_RATINFO_CALLBACK
                        break;
                    end
                    
                    if ~IS_STOPPED
                        function_settasks(handles);
                        ctr = get(handles.lbxRatInfo, 'Value') - 1;
                        if ctr==0
                            ctr=1;
                        end
                        
                        %Keep increasing ctr until a value is reached for
                        %which the mass is not available
                        foundval = false;
                        for ctr_skipping = ctr:length(subratlist)
                            if isempty(submasslist{ctr_skipping})
                                set(handles.lbxRatInfo, 'Value', ctr_skipping+1);
                                ctr = ctr_skipping;
                                foundval = true;
                                break;
                            end
                        end
                        if foundval
                            set(handles.textInstructions, 'String', {''; ['Place ' subratlist{ctr} ' on the scale...']});
                            set(handles.textInstructions, 'BackgroundColor', 'yellow');
                        end
                    end
                end
                
                
                %While not stopped
                if LBX_RATINFO_CALLBACK || POPUP_SESSION_CALLBACK || EDIT_CUSTOM_SETTINGS_CALLBACK
                    lbxlist = get(handles.lbxRatInfo, 'String');
                    subratlist = lbxlist(2:end);
                    subratlist = regexprep(subratlist, '\s', '');
                    subratlist = regexprep(subratlist, '\|.*', '');
                    submasslist = lbxlist(2:end);
                    submasslist = regexprep(submasslist, '\s', '');
                    submasslist = regexprep(submasslist, '[^\|]*\|', '');
                    ctr = get(handles.lbxRatInfo, 'Value') - 1;
                    if ctr==0
                        ctr=1;
                    end
                    if ~IS_STOPPED
                        set(handles.textInstructions, 'String', {''; ['Place ' subratlist{ctr} ' on the scale...']});
                        set(handles.textInstructions, 'BackgroundColor', 'yellow');
                        set(handles.editWeight, 'Enable', 'on');
                    end
                    break;
                end
                
                
                if EDIT_SELECTED_ENTRY_CALLBACK || CLEAR_SELECTED_ENTRY_CALLBACK
                    lbxlist = get(handles.lbxRatInfo, 'String');
                    subratlist = lbxlist(2:end);
                    subratlist = regexprep(subratlist, '\s', '');
                    subratlist = regexprep(subratlist, '\|.*', '');
                    submasslist = lbxlist(2:end);
                    submasslist = regexprep(submasslist, '\s', '');
                    submasslist = regexprep(submasslist, '[^\|]*\|', '');
                    
                    EDIT_SELECTED_ENTRY_CALLBACK(EDIT_SELECTED_ENTRY_CALLBACK==true) = false;
                    CLEAR_SELECTED_ENTRY_CALLBACK(CLEAR_SELECTED_ENTRY_CALLBACK==true) = false;
                end
                
                
                
                
                %global LAST_KEY_EVENT; %#ok<TLEV>
                
                %If LAST_KEY_EVENT is the return key, try to submit the
                %weight entered in the edit field
                try
                    switch LAST_KEY_EVENT.Key
                        case 'return'
                            LAST_KEY_EVENT.Key = 'CLEARED';
                            weightval_str = get(handles.editWeight, 'String');
                            weightval = str2double(weightval_str);
                            if ~isnan(weightval)
                                is_weight_obtained = true;
                                weight_obtained = weightval;
                            end
                            
                        case 'downarrow' %Next Rat
                            
                            LAST_KEY_EVENT.Key = 'CLEARED';
                            currRatValue = get(handles.lbxRatInfo, 'Value');
                            %difference = 0;
                            if currRatValue < length(lbxlist)
                                %Find the next rat that needs weighing
                                %for ctr_downarrow = ctr+1:length(submasslist)
                                %if isempty(submasslist{ctr_downarrow})
                                %difference = ctr_downarrow - ctr;
                                set(handles.lbxRatInfo, 'Value', currRatValue+1);
                                %break;
                                %end
                                %end
                                
                                ctr = ctr + 1;
                                set(handles.textInstructions, 'String', {''; ['Place ' subratlist{ctr} ' on the scale...']});
                                set(handles.textInstructions, 'BackgroundColor', 'yellow');
                                setfocus(handles.editWeight);
                                continue;
                            end
                            
                            %if ~isequal(difference, 0)
                            
                            %end
                            
                        case 'uparrow'
                            
                            LAST_KEY_EVENT.Key = 'CLEARED';
                            CurrentRatValue = get(handles.lbxRatInfo, 'Value');
                            
                            %difference = 0;
                            if CurrentRatValue >= 3
                                %for ctr_uparrow = ctr-1:-1:1
                                %if isempty(submasslist{ctr_uparrow})
                                %difference = ctr - ctr_uparrow;
                                set(handles.lbxRatInfo, 'Value', CurrentRatValue-1);
                                %break;
                                %end
                                %end
                                
                                ctr = ctr - 1;
                                set(handles.textInstructions, 'String', {''; ['Place ' subratlist{ctr} ' on the scale...']});
                                set(handles.textInstructions, 'BackgroundColor', 'yellow');
                                setfocus(handles.editWeight);
                                continue;
                            end
                            
                            %if ~isequal(difference, 0)
                            
                            %end
                            
                        otherwise
                            %Do nothing
                    end
                catch %#ok<CTCH>
                    err = lasterror; %#ok<LERR,NASGU>
                    keyboard;
                end
                
                
                
                if ~is_weight_obtained
                    pause(pause_time);
                    fprintf(SERIAL_OBJ_BALANCE, 'P');
                    if weight_index > length(weight)
                        weight = [weight(2:end); 0];
                        weight_index = weight_index - 1;
                        offset = offset + 1;
                    end
                    if weight_index >= 2
                        try
                            if exist('AXIS_HANDLE', 'var')
                                plot(AXIS_HANDLE, (1:weight_index-1)+offset, weight(1:weight_index-1));
                                xlabel(AXIS_HANDLE, 'Sample Number');
                                ylabel(AXIS_HANDLE, 'Weight (grams)');
                                %grid(AXIS_HANDLE, 'on');
                            end
                        catch %#ok<CTCH>
                        end
                    end
                    weight_string = fscanf(SERIAL_OBJ_BALANCE);
                    weight_string = regexprep(weight_string, '\D', '');
                    try
                        weight(weight_index) = eval(weight_string);
                    catch %#ok<CTCH>
                        %Saving data as a precaution, without user
                        %intervention
                        btnSaveCallback;
                        set(handles.textInstructions, 'BackgroundColor', 'red');
                        set(handles.textInstructions, 'String', 'ERROR READING DEVICE. THE DATA HAS BEEN SAVED AS A PRECAUTION.');
                        set(handles.btnSaveAndExit, 'Enable', 'on');
                        set(handles.btnSave, 'Enable', 'on');
                        set(handles.btnExitWithoutSaving, 'Enable', 'on');
                    end
                    if weight_index > number_of_readings
                        weight_vec_considered = weight(weight_index - number_of_readings:weight_index);
                        if max(abs(weight_vec_considered - mean(weight_vec_considered))) < accuracy_threshold*mean(weight_vec_considered) && mean(weight_vec_considered)>upper_weight_threshold
                            is_weight_obtained = true;
                            weight_obtained = mean(weight_vec_considered);
                            set(handles.textInstructions, 'String', {''; 'OK!'});
                            continue;
                        else
                            weight_index = weight_index + 1;
                        end
                    else
                        weight_index = weight_index + 1;
                    end
                end
            end
            
            if LBX_RATINFO_CALLBACK || POPUP_SESSION_CALLBACK
                lbxlist = get(handles.lbxRatInfo, 'String');
                subratlist = lbxlist(2:end);
                subratlist = regexprep(subratlist, '\s', '');
                subratlist = regexprep(subratlist, '\|.*', '');
                submasslist = lbxlist(2:end);
                submasslist = regexprep(submasslist, '\s', '');
                submasslist = regexprep(submasslist, '[^\|]*\|', '');
                ctr = get(handles.lbxRatInfo, 'Value') - 1;
                if ctr==0
                    ctr=1;
                end
                continue;
            end
            
            
            
            if is_weight_obtained
                submasslist{ctr} = num2str(weight_obtained);
                set(handles.editWeight, 'String', num2str(weight_obtained));
                
                savedata(subratlist{ctr}, submasslist{ctr});
                is_weighing_complete = refreshLbxRatInfo;
                
                set(handles.textInstructions', 'String', {''; ['Remove ' subratlist{ctr} ' from the scale...']});
                set(handles.textInstructions, 'BackgroundColor', 'green');
                
                %Disable most GUI elements until the rat has been removed
                %from the scale
                % set(handles.lbxRatInfo, 'Enable', 'inactive');
                % set(handles.btnPreviousRat, 'Enable', 'off');
                % set(handles.btnNextRat, 'Enable', 'off');
                
                
                is_empty = false;
                weight_index = 1;
                weight = zeros(30, 1);
                while ~is_empty
                    pause(pause_time);
                    fprintf(SERIAL_OBJ_BALANCE, 'P');
                    if weight_index > length(weight)
                        weight = [weight(2:end); 0];
                        weight_index = weight_index - 1;
                    end
                    weight_string = fscanf(SERIAL_OBJ_BALANCE);
                    weight_string = regexprep(weight_string, '\D', '');
                    try
                        weight(weight_index) = eval(weight_string);
                    catch %#ok<CTCH>
                        set(handles.textInstructions, 'BackgroundColor', 'red');
                        set(handles.textInstructions, 'String', 'ERROR READING DEVICE, PLEASE HIT SAVE AND EXIT AND RESTART THE APPLICATION.');
                        set(handles.btnSaveAndExit, 'Enable', 'on');
                        set(handles.btnSave, 'Enable', 'on');
                        set(handles.btnExitWithoutSaving, 'Enable', 'on');
                    end
                    if weight_index > number_of_readings
                        weight_vec_considered = weight(weight_index - number_of_readings:weight_index);
                        set(handles.editWeight, 'String', num2str(max(weight_vec_considered)));
                        if max(weight_vec_considered)<lower_weight_threshold
                            set(handles.editWeight, 'String', '');
                            set(handles.textInstructions, 'String', {''; 'OK!'; [num2str(ctr) '/' num2str(length(subratlist))]});
                            fprintf(SERIAL_OBJ_BALANCE, 'T');
                            is_empty = true;
                            continue;
                        else
                            weight_index = weight_index + 1;
                        end
                    else
                        weight_index = weight_index + 1;
                    end
                    
                end
            end
            
        end
        
        ctr = ctr + 1;
        
        if ctr > length(subratlist)
            
            end_of_list_reached = true; %#ok<NASGU>
            
            set(handles.textInstructions, 'String', {''; 'End of current list reached.'});
            if ~is_weighing_complete
                set(handles.btnStart, 'Enable', 'on');
            end
            
            pause(2.0);
            
            set(handles.btnEditSelectedEntry, 'Enable', 'on');
            set(handles.checkboxUseCustomSettings, 'Enable', 'on');
            
            set(handles.popupSession, 'Enable', 'on');
            set(handles.btnStop, 'Enable', 'off');
            set(handles.textInstructions, 'String', {''; 'Select a session and press START, or exit.'});
            set(handles.textInstructions, 'BackgroundColor', 'yellow');
            set(handles.lbxRatInfo, 'Enable', 'on');
            set(handles.btnClearSelectedEntry, 'Enable', 'on');
            set(handles.btnEditCustomSettings, 'Enable', 'on');
            set(handles.btnSetScaleToZero, 'Enable', 'on');
            
            IS_STOPPED = true;
            
            while IS_STOPPED
                pause(0.05);
                %fprintf('\nWait state');
                
                set(handles.editWeight, 'Enable', 'off');
                
                if EDIT_SELECTED_ENTRY_CALLBACK || CLEAR_SELECTED_ENTRY_CALLBACK || POPUP_SESSION_CALLBACK || EDIT_CUSTOM_SETTINGS_CALLBACK
                    lbxlist = get(handles.lbxRatInfo, 'String');
                    subratlist = lbxlist(2:end);
                    subratlist = regexprep(subratlist, '\s', '');
                    subratlist = regexprep(subratlist, '\|.*', '');
                    submasslist = lbxlist(2:end);
                    submasslist = regexprep(submasslist, '\s', '');
                    submasslist = regexprep(submasslist, '[^\|]*\|', '');
                    
                    EDIT_SELECTED_ENTRY_CALLBACK(EDIT_SELECTED_ENTRY_CALLBACK == true) = false;
                    CLEAR_SELECTED_ENTRY_CALLBACK(CLEAR_SELECTED_ENTRY_CALLBACK == true) = false;
                    
                    if POPUP_SESSION_CALLBACK || EDIT_CUSTOM_SETTINGS_CALLBACK
                        ctr = get(handles.lbxRatInfo, 'Value') - 1;
                        if ctr==0
                            ctr=1;
                        end
                    end
                end
                
                if ~IS_STOPPED
                    function_settasks(handles);
                    ctr = get(handles.lbxRatInfo, 'Value') - 1;
                    if ctr==0
                        ctr=1;
                    end
                    
                    %Keep increasing ctr until a value is reached for
                    %which the mass is not available
                    foundval = false;
                    for ctr_skipping = ctr:length(subratlist)
                        if isempty(submasslist{ctr_skipping})
                            set(handles.lbxRatInfo, 'Value', ctr_skipping+1);
                            ctr = ctr_skipping;
                            foundval = true;
                            break;
                        end
                    end
                    if foundval
                        set(handles.textInstructions, 'String', {''; ['Place ' subratlist{ctr} ' on the scale...']});
                        set(handles.textInstructions, 'BackgroundColor', 'yellow');
                    end
                end
            end
        end
        
    end
    
catch %#ok<CTCH>
    %It looks like I keep getting 'Error using set, invalid handle object',
    %even though the handle objects are very much valid, and being set
    %correctly. Therefore, all exception handling is done in the try-catch
    %section itself.
end

end

%%

function savedata(ratname, ratmass)

load('ratinfo_temp.mat');  %Loads 'RATLIST' 'CAGEMATELIST' 'MASSLIST' 'TIMESLOTLIST' 'ISRECOVERINGLIST' 'ISNEWLIST' 'ISTRAININGLIST'

for ctr = 1:length(RATLIST) %#ok<USENS>
    if strcmp(ratname, RATLIST{ctr})
        if ~strcmp(MASSLIST{ctr}, ratmass)
            MASSLIST{ctr} = ratmass; %#ok<AGROW>
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
        end
    end
end
end



%% function function_settasks
function function_settasks(handles)

set(handles.btnStop, 'Enable', 'on');
set(handles.btnStart, 'Enable', 'off');
set(handles.btnSetScaleToZero, 'Enable', 'off');
set(handles.btnSaveAndExit, 'Enable', 'off');
set(handles.btnSave, 'Enable', 'off');
set(handles.btnExitWithoutSaving, 'Enable', 'off');
%set(handles.popupSession, 'Enable', 'off');
set(handles.checkboxUseCustomSettings, 'Enable', 'off');
set(handles.btnEditCustomSettings, 'Enable', 'off');
set(handles.editWeight, 'Enable', 'on');

set(handles.btnStart, 'Callback', 'btnStartCallback_update');

setfocus(handles.editWeight);

end

%WEIGHALLRATS(ACTION, VARARGIN):
%   Application for the automated weighing of rats.
%
%   11/14/2009 - First release.
%
%   WeighAllRats('init'): To startup the application
%
%   Call flush; newstartup; from ExperPort before running this function.

function WeighAllRats(action, varargin)
            

%% Declaring globals
global FIGURE_NAME;
global SERIAL_OBJ_BALANCE;
global APPLICATION_NAME;
global AXIS_HANDLE;
global LAST_KEY_EVENT;
global IS_STOPPED;
global EDIT_CUSTOM_SETTINGS_CALLBACK;
global EXTRA_LIST_ITEMS;

%% Setting up connection to the MySQL database
try
    mym('close');
catch %#ok<CTCH>
end
bdata('connect');

%% Enter the tech's initials
promptstr = 'Enter your initials:';
titlestr = 'Initials';
numlines = 1;
defaultanswer = {''};
options.WindowStyle = 'modal';
answer = {''};
while isempty(answer{1})
    answer = inputdlg(promptstr, titlestr, numlines, defaultanswer, options);
    if isempty(answer)
        return;
    else
        answer{1} = regexprep(answer{1}, '\s', '');
        if isempty(answer{1})
            waitfor(errordlg('ERROR: You must enter your initials.', 'Error', 'modal'));
        end
    end
end
userinitials = upper(answer{1});


%% Allow the user to enter the rig order in which he/she wants the rats
if ~exist([userinitials '_settings.mat'], 'file')
    promptstr = 'Enter the rig order for weighing rats, separated by commas (e.g. 1,2,3,4...)';
    titlestr = 'Rig Order';
    numlines = 1;
    %GET MAX RIGID
    sqlstr = ['SELECT MAX(rig) AS maxrig FROM ratinfo.schedule WHERE date="' datestr(now, 29) '";'];
    data = bdata(sqlstr);
    defaultanswer = {num2str(1:data.maxrig)};
    defaultanswer = regexprep(defaultanswer, '\s+', ',');
    options.WindowStyle = 'modal';
    isanswervalid = false;
    while ~isanswervalid
        isanswervalid = true;
        answer = inputdlg(promptstr, titlestr, numlines, defaultanswer, options);
        if isempty(answer)
            return;
        else
            answer{1} = regexprep(answer{1}, '\s', '');
            try
                RIGORDER_VECTOR = eval(['[' answer{1} ']']); %#ok<NASGU>
            catch %#ok<CTCH>
                isanswervalid = false;
                waitfor(errordlg('ERROR: Invalid input.', 'Error', 'modal'));
                continue;
            end
        end
    end
    save([userinitials '_settings.mat'], 'RIGORDER_VECTOR', '-v7');
end


%% Initialize LAST_KEY_EVENT, which monitors keystrokes while the GUI is%running
LAST_KEY_EVENT = struct([]);
LAST_KEY_EVENT(1).Character = ' ';
LAST_KEY_EVENT(1).Modifier = cell(1,0);
LAST_KEY_EVENT(1).Key = 'Nothing';

%Initialize FIGURE_NAME and APPLICATION_NAME
FIGURE_NAME = 'WEIGH_ALL_RATS';
APPLICATION_NAME = mfilename;
IS_STOPPED = true;


%% 
%Get RATLIST, MASSLIST, TIMESLOTLIST, and generate ISNEWLIST, store in a
%MAT file temporarily.

[RATLIST CAGEMATELIST ISRECOVERINGLIST ISFORCEFREEWATERLIST ISFORCEDEPWATERLIST] =...
    bdata('select ratname, cagemate, recovering, forceFreeWater, forceDepWater from ratinfo.rats where extant=1');
%sqlstr = 'SELECT DISTINCT ratname, cagemate FROM ratinfo.rats WHERE extant=1 ORDER BY ratname;';
%data = mym(bdata, sqlstr);
%RATLIST = data.ratname;
%CAGEMATELIST = data.cagemate;
for ctr = 1:length(CAGEMATELIST)
    CAGEMATELIST{ctr} = strtrim(CAGEMATELIST{ctr});
    if strcmpi(strtrim(CAGEMATELIST{ctr}), '0') || isempty(strtrim(CAGEMATELIST{ctr}))
        CAGEMATELIST{ctr} = '';
    end
end
MASSLIST = cell(length(RATLIST), 1);
TIMESLOTLIST = cell(length(RATLIST), 1);
%ISRECOVERINGLIST = false(length(RATLIST), 1);
ISNEWLIST = false(length(RATLIST), 1); %#ok<NASGU>
ISTRAININGLIST = false(length(RATLIST), 1);
%ISFORCEFREEWATERLIST = false(length(RATLIST), 1);
%ISFORCEDEPWATERLIST = false(length(RATLIST), 1);

%Calls to bdata made more efficient by Chuck 7-23-2010
[ratmasslist ratmass] = bdata(['select ratname, mass from ratinfo.mass where date="',datestr(now,29),'"']);
[ratschedlist timeslot] = bdata(['select ratname, timeslot from ratinfo.schedule where date="',datestr(now,29),'"']);

for ctr = 1:length(RATLIST)
    temp = strcmp(ratmasslist,RATLIST{ctr});
    if sum(temp) == 1; MASSLIST{ctr} = num2str(ratmass(temp == 1));
    else               MASSLIST{ctr} = '';
    end
    
    temp = strcmp(ratschedlist,RATLIST{ctr});
    if sum(temp) == 1; TIMESLOTLIST{ctr} = timeslot(temp == 1);
                       ISTRAININGLIST(ctr) = true;
    else               TIMESLOTLIST{ctr} = [];
                       ISTRAININGLIST(ctr) = false;
    end
    
    if ISFORCEDEPWATERLIST(ctr) ~= 0
        if isempty(TIMESLOTLIST{ctr}) || ISFORCEDEPWATERLIST(ctr) > max(TIMESLOTLIST{ctr})
            TIMESLOTLIST{ctr}(end+1) = ISFORCEDEPWATERLIST(ctr);
            TIMESLOTLIST{ctr} = unique(TIMESLOTLIST{ctr});
        end
    end
end
ISFORCEDEPWATERLIST = logical(ISFORCEDEPWATERLIST); %#ok<NASGU>


% for ctr = 1:length(RATLIST)
%     sqlstr = ['SELECT DISTINCT mass FROM ratinfo.mass WHERE ratname="' RATLIST{ctr} '" AND date="' datestr(now, 29) '";'];
%     data = mym(bdata, sqlstr);
%     if ~isempty(data.mass)
%         MASSLIST{ctr} = num2str(data.mass(1));
%     else
%         MASSLIST{ctr} = '';
%     end
%     sqlstr = ['SELECT DISTINCT timeslot FROM ratinfo.schedule WHERE ratname="' RATLIST{ctr} '" ' ...
%         'AND date="' datestr(now, 29) '";'];
%     data = mym(bdata, sqlstr);
%     if ~isempty(data.timeslot)
%         TIMESLOTLIST{ctr} = data.timeslot;
%     else
%         TIMESLOTLIST{ctr} = [];
%     end
%     sqlstr = ['SELECT DISTINCT recovering FROM ratinfo.rats WHERE ratname="' RATLIST{ctr} '" '];
%     data = mym(bdata, sqlstr);
%     if ~isempty(data.recovering)
%         ISRECOVERINGLIST(ctr) = logical(data.recovering);
%     else
%         ISRECOVERINGLIST(ctr) = false;
%     end
%     %sqlstr = ['SELECT DISTINCT training FROM ratinfo.rats WHERE ratname="' RATLIST{ctr} '" '];
%     %data = mym(bdata, sqlstr);
%     %if ~isempty(data.training)
%     %    ISTRAININGLIST(ctr) = logical(data.training);
%     %else
%     %    ISTRAININGLIST(ctr) = false;
%     %end
%     %Sundeep Tuteja - 2010-03-25: It looks like the training flag is being
%     %ignored by everyone, when in Rome, do as Romans do.
%     sqlstr = ['SELECT DISTINCT ratname FROM ratinfo.schedule WHERE ratname="' RATLIST{ctr} '" AND date="' datestr(now, 'yyyy-mm-dd') '";'];
%     data = mym(bdata, sqlstr);
%     if ~isempty(data.ratname)
%         ISTRAININGLIST(ctr) = true;
%     else
%         ISTRAININGLIST(ctr) = false;
%     end
%     sqlstr = ['SELECT DISTINCT forceFreeWater FROM ratinfo.rats WHERE ratname="' RATLIST{ctr} '" '];
%     data = mym(bdata, sqlstr);
%     if ~isempty(data.forceFreeWater)
%         ISFORCEFREEWATERLIST(ctr) = logical(data.forceFreeWater);
%     else
%         ISFORCEFREEWATERLIST(ctr) = false;
%     end
%     sqlstr = ['SELECT DISTINCT forceDepWater FROM ratinfo.rats WHERE ratname="' RATLIST{ctr} '" '];
%     data = mym(bdata, sqlstr);
%     if ~isempty(data.forceDepWater)
%         ISFORCEDEPWATERLIST(ctr) = logical(data.forceDepWater);
%         %Sundeep Tuteja: 2010-03-31, Hack: adding this session explicitly
%         %to TIMESLOTLIST{ctr} so that it appears in the specified session
%         %as well.
%         %Sundeep Tuteja: 2010-04-07: We add this session to
%         %TIMESLOTLIST{ctr} only if data.forceDepWater >
%         %max(TIMESLOTLIST{ctr})
%         if ISFORCEDEPWATERLIST(ctr) && (isempty(TIMESLOTLIST{ctr}) || data.forceDepWater > max(TIMESLOTLIST{ctr}))
%             TIMESLOTLIST{ctr}(end+1) = data.forceDepWater;
%             TIMESLOTLIST{ctr} = unique(TIMESLOTLIST{ctr});
%         end
%     else
%         ISFORCEDEPWATERLIST(ctr) = false;
%     end
% end

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

%% INIT
hndlMassMeister = openfig([FIGURE_NAME '.fig'], 'reuse');
handles = guihandles(hndlMassMeister);
AXIS_HANDLE = handles.axesScalePlot;
xlabel(AXIS_HANDLE, 'Sample Number');
ylabel(AXIS_HANDLE, 'Weight (grams)');

sessionlist = get(handles.popupSession, 'String');
set(handles.popupSession, 'Value', length(sessionlist));
set(handles.editUserInitials, 'String', userinitials);

sqlstr = ['SELECT MAX(timeslot) AS maxtimeslot FROM ratinfo.schedule WHERE date="' datestr(now, 29) '";'];
data = bdata(sqlstr);

EXTRA_LIST_ITEMS = {'Non-training, water deprived rats', 'Recovering, free water rats', 'Recovering rats', 'Unassigned rats', 'All rats'};

sessionlist = cell(data.maxtimeslot(1)+length(EXTRA_LIST_ITEMS), 1);
for ctr = 1:length(sessionlist)-length(EXTRA_LIST_ITEMS)
    sessionlist{ctr} = ['Session ' num2str(ctr)];
end
ctr2 = 1;
for ctr = length(EXTRA_LIST_ITEMS)-1:-1:0
    sessionlist{length(sessionlist)-ctr} = EXTRA_LIST_ITEMS{ctr2};
    ctr2 = ctr2 + 1;
end
set(handles.popupSession, 'String', sessionlist);
set(handles.popupSession, 'Value', 1);


%% Close all existing open serial objects
objlist = instrfind;
for ctr = 1:length(objlist)
    try
        fclose(objlist(ctr));
    catch %#ok<CTCH>
    end
end

%% Prompt the user to change the COM port for the balance, if necessary.
[status, result] = system(['devcon_' computer '.exe listclass ports']);
number_of_com_ports = length(regexp(result, 'COM\d+'));
com_port_list = cell(number_of_com_ports, 1);
ctr_portnum = 1;
ctr = 1;
while ctr <= number_of_com_ports
    if ~isempty(strfind(result, ['COM' num2str(ctr_portnum)]))
        com_port_list{ctr} = ['COM' num2str(ctr_portnum)];
        ctr = ctr + 1;
    end
    ctr_portnum = ctr_portnum + 1;
end
answer = listdlg('PromptString', {'Select the COM port the balance'; 'is connected to:'}, ...
    'SelectionMode', 'single', ...
    'ListString', com_port_list);
if ~isempty(answer)
    balance_port = com_port_list{answer};
else
    delete(hndlMassMeister(1));
    try
        delete('ratinfo_temp.mat');
    catch %#ok<CTCH>
    end
    return;
end
found_serial_obj = false;
for ctr = 1:length(objlist)
    if strfind(objlist(ctr).Name, balance_port)
        found_serial_obj = true;
        SERIAL_OBJ_BALANCE = objlist(ctr);
        break;
    end
end
if ~found_serial_obj
    SERIAL_OBJ_BALANCE = serial(balance_port);
end


%% Probe for weighing scale and create SERIAL_OBJ_BALANCE. If an error is
% encountered, close SERIAL_OBJ_BALANCE if possible.
try
    set(SERIAL_OBJ_BALANCE, 'Terminator', 'CR');
    fopen(SERIAL_OBJ_BALANCE);
    waitfor(msgbox('Please make sure the weighing scale has nothing on it...', 'Message', 'modal'));
    fprintf(SERIAL_OBJ_BALANCE, 'T');
catch %#ok<CTCH>
    err = lasterror; %#ok<LERR>
    try
        fclose(SERIAL_OBJ_BALANCE);
    catch %#ok<CTCH>
    end
    rethrow(err);
end


%% Set callbacks
set(handles.btnSetScaleToZero, 'Callback', 'btnSetScaleToZeroCallback');
set(handles.btnStart, 'Callback', 'btnStartCallback');
set(handles.btnStop, 'Callback', 'btnStopCallback');
set(handles.btnSaveAndExit, 'Callback', 'btnSaveAndExitCallback');
set(handles.btnSave, 'Callback', 'btnSaveCallback');
set(handles.btnExitWithoutSaving, 'Callback', 'btnExitWithoutSavingCallback');
set(handles.btnHelp, 'Callback', 'btnHelpCallback');
set(handles.btnEditSelectedEntry, 'Callback', 'btnEditSelectedEntryCallback');
set(handles.popupSession, 'Callback', 'popupSessionCallback');
set(handles.lbxRatInfo, 'Callback', 'lbxRatInfoCallback');
set(handles.btnClearSelectedEntry, 'Callback', 'btnClearSelectedEntryCallback');
set(handles.checkboxUseCustomSettings, 'Callback', 'checkboxUseCustomSettingsCallback');
set(handles.btnEditCustomSettings, 'Callback', 'btnEditCustomSettingsCallback');
set(handles.editWeight, 'Enable', 'off');
set(handles.btnFindRat, 'Callback', 'btnFindRatCallback');


%Disable selected buttons
set(handles.btnStop, 'Enable', 'off');


%Setting instruction for the user
instruction_str = {''; 'Make sure the scale is set to zero.'; 'Select a session and press START.'};
set(handles.textInstructions, 'String', instruction_str);
set(handles.textInstructions, 'BackgroundColor', 'yellow');

%Refresh the rat list
refreshLbxRatInfo;


end
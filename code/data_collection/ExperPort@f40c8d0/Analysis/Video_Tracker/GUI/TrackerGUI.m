function varargout = TrackerGUI(varargin)
% TRACKERGUI M-file for TrackerGUI.fig
%      TRACKERGUI, by itself, creates a new TRACKERGUI or raises the existing
%      singleton*.
%
%      H = TRACKERGUI returns the handle to a new TRACKERGUI or the handle to
%      the existing singleton*.
%
%      TRACKERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACKERGUI.M with the given input arguments.
%
%      TRACKERGUI('Property','Value',...) creates a new TRACKERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TrackerGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TrackerGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TrackerGUI

% Last Modified by GUIDE v2.5 19-Jul-2008 15:03:04

%% initialization
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TrackerGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @TrackerGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before TrackerGUI is made visible.
function TrackerGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TrackerGUI (see VARARGIN)

% Choose default command line output for TrackerGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TrackerGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TrackerGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


%% framslider
% --- Executes on slider movement.
function frameslider_Callback(hObject, eventdata, handles)
set(handles.frameindex, 'String', num2str(round(get(hObject, 'Value'))));
try
    DrawFrames(handles.axes1, handles);
    UpdateProgressplot(handles.progressplot, handles);
end

% --- Executes during object creation, after setting all properties.
function frameslider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



%% slidercntrl
% --- Executes on selection change in slidercntrl.
function slidercntrl_Callback(hObject, eventdata, handles)
a = get(hObject, 'Value');
switch a,
    case 1,
        set(handles.frameslider, 'SliderStep', [0.001 0.1]);
    case 2,
        set(handles.frameslider, 'SliderStep', [0.005 0.1]);
    case 3,
        set(handles.frameslider, 'SliderStep', [0.01 0.1]);
end;
        


% --- Executes during object creation, after setting all properties.
function slidercntrl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slidercntrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'Fine',  'Medium', 'Coarse'});



%% frameindex
function frameindex_Callback(hObject, eventdata, handles)
entry = get(hObject, 'String');
index = str2num(entry);
if ~isempty(index) && isreal(index) && (index > 0), 
    DrawFrames(handles.axes1, handles);
    UpdateProgressplot(handles.progressplot, handles);
else
    set(hObject, 'String', '1');
end;

% --- Executes during object creation, after setting all properties.
function frameindex_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% rewbutton
% --- Executes on button press in rewbutton.
function rewbutton_Callback(hObject, eventdata, handles)
ind = str2num(get(handles.frameindex, 'String'));
try    
    if ind > 1,
        ind = ind - 1;
        set(handles.frameindex, 'String', num2str(ind));
        DrawFrames(handles.axes1, handles);
        UpdateProgressplot(handles.progressplot, handles);
    end;
end

% --- Executes during object creation, after setting all properties.
function rewbutton_CreateFcn(hObject, eventdata, handles)
Main_Code_Directory = bSettings('get', 'GENERAL', 'Main_Code_Directory');
load([Main_Code_Directory '/Analysis/Video_Tracker/private/pushbutton_images'], 'rewind');
set(hObject, 'CData', rewind);

%% frwbutton
% --- Executes on button press in frwbutton.
function frwbutton_Callback(hObject, eventdata, handles)
ind = str2num(get(handles.frameindex, 'String'));
try
    if ind < handles.nRecords,
        ind = ind + 1;
        set(handles.frameindex, 'String', num2str(ind));
        DrawFrames(handles.axes1, handles);
        UpdateProgressplot(handles.progressplot, handles);
    end;
end

% --- Executes during object creation, after setting all properties.
function frwbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frwbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
Main_Code_Directory = bSettings('get', 'GENERAL', 'Main_Code_Directory');
load([Main_Code_Directory '/Analysis/Video_Tracker/private/pushbutton_images'], 'forward');
set(hObject, 'CData', forward);

%% loadbutton
% --- Executes on button press in loadbutton.
function loadbutton_Callback(hObject, eventdata, handles)
% hObject    handle to loadbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load raw targets, preprocessed from a .nvt file
%[FileName,fdir] = uigetfile('*.*','Load raw targets as a .mat file');

uiopen('LOAD');
try
    handles.Targets    = Targets;
    handles.TimeStamps = TimeStamps;
    handles.NlxHeader  = NlxHeader;
    handles.nRecords   = cols(Targets);
    set(handles.statusdisplay, 'String', 'Targets loaded', ...
        'BackgroundColor', 0.9*[1 1 1]);

    % stores the extracted targets
    handles.extracted     = 0;
    handles.x             = [];
    handles.y             = [];
    handles.color         = [];
    handles.valid_targets = [];

    % to store the tracked head positions
    handles.head = zeros(6,1);
    handles.tracked = [];

    % rig position
    handles.RigPos = [225 63 330 400];

    set(handles.fileinfo, 'String', NlxHeader(1:5));

    handles.nRecords = length(TimeStamps);
    set(handles.frameslider, 'Max', handles.nRecords);
    set(handles.frameslider, 'Min', 1);
    set(handles.frameslider, 'Value', 1);
    set(handles.progressplot, 'XLim', [0 handles.nRecords]);
    set(handles.progressplot, 'XTick', []);

    guidata(hObject, handles);
catch
    set(handles.statusdisplay, 'String', 'Loading Failed', 'BackgroundColor', [1 0 0]);
    return;
end;



%% loadextractedbutton
% --- Executes on button press in loadextractedbutton.
function loadextractedbutton_Callback(hObject, eventdata, handles)
uiopen('LOAD');
try
    handles.extracted = targets.extracted;
    handles.x         = targets.x;
    handles.y         = targets.y;
    handles.color     = targets.color;
    handles.valid_targets = targets.valid_targets;
    
    handles.TimeStamps = targets.TimeStamps;
    handles.NlxHeader = targets.NlxHeader;
    set(handles.fileinfo, 'String', targets.NlxHeader(1:5));
    
    % to store the tracked head positions
    handles.head = zeros(6,1);
    handles.tracked = [];

    % rig position
    handles.RigPos = [225 63 330 400];

    handles.nRecords = length(handles.TimeStamps);
    set(handles.frameslider, 'Max', handles.nRecords);
    set(handles.frameslider, 'Min', 1);
    set(handles.frameslider, 'Value', 1);
    set(handles.progressplot, 'XLim', [0 handles.nRecords]);
    set(handles.progressplot, 'XTick', []);

    guidata(hObject, handles);

    set(handles.statusdisplay, 'String', 'Extracted Targets loaded', ...
        'BackgroundColor', 0.9*[1 1 1]);
catch
    set(handles.statusdisplay, 'String', 'Extracted Targets Loading Failed', 'BackgroundColor', [1 0 0]);
    return;    
end



%% savebutton
% --- Executes on button press in savebutton.
function savebutton_Callback(hObject, eventdata, handles)
% hObject    handle to savebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName, PathName] = uiputfile('*.mat');
head_coord = handles.head;
tracked = handles.tracked;
TimeStamps = handles.TimeStamps(1:cols(head_coord));
save([PathName FileName], 'head_coord', 'tracked', 'TimeStamps');


%% saveextractedbutton
% --- Executes on button press in saveextractedbutton.
function saveextractedbutton_Callback(hObject, eventdata, handles)
% hObject    handle to saveextractedbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName, PathName] = uiputfile('*.mat');
targets.extracted = handles.extracted;
targets.x = handles.x;
targets.y = handles.y;
targets.color = handles.color;
targets.valid_targets = handles.valid_targets;
targets.NlxHeader = handles.NlxHeader(1:5);
targets.TimeStamps = handles.TimeStamps(1:handles.extracted);
save([PathName FileName], 'targets');

%% LED1channel, LED2channel, LED3channel
% --- Executes on selection change in LED1channel.
function LED1channel_Callback(hObject, eventdata, handles)
% hObject    handle to LED1channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns LED1channel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LED1channel


% --- Executes during object creation, after setting all properties.
function LED1channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED1channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in LED2channel.
function LED2channel_Callback(hObject, eventdata, handles)
% hObject    handle to LED2channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns LED2channel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LED2channel


% --- Executes during object creation, after setting all properties.
function LED2channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED2channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in LED3channel.
function LED3channel_Callback(hObject, eventdata, handles)
% hObject    handle to LED3channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns LED3channel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LED3channel


% --- Executes during object creation, after setting all properties.
function LED3channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED3channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% relangle
function relangle_Callback(hObject, eventdata, handles)
% hObject    handle to relangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of relangle as text
%        str2double(get(hObject,'String')) returns contents of relangle as a double


% --- Executes during object creation, after setting all properties.
function relangle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to relangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% trackbackwards
% --- Executes on button press in trackbackwards.
function trackbackwards_Callback(hObject, eventdata, handles)
% hObject    handle to trackbackwards (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trackbackwards

%% trackbutton
% --- Executes on button press in trackbutton.
function trackbutton_Callback(hObject, eventdata, handles)
if get(handles.trackbackwards, 'Value') > 0, forwards = 0;
else                                         forwards = 1;
end;
set(handles.savebutton, 'Enable', 'on');

if forwards,
    set(handles.statusdisplay, 'String', 'Tracking forwards...', ...
        'BackgroundColor', [0.8 0.1 0.1]);
    pause(0.1);
    ind = str2double(get(handles.frameindex, 'String'));
    F = find(handles.tracked > 0);
    track_range = ind:min([handles.extracted, F(find(F > ind, 1)), handles.nRecords]);
    if isempty(track_range) && handles.tracked(ind) == 1,
        track_range = ind;
    end;
    [head, LEDs, records_tracked] = TrackFrames(handles.box, handles.x, handles.y, ...
        handles.color, handles.valid_targets, ... 
        'record_index', track_range);
    handles.head(:, ind:ind+records_tracked-1) = head;
    handles.tracked(ind:ind+records_tracked-1) = ones(1, cols(head));
    handles.lasttracked = ind+records_tracked-1;
    guidata(hObject, handles);
    str = sprintf('Tracked from record %d to %d.', ind, ind+records_tracked-1)
    set(handles.statusdisplay, 'String', str, ...
        'BackgroundColor', [0.1 0.8 0.1]);
else
    set(handles.statusdisplay, 'String', 'Tracking backwards...', ...
        'BackgroundColor', [0.8 0.1 0.1]);
    pause(0.1);
    ind = str2double(get(handles.frameindex, 'String'));
    F = find(handles.tracked > 0);
    track_range = ind:-1:max([1, F(find(F < ind, 1, 'last')), eps]);
    if isempty(track_range) && (handles.tracked(ind) == 1),
        track_range = ind;
    end;
    [head, LEDs, records_tracked] = TrackFrames(handles.box, handles.x, handles.y, ...
        handles.color, handles.valid_targets, ... 
        'record_index', track_range);
    handles.head(:, ind:-1:ind-records_tracked+1) = head;
    handles.tracked(ind:-1:ind-records_tracked+1) = ones(1, cols(head));
    handles.lasttracked = ind-records_tracked+1;
    guidata(hObject, handles);
    size(head)
    str = sprintf('Tracked from record %d to %d.', ind, ind-records_tracked+1)
    set(handles.statusdisplay, 'String', str, ...
        'BackgroundColor', [0.1 0.8 0.1]);    
end;

%% boxbutton
% --- Executes on button press in boxbutton.
% allows the user to draw a box in axes1 and stores it as handles.box
function boxbutton_Callback(hObject, eventdata, handles)
h = handles.axes1;
k = waitforbuttonpress;
point1 = get(h, 'CurrentPoint');
rect = rbbox;
point2 = get(h, 'CurrentPoint');
point1 = point1(1,1:2);
point2 = point2(1,1:2);
start  = min(point1, point2);
offset = abs(point1-point2);
handles.box = [start offset];
guidata(hObject, handles);

axes(h);
rectangle('Position', handles.box, 'EdgeColor', 'r');

ind = str2num(get(handles.frameindex, 'String'));
if ind < handles.extracted,
    set(handles.trackbutton, 'Enable', 'on');
end;

%% extractbutton
% --- Executes on button press in extractbutton.
function extractbutton_Callback(hObject, eventdata, handles)
try
    set(handles.saveextractedbutton, 'Enable', 'on');
    N = str2num(get(handles.nextract, 'String'));
    i = handles.extracted;   

    set(handles.statusdisplay, 'String', sprintf('Extracting %d targets...', N), ...
        'BackgroundColor', [0.8 0.1 0.1]);
    pause(0.2);

    chunk = 1000;
    for index = 1:chunk:N,
        pause(0.02);
        if get(handles.abortbutton, 'Value') == 1, 
            set(handles.abortbutton, 'Value', 0); 
            break;
        end;
        range = [i+index:i+1+index+min([chunk, N-index, handles.nRecords-i-1-index])];
        if range(end) > handles.nRecords,
            range = nonzeros(range .* (range <= handles.nRecords));
        end;

        [x, y, color, valid_targets] = ExtractFromTargets(handles.Targets(:,range), ...
            'h', handles.statusdisplay, ...
            'savetype', 'mat', ...
            'RigPos', handles.RigPos);

        if cols(handles.x) < cols(x),
            add = cols(x) - cols(handles.x);
            handles.x = [handles.x zeros(rows(handles.x), add)];
            handles.y = [handles.y zeros(rows(handles.y), add)];
            handles.color = [handles.color zeros(rows(handles.color), add, 7)];
        elseif cols(handles.x) > cols(x),
            add = cols(handles.x) - cols(x);
            x = [x zeros(rows(x), add)];
            y = [y zeros(rows(x), add)];
            color = [color zeros(rows(color), add, 7)];
        end;
        handles.x(range, :) = x;
        handles.y(range, :) = y;
        handles.color(range,:,:) = color;
        handles.valid_targets(range) = valid_targets;
        handles.extracted = range(end);

        guidata(hObject, handles);

        UpdateProgressplot(handles.progressplot, handles);
    end;

    set(handles.statusdisplay, 'String', 'Target extraction completed', ...
        'BackgroundColor', [.1 .9 .1]);

    axes(handles.axes1);
    rectangle('Position', [0 0 640 480]);
catch
    warning('Extract targets failed');
end;


%% extractallbutton
% --- Executes on button press in extractallbutton.
function extractallbutton_Callback(hObject, eventdata, handles)
% hObject    handle to extractallbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try        
    set(handles.saveextractedbutton, 'Enable', 'on');
    i = handles.extracted;   

    set(handles.statusdisplay, 'String', 'Extracting all targets...', ...
        'BackgroundColor', [0.8 0.1 0.1]);
    pause(0.2);

    chunk = 1000;
    for index = 1:chunk:(handles.nRecords-i-1),
        pause(0.02);
        if get(handles.abortbutton, 'Value') == 1, 
            set(handles.abortbutton, 'Value', 0); 
            break;
        end;
        range = [i+index:i+1+index+min([chunk, handles.nRecords-i-1-index])];
        if range(end) > handles.nRecords,
            range = nonzeros(range .* (range <= handles.nRecords));
        end;

        [x, y, color, valid_targets] = ExtractFromTargets(handles.Targets(:,range), ...
            'h', handles.statusdisplay, ...
            'savetype', 'mat', ...
            'RigPos', handles.RigPos);

        if cols(handles.x) < cols(x),
            add = cols(x) - cols(handles.x);
            handles.x = [handles.x zeros(rows(handles.x), add)];
            handles.y = [handles.y zeros(rows(handles.y), add)];
            handles.color = [handles.color zeros(rows(handles.color), add, 7)];
        elseif cols(handles.x) > cols(x),
            add = cols(handles.x) - cols(x);
            x = [x zeros(rows(x), add)];
            y = [y zeros(rows(x), add)];
            color = [color zeros(rows(color), add, 7)];
        end;
        handles.x(range, :) = x;
        handles.y(range, :) = y;
        handles.color = [handles.color; color];
        handles.valid_targets = [handles.valid_targets valid_targets];
        handles.extracted = range(end);

        guidata(hObject, handles);

        UpdateProgressplot(handles.progressplot, handles);
    end;

    set(handles.statusdisplay, 'String', 'Target extraction completed', ...
        'BackgroundColor', [.1 .9 .1]);

    axes(handles.axes1);
    rectangle('Position', [0 0 640 480]);
catch
    warning('Extract all targets failed');
end;




%% abortbutton
% --- Executes on button press in abortbutton.
function abortbutton_Callback(hObject, eventdata, handles)
% hObject    handle to abortbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% nextract
function nextract_Callback(hObject, eventdata, handles)
N = str2num(get(hObject, 'String'));
if isempty(N) || ~isreal(N) || N < 1,
    set(hObject, 'String', num2str(1000));
end;

% --- Executes during object creation, after setting all properties.
function nextract_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% gototrackedbutton
% --- Executes on button press in gototrackedbutton.
function gototrackedbutton_Callback(hObject, eventdata, handles)
% hObject    handle to gototrackedbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
        set(handles.frameindex, 'String', handles.lasttracked);
        DrawFrames(handles.axes1, handles);
        UpdateProgressplot(handles.progressplot, handles);
end



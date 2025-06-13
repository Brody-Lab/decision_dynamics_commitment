function varargout = TechNotes(varargin)
% TECHNOTES M-file for TechNotes.fig
%      TECHNOTES, by itself, creates a new TECHNOTES or raises the existing
%      singleton*.
%
%      H = TECHNOTES returns the handle to a new TECHNOTES or the handle to
%      the existing singleton*.
%
%      TECHNOTES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TECHNOTES.M with the given input arguments.
%
%      TECHNOTES('Property','Value',...) creates a new TECHNOTES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TechNotes_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TechNotes_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TechNotes

% Last Modified by GUIDE v2.5 03-Nov-2022 22:43:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TechNotes_OpeningFcn, ...
                   'gui_OutputFcn',  @TechNotes_OutputFcn, ...
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


% --- Executes just before TechNotes is made visible.
function TechNotes_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>

set(gcf,'name','TechNotes V2.2');
set(handles.date_text,'string',datestr(now,29));

[names, initials] = bdata('select experimenter, initials from ratinfo.contacts where is_alumni=0 order by experimenter');
names(2:end+1)=names; 
names{1}='Select Name'; 
set(handles.name_menu,'string',names);

handles = TN_disablebuttons(handles);

initials(2:end+1) = initials;
initials{1} = '';

handles.initials = initials;
handles.user     = '';

[r,s,g] = bdata(['select ratname, timeslot, rig from ratinfo.schedule where date="',...
    datestr(now,'yyyy-mm-dd'),'"']);

handles.schedule_rat = r;
handles.schedule_rig = g;
handles.schedule_ses = s;

[r,c] = bdata('select ratname, contact from ratinfo.rats where extant = 1');

handles.registry_rat = r;
handles.registry_con = c;

[e,m] = bdata('select experimenter, email from ratinfo.contacts where is_alumni = 0');

handles.contacts_exp = e;

for i = 1:numel(m)
    a = find(m{i} == '@',1,'first');
    if ~isempty(a)
        m{i} = m{i}(1:a-1);
    end
end
handles.contacts_email = m;

E = cell(numel(c),1);
for i = 1:numel(c);
    k = find(c{i}==',' | c{i}==' ');
    k = [0,k,numel(c{i})+1];
    for j = 1:numel(k) - 1
        x = c{i}(k(j)+1:k(j+1)-1);
        temp = strcmp(m,x);
        if sum(temp) == 1 && ~isempty(x)
            E{i}{end+1} = e{temp};
        end
    end
end
handles.registry_own = E;

set(handles.submit_button,'visible','off');

handles.olddate = 0;

handles.output = hObject;
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = TechNotes_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL>
varargout{1} = handles.output;


% --- Executes on selection change in name_menu.
function name_menu_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

handles.user = handles.initials{get(handles.name_menu,'value')};
if get(handles.name_menu,'value') == 1
    set(handles.submit_button,'visible','off');
    handles = TN_disablebuttons(handles);
else
    set(handles.submit_button,'visible','on');
    handles = TN_enablebuttons(handles);
end
guidata(hObject,handles);


% --- Executes on button press in x_button.
function x_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
newdate = inputdlg('Enter the new date:','',1,{datestr(now,29)});
if strcmp(newdate,datestr(now,29)) == 0
    handles.olddate = 1;
    set(handles.submit_button,'visible','off');
else
    handles.olddate = 0;
    set(handles.submit_button,'visible','on');
end
set(handles.date_text,'string',newdate{1});
guidata(hObject, handles);


% --- Executes on button press in rat_button.
function rat_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

set(handles.submit_button,'enable','on');
if get(hObject,'value') == 1
    handles = TN_listrats(handles);
    set(handles.roomempty_button,'enable','off')
    set(handles.pubempty_button, 'enable','off')
else
    handles = TN_clear(handles);
end
guidata(hObject,handles);


% --- Executes on button press in rig_button.
function rig_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

set(handles.submit_button,'enable','on');
if get(hObject,'value') == 1
    handles = TN_listrigs(handles);
    set(handles.roomempty_button,'enable','off')
    set(handles.pubempty_button, 'enable','off')
else
    handles = TN_clear(handles);
end
guidata(hObject,handles);


% --- Executes on button press in tower_button.
function tower_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

set(handles.submit_button,'enable','on');
if get(hObject,'value') == 1
    handles = TN_listtowers(handles);
    set(handles.roomempty_button,'enable','off')
    set(handles.pubempty_button, 'enable','off')
else
    handles = TN_clear(handles);
end
guidata(hObject,handles);


% --- Executes on button press in session_button.
function session_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

set(handles.submit_button,'enable','on');
if get(hObject,'value') == 1
    handles = TN_listsessions(handles);
    set(handles.roomempty_button,'enable','off')
    set(handles.pubempty_button, 'enable','off')
else
    handles = TN_clear(handles);
end
guidata(hObject,handles);



% --- Executes on button press in experimenter_button.
function experimenter_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

set(handles.submit_button,'enable','on');
if get(hObject,'value') == 1
    handles = TN_listexperimenters(handles);
    set(handles.roomempty_button,'enable','off')
    set(handles.pubempty_button, 'enable','off')
else
    handles = TN_clear(handles);
end
guidata(hObject,handles);


% --- Executes on button press in general_button.
function general_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

set(handles.submit_button,'enable','on');
if get(hObject,'value') == 1
    set(handles.exp_text,'string','EVERYONE');
    handles = TN_general(handles);
    set(handles.roomempty_button,'enable','off')
    set(handles.pubempty_button, 'enable','off')
else
    set(handles.exp_text,'string','');
    handles = TN_clear(handles);
end
guidata(hObject,handles);


% --- Executes on button press in room_button.
function room_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

set(handles.submit_button,'enable','on');
if get(hObject,'value') == 1
    handles = TN_listrooms(handles);
    set(handles.roomempty_button,'enable','on')
    set(handles.pubempty_button, 'enable','on')
else
    handles = TN_clear(handles);
    set(handles.roomempty_button,'enable','off')
    set(handles.pubempty_button, 'enable','off')
end
guidata(hObject,handles);


% --- Executes on button press in emergency_button.
function emergency_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

set(handles.submit_button,'enable','on');
handles = TN_emergency(handles);
guidata(hObject,handles);


function items_edit_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

set(handles.submit_button,'enable','on');
full_list = get(handles.items_edit,'string');
items_num = get(handles.items_edit,'value');
handles.active = full_list(items_num);

T = [];
for i = 1:length(items_num)
    T = [T,full_list{items_num(i)}]; %#ok<AGROW>
    if i < length(items_num); T = [T,', ']; end %#ok<AGROW>
end

set(handles.active_text,'string',T);

E = TN_determine_experimenters(handles);
X = [];
for i = 1:numel(E)
    X = [X,E{i}];
    if i < numel(E); X = [X,', ']; end
end
set(handles.exp_text,'string',X);

allnames = get(handles.name_menu,'string');
currname = allnames{get(handles.name_menu,'value')};

if isempty(strfind(X,currname)) && isempty(get(handles.note_edit,'string'));
    %This is not the current users rat and they haven't entered a note, so
    %we will disable the management buttons
    handles = TN_disablebuttons(handles,'management');
else
    handles = TN_enablebuttons(handles);
end

guidata(hObject,handles);


% --- Executes on button press in view_button.
function view_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

handles = TN_viewold(handles);
guidata(hObject,handles);


function note_edit_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>



% --- Executes on button press in submit_button.
function submit_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

handles = TN_submit(handles);
guidata(hObject,handles);


% --- Executes on button press in clear_button.
function clear_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

set(handles.submit_button,'enable','on');
set(handles.note_edit,'string','');
guidata(hObject,handles);


function oldnotes_edit_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>



% --- Executes during object creation, after setting all properties.
function oldnotes_edit_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function items_edit_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function note_edit_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function name_menu_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in freewater_button.
function freewater_button_Callback(hObject, eventdata, handles)

TN_removetraining(handles,'freewater');

% --- Executes on button press in recovery_button.
function recovery_button_Callback(hObject, eventdata, handles)

TN_removetraining(handles,'recovery');


% --- Executes on button press in dead_button.
function dead_button_Callback(hObject, eventdata, handles)

TN_removetraining(handles,'dead');


% --- Executes on button press in missing_button.
function missing_button_Callback(hObject, eventdata, handles)

TN_removetraining(handles,'missing')


% --- Executes on button press in cagemate_button.
function cagemate_button_Callback(hObject, eventdata, handles)

TN_cagemate(handles);


% --- Executes on button press in training_button.
function training_button_Callback(hObject, eventdata, handles)

TN_removetraining(handles,'training');

% --- Executes on button press in sick_button.
function sick_button_Callback(hObject, eventdata, handles)

TN_removetraining(handles,'sick');


% --- Executes on button press in hematuria_button.
function hematuria_button_Callback(hObject, eventdata, handles)

TN_removetraining(handles,'hematuria');





% --- Executes on button press in roomempty_button.
function roomempty_button_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>

if isfield(handles,'active') && ~isempty(handles.active)
    for i = 1:numel(handles.active)
        answer = questdlg(['Are you certain no animals remain in ',handles.active{i}],'Confirm Room Empty','Yes','No','No');
        if strcmp(answer,'Yes')
            note = ['Room ',handles.active{i},', confirmed empty'];
            set(handles.note_edit,'string',note);
            TN_submit(handles);
        end
    end
    
else
    msgbox('Please select a room first.');
end
guidata(hObject,handles);


% --- Executes on button press in pubempty_button.
function pubempty_button_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>

if isfield(handles,'active') && ~isempty(handles.active)
    for i = 1:numel(handles.active)
        answer = questdlg(['Are you certain no animals remain in any pubs in ',handles.active{i}],'Confirm Pubs Empty','Yes','No','No');
        if strcmp(answer,'Yes')
            note = ['Pubs in ',handles.active{i},', confirmed empty'];
            set(handles.note_edit,'string',note);
            TN_submit(handles);
        end
    end
    
else
    msgbox('Please select a room first.');
end
guidata(hObject,handles);



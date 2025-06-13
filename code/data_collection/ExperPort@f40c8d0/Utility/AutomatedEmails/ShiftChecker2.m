function varargout = ShiftChecker2(varargin)
% SHIFTCHECKER2 MATLAB code for ShiftChecker2.fig
%      SHIFTCHECKER2, by itself, creates a new SHIFTCHECKER2 or raises the existing
%      singleton*.
%
%      H = SHIFTCHECKER2 returns the handle to a new SHIFTCHECKER2 or the handle to
%      the existing singleton*.
%
%      SHIFTCHECKER2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SHIFTCHECKER2.M with the given input arguments.
%
%      SHIFTCHECKER2('Property','Value',...) creates a new SHIFTCHECKER2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ShiftChecker2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ShiftChecker2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ShiftChecker2

% Last Modified by GUIDE v2.5 22-Jul-2020 13:30:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ShiftChecker2_OpeningFcn, ...
                   'gui_OutputFcn',  @ShiftChecker2_OutputFcn, ...
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


% --- Executes just before ShiftChecker2 is made visible.
function ShiftChecker2_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for ShiftChecker2
handles.output = hObject;

handles.ratrig = bSettings('get','RIGS','ratrig');
if isnan(handles.ratrig); handles.ratrig = 1; end

handles.runonecycle = 0;
handles.running = 0;
IP = get_network_info;
allexp = bdata('select experimenter from ratinfo.contacts where is_alumni=0 order by experimenter');
allexp(2:end+1) = allexp;
allexp{1} = '';

set(handles.Atech_menu,'string',allexp);
set(handles.Btech_menu,'string',allexp);
set(handles.Ctech_menu,'string',allexp);

Atech = bdata(['select overnight from ratinfo.tech_schedule where date="',datestr(now,'yyyy-mm-dd'),'"']);
Btech = bdata(['select morning from ratinfo.tech_schedule where date="',datestr(now,'yyyy-mm-dd'),'"']);
Ctech = bdata(['select evening from ratinfo.tech_schedule where date="',datestr(now,'yyyy-mm-dd'),'"']);

Atech = Atech{1};
Btech = Btech{1};
Ctech = Ctech{1};

aspace = find(Atech==' ',1,'first');
bspace = find(Btech==' ',1,'first');
cspace = find(Ctech==' ',1,'first');

if ~isempty(aspace); Atech = Atech(1:aspace-1); end
if ~isempty(bspace); Btech = Btech(1:bspace-1); end
if ~isempty(cspace); Ctech = Ctech(1:cspace-1); end

anum = find(strcmpi(allexp,Atech)==1,1,'first');
bnum = find(strcmpi(allexp,Btech)==1,1,'first');
cnum = find(strcmpi(allexp,Ctech)==1,1,'first');

if isempty(anum); anum = 1; end
if isempty(bnum); bnum = 1; end
if isempty(cnum); cnum = 1; end

set(handles.Atech_menu,'value',anum);
set(handles.Btech_menu,'value',bnum);
set(handles.Ctech_menu,'value',cnum);

set(handles.Atech_menu,'enable','off');
set(handles.Btech_menu,'enable','off');
set(handles.Ctech_menu,'enable','off');

timerexists = timerfind('Tag','ShiftCheckerTimer');

if isempty(timerexists)
    handles.ShiftCheckerTimer = timer;
    set(handles.ShiftCheckerTimer,...
        'Period',       58,...
        'ExecutionMode','FixedRate',...
        'TasksToExecute',Inf,...
        'TimerFcn',     'RunOneShiftCheckerCycle',...
        'Tag',          'ShiftCheckerTimer');
end

%mp = get(0,'MonitorPositions');
%set(handles.figure1,'position',mp);
%set(handles.output,'position',mp);

%if strcmp(IP,'128.112.220.26')
%    %try
%        set(handles.figure1,'position',[-1599 1 1600 878],'visible','on');
%
%        handles.running = 1;
%        set(handles.run_toggle,'value',1,'string','Pause','BackgroundColor',[1 0 0]);
%        
%        guidata(hObject, handles);
%        
%        SC_running(handles);
%    %end
%end

%pos = get(handles.figure1,'position');
%set(handles.figure1,'position',[1,41,pos(3),pos(4)]);


% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = ShiftChecker2_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles;



function A_edit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function A_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function B_edit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function B_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function C_edit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function C_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in run_toggle.
function run_toggle_Callback(hObject, eventdata, handles)

if get(handles.run_toggle,'value') == 1
    if strcmp(handles.ShiftCheckerTimer.Running,'off')
        start(handles.ShiftCheckerTimer);
    end

    set(handles.run_toggle,'string','Pause','BackgroundColor',[1 0 0]);
    handles.running = 1;
    set(handles.Atech_menu,'enable','on');
    set(handles.Btech_menu,'enable','on');
    set(handles.Ctech_menu,'enable','on');
    
    if rem(str2num(datestr(now,'MM')),5) ~= 0
        update(hObject,eventdata,handles);
    end
else
    if strcmp(handles.ShiftCheckerTimer.Running,'on')
        stop(handles.ShiftCheckerTimer);
    end
    set(handles.run_toggle,'string','RUN','BackgroundColor',[0 1 0]);
    handles.running = 0;
    set(handles.Atech_menu,'enable','off');
    set(handles.Btech_menu,'enable','off');
    set(handles.Ctech_menu,'enable','off');
end

guidata(hObject,handles);


% --- Runs an update cycle.
function update(hObject, eventdata, handles)

%set(handles.figure1,'WindowState','Maximized');
handles = SC_running(handles);
guidata(hObject,handles);


% --- Executes on selection change in Atech_menu.
function Atech_menu_Callback(hObject, eventdata, handles)

handles = SC_update_tech(handles,1);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Atech_menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Btech_menu.
function Btech_menu_Callback(hObject, eventdata, handles)

handles = SC_update_tech(handles,2);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Btech_menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Ctech_menu.
function Ctech_menu_Callback(hObject, eventdata, handles)

handles = SC_update_tech(handles,3);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Ctech_menu_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
stop(handles.ShiftCheckerTimer);
delete(handles.ShiftCheckerTimer);

x = timerfind('Tag','ShiftCheckerTimer');
for i = 1:numel(x)
    delete(x(i));
end

delete(hObject);

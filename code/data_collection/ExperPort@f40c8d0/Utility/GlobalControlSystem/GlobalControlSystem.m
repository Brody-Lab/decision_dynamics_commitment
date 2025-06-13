function varargout = GlobalControlSystem(varargin)
% GLOBALCONTROLSYSTEM M-file for GlobalControlSystem.fig
%      GLOBALCONTROLSYSTEM, by itself, creates a new GLOBALCONTROLSYSTEM or raises the existing
%      singleton*.
%
%      H = GLOBALCONTROLSYSTEM returns the handle to a new GLOBALCONTROLSYSTEM or the handle to
%      the existing singleton*.
%
%      GLOBALCONTROLSYSTEM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GLOBALCONTROLSYSTEM.M with the given input arguments.
%
%      GLOBALCONTROLSYSTEM('Property','Value',...) creates a new GLOBALCONTROLSYSTEM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GlobalControlSystem_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GlobalControlSystem_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GlobalControlSystem

% Last Modified by GUIDE v2.5 31-Jul-2020 11:10:10
%
% Created by Chuck 2011

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GlobalControlSystem_OpeningFcn, ...
                   'gui_OutputFcn',  @GlobalControlSystem_OutputFcn, ...
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


% --- Executes just before GlobalControlSystem is made visible.
function GlobalControlSystem_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>

set(gcf,'name','GlobalControlSystem V3.0');

IP = get_network_info;

handles.output = hObject;
handles.lastrefresh = 0;
handles.goodpassword = 0;

pos = get(gcf,'position');
handles.size = pos(3:4);

[names,initials] = bdata('select experimenter, initials from ratinfo.contacts where is_alumni=0 order by experimenter');
set(handles.name_menu,'string',{'Select Name',names{:}}); %#ok<CCAT>

handles.initials  = {'',initials{:}}; %#ok<CCAT>
handles.compnames = get_compnames;
handles.ignore    = 201:205;                 
                 
handles = check_running(handles);   

f = fields(handles);
for i = 1:numel(f)
    fs = nan; %#ok<NASGU>
    try  %#ok<TRYNC>
        fs = get(eval(['handles.',f{i}]),'fontsize');
        if isempty(fs); fs = nan; end %#ok<NASGU>
    end
    eval(['handles.fontsize.',f{i},' = fs;'])
end

if strcmp(IP,'128.112.220.26')
    pos = get(handles.figure1,'position');
    handles.size = pos(3:4);
%    handles.size = [1280 858];
%    set(handles.figure1,'position',[-2879 1 1280 858],'visible','on');
%    set(handles.live_toggle,'value',1);
%    guidata(hObject, handles);
%    GCS_live_update(handles);
else
    pos = get(handles.figure1,'position');
    handles.size = pos(3:4);
end
handles.doingresize = 0;
guidata(hObject, handles);

set(handles.figure1,'position',[1,41,pos(3),pos(4)]);

timerexists = timerfind('Tag','GlobalControlSystemTimer');

if isempty(timerexists)
    handles.GlobalControlSystemTimer = timer;
    set(handles.GlobalControlSystemTimer,...
        'Period',       30,...
        'ExecutionMode','FixedRate',...
        'TasksToExecute',Inf,...
        'TimerFcn',     'GCS_live_update',...
        'Tag',          'GlobalControlSystemTimer');
end

guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = GlobalControlSystem_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL>

varargout{1} = handles;


% --- Executes on button press in monitoroff_button.
function monitoroff_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

handles = send_job(handles,'monitoroff');
guidata(hObject,handles);


% --- Executes on button press in monitoron_button.
function monitoron_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

handles = send_job(handles,'monitoron');
guidata(hObject,handles);


% --- Executes on button press in runrats_button.
function runrats_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

handles = send_job(handles,'runrats');
guidata(hObject,handles);


% --- Executes on button press in computers_button.
function computers_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

handles = send_job(handles,'reboot');
guidata(hObject,handles);


% --- Executes on button press in message_button.
function message_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

handles = send_job(handles,'message');
guidata(hObject,handles);


% --- Executes on button press in update_button.
function update_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

handles = send_job(handles,'update');
guidata(hObject,handles);


% --- Executes on button press in runscript_button.
function runscript_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

handles = send_job(handles,'run');
guidata(hObject,handles);


% --- Executes on selection change in name_menu.
function name_menu_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    
handles = activate_buttons(handles);
handles = check_running(handles);
guidata(hObject,handles);


function password_edit_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

handles = activate_buttons(handles);
guidata(hObject,handles);


% --- Executes on button press in read_button.
function read_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

answer = questdlg('Select Date of Message','','Today','Yesterday','Enter Date','Today');

if     strcmp(answer,'Today');     D = datestr(now,  'yyyy-mm-dd');
elseif strcmp(answer,'Yesterday'); D = datestr(now-1,'yyyy-mm-dd');
else D = inputdlg('Please enter the date as yyyy-mm-dd','',1,{''}); D = D{1}; %#ok<SEPEX>
end

names = get(handles.name_menu,'string');
name = names{get(handles.name_menu,'value')};
if strcmp(name,'Select Name'); msgbox('Please select you name before trying to read messages.'); return; end

IN = bdata(['select initials from ratinfo.contacts where experimenter="',name,'"']);

[M,R,T,C,F] = bdata(['select message, received, rectime, computer_name, failed from gcs where initials="',...
    IN{1},'" and dateval like "',D,'%" and job="message"']); %#ok<ASGLU>

if isempty(M)
    msgbox(['You posted no message on ',D]);
    return;
end

for i = 1:length(M)
    temp = find(strcmp(handles.compnames(:,1),C{i}) == 1,1,'first');
    if isempty(temp); continue; end
    rig = handles.compnames{temp,2};
    if strcmp(rig,'31'); rig = 'Tech Computer'; end
    if strcmp(T{i},'0000-00-00 00:00:00'); T{i} = 'Message NOT Received'; end
    if F(i) == 1;                          T{i} = 'Message Never Posted'; end
    
    GCS_Message({rig,str2num(char(M{i}')),T{i}}); %#ok<ST2NM>
    pause(0.1);
end



% --- Executes on button press in viewrig_button.
function viewrig_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

for i = 1:length(handles.compnames)
    if get(eval(['handles.rig',handles.compnames{i,2}]),'value') == 1
        system(['vncviewer ',handles.compnames{i,3},':5900 &'])
        pause(0.1);
    end
end


% --- Executes on button press in fix_button.
function fix_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

if get(handles.fix_button,'value') == 1
    set(handles.fix_button,'string','Select Free');
else
    set(handles.fix_button,'string','Fix Choice');
    handles = check_running(handles);
end
guidata(hObject,handles);


% --- Executes on button press in all_button.
function all_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

if get(handles.all_button,'value') == 0
    set(handles.all_button,'string','Unselect All')
    
    showwarn = 0;
    for i = 1:length(handles.compnames)
        if sum(handles.ignore == i) > 0; continue; end
        set(eval(['handles.rig',handles.compnames{i,2}]),'value',1);
        str = get(eval(['handles.status',handles.compnames{i,2}]),'string');
        if length(str) > 7 && strcmp(str(1:7),'Running')
            showwarn = 1;
        end
    end
    if showwarn == 1
        warndlg('WARNING: You have selected a rig that appears to be running a rat!','','modal');
    end
    
else
    set(handles.all_button,'string','Select All')
    for i = 1:length(handles.compnames)
        set(eval(['handles.rig',handles.compnames{i,2}]),'value',0);
    end
end
    
guidata(hObject,handles);


% --- Executes on button press in refresh_button.
function refresh_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

handles = check_running(handles);
guidata(hObject,handles);


% --- Executes on button press in live_toggle.
function live_toggle_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

%set(handles.figure1,'HandleVisibility','on')
if get(handles.live_toggle,'value') == 1
    if strcmp(handles.GlobalControlSystemTimer.Running,'off')
        start(handles.GlobalControlSystemTimer);
    end
else
    if strcmp(handles.GlobalControlSystemTimer.Running,'on')
        stop(handles.GlobalControlSystemTimer);
    end
    set(hObject,'String','Go Live','BackgroundColor',[0 1 0]);
end
    
guidata(hObject,handles);


function update(hObject, eventdata, handles) %#ok<DEFNU,INUSL>

handles = check_running(handles);
guidata(hObject,handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

set(handles.live_toggle,'value',0);
timerexists = timerfind('Tag','GlobalControlSystemTimer');
if ~isempty(timerexists)
    delete(timerexists);
end

delete(hObject);


% --- Executes during object creation, after setting all properties.
function name_menu_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rig1.
function rig1_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,1);
guidata(hObject,handles);

% --- Executes on button press in rig2.
function rig2_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,2);
guidata(hObject,handles);

% --- Executes on button press in rig3.
function rig3_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,3);
guidata(hObject,handles);

% --- Executes on button press in rig4.
function rig4_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,4);
guidata(hObject,handles);

% --- Executes on button press in rig5.
function rig5_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,30);
guidata(hObject,handles);

% --- Executes on button press in rig6.
function rig6_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,30);
guidata(hObject,handles);

% --- Executes on button press in rig7.
function rig7_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,7);
guidata(hObject,handles);

% --- Executes on button press in rig8.
function rig8_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,8);
guidata(hObject,handles);

% --- Executes on button press in rig9.
function rig9_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,9);
guidata(hObject,handles);

% --- Executes on button press in rig10.
function rig10_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,10);
guidata(hObject,handles);

% --- Executes on button press in rig11.
function rig11_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,11);
guidata(hObject,handles);

% --- Executes on button press in rig12.
function rig12_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,12);
guidata(hObject,handles);

% --- Executes on button press in rig13.
function rig13_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,13);
guidata(hObject,handles);

% --- Executes on button press in rig14.
function rig14_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,14);
guidata(hObject,handles);

% --- Executes on button press in rig15.
function rig15_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,15);
guidata(hObject,handles);

% --- Executes on button press in rig16.
function rig16_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,16);
guidata(hObject,handles);

% --- Executes on button press in rig17.
function rig17_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,17);
guidata(hObject,handles);

% --- Executes on button press in rig18.
function rig18_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,18);
guidata(hObject,handles);

% --- Executes on button press in rig19.
function rig19_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,19);
guidata(hObject,handles);

% --- Executes on button press in rig20.
function rig20_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,20);
guidata(hObject,handles);

% --- Executes on button press in rig21.
function rig21_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,21);
guidata(hObject,handles);

% --- Executes on button press in rig22.
function rig22_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,22);
guidata(hObject,handles);

% --- Executes on button press in rig23.
function rig23_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,23);
guidata(hObject,handles);

% --- Executes on button press in rig24.
function rig24_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,24);
guidata(hObject,handles);

% --- Executes on button press in rig25.
function rig25_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,25);
guidata(hObject,handles);

% --- Executes on button press in rig26.
function rig26_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,26);
guidata(hObject,handles);

% --- Executes on button press in rig27.
function rig27_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,27);
guidata(hObject,handles);

% --- Executes on button press in rig28.
function rig28_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,28);
guidata(hObject,handles);

% --- Executes on button press in rig29.
function rig29_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,29);
guidata(hObject,handles);

% --- Executes on button press in rig30.
function rig30_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,30);
guidata(hObject,handles);

% --- Executes on button press in rig31.
function rig31_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,31);
guidata(hObject,handles);

% --- Executes on button press in rig32.
function rig32_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,32);
guidata(hObject,handles);

% --- Executes on button press in rig33.
function rig33_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,33);
guidata(hObject,handles);

% --- Executes on button press in rig34.
function rig34_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,34);
guidata(hObject,handles);

% --- Executes on button press in rig35.
function rig35_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,35);
guidata(hObject,handles);

% --- Executes on button press in rig36.
function rig36_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,36);
guidata(hObject,handles);

% --- Executes on button press in rig37.
function rig37_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,37);
guidata(hObject,handles);

% --- Executes on button press in rig38.
function rig38_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,38);
guidata(hObject,handles);

% --- Executes on button press in rig70.
function rig70_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSD>

% --- Executes on button press in rig201.
function rig201_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,201);
guidata(hObject,handles);

% --- Executes on button press in rig202.
function rig202_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,202);
guidata(hObject,handles);

% --- Executes on button press in rig203.
function rig203_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,203);
guidata(hObject,handles);

% --- Executes on button press in rig204.
function rig204_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,204);
guidata(hObject,handles);

% --- Executes on button press in rig205.
function rig205_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,205);
guidata(hObject,handles);

% --- Executes on button press in rig210.
function rig210_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles = warn_running(handles,205);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function password_edit_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in schedule_button.
function schedule_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

system('start http://brodywiki-old.princeton.edu/zut/schedule.php');


% --- Executes on button press in registry_button.
function registry_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

system('start http://brodywiki-old.princeton.edu/zut/rats.php');


% --- Executes on button press in techschedule_button.
function techschedule_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

system('start http://brodywiki-old.princeton.edu/zut/tech_schedule.php');


% --- Executes on button press in watermeister_button.
function watermeister_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

WaterMeister;


% --- Executes on button press in massmeister_button.
function massmeister_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

MassMeister;


% --- Executes on button press in technotes_button.
function technotes_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

TechNotes;


% --- Executes on button press in shiftchecker_button.
function shiftchecker_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

ShiftChecker2;


% --- Executes on button press in readnote_button.
function readnote_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

[gN,rN,nN,tN,iN] = bdata(['select rigid, ratname, note, timestr, techinitials from',...
    ' ratinfo.technotes where datestr="',datestr(now,'yyyy-mm-dd'),'"']); %#ok<ASGLU>

[gM,nM,tM] = bdata('select rigid, note, broke_person from ratinfo.rig_maintenance where isbroken=1'); %#ok<ASGLU>

xN = [];
xM = [];

for j = 1:38
    if get(eval(['handles.rig',num2str(j)]),'value') == 1
        xN = [xN,find(gN == j)]; %#ok<AGROW>
        st = get(eval(['handles.status',num2str(j)]),'string');
        if ~isempty(st) && numel(st) >= 4
            xN = [xN,find(strcmp(rN,st(1:4))==1)]; %#ok<AGROW>
            
            if numel(st) >= 6 && strcmp(st(1:6),'BROKEN')
                xM = [xM,find(gM == j)]; %#ok<AGROW>
            end
        end
        
    end
end

if ~isempty(xM)
    set(handles.tech_session_text,'string',char(nM{xM(end)}'));
elseif ~isempty(xN)
    set(handles.tech_session_text,'string',char(nN{xM(end)}'));
end


% --- Executes on button press in maintenance_button.
function maintenance_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

system('start http://brodywiki-old.princeton.edu/zut/maintenance.php');


% --- Executes on button press in techsop_button.
function techsop_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

system('start https://brodylabwiki.princeton.edu/wiki/index.php?title=Animal_Tech_SOP');

% --- Executes on button press in neurobrowser_button.
function neurobrowser_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

newstartup;
neurobrowser init


% --- Executes on button press in contacts_button.
function contacts_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

system('start http://brodywiki-old.princeton.edu/zut/contacts.php');


% --- Executes on button press in emergency_button.
function emergency_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

user  = get(handles.name_menu,'value');
names = get(handles.name_menu,'string');

name = names{user};

message = GCS_Message({name,'',99});
message = double(message);

M = []; 
for r=1:size(message,1)
    M = [M,message(r,:),10];  %#ok<AGROW>
end
message = char(M);

send_emergency_alert(message,name);


% --- Executes on button press in massplotter_button.
function massplotter_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

RatMassPlotter


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

handles.doingresize = handles.doingresize + 1;

if handles.doingresize == 1
    pos = get(gcf,'position');

    %Let's ensure it stays proportional
    ratio = pos(3)/pos(4);

    if ~isfield(handles,'size')
        handles.size = pos(3:4);
    end
    fixratio = handles.size(1)/handles.size(2);

    newpos3 = pos(3);
    newpos4 = pos(4);
    if ratio > fixratio
        newpos3 = floor(fixratio * pos(4));
    elseif ratio < fixratio
        newpos4 = floor(pos(3) / fixratio);
    end
    newpos = [pos(1),pos(2),newpos3,newpos4];
    handles.newpos = newpos;
    
    guidata(hObject,handles);
    set(gcf,'position',newpos);
end

r = mean([handles.newpos(3)/handles.size(1),handles.newpos(4)/handles.size(2)]);

if handles.doingresize == 2
    if r ~= 1
        f = fields(handles);
        for i = 1:numel(f)
            try %#ok<TRYNC>
                originalfs = eval(['handles.fontsize.',f{i}]);
                if ~isnan(originalfs)
                    set(eval(['handles.',f{i}]),'fontsize',originalfs*r);
                end
            end
        end
    end
end

handles.doingresize = 0;
guidata(hObject,handles);




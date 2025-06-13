function varargout = WaterMeister(varargin)
%WATERMEISTER M-file for WaterMeister.fig
%      WATERMEISTER, by itself, creates a new WATERMEISTER or raises the existing
%      singleton*.
%
%      H = WATERMEISTER returns the handle to a new WATERMEISTER or the handle to
%      the existing singleton*.
%
%      WATERMEISTER('Property','Value',...) creates a new WATERMEISTER using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to WaterMeister_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      WATERMEISTER('CALLBACK') and WATERMEISTER('CALLBACK',hObject,...) call the
%      local function named CALLBACK in WATERMEISTER.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help WaterMeister

% Last Modified by GUIDE v2.5 26-Jul-2021 13:44:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @WaterMeister_OpeningFcn, ...
                   'gui_OutputFcn',  @WaterMeister_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end
global CLS running_timer
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
    if CLS ~= 0; if running_timer == 0; delete(CLS); CLS = 0; return; end; end
end
% End initialization code - DO NOT EDIT


% --- Executes just before WaterMeister is made visible.
function WaterMeister_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>

% Choose default command line output for WaterMeister
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

handles.ratrig = bSettings('get','RIGS','ratrig');
if isnan(handles.ratrig); handles.ratrig = 1; end

set(handles.startstop_toggle,'enable','off');
handles.buttons   = zeros(1,10);
handles.fontsize_ratname = 22;
handles.redraw_on_resize = 0;

C = get(gcf,'children');
P = get(gcf,'position');
for c = 1:length(C)
    handles.fontsize(c) = get(C(c),'fontsize');
end
handles.children = C;
handles.size = P(3:4);
handles.currsize = P(3:4);

try load('C:\ratter\ExperPort\Utility\WaterMeister\waittimes.mat');
catch; WT = [3600 3600 3600 3600 3600 3600 3600 3600 3600 1]; %#ok<CTCH>
end
handles.waittime = WT;
handles.use_tables = 1;

global button_state comp CLS running_timer
button_state = zeros(1,11);
comp = zeros(1,10);
CLS = 0;
running_timer = 0;

if handles.use_tables == 1
    handles = init_check(handles);
end
handles.rats = cell(0);

e = bdata('select experimenter from ratinfo.contacts where is_alumni=0');
e = sortrows(e);
e(2:end+1) = e;
e{1} = 'Name';

set(handles.initials_edit,'string',e)

set(gcf,'name','WaterMeister V3.5');

guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = WaterMeister_OutputFcn(hObject, eventdata, handles) %#ok<INUSL>

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in session1_toggle.
function session1_toggle_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>

if (now - handles.lastupdate) * 24 * 60 > 10; handles = init_check(handles); end

try load('C:\ratter\ExperPort\Utility\WaterMeister\Active_Rat_List.mat'); 
catch 
    disp('C:\ratter\ExperPort\Utility\WaterMeister\Active_Rat_List.mat does not exist...'); 
    active_rat_list = handles.rats;  %#ok<CTCH>
end 
handles.rats = active_rat_list;

global CLS running_timer
handles = session_button(1,handles);
if CLS ~= 0; delete(CLS); CLS = 0; running_timer = 0; return; end
guidata(hObject, handles);


% --- Executes on button press in session2_toggle.
function session2_toggle_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>

if (now - handles.lastupdate) * 24 * 60 > 10; handles = init_check(handles); end

try load('C:\ratter\ExperPort\Utility\WaterMeister\Active_Rat_List.mat'); 
catch 
    disp('C:\ratter\ExperPort\Utility\WaterMeister\Active_Rat_List.mat does not exist...'); 
    active_rat_list = handles.rats;  %#ok<CTCH>
end 
handles.rats = active_rat_list; 

global CLS running_timer
handles = session_button(2,handles);
if CLS ~= 0; delete(CLS); CLS = 0; running_timer = 0; return; end
guidata(hObject, handles);

% --- Executes on button press in session3_toggle.
function session3_toggle_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

if (now - handles.lastupdate) * 24 * 60 > 10; handles = init_check(handles); end

try load('C:\ratter\ExperPort\Utility\WaterMeister\Active_Rat_List.mat'); 
catch 
    disp('C:\ratter\ExperPort\Utility\WaterMeister\Active_Rat_List.mat does not exist...'); 
    active_rat_list = handles.rats;  %#ok<CTCH>
end 
handles.rats = active_rat_list; 

global CLS running_timer
handles = session_button(3,handles);
if CLS ~= 0; delete(CLS); CLS = 0; running_timer = 0; return; end
guidata(hObject, handles);

% --- Executes on button press in session4_toggle.
function session4_toggle_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

if (now - handles.lastupdate) * 24 * 60 > 10; handles = init_check(handles); end

try load('C:\ratter\ExperPort\Utility\WaterMeister\Active_Rat_List.mat'); 
catch 
    disp('C:\ratter\ExperPort\Utility\WaterMeister\Active_Rat_List.mat does not exist...'); 
    active_rat_list = handles.rats;  %#ok<CTCH>
end 
handles.rats = active_rat_list; 

global CLS running_timer
handles = session_button(4,handles);
if CLS ~= 0; delete(CLS); CLS = 0; running_timer = 0; return; end
guidata(hObject, handles);


% --- Executes on button press in session5_toggle.
function session5_toggle_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

if (now - handles.lastupdate) * 24 * 60 > 10; handles = init_check(handles); end

try load('C:\ratter\ExperPort\Utility\WaterMeister\Active_Rat_List.mat'); 
catch 
    disp('C:\ratter\ExperPort\Utility\WaterMeister\Active_Rat_List.mat does not exist...'); 
    active_rat_list = handles.rats;  %#ok<CTCH>
end 
handles.rats = active_rat_list;

global CLS running_timer
handles = session_button(5,handles);
if CLS ~= 0; delete(CLS); CLS = 0; running_timer = 0; return; end
guidata(hObject, handles);


% --- Executes on button press in session6_toggle.
function session6_toggle_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

if (now - handles.lastupdate) * 24 * 60 > 10; handles = init_check(handles); end

try load('C:\ratter\ExperPort\Utility\WaterMeister\Active_Rat_List.mat'); 
catch 
    disp('C:\ratter\ExperPort\Utility\WaterMeister\Active_Rat_List.mat does not exist...'); 
    active_rat_list = handles.rats;  %#ok<CTCH>
end 
handles.rats = active_rat_list;

global CLS running_timer
handles = session_button(6,handles);
if CLS ~= 0; delete(CLS); CLS = 0; running_timer = 0; return; end
guidata(hObject, handles);


% --- Executes on button press in session7_toggle.
function session7_toggle_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

if (now - handles.lastupdate) * 24 * 60 > 10; handles = init_check(handles); end

try load('C:\ratter\ExperPort\Utility\WaterMeister\Active_Rat_List.mat'); 
catch 
    disp('C:\ratter\ExperPort\Utility\WaterMeister\Active_Rat_List.mat does not exist...'); 
    active_rat_list = handles.rats;  %#ok<CTCH>
end 
handles.rats = active_rat_list;

global CLS running_timer
handles = session_button(7,handles);
if CLS ~= 0; delete(CLS); CLS = 0; running_timer = 0; return; end
guidata(hObject, handles);


% --- Executes on button press in session8_toggle.
function session8_toggle_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

if (now - handles.lastupdate) * 24 * 60 > 10; handles = init_check(handles); end

try load('C:\ratter\ExperPort\Utility\WaterMeister\Active_Rat_List.mat'); 
catch 
    disp('C:\ratter\ExperPort\Utility\WaterMeister\Active_Rat_List.mat does not exist...'); 
    active_rat_list = handles.rats;  %#ok<CTCH>
end 
handles.rats = active_rat_list;

global CLS running_timer
handles = session_button(8,handles);
if CLS ~= 0; delete(CLS); CLS = 0; running_timer = 0; return; end
guidata(hObject, handles);


% --- Executes on button press in session9_toggle.
function session9_toggle_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

if (now - handles.lastupdate) * 24 * 60 > 10; handles = init_check(handles); end

try load('C:\ratter\ExperPort\Utility\WaterMeister\Active_Rat_List.mat'); 
catch 
    disp('C:\ratter\ExperPort\Utility\WaterMeister\Active_Rat_List.mat does not exist...'); 
    active_rat_list = handles.rats;  %#ok<CTCH>
end  
handles.rats = active_rat_list;

global CLS running_timer
handles = session_button(9,handles);
if CLS ~= 0; delete(CLS); CLS = 0; running_timer = 0; return; end
guidata(hObject, handles);


% --- Executes on button press in session10_toggle.
function session10_toggle_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

if (now - handles.lastupdate) * 24 * 60 > 10; handles = init_check(handles); end

try load('C:\ratter\ExperPort\Utility\WaterMeister\Active_Rat_List.mat'); 
catch 
    disp('C:\ratter\ExperPort\Utility\WaterMeister\Active_Rat_List.mat does not exist...'); 
    active_rat_list = handles.rats;  %#ok<CTCH>
end  
handles.rats = active_rat_list;

global CLS running_timer
handles = session_button(10,handles);
if CLS ~= 0; delete(CLS); CLS = 0; running_timer = 0; return; end
guidata(hObject, handles);


% --- Executes on button press in startstop_toggle.
function startstop_toggle_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

set(handles.startstop_toggle,'enable','off');

if (now - handles.lastupdate) * 24 * 60 > 10; handles = init_check(handles); end

try load('C:\ratter\ExperPort\Utility\WaterMeister\Active_Rat_List.mat'); 
catch 
    disp('C:\ratter\ExperPort\Utility\WaterMeister\Active_Rat_List.mat does not exist...'); 
    active_rat_list = handles.rats;  %#ok<CTCH>
end  
handles.rats = active_rat_list;

names = get(handles.initials_edit,'string');
name = names{get(handles.initials_edit,'value')};
if strcmp(name,'Name')
    msgbox('Please enter your name.');
    set(handles.startstop_toggle,'enable','on');
    return;
else
    [E,I] = bdata('select experimenter, initials from ratinfo.contacts where is_alumni=0');
    initials = I{strcmp(E,name)};
end

global button_state comp CLS running_timer
running_timer = 0;
set(handles.print_button','enable','on');
S = find(button_state(1:10) == 1);
button_state(11) = get(handles.startstop_toggle,'value');
button_local = button_state;
comp_local   = comp;
    
str3 = 'BackgroundColor'; %#ok<NASGU>
if get(handles.startstop_toggle,'value') == 1
    %Starting
    set(handles.startstop_toggle,'fontsize',calcfontsize(20,handles),'BackgroundColor',[1 1 1],'string','Wait...','enable','off');
    pause(1);
    
    citricacid = get(handles.watertype_toggle,'value');
    if S < 10
        handles.start(S) = 1;

        st = handles.starttime(S);
        if isnan(st) || comp(S) == 1
            %Either this session hasn't stated today or this is a 2nd entry
            handles.starttime(S) = now;
            handles.stoptime(S)  = handles.starttime(S) + (handles.waittime(S) / (3600 * 24));
        end
        st = handles.starttime(S);
        
        pt = handles.stoptime(S);
        if isnan(pt)
            handles.stoptime(S) = handles.starttime(S) + (handles.waittime(S) / (3600 * 24));
        end
        pt = handles.stoptime(S);
        
        guidata(hObject, handles);

        timewait = (now - st) * 3600 * 24; %str2num(datestr(now - st,'SS')); %#ok<ST2NM>
        set(handles.startstop_toggle,'fontsize',calcfontsize(12,handles),'BackgroundColor',[1 1 0]);
        eval(['set(handles.session',num2str(S),'_toggle,str3,[1 1 0]);']);
        WT = handles.waittime(S);
    else
        st = now; 
    end
    
    set(handles.startstop_toggle,'enable','on');
    pause(0.01);
    if handles.use_tables == 1
        handles = WM_toggle_enable(handles);
        
        if S == 10
            answer = questdlg('Did the rats already have access to water?','','Yes','No','Yes');
            if strcmp(answer,'Yes')
                %The rats were connected before the tech checked on them,
                %so the start time is set to 1 minute after midnight.
                dstr = [datestr(now,'yyyy-mm-dd'),' 00:01:00'];
                st = datenum(dstr,'yyyy-mm-dd HH:MM:SS');
            end
        end
        
        for r = 1:length(handles.rats)
            if strcmp(handles.rats{r},''); continue; end
            set(handles.startstop_toggle,'string',handles.rats{r}); pause(0.01);
            
            bdata(['insert into ratinfo.water set date="',     datestr(st,'yyyy-mm-dd'),...
                                              '", rat="',      handles.rats{r},...
                                              '", tech="',     initials,...
                                              '", starttime="',datestr(st,'HH:MM:SS'),...
                                              '", stoptime="', datestr(st,'HH:MM:SS'),...
                                              '", citricacid=',num2str(citricacid)]);
            pause(0.01);

            %Here we check that the entries are going in
            temp_initials = bdata(['select tech from ratinfo.water where rat="',handles.rats{r},'" and date="',datestr(st,29),'"']);
            if isempty(temp_initials)
                errordlg('Connection with the database has been lost.  Please restart WaterMeister and try again.','Connection Error');
                return
            end
            
            disp(['Added Rat ',handles.rats{r},' to ratinfo.water by ',initials,' at ',datestr(st,29),' ',datestr(st,13)]);
        end
        handles = WM_toggle_enable(handles);
        comp(S) = 0;
        comp_local(S) = 0;
    end
    if S == 10
        
        
        %These are free water rats. Any that are not weighed should have a 
        %0 entered as their weight and FW as the initials
            
        Rm = bdata(['select ratname from ratinfo.mass where date="',datestr(now,'yyyy-mm-dd'),'"']);
        Rr = bdata(['select ratname from ratinfo.rats where extant=1 and recovering=1 and israt=',num2str(handles.ratrig)]);
        for i = 1:numel(handles.rats)
            %Confirm this rats doesn't already have a mass entered so we
            %don't overwrite it. And that he's not flagged as recovering
            %since they need to be weighed even if on free water
            if sum(strcmp(Rm,handles.rats{i})) == 0 && sum(strcmp(Rr,handles.rats{i})) == 0
                bdata(['insert into ratinfo.mass set mass=0, date="',datestr(now,'yyyy-mm-dd'),...
                    '", ratname="',handles.rats{i},'", tech="FW", timeval="',datestr(now,'HH:MM:SS'),'"']); 
            end
        end
            
        answer = questdlg('Do you want to confirm for TODAY ONLY?','','Yes','No','Yes');
        if strcmp(answer,'Yes')
            %This sets the stop time for today at a minute before midnight,
            %meaning rats on this list got water all day.  Answering no
            %leaves the stop time equal to the start time.  Any such
            %entries will be carried over by WM_carryover.m executed by
            %AES_Master just before midnight.
            
            comp(S) = 1;
            
            handles = WM_toggle_enable(handles);
            set(handles.startstop_toggle,'enable','off')
            pause(0.01);
            stoptime = '23:59:00';
            
            [W_all,R_all] = bdata(['select watering, rat from ratinfo.water where date="',datestr(now,'yyyy-mm-dd'),'"']);
            
            for r = 1:length(handles.rats)
                if strcmp(handles.rats{r},''); continue; end
                set(handles.startstop_toggle,'string',handles.rats{r}); pause(0.01);
                rtemp = strcmp(R_all,handles.rats{r});
                if sum(rtemp) > 0
                    wtemp = W_all(rtemp);
                    for w = 1:numel(wtemp)
                        bdata('call ratinfo.update_water_tbl2 ("{Si}","{S}")',wtemp(w),stoptime);
                    end
                end
                %bdata('call ratinfo.update_water_tbl ("{S}","{S}","{S}")',handles.rats{r},datestr(handles.starttime(S),29),stoptime);
            end
            handles = WM_toggle_enable(handles);
            pause(0.01);
            
            set(handles.startstop_toggle,'fontsize',calcfontsize(20,handles),'BackgroundColor',[0 1 1],'string','Complete','enable','off');
            eval(['set(handles.session',num2str(S),'_toggle,str3,[0 1 1]);']);
        
        else
            comp(S) = 0;
            set(handles.startstop_toggle,'fontsize',calcfontsize(16,handles),'BackgroundColor',[1 0 0],'string','Stop Now','enable','on');
            eval(['set(handles.session',num2str(S),'_toggle,str3,[1 1 0]);']);
        end
        
        return
    end
    
    %terminate = 0;
    %while timewait < WT
    %    running_timer = 1;
    %    set(handles.print_button','enable','off');
    %    if any(button_local ~= button_state) || any(comp_local ~= comp) || CLS ~= 0; terminate = 1; break; end
    %    
    %    timewait = (now - st) * 3600 * 24;
        set(handles.startstop_toggle,'string',['Stop at: ',datestr(pt,'HH:MM')],'fontsize',calcfontsize(12,handles));
    %    pause(1);
    %end
    %set(handles.print_button','enable','on');
    %running_timer = 0;
    if now - pt > 0
        %we are past the stop time
        set(handles.startstop_toggle,'fontsize',calcfontsize(16,handles),'BackgroundColor',[1 0 0],'string','Stop Now');
    end
    if CLS ~= 0
        delete(CLS); CLS = 0; running_timer = 0;
        set(handles.startstop_toggle,'enable','on');
        return;
    end
else
    %Stopping
    handles.start(S) = 0;
    comp(S)  = 1;
    set(handles.startstop_toggle,'fontsize',calcfontsize(20,handles),'BackgroundColor',[1 1 0],'string','Ending');
    eval(['set(handles.session',num2str(S),'_toggle,str3,[0 1 1]);']);
    pause(0.01);
    if handles.use_tables == 1
        handles = WM_toggle_enable(handles);
        set(handles.startstop_toggle,'enable','off')
        pause(0.01);
        if S == 10
            stoptime = '23:59:00';
        else
            stoptime = datestr(now,13);
        end
        
        [W_all,R_all] = bdata(['select watering, rat from ratinfo.water where date="',datestr(now,'yyyy-mm-dd'),'"']);
        
        for r = 1:length(handles.rats)
            if strcmp(handles.rats{r},''); continue; end
            set(handles.startstop_toggle,'string',handles.rats{r}); pause(0.01);
            rtemp = strcmp(R_all,handles.rats{r});
            if sum(rtemp) > 0
                wtemp = W_all(rtemp);
                for w = 1:numel(wtemp)
                    bdata('call ratinfo.update_water_tbl2 ("{Si}","{S}")',wtemp(w),stoptime);
                end
            end
        end
        handles = WM_toggle_enable(handles);
        pause(0.01);
    end
    set(handles.startstop_toggle,'fontsize',calcfontsize(20,handles),'BackgroundColor',[0 1 1],'string','Complete','enable','off');
    pause(0.1);
    guidata(hObject, handles);
    return
end

set(handles.startstop_toggle,'enable','on');

guidata(hObject, handles);


function initials_edit_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>



% --- Executes during object creation, after setting all properties.
function initials_edit_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

try %#ok<TRYNC>
    global button_state CLS running_timer %#ok<TLEV>
    
    P = get(gcf,'position');
    C = handles.children;
    tempR = P(3:4) ./ handles.size;
    
    R = (tempR(find(abs(log(tempR)) == min(abs(log(tempR))),1,'first')));
    %R = min(tempR);
    if find(tempR == R) == 2
        set(handles.axes1,'ylim',[0 75]);
        temp = (100 * (max(tempR) / min(tempR))) - 100;
        set(handles.axes1,'xlim',[-temp/2, 100+(temp/2)]);
    else
        set(handles.axes1,'xlim',[0 100]);
        temp = (75 * (max(tempR) / min(tempR))) - 75;
        set(handles.axes1,'ylim',[-temp/2, 75+(temp/2)]);
    end

    for c = 1:length(C)
        if strcmp(get(C(c),'tag'),'startstop_toggle')
            str = get(C(c),'string');
            if     strcmp(str,     'Start');    set(C(c),'fontsize',36*R);
            elseif strcmp(str,     'Confirm');  set(C(c),'fontsize',24*R);
            elseif strcmp(str(1:8),'Stop in:'); set(C(c),'fontsize',12*R);
            elseif strcmp(str(1:8),'Stop Now'); set(C(c),'fontsize',16*R);
            elseif strcmp(str(1:8),'Complete'); set(C(c),'fontsize',20*R);    
            end
        else
            set(C(c),'fontsize',handles.fontsize(c)*R);
        end
    end
    C = get(handles.axes1,'children');
    numcage = numel(C) / 3;
    if     numcage <= 20;
    elseif numcage <= 30; R = R * 0.8;
    elseif numcage <= 42; R = R * 0.7;
    else                  R = R * 0.6;  
    end
    for c = 1:length(C)
        try set(C(c),'fontsize',handles.fontsize_ratname*R); end %#ok<TRYNC>
    end

    handles.currsize = P(3:4);
    guidata(hObject, handles);
    
    if isfield(handles,'redraw_on_resize') && handles.redraw_on_resize == 1
        if isempty(button_state); temp = find(handles.buttons(1:7) == 1,1,'first');
        else                      temp = find(button_state(   1:7) == 1,1,'first');
        end
        if ~isempty(temp); handles = session_button(temp,handles); end
        if CLS ~= 0; delete(CLS); CLS = 0; running_timer = 0; return; end
        guidata(hObject, handles);
    end
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

global CLS
CLS = handles.figure1;



% --- Executes on button press in print_button.
function print_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

if (now - handles.lastupdate) * 24 * 60 > 10; handles = init_check(handles); end

cp_old = get(gcf,'position');
size_old = handles.size;
set(gcf,'paperunits','inches');
set(gcf,'paperposition',[0.25 0.25 10.5 8]);
set(gcf,'units','points','paperunits','points')
cp = get(gcf,'position');
pp = get(gcf,'paperposition');

handles.currsize = cp(3:4);
handles.size = handles.size * (cp(3) / cp_old(3));
handles.redraw_on_resize = 1;
guidata(hObject, handles);

pause(0.1);
set(gcf,'position',[20 20 pp(3) pp(4)]);
orient landscape

handles = session_button(find(handles.buttons == 1),handles);

saveas(gcf,'C:\WaterMeisterFigure_temp.fig'); pause(0.1);
!matlab -r "print_WM_figure"

set(gcf,'units','pixels','paperunits','inches');
cp = get(gcf,'position');
handles.currsize = cp(3:4);
handles.size = size_old;

guidata(hObject, handles);
pause(0.1);
set(gcf,'position',cp_old);
pause(0.1);
handles.redraw_on_resize = 0;
guidata(hObject, handles);




% --- Executes on button press in watertime_button.
function watertime_button_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>

global button_state
S = find(button_state(1:9) == 1);
if ~isempty(S)
    wt = handles.waittime(S);
    h = floor(wt / 3600); wt = wt - (3600 * h);
    m = floor(wt / 60);
    
    nwt = inputdlg({'Water Duration Hours:','Water Duration Minutes:'},...
        ['Session ',num2str(S)],1,{num2str(h),num2str(m)});
    if isempty(nwt); return; end
    wt = (str2num(nwt{1}) * 3600) + (str2num(nwt{2}) * 60); %#ok<ST2NM>
    handles.waittime(S) = wt;
    
    WT = handles.waittime; %#ok<NASGU>
    try
        save('C:\ratter\ExperPort\Utility\WaterMeister\waittimes.mat','WT');
    catch %#ok<CTCH>
        disp('Could not save new water duration...');
    end
    guidata(hObject, handles);
end


% --- Executes on button press in multientry_toggle.
function multientry_toggle_Callback(hObject, eventdata, handles)

global button_state comp

if get(handles.multientry_toggle,'value') == 1
    set(handles.multientry_toggle,'string','ON','BackgroundColor',[0 1 0]);
    
    if strcmp(get(handles.startstop_toggle,'string'),'Complete')
        set(handles.startstop_toggle,'string','Start','fontsize',calcfontsize(36,handles),'BackgroundColor',[0 1 0],'enable','on');
    end
else
    set(handles.multientry_toggle,'string','OFF','BackgroundColor',[1 0 0]);
end

guidata(hObject,handles);
    



% --- Executes on button press in manual_button.
function manual_button_Callback(hObject, eventdata, handles)

global button_state comp

if all(button_state(1:10) == 0); ratnames = '';
elseif isempty(handles.rats);    ratnames = ''; 
else                             ratnames = handles.rats;
end

names = get(handles.initials_edit,'string');
name = names{get(handles.initials_edit,'value')};
if strcmp(name,'Name')
    msgbox('Please enter your name.');
    set(handles.startstop_toggle,'enable','on');
    return;
else
    [E,I] = bdata('select experimenter, initials from ratinfo.contacts where is_alumni=0');
    initials = I{strcmp(E,name)};
end

if iscell(ratnames);
    ratnames(strcmp(ratnames,'')) = [];
    rn = ratnames{1};
    for i = 2:numel(ratnames)
        rn(end+1:end+numel(ratnames{i})+1) = [',',ratnames{i}];
    end
    ratnames = rn;
end

output = inputdlg({'Rat Names (comma separated):','Date: (yyyy-mm-dd)','Start Time: (hh:mm:ss)','Stop Time: (leave blank if still watering)'},'Manual Water Entry',...
    [1 max([numel(ratnames),100]); 1 50; 1 50; 1 50],...
    {ratnames,datestr(now,'yyyy-mm-dd'),datestr(now,'HH:MM:SS'),datestr(now,'HH:MM:SS')});

if isempty(output); return; end

ratnames  = output{1};
waterdate = output{2};
starttime = output{3};
stoptime  = output{4};

if isempty(stoptime); stoptime=starttime; end

allrats = bdata(['select ratname from ratinfo.rats where extant=1 and israt=',num2str(handles.ratrig)]);

ratnames(ratnames == ' ') = '';
sep = [0,find(ratnames == ','),numel(ratnames)+1];
R = cell(0);
for i = 1:numel(sep)-1
    temp = ratnames(sep(i)+1:sep(i+1)-1);
    if sum(strcmp(allrats,temp)) == 1
        R{end+1} = temp;
    end
end

if isempty(R); return; end
try
    test1 = datenum(starttime,'HH:MM:SS');
    test2 = datenum(stoptime, 'HH:MM:SS');
    test3 = datenum(waterdate,'yyyy-mm-dd');
catch
    return;
end


for i = 1:numel(R)
    bdata('INSERT INTO ratinfo.water (date, rat, tech, starttime, stoptime) values ("{S}","{S}","{S}","{S}","{S}")',...
        waterdate,R{i},initials,starttime,stoptime);
    disp(['Added Rat ',R{i},' to ratinfo.water by ',initials,' from ',starttime,' to ',stoptime,' on ',waterdate]);
end

handles = init_check(handles);
guidata(hObject,handles);



% --- Executes on button press in watertype_toggle.
function watertype_toggle_Callback(hObject, eventdata, handles)

if get(handles.watertype_toggle,'value') == 0
    set(handles.watertype_toggle,'string','Plain','fontsize',16,'backgroundcolor',[0.941 0.941 0.941],'foregroundcolor',[0,0,0])
else
    set(handles.watertype_toggle,'string','CitricAcid','fontsize',12,'backgroundcolor',[0.8 0.7 0.2])
end

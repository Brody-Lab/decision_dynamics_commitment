function varargout = GCS_Message(varargin)
% GCS_MESSAGE M-file for GCS_Message.fig
%      GCS_MESSAGE, by itself, creates a new GCS_MESSAGE or raises the existing
%      singleton*.
%
%      H = GCS_MESSAGE returns the handle to a new GCS_MESSAGE or the handle to
%      the existing singleton*.
%
%      GCS_MESSAGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GCS_MESSAGE.M with the given input arguments.
%
%      GCS_MESSAGE('Property','Value',...) creates a new GCS_MESSAGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GCS_Message_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GCS_Message_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GCS_Message

% Last Modified by GUIDE v2.5 19-Oct-2011 16:40:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GCS_Message_OpeningFcn, ...
                   'gui_OutputFcn',  @GCS_Message_OutputFcn, ...
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


% --- Executes just before GCS_Message is made visible.
function GCS_Message_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>

warning('off','all')

if numel(varargin{1}) >= 3 && varargin{1}{3} == 99
    set(handles.title_text,  'string',['EMERGENCY from ',upper(varargin{1}{1})]);
else
    set(handles.title_text,  'string',['Message from ',upper(varargin{1}{1})]);
end

MS = char(varargin{1}{2});

set(handles.message_text,'string',MS);
handles.ID = varargin{1}{3};
set(gcf,'visible','on');
handles.message_received = 0;
handles.mode = 'reading';

if ischar(varargin{1}{3})
    %The user is reviewing thir sent messages
    if strcmp(varargin{1}{1},'Tech Computer')
        set(handles.title_text,  'string',['Message on ',varargin{1}{1}]);
    else
        set(handles.title_text,  'string',['Message on Rig ',varargin{1}{1}]);
    end
    set(handles.receipt_button,'string',['Received at ',varargin{1}{3}]);
    if strcmp(varargin{1}{3},'Message NOT Received') || strcmp(varargin{1}{3},'Message Never Posted')
        set(handles.receipt_button,'backgroundcolor',[1 0 0],'string',varargin{1}{3}); 
    end
    handles.message_received = 1;
    handles.mode = 'reviewing';
else
    try %#ok<TRYNC>
        pause(1);
        jf=get(gcf,'JavaFrame');
        pause(1);
        javaMethod('setAlwaysOnTop', jf.fFigureClient.getWindow, 1);
    end
end

if isempty(varargin{1}{3}) || varargin{1}{3} == 99
    %The user is entering their message
    handles.message_received = 1;
    set(handles.message_text,'style','edit','string','Enter your message here.');
    set(handles.receipt_button,'string','Send');
    handles.mode = 'sending';    
end

handles.output = hObject;
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = GCS_Message_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL>

if strcmp(get(handles.message_text,'style'),'edit') == 1
    uicontrol(handles.message_text);
    while strcmp(get(handles.message_text,'style'),'edit') == 1
        pause(0.1);
    end
    varargout{1} = get(handles.message_text,'string');
    close(gcf);
else
    varargout{1} = hObject;
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

if handles.message_received == 1
    delete(hObject);
    %Close matlab if this message is being read, not sent
    if strcmp(handles.mode,'reading'); exit; end
else
    h = msgbox('','','warn');
    pos = get(h,'position');
    set(h,'position',[pos(1),pos(2),325,100]);
    c = get(get(h,'children'),'children');
    set(c{2},'string',{'Please acknowledge that you have read','the message before attempting to close.'});
    set(c{2},'fontsize',14);
    
    try
        pause(1);
        jf=get(gcf,'JavaFrame');
        pause(1);
        javaMethod('setAlwaysOnTop', jf.fFigureClient.getWindow, 1);
    end
end


% --- Executes on button press in receipt_button.
function receipt_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

if strcmp(get(handles.message_text,'style'),'edit')
    %The user is sending a message
    set(handles.message_text,'style','text');
    guidata(hObject,handles);
else
    %The tech is acknowledging the message
    set(handles.receipt_button,'string','Message Marked as Received','backgroundcolor',[0.8 0.8 0.8]);
    handles.message_received = 1;
    bdata('call bdata.mark_gcs_received("{Si}","{S}")',handles.ID,datestr(now,'yyyy-mm-dd HH:MM:SS'));
end
guidata(hObject,handles);


% --- Executes on button press in receipt_button.
function message_text_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

set(handles.message_text,'style','text');
guidata(hObject,handles);




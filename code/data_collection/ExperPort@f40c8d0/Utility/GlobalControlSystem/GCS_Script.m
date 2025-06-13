function varargout = GCS_Script(varargin)
% GCS_SCRIPT M-file for GCS_Script.fig
%      GCS_SCRIPT, by itself, creates a new GCS_SCRIPT or raises the existing
%      singleton*.
%
%      H = GCS_SCRIPT returns the handle to a new GCS_SCRIPT or the handle to
%      the existing singleton*.
%
%      GCS_SCRIPT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GCS_SCRIPT.M with the given input arguments.
%
%      GCS_SCRIPT('Property','Value',...) creates a new GCS_SCRIPT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GCS_Script_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GCS_Script_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GCS_Script

% Last Modified by GUIDE v2.5 27-Oct-2011 21:54:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GCS_Script_OpeningFcn, ...
                   'gui_OutputFcn',  @GCS_Script_OutputFcn, ...
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


% --- Executes just before GCS_Script is made visible.
function GCS_Script_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = GCS_Script_OutputFcn(hObject, eventdata, handles) 

while get(handles.submit_button,'value')==0 && get(handles.cancel_button,'value')==0
    pause(0.1);
end

if get(handles.cancel_button,'value') == 1
    varargout{1} = '';
else
    varargout{1} = get(handles.script_text,'string');
end
close(gcf);


function script_text_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function script_text_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in submit_button.
function submit_button_Callback(hObject, eventdata, handles)

% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles)



function varargout = GCS_Confirm(varargin)
% GCS_CONFIRM M-file for GCS_Confirm.fig
%      GCS_CONFIRM, by itself, creates a new GCS_CONFIRM or raises the existing
%      singleton*.
%
%      H = GCS_CONFIRM returns the handle to a new GCS_CONFIRM or the handle to
%      the existing singleton*.
%
%      GCS_CONFIRM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GCS_CONFIRM.M with the given input arguments.
%
%      GCS_CONFIRM('Property','Value',...) creates a new GCS_CONFIRM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GCS_Confirm_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GCS_Confirm_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GCS_Confirm

% Last Modified by GUIDE v2.5 18-Oct-2011 16:25:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GCS_Confirm_OpeningFcn, ...
                   'gui_OutputFcn',  @GCS_Confirm_OutputFcn, ...
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


% --- Executes just before GCS_Confirm is made visible.
function GCS_Confirm_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>

%Let's find the position of the GlobalControlSystem
c = get(0,'children');
for i = 1:length(c); 
    if strcmp(get(c(i),'name'),'GlobalControlSystem'); break; end; 
end
posp = get(c(i),'position');
posc = get(gcf, 'position');

set(gcf,'position',[posp(1)+200,posp(2)+100,posc(3),posc(4)]);


handles.output = hObject;
set(handles.job_text, 'string',varargin{1}{1});
set(handles.name_text,'string',upper(varargin{1}{2}),'fontweight','bold');

% Update handles structure
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = GCS_Confirm_OutputFcn(hObject, eventdata, handles)  %#ok<INUSD>

waitforbuttonpress;
varargout{1} = get(gco,'string');
close(gcf);


% --- Executes on button press in confirm_button.
function confirm_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

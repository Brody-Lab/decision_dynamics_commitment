function varargout = MouseMassMeister_Properties(varargin)
% MouseMassMeister_PROPERTIES M-file for MouseMassMeister_Properties.fig
%      MouseMassMeister_PROPERTIES, by itself, creates a new MouseMassMeister_PROPERTIES or raises the existing
%      singleton*.
%
%      H = MouseMassMeister_PROPERTIES returns the handle to a new MouseMassMeister_PROPERTIES or the handle to
%      the existing singleton*.
%
MouseMassMeister
%      function named CALLBACK in MouseMassMeister_PROPERTIES.M with the given input arguments.
%
%      MouseMassMeister_PROPERTIES('Property','Value',...) creates a new MouseMassMeister_PROPERTIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MouseMassMeister_Properties_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MouseMassMeister_Properties_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MouseMassMeister_Properties

% Last Modified by GUIDE v2.5 28-Feb-2019 14:05:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MouseMassMeister_Properties_OpeningFcn, ...
                   'gui_OutputFcn',  @MouseMassMeister_Properties_OutputFcn, ...
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


% --- Executes just before MouseMassMeister_Properties is made visible.
function MouseMassMeister_Properties_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

handles = load_settings(handles);

guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = MouseMassMeister_Properties_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;



function minmass_edit_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function minmass_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rate_edit_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function rate_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numreads_edit_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function numreads_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function threshold_edit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function threshold_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in enter_button.
function enter_button_Callback(hObject, eventdata, handles)

properties.minmass   = str2num(get(handles.minmass_edit,  'string'));
properties.rate      = str2num(get(handles.rate_edit,     'string'));
properties.numreads  = str2num(get(handles.numreads_edit, 'string'));
properties.threshold = str2num(get(handles.threshold_edit,'string'));
properties.error     = str2num(get(handles.error_edit,    'string'));
properties.smallrat  = str2num(get(handles.smallrat_edit, 'string'));
    
save(handles.file,'properties');    
close(gcf);

% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles)

close(gcf);



function error_edit_Callback(hObject, eventdata, handles)
% hObject    handle to error_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of error_edit as text
%        str2double(get(hObject,'String')) returns contents of error_edit as a double


% --- Executes during object creation, after setting all properties.
function error_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to error_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function smallrat_edit_Callback(hObject, eventdata, handles)
% hObject    handle to smallrat_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smallrat_edit as text
%        str2double(get(hObject,'String')) returns contents of smallrat_edit as a double


% --- Executes during object creation, after setting all properties.
function smallrat_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smallrat_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

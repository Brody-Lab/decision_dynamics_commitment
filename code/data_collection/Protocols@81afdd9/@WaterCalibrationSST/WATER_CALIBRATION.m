function varargout = WATER_CALIBRATION(varargin)
% WATER_CALIBRATION M-file for WATER_CALIBRATION.fig
%      WATER_CALIBRATION, by itself, creates a new WATER_CALIBRATION or raises the existing
%      singleton*.
%
%      H = WATER_CALIBRATION returns the handle to a new WATER_CALIBRATION or the handle to
%      the existing singleton*.
%
%      WATER_CALIBRATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WATER_CALIBRATION.M with the given input arguments.
%
%      WATER_CALIBRATION('Property','Value',...) creates a new WATER_CALIBRATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before WATER_CALIBRATION_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to WATER_CALIBRATION_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help WATER_CALIBRATION

% Last Modified by GUIDE v2.5 16-Nov-2009 12:51:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @WATER_CALIBRATION_OpeningFcn, ...
                   'gui_OutputFcn',  @WATER_CALIBRATION_OutputFcn, ...
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


% --- Executes just before WATER_CALIBRATION is made visible.
function WATER_CALIBRATION_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to WATER_CALIBRATION (see VARARGIN)

% Choose default command line output for WATER_CALIBRATION
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes WATER_CALIBRATION wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = WATER_CALIBRATION_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function settings_ipi_Callback(hObject, eventdata, handles)
% hObject    handle to settings_ipi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of settings_ipi as text
%        str2double(get(hObject,'String')) returns contents of settings_ipi as a double


% --- Executes during object creation, after setting all properties.
function settings_ipi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to settings_ipi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function settings_npulses_Callback(hObject, eventdata, handles)
% hObject    handle to settings_npulses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of settings_npulses as text
%        str2double(get(hObject,'String')) returns contents of settings_npulses as a double


% --- Executes during object creation, after setting all properties.
function settings_npulses_CreateFcn(hObject, eventdata, handles)
% hObject    handle to settings_npulses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function settings_errtolerance_Callback(hObject, eventdata, handles)
% hObject    handle to settings_errtolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of settings_errtolerance as text
%        str2double(get(hObject,'String')) returns contents of settings_errtolerance as a double


% --- Executes during object creation, after setting all properties.
function settings_errtolerance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to settings_errtolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in WaterCalibrationTable.
function WaterCalibrationTable_Callback(hObject, eventdata, handles)
% hObject    handle to WaterCalibrationTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns WaterCalibrationTable contents as cell array
%        contents{get(hObject,'Value')} returns selected item from WaterCalibrationTable


% --- Executes during object creation, after setting all properties.
function WaterCalibrationTable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WaterCalibrationTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnSaveTableAndExit.
function btnSaveTableAndExit_Callback(hObject, eventdata, handles)
% hObject    handle to btnSaveTableAndExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnExit.
function btnExit_Callback(hObject, eventdata, handles)
% hObject    handle to btnExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnStartCalibrationLowTarget.
function btnStartCalibrationLowTarget_Callback(hObject, eventdata, handles)
% hObject    handle to btnStartCalibrationLowTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnStartCalibrationHighTarget.
function btnStartCalibrationHighTarget_Callback(hObject, eventdata, handles)
% hObject    handle to btnStartCalibrationHighTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnHelp.
function btnHelp_Callback(hObject, eventdata, handles)
% hObject    handle to btnHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LeftPulseTime_Callback(hObject, eventdata, handles)
% hObject    handle to LEFT_PULSE_TIME_SECONDS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LEFT_PULSE_TIME_SECONDS as text
%        str2double(get(hObject,'String')) returns contents of LEFT_PULSE_TIME_SECONDS as a double


% --- Executes during object creation, after setting all properties.
function LeftPulseTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LEFT_PULSE_TIME_SECONDS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LeftWeightMeasured_Callback(hObject, eventdata, handles)
% hObject    handle to LeftWeightMeasured (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LeftWeightMeasured as text
%        str2double(get(hObject,'String')) returns contents of LeftWeightMeasured as a double


% --- Executes during object creation, after setting all properties.
function LeftWeightMeasured_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LeftWeightMeasured (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LeftActualDispense_Callback(hObject, eventdata, handles)
% hObject    handle to LeftActualDispense (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LeftActualDispense as text
%        str2double(get(hObject,'String')) returns contents of LeftActualDispense as a double


% --- Executes during object creation, after setting all properties.
function LeftActualDispense_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LeftActualDispense (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LeftTargetDispense_Callback(hObject, eventdata, handles)
% hObject    handle to LeftTargetDispense (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LeftTargetDispense as text
%        str2double(get(hObject,'String')) returns contents of LeftTargetDispense as a double


% --- Executes during object creation, after setting all properties.
function LeftTargetDispense_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LeftTargetDispense (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RightWeightMeasured_Callback(hObject, eventdata, handles)
% hObject    handle to RightWeightMeasured (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RightWeightMeasured as text
%        str2double(get(hObject,'String')) returns contents of RightWeightMeasured as a double


% --- Executes during object creation, after setting all properties.
function RightWeightMeasured_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RightWeightMeasured (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RightActualDispense_Callback(hObject, eventdata, handles)
% hObject    handle to RightActualDispense (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RightActualDispense as text
%        str2double(get(hObject,'String')) returns contents of RightActualDispense as a double


% --- Executes during object creation, after setting all properties.
function RightActualDispense_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RightActualDispense (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RightTargetDispense_Callback(hObject, eventdata, handles)
% hObject    handle to RightTargetDispense (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RightTargetDispense as text
%        str2double(get(hObject,'String')) returns contents of RightTargetDispense as a double


% --- Executes during object creation, after setting all properties.
function RightTargetDispense_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RightTargetDispense (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RightPulseTime_Callback(hObject, eventdata, handles)
% hObject    handle to RIGHT_PULSE_TIME_SECONDS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RIGHT_PULSE_TIME_SECONDS as text
%        str2double(get(hObject,'String')) returns contents of RIGHT_PULSE_TIME_SECONDS as a double


% --- Executes during object creation, after setting all properties.
function RightPulseTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RIGHT_PULSE_TIME_SECONDS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CenterWeightMeasured_Callback(hObject, eventdata, handles)
% hObject    handle to CenterWeightMeasured (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CenterWeightMeasured as text
%        str2double(get(hObject,'String')) returns contents of CenterWeightMeasured as a double


% --- Executes during object creation, after setting all properties.
function CenterWeightMeasured_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CenterWeightMeasured (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CenterActualDispense_Callback(hObject, eventdata, handles)
% hObject    handle to CenterActualDispense (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CenterActualDispense as text
%        str2double(get(hObject,'String')) returns contents of CenterActualDispense as a double


% --- Executes during object creation, after setting all properties.
function CenterActualDispense_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CenterActualDispense (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CenterTargetDispense_Callback(hObject, eventdata, handles)
% hObject    handle to CenterTargetDispense (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CenterTargetDispense as text
%        str2double(get(hObject,'String')) returns contents of CenterTargetDispense as a double


% --- Executes during object creation, after setting all properties.
function CenterTargetDispense_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CenterTargetDispense (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CenterPulseTime_Callback(hObject, eventdata, handles)
% hObject    handle to CENTER_PULSE_TIME_SECONDS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CENTER_PULSE_TIME_SECONDS as text
%        str2double(get(hObject,'String')) returns contents of CENTER_PULSE_TIME_SECONDS as a double


% --- Executes during object creation, after setting all properties.
function CenterPulseTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CENTER_PULSE_TIME_SECONDS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnCustomizeSettings.
function btnCustomizeSettings_Callback(hObject, eventdata, handles)
% hObject    handle to btnCustomizeSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function CENTER_PULSE_TIME_SECONDS_Callback(hObject, eventdata, handles)
% hObject    handle to CENTER_PULSE_TIME_SECONDS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CENTER_PULSE_TIME_SECONDS as text
%        str2double(get(hObject,'String')) returns contents of CENTER_PULSE_TIME_SECONDS as a double


% --- Executes during object creation, after setting all properties.
function CENTER_PULSE_TIME_SECONDS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CENTER_PULSE_TIME_SECONDS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ERROR_TOLERANCE_MICROLITERS_Callback(hObject, eventdata, handles)
% hObject    handle to ERROR_TOLERANCE_MICROLITERS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ERROR_TOLERANCE_MICROLITERS as text
%        str2double(get(hObject,'String')) returns contents of ERROR_TOLERANCE_MICROLITERS as a double


% --- Executes during object creation, after setting all properties.
function ERROR_TOLERANCE_MICROLITERS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ERROR_TOLERANCE_MICROLITERS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HIGH_TARGET_MICROLITERS_Callback(hObject, eventdata, handles)
% hObject    handle to HIGH_TARGET_MICROLITERS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HIGH_TARGET_MICROLITERS as text
%        str2double(get(hObject,'String')) returns contents of HIGH_TARGET_MICROLITERS as a double


% --- Executes during object creation, after setting all properties.
function HIGH_TARGET_MICROLITERS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HIGH_TARGET_MICROLITERS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function INTER_PULSE_INTERVAL_SECONDS_Callback(hObject, eventdata, handles)
% hObject    handle to INTER_PULSE_INTERVAL_SECONDS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of INTER_PULSE_INTERVAL_SECONDS as text
%        str2double(get(hObject,'String')) returns contents of INTER_PULSE_INTERVAL_SECONDS as a double


% --- Executes during object creation, after setting all properties.
function INTER_PULSE_INTERVAL_SECONDS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to INTER_PULSE_INTERVAL_SECONDS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LEFT_PULSE_TIME_SECONDS_Callback(hObject, eventdata, handles)
% hObject    handle to LEFT_PULSE_TIME_SECONDS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LEFT_PULSE_TIME_SECONDS as text
%        str2double(get(hObject,'String')) returns contents of LEFT_PULSE_TIME_SECONDS as a double


% --- Executes during object creation, after setting all properties.
function LEFT_PULSE_TIME_SECONDS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LEFT_PULSE_TIME_SECONDS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LOW_TARGET_MICROLITERS_Callback(hObject, eventdata, handles)
% hObject    handle to LOW_TARGET_MICROLITERS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LOW_TARGET_MICROLITERS as text
%        str2double(get(hObject,'String')) returns contents of LOW_TARGET_MICROLITERS as a double


% --- Executes during object creation, after setting all properties.
function LOW_TARGET_MICROLITERS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LOW_TARGET_MICROLITERS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function WEIGHT_OF_CUP_GRAMS_Callback(hObject, eventdata, handles)
% hObject    handle to WEIGHT_OF_CUP_GRAMS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WEIGHT_OF_CUP_GRAMS as text
%        str2double(get(hObject,'String')) returns contents of WEIGHT_OF_CUP_GRAMS as a double


% --- Executes during object creation, after setting all properties.
function WEIGHT_OF_CUP_GRAMS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WEIGHT_OF_CUP_GRAMS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RIGHT_PULSE_TIME_SECONDS_Callback(hObject, eventdata, handles)
% hObject    handle to RIGHT_PULSE_TIME_SECONDS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RIGHT_PULSE_TIME_SECONDS as text
%        str2double(get(hObject,'String')) returns contents of RIGHT_PULSE_TIME_SECONDS as a double


% --- Executes during object creation, after setting all properties.
function RIGHT_PULSE_TIME_SECONDS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RIGHT_PULSE_TIME_SECONDS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NUMBER_OF_PULSES_Callback(hObject, eventdata, handles)
% hObject    handle to NUMBER_OF_PULSES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NUMBER_OF_PULSES as text
%        str2double(get(hObject,'String')) returns contents of NUMBER_OF_PULSES as a double


% --- Executes during object creation, after setting all properties.
function NUMBER_OF_PULSES_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NUMBER_OF_PULSES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit28_Callback(hObject, eventdata, handles)
% hObject    handle to ERROR_TOLERANCE_MICROLITERS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ERROR_TOLERANCE_MICROLITERS as text
%        str2double(get(hObject,'String')) returns contents of ERROR_TOLERANCE_MICROLITERS as a double


% --- Executes during object creation, after setting all properties.
function edit28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ERROR_TOLERANCE_MICROLITERS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit29_Callback(hObject, eventdata, handles)
% hObject    handle to HIGH_TARGET_MICROLITERS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HIGH_TARGET_MICROLITERS as text
%        str2double(get(hObject,'String')) returns contents of HIGH_TARGET_MICROLITERS as a double


% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HIGH_TARGET_MICROLITERS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit30_Callback(hObject, eventdata, handles)
% hObject    handle to INTER_PULSE_INTERVAL_SECONDS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of INTER_PULSE_INTERVAL_SECONDS as text
%        str2double(get(hObject,'String')) returns contents of INTER_PULSE_INTERVAL_SECONDS as a double


% --- Executes during object creation, after setting all properties.
function edit30_CreateFcn(hObject, eventdata, handles)
% hObject    handle to INTER_PULSE_INTERVAL_SECONDS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit31_Callback(hObject, eventdata, handles)
% hObject    handle to LOW_TARGET_MICROLITERS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LOW_TARGET_MICROLITERS as text
%        str2double(get(hObject,'String')) returns contents of LOW_TARGET_MICROLITERS as a double


% --- Executes during object creation, after setting all properties.
function edit31_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LOW_TARGET_MICROLITERS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit32_Callback(hObject, eventdata, handles)
% hObject    handle to WEIGHT_OF_CUP_GRAMS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WEIGHT_OF_CUP_GRAMS as text
%        str2double(get(hObject,'String')) returns contents of WEIGHT_OF_CUP_GRAMS as a double


% --- Executes during object creation, after setting all properties.
function edit32_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WEIGHT_OF_CUP_GRAMS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit33_Callback(hObject, eventdata, handles)
% hObject    handle to NUMBER_OF_PULSES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NUMBER_OF_PULSES as text
%        str2double(get(hObject,'String')) returns contents of NUMBER_OF_PULSES as a double


% --- Executes during object creation, after setting all properties.
function edit33_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NUMBER_OF_PULSES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnSuggestPulseTimes.
function btnSuggestPulseTimes_Callback(hObject, eventdata, handles)
% hObject    handle to btnSuggestPulseTimes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in WaterCalibrationTable.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to WaterCalibrationTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns WaterCalibrationTable contents as cell array
%        contents{get(hObject,'Value')} returns selected item from WaterCalibrationTable


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WaterCalibrationTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnInterruptCalibration.
function btnInterruptCalibration_Callback(hObject, eventdata, handles)
% hObject    handle to btnInterruptCalibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnRestartCalibrationProcess.
function btnRestartCalibrationProcess_Callback(hObject, eventdata, handles)
% hObject    handle to btnRestartCalibrationProcess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnIgnoreSelectedEntries.
function btnIgnoreSelectedEntries_Callback(hObject, eventdata, handles)
% hObject    handle to btnIgnoreSelectedEntries (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnAcceptSelectedEntries.
function btnAcceptSelectedEntries_Callback(hObject, eventdata, handles)
% hObject    handle to btnAcceptSelectedEntries (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editUserInitials_Callback(hObject, eventdata, handles)
% hObject    handle to editUserInitials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editUserInitials as text
%        str2double(get(hObject,'String')) returns contents of editUserInitials as a double


% --- Executes during object creation, after setting all properties.
function editUserInitials_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editUserInitials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



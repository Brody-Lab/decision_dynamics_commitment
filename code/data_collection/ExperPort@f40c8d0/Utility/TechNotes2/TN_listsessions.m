function handles = TN_listsessions(handles)

handles = TN_clear(handles);

set(handles.rat_button,'value',0);
set(handles.rig_button,'value',0);
set(handles.tower_button,'value',0);
%set(handles.session_button,'value',0);
set(handles.experimenter_button,'value',0);
set(handles.general_button,'value',0);
set(handles.room_button,'value',0);


sessions = {'1';'2';'3';'4';'5';'6';'7';'8';'9'};

set(handles.items_edit,'string',sessions);
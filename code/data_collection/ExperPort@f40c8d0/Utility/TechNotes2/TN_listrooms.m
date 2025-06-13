function handles = TN_listrooms(handles)

handles = TN_clear(handles);

set(handles.rat_button,'value',0);
set(handles.rig_button,'value',0);
set(handles.tower_button,'value',0);
set(handles.session_button,'value',0);
set(handles.experimenter_button,'value',0);
set(handles.general_button,'value',0);
%set(handles.room_button,'value',0);

rooms = {'186: Rats';'165: Mice'};    

set(handles.items_edit,'string',rooms);
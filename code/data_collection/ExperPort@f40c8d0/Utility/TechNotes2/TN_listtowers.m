function handles = TN_listtowers(handles)

handles = TN_clear(handles);

set(handles.rat_button,'value',0);
set(handles.rig_button,'value',0);
%set(handles.tower_button,'value',0);
set(handles.session_button,'value',0);
set(handles.experimenter_button,'value',0);
set(handles.general_button,'value',0);
set(handles.room_button,'value',0);

towers = {'1,2,3';'4,5,6';'7,8,9';'10,11,12';'13,14,15';'16,17,18';'19,20,21';...
         '22,23,24';'25,26,27';'28,29,30';'31,32,33';'34,35,36'};

set(handles.items_edit,'string',towers);
function handles = TN_listrats(handles)

handles = TN_clear(handles);

%set(handles.rat_button,'value',0);
set(handles.rig_button,'value',0);
set(handles.tower_button,'value',0);
set(handles.session_button,'value',0);
set(handles.experimenter_button,'value',0);
set(handles.general_button,'value',0);
set(handles.room_button,'value',0);

    
rats = bdata('select ratname from ratinfo.rats where extant="1"');
rats = unique(rats);
rats(strcmp(rats,'')) = [];

set(handles.items_edit,'string',rats);

function handles = TN_listrigs(handles)

handles = TN_clear(handles);

set(handles.rat_button,'value',0);
%set(handles.rig_button,'value',0);
set(handles.tower_button,'value',0);
set(handles.session_button,'value',0);
set(handles.experimenter_button,'value',0);
set(handles.general_button,'value',0);
set(handles.room_button,'value',0);


rigs = bdata(['select rig from ratinfo.schedule where date="',datestr(now,'yyyy-mm-dd'),'"']);
rigs = unique(rigs);
rigs(strcmp(rigs,'')) = [];
rigs = [rigs;[301:336]'];

for i = 1:length(rigs); R{i} = num2str(rigs(i)); end %#ok<AGROW>
R = R';

set(handles.items_edit,'string',R);
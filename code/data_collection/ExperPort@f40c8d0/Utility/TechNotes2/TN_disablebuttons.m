function handles = TN_disablebuttons(handles,group,varargin)

if nargin < 2; group = 'all'; end

if strcmp(group,'all')
    set(handles.rat_button,         'enable','off');
    set(handles.rig_button,         'enable','off');
    set(handles.tower_button,       'enable','off');
    set(handles.session_button,     'enable','off');
    set(handles.experimenter_button,'enable','off');
    set(handles.general_button,     'enable','off');
    set(handles.room_button,        'enable','off');
    set(handles.roomempty_button,   'enable','off');
    set(handles.pubempty_button,    'enable','off');
end

if strcmp(group,'all') || strcmp(group,'management')
    set(handles.cagemate_button,    'enable','off');
    set(handles.training_button,    'enable','off');
    set(handles.freewater_button,   'enable','off');
    set(handles.recovery_button,    'enable','off');
    set(handles.hematuria_button,   'enable','off');
    set(handles.sick_button,        'enable','off');
    set(handles.missing_button,     'enable','off');
    set(handles.dead_button,        'enable','off');
    set(handles.emergency_button,   'enable','off');
    set(handles.submit_button,      'enable','off');
end
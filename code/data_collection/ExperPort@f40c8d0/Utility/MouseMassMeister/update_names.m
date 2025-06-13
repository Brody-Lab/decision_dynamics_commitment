function handles = update_names(handles)

try
     [N I] = bdata(['select experimenter, initials from ratinfo.contacts where is_alumni=0',...
         ' order by experimenter']);
catch %#ok<CTCH>
    set(handles.status_text,'string','ERROR: Unable to connect to network.',...
        'backgroundcolor',[1 0 0]);
    handles.initials = {''};
    return
end

set(handles.user_menu,'string',[{'Select Name'};N]);
handles.initials = [{''};I];
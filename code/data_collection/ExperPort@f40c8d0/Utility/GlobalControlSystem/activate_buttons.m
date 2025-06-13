function handles = activate_buttons(handles)

handles.password = get(handles.password_edit,'string');
password = handles.password;

if GCS_checkpassword(handles.password) == 1
    handles.goodpassword = 1;
    password(:) = '*';
    set(handles.password_edit,'string',password);
elseif GCS_checkpassword(handles.password) == 2
    handles.goodpassword = 2;
    password(:) = '*';
    set(handles.password_edit,'string',password);
end

IPaddress = get_network_info;

if ~strcmp(IPaddress(1:7),'128.112')
    fullcontrol = 0;
else
    fullcontrol = 1;
end


if get(handles.name_menu,'value') > 1 && handles.goodpassword > 0
    if fullcontrol == 1
        set(handles.monitoron_button, 'enable','on');
        set(handles.monitoroff_button,'enable','on');
       %set(handles.bcg_button,       'enable','on');
        set(handles.runrats_button,   'enable','on');
        set(handles.computers_button, 'enable','on');
        set(handles.update_button,    'enable','on');
       %set(handles.updatetime_button,'enable','on');
        set(handles.emergency_button, 'enable','on');
        if handles.goodpassword == 2
            set(handles.runscript_button,'enable','on');
        else
            set(handles.runscript_button,'enable','off');
        end
    else
        msgbox('You must VPN into Princeton to have full access to GCS fuctions.')
    end
    set(handles.message_button,  'enable','on');    
    
else
    if get(handles.name_menu,'value') > 1
        set(handles.read_button, 'enable','on');
        set(handles.emergency_button,'enable','on');
    else
        set(handles.read_button, 'enable','off');
        set(handles.emergency_button,'enable','off');
    end
    set(handles.monitoron_button, 'enable','off');
    set(handles.monitoroff_button,'enable','off');
   %set(handles.bcg_button,       'enable','off');
    set(handles.runrats_button,   'enable','off');
    set(handles.computers_button, 'enable','off');
   %set(handles.updatetime_button,'enable','off');
    set(handles.message_button,   'enable','off');
    set(handles.update_button,    'enable','off');
    set(handles.runscript_button, 'enable','off');
    
end



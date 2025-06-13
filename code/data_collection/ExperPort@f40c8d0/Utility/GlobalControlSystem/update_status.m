function handles = update_status(handles)

%E{1} = get(handles.bcg_button,      'enable');
E{1} = get(handles.monitoroff_button,'enable');
E{2} = get(handles.monitoron_button, 'enable');
E{3} = get(handles.runrats_button,   'enable');
E{4} = get(handles.computers_button, 'enable');
E{5} = get(handles.message_button,   'enable');
E{6} = get(handles.update_button,    'enable');
E{7} = get(handles.runscript_button, 'enable');
E{8} = get(handles.read_button,      'enable');

%set(handles.bcg_button,      'enable','off');
set(handles.monitoroff_button,'enable','off');
set(handles.monitoron_button, 'enable','off');
set(handles.runrats_button,   'enable','off');
set(handles.computers_button, 'enable','off');
set(handles.message_button,   'enable','off');
set(handles.update_button,    'enable','off');
set(handles.all_button,       'enable','off');
set(handles.fix_button,       'enable','off');
set(handles.refresh_button,   'enable','off');
set(handles.live_toggle,      'enable','off');
set(handles.name_menu,        'enable','off');
set(handles.password_edit,    'enable','off');
set(handles.read_button,      'enable','off');
set(handles.runscript_button, 'enable','off');
set(handles.viewrig_button,   'enable','off');

starttime = now;
while (now - starttime) * 24 * 60 < 2
    tempstart = now;
    uncompleted = bdata('select computer_name from bdata.gcs where completed=0 and failed=0'); 
    for i = 1:length(handles.compnames)
        
        if sum(strcmp(handles.compnames{i,1},uncompleted)) == 0
            temp = eval(['handles.status',handles.compnames{i,2}]);
            
            if sum(get(temp,'foregroundcolor') == [1 0 0]) == 3
                set(temp,'foregroundcolor',[0 1 0],'string','Completed');
            end
        end
    end
    if isempty(uncompleted); break; end    
    pause(10 - ((now - tempstart) * 24 * 3600));
end

[uncompleted id] = bdata('select computer_name, id from bdata.gcs where completed=0'); 
for i = 1:length(uncompleted)
    temp = find(strcmp(uncompleted{i},handles.compnames(:,1)) == 1,1,'first');
    
    if ~isempty(temp) && temp <= size(handles.compnames,1)
        temp = eval(['handles.status',handles.compnames{temp,2}]);
        set(temp,'foregroundcolor',[1 0 0],'string','FAILED');
    end
    bdata('call bdata.mark_gcs_failed("{Si}")',  id(i));
    bdata('call bdata.mark_gcs_complete("{Si}")',id(i));
end

%set(handles.bcg_button,      'enable',E{1});
set(handles.monitoroff_button,'enable',E{1});
set(handles.monitoron_button, 'enable',E{2});
set(handles.runrats_button,   'enable',E{3});
set(handles.computers_button, 'enable',E{4});
set(handles.message_button,   'enable',E{5});
set(handles.update_button,    'enable',E{6});
set(handles.runscript_button, 'enable',E{7});
set(handles.read_button,      'enable',E{8});
set(handles.all_button,       'enable','on');
set(handles.fix_button,       'enable','on');
set(handles.refresh_button,   'enable','on');
set(handles.live_toggle,      'enable','on');
set(handles.name_menu,        'enable','on');
set(handles.password_edit,    'enable','on');
set(handles.viewrig_button,   'enable','on');

handles.lastrefresh = 0;


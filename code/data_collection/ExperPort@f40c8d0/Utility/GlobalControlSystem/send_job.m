function handles = send_job(handles,job)

if (now - handles.lastrefresh) * 24 * 60 > 1
    warndlg('You must "Refresh" before sending a global command.');
    return;
end

user  = get(handles.name_menu,'value');
names = get(handles.name_menu,'string');

name = names{user};
initials = handles.initials{user};

if     strcmp(job,'bcg');        x = 'Start BCG';         y = 'Starting BCG';
elseif strcmp(job,'runrats');    x = 'Start RunRats';     y = 'Starting RunRats';
elseif strcmp(job,'reboot');     x = 'Restart Computers'; y = 'Rebooting';
elseif strcmp(job,'message');    x = 'Send Message';      y = 'Sending Message';
elseif strcmp(job,'update');     x = 'Update Code';       y = 'Updating Code';
elseif strcmp(job,'run');        x = 'Run Script';        y = 'Running Script';
elseif strcmp(job,'time');       x = 'Update Time';       y = 'Updating Time';
elseif strcmp(job,'monitoroff'); x = 'Monitor Off';    y = 'Turning Off';
elseif strcmp(job,'monitoron');  x = 'Monitor On';     y = 'Turning On';    
end
    

if strcmp(GCS_Confirm({x,name}),'Confirm')
    showwarn = 0;
    for i = 1:length(handles.compnames)
        if get(eval(['handles.rig',handles.compnames{i,2}]),'value') == 1
            str = get(eval(['handles.status',handles.compnames{i,2}]),'string');
            if length(str) > 7 && strcmp(str(1:7),'Running')
                showwarn = 1;
            end
        end
    end
    if showwarn == 1 && ~strcmp(job,'message')
        answer = questdlg('WARNING: Are you sure you want to send a command to a rig that appears to be running a rat?',...
            '','Yes','No','No');
        if strcmp(answer,'No'); return; end
    end 
    
    if strcmp(job,'message')
        name = bdata(['select experimenter, initials from ratinfo.contacts where initials="',initials,'"']);
        message = GCS_Message({name{1},'',[]});
        message = double(message);
        
        M = []; 
        for r=1:size(message,1)
            M = [M,message(r,:),10]; 
        end
        message = num2str(M);
    
    elseif strcmp(job,'run')
        message = GCS_Script;
        
        concat = '';
        if size(message,2)<1, return; end;
        continuing_line_flag = 0;
        for i=1:size(message,1)
            u1 = find(~isspace(message(i,:)), 1,'first');
            if ~isempty(u1) && message(i,u1)~='%',  % ignore empty lines or comment lines
                if i>1 && continuing_line_flag==0, concat = [concat '; ']; end; %#ok<AGROW>
                u2 = find(~isspace(message(i,:)), 1, 'last');
                if u2>=3 && strcmp(message(i,u2-2:u2), '...')
                    concat = [concat message(i, u1:u2-3)]; %#ok<AGROW>
                    continuing_line_flag = 1;
                else
                    concat = [concat message(i,u1:u2)]; %#ok<AGROW>
                    continuing_line_flag = 0;
                end
            end
        end
        message = num2str(double(concat));
        
    elseif strcmp(job,'time')
        message = datestr(now,'mm/dd/yyyy HH:MM:SS PM');
    else
        message = '';
    end
    
    handles.now = datestr(now,'yyyy-mm-dd HH:MM:SS');
    
    id = bdata('select id from gcs');
    handles.id = max(id);
    
    for i = 1:length(handles.compnames)
        if get(eval(['handles.rig',handles.compnames{i,2}]),'value') == 1
            handles.id = handles.id + 1;
            code = GCS_makecode(handles);
            
            bdata(['insert into bdata.gcs set computer_name="',handles.compnames{i,1},...
            '", dateval="',handles.now,'", job="',job,'", completed=0, initials="',...
            initials,'", message="',message,'", code="',code,'"']);

            set(eval(['handles.status',handles.compnames{i,2}]),'string',y,'foregroundcolor',[1 0 0]);
        else
            set(eval(['handles.status',handles.compnames{i,2}]),'string','','foregroundcolor',[1 1 1]);
        end
    end
end
handles = update_status(handles);

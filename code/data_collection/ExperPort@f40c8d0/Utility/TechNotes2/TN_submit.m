function handles = TN_submit(handles)

dstr = get(handles.date_text,'string');
tstr = datestr(now,13);

initials = lower(handles.initials{get(handles.name_menu,'value')});
note = get(handles.note_edit,'string');
if isempty(note); return; end
if get(handles.rat_button,'value') == 1
    
    for i = 1:length(handles.active);
        ratname = handles.active{i};
        bdata('INSERT INTO ratinfo.technotes (datestr, timestr, ratname, techinitials, note) values ("{S}","{S}","{S}","{S}","{S}")',...
            dstr,tstr,ratname,initials,note);
    end
    
elseif get(handles.rig_button,'value') == 1 || get(handles.tower_button,'value') == 1
    
    isbroken = questdlg({'Is this rig broken?','Clicking YES will disable runrats',...
        'preventing anyone from running rats on that rig.'},'','Yes','No','No');
    if strcmp(isbroken,'Yes')
        names = get(handles.name_menu,'string');
        name  = names{get(handles.name_menu,'value')};
        if strcmp(name,''); name = 'unknown'; end
    end
    
    for i = 1:length(handles.active);
        R = handles.active{i};
        if ischar(R); R(R == ',') = ' '; R = str2num(R); end %#ok<ST2NM>
        
        for r = 1:length(R);
            bdata('INSERT INTO ratinfo.technotes (datestr, timestr, rigid, techinitials, note) values ("{S}","{S}","{S}","{S}","{S}")',...
                dstr,tstr,R(r),initials,sprintf('%s\n',note));
            
            if strcmp(isbroken,'Yes')
                bdata(['insert into ratinfo.rig_maintenance set rigid=',num2str(R(r)),', note="{S}", isbroken=1, broke_person="',...
                    name,'", broke_date=now()'],sprintf('%s\n',note));
                
                %If it's between 8am and 7pm let's text the person
                %responsible with repairing the rig or snug
                h = str2num(datestr(now,'HH'));
                if h >= 8 && h <= 19
                    [Experimenters,rigfix] = bdata('select experimenter, tech_shifts from ratinfo.contacts where is_alumni=0');
                    for e = 1:numel(Experimenters)
                        responsiblefor = str2num(rigfix{e});
                        for j = 1:numel(responsiblefor)
                            if R(r) == responsiblefor(j)
                                
                                if R(r) > 299; rigtype = 'Snug';
                                else           rigtype = 'Rig'; 
                                end
                                subject = [rigtype,' ',num2str(R(r)),' Broken'];
                                
                                message = [name,' flagged ',rigtype,' ',num2str(R(r)),' as broken.  ',note,'. Please repair.'];
                                send_text_message(message,subject,Experimenters{e});
                            end
                        end
                    end
                end
            end
        end
    end
    
elseif get(handles.session_button,'value') == 1
    
    for i = 1:length(handles.active);
        S = handles.active{i};
        bdata('INSERT INTO ratinfo.technotes (datestr, timestr, timeslot, techinitials, note) values ("{S}","{S}","{S}","{S}","{S}")',...
            dstr,tstr,S,initials,note);
    end
    
elseif get(handles.experimenter_button,'value') == 1
    
    for i = 1:length(handles.active);
        EXP = handles.active{i};
        bdata('INSERT INTO ratinfo.technotes (datestr, timestr, experimenter, techinitials, note) values ("{S}","{S}","{S}","{S}","{S}")',...
            dstr,tstr,EXP,initials,note);
    end
    
elseif get(handles.room_button,'value') == 1
    %modify note to indicate the room number then submit
    
    raw_note = note;
    if ~isempty(handles.active)
        for i = 1:numel(handles.active)
            if isempty(strfind(raw_note,handles.active))
                note = [handles.active{i},' ',raw_note];
            else
                note = raw_note;
            end
            bdata('INSERT INTO ratinfo.technotes (datestr, timestr, techinitials, note) values ("{S}","{S}","{S}","{S}")',...
                dstr,tstr,initials,note);
        end
    end
    
else
    bdata('INSERT INTO ratinfo.technotes (datestr, timestr, techinitials, note) values ("{S}","{S}","{S}","{S}")',...
        dstr,tstr,initials,note);
end

set(handles.submit_button,'enable','off');

handles = TN_viewold(handles);

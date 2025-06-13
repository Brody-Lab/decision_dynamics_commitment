function handles = TN_emergency(handles)

[contacts ratR] = bdata('select contact, ratname from ratinfo.rats where extant = 1');
[EX EM TL LM TC] = bdata('select experimenter, email, telephone, lab_manager, tech_computer from ratinfo.contacts where is_alumni=0');

for i = 1:length(EM)
    EM{i} = EM{i}(1:find(EM{i}=='@')-1);
end

TEL = cell(length(TL),1);
for i = 1:length(TL)
    temp = num2str(TL(i));
    if     length(temp) == 7;  TEL{i} = [temp(1:3),'-',temp(4:7)];
    elseif length(temp) == 10; TEL{i} = [temp(1:3),'-',temp(4:6),'-',temp(7:10)];
    else                        TEL{i} = temp;
    end
end

if isempty(get(handles.items_edit,'value'))
    LabMan = EX(logical(LM));
    for i = 1:length(LabMan); LabMan{i}(1) = upper(LabMan{i}(1)); end
    
    S = cell(0);
    for i = 1:length(LabMan)
        S{end+1} = 'For Lab Emergencies:'; %#ok<AGROW>
        S{end+1} = 'Lab Manager'; %#ok<AGROW>
        S{end+1} = LabMan{i}; %#ok<AGROW>
        S{end+1} = ['Phone: ',TEL{strcmpi(EX,LabMan{i})}]; %#ok<AGROW>
        S{end+1} = ' '; %#ok<AGROW>
    end
    S{end+1} = 'For All Other Emergencies:'; 
    S{end+1} = 'Phone: 911';
    
    set(handles.note_edit,'string',S');
    
elseif get(handles.experimenter_button,'value') == 1
    S = cell(0);
    for i = 1:length(handles.active)
        S{end+1} = 'Emergency Contact for:'; %#ok<AGROW>
        S{end+1} = [handles.active{i},'']; %#ok<AGROW>
        S{end+1} = ['Phone: ',TEL{strcmpi(EX,handles.active{i})}]; %#ok<AGROW>
        S{end+1} = ' '; %#ok<AGROW>
    end    
    set(handles.note_edit,'string',S');
    
elseif get(handles.session_button,'value') == 1 ||...
       get(handles.tower_button,  'value') == 1 ||...
       get(handles.rig_button,'value') == 1
   
    LabMan = EX(logical(LM));
    for i = 1:length(LabMan); LabMan{i}(1) = upper(LabMan{i}(1)); end
    
    CompTech = EX(logical(TC));
    for i = 1:length(CompTech); CompTech{i}(1) = upper(CompTech{i}(1)); end
    
    S = cell(0);
    for i = 1:length(LabMan)
        S{end+1} = 'Emergency Contact for:'; %#ok<AGROW>
        S{end+1} = 'Lab Manager'; %#ok<AGROW>
        S{end+1} = LabMan{i}; %#ok<AGROW>
        S{end+1} = ['Phone: ',TEL{strcmpi(EX,LabMan{i})}]; %#ok<AGROW>
        S{end+1} = ' '; %#ok<AGROW>
    end
    for i = 1:length(CompTech)
        S{end+1} = 'Emergency Contact for:'; %#ok<AGROW>
        S{end+1} = 'Computer Tech'; %#ok<AGROW>
        S{end+1} = CompTech{i}; %#ok<AGROW>
        S{end+1} = ['Phone: ',TEL{strcmpi(EX,CompTech{i})}]; %#ok<AGROW>
        S{end+1} = ' '; %#ok<AGROW>
    end
    set(handles.note_edit,'string',S');

   
elseif get(handles.rat_button,'value') == 1
    
    EXP = cell(0);
    for i = 1:length(handles.active)
        temp = strcmp(ratR,handles.active{i});
        if sum(temp) == 0; continue; end
        
        C = cell(0);
        ctemp = contacts{temp};
        ctemp(ctemp == ' ') = ''; 
        if length(ctemp) < 2; continue; end

        st = 1;
        for j = 2:length(ctemp)
            if ctemp(j) == ',' 
                C{end+1} = ctemp(st:j-1); %#ok<AGROW>
                st = j+1;
            elseif j == length(ctemp)
                C{end+1} = ctemp(st:j); %#ok<AGROW>
                st = j+1;
            end
        end

        for j = 1:length(C)
            temp2 = strcmp(EM,C{j});
            if sum(temp2) == 0; continue; end
            EXP{end+1} = lower(EX{temp2}); %#ok<AGROW>
        end
    end
    EXP = unique(EXP);    
    for i = 1:length(EXP); EXP{i}(1) = upper(EXP{i}(1)); end
    
    S = cell(0);
    for i = 1:length(EXP)
        S{end+1} = 'Emergency Contact for:'; %#ok<AGROW>
        S{end+1} = [EXP{i},'']; %#ok<AGROW>
        S{end+1} = ['Phone: ',TEL{strcmpi(EX,EXP{i})}]; %#ok<AGROW>
        S{end+1} = ' '; %#ok<AGROW>
    end    
    
    LabMan = EX(logical(LM));
    for i = 1:length(LabMan); LabMan{i}(1) = upper(LabMan{i}(1)); end
    
    for i = 1:length(LabMan)
        S{end+1} = 'Emergency Contact for:'; %#ok<AGROW>
        S{end+1} = 'Lab Manager'; %#ok<AGROW>
        S{end+1} = LabMan{i}; %#ok<AGROW>
        S{end+1} = ['Phone: ',TEL{strcmpi(EX,LabMan{i})}]; %#ok<AGROW>
        S{end+1} = ' '; %#ok<AGROW>
    end
    
    set(handles.note_edit,'string',S');
    
else
    note = get(handles.note_edit,'string');
    usernum = get(handles.name_menu,'value');
    alluser = get(handles.name_menu,'string');
    user    = alluser{usernum};
    if isempty(note)
        msgbox('User must enter a note to text to all lab memebrs.');
    else
        answer = questdlg('Are you certain you want to text the entire lab?','Confirm Mass Text','Yes','No','No');
        
        if strcmp(answer,'Yes')
            
            try
                message = [note,' Contact ',user,' ',TEL{strcmp(EX,user)},' and coordinate response on Slack #Rigs.']; 
            catch
                message = note;
            end
            
            for i = 1:numel(EX)
                if ~strcmp(EX{i},'Carlos');
                    try
                        send_text_message(message,['Emergency TechNote from ',user],EX{i});
                    catch
                        msgbox(['Unable to text ',EX{i}]);
                    end
                    
                end
            end
        end
    end
end
    
    
    
    
    
    
function handles = TN_listexperimenters(handles)

handles = TN_clear(handles);

set(handles.rat_button,'value',0);
set(handles.rig_button,'value',0);
set(handles.tower_button,'value',0);
set(handles.session_button,'value',0);
%set(handles.experimenter_button,'value',0);
set(handles.general_button,'value',0);
set(handles.room_button,'value',0);


[contacts ratR] = bdata('select contact, ratname from ratinfo.rats where extant = 1');
[EX EM] = bdata('select experimenter, email from ratinfo.contacts');

for i = 1:length(EM)
    EM{i} = EM{i}(1:find(EM{i}=='@')-1);
end

EXP = cell(0);
for i = 1:length(ratR)
    
    C = cell(0);
    ctemp = contacts{i};
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

    
set(handles.items_edit,'string',EXP');
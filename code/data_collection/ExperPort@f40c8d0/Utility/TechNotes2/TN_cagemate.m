function TN_cagemate(handles)

if get(handles.rat_button,'value') == 1
    
    names = get(handles.name_menu,'string');
    tech  = names{get(handles.name_menu,'value')};

    [Rr,C] = bdata('select ratname, contact from ratinfo.rats where extant=1');
    [Exp,Eml,phone] = bdata('select experimenter, email, telephone from ratinfo.contacts where is_alumni=0');
    
    temp = strcmp(Exp,tech);
    if sum(temp) == 1
        techphone = phone(temp);
    end
    
    if numel(handles.active) < 1; msgbox('User must select 1 or 2 rats.'); return; end
    if numel(handles.active) > 2; msgbox('User cannot select more than 2 rats.'); return; end
    
    for i = 1:length(handles.active)
        ratname = handles.active{i};
        
        cm = bdata(['select cagemate from ratinfo.rats where ratname="',ratname,'"']);
        if iscell(cm) && ~isempty(cm); cm = cm{1}; end
        CM{i} = cm;
    end
    
    if numel(handles.active) == 1 && ~isempty(CM{1})
        handles.active{2} = CM{1};
        ratname = CM{1};
        
        cm = bdata(['select cagemate from ratinfo.rats where ratname="',ratname,'"']);
        if iscell(cm) && ~isempty(cm); cm = cm{1}; end
        CM{2} = cm;
    end
    
    do = 'nothing';
    if numel(handles.active) == 1 || numel(CM) == 1; msgbox('Nothing for me to do.'); return; end
    
    if strcmp(handles.active{1},CM{2}) && strcmp(handles.active{2},CM{1}) 
        do = 'separate';
    elseif strcmp(CM{1},'') && strcmp(CM{2},'')
        do = 'combine';
    end
    
    if strcmp(do,'separate')
        
        answer = questdlg(['Are you sure you want to separate ',handles.active{1},' and ',handles.active{2},'?'],'','Yes','No','No');
        
        if strcmp(answer,'Yes')
            ID1 = bdata(['select internalID from ratinfo.rats where ratname="',handles.active{1},'"']);
            if numel(ID1) == 1
                %mym(bdata,'update ratinfo.rats set cagemate="" where internalID="{S}"',ID1);
                bdata('call ratinfo.update_cagemate("{S}","{Si}")','',ID1);
            end

            ID2 = bdata(['select internalID from ratinfo.rats where ratname="',handles.active{2},'"']);
            if numel(ID2) == 1
                %mym(bdata,'update ratinfo.rats set cagemate="" where internalID="{S}"',ID2);
                bdata('call ratinfo.update_cagemate("{S}","{Si}")','',ID2);
            end

            msgbox([handles.active{1},' and ',handles.active{2},' split up.']);
        end
    elseif strcmp(do,'combine')
        
        answer = questdlg(['Are you sure you want to combine ',handles.active{1},' and ',handles.active{2},'?'],'','Yes','No','No');
        
        if strcmp(answer,'Yes')
            ID1 = bdata(['select internalID from ratinfo.rats where ratname="',handles.active{1},'"']);
            if numel(ID1) == 1
                %mym(bdata,['update ratinfo.rats set cagemate="',handles.active{2},'" where internalID="{S}"'],ID1);
                bdata('call ratinfo.update_cagemate("{S}","{Si}")',handles.active{2},ID1);
            end

            ID2 = bdata(['select internalID from ratinfo.rats where ratname="',handles.active{2},'"']);
            if numel(ID2) == 1
                %mym(bdata,['update ratinfo.rats set cagemate="',handles.active{1},'" where internalID="{S}"'],ID2);
                bdata('call ratinfo.update_cagemate("{S}","{Si}")',handles.active{1},ID2);
            end

            msgbox([handles.active{1},' and ',handles.active{2},' combined as cagemates.']);
        end
    else
        msgbox('I''m confused');
    end
    
end
      


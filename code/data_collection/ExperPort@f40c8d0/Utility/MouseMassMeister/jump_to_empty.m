function handles = jump_to_empty(handles)

str = get(handles.ratname_list,'string');
rtn = get(handles.ratname_list,'value');

foundempty = 0;
for i = rtn:length(str)
    w = str2num(str{i}(end-3:end)); %#ok<ST2NM>
    if isempty(w); foundempty = 1; break; end
end

if foundempty == 0
    %There were no empty entries below the starting position, but we should
    %check the entire session
    
    for i = 1:length(str)
        w = str2num(str{i}(end-3:end)); %#ok<ST2NM>
        if isempty(w); foundempty = 1; break; end
    end
    
    if foundempty == 0
        %All rats were weighed
        set(handles.start_toggle,'value',0);
        set(handles.colorbar1,'backgroundcolor',[1 1 1]);
        set(handles.colorbar2,'backgroundcolor',[1 1 1]);
        set(handles.ratname_text,'string','');

        grpstr = get(handles.session_list,'string');
        grpval = get(handles.session_list,'value');
        set(handles.status_text,'string',['Weighing Complete for ',grpstr{grpval}(1:end-3),' rats.'],...
            'backgroundcolor',[0 1 0]);

        return;
    end
end

set(handles.ratname_list,'value',i);
handles = update_ratname(handles);
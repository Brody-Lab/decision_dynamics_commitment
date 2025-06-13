function E = TN_determine_experimenters(handles)

E = cell(0);
if get(handles.rat_button,'Value') == 1
    for i = 1:numel(handles.active)
        temp = find(strcmp(handles.registry_rat,handles.active{i})==1,1,'first');
        for j = 1:numel(handles.registry_own{temp})
            E{end+1} = handles.registry_own{temp}{j};
        end
    end
    E = unique(E);
    
elseif get(handles.rig_button,'Value') == 1    
    for r = 1:numel(handles.active)
        rats = handles.schedule_rat(find(handles.schedule_rig == str2num(handles.active{r})));
        rats(strcmp(rats,'')) = [];
        for i = 1:numel(rats)
            temp = find(strcmp(handles.registry_rat,rats{i})==1,1,'first');
            for j = 1:numel(handles.registry_own{temp})
                E{end+1} = handles.registry_own{temp}{j};
            end
        end
    end
    E = unique(E);
    
elseif get(handles.tower_button,'Value') == 1
    for t = 1:numel(handles.active)
        rigs = str2num(handles.active{t});
        for r = 1:numel(rigs)
            rats = handles.schedule_rat(find(handles.schedule_rig == rigs(r)));
            rats(strcmp(rats,'')) = [];
            for i = 1:numel(rats)
                temp = find(strcmp(handles.registry_rat,rats{i})==1,1,'first');
                for j = 1:numel(handles.registry_own{temp})
                    E{end+1} = handles.registry_own{temp}{j};
                end
            end
        end
    end
    E = unique(E);
    
elseif get(handles.session_button,'Value') == 1
    for s = 1:numel(handles.active)
        rats = handles.schedule_rat(find(handles.schedule_ses == str2num(handles.active{s})));
        rats(strcmp(rats,'')) = [];
        for i = 1:numel(rats)
            temp = find(strcmp(handles.registry_rat,rats{i})==1,1,'first');
            for j = 1:numel(handles.registry_own{temp})
                E{end+1} = handles.registry_own{temp}{j};
            end
        end
    end
    E = unique(E);

elseif get(handles.experimenter_button,'Value') == 1
    E = unique(handles.active);
    
end
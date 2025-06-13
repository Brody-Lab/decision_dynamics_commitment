function handles = warn_running(handles,rig)

i = find(strcmp(handles.compnames(:,2),num2str(rig)) == 1);

if get(eval(['handles.rig',handles.compnames{i,2}]),'value') == 1
    str = get(eval(['handles.status',handles.compnames{i,2}]),'string');
    if length(str) > 7 && (strcmp(str(1:7),'Running') || ~isempty(str2num(str(2:4))))
        h = warndlg('','','modal');
        
        pos = get(h,'position');
        set(h,'position',[pos(1),pos(2),325,100]);
        c = get(get(h,'children'),'children');
        set(c{2},'string',{'WARNING: You have selected a rig','that appears to be running a rat!'});
        set(c{2},'fontsize',14);
    end
end
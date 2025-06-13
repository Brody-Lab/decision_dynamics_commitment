function handles = update_plot(handles)

axes(handles.axes1);
for i = 1:length(handles.datebounds)
    plot([handles.datebounds(i),handles.datebounds(i)],[0 2e3],':','color',[0.5 0.5 0.5],'linewidth',1);
    if i == 1; hold on; end
end



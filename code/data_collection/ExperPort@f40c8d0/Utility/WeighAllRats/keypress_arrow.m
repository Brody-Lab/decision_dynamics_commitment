function keypress_arrow(src, eventdata, handles)

global LAST_KEY_EVENT;

if strcmp(eventdata.Key, 'uparrow') || strcmp(eventdata.Key, 'downarrow')
    LAST_KEY_EVENT = eventdata;
end


end
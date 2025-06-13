function keypress_return(src, eventdata, handles)

global LAST_KEY_EVENT;

if strcmp(eventdata.Key, 'return')
    LAST_KEY_EVENT = eventdata;
end


end
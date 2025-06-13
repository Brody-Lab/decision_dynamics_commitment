function GCS_send_automated_script(code)

compnames = get_compnames;             
ignore = [5,6,31];

try 
    GCS_key
catch %#ok<CTCH>
    return;
end

message = num2str(double(code));
handles.now = datestr(now,'yyyy-mm-dd HH:MM:SS');
id = bdata('select id from gcs');
handles.id = max(id);
    
for i = 1:length(compnames)
    if sum(ignore == i) > 0; continue; end
    
    handles.id = handles.id + 1;
    code = GCS_makecode(handles);

    bdata(['insert into bdata.gcs set computer_name="',compnames{i,1},...
    '", dateval="',handles.now,'", job="run", completed=0, initials="XX"',...
    ', message="',message,'", code="',code,'"']);
end
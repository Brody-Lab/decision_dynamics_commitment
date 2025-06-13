function handles = get_newrats(handles)

try
    ratM = bdata(['select ratname from ratinfo.mass where date>"',datestr(now-180,'yyyy-mm-dd'),'"']);
    ratR = bdata('select ratname from ratinfo.rats where extant=1 order by ratname');
catch %#ok<CTCH>
    handles.newrats = {''};
    set(handles.status_text,'string','ERROR: Unable to connect to network.',...
        'backgroundcolor',[1 0 0]);
    return;
end

newrats = cell(0);
for i = 1:length(ratR);
    if sum(strcmp(ratM,ratR{i})) < 14;
        newrats{end+1} = ratR{i}; %#ok<AGROW>
    end
end

handles.newrats = newrats;
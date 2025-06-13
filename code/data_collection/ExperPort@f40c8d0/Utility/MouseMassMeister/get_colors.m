function handles = get_colors(handles)

try
     [C T] = bdata('select tag_RGB, tag_letter from ratinfo.contacts');
catch %#ok<CTCH>
    handles.colors = [];
    handles.rattag = [];
    set(handles.status_text,'string','ERROR: Unable to connect to network.',...
        'backgroundcolor',[1 0 0]);
    return
end

empties = strcmp(T,'');
C(empties) = [];
T(empties) = [];

for i=1:length(C)
    if strcmp(C{i},''); C{i} = [1 1 1]; end
end

for i=1:length(C); 
    if ischar(C{i}); handles.colors(i,:) = str2num(C{i});  %#ok<ST2NM>
    else             handles.colors(i,:) = C{i};
    end
end
for i=1:length(T);   handles.rattag(i)   = T{i}; end

handles.colors = handles.colors / 255; 
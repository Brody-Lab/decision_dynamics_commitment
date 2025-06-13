function handles = update_ratname(handles)

str = get(handles.ratname_list,'string');
rtn = get(handles.ratname_list,'value');

if isempty(str) || rtn == 0; return; end
temp = str{rtn};

ratname = temp(1:4);
mass = str2num(temp(end-4:end)); %#ok<ST2NM>
if strcmp(temp(end-4:end),'New!!'); newrat = 1; else newrat=0; end

ratpos = find(handles.rattag == ratname(1),1,'first');
if ~isempty(ratpos); ratclr = handles.colors(ratpos,:);
else                 ratclr = [1 1 1];
end

rfw = 0;
chm = 0;

instr = bdata(['select instructions from ratinfo.schedule where ratname="',...
    temp,'" and date="',datestr(now,'yyyy-mm-dd'),'"']);
if ~isempty(instr) 
    if ~isempty(strfind(lower(instr{1}),'remove')) &&...
       ~isempty(strfind(lower(instr{1}),'free'))   &&...
       ~isempty(strfind(lower(instr{1}),'water')); 
    
        rfw = 1;
    
    elseif ~isempty(strfind(lower(instr{1}),'check hematuria'))
        chm = 1;
    end

end

set(handles.colorbar1,'backgroundcolor',ratclr);
set(handles.colorbar2,'backgroundcolor',ratclr);


set(handles.ratname_text,'string',ratname);
if ~isempty(mass)
    set(handles.status_text,'string','Is it the CORRECT RAT? Reweigh.',...
        'backgroundcolor',[1 0.6 0.8]);
elseif rfw == 1
    set(handles.status_text,'string','Remove from free water. Place on scale',...
        'backgroundcolor',[0 1 1]);
    
elseif chm == 1
    set(handles.status_text,'string','Check for hematuria. Place on scale',...
        'backgroundcolor',[0.9 0.2 0]);
    
else
    if newrat == 1
        set(handles.status_text,'string','CAREFUL, New rat! Place on the scale.',...
            'backgroundcolor',[1 1 0]);
    else
        set(handles.status_text,'string','Place the rat on the scale.',...
            'backgroundcolor',[1 1 1]);
    end
end

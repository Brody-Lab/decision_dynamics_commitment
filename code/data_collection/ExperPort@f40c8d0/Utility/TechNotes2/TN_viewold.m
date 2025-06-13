function handles = TN_viewold(handles)

dstr = get(handles.date_text,'string');
if isempty(dstr)
    [dates,times,rats,rigs,slots,exps,initials,notes] = bdata(['select datestr, timestr, ratname, rigid, timeslot, experimenter,',...
        ' techinitials, note from ratinfo.technotes']);
else
    [dates,times,rats,rigs,slots,exps,initials,notes] = bdata(['select datestr, timestr, ratname, rigid, timeslot, experimenter,',...
        ' techinitials, note from ratinfo.technotes where datestr="',dstr,'"']);
end

S = cell(0);
if get(handles.rat_button,'value') == 1
    good1 = ~strcmp(rats,'') & isnan(rigs) & isnan(slots) & strcmp(exps,'');
    good2 = false(size(good1));
    if isempty(handles.active)
        good2 = good1;
    else
        for i = 1:length(handles.active)
            good2 = good2 + (good1 & strcmp(rats,handles.active{i}));
        end
    end
    good = find(good2 == 1);
    
    for i = 1:length(good)
        S{end+1} = ['TechNote by ',upper(initials{good(i)}),' at ',times{good(i)},' on ',dates{good(i)},' for Rat ',rats{good(i)}]; %#ok<AGROW>
        S{end+1} = char(notes{good(i)})'; %#ok<AGROW>
        S{end+1} = ' '; %#ok<AGROW>
    end
    
elseif get(handles.rig_button,'value') == 1 || get(handles.tower_button,'value') == 1
    good1 = strcmp(rats,'') & ~isnan(rigs) & isnan(slots) & strcmp(exps,'');
    good2 = false(size(good1));
    if isempty(handles.active)
        good2 = good1;
    else
        for i = 1:length(handles.active)
            R = handles.active{i}; R(R == ',') = ' '; R = str2num(R); %#ok<ST2NM>
            for r = 1:length(R)
                good2 = good2 + (good1 & (rigs == R(r))); 
            end
        end
    end
    good = find(good2 == 1);
    
    for i = 1:length(good)
        S{end+1} = ['TechNote by ',upper(initials{good(i)}),' at ',times{good(i)},' on ',dates{good(i)},' for Rig ',num2str(rigs(good(i)))]; %#ok<AGROW>
        S{end+1} = char(notes{good(i)})'; %#ok<AGROW>
        S{end+1} = ' '; %#ok<AGROW>
    end
    
elseif get(handles.session_button,'value') == 1    
    good1 = strcmp(rats,'') & isnan(rigs) & ~isnan(slots) & strcmp(exps,'');
    good2 = false(size(good1));
    if isempty(handles.active)
        good2 = good1;
    else
        for i = 1:length(handles.active)
            good2 = good2 + (good1 & (slots == str2num(handles.active{i}))); %#ok<ST2NM>
        end
    end
    good = find(good2 == 1);
    
    for i = 1:length(good)
        S{end+1} = ['TechNote by ',upper(initials{good(i)}),' at ',times{good(i)},' on ',dates{good(i)},' for Session ',num2str(slots(good(i)))]; %#ok<AGROW>
        S{end+1} = char(notes{good(i)})'; %#ok<AGROW>
        S{end+1} = ' '; %#ok<AGROW>
    end
    
elseif get(handles.experimenter_button,'value') == 1    
    good1 = strcmp(rats,'') & isnan(rigs) & isnan(slots) & ~strcmp(exps,'');
    good2 = false(size(good1));
    if isempty(handles.active)
        good2 = good1;
    else
        for i = 1:length(handles.active)
            good2 = good2 + (good1 & (strcmp(exps,handles.active{i})));
        end
    end
    good = find(good2 == 1);
    
    for i = 1:length(good)
        S{end+1} = ['TechNote by ',upper(initials{good(i)}),' at ',times{good(i)},' on ',dates{good(i)},' for ',exps{good(i)}]; %#ok<AGROW>
        S{end+1} = char(notes{good(i)})'; %#ok<AGROW>
        S{end+1} = ' '; %#ok<AGROW>
    end
    
elseif get(handles.general_button,'value') == 1
    good = find((strcmp(rats,'') & isnan(rigs) & isnan(slots) & strcmp(exps,'')) == 1);
    for i = 1:length(good)
        S{end+1} = ['General TechNote by ',upper(initials{good(i)}),' at ',times{good(i)},' on ',dates{good(i)}]; %#ok<AGROW>
        S{end+1} = char(notes{good(i)})'; %#ok<AGROW>
        S{end+1} = ' '; %#ok<AGROW>
    end
else
    for i = 1:length(notes)
        if     ~strcmp(rats{i},'') &&  isnan(rigs(i)) &&  isnan(slots(i)) &&  strcmp(exps{i},'')
            S{end+1} = ['TechNote by ',upper(initials{i}),' at ',times{i},' on ',dates{i},' for Rat ',rats{i}]; %#ok<AGROW>
        elseif  strcmp(rats{i},'') && ~isnan(rigs(i)) &&  isnan(slots(i)) &&  strcmp(exps{i},'')
            S{end+1} = ['TechNote by ',upper(initials{i}),' at ',times{i},' on ',dates{i},' for Rig ',num2str(rigs(i))]; %#ok<AGROW>
        elseif  strcmp(rats{i},'') &&  isnan(rigs(i)) && ~isnan(slots(i)) &&  strcmp(exps{i},'')
            S{end+1} = ['TechNote by ',upper(initials{i}),' at ',times{i},' on ',dates{i},' for Session ',num2str(slots(i))]; %#ok<AGROW>
        elseif  strcmp(rats{i},'') &&  isnan(rigs(i)) &&  isnan(slots(i)) && ~strcmp(exps{i},'')
            S{end+1} = ['TechNote by ',upper(initials{i}),' at ',times{i},' on ',dates{i},' for ',exps{i}]; %#ok<AGROW>
        else
            S{end+1} = ['General TechNote by ',upper(initials{i}),' at ',times{i}]; %#ok<AGROW> 
        end
        S{end+1} = char(notes{i})'; %#ok<AGROW>
        S{end+1} = ' '; %#ok<AGROW>
    end
    
end
set(handles.oldnotes_edit,'string',S);





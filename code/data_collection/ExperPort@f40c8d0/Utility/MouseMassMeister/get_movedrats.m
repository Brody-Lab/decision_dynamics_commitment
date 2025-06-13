function handles = get_movedrats(handles)

[ry,sy] = bdata(['select ratname, timeslot from ratinfo.schedule where date="',datestr(now-1,'yyyy-mm-dd'),'"']);
[rt,st] = bdata(['select ratname, timeslot from ratinfo.schedule where date="',datestr(now,'yyyy-mm-dd'),'"']);

%badind=find(sy==9&rry==17);
%goodind=setdiff(1:length(rry),badind);
%ry=ry(goodind);
%sy=sy(goodind);

handles.movedrats = cell(0);
handles.movedfrom = [];

%First we look for rats on the schedule today that either weren't on it
%yesterday or were on a different session yesterday
for i = 1:numel(rt)
    if strcmp(rt{i},''); continue; end
    if sum(strcmp(ry,rt{i})) == 0
        %This rat wasn't on the schedule yesterday, probably on free water
        handles.movedrats{end+1} = rt{i};
        handles.movedfrom(end+1) = 10;
    else
        ty = sy(find(strcmp(ry,rt{i})==1,1,'last'));
        tt = st(i);
        
        if ty ~= tt && ~isempty(ty) && ~isempty(tt)
            %This rat trained in a different session yesterday and may be
            %on a different tower
            handles.movedrats{end+1} = rt{i};
            handles.movedfrom(end+1) = ty;
            
        elseif isempty(ty) 
            handles.movedrats{end+1} = rt{i};
            handles.movedfrom(end+1) = 10;
            
        end
    end
end

%Now we look for rats that were on the schedule yesterday but aren't on it
%today
for i = 1:numel(ry)
    if strcmp(rt{i},''); continue; end
    if sum(strcmp(rt,ry{i})) == 0
        handles.movedrats{end+1} = ry{i};
        handles.movedfrom(end+1) = sy(i);
    end
end


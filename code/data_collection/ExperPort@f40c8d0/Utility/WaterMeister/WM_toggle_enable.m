function handles = WM_toggle_enable(handles)

f = fields(handles);

for i = 1:numel(f)
    h = eval(['handles.',f{i}]);
    try %#ok<TRYNC>
        if     strcmp(get(h,'enable'),'on');  set(h,'enable','off');
        elseif strcmp(get(h,'enable'),'off'); set(h,'enable','on');
        end
    end
end

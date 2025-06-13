function remove_svn_from_path

try
    x = path;
    if x(1)   ~= ';'; x = [';',x]; end;
    if x(end) ~= ';'; x = [x,';']; end;

    seps = find(x == ';');
    bad = zeros(size(x));
    for i=1:length(seps)-1;
        ptemp = x(seps(i)+1:seps(i+1)-1);

        if ~isempty(strfind(lower(ptemp),[filesep,'.svn'])) ||...
           ~isempty(strfind(lower(ptemp),[filesep,'cvs']))  ||...
           ~isempty(strfind(lower(ptemp),[filesep,'.git']));
            bad(seps(i)+1:seps(i+1)) = 1;
        end;
    end;

    newx = x(bad == 0);
    if newx(1)   == ';'; newx = newx(2:end);   end;
    if newx(end) == ';'; newx = newx(1:end-1); end;

    path(newx);
    savepath;

catch %#ok<CTCH>
    senderror_report;
end